//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// LogicButton.lua
// Base entity for LogicButton things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/ExtraEntitiesMod/ScaledModelMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")

class 'LogicButton' (ScriptActor)

LogicButton.kMapName = "logic_button"

LogicButton.kModelName = PrecacheAsset("models/props/generic/terminals/generic_controlpanel_02.model")
local kAnimationGraph = PrecacheAsset("models/marine/sentry/sentry.animation_graph")

local networkVars =
{
    scale = "vector",
    model = "string (128)",
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)


function LogicButton:OnCreate()
    ScriptActor.OnCreate(self)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, GameEffectsMixin)
end


function LogicButton:OnInitialized()
    ScriptActor.OnInitialized(self)
    InitMixin(self, ScaledModelMixin)

    if Server then
        InitMixin(self, LogicMixin)
        self:SetUpdates(true)
    end

end

function LogicButton:Reset()
end


function LogicButton:GetCanTakeDamageOverride()
    return false
end


function LogicButton:GetTechId()
    return kTechId.Door    
end


function LogicButton:GetOutputNames()
    return {self.output1}
end

function LogicButton:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = true
end

function LogicButton:OnUse(player, elapsedTime, useAttachPoint, usePoint, useSuccessTable)

    if Server then   
        if self.enabled then
            self:TriggerOutputs()
        end
    elseif Client then
    end
    
end

function LogicButton:OnLogicTrigger()
    if self.enabled then
        self.enabled = false 
    else
        self.enabled = true
    end       
end


Shared.LinkClassToMap("LogicButton", LogicButton.kMapName, networkVars)