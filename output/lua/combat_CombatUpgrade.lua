//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_CombatUpgrade.lua

Script.Load("lua/combat_ExperienceEnums.lua")
							
class 'CombatUpgrade'

function CombatUpgrade:Initialize(team, upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType, refundUpgrade, hardCap, mutuallyExclusive)

	self.team = team
    self.id = upgradeId
	self.textCode = upgradeTextCode
	self.description = upgradeDescription
	self.techId = upgradeTechId
    self.upgradeType = upgradeType
	self.requirements = requirements
	self.levels = levels
	self.refundUpgrade = refundUpgrade
	self.mutuallyExclusive = mutuallyExclusive
	self.hardCapScale = hardCap

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

function CombatUpgrade:GetRefundUpgrade()
	return self.refundUpgrade
end

function CombatUpgrade:GetHardCapScale()
	return self.hardCapScale
end

function CombatUpgrade:GetIsHardCapped(player)

	// Hard cap scale is expressed e.g. 1/5
	// So if we have more than 1 player with this upgrade per 5 players we are hardcapped.
	// Recalculate at the point someone tries to buy for accuracy.
	if (self.hardCapScale > 0) then
	
		local teamPlayers = GetEntitiesForTeam("Player", player:GetTeamNumber())
		local numInTeam = #teamPlayers
		local numPlayersWithUpgrade = 0
		
		for index, teamPlayer in ipairs(teamPlayers) do
		
			// Skip dead players
			if (teamPlayer:GetIsAlive()) then
				
				if (teamPlayer:GetHasCombatUpgrade(self:GetId())) then
					numPlayersWithUpgrade = numPlayersWithUpgrade + 1
				end
				
			end
			
		end		
		
		if (numPlayersWithUpgrade / numInTeam) >= self.hardCapScale then
			return true
		else
			return false
		end
		
	else
		return false
	end
	
end

function CombatUpgrade:GetMutuallyExclusive()
	return self.mutuallyExclusive
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
	// Update the tech tree and send updates to the client. Don't know why, but it's only working when we send it here.
    //techTree:SendTechTreeBase(player)

    // Update the hard cap count, if necessary
	if (self:GetHardCapScale() > 0) then
		self:UpdateHardCapCount(player:GetTeamNumber())
	end
end

// Update the count for the upgrades at the time of buying, to improve the user experience.
function CombatUpgrade:UpdateHardCapCount(teamIndex)

	UpdateUpgradeCountsForTeam(GetGamerules(), teamIndex)
	
end

function CombatUpgrade:GiveItem(player)

	local kMapName = LookupTechData(self:GetTechId(), kTechDataMapName)
	if (player:GetIsAlive()) then
		player:GiveItem(kMapName)
	end

end

function CombatUpgrade:DoUpgrade(player)
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
    self:TeamSpecificLogic(player)
end

local origGetIsTechUnlocked = GetIsTechUnlocked
function GetIsTechUnlocked(player, techId)

	if player:isa("Alien") then
		// Check for Tier 2 ups
		for _, v in ipairs(kCombatAlienTierTwoTechIds) do
	    	if techId == v then
	    		return player.twoHives
	    	end
	    end

	    // Check for Tier 3 ups
		for _, v in ipairs(kCombatAlienTierThreeTechIds) do
	    	if techId == v then
	    		return player.threeHives
	    	end
	    end
	end

	return origGetIsTechUnlocked(player, techId)

end