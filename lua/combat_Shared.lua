
//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_shared.lua

// the weapon hook, even in vanilla ns2 that marine reloading is working and to provide focus
Script.Load("lua/Weapons/Marines/combat_ClipWeapon.lua")
Script.Load("lua/combat_Alien_Hooks.lua")

// add every new class (entity based) here
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/AITEST.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/TeleportTrigger.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/FuncTrain.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/FuncTrainWaypoint.lua", nil)

LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/combat_Player.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/combat_SpawnProtectClass.lua", nil)



