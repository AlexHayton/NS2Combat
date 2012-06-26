//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_CombatAlienUpgrade.lua

class 'CombatAlienUpgrade' (CombatUpgrade)

function CombatAlienUpgrade:Initialize(upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)

	CombatUpgrade.Initialize(self, "Alien", upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)

end

function CombatAlienUpgrade:DoUpgrade(player)
	
	local techId = self:GetTechId()
	local kMapName = LookupTechData(techId, kTechDataMapName)
	
	// Generic functions for upgrades and custom ones.
	if self:HasCustomFunc() then
		local customFunc = self:GetCustomFunc()
		customFunc(player, self)
	else
		player:GiveUpgrade(techId)
	end
	
	if (self:GetType() == kCombatUpgradeTypes.Class) then
		// Some special stuff for classes.
		if not player.isRespawning then
			player:EvolveTo(techId)
		end
	end
	
end