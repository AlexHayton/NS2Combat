//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_DSPEffects.lua

local devouredPlayerLowPassId = -1
local devouredPlayerEchoId = -1

local HotReload = CombatDSPEffects
if(not HotReload) then
  CombatDSPEffects = {}
  ClassHooker:Mixin("CombatDSPEffects")
end

function CombatDSPEffects:OnLoad()

	_addHookToTable(self:PostHookFunction("CreateDSPs", "CreateDSPs_Hook"))
	_addHookToTable(self:PostHookFunction("UpdateDSPEffects", "UpdateDSPEffects_Hook"))

end

function CombatDSPEffects:CreateDSPs_Hook()

    // Devoured effect low-pass filter.
    devouredPlayerLowPassId = Client.CreateDSP(SoundSystem.DSP_LowPassSimple)
    Client.SetDSPActive(devouredPlayerLowPassId, false)
    Client.SetDSPFloatParameter(devouredPlayerLowPassId, 0, 3000)
	
	// Devoured effect echo filter.
	devouredPlayerEchoId = Client.CreateDSP(SoundSystem.DSP_Echo)
	Client.SetDSPActive(devouredPlayerEchoId, false)
    Client.SetDSPFloatParameter(devouredPlayerEchoId, 0, 45)
	
end

function CombatDSPEffects:UpdateDSPEffects_Hook()
    
    local player = Client.GetLocalPlayer()
	if (player) then
		Client.SetDSPActive(devouredPlayerLowPassId, player:isa("DevouredPlayer"))
		Client.SetDSPActive(devouredPlayerEchoId, player:isa("DevouredPlayer"))
	end
    
end

if (not HotReload) then
	CombatDSPEffects:OnLoad()
end