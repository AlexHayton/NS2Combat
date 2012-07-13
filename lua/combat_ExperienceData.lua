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
local HotReload = XpList
if(not HotReload) then
	XpList = {}
end
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

// range 35 was too big
mateXpRange = 15

// XP-Values
// Scores for various creatures and structures.
if(not HotReload) then
	XpValues = {}
end
XpValues["Marine"] = 100
XpValues["Skulk"] = 100
XpValues["Gorge"] = 100
XpValues["Lerk"] = 100
XpValues["Fade"] = 100
XpValues["Onos"] = 100
XpValues["Hydra"] = 50
XpValues["Clog"] = 20
XpValues["Armory"] = 200
XpValues["CommandStation"] = 700
XpValues["Hive"] = 700

local function UpgradeArmor(player, techUpgrade)
	techUpgrade:ExecuteTechUpgrade(player)
	player:UpdateArmorAmount()
end

local function GiveJetpack(player, techUpgrade)
	jetpackMarine = player:GiveJetpack()
	// get jp back after respawn
	jetpackMarine.combatTable.giveClassAfterRespawn = JetpackMarine.kMapName
	return jetpackMarine
end

local function TierTwo(player, techUpgrade)
    player.twoHives = true
end

local function TierThree(player, techUpgrade)
    player.threeHives = true
end

local function Camouflage(player, techUpgrade)
    player.combatTable.hasCamouflage = true
end

local function Scan(player, techUpgrade)
	player.combatTable.hasScan = true
end

local function Resupply(player, techUpgrade)
	player.combatTable.hasResupply = true
end

// Helper function to build upgrades for us.
local function BuildUpgrade(team, upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)
	local upgrade = nil
	
	if team == "Marine" then
		upgrade = CombatMarineUpgrade()
	else
		upgrade = CombatAlienUpgrade()
	end
	upgrade:Initialize(upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType)
	
	return upgrade
end

if(not HotReload) then
	UpsList = {}
end
// Clear the table
for k,v in pairs(UpsList) do UpsList[k]=nil end

// Marine Upgrades
// Parameters:        				team,	 upgradeId, 						upgradeTextCode, 	upgradeDesc, 		upgradeTechId, 				upgradeFunc, 	requirements, 				levels, upgradeType
// Start with classes
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Jetpack,			"jp",				"Jetpack",			kTechId.Jetpack, 			GiveJetpack, 	kCombatUpgrades.Armor2, 	2, 		kCombatUpgradeTypes.Class))

// Weapons
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Mines,				"mines",			"Mines",			kTechId.LayMines, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Weapon))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Welder,			"welder",			"Welder",			kTechId.Welder, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Weapon))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Shotgun,			"sg",				"Shotgun",			kTechId.Shotgun, 			nil, 			kCombatUpgrades.Weapons1, 	1, 		kCombatUpgradeTypes.Weapon))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Flamethrower,		"flame",			"Flamethrower",		kTechId.Flamethrower, 		nil, 			kCombatUpgrades.Shotgun, 	1, 		kCombatUpgradeTypes.Weapon))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.GrenadeLauncher,	"gl",				"GrenadeLauncher",	kTechId.GrenadeLauncher, 	nil, 			kCombatUpgrades.Shotgun, 	1, 		kCombatUpgradeTypes.Weapon))

// Tech
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons1,			"dmg1",				"Damage 1",			kTechId.Weapons1, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons2,			"dmg2",				"Damage 2",			kTechId.Weapons2, 			nil, 			kCombatUpgrades.Weapons1,	1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons3,			"dmg3",				"Damage 3",			kTechId.Weapons3, 			nil, 			kCombatUpgrades.Weapons2, 	1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor1,			"arm1",				"Armor 1",			kTechId.Armor1, 			UpgradeArmor, 	nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor2,			"arm2",				"Armor 2",			kTechId.Armor2, 			UpgradeArmor, 	kCombatUpgrades.Armor1,		1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor3,			"arm3",				"Armor 3",			kTechId.Armor3, 			UpgradeArmor, 	kCombatUpgrades.Armor2, 	1, 		kCombatUpgradeTypes.Tech))

// Add motion detector, scanner, resup, catpacks as available...
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Scanner,			"scan",				"Scanner",			kTechId.Scan, 			    Scan, 	        nil,                     	1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Resupply,			"resup",			"Resupply",			kTechId.MedPack , 	        Resupply,    	nil, 	                    1, 		kCombatUpgradeTypes.Tech))


// Alien Upgrades
// Parameters:        				team,	 upgradeId, 						upgradeTextCode, 	upgradeDesc, 		upgradeTechId, 				upgradeFunc, 	requirements, 				levels, upgradeType
// Start with classes
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Gorge,				"gorge",			"Gorge",			kTechId.Gorge, 				nil, 			nil, 						1, 		kCombatUpgradeTypes.Class))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Lerk,				"lerk",				"Lerk",				kTechId.Lerk, 				nil, 			nil,                 		2, 		kCombatUpgradeTypes.Class))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Fade,				"fade",				"Fade",				kTechId.Fade, 				nil, 			nil,                 		3, 		kCombatUpgradeTypes.Class))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Onos,				"onos",				"Onos",				kTechId.Onos, 				nil, 			nil,                 		4, 		kCombatUpgradeTypes.Class))

// Tech
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierTwo,			"tier2",			"Tier 2",			kTechId.TwoHives, 			TierTwo, 		nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierThree,			"tier3",			"Tier 3",			kTechId.ThreeHives, 		TierThree, 		kCombatUpgrades.TierTwo,	2, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Carapace,			"cara",				"Carapace",			kTechId.Carapace, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Regeneration,		"regen",			"Regeneration",		kTechId.Regeneration, 		nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Silence,			"silence",			"Silence",			kTechId.Silence, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Camouflage,			"camo",				"Camouflage",		kTechId.Camouflage, 		Camouflage,		nil, 						1, 		kCombatUpgradeTypes.Tech))
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Celerity,			"cele",				"Celerity",			kTechId.Celerity, 			nil, 			nil, 						1, 		kCombatUpgradeTypes.Tech))