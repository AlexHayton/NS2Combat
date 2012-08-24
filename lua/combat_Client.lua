//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// Load the script from fsfod that we can hook some functions
Script.Load("lua/PathUtil.lua")
Script.Load("lua/fsfod_scripts.lua")

// Loading the Hook classes
Script.Load("lua/combat_Utility.lua")
Script.Load("lua/Hud/Marine/combat_GUIMarineHud.lua")
Script.Load("lua/Hud/Alien/combat_GUIAlienBuyMenu.lua")
Script.Load("lua/Hud/combat_GUIPlayerResources.lua")
Script.Load("lua/combat_Player_ClientHook.lua")

// Calling the Hook classes
CombatUtility:OnLoad()
CombatGUIMarineHud:OnLoad()
CombatGUIAlienBuyMenu:OnLoad()
CombatGUIPlayerResources:OnLoad()
CombatPlayerClient:OnLoad()

// Load the normal Ns2 Server Scripts
Script.Load("lua/Client.lua")

if kDebugPrecache then
	CombatUtility:LoadAssetList()
end

// new functions, no hooks
// to provide the client also with all Ups (for the GUI)
Script.Load("lua/combat_Player_ClientUpgrade.lua")
Script.Load("lua/combat_CombatUpgrade.lua")
Script.Load("lua/combat_CombatMarineUpgrade.lua")
Script.Load("lua/combat_CombatAlienUpgrade.lua")
Script.Load("lua/combat_ExperienceData.lua")
Script.Load("lua/combat_ExperienceFuncs.lua")
Script.Load("lua/combat_Values.lua")
Script.Load("lua/combat_ConsoleCommands_Client.lua")
Script.Load("lua/combat_MarineBuyFuncs.lua")
Script.Load("lua/combat_AlienBuyFuncs.lua")

// just for testing that i see the props
//Script.Load("lua/combat_Props.lua")

// Tell the class hooker that we've fully loaded.
ClassHooker:OnLuaFullyLoaded()
