//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Server.lua

// Load the script from fsfod that we can hook some functions
Script.Load("lua/PathUtil.lua")
Script.Load("lua/fsfod_scripts.lua")

Script.Load("..\\NS2GmOvrmind\\Lua\\NS2GmOvrmind.lua"); -- Load the NS2-GmOvrmind prerequisites

NS2GmOvrmind.InitFunc,CallRes=package.loadlib(string.format("%s\\Binaries_x86\\%s.dll",
NS2GmOvrmind.Name.Internal,NS2GmOvrmind.Name.Internal),string.format("%s_Initialize",NS2GmOvrmind.Name.Internal));
NS2GmOvrmind.InitFunc(1); -- Execute the initialization-function (in slave-mode)

// Loading the Hook classes
// TODO: Maybe we don't need the OnLoad?
Script.Load("lua/combat_TechTreeHooks.lua")
Script.Load("lua/combat_NS2Gamerules.lua")
Script.Load("lua/combat_Team.lua")
Script.Load("lua/combat_PlayingTeam.lua")
Script.Load("lua/combat_MarineTeam.lua")
Script.Load("lua/combat_AlienTeam.lua")
Script.Load("lua/combat_Structure.lua")
Script.Load("lua/combat_Embryo.lua")
Script.Load("lua/combat_TeamMessenger.lua")
Script.Load("lua/combat_Balance.lua")
Script.Load("lua/combat_PlayerHooks.lua")
Script.Load("lua/combat_Marine.lua")
Script.Load("lua/combat_CommandStructure.lua")
Script.Load("lua/combat_Armory.lua")

// Calling the Hook classes
CombatTechTree:OnLoad()
CombatNS2Gamerules:OnLoad()
CombatTeam:OnLoad()
CombatPlayingTeam:OnLoad()
CombatMarineTeam:OnLoad()
CombatAlienTeam:OnLoad()
CombatStructure:OnLoad()
CombatEmbryo:OnLoad()
CombatTeamMessenger:OnLoad()
CombatBalance:OnLoad()
CombatPlayer:OnLoad()
CombatMarine:OnLoad()
CombatCommandStructure:OnLoad()
CombatArmory:OnLoad()

// Load the normal Ns2 Server Scripts
Script.Load("lua/Server.lua")

// new functions, no hooks
Script.Load("lua/combat_TechTree.lua")
Script.Load("lua/combat_TechNode.lua")
Script.Load("lua/combat_Chat.lua")
Script.Load("lua/combat_Player.lua")
Script.Load("lua/combat_ConsoleCommands.lua")
Script.Load("lua/combat_CombatUpgrade.lua")
Script.Load("lua/combat_CombatMarineUpgrade.lua")
Script.Load("lua/combat_CombatAlienUpgrade.lua")
Script.Load("lua/combat_ExperienceData.lua")
Script.Load("lua/combat_ExperienceFuncs.lua")
Script.Load("lua/combat_Values.lua")

// due to a bug, this needs to be loaded here
Script.Load("lua/combat_PointGiverMixin.lua")
Script.Load("lua/combat_ScoringMixin.lua")

NS2GmOvrmind.InitFunc(2); -- Execute the initialization-function (in slave-mode)

// Tell the class hooker that we've fully loaded.
ClassHooker:OnLuaFullyLoaded()