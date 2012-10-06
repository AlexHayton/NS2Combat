//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_ConsoleCommands.lua

function OnCommandSpendLvl(client, ...)
        
    // support multiple types
    local args = {...}    
    local upgradeTable = {}
    local player = client:GetControllingPlayer() 
    
	if player:isa("Spectator") then
		player:spendlvlHints("spectator")
	elseif not player:GetIsAlive() then
		player:spendlvlHints("dead")
    else		
        for i, typeCode in ipairs(args) do
            local upgrade = GetUpgradeFromTextCode(typeCode)
            if not upgrade then 
                // check for every arg if its a valid update
                local hintType = ""
                if player:isa("Marine") or player:isa("Exo") then
                    hintType = "wrong_type_marine"
                else
                    hintType = "wrong_type_alien"
                end			
                player:spendlvlHints(hintType, typeCode)
            else
            // build new table with upgrades
                table.insert(upgradeTable, upgrade) 
            end        
        end       

        if table.maxn(upgradeTable) > 0 then   
            player:CoEnableUpgrade(upgradeTable)
        else
            player:spendlvlHints("no_type")
        end
    end
   
end


local function OnCommandAddXp(client, amount)

        local player = client:GetControllingPlayer()        
        if Shared.GetCheatsEnabled() then
			amount = tonumber(amount)
			
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
	player:SendDirectMessage("Use the 'buy' menu to buy upgrades.")
	player:SendDirectMessage("You gain XP for killing other players, damaging structures and healing your structures.")

end

function OnCommandUpgrades(client)

	// Shows all available Upgrades
	local player = client:GetControllingPlayer()
	local upgradeList = nil
	
	if player:isa("Marine") or player:isa("Exo") then
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


// send the Ups to the requesting player
function OnCommandSendUpgrades(client)

    local player = client:GetControllingPlayer()
    player:SendUpgrades()

end

local function OnCommandModActive(client, activeBoolean)

    if client == nil or client:GetIsLocalClient() then
        OnCommandModActiveAdmin(client, activeBoolean)
    end
    
end

function OnCommandModActiveAdmin(client, activeBoolean)

    if activeBoolean then
        if activeBoolean == "true" or activeBoolean == "false" then
            ModSwitcher_Save(activeBoolean, nil, nil, false)
            Shared.Message("The changes only take effect after the next mapchange")
            
            // send it to every player            
            local message = "CombatMod will be generally " .. ModSwitcher_Status(activeBoolean) .. " after this map."
            Shared.ConsoleCommand("say " .. message)
              
        else
            Shared.Message("CombatModSwitcher: Only true or false allowed")
        end
	end
end

local function OnCommandModThreshold(client, numPlayers)

    if client == nil or client:GetIsLocalClient() then
        OnCommandModThresholdAdmin(client, numPlayers)
    end
    
end

function OnCommandModThresholdAdmin(client, numPlayers)

    if numPlayers then
        if tonumber(numPlayers) then
            ModSwitcher_Save(nil, tonumber(numPlayers), nil, false)
            Shared.Message("The changes only take effect after the next mapchange!")
            
            // send it to every player            
            local message = "CombatMod will only be activate after this map if player count is less than " .. numPlayers 
            Shared.ConsoleCommand("say " .. message)
              
        else
            Shared.Message("CombatModSwitcher: Only numbers allowed")
        end
    end
end

function OnCommandChangeMap(client, mapName)
    
    if client == nil or client:GetIsLocalClient() then
		local playerCount = Shared.GetEntitiesWithClassname("Player"):GetSize()
		ModSwitcher_Save(nil, nil, playerCount, false)
	
        local mods = { }
        Server.StartWorld(mods, mapName)
    end
    
end


// All commands that should be accessible via the chat need to be in this list
combatCommands = {"co_spendlvl", "co_help", "co_status", "co_upgrades", "/upgrades", "/status", "/buy", "/help"}

if kCombatModActive then

    Event.Hook("Console_co_help",                OnCommandHelp) 
    Event.Hook("Console_/help",                OnCommandHelp) 
    Event.Hook("Console_co_upgrades",                OnCommandUpgrades) 
    Event.Hook("Console_/upgrades",                OnCommandUpgrades) 
    Event.Hook("Console_co_spendlvl",                OnCommandSpendLvl)
    Event.Hook("Console_/buy",						OnCommandSpendLvl)
    Event.Hook("Console_co_addxp",                OnCommandAddXp)
    Event.Hook("Console_co_showxp",                OnCommandShowXp)
    Event.Hook("Console_co_showlvl",                OnCommandShowLvl)
    Event.Hook("Console_co_status",                OnCommandStatus) 
    Event.Hook("Console_/status",                OnCommandStatus) 
    //Event.Hook("Console_/stuck",                OnCommandStuck)    
    Event.Hook("Console_co_sendupgrades",       OnCommandSendUpgrades) 
    
end

// only this command works when in classic mode
// to make it available for admins and dedicated servers
Event.Hook("Console_co_mode",         OnCommandModActive) 
Event.Hook("Console_co_mod_active",         OnCommandModActive) 
Event.Hook("Console_co_mod_player_threshold",         OnCommandModThreshold) 
Event.Hook("Console_changemap", OnCommandChangeMap)
CreateServerAdminCommand("Console_sv_co_mode", OnCommandModActiveAdmin, "Switches between combat and classic mode") 
CreateServerAdminCommand("Console_sv_co_mode_player_threshold", OnCommandModThresholdAdmin, "Sets the game to classic mode after a certain player threshold") 