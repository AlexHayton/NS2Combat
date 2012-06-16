//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_PlayingTeam.lua



local function GetChatPlayerData(client)

    local playerName = "Admin"
    local playerLocationId = -1
    local playerTeamNumber = kTeamReadyRoom
    local playerTeamType = kNeutralTeamType
    
    if client then
    
        local player = client:GetControllingPlayer()
        if not player then
            return
        end
        playerName = player:GetName()
        playerLocationId = player.locationId
        playerTeamNumber = player:GetTeamNumber()
        playerTeamType = player:GetTeamType()
        
    end
    
    return playerName, playerLocationId, playerTeamNumber, playerTeamType
    
end

// we can't hook that cause it's a local function, so we just create a new one
local function OnChatReceived(client, message)
    
    chatMessage = string.sub(message.message , 1, kMaxChatLength) 
    combatMessage = false
    
    for i, entry in pairs(combatCommands) do
        if string.sub(chatMessage, 1, string.len(entry)) == entry then
           combatMessage = true 
           break
        end
    end   
    
    if not combatMessage then   
        
        if chatMessage and string.len(chatMessage) > 0 then
        
            local playerName, playerLocationId, playerTeamNumber, playerTeamType = GetChatPlayerData(client)
            
            if playerName then
            
                if message.teamOnly then
                
                    local players = GetEntitiesForTeam("Player", playerTeamNumber)
                    for index, player in ipairs(players) do
                        Server.SendNetworkMessage(player, "Chat", BuildChatMessage(true, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage), true)
                    end
                    
                else
                    Server.SendNetworkMessage("Chat", BuildChatMessage(false, playerName, playerLocationId, playerTeamNumber, playerTeamType, chatMessage), true)
                end
                
                Shared.Message("Chat " .. (message.teamOnly and "Team - " or "All - ") .. playerName .. ": " .. chatMessage)
                
            end
            
        end
    
    else
    // if its a combat Command, call it 
        local player = client:GetControllingPlayer()
        Server.ClientCommand(player, chatMessage)
    end
        
end

Server.HookNetworkMessage("ChatClient", OnChatReceived)