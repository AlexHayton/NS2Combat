//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// LogicTimer.lua
// Base entity for LogicTimer things

Script.Load("lua/LogicMixin.lua")


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
        if self.output1 then
            self:SetFindEntity()
        else
            Print("Error: No Output-Entity declared")
        end
        self:SetUpdates(true)    
    end
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


function LogicTimer:FindEntitys()
    // find the output entity
    local entitys = self:GetEntityList()
    for name, entityId in pairs(entitys) do
        if name == self.output1 then
            self.output1_id = entityId
            break                
        end
    end    
    
end


function LogicTimer:OnLogicTrigger()
    if self.enabled then
        self.enabled = false
        self.unlockTime = nil
    else
        self.enabled = true
        self:CheckTimer()
    end       
end


function LogicTimer:OnTime()
    if self.output1_id then
        local entity = Shared.GetEntity(self.output1_id)
        if entity then
            if  HasMixin(entity, "Logic") then
                entity:OnLogicTrigger()
                // to disable this timer
                self:OnLogicTrigger()
            else
                Print("Error: Entity " .. entity.name .. " has no Logic function!")
            end
        else
            // something is wrong, search again
            self:FindEntitys()
            self:OnLogicTrigger()
        end
    else
        Print("Error: Entity " .. self.output1 .. " not found!")
        DestroyEntity(self)
    end
end

Shared.LinkClassToMap("LogicTimer", LogicTimer.kMapName, networkVars)