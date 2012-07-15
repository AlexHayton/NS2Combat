//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
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
			allXp = allXp + player:GetXp()
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

function GetXpValue(entity)

	if entity:isa("Player") then
		return XpList[entity.combatTable.lvl]["GivenXP"]
	else
		return XpValues[entity:GetClassName()]
	end
	
end

// Used to check whether an entity should deliver Xp on death or on damage
function GetTrickleXp(entity)
	if entity:isa("Hive") or entity:isa("CommandStation") or entity:isa("Armory") then
		return true
	else
		return false
	end
end

function GetAllUpgrades(team)
	
	local upgradeList = {}
	local className = ""
	
	if team == "Marine" then
		className = "CombatMarineUpgrade"
	else
		className = "CombatAlienUpgrade"
	end
	
	// Extract all the upgrades for this kind of team (Alien vs. Marine).
	for index, upgrade in pairs(UpsList) do
		if upgrade:isa(className) then
			table.insert(upgradeList, upgrade)
		end
	end
	
	return upgradeList
	
end

function GetUpgradeFromId(upgradeId)

	// Find the upgrade that matches this Id.
	for index, upgrade in pairs(UpsList) do
		if upgrade:GetId() == upgradeId then
			return upgrade
		end
	end

end

function GetUpgradesOfType(upgradeList, upgradeType)

	local typeList = {}

	// Extract all the upgrades of this type.
	for index, upgrade in pairs(upgradeList) do
		if upgrade:GetType() == upgradeType then
			table.insert(typeList, upgrade)
		end
	end
	
	return typeList

end

function GetUpgradeFromTextCode(textCode)

	for index, upgrade in pairs(UpsList) do
		if (textCode == upgrade:GetTextCode()) then
			return upgrade
		end
	end
	
	return nil

end

function GetUpgradeFromTechId(techId)

	for index, upgrade in pairs(UpsList) do
		if (techId == upgrade:GetTechId()) then
			return upgrade
		end
	end
	
	return nil

end