//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Predict.lua

// Set the name of the VM for debugging
decoda_name = "Predict"

// sewleks framework
Script.Load("lua/PreLoadMod.lua")

// Load the script from fsfod that we can hook some functions
Script.Load("lua/PathUtil.lua")
Script.Load("lua/fsfod_scripts.lua")

Script.Load("lua/combat_Shared.lua")

Script.Load("lua/Shared.lua")
Script.Load("lua/ClassUtility.lua")

// load the extra entities
Script.Load("lua/ExtraEntitiesMod/eem_Shared.lua")

Script.Load("lua/Predict.lua")

Script.Load("lua/combat_ScoringMixin.lua")

Script.Load("lua/PostLoadMod.lua")
