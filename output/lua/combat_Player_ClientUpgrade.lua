//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Player_SharedUpgrade.lua

// Sound Precache here

// helper functions for the buy Menu

function Player:GetScore()

    // There are cases where the player name will be nil such as right before
    // this Player is destroyed on the Client (due to the scoreboard removal message
    // being received on the Client before the entity removed message). Play it safe.
    local scoreboardScore = Scoreboard_GetPlayerData(self:GetClientIndex(), "Score") or 0
	local playerScore = self.score
	local bestGuessScore = 0
	
	if (playerScore > scoreboardScore) and scoreboardScore > 0 then
		bestGuessScore = playerScore
	else
		bestGuessScore = scoreboardScore
    end
	
	self.score = bestGuessScore
	return bestGuessScore
	
end

function Player:GotRequirements(upgrade)
    
    if upgrade then
        local requirements = upgrade:GetRequirements()

        // does this up needs other ups??
        if requirements then
            requiredUpgrade = GetUpgradeFromId(requirements)    
            if (self.combatUpgrades and table.maxn(self.combatUpgrades) > 0) then
                for i, id in ipairs(self.combatUpgrades) do
                    if (tonumber(id) == requiredUpgrade:GetId()) then
                        return true
                    end  
                end  
            else
            
                return false
                
            end 
        else
            return true
        end
    end
    return false
end

function Player:GotRequirementsFromTechIds(upgrade, upgradeTechIdList)
    
    if upgrade then
        local requirements = upgrade:GetRequirements()

        // does this up needs other ups??
        if requirements then
			requiredUpgrade = GetUpgradeFromId(requirements)    
			for i, techId in pairs(upgradeTechIdList) do
				if (techId == requiredUpgrade:GetTechId()) then
					return true
				end  
			end  
        else
            return true
        end
    end
    return false
end

function Player:GotItemAlready(upgrade)

    if upgrade then 
        if (self.combatUpgrades and table.maxn(self.combatUpgrades) > 0) then
            for i, id in ipairs(self.combatUpgrades) do
                if (tonumber(id) == upgrade:GetId()) then
                    return true
                end  
            end  
        else        
            return false            
        end 
    end
    return false
    
end

function Player:GetUpgrades()

    local upgrades = {}
    local deleteIDs = {}
    
    if (self.combatUpgrades and table.maxn(self.combatUpgrades) > 0) then    
        for i, id in ipairs(self.combatUpgrades) do
            // dunno why but the first entry is now nil
            if not(id == "nil") then
                local upgrade = GetUpgradeFromId(tonumber(id))
                local techId = upgrade:GetTechId()
                table.insert(upgrades,  techId)  

                if techId == kTechId.Weapons2 then
                    table.insert(deleteIDs, kTechId.Weapons1)
                elseif techId == kTechId.Weapons3 then
                    table.insert(deleteIDs, kTechId.Weapons2)
                elseif techId == kTechId.Armor2 then
                    table.insert(deleteIDs, kTechId.Armor1)                
                elseif techId == kTechId.Armor3 then                
                    table.insert(deleteIDs, kTechId.Armor2)
                end   
            end            
        end   
 
        if (table.maxn(deleteIDs) > 0) and (table.maxn(upgrades) > 0) then
            // sort upgrades, if we got wpn2, delete wpn1 again etc..
            for i, deleteId in ipairs(deleteIDs) do
                for j, techId in ipairs(upgrades) do
                    if techId == deleteId then
                        table.remove(upgrades, j)
                        break
                    end
                end
            end
            
        end 
     
    end
    
    return upgrades

end


// sends the buy command to the console
function Player:Combat_PurchaseItemAndUpgrades(textCodes)

    local buyString = ""
    
    if type(textCodes) == "table" then    
        for i, textCode in ipairs(textCodes) do
            buyString = (buyString  .. textCode .. " ")
        end        
    else
        buyString = textCodes
    end
    

    Shared.ConsoleCommand("/buy " .. buyString)

end

function Player:XPUntilNextLevel()
	
	local xp = self:GetScore()
	if Experience_GetLvl(xp) == maxLvl then
		return 0
	end
	
	return XpList[Experience_GetLvl(xp) + 1]["XP"] - xp

end

function Player:GetNextLevelXP()

	local xp = self:GetScore()
	if Experience_GetLvl(xp) == maxLvl then
		return maxXp
	end
	
	return XpList[Experience_GetLvl(xp) + 1]["XP"]

end

// Return the proportion of this level that we've progressed.
function Player:GetLevelProgression()

	local xp = self:GetScore()
	if Experience_GetLvl(xp) == maxLvl then
		return 1
	end
	
	local thisLevel = XpList[Experience_GetLvl(xp)]["XP"]
	local nextLevel = XpList[Experience_GetLvl(xp) + 1]["XP"]
	return (xp - thisLevel) / (nextLevel - thisLevel)

end


function Player:LevelUpMessage()

    local lvl = Experience_GetLvl(player:GetScore())
    local LvlName = Experience_GetLvlName(lvl  , self:GetTeamNumber())
    ChatUI_AddSystemMessage( "!! Level UP !! New Lvl: " .. LvlName .. " (" .. lvl .. ")")
    local lvlFree = self.resources
    local upgradeWord = (lvlFree > 1) and "upgrade points" or "upgrade point"
    ChatUI_AddSystemMessage("You have " .. lvlFree .. " " .. upgradeWord .. " to spend. Use the B key to buy upgrades.") 
    
end


function PlayerUI_TriggerInvalidSound()

	local player = Client.GetLocalPlayer()
	player:TriggerInvalidSound()

end

function PlayerUI_GetTimeRemaining()

	timeDigital = "00:00:00"
	if (kCombatTimeLimit ~= nil) then
		local exactTimeLeft = (kCombatTimeLimit - kCombatTimeSinceGameStart)
		if exactTimeLeft > 0 then
			local showMinutes = math.abs(exactTimeLeft) > 0
			local showMilliseconds = exactTimeLeft > 0 and exactTimeLeft < 30		
			timeDigital = GetTimeDigital(exactTimeLeft, showMinutes, showMilliseconds)
		end
	end
	
	return timeDigital

end

function PlayerUI_GetHasTimelimitPassed()
	if kCombatTimeLimit ~= nil and kCombatTimeLimit - kCombatTimeSinceGameStart > 0 then
		return true
	else
		return false
	end
end