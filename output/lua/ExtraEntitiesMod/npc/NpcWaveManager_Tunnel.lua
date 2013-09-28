//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/LiveMixin.lua")
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'NpcManagerTunnel' (NpcManager)

NpcManagerTunnel.kMapName = "npc_wave_manager_tunnel"
NpcManagerTunnel.kModelName = PrecacheAsset("models/alien/tunnel/mouth.model")
local kAnimationGraph = PrecacheAsset("models/alien/tunnel/mouth.animation_graph")

local networkVars = {
    timeLastExited = "time",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

function NpcManagerTunnel:OnCreate()
	NpcManager.OnCreate(self)
	
	InitMixin(self, BaseModelMixin)
	InitMixin(self, ClientModelMixin)
	InitMixin(self, LiveMixin)
	InitMixin(self, GameEffectsMixin)
	InitMixin(self, FlinchMixin)
	InitMixin(self, TeamMixin)
	InitMixin(self, PointGiverMixin)
	InitMixin(self, SelectableMixin)
	InitMixin(self, EntityChangeMixin)
	InitMixin(self, CloakableMixin)
	InitMixin(self, LOSMixin)
	InitMixin(self, DetectableMixin)
	InitMixin(self, ConstructMixin)
	InitMixin(self, ObstacleMixin)    
	InitMixin(self, FireMixin)
	InitMixin(self, CatalystMixin)  
	InitMixin(self, UmbraMixin)
	InitMixin(self, CombatMixin)
	InitMixin(self, RagdollMixin)
	InitMixin(self, DissolveMixin)

	if Server then
		InitMixin(self, InfestationTrackerMixin)
		self.connected = false
	elseif Client then
		InitMixin(self, CommanderGlowMixin)     
	end

	self:SetLagCompensated(false)
	self:SetPhysicsType(PhysicsType.Kinematic)
	self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
	
	self.startsBuilt = true
	self.timeLastExited = 0

end

function NpcManagerTunnel:OnInitialized()
	NpcManager.OnInitialized(self)

	self:SetModel(NpcManagerTunnel.kModelName, kAnimationGraph)
	
	if Server then
	
		InitMixin(self, StaticTargetMixin)
		InitMixin(self, SleeperMixin)
		
		// This Mixin must be inited inside this OnInitialized() function.
		if Server and not HasMixin(self, "MapBlip") then
			InitMixin(self, MapBlipMixin)
		end
		
		self:SetTeamNumber(self.team)
		
		self:SetConstructionComplete()
		
	elseif Client then
	
		InitMixin(self, UnitStatusMixin)
		InitMixin(self, HiveVisionMixin)
		
	end
end

function NpcManagerTunnel:Reset()
    NpcManager.Reset(self)
    self.activatedAfterDamage = false
end

function NpcManagerTunnel:GetReceivesStructuralDamage()
    return true
end

function NpcManagerTunnel:GetMaxHealth()
    return kMatureTunnelEntranceHealth
end 

function NpcManagerTunnel:GetMaxArmor()
    return kMatureTunnelEntranceArmor
end 

function NpcManagerTunnel:GetIsWallWalkingAllowed()
    return false
end

function NpcManagerTunnel:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function NpcManagerTunnel:GetCanSleep()
    return true
end

function NpcManagerTunnel:OnKill(attacker, doer, point, direction)

	ScriptActor.OnKill(self, attacker, doer, point, direction)
	self:TriggerEffects("death")
	self.enabled = false

end

function NpcManagerTunnel:GetHealthbarOffset()
    return TunnelEntrance.GetHealthbarOffset(self)
end

function NpcManagerTunnel:OnUpdate(deltaTime)
	if self.active then
		local time = Shared.GetTime()
		if not self.lastWaveSpawn or time - self.lastWaveSpawn >= self.waveTime then
		    self.timeLastExited = Shared.GetTime()
			self:TriggerEffects("tunnel_exit_3D")
		end
	end
	
	NpcManager.OnUpdate(self, deltaTime)
end


function NpcManagerTunnel:GetSendDeathMessageOverride()
    return false
end


if Server then
    // set spawn active when getting attacked
    function NpcManagerTunnel:OnTakeDamage(damage, attacker, doer, point)
        if not self.active and not self.activatedAfterDamage then
            self:OnLogicTrigger(attacker)
            self.activatedAfterDamage = true
        end
    end
end


function NpcManagerTunnel:OnUpdateAnimationInput(modelMixin)

	modelMixin:SetAnimationInput("built", true)
    modelMixin:SetAnimationInput("open", true)
    modelMixin:SetAnimationInput("player_in", self.timeLastExited + 0.2 > Shared.GetTime())
    
end

function NpcManagerTunnel:OnUpdateRender()

    local showDecal = self:GetIsVisible() and not self:GetIsCloaked()

    if not self.decal and showDecal then
        self.decal = CreateSimpleInfestationDecal(1.9, self:GetCoords())
    elseif self.decal and not showDecal then
        Client.DestroyRenderDecal(self.decal)
        self.decal = nil
    end

end

Shared.LinkClassToMap("NpcManagerTunnel", NpcManagerTunnel.kMapName, networkVars)