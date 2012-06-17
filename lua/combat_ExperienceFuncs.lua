//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_ExperienceFuncs.lua

// Returns the average XP of all active players.
function Experience_GetAvgXp()

    local avgXp = 0
    local allXp = 0
    local playerNumbers = 0
    
    for i, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do      
		// Ignore players that are not on a team.
		if (player:GetTeamNumber() >= 1) and (player:GetTeamNumber() <= 2) then
			allXp = allXp + (player:GetXp() or 0)
			playerNumbers = playerNumbers + 1
		end
    end
    
    if allXp > 0 and playerNumbers > 0 then
        avgXp = math.floor((allXp / playerNumbers) * avgXpAmount)
    end
    
    return avgXp

end