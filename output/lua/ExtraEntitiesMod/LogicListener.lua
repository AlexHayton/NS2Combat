//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// LogicListener.lua
// Entity for mappers to create teleporters

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/Mixins/SignalListenerMixin.lua")

class 'LogicListener' (Entity)

LogicListener.kMapName = "logic_listener"

local networkVars =
{
}

function LogicListener:OnCreate()   
    Entity.OnCreate(self)     
    InitMixin(self, SignalListenerMixin)
end

function LogicListener:OnInitialized()
    self:SetListenChannel(self.listenChannel)
    self:RegisterSignalListener(function() self:TriggerOutputs() end, self.listenMessage)
	
	if Server then
        InitMixin(self, LogicMixin)
    end
end


Shared.LinkClassToMap("LogicListener", LogicListener.kMapName, networkVars)