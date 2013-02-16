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


function LogicTimer:OnLogicTrigger()
    if self.enabled then
        if self.triggerAction == 1 then 
            self.unlockTime = Shared.GetTime() + self.waitDelay
        elseif self.triggerAction == 0 or self.triggerAction == nil then
            self.enabled = false
            self.unlockTime = nil
        end
    else
        self.enabled = true
        self:CheckTimer()
    end       
end


function LogicTimer:OnTime()
    self:TriggerOutputs()
    // to reset the timer
    self:OnLogicTrigger()
end

Shared.LinkClassToMap("LogicTimer", LogicTimer.kMapName, networkVars)