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
        self.triggered = false
        self.triggerPlayerList = {}
        self.timeLastTriggered = 0
        self.coolDownTime = self.coolDownTime or 0
    end

end

function LogicTrigger:Reset()
    self.triggered = false
    self.triggerPlayerList = {}
    self.timeLastTriggered = 0
end

if Server then

    
    function LogicTrigger:CheckTrigger(enterEnt)
    
        local timeOk = ((Shared.GetTime() + self.coolDownTime) >= self.timeLastTriggered) 
       
        if self.disallowNpcs then
            timeOk = not enterEnt.isaNpc
        end     
   
        if self.enabled and timeOk then
        
            local teamNumber = enterEnt:GetTeamNumber()
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
                    local playerId = enterEnt:GetId()
                    if not table.contains(self.triggerPlayerList, playerId) then
                        typeOk = true
                        table.insert(self.triggerPlayerList, playerId)                
                    end
                elseif self.teamType == 2 then              // trigger only once 
                    typeOk = not self.triggered
                    self.triggered = true
                elseif self.teamType == 3 then              // trigger only once per SteamId
                    // just ignore npcs here
                    if enterEnt.isaNpc then
                        typeOk = true
                    else
                        local steamid = Server.GetOwner(enterEnt):GetUserId()
                        if not table.contains(self.triggerPlayerList, steamid) then
                            typeOk = true
                            table.insert(self.triggerPlayerList, steamid)                
                        end
                    end
                end
                
                if typeOk then
                    self:TriggerOutputs(enterEnt)
                    self.timeLastTriggered = Shared.GetTime()
                end
                
            end
            
        end
    end

    function LogicTrigger:OnTriggerEntered(enterEnt, triggerEnt) 
        if enterEnt:isa("Player") and (self.triggerStyle == 0 or self.triggerStyle == nil) then
            self:CheckTrigger(enterEnt)
        end
    end
        
    function LogicTrigger:OnTriggerExited(exitEnt, triggerEnt)
        if exitEnt:isa("Player") and self.triggerStyle == 1 then
            self:CheckTrigger(exitEnt)
        end
    end

    function LogicTrigger:OnLogicTrigger(player)
		self:OnTriggerAction() 
    end

end


Shared.LinkClassToMap("LogicTrigger", LogicTrigger.kMapName, networkVars)