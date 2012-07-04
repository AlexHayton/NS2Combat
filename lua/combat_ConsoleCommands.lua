//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_ConsoleCommands.lua

function OnCommandSpendLvl(client, typeCode)
        
    local player = client:GetControllingPlayer() 
	if player:isa("Spectator") then
		player:spendlvlHints("spectator")
    elseif typeCode then
		local upgrade = GetUpgradeFromTextCode(typeCode)
		
		if upgrade then
			player:CoEnableUpgrade(upgrade)
		else
			local hintType = ""
			if player:isa("Marine") then
				hintType = "wrong_type_marine"
			else
				hintType = "wrong_type_alien"
			end
			
			player:spendlvlHints(hintType, typeCode)
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
	player:SendDirectMessage( "You are level " .. player:GetLvl() .. " and have " .. player:GetLvlFree() .. " free Lvl to use")
	player:SendDirectMessage( "You have " .. player:GetXp() .. " XP, " .. (XpList[player:GetLvl() + 1]["XP"] - player:GetXp()).. " XP until level up!")
	
end

function OnCommandHelp(client)

	// Display a banner showing the available commands
	local player = client:GetControllingPlayer()
	player:SendDirectMessage("Available commands:")
	player:SendDirectMessage("/buy or co_spendlvl - use this to buy upgrades")
	player:SendDirectMessage("/upgrades or co_upgrades - show available upgrades")
	player:SendDirectMessage("/status or co_status - use this to show your level, xp and available upgrades")

end

function OnCommandUpgrades(client)

	// Shows all available Upgrades
	local player = client:GetControllingPlayer()
	local upgradeList = nil
	
	if player:isa("Marine") then
		upgradeList = GetAllUpgrades("Marine")
	else
		upgradeList = GetAllUpgrades("Alien")
	end
	
	for index, upgrade in pairs(upgradeList) do
		local requirements = upgrade:GetRequirements()
		local requirementsText = ""
		
		if (requirements) then 
			requirementsText = GetUpgradeFromId(requirements):GetDescription()
		else
			requirementsText = "no"
		end
		
	    player:SendDirectMessage(upgrade:GetTextCode() .. " (" .. upgrade:GetDescription() .. ") needs " .. (requirementsText or "no") .. " upgrade first and " .. (upgrade:GetLevels() or 0) .. " free Lvl" )
    end

end

// All commands that should be accessible via the chat need to be in this list
combatCommands = {"co_spendlvl", "co_help", "co_status", "co_upgrades", "/upgrades", "/status", "/buy"}

Event.Hook("Console_co_help",                OnCommandHelp) 
Event.Hook("Console_co_upgrades",                OnCommandUpgrades) 
Event.Hook("Console_/upgrades",                OnCommandUpgrades) 
Event.Hook("Console_co_spendlvl",                OnCommandSpendLvl)
Event.Hook("Console_/buy",						OnCommandSpendLvl)
Event.Hook("Console_co_addxp",                OnCommandAddXp)
Event.Hook("Console_co_showxp",                OnCommandShowXp)
Event.Hook("Console_co_showlvl",                OnCommandShowLvl)
Event.Hook("Console_co_status",                OnCommandStatus) 
Event.Hook("Console_/status",                OnCommandStatus) 
Event.Hook("Console_testmsg",                OnCommandTestMsg)
Event.Hook("Console_/stuck",                OnCommandStuck)
