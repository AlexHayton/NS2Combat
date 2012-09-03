//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Player_SharedUpgrade.lua

// helper functions for the buy Menu

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