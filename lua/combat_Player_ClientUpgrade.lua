//________________________________
//
//   	combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
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
function Player:Combat_PurchaseItemAndUpgrades(textCode)

    Shared.ConsoleCommand("/buy " .. tostring(textCode))

end



