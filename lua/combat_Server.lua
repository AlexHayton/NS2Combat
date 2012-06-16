//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Server.lua

// Load the script from fsfod that we can hook some functions
Script.Load("lua/PathUtil.lua")
Script.Load("lua/fsfod_scripts.lua")

// Loading the Hook classes
// TODO: Maybe we don't need the OnLoad?
Script.Load("lua/combat_NS2Gamerules.lua")
Script.Load("lua/combat_PointGiverMixin.lua")
Script.Load("lua/combat_Team.lua")
Script.Load("lua/combat_PlayingTeam.lua")
Script.Load("lua/combat_MarineTeam.lua")
Script.Load("lua/combat_AlienTeam.lua")
Script.Load("lua/combat_Balance.lua")
Script.Load("lua/combat_Player.lua")
Script.Load("lua/combat_Marine.lua")
Script.Load("lua/combat_CommandStructure.lua")
Script.Load("lua/combat_Hive.lua")

// Calling the Hook classes
CombatNS2Gamerules:OnLoad()
CombatPointGiverMixin:OnLoad()
CombatTeam:OnLoad()
CombatPlayingTeam:OnLoad()
CombatMarineTeam:OnLoad()
CombatAlienTeam:OnLoad()
CombatBalance:OnLoad()
CombatPlayer:OnLoad()
CombatMarine:OnLoad()
CombatCommandStructure:OnLoad()
CombatHive:OnLoad()

// Load the normal Ns2 Server Scripts
Script.Load("lua/Server.lua")

// new functions, no hooks
Script.Load("lua/combat_Chat.lua")
Script.Load("lua/combat_Player_normal.lua")
Script.Load("lua/combat_ConsoleCommands.lua")

// Tell the class hooker that we've fully loaded.
ClassHooker:OnLuaFullyLoaded()


