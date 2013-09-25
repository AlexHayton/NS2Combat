//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// LogicEventListener.lua
// Base entity for LogicEventListener things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")


class 'LogicEventListener' (Entity)

LogicEventListener.kMapName = "logic_event_listener"


local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicEventListener:OnCreate()
end


function LogicEventListener:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)
    end
    
end


function LogicEventListener:Reset()
end


function LogicEventListener:OnLogicTrigger(player)
    self:OnTriggerAction()
end


function LogicEventListener:OnEvent(msg, targetEntity)
    if self.enabled then
        if self.listenEvent == 0 then           // game started
            if msg == "Game started" then        
                self:TriggerOutputs()
            end
        // something strange here in the code but ok lets just flip it
        elseif self.listenEvent == 1 then       // team 1 won
            if msg == "Alien win" then 
                self:TriggerOutputs()
            end        
        elseif self.listenEvent == 2 then       // team 2 won            
            if msg == "Marine win" then        
                self:TriggerOutputs()
            end         
        elseif self.listenEvent == 3 then       // any team won
            if msg == "Marine win" or msg == "Alien win" then        
                self:TriggerOutputs()
            end   
        end
    end
end


Shared.LinkClassToMap("LogicEventListener", LogicEventListener.kMapName, networkVars)