//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
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
    
	if data then
		if string.sub(data , 1, 1) ~= "<" then
			local WebVersion = tonumber(string.sub(data, string.len("kCombatLocalVersion = "), string.len("kCombatLocalVersion = ") + 6))
			if WebVersion == nil then
				Shared.Message("Could not download version check information!")
			elseif WebVersion <= kCombatLocalVersion then
				Shared.Message("CombatMod is on the newest version")
			else
				Shared.Message("Warning: CombatMod is Out of Date, your version is: " .. ToString(kCombatLocalVersion) .. " , newest version is: " .. ToString(WebVersion))
			end
		else
			// must be a 404 page
			Shared.Error("Error: Couldn't check the Version, file not found.")
		end
	else
		Shared.Error("Error: Couldn't check the Version, timed out.")
	end
    
    Shared.Message("\n")
    Shared.Message("**********************************")
    Shared.Message("**********************************")
    
end

function CombatInitCheckVersion()
	//local params = {}
	//Shared.SendHTTPRequest(kCombatVersionPath, "GET", params, CombatCheckVersion)
end