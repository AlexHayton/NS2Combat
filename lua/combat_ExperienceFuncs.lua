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

function Experience_GetLvlName(lvl, team)

	local LvlName = ""
	// ToDo: Support Marine vs Marine?
	if (team == 1) then
		LvlName = XpList[lvl]["MarineName"]
	else
		LvlName = XpList[lvl]["AlienName"]
	end
	
	return LvlName
	
end

function Experience_GetLvl(xp)

	local returnlevel = 1

	// Look up the level of this amount of Xp
	if xp >= maxXp then 
		return maxLvl
	end
	
	// ToDo: Do a binary search instead. We're going to be here a lot!
	for index, thislevel in ipairs(XpList) do
	
		if xp >= thislevel["XP"] and 
		   xp < XpList[index+1]["XP"] then
		
			returnlevel = thislevel["Level"]
		
		end
		
	end

	return returnlevel
end