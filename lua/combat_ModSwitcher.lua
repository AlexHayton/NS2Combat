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

kCombatModActive = true
kCombatPlayerThreshold = 0
kCombatLastPlayerCount = 0
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
            end
			local originalCombatModActive = kCombatModActive
			
			if tonumber(settings.ModPlayerThreshold) and tonumber(settings.ModPlayerThreshold) > -1 then
				kCombatPlayerThreshold = settings.ModPlayerThreshold
			else
				Shared.Message("For the value ModPlayerThreshold in " .. kCombatModSwitcherPath .. " only numbers from 0 and above are allowed")
			end
			
			if tonumber(settings.ModLastPlayerCount) and tonumber(settings.ModLastPlayerCount) > -1 then
				kCombatLastPlayerCount = settings.ModLastPlayerCount
			else
				Shared.Message("For the value ModLastPlayerCount in " .. kCombatModSwitcherPath .. " only numbers from 0 and above are allowed")
			end
			
			// Enable/Disable the mod based on the player threshold if that value is set.
			if kCombatModActive and kCombatPlayerThreshold > 0 then
				if kCombatLastPlayerCount < kCombatPlayerThreshold then
					kCombatModActive = true
				else
					kCombatModActive = false
				end
			end
            
            Shared.Message("**********************************")
            Shared.Message("**********************************")
            Shared.Message("\n")
			Shared.Message("CombatMod Mod Active Setting is: " .. ModSwitcher_Status(originalCombatModActive)) 
			Shared.Message("CombatMod Player Threshold is " .. kCombatPlayerThreshold .. " players.")
			Shared.Message("CombatMod Last Map ended with " .. kCombatLastPlayerCount .. " players.")
            Shared.Message("CombatMod is now: " .. ModSwitcher_Status(kCombatModActive)) 
            Shared.Message("\n")
            Shared.Message("**********************************")
            Shared.Message("**********************************")
            
        else
            io.close(settingsFile)
            return settings
        end
        
    else
        // file not found, create it
        Shared.Message(kCombatModSwitcherPath .. " not found, will create it now.")
        ModSwitcher_Save(kCombatModActive, kCombatPlayerThreshold, kCombatLastPlayerCount, true)       
    end 
    
end


// save it, but change the local variable when the map is changing (will be done via load the value
function ModSwitcher_Save(ModActiveBool, ThresholdNumber, LastPlayers, newlyCreate)
  
	// Default values in case the file does not exist.
	local currentSettings = { 
		ModActive = true,
		ModThreshold = 0,
		ModLastPlayerCount = 0
	}
	// If we're not newly creating the file, fill in any missing values here.
    if not newlyCreate then
		// load the values, maybe it was changed shortly before and the local value is wrong, but dont change the local value
		currentSettings = ModSwitcher_Load(false)
	end
	
	Shared.Message("\n")
 
	// Override the incoming values with the current ones if they are not specified.
    if currentSettings.ModActive == nil then    
		ModActiveBool = true
	elseif ModActiveBool == nil then
		ModActiveBool = currentSettings.ModActive
	else
		Shared.Message("CombatMod is now: " .. ModSwitcher_Status(ModActiveBool))
	end
	
	if currentSettings.ModPlayerThreshold == nil then    
		ThresholdNumber = 0
	elseif ThresholdNumber == nil then
		ThresholdNumber = currentSettings.ModPlayerThreshold
	else
		Shared.Message("CombatModPlayerThreshold is now: " .. ThresholdNumber)
	end
	
	if currentSettings.ModLastPlayerCount == nil then    
		LastPlayers = 0
	elseif LastPlayers == nil then
		LastPlayers = currentSettings.ModLastPlayerCount	
	else
		Shared.Message("CombatModLastPlayerCount is now: " .. LastPlayers)
	end

	// Save to disk.
	local settingsFile = io.open(kCombatModSwitcherPath, "w+")
	
	kCombatModSwitcherConfig = { 
						ModActive = ModActiveBool,
						ModPlayerThreshold = ThresholdNumber,
						ModLastPlayerCount = LastPlayers
						}
	
	// if its not exist it will be created automatically                  
	settingsFile:write(json.encode(kCombatModSwitcherConfig))
	
	io.close(settingsFile)

end

function ModSwitcher_Status(Boolean)        
    return ConditionalValue(ToString(Boolean) == "true", "activated", "deactivated")
end

function ModSwitcher_OnClientConnect(client)
    SendCombatModeActive(client, kCombatModActive)
end

// to tell every client if the combat mode is active or not
Event.Hook("ClientConnect", ModSwitcher_OnClientConnect)