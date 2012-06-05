//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_Server.lua

// Load the script from fsfod that we can hook some functions
Script.Load("lua/PathUtil.lua")
Script.Load("lua/fsfod_scripts.lua")


// Loading the Hook classes
Script.Load("lua/combat_PlayingTeam.lua")
Script.Load("lua/combat_Balance.lua")
Script.Load("lua/combat_Player.lua")
Script.Load("lua/combat_CommandStation.lua")


// Calling the Hook classes
CombatPlayingTeam:OnLoad()
CombatBalance:OnLoad()
CombatPlayer:OnLoad()
CombatCommandStation:OnLoad()

// Load the normal Ns2 Server Scripts
Script.Load("lua/Server.lua")


// new functions, no hooks
Script.Load("lua/combat_Player_normal.lua")
Script.Load("lua/combat_ConsoleCommands.lua")


ClassHooker:OnLuaFullyLoaded()


