//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_CombatMarineUpgrade.lua

class 'CombatMarineUpgrade' (CombatUpgrade)

function CombatMarineUpgrade:Initialize(upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)

	CombatUpgrade.Initialize(self, "Marine", upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)

end

function CombatMarineUpgrade:DoUpgrade(player)
	
	local techId = self:GetTechId()
	local kMapName = LookupTechData(techId, kTechDataMapName)
	
	// Generic functions for upgrades and custom ones.
	if self:HasCustomFunc() then
		local customFunc = self:GetCustomFunc()
		customFunc(player, self)
	else
		self:ExecuteTechUpgrade(player)
	end
	
	// Apply weapons upgrades to a marine.
	if (self:GetType() == kCombatUpgradeTypes.Weapon) then
		Player.InitWeapons(player)
		
		// if this is a primary weapon, destroy the old one.
		if GetIsPrimaryWeapon(kMapName) then
			local weapon = player:GetWeaponInHUDSlot(1)
			player:RemoveWeapon(weapon)
			DestroyEntity(weapon)
		end
		
		self:GiveItem(player)
	end
	
end

// TODO: Walk up the player's tech tree...
function GetIsPrimaryWeapon(kMapName)
    local isPrimary = false
    
    if kMapName == Shotgun.kMapName or
        kMapName == Flamethrower.kMapName  or
        kMapName == GrenadeLauncher.kMapName or
        kMapName == Rifle.kMapName then
        
        isPrimary = true
    end
    
    return isPrimary
end