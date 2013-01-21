//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________


// Players heal by base amount + percentage of max health
local kHealPlayerPercent = 3

// Structures heal by base x this multiplier (same as NS1)
local kHealStructuresMultiplier = 5

local kRange = 6
local kHealCylinderWidth = 3

local function GetHealOrigin(self, player)

    // Don't project origin the full radius out in front of Gorge or we have edge-case problems with the Gorge 
    // not being able to hear himself
    local startPos = player:GetEyePos()
    local endPos = startPos + (player:GetViewAngles():GetCoords().zAxis * kHealsprayRadius * .9)
    local trace = Shared.TraceRay(startPos, endPos, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
    return trace.endPoint
    
end

local function DamageEntity(self, player, targetEntity)

    local healthScalar = targetEntity:GetHealthScalar()
    self:DoDamage(kHealsprayDamage, targetEntity, targetEntity:GetEngagementPoint(), GetNormalizedVector(targetEntity:GetOrigin(), player:GetEyePos()), "none")
    
    if Server and healthScalar ~= targetEntity:GetHealthScalar() then
        targetEntity:TriggerEffects("sprayed")
    end

end

local function HealEntity(self, player, targetEntity)

    local onEnemyTeam = (GetEnemyTeamNumber(player:GetTeamNumber()) == targetEntity:GetTeamNumber())
    local isEnemyPlayer = onEnemyTeam and targetEntity:isa("Player")
    local toTarget = (player:GetEyePos() - targetEntity:GetOrigin()):GetUnit()

    // Heal players by base amount plus a scaleable amount so it's effective vs. small and large targets            
    local health = kHealsprayDamage + targetEntity:GetMaxHealth() * kHealPlayerPercent / 100.0
    
    // Heal structures by multiple of damage(so it doesn't take forever to heal hives, ala NS1)
    if GetReceivesStructuralDamage(targetEntity) then
        health = 60
    // Don't heal self at full rate - don't want Gorges to be too powerful. Same as NS1.
    elseif targetEntity == player then
        health = health * .5
    end
    
    local amountHealed = targetEntity:AddHealth(health)
    
    /*
	 * Addition for Combat Mode to give XP for healing.
	 */
	local maxXp = GetXpValue(targetEntity)
	local healXp = 0
	if targetEntity:isa("Player") then
		val = (maxXp * kPlayerHealXpRate * kHealXpRate * amountHealed / targetEntity:GetMaxHealth())
		healXp = math.floor( (val * 10) + 0.5) / (10)
	else
		val = (maxXp * kHealXpRate * amountHealed / targetEntity:GetMaxHealth())
		healXp = math.floor( (val * 10) + 0.5) / (10)
	end
		
	// Award XP, but only the player is not the parent
	if targetEntity:isa("Player") or targetEntity:GetOwner() ~= player then
	    player:AddXp(healXp)
    end

    if targetEntity.OnHealSpray then
        targetEntity:OnHealSpray(player)
    end         
    
    // Put out entities on fire sometimes
    if HasMixin(targetEntity, "GameEffects") and math.random() < kSprayDouseOnFireChance then
        targetEntity:SetGameEffectMask(kGameEffect.OnFire, false)
    end
    
    if Server and amountHealed > 0 then
        targetEntity:TriggerEffects("sprayed")
    end
        
end

local kConeWidth = 0.6
local function GetEntitiesWithCapsule(self, player)

    local fireDirection = player:GetViewCoords().zAxis
    // move a bit back for more tolerance, healspray does not need to be 100% exact
    local startPoint = player:GetEyePos() + player:GetViewCoords().yAxis * 0.2

    local extents = Vector(kConeWidth, kConeWidth, kConeWidth)
    local remainingRange = kRange
 
    local ents = {}
    
    // always heal self as well
    HealEntity(self, player, player)
    
    for i = 1, 4 do
    
        if remainingRange <= 0 then
            break
        end
        
        local trace = TraceMeleeBox(self, startPoint, fireDirection, extents, remainingRange, PhysicsMask.Melee, EntityFilterOne(player))
        
        if trace.fraction ~= 1 then
        
            if trace.entity then
            
                if HasMixin(trace.entity, "Live") then
                    table.insertunique(ents, trace.entity)
                end
        
            else
            
                // Make another trace to see if the shot should get deflected.
                local lineTrace = Shared.TraceRay(startPoint, startPoint + remainingRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterOne(player))
                
                if lineTrace.fraction < 0.8 then
                
                    local dotProduct = trace.normal:DotProduct(fireDirection) * -1

                    if dotProduct > 0.6 then
                        self:TriggerEffects("healspray_collide",  {effecthostcoords = Coords.GetTranslation(lineTrace.endPoint)})
                        break
                    else                    
                        fireDirection = fireDirection + trace.normal * dotProduct
                        fireDirection:Normalize()
                    end    
                        
                end
                
            end
            
            remainingRange = remainingRange - (trace.endPoint - startPoint):GetLength() - kConeWidth
            startPoint = trace.endPoint + fireDirection * kConeWidth + trace.normal * 0.05
        
        else
            break
        end

    end
    
    return ents

end


local function GetEntitiesInCylinder(self, player, viewCoords, range, width)

    // gorge always heals itself    
    local ents = { player }
    local startPoint = viewCoords.origin
    local fireDirection = viewCoords.zAxis
    
    local relativePos = nil
    
    for _, entity in ipairs( GetEntitiesWithMixinWithinRange("Live", startPoint, range) ) do
    
        relativePos = entity:GetOrigin() - startPoint
        local yDistance = viewCoords.yAxis:DotProduct(relativePos)
        local xDistance = viewCoords.xAxis:DotProduct(relativePos)
        local zDistance = viewCoords.zAxis:DotProduct(relativePos)

        local xyDistance = math.sqrt(yDistance * yDistance + xDistance * xDistance)

        // could perform a LOS check here or simply keeo the code a bit more tolerant. healspray is kinda gas and it would require complex calculations to make this check be exact
        if xyDistance <= width and zDistance >= 0 then
            table.insert(ents, entity)
        end
    
    end
    
    return ents

end

local function GetEntitiesInCone(self, player)

    local range = 0
    
    local viewCoords = player:GetViewCoords()
    local fireDirection = viewCoords.zAxis
    
    local startPoint = viewCoords.origin + viewCoords.yAxis * kHealCylinderWidth * 0.2
    local lineTrace1 = Shared.TraceRay(startPoint, startPoint + kRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterAll())
    if (lineTrace1.endPoint - startPoint):GetLength() > range then
        range = (lineTrace1.endPoint - startPoint):GetLength()
    end

    startPoint = viewCoords.origin - viewCoords.yAxis * kHealCylinderWidth * 0.2
    local lineTrace2 = Shared.TraceRay(startPoint, startPoint + kRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterAll())    
    if (lineTrace2.endPoint - startPoint):GetLength() > range then
        range = (lineTrace2.endPoint - startPoint):GetLength()
    end
    
    startPoint = viewCoords.origin - viewCoords.xAxis * kHealCylinderWidth * 0.2
    local lineTrace3 = Shared.TraceRay(startPoint, startPoint + kRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterAll())    
    if (lineTrace3.endPoint - startPoint):GetLength() > range then
        range = (lineTrace3.endPoint - startPoint):GetLength()
    end
    
    startPoint = viewCoords.origin + viewCoords.xAxis * kHealCylinderWidth * 0.2
    local lineTrace4 = Shared.TraceRay(startPoint, startPoint + kRange * fireDirection, CollisionRep.LOS, PhysicsMask.Melee, EntityFilterAll())
    if (lineTrace4.endPoint - startPoint):GetLength() > range then
        range = (lineTrace4.endPoint - startPoint):GetLength()
    end

    return GetEntitiesInCylinder(self, player, viewCoords, range, kHealCylinderWidth)

end

local function PerformHealSpray(self, player)
 
    for _, entity in ipairs(GetEntitiesInCone(self, player)) do
    
        if HasMixin(entity, "Team") then
        
            if entity:GetTeamNumber() == player:GetTeamNumber() then
                HealEntity(self, player, entity)
            elseif GetAreEnemies(entity, player) then
                DamageEntity(self, player, entity)
            end

        end
                
    end

end

function HealSprayMixin:OnTag(tagName)

    PROFILE("HealSprayMixin:OnTag")

    if self.secondaryAttacking and tagName == "heal" then
        
        local player = self:GetParent()
        if player and player:GetEnergy() >= self:GetSecondaryEnergyCost(player) then
        
            PerformHealSpray(self, player)            
            player:DeductAbilityEnergy(self:GetSecondaryEnergyCost(player))
            self:TriggerEffects("heal_spray")
            self.lastSecondaryAttackTime = Shared.GetTime()
        
        end
    
    end
    
end