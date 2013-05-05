//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_CustomEffects.lua

// Sounds for both client and server
CombatEffects = {}
CombatEffects.kMarineLvlUpSound = PrecacheAsset("sound/combat.fev/combat/upgrades/marine_lvl_up")
CombatEffects.kAlienLvlUpSound = PrecacheAsset("sound/NS2.fev/alien/common/res_received")
CombatEffects.kMarineXpSound = PrecacheAsset("sound/NS2.fev/marine/common/res_received")
CombatEffects.kAlienXpSound = PrecacheAsset("sound/combat.fev/combat/upgrades/alien_lvl_up")
CombatEffects.kLastStandAnnounce = PrecacheAsset("sound/combat.fev/combat/general/overtime001")

kCombatEffects =
{
 
	// When a player levels up...
    combat_level_up =
    {
        levelUpEffects = 
        {
			{cinematic = "cinematics/marine/infantryportal/player_spawn.cinematic", classname = "Alien"},
            {private_sound = "sound/NS2.fev/alien/common/res_received", classname = "Alien", done = true},
			{cinematic = "cinematics/marine/infantryportal/player_spawn.cinematic"},
            {private_sound = "sound/combat.fev/combat/upgrades/marine_lvl_up"},
        },
    },
	
	combat_xp =
    {
        resReceivedEffects =
        {
            {private_sound = "sound/combat.fev/combat/upgrades/alien_lvl_up", classname = "Alien", done = true},
            // Marine/Exo
            {private_sound = "sound/NS2.fev/marine/common/res_received", done = true},

        },
    },
	
}

GetEffectManager():AddEffectData("combat_CustomEffects", kCombatEffects)
GetEffectManager():PrecacheEffects()