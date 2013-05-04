//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_PowerPoint.lua
local kSocketedModelName = PrecacheAsset("models/system/editor/power_node.model")
local kSocketedAnimationGraph = PrecacheAsset("models/system/editor/power_node.animation_graph")
local kAuxPowerBackupSound = PrecacheAsset("sound/NS2.fev/marine/power_node/backup")

local HotReload = CombatPowerPoint
if(not HotReload) then
  CombatPowerPoint = {}
  ClassHooker:Mixin("CombatPowerPoint")
end

function CombatPowerPoint:OnLoad()
    ClassHooker:SetClassCreatedIn("PowerPoint", "lua/PowerPoint.lua") 
    self:ReplaceClassFunction("PowerPoint", "GetCanTakeDamageOverride", "PowerPointGetCanTakeDamageOverride_Hook")
    self:PostHookClassFunction("PowerPoint", "OnInitialized", "OnInitialized_Hook")
	self:PostHookClassFunction("PowerPoint", "Reset", "Reset_Hook")
    self:PostHookClassFunction("PowerPoint", "OnKill", "OnKill_Hook")
end

function CombatPowerPoint:PowerPointGetCanTakeDamageOverride_Hook(self)
    return kCombatPowerPointsTakeDamage
end

local function PowerUp(self)

	self:SetModel(kSocketedModelName, kSocketedAnimationGraph)
	self:SetInternalPowerState(PowerPoint.kPowerState.socketed)
	self:SetConstructionComplete()
	self:SetLightMode(kLightMode.Normal)
	self:StopSound(kAuxPowerBackupSound)
	self:TriggerEffects("fixed_power_up")
	self:SetPoweringState(true)
	
end

function CombatPowerPoint:OnInitialized_Hook(self)
	PowerUp(self)
end

function CombatPowerPoint:Reset_Hook()
	PowerUp(self)
end

local function AutoRepair(self)
	self.health = kPowerPointHealth
	self.armor = kPowerPointArmor
	
	self.maxHealth = kPowerPointHealth
	self.maxArmor = kPowerPointArmor
	
	self.alive = true
	
	PowerUp(self)
	return false
end

function CombatPowerPoint:OnKill_Hook(self, attacker, doer, point, direction)
	if attacker and attacker:isa("Player") then
		self:AddTimedCallback(AutoRepair, kCombatPowerPointAutoRepairTime)
	end
end

if (not HotReload) then
	CombatPowerPoint:OnLoad()
end
