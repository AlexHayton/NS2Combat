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

local function UpgradeArmor(player, self)
	CombatUpgrade.ExecuteTechUpgrade(player, self)
	player:UpdateArmorAmounts()
end

local function GiveJetpack(player, self)
	player:GiveJetpack()
end

local function TierTwo(player, self)
	player:UnlockTierTwo()
end

local function TierThree(player, self)
	player:UnlockTierThree()
end

local function Camouflage(player, self)
	player.combatTable.hasCamouflage = true
end

local function BuildUpgrade(team, upgradeId, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)
	local upgrade
	if team == "Marine" then
		upgrade = CombatMarineUpgrade()
	else
		upgrade = CombatAlienUpgrade()
	end
	
	upgrade:Initialize(upgradeId, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)
end

UpsList = {}
// Marine Upgrades
// Parameters:        				team,	 upgradeId, 						upgradeDesc, 		upgradeTechId, 				upgradeFunc, 	requirements, 				levels, upgradeType
// Start with classes
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Jetpack,			"Jetpack",			nil, 						GiveJetpack, 	kCombatUpgrades.Armor2, 	1, 		kCombatUpgradeTypes.Class))

// Weapons
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Mines,				"Mines",			kTechId.LayMines, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Weapon))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Welder,			"Welder",			kTechId.Welder, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Weapon))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Shotgun,			"Shotgun",			kTechId.Shotgun, 			nil, 			kCombatUpgrades.Weapons1, 	1, 		kCombatUpgradeTypes.Weapon))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Flamethrower,		"Flamethrower",		kTechId.Flamethrower, 		nil, 			kCombatUpgrades.Shotgun, 	1, 		kCombatUpgradeTypes.Weapon))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.GrenadeLauncher,	"GrenadeLauncher",	kTechId.GrenadeLauncher, 	nil, 			kCombatUpgrades.Shotgun, 	1, 		kCombatUpgradeTypes.Weapon))

// Tech
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons1,			"Damage 1",			kTechId.Weapons1, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons2,			"Damage 2",			kTechId.Weapons2, 			nil, 			kCombatUpgrades.Weapons1,	1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons3,			"Damage 3",			kTechId.Weapons3, 			nil, 			kCombatUpgrades.Weapons2, 	1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor1,			"Armor 1",			kTechId.Armor1, 			UpgradeArmor, 	nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor2,			"Armor 2",			kTechId.Armor2, 			UpgradeArmor, 	kCombatUpgrades.Armor1,		1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor3,			"Armor 3",			kTechId.Armor3, 			UpgradeArmor, 	kCombatUpgrades.Armor2, 	1, 		kCombatUpgradeTypes.Tech))

// Add motion detector, scanner, resup, catpacks as available...

// Alien Upgrades
// Parameters:        				team,	 upgradeId, 						upgradeDesc, 		upgradeTechId, 				upgradeFunc, 	requirements, 				levels, upgradeType
// Start with classes
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Gorge,				"Gorge",			kTechId.Gorge, 				nil, 			nil, 						1, 		kCombatUpgradeTypes.Class))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Lerk,				"Lerk",				kTechId.Lerk, 				nil, 			kCombatUpgrades.Gorge, 		1, 		kCombatUpgradeTypes.Class))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Fade,				"Fade",				kTechId.Fade, 				nil, 			kCombatUpgrades.Gorge, 		2, 		kCombatUpgradeTypes.Class))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Onos,				"Onos",				kTechId.Onos, 				nil, 			kCombatUpgrades.Fade, 		2, 		kCombatUpgradeTypes.Class))

// Tech
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierTwo,			"Tier 2",			kTechId.TwoHives, 			TierTwo, 		nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierThree,			"Tier 3",			kTechId.ThreeHives, 		TierThree, 		kCombatUpgrades.TierTwo,	1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Carapace,			"Carapace",			kTechId.Carapace, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Regeneration,		"Regeneration",		kTechId.Regeneration, 		nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Silence,			"Silence",			kTechId.Silence, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Camouflage,			"Camouflage",		kTechId.Shade, 				Camouflage,		nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Celerity,			"Celerity",			kTechId.Celerity, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))