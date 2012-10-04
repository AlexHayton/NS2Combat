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
						
kCombatUpgradeNotifyInterval = 20
kCombatReminderNotifyInterval = 45
kDirectMessageFadeTime = 8
kDirectMessagesNumVisible = 9

// Menu tweaks
kCombatAlienBuyMenuTotalAngle = 0.8
kCombatAlienBuyMenuUpgradeButtonDistance = 210

// Set the respawn timer
kCombatRespawnTimer = 10
kAlienWaveSpawnInterval = 10

// Rebalancing Intervals (secs)
kCombatRebalanceInterval = 300

// Spawn protection
kCombatMarineSpawnProtectTime = 4
// nano shield = spawn Protection
kNanoShieldDuration = kCombatMarineSpawnProtectTime 
kCombatAlienSpawnProtectTime = 5
kSpawnMaxRetries = 30
kSpawnMinDistance = 3
kSpawnMaxDistance = 70
kSpawnMaxVertical = 30

// By default, Aliens win after a certain amount of time...
// Specified in seconds...
kCombatTimeLimit = 1500
kCombatTimeLeftPlayed = 0
kCombatTimeReminderInterval = 300

// make xpeffect less "spammy"
kXPEffectTimer = 0.2
kXPForgetTimer = 5

// Timers for Scan, Resupply and Catalyst packs.
kScanTimer = 14
kResupplyTimer = 10
AmmoPack.kNumClips = 1
kCatalystTimer = 14
// scan Duration, maybe we need to tune it a bit
kScanDuration = 7
kScanRadius = 40

// Make these less "spammy"
kEMPTimer = 30
kInkTimer = 30

// fast reload
kClassicReloadTime = 1.150000
kCombatFastReloadTime = kClassicReloadTime * 1.375

// Focus
kCombatFocusAttackSpeed = 0.6
kCombatFocusDamageScalar = 1.23

// Props
kPropEffect = "vortex_destroy"
kPropEffectTimer = 2

// Gestate Times
kGestateTime = {}
kGestateTime[kTechId.Skulk] = 1.5
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
kStructureWeldRate = 120
// The rate at which players gain XP for healing... relative to damage dealt.
kHealXpRate = 1
// Rate at which players gain XP for healing other players...
kPlayerHealXpRate = 0

// Power points
kPowerPointHealth = 1200	
kPowerPointArmor = 500	
kPowerPointPointValue = 0

// Alien vision should be free
kAlienVisionCost = 0
kAlienVisionEnergyRegenMod = 1

// Ammo for mines
kNumMines = 1

// Override the costs of each of our entries.
// These won't take effect on the client side until we import this file into the client side mods

// at the moment, nobody should buy something, it needs to be implemented before
kPlayerInitialIndivRes = 0
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
kHydraCost = 0
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
kCommandStationHealth = 4000

// dont Track the CombatMod anylonger (later we could maybe make our own tracking site?
kStatisticsURL = ""
