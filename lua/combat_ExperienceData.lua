//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_ExperienceData.lua

Script.Load("lua/combat_ExperienceLevels.lua")

// default start points
kCombatStartUpgradePoints = 0

// how much % from the avg xp can new player get
avgXpAmount = 0.75

// how much % from the xp are the m8 nearby getting and the range
mateXpAmount = 0.4

// range 35 was too big
mateXpRange = 20

// XP-Values
// Scores for various creatures and structures.
if(not HotReload) then
	XpValues = {}
end
XpValues["Marine"] = 0
XpValues["Skulk"] = 0
XpValues["Gorge"] = 10
XpValues["Lerk"] = 20
XpValues["Fade"] = 50
XpValues["Onos"] = 100
XpValues["Exo"] = 100
XpValues["Hydra"] = 30
XpValues["Clog"] = 20
XpValues["Cyst"] = 10
XpValues["Armory"] = 100
XpValues["CommandStation"] = 200
XpValues["PowerPoint"] = 0
XpValues["Extractor"] = 0
XpValues["Hive"] = 400

// for our halloween AI
XpValues["AITEST"] = 200

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
	local exoMarine = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, player:GetOrigin(), { layout = "ClawMinigun" })
	return exoMarine
end

local function GiveExoDualMinigun(player, techUpgrade)
	local exoMarine = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, player:GetOrigin(), { layout = "MinigunMinigun" })
	return exoMarine
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

local function FastReload(player, techUpgrade)
	player.combatTable.hasFastReload = true
end

local function Focus(player, techUpgrade)
	player.combatTable.hasFocus = true
end

// Helper function to build upgrades for us.
local function BuildUpgrade(team, upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType, refundUpgrade, mutuallyExclusive)
	local upgrade = nil
	
	if team == "Marine" then
		upgrade = CombatMarineUpgrade()
	else
		upgrade = CombatAlienUpgrade()
	end
	upgrade:Initialize(upgradeId, upgradeTextCode, upgradeDescription, upgradeTechId, upgradeFunc, requirements, levels, upgradeType, refundUpgrade, mutuallyExclusive)
	
	return upgrade
end

if(not HotReload) then
	UpsList = {}
end
// Clear the table
for k,v in pairs(UpsList) do UpsList[k]=nil end

// Marine Upgrades
// Parameters:        				team,	 upgradeId, 							upgradeTextCode, 	upgradeDesc, 		upgradeTechId, 					upgradeFunc, 		requirements, 				levels, upgradeType,				refundUpgrade,	mutuallyExclusive			
// Start with classes                                                                                                                                                                                                                           
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Jetpack,				"jp",				"Jetpack",			kTechId.Jetpack, 				GiveJetpack, 		kCombatUpgrades.Armor2, 	2, 		kCombatUpgradeTypes.Class,	false,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit } )) 	
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Exosuit,   			"exo",			    "Exosuit",			kTechId.Exosuit, 	       		GiveExo,        	kCombatUpgrades.Armor2, 	5, 		kCombatUpgradeTypes.Class,	true,			{ kCombatUpgrades.Jetpack, kCombatUpgrades.DualMinigunExosuit } )) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.DualMinigunExosuit,   	"dualminigun",		"Dual Minigun Exo",	kTechId.DualMinigunExosuit, 	GiveExoDualMinigun, kCombatUpgrades.Armor2, 	6, 		kCombatUpgradeTypes.Class,  true,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.Jetpack } )) 
                                                                                                                                                                                                                                                
// Weapons                                                                                                                                                                                                                                      
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Mines,					"mines",			"Mines",			kTechId.LayMines, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Weapon, false,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit })) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Welder,				"welder",			"Welder",			kTechId.Welder, 				GiveWelder, 		nil, 						1, 		kCombatUpgradeTypes.Weapon, false,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit })) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Shotgun,				"sg",				"Shotgun",			kTechId.Shotgun, 				nil, 				kCombatUpgrades.Weapons1, 	1, 		kCombatUpgradeTypes.Weapon, false,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit })) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Flamethrower,			"flame",			"Flamethrower",		kTechId.Flamethrower, 			nil, 				kCombatUpgrades.Shotgun, 	1, 		kCombatUpgradeTypes.Weapon, false,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit, kCombatUpgrades.GrenadeLauncher })) 	
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.GrenadeLauncher,		"gl",				"Grenade Launcher",	kTechId.GrenadeLauncher, 		nil, 				kCombatUpgrades.Shotgun, 	1, 		kCombatUpgradeTypes.Weapon, false,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit, kCombatUpgrades.Flamethrower })) 
                                                                                                                                                                                                                                                
// Tech                                                                                                                                                                                                                                         
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons1,				"dmg1",				"Damage 1",			kTechId.Weapons1, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons2,				"dmg2",				"Damage 2",			kTechId.Weapons2, 				nil, 				kCombatUpgrades.Weapons1,	1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Weapons3,				"dmg3",				"Damage 3",			kTechId.Weapons3, 				nil, 				kCombatUpgrades.Weapons2, 	1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor1,				"arm1",				"Armor 1",			kTechId.Armor1, 				UpgradeArmor, 		nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor2,				"arm2",				"Armor 2",			kTechId.Armor2, 				UpgradeArmor, 		kCombatUpgrades.Armor1,		1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Armor3,				"arm3",				"Armor 3",			kTechId.Armor3, 				UpgradeArmor, 		kCombatUpgrades.Armor2, 	1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
                                                                                                                                                                                                                                                
// Add motion detector, scanner, resup, catpacks as available...                                                                                                                                                                                
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Scanner,				"scan",				"Scanner",			kTechId.Scan, 			   		Scan, 	      		nil,                     	1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Resupply,				"resup",			"Resupply",			kTechId.MedPack , 	       		Resupply,    		nil, 	                    1, 		kCombatUpgradeTypes.Tech,   false,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit })) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.Catalyst,				"cat",				"Catalyst",			kTechId.CatPack , 	       		Catalyst,  			nil, 	                    1, 		kCombatUpgradeTypes.Tech,   false,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit })) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.EMP,   				"emp",			    "EMP-Taunt",		kTechId.MACEMP , 	       		EMP,        		nil, 	                    1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Marine", kCombatUpgrades.FastReload,   		    "fastreload",		"Fast Reload",		kTechId.RifleUpgrade , 		    FastReload,   	    nil, 	                    1, 		kCombatUpgradeTypes.Tech,   false,			{ kCombatUpgrades.Exosuit, kCombatUpgrades.DualMinigunExosuit })) 					
                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                
// Alien Upgrades                                                                                                                                                                                                                               
// Parameters:        				team,	 upgradeId, 							upgradeTextCode, 	upgradeDesc, 		upgradeTechId, 					upgradeFunc, 		requirements, 				levels, upgradeType,                refundUpgrade,	mutuallyExclusive		
// Start with classes                                                                                                                                                                                                                           
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Gorge,					"gorge",			"Gorge",			kTechId.Gorge, 					nil, 				nil, 						1, 		kCombatUpgradeTypes.Class,  true,			nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Lerk,					"lerk",				"Lerk",				kTechId.Lerk, 					nil, 				nil,                 		2, 		kCombatUpgradeTypes.Class,  true,			nil)) 						
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Fade,					"fade",				"Fade",				kTechId.Fade, 					nil, 				nil,                 		3, 		kCombatUpgradeTypes.Class,  true,			nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Onos,					"onos",				"Onos",				kTechId.Onos, 					nil, 				nil,                 		5, 		kCombatUpgradeTypes.Class,  true,			nil)) 					
                                                                                                                                                                                                                                                
// Tech                                                                                                                                                                                                                                         
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Carapace,				"cara",				"Carapace",			kTechId.Carapace, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Regeneration,			"regen",			"Regeneration",		kTechId.Regeneration, 			nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Silence,				"silence",			"Silence",			kTechId.Silence, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Camouflage,				"camo",				"Camouflage",		kTechId.Camouflage, 			Camouflage,			nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Celerity,				"cele",				"Celerity",			kTechId.Celerity, 				nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Adrenaline,				"adrenaline",		"Adrenaline",		kTechId.Adrenaline, 			nil, 				nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
// a bit sorting for better sorting in the alien GUI                                                                                                                                                                                            
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierTwo,				"tier2",			"Tier 2",			kTechId.TwoHives, 				TierTwo, 			nil, 						2, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
                                                                                                                                                                                                                                                
// new ink abilitiy                                                                                                                                                                                                                             
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.ShadeInk,				"ink",		        "Ink-Taunt",		kTechId.ShadeInk, 		   	 	ShadeInk,			nil, 						1, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.TierThree,				"tier3",			"Tier 3",			kTechId.ThreeHives, 			TierThree, 			kCombatUpgrades.TierTwo,	2, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					
table.insert(UpsList, BuildUpgrade("Alien", kCombatUpgrades.Focus,				    "focus",			"Focus",			kTechId.NutrientMist, 			Focus, 			    nil,	                    2, 		kCombatUpgradeTypes.Tech,   false,			nil)) 					

