//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_VersionsCheck.lua

// Checks if a new version is available

// Local Versionsnumber

Script.Load("Version.lua")
local kCombatVersionPath = "https://raw.github.com/AlexHayton/NS2Combat/master/Version.lua"

local CombatCheckVersion = function(data)

    Shared.Message("**********************************")
    Shared.Message("**********************************")
    Shared.Message("\n")
    Shared.Message("CombatMod: Checking Version-Number")
    Shared.Message("\n")
    
    if not string.sub(data , 1, 1) == "<" then
        local WebVersion = tonumber(string.sub(data, string.len("kCombatLocalVersion = "), 6)
        if WebVersion <= kCombatLocalVersion then
            Shared.Message("CombatMod is on the newest version")
        else
            Shared.Message("Warning: CombatMod is Out of Date, your version is: " .. ToString(kCombatLocalVersion) .. " , newest version is: " .. ToString(WebVersion))
        end
    else
        // must be a 404 page
        Shared.Error("Error: Couldn't check the Version, file not found")
    end
    
    Shared.Message("\n")
    Shared.Message("**********************************")
    Shared.Message("**********************************")
    
end

function CombatInitCheckVersion()
    Shared.GetWebpage(kCombatVersionPath, CombatCheckVersion)
end