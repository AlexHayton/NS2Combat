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
XpList[4] = { Level=4, 		XP=500, 	MarineName="Sergeant", 				AlienName="Ambusher", 		GivenXP=90}
XpList[5] = { Level=5, 		XP=700, 	MarineName="Lieutenant", 			AlienName="Attacker", 		GivenXP=100}
XpList[6] = { Level=6, 		XP=1000, 	MarineName="Captain", 				AlienName="Rampager", 		GivenXP=110}
XpList[7] = { Level=7, 		XP=1350, 	MarineName="Commander", 			AlienName="Slaughterer", 	GivenXP=120}
XpList[8] = { Level=8, 		XP=1750, 	MarineName="Major", 				AlienName="Eliminator", 	GivenXP=130}
XpList[9] = { Level=9, 		XP=2200, 	MarineName="Field Marshal", 		AlienName="Nightmare", 		GivenXP=140}
XpList[10] = { Level=10, 	XP=2700, 	MarineName="General", 				AlienName="Behemoth", 		GivenXP=150}

// how much % from the avg xp can new player get
avgXpAmount = 0.75
maxLvl = table.maxn(XpList)
maxXp = XpList[maxLvl]["XP"]

// how much % from the xp are the m8 nearby getting and the range
mateXpAmount = 0.4

// range 35 was to big
mateXpRange = 15

// XP-Values
// Scores for various creatures and structures.
XpValues = {}
XpValues["Marine"] = 100
XpValues["Skulk"] = 100
XpValues["Gorge"] = 100
XpValues["Lerk"] = 100
XpValues["Fade"] = 100
XpValues["Onos"] = 100
XpValues["Hydra"] = 50
XpValues["Clog"] = 10
XpValues["Armory"] = 100

// List with possible Upgrades
UpsList = {}
UpsList.Marine = {}
// Table:        Type,   kMapName,  needs Up, need Lvl, Weapon or other
//Weapons
UpsList.Marine["mines"] = {UpgradeText = "Mines", 				UpgradeName = LayMines.kMapName, 		UpgradeTechId = kTechId.LayMines, 				Requires = nil, Levels = 1, Type = "weapon"}
UpsList.Marine["welder"] = {UpgradeText = "Welder", 			UpgradeName = Welder.kMapName, 			UpgradeTechId = kTechId.Welder,			 	Requires = nil, Levels = 1, Type = "weapon"}
UpsList.Marine["sg"] = {UpgradeText = "Shotgun", 				UpgradeName = Shotgun.kMapName,			UpgradeTechId = kTechId.ShotgunTech, 		Requires = "dmg1", Levels = 1, Type = "weapon"}
UpsList.Marine["flame"] = {UpgradeText = "Flamethrower", 		UpgradeName = Flamethrower.kMapName, 	UpgradeTechId = kTechId.Flamethrower, 		Requires = "sg", Levels = 1, Type = "weapon"}
UpsList.Marine["gl"] = {UpgradeText = "Grenade Launcher", 		UpgradeName = GrenadeLauncher.kMapName, UpgradeTechId = kTechId.GrenadeLauncher, 	Requires = "sg", Levels = 1, Type = "weapon"}
// Tech
UpsList.Marine["dmg1"] = {UpgradeText = "Damage 1", 			UpgradeName = kTechId.Weapons1, 		UpgradeTechId = kTechId.Weapons1,			Requires = nil, Levels = 1, Type = "tech"}
UpsList.Marine["dmg2"] = {UpgradeText = "Damage 2", 			UpgradeName = kTechId.Weapons2, 		UpgradeTechId = kTechId.Weapons2,			Requires = "dmg1", Levels = 1, Type = "tech"}
UpsList.Marine["dmg3"] = {UpgradeText = "Damage 3", 			UpgradeName = kTechId.Weapons3, 		UpgradeTechId = kTechId.Weapons3, 			Requires = "dmg2", Levels = 1, Type = "tech"}
UpsList.Marine["arm1"] = {UpgradeText = "Armor 1", 				UpgradeName = kTechId.Armor1, 			UpgradeTechId = kTechId.Armor1, 			Requires = nil, Levels = 1, Type = "tech"}
UpsList.Marine["arm2"] = {UpgradeText = "Armor 2", 				UpgradeName = kTechId.Armor2, 			UpgradeTechId = kTechId.Armor2, 			Requires = "arm1", Levels = 1, Type = "tech"}
UpsList.Marine["arm3"] = {UpgradeText = "Armor 3", 				UpgradeName = kTechId.Armor3, 			UpgradeTechId = kTechId.Armor3,				Requires = "arm2", Levels = 1, Type = "tech"}

// These will need some new kTechIds...
UpsList.Marine["motion"] = {UpgradeText = "Motion Detector", 	UpgradeName = nil, nil, nil, "tech"}
UpsList.Marine["scanner"] = {UpgradeText = "Scanner", 			UpgradeName = nil, nil, nil, "tech"}
UpsList.Marine["cat"] = {UpgradeText = "Catalyst Packs", 		UpgradeName = nil, nil, nil, "tech"}
UpsList.Marine["resup"] = {UpgradeText = "Resupply", 			UpgradeName = nil, nil, nil, "tech"}

// Suits for marines
UpsList.Marine["jp"] = {UpgradeText = "Jetpack", 				UpgradeName = JetpackMarine.kMapName, 	UpgradeTechId = kTechId.Jetpack, 			Requires = "arm2", Levels = 2, Type = "class"}
// if the exo is rdy
//UpsList.Marine["exo"] = {JetpackMarine.kMapName, "arm2", 2, "class"} 

UpsList.Alien = {}
// Table:        Type,   kMapName,  needs Up, need Lvl, Weapon or other
// Class
UpsList.Alien ["gorge"] = {UpgradeText = "Gorge", 				UpgradeName = kTechId.Gorge, 			UpgradeTechId = kTechId.Gorge, 				Requires = nil, Levels = 1, Type = "class"}
UpsList.Alien ["lerk"] = {UpgradeText = "Lerk", 				UpgradeName = kTechId.Lerk, 			UpgradeTechId = kTechId.Lerk, 				Requires = "gorge", Levels = 1, Type = "class"}
UpsList.Alien ["fade"] = {UpgradeText = "Fade", 				UpgradeName = kTechId.Fade, 			UpgradeTechId = kTechId.Fade, 				Requires = "gorge", Levels = 2, Type = "class"}
UpsList.Alien ["onos"] = {UpgradeText = "Onos", 				UpgradeName = kTechId.Onos, 			UpgradeTechId = kTechId.Onos, 				Requires = "fade", Levels = 2, Type = "class"}
// Tech
UpsList.Alien ["tier2"] = {UpgradeText = "Tier 2", 				UpgradeName = kTechId.Augmentation,		UpgradeTechId = kTechId.Augmentation, 		Requires = nil, Levels = 1, Type = "tech"}
UpsList.Alien ["tier3"] = {UpgradeText = "Tier 3", 				UpgradeName = kTechId.AlienArmor3,		UpgradeTechId = kTechId.AlienArmor3, 		Requires = "tier2", Levels = 1, Type = "tech"}
UpsList.Alien ["carapace"] = {UpgradeText = "Carapace", 		UpgradeName = kTechId.Carapace, 		UpgradeTechId = kTechId.Carapace, 			Requires = nil, Levels = 1, Type = "tech"}
UpsList.Alien ["regen"] = {UpgradeText = "Regeneration", 		UpgradeName = kTechId.Regeneration,		UpgradeTechId = kTechId.Regeneration, 		Requires = nil, Levels = 1, Type = "tech"}
UpsList.Alien ["silence"] = {UpgradeText = "Silence", 			UpgradeName = kTechId.Silence, 			UpgradeTechId = kTechId.Silence, 			Requires = nil, Levels = 1, Type = "tech"}
UpsList.Alien ["camo"] = {UpgradeText = "Camoflage", 			UpgradeName = kTechId.Camouflage, 		UpgradeTechId = kTechId.Camouflage,			Requires = nil, Levels = 1, Type = "tech"}
UpsList.Alien ["cele"] = {UpgradeText = "Celerity", 			UpgradeName = kTechId.Celerity, 		UpgradeTechId = kTechId.Celerity, 			Requires = nil, Levels = 1, Type = "tech"}
