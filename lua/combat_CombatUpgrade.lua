//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_CombatUpgrade.lua

kCombatUpgrades = enum({// Marine upgrades
						'Mines', 'Welder', 'Shotgun', 'Flamethrower', 'GrenadeLauncher', 
						'Damage1', 'Damage2', 'Damage3', 'Armor1', 'Armor2', 'Armor3', 
						'MotionDetector', 'Scanner', 'CatalystPacks', 'Resupply', 
						'Jetpack', 'Exosuit',
						
						// Alien upgrades
						'Gorge', 'Lerk', 'Fade', 'Onos', 
						'TierTwo', 'TierThree',
						'Carapace', 'Regeneration', 'Silence', 'Camouflage', 'Celerity'})
						
// The order of these is important...
kCombatUpgradeTypes = enum({'Class', 'Tech', 'Weapon'})
							
class 'CombatUpgrade'

function CombatUpgrade:Initialize(team, upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)

	self.team = team
    self.id = upgradeId
	self.textCode = upgradeTextCode
	self.description = upgradeDescription
	self.techId = upgradeTechId
    self.upgradeType = upgradeType
	self.requirements = requirements
	self.levels = levels
	self.applied = false

	if (upgradeFunc) then
		self.upgradeFunc = upgradeFunc
		self.useCustomFunc = true
	else
		self.useCustomFunc = false
	end
	
end

function CombatUpgrade:GetIsApplied()
	return self.applied
end

function CombatUpgrade:SetIsApplied(applied)
	self.applied = applied
end

function CombatUpgrade:GetTextCode()
	return self.textCode
end

function CombatUpgrade:GetDescription()
	return self.description
end

function CombatUpgrade:GetId()
	return self.id
end

function CombatUpgrade:GetTechId()
	return self.techId
end

function CombatUpgrade:GetLevels()
	return self.levels
end

function CombatUpgrade:GetRequirements()
	return self.requirements
end

function CombatUpgrade:HasCustomFunc()
	return self.useCustomFunc
end

function CombatUpgrade:GetCustomFunc()
	return self.upgradeFunc
end

function CombatUpgrade:GetType()
	return self.upgradeType
end

function CombatUpgrade:ExecuteTechUpgrade(player)

	/*local techTree = player:GetTechTree()
	local techId = self:GetTechId()
	local node = techTree:GetTechNode(techId)
	if node == nil then
    
        Print("Player:ExecuteTechUpgrade(): Couldn't find tech node %d", techId)
        return false
        
    end

    node:SetResearched(true)
	node:SetHasTech(true)
	techTree:SetTechNodeChanged(node)
	techTree:SetTechChanged()
	self:SetIsApplied(true)*/
	player:GiveUpgrade(self:GetTechId())

end

function CombatUpgrade:GiveItem(player)

	local kMapName = LookupTechData(self:GetTechId(), kTechDataMapName)
	player:GiveItem(kMapName)

end