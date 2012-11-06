//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_ModSwitchter.lua

// functions for switching the mod to classic or combat, load the defaults etc.

Script.Load("lua/dkjson.lua")
Script.Load("lua/Utility.lua")
Script.Load("lua/combat_Utility.lua")

kCombatModActiveDefault = true
kCombatPlayerThresholdDefault = 0
kCombatLastPlayerCountDefault = 0
kCombatTimeLimitDefault = 1500
kCombatGlobalMicDefault = false

kCombatModActive = kCombatModActiveDefault
kCombatPlayerThreshold = kCombatPlayerThresholdDefault
kCombatLastPlayerCount = kCombatLastPlayerCountDefault
kCombatTimeLimit = kCombatTimeLimitDefault 
kCombatGlobalMic = kCombatGlobalMicDefault
kCombatModSwitcherPath = "config://CombatMod.cfg"

// load the ModActive value from config://CombatModConfig.json
function ModSwitcher_Load(changeLocal)

    // Load the settings from file if the file exists.
    local settings = { }
    local settingsFile = io.open(kCombatModSwitcherPath, "r")
    if settingsFile then

        local fileContents = settingsFile:read("*all")
        settings = json.decode(fileContents)
        
        if changeLocal then
            // there is no string to bool function so we need to do it like this
            if settings.ModActive == "true" or settings.ModActive == true then 
                kCombatModActive = true 
            elseif settings.ModActive == "false" or  settings.ModActive == false then
                kCombatModActive = false 
            else
                Shared.Message("For the value ModActive in " .. kCombatModSwitcherPath .. " only true and false are allowed")
				Shared.Message("Resetting the value to default (true)")
				kCombatModActive = kCombatModActiveDefault
				settings.ModActive = kCombatModActiveDefault
            end
			local originalCombatModActive = kCombatModActive
			
			if tonumber(settings.ModPlayerThreshold) and tonumber(settings.ModPlayerThreshold) > -1 then
				kCombatPlayerThreshold = tonumber(settings.ModPlayerThreshold)
			else
				Shared.Message("For the value ModPlayerThreshold in " .. kCombatModSwitcherPath .. " only numbers from 0 and above are allowed")
				Shared.Message("Resetting the value to default ("..kCombatPlayerThresholdDefault..")")
				kCombatPlayerThreshold = kCombatPlayerThresholdDefault
				settings.ModPlayerThreshold = kCombatPlayerThresholdDefault
			end
			
			if tonumber(settings.ModLastPlayerCount) and tonumber(settings.ModLastPlayerCount) > -1 then
				kCombatLastPlayerCount = tonumber(settings.ModLastPlayerCount)
			else
				Shared.Message("For the value ModLastPlayerCount in " .. kCombatModSwitcherPath .. " only numbers from 0 and above are allowed")
				Shared.Message("Resetting the value to default ("..kCombatLastPlayerCountDefault..")")
				kCombatLastPlayerCount = kCombatLastPlayerCountDefault
				settings.ModLastPlayerCount = kCombatLastPlayerCountDefault
			end
			
			if tonumber(settings.ModTimeLimit) and tonumber(settings.ModTimeLimit) > -1 then
				kCombatTimeLimit = tonumber(settings.ModTimeLimit)
			else
				Shared.Message("For the value ModTimeLimit in " .. kCombatModSwitcherPath .. " only numbers from 0 and above are allowed")
				Shared.Message("Resetting the value to default ("..kCombatTimeLimitDefault..")")
				kCombatTimeLimit = kCombatTimeLimitDefault
				settings.ModTimeLimit = kCombatTimeLimitDefault
			end
			
            // there is no string to bool function so we need to do it like this
            if settings.ModGlobalMic == "true" or settings.ModGlobalMic == true then 
                kCombatGlobalMic = true 
            elseif settings.ModGlobalMic == "false" or  settings.ModGlobalMic == false then
                kCombatGlobalMic = false 
            else
                Shared.Message("For the value ModGlobalMic in " .. kCombatModSwitcherPath .. " only true and false are allowed")
				Shared.Message("Resetting the value to default (false)")
				kCombatGlobalMic = kCombatGlobalMicDefault
				settings.ModGlobalMic = kCombatGlobalMicDefault
            end
			local originalCombatModActive = kCombatModActive
			
			// Enable/Disable the mod based on the player threshold if that value is set greater than 0.
			if kCombatModActive and kCombatPlayerThreshold > 0 then
				if kCombatLastPlayerCount < kCombatPlayerThreshold then
					kCombatModActive = true
				else
					kCombatModActive = false
				end
			end
			
			ModSwitcher_Output_Status(settings)
            
        else
            io.close(settingsFile)
			
			// Handle cases where there are missing attributes.
			if settings.ModActive == nil then
				settings.ModActive = kCombatModActiveDefault
			end
			
			if settings.ModPlayerThreshold == nil then
				settings.ModPlayerThreshold = kCombatPlayerThresholdDefault
			end
			
			if settings.ModLastPlayerCount == nil then
				settings.ModLastPlayerCount = kCombatLastPlayerCountDefault
			end
			
			if settings.ModTimeLimit == nil then
				settings.ModTimeLimit = kCombatTimeLimitDefault
			end
			
			if settings.ModGlobalMic == nil then
				settings.ModGlobalMic = kCombatGlobalMicDefault
			end
			
            return settings
        end
        
    else
        // file not found, create it
        Shared.Message(kCombatModSwitcherPath .. " not found, will create it now.")
        ModSwitcher_Save(kCombatModActive, kCombatPlayerThreshold, kCombatLastPlayerCount, kCombatTimeLimit, kCombatGlobalMic, true)       
    end 
    
end


// save it, but change the local variable when the map is changing (will be done via load the value
function ModSwitcher_Save(ModActiveBool, ThresholdNumber, LastPlayers, TimeLimit, GlobalMic, newlyCreate)
  
	// Default values in case the file does not exist.
	local currentSettings = { 
		ModActive = kCombatModActiveDefault,
		ModThreshold = kCombatPlayerThresholdDefault,
		ModLastPlayerCount = kCombatLastPlayerCountDefault,
		ModTimeLimit = kCombatTimeLimitDefault,
		ModGlobalMic = kCombatGlobalMicDefault,
	}
	// If we're not newly creating the file, fill in any missing values here.
    if not newlyCreate then
		// load the values, maybe it was changed shortly before and the local value is wrong, but dont change the local value
		currentSettings = ModSwitcher_Load(false)
	end
	
	Shared.Message("\n")
 
	// Override the incoming values with the current ones if they are not specified.
    if currentSettings.ModActive == nil then    
		ModActiveBool = kCombatModActiveDefault
	elseif ModActiveBool == nil then
		ModActiveBool = currentSettings.ModActive
	else
		Shared.Message("CombatMod is now: " .. ModSwitcher_Active_Status(ModActiveBool))
	end
	
	if currentSettings.ModPlayerThreshold == nil then    
		ThresholdNumber = kCombatPlayerThresholdDefault
	elseif ThresholdNumber == nil then
		ThresholdNumber = currentSettings.ModPlayerThreshold
	else
		Shared.Message("CombatModPlayerThreshold is now: " .. ThresholdNumber)
	end
	
	if currentSettings.ModLastPlayerCount == nil then    
		LastPlayers = kCombatLastPlayerCountDefault
	elseif LastPlayers == nil then
		LastPlayers = currentSettings.ModLastPlayerCount	
	else
		Shared.Message("CombatModLastPlayerCount is now: " .. LastPlayers)
	end
	
	if currentSettings.ModTimeLimit == nil then    
		TimeLimit = kCombatTimeLimitDefault
	elseif TimeLimit == nil then
		TimeLimit = currentSettings.ModTimeLimit	
	else
		SendGlobalChatMessage("Time Limit is now: " .. GetTimeText(TimeLimit))
	end
	
    if currentSettings.ModGlobalMic == nil then    
		GlobalMic = kCombatGlobalMicDefault
	elseif GlobalMic == nil then
		GlobalMic = currentSettings.ModGlobalMic
	else
		SendGlobalChatMessage("GlobalMic is now: " .. ModSwitcher_Active_Status(GlobalMic))
	end

	// Save to disk.
	local settingsFile = io.open(kCombatModSwitcherPath, "w+")
	
	kCombatModSwitcherConfig = { 
						ModActive = ModActiveBool,
						ModPlayerThreshold = ThresholdNumber,
						ModLastPlayerCount = LastPlayers,
						ModTimeLimit = TimeLimit,
						ModGlobalMic = GlobalMic,
						}
	
	// if its not exist it will be created automatically                  
	settingsFile:write(json.encode(kCombatModSwitcherConfig))
	
	io.close(settingsFile)

end

function ModSwitcher_Output_Status_Console()
	// load the values, maybe it was changed shortly before and the local value is wrong, but dont change the local value
	currentSettings = ModSwitcher_Load(false)
	
	ModSwitcher_Output_Status(currentSettings)
end

function ModSwitcher_Output_Status(currentSettings)
	Shared.Message("**********************************")
	Shared.Message("**********************************")
	Shared.Message("\n")
	Shared.Message("CombatMod Mod Active Setting is: " .. ModSwitcher_Active_Status(currentSettings.ModActive)) 
	Shared.Message("CombatMod Player Threshold is " .. currentSettings.ModPlayerThreshold .. " players.")
	Shared.Message("CombatMod Last Map ended with " .. currentSettings.ModLastPlayerCount .. " players.")
	Shared.Message("CombatMod is now: " .. ModSwitcher_Active_Status(kCombatModActive)) 
	Shared.Message("CombatMod Time Limit is now: " .. GetTimeText(currentSettings.ModTimeLimit) .. ".")
	Shared.Message("CombatMod Global Mic is now: " .. ModSwitcher_Active_Status(currentSettings.ModGlobalMic))
	Shared.Message("\n")
	Shared.Message("**********************************")
	Shared.Message("**********************************")
end

function ModSwitcher_Output_Status_All()
	local playerCount = Shared.GetEntitiesWithClassname("Player"):GetSize()
	local currentSettings = ModSwitcher_Load(false)
	
	if (currentSettings.ModActive == "true" or currentSettings.ModActive == true) and currentSettings.ModPlayerThreshold > 0 then
		SendGlobalChatMessage("There are " .. playerCount .. " players on the server...")
		SendGlobalChatMessage("If there are more than " .. currentSettings.ModPlayerThreshold .. " players(s) on the server at next map change,")
		SendGlobalChatMessage("this server will switch to Standard NS2. If there are fewer then next round is Combat Mode!")
	else	
		SendGlobalChatMessage("On the next map change, Combat Mode will be **" .. ModSwitcher_Active_Status(currentSettings.ModActive) .. "**")
	end
end

function ModSwitcher_Active_Status(Boolean)        
    return ConditionalValue(ToString(Boolean) == "true", "activated", "deactivated")
end

function ModSwitcher_OnClientConnect(client)
    SendCombatModeActive(client, kCombatModActive)
end

// to tell every client if the combat mode is active or not
Event.Hook("ClientConnect", ModSwitcher_OnClientConnect)