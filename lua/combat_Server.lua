//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Server.lua

// Load the script from fsfod that we can hook some functions
Script.Load("lua/PathUtil.lua")
Script.Load("lua/fsfod_scripts.lua")

// Loading the Hook classes
// TODO: Maybe we don't need the OnLoad?
Script.Load("lua/combat_TechTreeHooks.lua")
Script.Load("lua/combat_NS2Gamerules.lua")
Script.Load("lua/combat_Team.lua")
Script.Load("lua/combat_PlayingTeam.lua")
Script.Load("lua/combat_MarineTeam.lua")
Script.Load("lua/combat_AlienTeam.lua")
Script.Load("lua/combat_Embryo.lua")
Script.Load("lua/combat_TeamMessenger.lua")
Script.Load("lua/combat_Balance.lua")
Script.Load("lua/combat_PlayerHooks.lua")
Script.Load("lua/combat_Marine.lua")
Script.Load("lua/combat_Alien.lua")
Script.Load("lua/combat_CommandStructure_Hooks.lua")
Script.Load("lua/combat_Hive.lua")
Script.Load("lua/combat_Armory.lua")
Script.Load("lua/combat_Weapon.lua")

// Calling the Hook classes
CombatTechTree:OnLoad()
CombatNS2Gamerules:OnLoad()
CombatTeam:OnLoad()
CombatPlayingTeam:OnLoad()
CombatMarineTeam:OnLoad()
CombatAlienTeam:OnLoad()
CombatEmbryo:OnLoad()
CombatTeamMessenger:OnLoad()
CombatBalance:OnLoad()
CombatPlayer:OnLoad()
CombatMarine:OnLoad()
CombatAlien:OnLoad()
CombatCommandStructure:OnLoad()
CombatHive:OnLoad()
CombatArmory:OnLoad()
CombatWeapon:OnLoad()

// Load the normal Ns2 Server Scripts
Script.Load("lua/Server.lua")

// new functions, no hooks
Script.Load("lua/combat_TechTree.lua")
Script.Load("lua/combat_TechNode.lua")
Script.Load("lua/combat_Chat.lua")
Script.Load("lua/combat_Player.lua")
Script.Load("lua/combat_CommandStructure.lua")
Script.Load("lua/combat_StaticTargetMixin.lua")
Script.Load("lua/combat_ConsoleCommands.lua")
Script.Load("lua/combat_AlienTeam_NewFuncs.lua")
Script.Load("lua/combat_CombatUpgrade.lua")
Script.Load("lua/combat_CombatMarineUpgrade.lua")
Script.Load("lua/combat_CombatAlienUpgrade.lua")
Script.Load("lua/combat_ExperienceData.lua")
Script.Load("lua/combat_ExperienceFuncs.lua")
Script.Load("lua/combat_Values.lua")

Script.Load("lua/combat_Props.lua")

// due to a bug, this needs to be loaded here
Script.Load("lua/combat_PointGiverMixin.lua")
Script.Load("lua/combat_ScoringMixin.lua")

// Load the Versions Checker and kill him
Script.Load("lua/combat_VersionsCheck.lua")
CombatInitCheckVersion()

// Tell the class hooker that we've fully loaded.
ClassHooker:OnLuaFullyLoaded()