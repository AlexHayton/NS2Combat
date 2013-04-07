//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// LogicTimer.lua
// Base entity for LogicTimer things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")


class 'LogicTimer' (Entity)

LogicTimer.kMapName = "logic_timer"

local kDefaultWaitDelay = 10

local networkVars =
{
    //output1_id  = "entityid",    
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicTimer:OnCreate()
end


function LogicTimer:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)
        
        if not self.waitDelay then
            self.waitDelay = kDefaultWaitDelay 
        end 
        self:SetUpdates(true)    
    end
    
end

function LogicTimer:Reset() 
    self.unlockTime = nil
end


function LogicTimer:OnUpdate(deltaTime)
   
    if not Client then
        if self.enabled then
            if GetGamerules():GetGameStarted() then
                self:CheckTimer() 
            end 
        end
    end
           
end


function LogicTimer:CheckTimer()

    if self.enabled then
        if not self.unlockTime then
            self.unlockTime = Shared.GetTime() + self.waitDelay
        end
        if Shared.GetTime() >= self.unlockTime then
            self:OnTime()
        end 
    end

end


function LogicTimer:GetOutputNames()
    return {self.output1}
end


function LogicTimer:OnLogicTrigger(player)
    self:OnTriggerAction()     
end


function LogicTimer:OnTime()
    self:TriggerOutputs()
    // to reset the timer
    if self.onTimeAction == 0 or self.onTimeAction == nil then
        self.enabled = false
        self.unlockTime = nil
    elseif self.onTimeAction == 1 then
        self:Reset()
    elseif self.onTimeAction == 2 then 
        self.unlockTime = Shared.GetTime() + self.waitDelay
    end
end

Shared.LinkClassToMap("LogicTimer", LogicTimer.kMapName, networkVars)