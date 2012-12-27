//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_NS2Utlility.lua

local HotReload = CombatNS2Utility
if(not HotReload) then
  CombatNS2Utility = {}
  ClassHooker:Mixin("CombatNS2Utility")
end
    
function CombatNS2Utility:OnLoad()
    self:ReplaceFunction("AttackMeleeCapsule", "AttackMeleeCapsule_Hook")    
    self:ReplaceClassFunction("Spit", "ProcessHit", "ProcessHit_Hook") 
    self:ReplaceFunction("GetAreEnemies", "GetAreEnemies_Hook") 
	self:ReplaceFunction("GetRandomSpawnForCapsule", "GetRandomSpawnForCapsule_Hook")
    self:PostHookFunction("UpdateAbilityAvailability", "UpdateAbilityAvailability_Hook"):SetPassHandle(true)
end

// for focus to make more dmg
function CombatNS2Utility:AttackMeleeCapsule_Hook(weapon, player, damage, range, optionalCoords, altMode)

    // Enable tracing on this capsule check, last argument.
    local didHit, target, endPoint, direction, surface = CheckMeleeCapsule(weapon, player, damage, range, optionalCoords, true)
    
    if didHit then
        // check if player has focus then do more dmg, only on some weapons, so check weapon
        if player:GotFocus() then
            damage = damage * kCombatFocusDamageScalar
        end
        
        weapon:DoDamage(damage, target, endPoint, direction, surface, altMode)
        
    end
    
    return didHit, target, endPoint, surface
    
end

// only possible to replace it, hooking the mixin or the function is not possible

function CombatNS2Utility:ProcessHit_Hook(self, targetHit, surface, normal)

    if normal:GetLength() == 0 then
        DestroyEntity(self)
        
    elseif not targetHit then
    
        self.onSurface = true
        
        local coords = Coords.GetIdentity()
        coords.origin = self:GetOrigin()
        coords.yAxis = normal
        coords.zAxis = GetNormalizedVector(self.desiredVelocity)
        coords.xAxis = coords.zAxis:CrossProduct(coords.yAxis)
        coords.zAxis = coords.yAxis:CrossProduct(coords.xAxis)
        
        self:SetCoords(coords)

    // Don't hit owner - shooter
    elseif self:GetOwner() ~= targetHit then
    
        self:TriggerEffects("spit_hit", { effecthostcoords = Coords.GetTranslation(self:GetOrigin()) } )
    
        if self:GetOwner():GotFocus() then
            self:DoDamage(Spit.kDamage * kCombatFocusDamageScalar, targetHit, self:GetOrigin(), nil, surface)
        else
            self:DoDamage(Spit.kDamage, targetHit, self:GetOrigin(), nil, surface)
        end
        
        if targetHit and targetHit:isa("Marine") then
        
            local direction = self:GetOrigin() - targetHit:GetEyePos()
            direction:Normalize()
            targetHit:OnSpitHit(direction)
            
        end
        
        DestroyEntity(self)
        
    end    
    
end


function CombatNS2Utility:GetAreEnemies_Hook(entityOne, entityTwo)
    return entityOne and entityTwo and HasMixin(entityOne, "Team") and HasMixin(entityTwo, "Team") and (
            (entityOne:GetTeamNumber() == kMarineTeamType and entityTwo:GetTeamNumber() == kAlienTeamType) or
            (entityOne:GetTeamNumber() == kAlienTeamType and entityTwo:GetTeamNumber() == kMarineTeamType)
            or entityOne:GetTeamNumber() == kNeutralTeamType or entityTwo:GetTeamNumber() == kNeutralTeamType)
end

/**
 * Returns the spawn point on success, nil on failure.
 */
local function ValidateSpawnPoint(spawnPoint, capsuleHeight, capsuleRadius, filter, origin)

    local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)
    local spawnPointCenter = spawnPoint + center
    
    // Make sure capsule isn't interpenetrating something.
    local spawnPointBlocked = Shared.CollideCapsule(spawnPointCenter, capsuleRadius, capsuleHeight, CollisionRep.Default, PhysicsMask.AllButPCs, nil)
    if not spawnPointBlocked then

        // Trace capsule to ground, making sure we're not on something like a player or structure
        local trace = Shared.TraceCapsule(spawnPointCenter, spawnPoint - Vector(0, 10, 0), capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.AllButPCs)            
        if trace.fraction < 1 and (trace.entity == nil or not trace.entity:isa("ScriptActor")) then
        
            VectorCopy(trace.endPoint, spawnPoint)
            
            local endPoint = trace.endPoint + Vector(0, capsuleHeight / 2, 0)
            // Trace in both directions to make sure no walls are being ignored.
            trace = Shared.TraceRay(endPoint, origin, CollisionRep.Move, PhysicsMask.AllButPCs, filter)
            local traceOriginToEnd = Shared.TraceRay(origin, endPoint, CollisionRep.Move, PhysicsMask.AllButPCs, filter)
            
            if trace.fraction == 1 and traceOriginToEnd.fraction == 1 then
                return spawnPoint - Vector(0, capsuleHeight / 2, 0)
            end
            
        end
        
    end
    
    return nil
    
end

// Find place for player to spawn, within range of origin. Makes sure that a line can be traced between the two points
// without hitting anything, to make sure you don't spawn on the other side of a wall. Returns nil if it can't find a 
// spawn point after a few tries.
function CombatNS2Utility:GetRandomSpawnForCapsule_Hook(capsuleHeight, capsuleRadius, origin, minRange, maxRange, filter, validationFunc)

    ASSERT(capsuleHeight > 0)
    ASSERT(capsuleRadius > 0)
    ASSERT(origin ~= nil)
    ASSERT(type(minRange) == "number")
    ASSERT(type(maxRange) == "number")
    ASSERT(maxRange > minRange)
    ASSERT(minRange > 0)
    ASSERT(maxRange > 0)
    
	// Now set in combat_Values.lua - see kSpawnMaxVertical
    //local maxHeight = 10
    
    for i = 0, kSpawnMaxRetries do
    
        local spawnPoint = nil
		local points = GetRandomPointsWithinRadius(origin, minRange, minRange*2 + ((maxRange-minRange*2) * i / kSpawnMaxRetries), kSpawnMaxVertical, 1, 1, nil, validationFunc)
        if #points == 1 then
            spawnPoint = points[1]
        elseif Server then
            Print("GetRandomPointsWithinRadius() failed inside of GetRandomSpawnForCapsule()")
        end
        
        if spawnPoint then
        
            // The spawn point returned by GetRandomPointsWithinRadius() may be too close to the ground.
            // Move it up a bit so there is some "wiggle" room. ValidateSpawnPoint() traces down anyway.
            spawnPoint = spawnPoint + Vector(0, 0.5, 0)
            local validSpawnPoint = ValidateSpawnPoint(spawnPoint, capsuleHeight, capsuleRadius, filter, origin)
            if validSpawnPoint then
                return validSpawnPoint
            end
            
        end
        
    end
    
    return nil
    
end

// to get tier2 and tier3 working again
local function UnlockAbility(forAlien, techId)

    local mapName = LookupTechData(techId, kTechDataMapName)
    if mapName and forAlien:GetIsAlive() then
    
        local activeWeapon = forAlien:GetActiveWeapon()

        local tierWeapon = forAlien:GetWeapon(mapName)
        if not tierWeapon then
            forAlien:GiveItem(mapName)
        end
        
        if activeWeapon then
            forAlien:SetActiveWeapon(activeWeapon:GetMapName())
        end
    
    end

end

function CombatNS2Utility:UpdateAbilityAvailability_Hook(handle, forAlien, tierTwoTechId, tierThreeTechId)
    
    forAlien:CheckCombatData()
    if tierTwoTechId then
        if forAlien.combatTable.twoHives then
            UnlockAbility(forAlien, tierTwoTechId)
            handle:BlockOrignalCall()
        end
    end 
        
    if tierThreeTechId then
        if forAlien.combatTable.threeHives then
            UnlockAbility(forAlien, tierThreeTechId)
            handle:BlockOrignalCall()
        end
    end   
 
    // enable new abilities
    if forAlien:isa("Onos") and forAlien.combatTable.threeHives then
        // only if we dont got already devour
        local abilities = GetChildEntities(forAlien, "Devour")
        if (abilities ~= nil) and (#abilities == 0) then
            forAlien:GiveItem(Devour.kMapName)
            handle:BlockOrignalCall()
        end
    end

end

if (not HotReload) then
	CombatNS2Utility:OnLoad()
end