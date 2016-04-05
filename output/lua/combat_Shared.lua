
//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_shared.lua


// creates a global hook table that we can Remove all hooks, if necessary
function _addHookToTable(hook)

    if not globalHookTable then
        globalHookTable = {}
    end

    table.insert(globalHookTable , hook)

end

// the weapon hook, even in vanilla ns2 that marine reloading is working and to provide focus
Script.Load("lua/Weapons/Marines/combat_ClipWeapon.lua")
Script.Load("lua/combat_Alien_Hooks.lua")

// add every new class (entity based) here
//LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/AITEST.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/combat_Player.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/combat_SpawnProtectClass.lua", nil)
//LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/combat_Xmas.lua", nil)
//LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/combat_XmasGift.lua", nil)
//LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/Weapons/Alien/Devour.lua", nil)
//LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/Weapons/Alien/WebAbility.lua", nil)
//LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/Weapons/Alien/Web.lua", nil)
//LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/Weapons/Alien/WebShot.lua", nil)
//LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/DevouredPlayer.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/combat_DisorientableMixin.lua", nil)
LoadTracker:LoadScriptAfter("lua/Shared.lua", "lua/combat_Exo.lua", nil)

// Register Network Messages here.
Script.Load("lua/combat_NetworkMessages.lua")





