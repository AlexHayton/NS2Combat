//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// LogicWeldable.lua
// Base entity for LogicWeldable things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")

class 'LogicWeldable' (ScriptActor)

LogicWeldable.kMapName = "logic_weldable"

LogicWeldable.kModelName = PrecacheAsset("models/props/generic/terminals/generic_controlpanel_01.model")

local networkVars =
{
    weldedPercentage = "float",
    scale = "vector",
    model = "string (128)",
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)


function LogicWeldable:OnCreate()
    ScriptActor.OnCreate(self)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, GameEffectsMixin)
end


function LogicWeldable:OnInitialized()
    ScriptActor.OnInitialized(self)
    InitMixin(self, WeldableMixin)
    InitMixin(self, ScaledModelMixin)
	self:SetScaledModel(self.model)

    if Server then
        InitMixin(self, LogicMixin)
        self:SetUpdates(true)
        self.weldPercentagePerSecond  = 1 / self.weldTime

        // weldables always belong to the Marine team.
        self:SetTeamNumber(kTeam1Index)  
    end
    self:SetArmor(0)
    self.weldedPercentage = 0
end

function LogicWeldable:Reset()
    self:SetArmor(0)
    self.weldedPercentage = 0
end


function LogicWeldable:GetCanTakeDamageOverride()
    return false
end


function LogicWeldable:OnWeldOverride(doer, elapsedTime)

    if Server then
        self.weldedPercentage = self.weldedPercentage + self.weldPercentagePerSecond  * elapsedTime

         if self.weldedPercentage >= 1.0 then
            self.weldedPercentage = 1.0
            self:OnWelded()
         end
    end
    
end

function LogicWeldable:GetWeldPercentageOverride()    
    return self.weldedPercentage    
end


function LogicWeldable:GetTechId()
    return kTechId.Door    
end


function LogicWeldable:GetOutputNames()
    return {self.output1}
end

function LogicWeldable:OnWelded()
    self:SetArmor(self:GetMaxArmor())
    self:TriggerOutputs()
end

function LogicWeldable:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false  
end


function LogicWeldable:OnLogicTrigger(player)
	self:OnTriggerAction()     
end


Shared.LinkClassToMap("LogicWeldable", LogicWeldable.kMapName, networkVars)