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
	_addHookToTable(self:ReplaceClassFunction("Alien", "UpdateHealthAmount","UpdateHealthAmount_Hook"))	
    _addHookToTable(self:PostHookClassFunction("Alien", "OnUpdateAnimationInput","OnUpdateAnimationInput_Hook"))
   
    if Server then
        self:PostHookClassFunction("Alien", "GetCanTakeDamageOverride", "GetCanTakeDamageOverride_Hook"):SetPassHandle(true)
		self:PostHookClassFunction("Alien", "CopyPlayerDataFrom","CopyPlayerDataFrom_Hook")
    end
   
	
end

function CombatAlien:GetHasTwoHives_Hook(self)
	return self.twoHives
end

function CombatAlien:GetHasThreeHives_Hook(self)
	return self.threeHives
end

function CombatAlien:UpdateArmorAmount_Hook(self, carapaceLevel)

    local level = GetHasCarapaceUpgrade(self) and carapaceLevel or 0
    local newMaxArmor = (level / 3) * (self:GetArmorFullyUpgradedAmount() - self:GetBaseArmor()) + self:GetBaseArmor()

    if newMaxArmor ~= self.maxArmor then

        local armorPercent = self.maxArmor > 0 and self.armor/self.maxArmor or 0
        self.maxArmor = newMaxArmor
        self:SetArmor(self.maxArmor * armorPercent)
    
    end

	// Always set the hives back to false, so that later on we can enable tier 2/3 even after embryo.
	if self:GetTeamNumber() ~= kTeamReadyRoom then
		if self.combatTwoHives then
			self.twoHives = true
		else
			self.twoHives = false
		end
		
		if self.combatThreeHives then
			self.threeHives = true
		else
			self.threeHives = false
		end
	end

end

function CombatAlien:UpdateHealthAmount_Hook(self, bioMassLevel, maxLevel)

	// Cap the health level at the max biomass level
    local level = math.min(10, math.max(0, self:GetLvl() - 1))
    local newMaxHealth = self:GetBaseHealth() + level * self:GetHealthPerBioMass()

    if newMaxHealth ~= self.maxHealth then

        local healthPercent = self.maxHealth > 0 and self.health/self.maxHealth or 0
        self.maxHealth = newMaxHealth
        self:SetHealth(self.maxHealth * healthPercent)
    
    end

end

function CombatAlien:OnUpdateAnimationInput_Hook(self, modelMixin)
  
	if (Server and self.combatTable) or not Server then
		if self:GotFocus() then
			modelMixin:SetAnimationInput("attack_speed", kCombatFocusAttackSpeed)        
		else
			// standard attack speed is 1, but the variable is local so we cant use it
			modelMixin:SetAnimationInput("attack_speed", self:GetIsEnzymed() and kEnzymeAttackSpeed or 1.0)
		end
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
	
	function CombatAlien:CopyPlayerDataFrom_Hook(self, player)
		
		self.combatTwoHives = player.combatTwoHives
		self.combatThreeHives = player.combatThreeHives
		//Shared.Message("player.combatTwoHives: " .. tostring(player.combatTwoHives))
		//Shared.Message("player.combatThreeHives: " .. tostring(player.combatThreeHives))
		
		if player.combatTable then
			self:CheckCombatData()
			//Shared.Message("player.combatTable.twoHives: " .. tostring(player.combatTable.twoHives))
			if player.combatTable.twoHives then
				self.combatTwoHives = true
				self.combatTable.twoHives = true
			end
			
			//Shared.Message("player.combatTable.threeHives: " .. tostring(player.combatTable.threeHives))
			if player.combatTable.threeHives then
				self.combatThreeHives = true
				self.combatTable.threeHives = true
			end
		end
    
	end

end


if (not HotReload) then
	CombatAlien:OnLoad()
end