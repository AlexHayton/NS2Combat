//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_CustomEffects.lua

kCombatEffects =
{
 
	// When a player levels up...
    combat_level_up =
    {
        levelUpEffects = 
        {
			{cinematic = "cinematics/alien/catalyst_small.cinematic", classname = "Alien"},
            {sound = "sound/combat.fev/combat/upgrades/alien_lvl_up", classname = "Alien", done = true},
			{cinematic = "cinematics/marine/infantryportal/player_spawn.cinematic"},
            {sound = "sound/combat.fev/combat/upgrades/marine_lvl_up"}
        }
    }
    
}

GetEffectManager():AddEffectData("combat_CustomEffects", kCombatEffects)