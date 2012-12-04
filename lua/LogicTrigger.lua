//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// LogicTrigger.lua
// Entity for mappers to create teleporters

Script.Load("lua/LogicMixin.lua")

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
        if self.output1 then
            self:SetFindEntity()
        else
            Print("Error: No Output-Entity declared")
        end
    end

end

function LogicTrigger:FindEntitys()
    // find the output entity
    local entitys = self:GetEntityList()
    for name, entityId in pairs(entitys) do
        if name == self.output1 then
            self.output1_id = entityId
            break                
        end
    end    
    
end

function LogicTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    if self.enabled then
         self:OnLogicTrigger(enterEnt)
    end
    
end

function LogicTrigger:OnLogicTrigger()
    if self.output1_id then
        local entity = Shared.GetEntity(self.output1_id)
        if entity then
            if  HasMixin(entity, "Logic") then
                entity:OnLogicTrigger()
            else
                Print("Error: Entity " .. entity.name .. " has no Logic function!")
            end
        else
        end
    else
        Print("Error: Entity " .. self.output1 .. " not found!")
        DestroyEntity(self)
    end
end


Shared.LinkClassToMap("LogicTrigger", LogicTrigger.kMapName, networkVars)