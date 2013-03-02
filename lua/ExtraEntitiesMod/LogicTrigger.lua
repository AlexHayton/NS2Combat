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
        local teamNumber = enterEnt:GetTeamNumber()
        local teamOk = false
        if self.teamNumber == 0 then
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
            self:TriggerOutputs(enterEnt)
        end
    end
    
end

function LogicTrigger:OnLogicTrigger(player)
    if self.enabled then
        self.enabled = false 
    else
        self.enabled = true
    end    
end


Shared.LinkClassToMap("LogicTrigger", LogicTrigger.kMapName, networkVars)