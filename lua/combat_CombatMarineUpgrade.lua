//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_CombatMarineUpgrade.lua

class 'CombatMarineUpgrade' (CombatUpgrade)

function CombatMarineUpgrade:Initialize(upgradeName, upgradeFunc, requiresUpgrade, levels, upgradeType)

	CombatUpgrade.Initialize(self, "Marine", upgradeName, upgradeFunc, requiresUpgrade, levels, upgradeType)

end

function CombatMarineUpgrade:DoUpgrade(player)
	
	local techId = self:GetTechId()
	local kMapName = LookupTechData(techId, kTechDataMapName)
	
	// Generic functions for upgrades and custom ones.
	if self:HasCustomFunc() then
		local customFunc = self:GetCustomFunc()
		customFunc(player, self)
	else
		CombatUpgrade.ExecuteTechUpgrade(player, self)
	end
	
	// Apply weapons upgrades to a marine.
	if (self:GetUpgradeType() == kCombatUpgradeTypes.Weapon) then
		Player.InitWeapons(player)
		
		// if this is a primary weapon, destroy the old one.
		if GetIsPrimaryWeapon(kMapName) then
			local weapon = self:GetWeaponInHUDSlot(1)
			self:RemoveWeapon(weapon)
			DestroyEntity(weapon)
		end
		
		CombatUpgrade.GiveItem(player, self)
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