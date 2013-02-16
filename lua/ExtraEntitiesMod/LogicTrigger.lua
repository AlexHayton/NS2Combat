//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// LogicTrigger.lua
// Entity for mappers to create teleporters

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'LogicTrigger' (Trigger)

LogicTrigger.kMapName = "logic_trigger"

local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)


function LogicTrigger:OnCreate()
 
    Trigger.OnCreate(self)  
    
end

function LogicTrigger:OnInitialized()

    Trigger.OnInitialized(self) 
    if Server then
        InitMixin(self, LogicMixin)
    end

end

function LogicTrigger:GetOutputNames()
    return {self.output1}
end

function LogicTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    if self.enabled then
         self:OnLogicTrigger(enterEnt)
    end
    
end

function LogicTrigger:OnLogicTrigger()
    self:TriggerOutputs()
end


Shared.LinkClassToMap("LogicTrigger", LogicTrigger.kMapName, networkVars)