//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// LogicCounter.lua
// Base entity for LogicCounter things

Script.Load("lua/LogicMixin.lua")


class 'LogicCounter' (Entity)

LogicCounter.kMapName = "logic_counter"


local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicCounter:OnCreate()
end


function LogicCounter:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)
        self.countAmount = 0
        
        if self.output1 then
            self:SetFindEntity()
        else
            Print("Error: No Output-Entity declared")
        end
    end
end


function LogicCounter:Reset()
    self.countAmount = 0
end


function LogicCounter:FindEntitys()
    // find the output entity
    local entitys = self:GetEntityList()
    for name, entityId in pairs(entitys) do
        if name == self.output1 then
            self.output1_id = entityId
            break                
        end
    end    
    
end


function LogicCounter:OnLogicTrigger()

    self.countAmount = self.countAmount + 1
    if self.countAmount == self.counter then
        local entity = Shared.GetEntity(self.output1_id)
        if entity then
            if  HasMixin(entity, "Logic") then
                entity:OnLogicTrigger()
                self.countAmount = 0
            else
                Print("Error: Entity " .. entity.name .. " has no Logic function!")
            end
        else
        end   
    end
    
end


Shared.LinkClassToMap("LogicCounter", LogicCounter.kMapName, networkVars)