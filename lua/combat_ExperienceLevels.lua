//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_ExperienceLevels.lua

// XP-List
//Table for 
//    LVL,  needed XP to reach, RineName, AlienName, givenXP to killer     
local HotReload = XpList
if(not HotReload) then
	XpList = {}
end
XpList[1] = { Level=1, 		XP=0,		MarineName="Private", 				AlienName="Hatchling", 		GivenXP=60}
XpList[2] = { Level=2, 		XP=100, 	MarineName="Private First Class", 	AlienName="Xenoform", 		GivenXP=70}
XpList[3] = { Level=3, 		XP=250, 	MarineName="Corporal", 				AlienName="Minion", 		GivenXP=80}
XpList[4] = { Level=4, 		XP=500, 	MarineName="Sergeant", 				AlienName="Ambusher", 		GivenXP=90}
XpList[5] = { Level=5, 		XP=800, 	MarineName="Lieutenant", 			AlienName="Attacker", 		GivenXP=100}
XpList[6] = { Level=6, 		XP=1100, 	MarineName="Captain", 				AlienName="Rampager", 		GivenXP=110}
XpList[7] = { Level=7, 		XP=1450, 	MarineName="Commander", 			AlienName="Slaughterer", 	GivenXP=120}
XpList[8] = { Level=8, 		XP=1900, 	MarineName="Major", 				AlienName="Eliminator", 	GivenXP=130}
XpList[9] = { Level=9, 		XP=2300, 	MarineName="Field Marshal", 		AlienName="Nightmare", 		GivenXP=140}
XpList[10] = { Level=10, 	XP=2800, 	MarineName="General", 				AlienName="Behemoth", 		GivenXP=160}
XpList[11] = { Level=11, 	XP=3500, 	MarineName="President", 			AlienName="Overlord", 		GivenXP=180}
XpList[12] = { Level=12, 	XP=4500, 	MarineName="Badass", 				AlienName="Super Mutant", 	GivenXP=200}
XpList[13] = { Level=13, 	XP=6000, 	MarineName="Rambo", 				AlienName="Hive Mind", 	 	GivenXP=210}

maxLvl = table.maxn(XpList)
maxXp = XpList[maxLvl]["XP"]

function Experience_GetLvl(xp)

	local returnlevel = 1

	// Look up the level of this amount of Xp
	if xp >= maxXp then 
		return maxLvl
	end
	
	// ToDo: Do a faster search instead. We're going to be here a lot!
	for index, thislevel in ipairs(XpList) do
	
		if xp >= thislevel["XP"] and 
		   xp < XpList[index+1]["XP"] then
		
			returnlevel = thislevel["Level"]
		
		end
		
	end

	return returnlevel
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

function Experience_XpForLvl(lvl)

	local returnXp = XpList[1]["XP"]

	if lvl > 0 then
		returnXp = XpList[lvl]["XP"]
	end

	return returnXp
end