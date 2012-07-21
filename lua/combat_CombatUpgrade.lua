//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_CombatUpgrade.lua

kCombatUpgrades = enum({// Marine upgrades
						'Mines', 'Welder', 'Shotgun', 'Flamethrower', 'GrenadeLauncher', 
						'Weapons1', 'Weapons2', 'Weapons3', 'Armor1', 'Armor2', 'Armor3', 
						'MotionDetector', 'Scanner', 'CatalystPacks', 'Resupply', 'EMP',
						'Jetpack', 'Exosuit',
						
						// Alien upgrades
						'Gorge', 'Lerk', 'Fade', 'Onos', 
						'TierTwo', 'TierThree',
						'Carapace', 'Regeneration', 'Silence', 'Camouflage', 'Celerity',
                        'Adrenaline', 'Feint'})
						
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

	if (upgradeFunc) then
		self.upgradeFunc = upgradeFunc
		self.useCustomFunc = true
	else
		self.useCustomFunc = false
	end
	
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

function CombatUpgrade:GetTeam()
	return self.team
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

	local techTree = player:GetTechTree()
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
	// Update the tech tree and send updates to the client. Don't know why, but it's only working when we send it hear
    techTree:SendTechTreeBase(player)

    // GiveUpgrade caused only problems, its working without	

end

function CombatUpgrade:GiveItem(player)

	local kMapName = LookupTechData(self:GetTechId(), kTechDataMapName)
	player:GiveItem(kMapName)

end

function CombatUpgrade:DoUpgrade(player, wait, upgradeList)
	local techId = self:GetTechId()
	local kMapName = LookupTechData(techId, kTechDataMapName)
	
	// Generic functions for upgrades and custom ones.
	if self:HasCustomFunc() then
		// If the custom function returns a new player then use that instead.
		local customFunc = self:GetCustomFunc()
		local customReturnPlayer = customFunc(player, self)
		if (customReturnPlayer) then
			player = customReturnPlayer
		end
	else
		self:ExecuteTechUpgrade(player)
	end
	
	// Do specific stuff for aliens or marines.
	if wait ~= nil then
	    self:TeamSpecificLogic(player)
    else
        if not wait then
            self:TeamSpecificLogic(player)
        end
    end
end