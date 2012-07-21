//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Values.lua

// Experience based values like avgXpAmount is still in ExperienceData

// Welcome Message that every player receives who joined our game
combatWelcomeMessage = {"Welcome to this Server",
                        "It's running a special Combat Mod",
                        "Score = XP and Resources = FreeLvl to use",
                        "For more informations type co_help in the chat or console"
                        }
						
kUpgradeNotifyInterval = 10

// Set the respawn timer
kCombatRespawnTimer = 10
kAlienWaveSpawnInterval = 10

// Spawn protection
kCombatSpawnProtectTime = 4
// nano shield = spawn Protection
kNanoShieldDuration = kCombatSpawnProtectTime 

// By default, Aliens win after a certain amount of time...
kCombatTimeLimit = 30

// time for Scan and Resuply
kScanTimer = 12
kResupplyTimer = 10
// scan Duration, maybe we need to tune it a bit
kScanDuration = 5
kScanRadius = 30

kEMPTimer = 20


// Change the GestateTime so every new Class takes the same time
kSkulkGestateTime = 2
kGorgeGestateTime = 2
kLerkGestateTime = 2
kFadeGestateTime = 2
kOnosGestateTime = 2

// No eggs
kAlienEggsPerHive = 0

// Tweaks for weapons and upgrades
// Camouflage
kCamouflageTime = 3
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
// Give the armory more health
kArmoryHealth = 2500

// dont Track the CombatMod anylonger (later we could maybe make our own tracking site?
kStatisticsURL = ""
