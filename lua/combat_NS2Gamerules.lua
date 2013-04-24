//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_NS2Gamerules.lua

function NS2Gamerules:GetHasPassedTimelimit()
	if self.timeSinceGameStateChanged >= kCombatTimeLimit then
		return true
	else
		return false
	end
end