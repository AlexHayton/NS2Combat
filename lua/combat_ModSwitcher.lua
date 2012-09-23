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
                Shared.Message("For the value ModActive in " .. kCombatModSwitcherPath .. " is only true and false allowed")
            end
            
            Shared.Message("**********************************")
            Shared.Message("**********************************")
            Shared.Message("\n")
            Shared.Message("CombatMod is: " .. ModSwitcher_Status(kCombatModActive)) 
            Shared.Message("\n")
            Shared.Message("**********************************")
            Shared.Message("**********************************")
            
        else
            io.close(settingsFile)
            return settings.ModActive
        end
        
    else
        // file not found, create it
        Shared.Message(kCombatModSwitcherPath .. " not found, will create it now.")
        ModSwitcher_Save(kCombatModActive, true)       
    end 
    
end


// save it, but change the local variable when the map is changing (will be done via load the value

function ModSwitcher_Save(ModActiveBool, newlyCreate)
  
    if ModActiveBool then    
    
        if not newlyCreate then
        // load the values, maybe it was changed shortly before and the local value is wrong, but dont change the local value
            ModSwitcher_Load(false)
        end
        
        if kCombatModActive ~= ModActiveBool or newlyCreate then
            // Save to disk.
            local settingsFile = io.open(kCombatModSwitcherPath, "w+")
            
            kCombatModSwitcherConfig = { 
                                ModActive = ModActiveBool
                                }
            
            // if its not exist it will be created automatically                  
            settingsFile:write(json.encode(kCombatModSwitcherConfig))
            
            Shared.Message("\n")
            Shared.Message("CombatMod is now: " .. ModSwitcher_Status(ModActiveBool))
            io.close(settingsFile)

        end
    end

end


function ModSwitcher_Status(Boolean)        
        return ConditionalValue(ToString(Boolean) == "true", "activated", "deactivated")
end