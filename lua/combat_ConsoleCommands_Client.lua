//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_ConsoleCommands_Client.lua

// Console commands only for the client (so the server can send the ups to the client)

function OnCommandSetUpgrades(upgradeId)
        
    // insert the ids in the personal player table
    local player = Client.GetLocalPlayer()
    table.insert(player.combatUpgrades, upgradeId)
 
end


function OnCommandClearUpgrades()
        
    // clear all tech
    local player = Client.GetLocalPlayer()
    player.combatUpgrades = {}
   
end


Event.Hook("Console_co_setupgrades",                OnCommandSetUpgrades) 
Event.Hook("Console_co_clearupgrades",              OnCommandClearUpgrades) 

