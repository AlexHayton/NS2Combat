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
			{cinematic = "cinematics/marine/infantryportal/player_spawn.cinematic"},
            {sound = "sound/NS2.fev/marine/voiceovers/commander/research_complete"}
        }
    }
    
}

GetEffectManager():AddEffectData("combat_CustomEffects", kCombatEffects)