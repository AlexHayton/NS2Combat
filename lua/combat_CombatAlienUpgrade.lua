//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_CombatAlienUpgrade.lua

class 'CombatAlienUpgrade' (CombatUpgrade)

function CombatAlienUpgrade:Initialize(upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)

	CombatUpgrade.Initialize(self, "Alien", upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)

end

function CombatAlienUpgrade:TeamSpecificLogic(player)
	
	//if (self:GetType() == kCombatUpgradeTypes.Class) then
		// Some special stuff for classes.
		if not player.isRespawning then
		    player:DropToFloor()
			player:EvolveTo(self:GetTechId())
		end
	//end
	
end