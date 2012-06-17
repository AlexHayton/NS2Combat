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
            else
                player:spendlvlHints("wrong_type_marine", type)
            end
            
        elseif player:isa("Alien") then
        
            if UpsList.Alien[type] then             
                player:CoCheckUpgrade_Alien(type)   
            else 
                player:spendlvlHints("wrong_type_alien", type)
            end
            
        end
    else
        player:spendlvlHints("no_type")
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
	player:SetOrigin( player:GetOrigin()+ Vector(0, 4, 0))
	
	// TODO: Find the nearest wall and move us to the other side of it.
	// AH: This is low priority for me.

end

function OnCommandStatus(client)

	local player = client:GetControllingPlayer()
	player:SendDirectMessage( "You are level " .. player:GetLvl() .. " with " .. player:GetXp() .. " XP. " .. (XpList[player:GetLvl() + 1]["XP"] - player:GetXp()).. " XP to go!")
	
end

function OnCommandHelp(client)

	// Display a banner showing the available commands
	local player = client:GetControllingPlayer()
	player:SendDirectMessage("Available commands:")
	player:SendDirectMessage("co_spendlvl - use this to buy upgrades")
	player:SendDirectMessage("co_status - use this to show your level, xp and available upgrades")

end


function OnCommandUpgrades(client)

	// Shows all available Upgrades
	local player = client:GetControllingPlayer()
	
	if player:isa("Marine") then
		for upName in pairs(UpsList.Marine) do
	        player:SendDirectMessage(upName .. " , needs Upgrade " .. (UpsList.Marine[upName]["Requires"] or "no") .. " upgrade first and " .. (UpsList.Marine[upName]["Levels"] or 0) .. " free Lvl" )
        end
	elseif player:isa("Alien") then
        for upName in pairs(UpsList.Alien) do
	        player:SendDirectMessage(upName .. " , needs Upgrade " .. (UpsList.Alien[upName]["Requires"] or "no") .. " upgrade first and " .. (UpsList.Alien[upName]["Levels"] or 0) .. " free Lvl" )	
        end
	end

end

// All commands that should be accessible via the need to be in this list
combatCommands = {"co_spendlvl", "co_help", "co_status", "co_upgrades"}

Event.Hook("Console_co_help",                OnCommandHelp) 
Event.Hook("Console_co_upgrades",                OnCommandUpgrades) 
Event.Hook("Console_co_spendlvl",                OnCommandSpendLvl)
Event.Hook("Console_co_addxp",                OnCommandAddXp)
Event.Hook("Console_co_showxp",                OnCommandShowXp)
Event.Hook("Console_co_showlvl",                OnCommandShowLvl)
Event.Hook("Console_co_status",                OnCommandStatus) 
Event.Hook("Console_testmsg",                OnCommandTestMsg)
Event.Hook("Console_/stuck",                OnCommandStuck)
