//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________


// add every new class (entity based) here

Script.Load("lua/eem_Globals.lua")

LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/eem_Utility.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/NS2Gamerules_hook.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/TeleportTrigger.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/FuncTrain.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/FuncTrainWaypoint.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/FuncMoveable.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/FuncDoor.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/PushTrigger.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/LogicTimer.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/LogicMultiplier.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/LogicWeldable.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/LogicFunction.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/LogicCounter.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/LogicTrigger.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/LogicLua.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/MapSettings.lua", nil)

// file overrides
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/eem_MovementModifier.lua", nil)


