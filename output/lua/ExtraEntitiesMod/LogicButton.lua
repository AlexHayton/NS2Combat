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
	self:SetScaledModel(self.model)

    if Server then
        InitMixin(self, LogicMixin)
        self.triggered = false
        self.triggerPlayerList = {}
        self.timeLastTriggered = 0
        self.coolDownTime = self.coolDownTime or 0
        self:SetUpdates(true)
    end

end

function LogicButton:Reset()
    self.triggered = false
    self.triggerPlayerList = {}
    self.timeLastTriggered = 0
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
        local timeOk = ((Shared.GetTime() + self.coolDownTime) >= self.timeLastTriggered)
        
        if self.enabled and timeOk then
        
            local teamNumber = player:GetTeamNumber()
            local teamOk = false
            if self.teamNumber == 0 or self.teamNumber == nil then
                teamOk = true
            elseif self.teamNumber == 1 then
                if teamNumber == 1 then
                    teamOk = true
                end
            elseif self.teamNumber == 2 then
            if teamNumber == 2 then
                    teamOk = true
                end
            end
            
            if teamOk then        
                local typeOk = false                
                if self.teamType == 0 or self.teamType == nil then           // triggers all the time
                    typeOk = true                
                elseif self.teamType == 1 then              // trigger once per player
                    local playerId = player:GetId()
                    if not table.contains(self.triggerPlayerList, playerId) then
                        typeOk = true
                        table.insert(self.triggerPlayerList, playerId)                
                    end
                elseif self.teamType == 2 then              // trigger only once 
                    typeOk = not self.triggered
                    self.triggered = true
                end
                
                if typeOk then
                    self:TriggerOutputs(player)
                    self.timeLastTriggered = Shared.GetTime()
                end
            end
        end
        
    elseif Client then
    end
    
end

function LogicButton:OnLogicTrigger(player)
	self:OnTriggerAction()   
end


Shared.LinkClassToMap("LogicButton", LogicButton.kMapName, networkVars)