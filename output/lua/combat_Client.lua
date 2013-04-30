//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// sewleks framework
Script.Load("lua/PreLoadMod.lua")

// Load the script from fsfod that we can hook some functions
Script.Load("lua/PathUtil.lua")
Script.Load("lua/fsfod_scripts.lua")
Script.Load("lua/combat_Shared.lua")

/*
test = {
chatMessage = "Test",
teamOnly = false
}

Client.SendNetworkMessage("ChatClient", test, true)
*/

//Client.SendNetworkMessage("CombatModeActive_Client", {})

// Register the files we don't want to ever load.
// Seems to work well but not compatible with the ModSwitcher class yet.
//Script.Load("lua/combat_FileOverrides.lua")

// Loading the Hook classes
Script.Load("lua/Hud/Marine/combat_GUIMarineHud.lua")
Script.Load("lua/Hud/Alien/combat_GUIAlienBuyMenu.lua")
Script.Load("lua/Hud/Alien/combat_GUIAlienSpectatorHUD.lua")
Script.Load("lua/Hud/combat_GUIPlayerResources.lua")
Script.Load("lua/combat_Player_ClientHook.lua")
Script.Load("lua/combat_Alien_Hooks.lua")
Script.Load("lua/combat_Armory_Client.lua")
Script.Load("lua/Weapons/Alien/combat_StructureAbility.lua")


Script.Load("lua/ClientResources.lua")

Script.Load("lua/Shared.lua")
Script.Load("lua/ClassUtility.lua")

// load the extra entities
Script.Load("lua/ExtraEntitiesMod/eem_Shared.lua")

// Load the normal Ns2 Server Scripts
Script.Load("lua/Client.lua")

// new functions, no hooks
// to provide the client also with all Ups (for the GUI)

function combatLoadClientFunctions()

	// Language support
	Script.Load("lua/combat_Locale.lua")
	local locale = Client.GetOptionString( "locale", "enUS" )
	// Test for locale here when we have more languages added.
	Script.Load("gamestrings/combat_enUS.lua")
	
	// Load everything we need for Combat
    Script.Load("lua/combat_Player_ClientUpgrade.lua")
    Script.Load("lua/combat_CustomEffects.lua")
    Script.Load("lua/combat_CombatUpgrade.lua")
    Script.Load("lua/combat_CombatMarineUpgrade.lua")
    Script.Load("lua/combat_CombatAlienUpgrade.lua")
    Script.Load("lua/combat_ExperienceLevels.lua")
    Script.Load("lua/combat_ExperienceData.lua")
    Script.Load("lua/combat_ExperienceFuncs.lua")
    Script.Load("lua/combat_Values.lua")
    Script.Load("lua/combat_ConsoleCommands_Client.lua")
    Script.Load("lua/combat_MarineBuyFuncs.lua")
    Script.Load("lua/combat_AlienBuyFuncs.lua")
	Script.Load("lua/combat_PowerConsumerMixin.lua")
    Script.Load("lua/combat_Marine_Client.lua")
    Script.Load("lua/Hud/combat_GUIExperienceBar.lua")
	Script.Load("lua/Hud/combat_GUIGameTimeCountDown.lua")
	Script.Load("lua/Hud/GUIDevouredPlayer.lua")
	Script.Load("lua/Hud/GUIDevourOnos.lua")
	
    Script.Load("lua/combat_ScoringMixin.lua")

end

Script.Load("lua/PostLoadMod.lua")

// Tell the class hooker that we've fully loaded.
ClassHooker:OnLuaFullyLoaded()
