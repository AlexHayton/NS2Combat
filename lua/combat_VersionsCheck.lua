//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_VersionsCheck.lua

// Checks if a new version is available

// Local Versionsnumber
kCombatLocalVersion = 0.9
local kCombatVersionPath = "https://raw.github.com/AlexHayton/NS2Combat/master/Version.txt"

local CombatCheckVersion = function(data)

    Shared.Message("**********************************")
    Shared.Message("**********************************")
    Shared.Message("\n")
    Shared.Message("CombatMod: Checking Version-Number")
    Shared.Message("\n")

    if string.len(data) < 6 then
        local Version = tonumber(data)
        if Version <= kCombatLocalVersion then
            Shared.Message("CombatMod is on the newest version")
        else
            Shared.Message("Warning: CombatMod is Out of Date, your version is: " .. ToString(kCombatLocalVersion) .. " , newest version is: " .. ToString(Version))
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