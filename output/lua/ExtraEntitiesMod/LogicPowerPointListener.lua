//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// LogicPowerPointListener.lua
// Base entity for LogicPowerPointListener things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")

class 'LogicPowerPointListener' (ScriptActor)

LogicPowerPointListener.kMapName = "logic_power_point_listener"


local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)

function LogicPowerPointListener:OnCreate()
    ScriptActor.OnCreate(self)
    InitMixin(self, PowerConsumerMixin)
end


function LogicPowerPointListener:OnInitialized()
    ScriptActor.OnInitialized(self)
    if Server then
        InitMixin(self, LogicMixin)
        Print(self:GetLocationName())
        //SetLocationName
    end
    
end


function LogicPowerPointListener:Reset()
end


function LogicPowerPointListener:GetRequiresPower()
    return true
end


function LogicPowerPointListener:OnPowerOn()
    if GetGamerules():GetGameStarted() then
        if self.type == 0 or self.type == 2 then
            self:TriggerOutputs()
        end
    end
end


function LogicPowerPointListener:OnPowerOff()
    if GetGamerules():GetGameStarted() then
        if self.type == 1 or self.type == 2 then
            self:TriggerOutputs()
        end
    end
end


Shared.LinkClassToMap("LogicPowerPointListener", LogicPowerPointListener.kMapName, networkVars)
