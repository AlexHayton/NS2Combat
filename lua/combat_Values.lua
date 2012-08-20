//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Values.lua

// Experience based values like avgXpAmount is still in ExperienceData

// Welcome Message that every player receives who joined our game

Script.Load("Version.lua")
combatModifiedMessage = "This mod is not reflective of the standard NS2 experience!!"
combatWelcomeMessage = {combatModifiedMessage,
                        "This server is running a special Combat Mod V." .. kCombatLocalVersion .. ".",
                        "This mod removes RTS elements and gives you upgrades for kills.",
                        "Score = XP and Resources = Upgrade Points to use.",
                        "For more information type /help in the chat or console."
                        }
						
kCombatUpgradeNotifyInterval = 10
kCombatReminderNotifyInterval = 35
kDirectMessageFadeTime = 8
kDirectMessagesNumVisible = 9

// Set the respawn timer
kCombatRespawnTimer = 10
kAlienWaveSpawnInterval = 10

// Spawn protection
kCombatSpawnProtectTime = 4
// nano shield = spawn Protection
kNanoShieldDuration = kCombatSpawnProtectTime 

// By default, Aliens win after a certain amount of time...
// Specified in seconds...
kCombatTimeLimit = 1200
kCombatTimeLeftPlayed = 0
kCombatTimeReminderInterval = 300

// Timers for Scan, Resupply and Catalyst packs.
kScanTimer = 12
kResupplyTimer = 10
kCatalystTimer = 20
// scan Duration, maybe we need to tune it a bit
kScanDuration = 5
kScanRadius = 30

kEMPTimer = 20
kInkTimer = 15

// Props
kPropEffect = "vortex_destroy"
kPropEffectTimer = 2

// Gestate Times
kGestateTime = {}
kGestateTime[kTechId.Skulk] = 2
kGestateTime[kTechId.Gorge] = 3
kGestateTime[kTechId.Lerk] = 4
kGestateTime[kTechId.Fade] = 5
kGestateTime[kTechId.Onos] = 8
kSkulkGestateTime = kGestateTime[kTechId.Skulk]

// No eggs
kAlienEggsPerHive = 0

// Don't try to increase the Infestation radius above kMaxRadius - you will get errors in Infestation.lua
//kHiveInfestationRadius = 20

// Tweaks for weapons and upgrades
// Camouflage
kCamouflageTime = 1.5
kCamouflageUncloakFactor = 2 / 3

// Gorge Healspray heals more (and makes a bit more damage)
kHealsprayDamage = 10
// Conversely, reduce the welder's effectiveness from its original value of 150.
kStructureWeldRate = 100

// Alien vision should be free
kAlienVisionCost = 0
kAlienVisionEnergyRegenMod = 1

// Ammo for mines
kNumMines = 1

// Override the costs of each of our entries.
// These won't take effect on the client side until we import this file into the client side mods

// at the moment, nobody should buy something, it needs to be implemented before
local generalCost = 99

kShotgunCost = generalCost
kMinesCost = generalCost
kGrenadeLauncherCost = generalCost
kFlamethrowerCost = generalCost
kJetpackCost = generalCost
kExosuitCost = generalCost
kMinigunCost = generalCost
kDualMinigunCost = generalCost

kGorgeCost = generalCost
kLerkCost = generalCost
kFadeCost = generalCost
kOnosCost = generalCost
kCarapaceCost = generalCost
kRegenerationCost = generalCost
kAuraCost = generalCost
kSilenceCost = generalCost
kHydraAbilityCost = generalCost
kPiercingCost = generalCost
kAdrenalineCost = generalCost
kFeintCost = generalCost
kSapCost = generalCost
kBoneShieldCost = generalCost
kCelerityCost = generalCost
kHyperMutationCost = generalCost

// Health values
// Make the marine structures slightly less squishy...
kArmoryHealth = 2500
kCommandStationHealth = 3500

// dont Track the CombatMod anylonger (later we could maybe make our own tracking site?
kStatisticsURL = ""
