//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_ConsoleCommands.lua
                
testSound = PrecacheAsset("sound/combat.fev/combat/general/overtime001")
                     
function IsSuperAdmin(steamId)

    if steamId then
        for i, entry in ipairs(kSuperAdmins) do
            if steamId == entry then
                return true
            end
        end
    end
    
    return false
    
end

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
	player:SendDirectMessage("You gain XP for killing other players, ")
	player:SendDirectMessage("damaging structures and healing your structures.")
	player:SendDirectMessage("Type /timeleft in chat to get the time remaining.")

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
    player:SendAllUpgrades()

end

// Refund all the upgrades for this player
function OnCommandRefundAllUpgrades(client)

    local player = client:GetControllingPlayer()
    player:RefundAllUpgrades()

end

local function OnCommandModActive(client, activeBoolean)

    if client == nil or client:GetIsLocalClient() then
        OnCommandModActiveAdmin(client, activeBoolean)
    end
    
end

function OnCommandModActiveAdmin(client, activeBoolean)

    if activeBoolean then
        if activeBoolean == "true" or activeBoolean == "false" then
            ModSwitcher_Save(activeBoolean, nil, nil, nil, nil, nil, nil, nil, false)
            Shared.Message("The changes only take effect after the next mapchange")
            
            // send it to every player            
            ModSwitcher_Output_Status_All()
              
        else
            Shared.Message("CombatModSwitcher: Only true or false allowed")
        end
	else
		ModSwitcher_Output_Status_Console()
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
            ModSwitcher_Save(nil, tonumber(numPlayers), nil, nil, nil, nil, nil, nil, false)
            Shared.Message("The changes only take effect after the next mapchange!")
            
            // send it to every player            
            ModSwitcher_Output_Status_All()
              
        else
            Shared.Message("CombatModSwitcher: Only numbers allowed")
        end
	else
		ModSwitcher_Output_Status_Console()
    end

end

local function SendTimeLeftChatToPlayer(player)

	local gameRules = GetGamerules()
	local exactTimeLeft = (kCombatTimeLimit - gameRules.timeSinceGameStateChanged)
	local timeLeft = math.ceil(exactTimeLeft)
	local timeLeftText = GetTimeText(timeLeft)
	
	if (player:GetTeamNumber() == kMarineTeamType) then
		timeLeftText = timeLeftText .. " left until Marines have lost!"
	else
		timeLeftText = timeLeftText .. " left until Aliens have won!"
	end
	
	player:SendDirectMessage( timeLeftText )

end

// Get the time remaining in this match.
local function OnCommandTimeLeft(client)

	// Display the remaining time left
	local player = client:GetControllingPlayer()
	SendTimeLeftChatToPlayer(player)

end

local function OnCommandTimeLimit(client, timeLimit)

    if client == nil or client:GetIsLocalClient() then
        OnCommandTimeLimitAdmin(client, timeLimit)
    end
    
end

function OnCommandTimeLimitAdmin(client, timeLimit)
	
    if timeLimit then
        if tonumber(timeLimit) then
            ModSwitcher_Save(nil, nil, nil, timeLimit, nil, nil, nil, nil, false)
			kCombatTimeLimit = tonumber(timeLimit)
            
            // send it to every player            
            ModSwitcher_Output_Status_All()
			
			// Also send out a network message to update players' GUI.
			// and remind them how long is remaining
			for i, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
				SendCombatGameTimeUpdate(player)
				SendTimeLeftChatToPlayer(player)
			end
              
        else
            Shared.Message("CombatModSwitcher: Only numbers allowed")
        end
	else
		ModSwitcher_Output_Status_Console()
    end
end

function OnCommandOvertimeAdmin(client, activeBoolean)

    if activeBoolean then
        if activeBoolean == "true" or activeBoolean == "false" then
            ModSwitcher_Save(nil, nil, nil, nil, activeBoolean, nil, nil, nil, false)
            Shared.Message("The changes only take effect after the next mapchange")
            
            // send it to every player            
            ModSwitcher_Output_Status_All()
              
        else
            Shared.Message("CombatModSwitcher: Only true or false allowed")
        end
	else
		ModSwitcher_Output_Status_Console()
	end
end

local function OnCommandOvertime(client, activeBoolean)

    if client == nil or client:GetIsLocalClient() then
        OnCommandOvertimeAdmin(client, activeBoolean)
    end
    
end

function OnCommandPowerPointDamageAdmin(client, activeBoolean)

    if activeBoolean then
        if activeBoolean == "true" or activeBoolean == "false" then
            ModSwitcher_Save(nil, nil, nil, nil, nil, activeBoolean, nil, nil, false)
            Shared.Message("The changes only take effect after the next mapchange")
            
            // send it to every player            
            ModSwitcher_Output_Status_All()
              
        else
            Shared.Message("CombatModSwitcher: Only true or false allowed")
        end
	else
		ModSwitcher_Output_Status_Console()
	end
end

local function OnCommandPowerPointDamage(client, activeBoolean)

    if client == nil or client:GetIsLocalClient() then
        OnCommandPowerPointDamageAdmin(client, activeBoolean)
    end
    
end

function OnCommandCompModeAdmin(client, activeBoolean)

    if activeBoolean then
        if activeBoolean == "true" or activeBoolean == "false" then
            ModSwitcher_Save(nil, nil, nil, nil, nil, nil, nil, activeBoolean, false)
            Shared.Message("The changes only take effect after the next mapchange")

            // send it to every player
            ModSwitcher_Output_Status_All()

        else
            Shared.Message("CombatModSwitcher: Only true or false allowed")
        end
    else
        ModSwitcher_Output_Status_Console()
    end
end

local function OnCommandCompMode(client, activeBoolean)

    if client == nil or client:GetIsLocalClient() then
        OnCommandCompModeAdmin(client, activeBoolean)
    end

end

local function OnCommandDefaultWinner(client, defaultWinner)

    if client == nil or client:GetIsLocalClient() then
        OnCommandDefaultWinnerAdmin(client, defaultWinner)
    end
    
end

function OnCommandDefaultWinnerAdmin(client, defaultWinner)
	
    if defaultWinner then
        if tonumber(defaultWinner) and tonumber(defaultWinner) >= 1 and tonumber(defaultWinner) <= 2 then
            ModSwitcher_Save(nil, nil, nil, nil, nil, nil, tonumber(defaultWinner), nil, false)
			kCombatDefaultWinner = tonumber(defaultWinner)
            
            // send it to every player            
            ModSwitcher_Output_Status_All()
        else
            Shared.Message("CombatModSwitcher: Only 1 or 2 allowed. (1 = Marines, 2 = Aliens)")
        end
	else
		ModSwitcher_Output_Status_Console()
    end
end


function OnCommandChangeMap(client, mapName)
    
    if client == nil or client:GetIsLocalClient() then
		local playerCount = Shared.GetEntitiesWithClassname("Player"):GetSize()
		ModSwitcher_Save(nil, nil, playerCount, nil, nil, nil, nil, nil, false)
	
        MapCycle_ChangeMap(mapName)
    end
    
end

// this should only be used when a player makes racistic comments etc. and no admin is there! 
function OnCommandSuperAdminKick(client, userId)

    local steamId = client:GetUserId()
    if Shared.GetCheatsEnabled() or IsSuperAdmin(steamId)  then  
        if userId then        
            for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do   
                local playerClient = Server.GetOwner(player)      
                if  playerClient:GetUserId() == tonumber(userId) then
                    Server.DisconnectClient(playerClient)
                    break
                end                
            end

        else
            Shared.Message("Player List -")        
            for _, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do
            
                local playerClient = Server.GetOwner(player)
                Shared.Message(player:GetName() .. " : " .. playerClient:GetUserId())
                
            end
        end
    end
    
end

local function ActuallyKill(player)

    if player ~= nil then
        
		if HasMixin(player, "Live") and player:GetCanDie() then
			player:Kill(nil, nil, player:GetOrigin())
		end
        
    end
	
	return false
    
end

Event.Hook("Console_superadminkick",       OnCommandSuperAdminKick) 

function OnCommandSoundTest(client)

    local player = client:GetControllingPlayer()
    Print("Soundtest")    
    Server.PlayPrivateSound(player, testSound, player, 1.0, Vector(0, 0, 0))

end

Event.Hook("Console_soundtest",       OnCommandSoundTest) 



// All commands that should be accessible via the chat need to be in this list
combatCommands = {"co_spendlvl", "co_help", "co_status", "co_upgrades", "/upgrades", "/status", "/buy", "/help", "/timeleft"}

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
	Event.Hook("Console_co_timeleft",              OnCommandTimeLeft)
	Event.Hook("Console_timeleft",              OnCommandTimeLeft)
	Event.Hook("Console_/timeleft",              OnCommandTimeLeft)
    Event.Hook("Console_/status",                OnCommandStatus) 
    //Event.Hook("Console_/stuck",                OnCommandStuck)    
    Event.Hook("Console_co_sendupgrades",       OnCommandSendUpgrades) 
	Event.Hook("Console_co_refundall", 	        OnCommandRefundAllUpgrades)
    
end

// only this command works when in classic mode
// to make it available for admins and dedicated servers
Event.Hook("Console_co_mod_active",         OnCommandModActive) 
Event.Hook("Console_co_mod_threshold",         OnCommandModThreshold) 
Event.Hook("Console_co_mod_timelimit",         OnCommandTimeLimit) 
Event.Hook("Console_co_mod_overtime",         OnCommandOvertime) 
Event.Hook("Console_co_mod_powerpointdamage",         OnCommandPowerPointDamage) 
Event.Hook("Console_co_mod_defaultwinner",         OnCommandDefaultWinner) 
Event.Hook("Console_co_mod_compmode",         OnCommandCompMode)
Event.Hook("Console_changemap", OnCommandChangeMap)
CreateServerAdminCommand("Console_sv_co_mod_active", OnCommandModActiveAdmin, "<true/false> Switches between combat and classic mode") 
CreateServerAdminCommand("Console_sv_co_mod_threshold", OnCommandModThresholdAdmin, "<number of players> Sets the game to classic mode after a certain player threshold") 
CreateServerAdminCommand("Console_sv_co_mod_timelimit", OnCommandTimeLimitAdmin, "<number of seconds> Sets the time limit of the game (in seconds)") 
CreateServerAdminCommand("Console_sv_co_mod_overtime", OnCommandOvertimeAdmin, "<true/false> Sets whether the game can go into overtime") 
CreateServerAdminCommand("Console_sv_co_mod_powerpointdamage", OnCommandPowerPointDamageAdmin, "<true/false> Sets whether power points can take damage") 
CreateServerAdminCommand("Console_sv_co_mod_defaultwinner", OnCommandDefaultWinnerAdmin, "<1/2> Sets the default winner") 
CreateServerAdminCommand("Console_sv_co_mod_compmode", OnCommandCompModeAdmin, "<true/false> Sets whether competitive mode is activated")
CreateServerAdminCommand("Console_sv_changemap", OnCommandChangeMap, "<map name>, Switches to the map specified") 