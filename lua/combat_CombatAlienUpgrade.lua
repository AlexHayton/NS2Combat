//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_CombatAlienUpgrade.lua

class 'CombatAlienUpgrade' (CombatUpgrade)

function CombatAlienUpgrade:Initialize(upgradeName, upgradeFunc, requiresUpgrade, levels, upgradeType)

	CombatUpgrade.Initialize(self, "Alien" upgradeName, upgradeFunc, requiresUpgrade, levels, upgradeType)

end

function CombatAlienUpgrade:DoUpgrade(player)
	
	local techId = self:GetTechId()
	local kMapName = LookupTechData(techId, kTechDataMapName)
	
	// Generic functions for upgrades and custom ones.
	if self:HasCustomFunc() then
		local customFunc = self:GetCustomFunc()
		customFunc(player, self)
	else
		CombatUpgrade.ExecuteTechUpgrade(player, self)
	end
	
	if (self:GetUpgradeType() == kCombatUpgradeTypes.Class) then
		// Some special stuff for classes.
		if not player.isRespawning then
			player:EvolveTo(techId)
		end
	end
	
end