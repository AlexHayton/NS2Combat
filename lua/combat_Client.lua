//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// Load the script from fsfod that we can hook some functions
Script.Load("lua/PathUtil.lua")
Script.Load("lua/fsfod_scripts.lua")

// Loading the Hook classes
Script.Load("lua/Hud/Marine/combat_GUIMarineHud.lua")

// Calling the Hook classes
CombatGUIMarineHud:OnLoad()

// Load the normal Ns2 Server Scripts
Script.Load("lua/Client.lua");

// Tell the class hooker that we've fully loaded.
ClassHooker:OnLuaFullyLoaded()
