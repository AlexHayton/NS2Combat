//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

Script.Load("lua/ModUtility.lua")

// Adjust values
Script.Load("lua/ExtraEntitiesMod/eem_Globals.lua")

// New functions
Script.Load("lua/ExtraEntitiesMod/eem_Utility.lua")

// Class overrides here
Script.Load("lua/ExtraEntitiesMod/eem_MovementModifier.lua")
Script.Load("lua/ExtraEntitiesMod/PathingUtility_Modded.lua")
Script.Load("lua/ExtraEntitiesMod/OrdersMixin_Modded.lua")
Script.Load("lua/ExtraEntitiesMod/DamageTypes_modded.lua")
Script.Load("lua/ExtraEntitiesMod/Player_modded.lua")
Script.Load("lua/ExtraEntitiesMod/Spit_modded.lua")
Script.Load("lua/ExtraEntitiesMod/Team_modded.lua")
Script.Load("lua/ExtraEntitiesMod/eem_ParticleEffect.lua")
Script.Load("lua/ExtraEntitiesMod/Exo_modded.lua")
Script.Load("lua/ExtraEntitiesMod/RagdollMixin_modded.lua")
Script.Load("lua/ExtraEntitiesMod/NS2Utiliy_modded.lua")
Script.Load("lua/ExtraEntitiesMod/BaseMoveMixin_modded.lua")
Script.Load("lua/ExtraEntitiesMod/Order_modded.lua")

// New classes
Script.Load("lua/ExtraEntitiesMod/TeleportTrigger.lua")
Script.Load("lua/ExtraEntitiesMod/FuncTrain.lua")
Script.Load("lua/ExtraEntitiesMod/FuncPlatform.lua")
Script.Load("lua/ExtraEntitiesMod/FuncTrainWaypoint.lua")
Script.Load("lua/ExtraEntitiesMod/FuncMoveable.lua")
Script.Load("lua/ExtraEntitiesMod/FuncDoor.lua")
Script.Load("lua/ExtraEntitiesMod/PushTrigger.lua")
Script.Load("lua/ExtraEntitiesMod/LogicTimer.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMultiplier.lua")
Script.Load("lua/ExtraEntitiesMod/LogicSwitch.lua")
Script.Load("lua/ExtraEntitiesMod/LogicWeldable.lua")
Script.Load("lua/ExtraEntitiesMod/LogicFunction.lua")
Script.Load("lua/ExtraEntitiesMod/LogicCounter.lua")
Script.Load("lua/ExtraEntitiesMod/LogicTrigger.lua")
Script.Load("lua/ExtraEntitiesMod/LogicLua.lua")
Script.Load("lua/ExtraEntitiesMod/LogicEmitter.lua")
Script.Load("lua/ExtraEntitiesMod/LogicEmitterDestroyer.lua")
Script.Load("lua/ExtraEntitiesMod/LogicListener.lua")
Script.Load("lua/ExtraEntitiesMod/LogicButton.lua")
Script.Load("lua/ExtraEntitiesMod/LogicWorldTooltip.lua")
Script.Load("lua/ExtraEntitiesMod/LogicWaypoint.lua")
Script.Load("lua/ExtraEntitiesMod/LogicGiveItem.lua")
Script.Load("lua/ExtraEntitiesMod/LogicReset.lua")

Script.Load("lua/ExtraEntitiesMod/MapSettings.lua")
Script.Load("lua/ExtraEntitiesMod/NobuildArea.lua")

Script.Load("lua/ExtraEntitiesMod/GravityTrigger.lua")


// npc things
Script.Load("lua/ExtraEntitiesMod/npc/NpcUtility.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcSpawner.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcSpawnerMarine.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcSpawnerMarineExo.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcSpawnerSkulk.lua")

Script.Load("lua/ExtraEntitiesMod/npc/NpcWaveManager.lua")


// old ns2 alpha entity, made as logic
Script.Load("lua/ExtraEntitiesMod/LogicTarget.lua")

// disable the portal gun, was just 4 fun, maybe make it later better
// Script.Load("lua/ExtraEntitiesMod/PortalGunTeleport.lua")
//Script.Load("lua/ExtraEntitiesMod/PortalGun.lua")


if Client then
	Script.Load("lua/ExtraEntitiesMod/eem_Player_Client.lua")
//	Script.Load("lua/ExtraEntitiesMod/Hud/GUIFuncTrain.lua")
end
