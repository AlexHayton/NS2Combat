//________________________________
//
// NS2 Combat Mod
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

-- Players heal by base amount + percentage of max health
local kHealPlayerPercent = 3

local kRange = 6
local kHealCylinderWidth = 3
 
local kHealScoreAdded = 2
-- Every kAmountHealedForPoints points of damage healed, the player gets
-- kHealScoreAdded points to their score.
local kAmountHealedForPoints = 400

local function GetHealOrigin(self, player)

    -- Don't project origin the full radius out in front of Gorge or we have edge-case problems with the Gorge 
    -- not being able to hear himself
    local startPos = player:GetEyePos()
    local endPos = startPos + (player:GetViewAngles():GetCoords().zAxis * kHealsprayRadius * .9)
    local trace = Shared.TraceRay(startPos, endPos, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterOne(player))
    return trace.endPoint
    
end

local function DamageEntity(self, player, targetEntity)

    local healthScalar = targetEntity:GetHealthScalar()
    self:DoDamage(kHealsprayDamage, targetEntity, targetEntity:GetEngagementPoint(), GetNormalizedVector(targetEntity:GetOrigin(), player:GetEyePos()), "none")

end

local function HealEntity(self, player, targetEntity)

    local onEnemyTeam = (GetEnemyTeamNumber(player:GetTeamNumber()) == targetEntity:GetTeamNumber())
    local isEnemyPlayer = onEnemyTeam and targetEntity:isa("Player")
    local toTarget = (player:GetEyePos() - targetEntity:GetOrigin()):GetUnit()
    
    -- Heal players by base amount plus a scaleable amount so it's effective vs. small and large targets.
    local health = kHealsprayDamage + targetEntity:GetMaxHealth() * kHealPlayerPercent / 100.0
    
    -- Heal structures by multiple of damage(so it doesn't take forever to heal hives, ala NS1)
    if GetReceivesStructuralDamage(targetEntity) then
        health = 60
    -- Don't heal self at full rate - don't want Gorges to be too powerful. Same as NS1.
    elseif targetEntity == player then
        health = health * 0.5
    end
    
    local amountHealed = targetEntity:AddHealth(health, true, false, true, player)
    
    -- Do not count amount self healed.
    if targetEntity ~= player then
	
		/*
		 * Addition for Combat Mode to give XP for healing.
		 */
		local maxXp = GetXpValue(targetEntity) or 1
		local healXp = 0
		if targetEntity:isa("Player") then
			val = (maxXp * kPlayerHealXpRate * kHealXpRate * amountHealed / targetEntity:GetMaxHealth())
			healXp = math.floor( (val * 10) + 0.5) / (10)
		else
			val = (maxXp * kHealXpRate * amountHealed / targetEntity:GetMaxHealth())
			healXp = math.floor( (val * 10) + 0.5) / (10)
		end
			
		player:AddXp(healXp)
		
    end
    
    if targetEntity.OnHealSpray then
        targetEntity:OnHealSpray(player)
    end
    
    -- Put out entities on fire sometimes.
    if HasMixin(targetEntity, "GameEffects") and math.random() < kSprayDouseOnFireChance then
        targetEntity:SetGameEffectMask(kGameEffect.OnFire, false)
    end
    
    if Server and amountHealed > 0 then
        targetEntity:TriggerEffects("sprayed")
    end
    
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

local function GetEntitiesInCylinder(self, player, viewCoords, range, width)

    -- gorge always heals itself
    local ents = { player }
    local startPoint = viewCoords.origin
    local fireDirection = viewCoords.zAxis
    
    local relativePos = nil
    
    for _, entity in ipairs( GetEntitiesWithMixinWithinRange("Live", startPoint, range) ) do
    
        if entity:GetIsAlive() then
    
            relativePos = entity:GetOrigin() - startPoint
            local yDistance = viewCoords.yAxis:DotProduct(relativePos)
            local xDistance = viewCoords.xAxis:DotProduct(relativePos)
            local zDistance = viewCoords.zAxis:DotProduct(relativePos)

            local xyDistance = math.sqrt(yDistance * yDistance + xDistance * xDistance)

            -- could perform a LOS check here or simply keeo the code a bit more tolerant. healspray is kinda gas and it would require complex calculations to make this check be exact
            if xyDistance <= width and zDistance >= 0 then
                table.insert(ents, entity)
            end
            
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
            
            local effectCoords = Coords.GetLookIn(GetHealOrigin(self, player), player:GetViewCoords().zAxis)
            player:TriggerEffects("heal_spray", { effecthostcoords = effectCoords })
            
            self.lastSecondaryAttackTime = Shared.GetTime()
        
        end
    
    end
    
end

