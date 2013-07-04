//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Alien_Hooks.lua

local HotReload = CombatAlien
if(not HotReload) then
    CombatAlien = {}
	ClassHooker:Mixin("CombatAlien")
end
    
function CombatAlien:OnLoad()

    _addHookToTable(self:ReplaceClassFunction("Alien", "GetHasTwoHives","GetHasTwoHives_Hook"))
    _addHookToTable(self:ReplaceClassFunction("Alien", "GetHasThreeHives","GetHasThreeHives_Hook"))
	_addHookToTable(self:ReplaceClassFunction("Alien", "UpdateArmorAmount","UpdateArmorAmount_Hook"))
	_addHookToTable(self:ReplaceClassFunction("Alien", "UpdateHealAmount","UpdateHealAmount_Hook"))	
    _addHookToTable(self:PostHookClassFunction("Alien", "OnUpdateAnimationInput","OnUpdateAnimationInput_Hook"))
   
    if Server then
        self:PostHookClassFunction("Alien", "GetCanTakeDamageOverride", "GetCanTakeDamageOverride_Hook"):SetPassHandle(true)
    end
   
	
end

function CombatAlien:GetHasTwoHives_Hook(self)
	return self.twoHives
end

function CombatAlien:GetHasThreeHives_Hook(self)
	return self.threeHives
end

function CombatAlien:UpdateArmorAmount_Hook(self, carapaceLevel)

    local level = math.min(self:GetLvl(), 12)
    local newMaxArmor = (level / 12) * (self:GetArmorFullyUpgradedAmount() - self:GetBaseArmor()) + self:GetBaseArmor()

    if newMaxArmor ~= self.maxArmor then

        local armorPercent = self.maxArmor > 0 and self.armor/self.maxArmor or 0
        self.maxArmor = newMaxArmor
        self:SetArmor(self.maxArmor * armorPercent)
    
    end

end

function CombatAlien:UpdateHealAmount_Hook(self, bioMassLevel, maxLevel)

	// Cap the health level at the max biomass level
    local level = math.max(0, self:GetLvl() - 1)
    local newMaxHealth = self:GetBaseHealth() + level * self:GetHealthPerBioMass()

    if newMaxHealth ~= self.maxHealth then

        local healthPercent = self.maxHealth > 0 and self.health/self.maxHealth or 0
        self.maxHealth = newMaxHealth
        self:SetHealth(self.maxHealth * healthPercent)
    
    end

end

function CombatAlien:OnUpdateAnimationInput_Hook(self, modelMixin)
  
    if self:GotFocus() then
        modelMixin:SetAnimationInput("attack_speed", kCombatFocusAttackSpeed)        
    else
        // standard attack speed is 1, but the variable is local so we cant use it
        modelMixin:SetAnimationInput("attack_speed", self:GetIsEnzymed() and kEnzymeAttackSpeed or 1.0)
    end
    
end

// no hook, replace it
function GetHasCamouflageUpgrade(callingEntity)
    if Server then
        return callingEntity.combatTable and callingEntity.combatTable.hasCamouflage 
    elseif Client then
        local upgrade = GetUpgradeFromId(GetUpgradeFromId(upgradeId))
        return callingEntity:GotItemAlready(upgrade)
    end
end


if Server then


    function CombatAlien:GetCanTakeDamageOverride_Hook(handle, self)

        local canTakeDamage = handle:GetReturn() and not self.gotSpawnProtect
        handle:SetReturn(canTakeDamage)

    end

end


if (not HotReload) then
	CombatAlien:OnLoad()
end