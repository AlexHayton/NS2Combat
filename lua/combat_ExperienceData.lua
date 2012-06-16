//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_ExperienceData.lua

// XP-List
//Table for 
//    LVL,  needed XP to reach, RineName, AlienName, givenXP to killer     
XpList = {}  
XpList[1] = { Level=1, 		XP=0,		MarineName="Private", 				AlienName="Hatchling", 		GivenXP=60}
XpList[2] = { Level=2, 		XP=100, 	MarineName="Private First Class", 	AlienName="Xenoform", 		GivenXP=70}
XpList[3] = { Level=3, 		XP=250, 	MarineName="Corporal", 				AlienName="Minion", 		GivenXP=80}
XpList[4] = { Level=4, 		XP=250, 	MarineName="Sergeant", 				AlienName="Ambusher", 		GivenXP=90}
XpList[5] = { Level=5, 		XP=700, 	MarineName="Lieutenant", 			AlienName="Attacker", 		GivenXP=100}
XpList[6] = { Level=6, 		XP=1000, 	MarineName="Captain", 				AlienName="Rampager", 		GivenXP=110}
XpList[7] = { Level=7, 		XP=1350, 	MarineName="Commander", 			AlienName="Slaughterer", 	GivenXP=120}
XpList[8] = { Level=8, 		XP=1750, 	MarineName="Major", 				AlienName="Eliminator", 	GivenXP=130}
XpList[9] = { Level=9, 		XP=2200, 	MarineName="Field Marshal", 		AlienName="Nightmare", 		GivenXP=140}
XpList[10] = { Level=10, 	XP=2700, 	MarineName="General", 				AlienName="Behemoth", 		GivenXP=150}

// XP-Values
// Scores for various creatures and structures.
XpValues = {}
XpValues["Marine"] = 100
XpValues["Skulk"] = 100
XpValues["Gorge"] = 100
XpValues["Lerk"] = 100
XpValues["Fade"] = 100
XpValues["Onos"] = 100
XpValues["Hydra"] = 20
XpValues["Clog"] = 20
XpValues["Armory"] = 100

// how much % from the avg xp can new player get
avgXpAmount = 0.75

// List with possible Upgrades
UpsList = {}
UpsList.Marine = {}
// Table:        Type,   kMapName,  needs Up, need Lvl, Weapon or other
//Weapons
UpsList.Marine["mines"] = {Mine.kMapName, nil, 1, "weapon"}
UpsList.Marine["welder"] = {Welder.kMapName, nil, 1, "weapon"}
UpsList.Marine["sg"] = {Shotgun.kMapName, "dmg1", 1, "weapon"}
UpsList.Marine["flame"] = {Flamethrower.kMapName, "sg", 1, "weapon"}
UpsList.Marine["gl"] = {GrenadeLauncher.kMapName, "sg", 1, "weapon"}
// Tech
UpsList.Marine["dmg1"] = {kTechId.Weapons1, nil, 1, "tech"}
UpsList.Marine["dmg2"] = {kTechId.Weapons2, "dmg1", 1, "tech"}
UpsList.Marine["dmg3"] = {kTechId.Weapons3, "dmg2", 1, "tech"}
UpsList.Marine["arm1"] = {kTechId.Armor1, nil, 1, "tech"}
UpsList.Marine["arm2"] = {kTechId.Armor2, "arm1", 1, "tech"}
UpsList.Marine["arm3"] = {kTechId.Armor3, "arm2", 1, "tech"}

// need new functions for this
//UpsList.Marine["motion"] = {"MotionTracking", nil, 1, "tech"}
//UpsList.Marine["scanner"] = {"ScannerSweep", nil, 1, "tech"}
//UpsList.Marine["cat"] = {"CatPack", nil, 1, "tech"}
//UpsList.Marine["resup"] = {"Resuply", nil, 1, "tech"}

// Class
//UpsList.Marine["jp"] = {JetpackMarine.kMapName, "arm2", 2, "class"}
// For Testing
UpsList.Marine["jp"] = {JetpackMarine.kMapName, nil, 0, "class"}
// if the exo is rdy
//UpsList.Marine["exo"] = {JetpackMarine.kMapName, "arm2", 2, "class"} 

UpsList.Alien = {}
// Table:        Type,   kMapName,  needs Up, need Lvl, Weapon or other
// Class
UpsList.Alien ["gorge"] = {kTechId.Gorge, nil, 1, "class"}
UpsList.Alien ["lerk"] = {kTechId.Lerk, "gorge", 1, "class"}
UpsList.Alien ["fade"] = {kTechId.Fade, "gorge", 2, "class"}
UpsList.Alien ["onos"] = {kTechId.Onos, "fade", 2, "class"}
// Tech
UpsList.Alien ["tier2"] = {kTechId.Augmentation, nil, 1, "tech"}
UpsList.Alien ["tier3"] = {kTechId.AlienArmor3, "tier2", 1, "tech"}
UpsList.Alien ["carapace"] = {kTechId.Carapace, nil , 1, "tech"}
UpsList.Alien ["regen"] = {kTechId.Regeneration, nil , 1, "tech"}
UpsList.Alien ["silence"] = {kTechId.Silence, nil , 1, "tech"}
UpsList.Alien ["camo"] = {kTechId.Camouflage, nil , 1, "tech"}
UpsList.Alien ["cele"] = {kTechId.Celerity, nil , 1, "tech"}

// Change the GestateTime so every new Class takes the same time
kSkulkGestateTime = 3
kGorgeGestateTime = 3
kLerkGestateTime = 3
kFadeGestateTime = 3
kOnosGestateTime = 3

// No eggs
kAlienEggsPerHive = 0