//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_ConsoleCommands.lua



function OnCommandSpendLvl(client, type)
        
    local player = client:GetControllingPlayer() 
        
    if type then
        if player:isa("Marine") then
        
            if UpsList.Marine[type] then             
                    player:CoCheckUpgrade_Marine(type)   
            end
            
        elseif player:isa("Alien") then
        
            if UpsList.Alien[type] then             
                    player:CoCheckUpgrade_Alien(type)   
            end
            
        end
    else
        Shared.Message("No type defined, usage is: co_spendlvl type")
    end
   
end

function OnCommandAddXp(client, amount)

        local player = client:GetControllingPlayer()        
        if Shared.GetCheatsEnabled() then
            if amount then            
                player:AddXp(amount)
            else
                player:AddXp(1)
            end
	    end
end

function OnCommandShowXp(client)

        local player = client:GetControllingPlayer()        
        Print(player:GetXp())

end

function OnCommandShowLvl(client)

        local player = client:GetControllingPlayer()        
        Print(player:GetLvl())

end

function OnCommandTestMsg(client, message)

    local player = client:GetControllingPlayer() 
    local worldmessage = BuildWorldTextMessage(message, player:GetOrigin())




    //for index, marine in ipairs(GetEntitiesForTeam("Player", player:GetTeamNumber())) do
        Server.SendNetworkMessage(player, "WorldText", worldmessage, true) 
    //end 
end

function OnCommandStuck(client)

local player = client:GetControllingPlayer()
player:SetOrigin( player:GetOrigin()+ Vector(0, 2, 0))

end

 
Event.Hook("Console_co_spendlvl",                OnCommandSpendLvl)

Event.Hook("Console_co_addxp",                OnCommandAddXp)
Event.Hook("Console_co_showxp",                OnCommandShowXp)
Event.Hook("Console_co_showlvl",                OnCommandShowLvl)

Event.Hook("Console_testmsg",                OnCommandTestMsg)




Event.Hook("Console_/stuck",                OnCommandStuck)
