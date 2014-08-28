//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Server.lua

// sewleks framework
Script.Load("lua/PreLoadMod.lua")

// Load the script from fsfod that we can hook some functions
Script.Load("lua/PathUtil.lua")
Script.Load("lua/fsfod_scripts.lua")
Script.Load("lua/combat_Shared.lua")

// load the ModSwitcher functions
Script.Load("lua/combat_ModSwitcher.lua")
ModSwitcher_Load(true)

// dont load the rest of the hooks if combat mode is deactivated
if kCombatModActive then

	// Register the files we don't want to ever load.
	// Disabled for now - it would work if we didn't have the mod switcher!
	//Script.Load("lua/combat_FileOverrides.lua")
	
	// Language Support
	Script.Load("lua/combat_Locale.lua")
	Script.Load("gamestrings/combat_enUS.lua")

    // Loading the Hook classes
    // TODO: Maybe we don't need the OnLoad?
    Script.Load("lua/combat_TechTreeHooks.lua")
    Script.Load("lua/combat_NS2Gamerules_Hooks.lua")
    Script.Load("lua/combat_Team.lua")
    Script.Load("lua/combat_PlayingTeam.lua")
    Script.Load("lua/combat_MarineTeam.lua")
    Script.Load("lua/combat_AlienTeam.lua")
	Script.Load("lua/combat_AlienTeamInfo.lua")
    Script.Load("lua/combat_Embryo.lua")
    Script.Load("lua/combat_TeamMessenger.lua")
    Script.Load("lua/combat_PowerPoint.lua")
    Script.Load("lua/combat_PlayerHooks.lua")
    Script.Load("lua/combat_Alien_Hooks.lua")
    Script.Load("lua/combat_Marine_Hooks.lua")
    Script.Load("lua/combat_CommandStructure_Hooks.lua")
    Script.Load("lua/combat_Hive.lua")
    Script.Load("lua/combat_Armory.lua")
    Script.Load("lua/combat_Weapon.lua")    
    Script.Load("lua/combat_NS2Utility.lua")
	// Hooks for Ink and EMP are in here.
	Script.Load("lua/combat_SoundEffect.lua")
	Script.Load("lua/combat_Hydra.lua")
	Script.Load("lua/Weapons/Alien/combat_StructureAbility.lua")
    
end

// but load the weapon hook, even in vanilla ns2 that marine reloading is working
Script.Load("lua/Weapons/Marines/combat_ClipWeapon.lua")

Script.Load("lua/Shared.lua")
Script.Load("lua/ClassUtility.lua")

// load the extra entities
Script.Load("lua/ExtraEntitiesMod/eem_Shared.lua")

// Load the normal Ns2 Server Scripts
Script.Load("lua/Server.lua")

if kCombatModActive then

    // new functions, no hooks
    Script.Load("lua/combat_TechTree.lua")
    Script.Load("lua/combat_TechNode.lua")
	Script.Load("lua/combat_NS2Gamerules.lua")
    Script.Load("lua/combat_Chat.lua")
	Script.Load("lua/combat_CustomEffects.lua")
    Script.Load("lua/combat_CommandStructure.lua")
    Script.Load("lua/combat_StaticTargetMixin.lua")
    Script.Load("lua/combat_AlienTeam_NewFuncs.lua")
    Script.Load("lua/combat_CombatUpgrade.lua")
    Script.Load("lua/combat_CombatMarineUpgrade.lua")
    Script.Load("lua/combat_CombatAlienUpgrade.lua")
    Script.Load("lua/combat_ExperienceData.lua")
    Script.Load("lua/combat_ExperienceFuncs.lua")
    Script.Load("lua/combat_Utility.lua")
    Script.Load("lua/combat_Values.lua")

    Script.Load("lua/combat_Props.lua")
    // halloween special
    //Script.Load("lua/combat_Halloween.lua")

    // due to a bug, this needs to be loaded here
	Script.Load("lua/combat_PowerConsumerMixin.lua")
    Script.Load("lua/combat_PointGiverMixin.lua")
    Script.Load("lua/combat_WeldableMixin.lua")
	Script.Load("lua/combat_LiveMixin.lua")
    Script.Load("lua/Weapons/Alien/combat_HealSprayMixin.lua")
    Script.Load("lua/combat_ScoringMixin.lua")
	
	// new hook style hooks
	Script.Load("lua/combat_Babbler.lua")
	Script.Load("lua/combat_Onos.lua")
	Script.Load("lua/combat_StompMixin.lua")
    
end

// load the aitest class (even when combat mod is off so there are no client-server errors)
Script.Load("lua/combat_ReadyRoomTeam.lua")

// also load the console commands when combat is deactivated
Script.Load("lua/combat_ConsoleCommands.lua")

// Load the Versions Checker and kill him
Script.Load("lua/combat_VersionsCheck.lua")
CombatInitCheckVersion()

Script.Load("lua/PostLoadMod.lua")

// Tell the class hooker that we've fully loaded.
ClassHooker:OnLuaFullyLoaded()