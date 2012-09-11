//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
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
XpList[5] = { Level=5, 		XP=800, 	MarineName="Lieutenant", 			AlienName="Attacker", 		GivenXP=100}
XpList[6] = { Level=6, 		XP=1100, 	MarineName="Captain", 				AlienName="Rampager", 		GivenXP=110}
XpList[7] = { Level=7, 		XP=1450, 	MarineName="Commander", 			AlienName="Slaughterer", 	GivenXP=120}
XpList[8] = { Level=8, 		XP=1900, 	MarineName="Major", 				AlienName="Eliminator", 	GivenXP=130}
XpList[9] = { Level=9, 		XP=2300, 	MarineName="Field Marshal", 		AlienName="Nightmare", 		GivenXP=140}
XpList[10] = { Level=10, 	XP=2800, 	MarineName="General", 				AlienName="Behemoth", 		GivenXP=150}
XpList[11] = { Level=11, 	XP=3500, 	MarineName="President", 			AlienName="Overlord", 		GivenXP=160}

// default start points
kCombatStartUpgradePoints = 0

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
XpValues["Hydra"] = 30
XpValues["Clog"] = 20
XpValues["Armory"] = 50
XpValues["CommandStation"] = 150
XpValues["Hive"] = 400

// xp  for welding, healing
kCombatHealingXP = 5

local function UpgradeArmor(player, techUpgrade)
	techUpgrade:ExecuteTechUpgrade(player)
	player:UpdateArmorAmount()
end

local function GiveJetpack(player, techUpgrade)
	local jetpackMarine = player:GiveJetpack()
	// get jp back after respawn
	jetpackMarine.combatTable.giveClassAfterRespawn = JetpackMarine.kMapName
	return jetpackMarine
end

local function GiveExo(player, techUpgrade)
	local exoMarine = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, player:GetOrigin())
	// get exo back after respawn
	exoMarine.combatTable.giveClassAfterRespawn = Exo.kMapName
	return exoMarine
end

local function GiveExoDualMinigun(player, techUpgrade)
	player:InitDualMinigun()
end

local function TierTwo(player, techUpgrade)
    player.combatTable.twoHives = true
end

local function TierThree(player, techUpgrade)
    player.combatTable.threeHives = true
end

local function Camouflage(player, techUpgrade)
    player.combatTable.hasCamouflage = true
end

local function Scan(player, techUpgrade)
	player.combatTable.hasScan = true
	player.combatTable.lastScan = 0
end

local function Resupply(player, techUpgrade)
	player.combatTable.hasResupply = true
	player.combatTable.lastResupply = 0
end

local function Catalyst(player, techUpgrade)
	player.combatTable.hasCatalyst = true
	player.combatTable.lastCatalyst = 0
end

local function FastReload(player, techUpgrade)
	player.combatTable.hasFastReload = true
end

local function EMP(player, techUpgrade)
	player.combatTable.hasEMP = true
	player.combatTable.lastEMP = 0
	player:SendDirectMessage("You got EMP-taunt, use your taunt key to activate it")
end

local function ShadeInk(player, techUpgrade)
    player.combatTable.hasInk = true
	player.combatTable.lastInk = 0
    player:SendDirectMessage("You got Ink-taunt, use your taunt key to activate it")
end

local function GiveWelder(player, techUpgrade)
	techUpgrade:ExecuteTechUpgrade(player)
	player.combatTable.justGotWelder = true
	
	// SwitchWeapon here doesn't work - move it further along...
	//player:SwitchWeapon(1)
end

// Helper function to build upgrades for us.
local function BuildUpgrade(team, upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType, mutuallyExclusive)
	local upgrade = nil
	
	if team == "Marine" then
		upgrade = CombatMarineUpgrade()
	else
		upgrade = CombatAlienUpgrade()
	end
	upgrade:Initialize(upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType, mutuallyExclusive)
	
	return upgrade
end

if(not HotReload) then
	UpsList = {}
end
// Clear the table
for k,v in pairs(UpsList) do UpsList[k]=nil end

// Marine Upgrades
// Parameters:        				team,	 upgradeId, 							upgradeTextCode, 	upgradeDesc, 		upgradeTechId, 					upgradeFunc, 		requirements, 				levels, upgradeType,				mutuallyExclusive			
// Start with classes                                                                                                                                                                                                                           
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Jetpack,				"jp",				"Jetpack",			kTechId.Jetpack, 				GiveJetpack, 		kCombatUpgrades.Armor2, 	2, 		kCombatUpgradeTypes.Class,	kCombatUpgrades.Exosuit)) 	
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Exosuit,   			"exo",			    "Exosuit",			kTechId.Exosuit, 	       		GiveExo,        	kCombatUpgrades.Armor2, 	2, 		kCombatUpgradeTypes.Class,	kCombatUpgrades.Jetpack)) 
                                                                                                                                                                                                                                                
// Weapons                                                                                                                                                                                                                                      
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Mines,					"mines",			"Mines",			kTechId.LayMines, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Weapon, kCombatUpgrades.Exosuit)) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Welder,				"welder",			"Welder",			kTechId.Welder, 				GiveWelder, 		nil, 						1, 		kCombatUpgradeTypes.Weapon, kCombatUpgrades.Exosuit)) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Shotgun,				"sg",				"Shotgun",			kTechId.Shotgun, 				nil, 				kCombatUpgrades.Weapons1, 	1, 		kCombatUpgradeTypes.Weapon, kCombatUpgrades.Exosuit)) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Flamethrower,			"flame",			"Flamethrower",		kTechId.Flamethrower, 			nil, 				kCombatUpgrades.Shotgun, 	1, 		kCombatUpgradeTypes.Weapon, kCombatUpgrades.Exosuit)) 	
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.GrenadeLauncher,		"gl",				"Grenade Launcher",	kTechId.GrenadeLauncher, 		nil, 				kCombatUpgrades.Shotgun, 	1, 		kCombatUpgradeTypes.Weapon, kCombatUpgrades.Exosuit)) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.DualMinigunExosuit,   	"dualminigun",		"Dual Miniguns",	kTechId.DualMinigunExosuit, 	GiveExoDualMinigun, kCombatUpgrades.Exosuit, 	1, 		kCombatUpgradeTypes.Tech,   kCombatUpgrades.Jetpack)) 
                                                                                                                                                                                                                                                
// Tech                                                                                                                                                                                                                                         
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons1,				"dmg1",				"Damage 1",			kTechId.Weapons1, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   nil)) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons2,				"dmg2",				"Damage 2",			kTechId.Weapons2, 				nil, 				kCombatUpgrades.Weapons1,	1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons3,				"dmg3",				"Damage 3",			kTechId.Weapons3, 				nil, 				kCombatUpgrades.Weapons2, 	1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor1,				"arm1",				"Armor 1",			kTechId.Armor1, 				UpgradeArmor, 		nil, 						1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor2,				"arm2",				"Armor 2",			kTechId.Armor2, 				UpgradeArmor, 		kCombatUpgrades.Armor1,		1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor3,				"arm3",				"Armor 3",			kTechId.Armor3, 				UpgradeArmor, 		kCombatUpgrades.Armor2, 	1, 		kCombatUpgradeTypes.Tech,   nil)) 					
                                                                                                                                                                                                                                                
// Add motion detector, scanner, resup, catpacks as available...                                                                                                                                                                                
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Scanner,				"scan",				"Scanner",			kTechId.Scan, 			   		Scan, 	      		nil,                     	1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Resupply,				"resup",			"Resupply",			kTechId.MedPack , 	       		Resupply,    		nil, 	                    1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Catalyst,				"cat",				"Catalyst",			kTechId.CatPack , 	       		Catalyst,  			nil, 	                    1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.EMP,   				"emp",			    "EMP-Taunt",		kTechId.MACEMP , 	       		EMP,        		nil, 	                    1, 		kCombatUpgradeTypes.Tech,   nil)) 					
//table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.FastReload,   		"fastreload",		"Fast Reload",		kTechId.SocketPowerNode , 		FastReload,   	    nil, 	                    1, 		kCombatUpgradeTypes.Tech,   nil)) 					
                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                
// Alien Upgrades                                                                                                                                                                                                                               
// Parameters:        				team,	 upgradeId, 							upgradeTextCode, 	upgradeDesc, 		upgradeTechId, 					upgradeFunc, 		requirements, 				levels, upgradeType,                mutuallyExclusive		
// Start with classes                                                                                                                                                                                                                           
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Gorge,					"gorge",			"Gorge",			kTechId.Gorge, 					nil, 				nil, 						1, 		kCombatUpgradeTypes.Class,  nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Lerk,					"lerk",				"Lerk",				kTechId.Lerk, 					nil, 				nil,                 		2, 		kCombatUpgradeTypes.Class,  nil)) 						
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Fade,					"fade",				"Fade",				kTechId.Fade, 					nil, 				nil,                 		3, 		kCombatUpgradeTypes.Class,  nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Onos,					"onos",				"Onos",				kTechId.Onos, 					nil, 				nil,                 		4, 		kCombatUpgradeTypes.Class,  nil)) 					
                                                                                                                                                                                                                                                
// Tech                                                                                                                                                                                                                                         
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Carapace,				"cara",				"Carapace",			kTechId.Carapace, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Regeneration,			"regen",			"Regeneration",		kTechId.Regeneration, 			nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Silence,				"silence",			"Silence",			kTechId.Silence, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Camouflage,				"camo",				"Camouflage",		kTechId.Camouflage, 			Camouflage,			nil, 						1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Celerity,				"cele",				"Celerity",			kTechId.Celerity, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Adrenaline,				"adrenaline",		"Adrenaline",		kTechId.Adrenaline, 			nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   nil)) 					
// a bit sorting for better sorting in the alien GUI                                                                                                                                                                                            
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierTwo,				"tier2",			"Tier 2",			kTechId.TwoHives, 				TierTwo, 			nil, 						2, 		kCombatUpgradeTypes.Tech,   nil)) 					
                                                                                                                                                                                                                                                
// new ink abilitiy                                                                                                                                                                                                                             
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.ShadeInk,				"ink",		        "Ink-Taunt",		kTechId.ShadeInk, 		   	 	ShadeInk,			nil, 						1, 		kCombatUpgradeTypes.Tech,   nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierThree,				"tier3",			"Tier 3",			kTechId.ThreeHives, 			TierThree, 			kCombatUpgrades.TierTwo,	2, 		kCombatUpgradeTypes.Tech,   nil)) 					

