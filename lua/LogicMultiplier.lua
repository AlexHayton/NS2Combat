//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// LogicMultiplier.lua
// Base entity for LogicMultiplier things

Script.Load("lua/LogicMixin.lua")


class 'LogicMultiplier' (Entity)

LogicMultiplier.kMapName = "logic_multiplier"


local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicMultiplier:OnCreate()
end

function LogicMultiplier:OnInitialized()
    
    self.possibleOutputs = {}
    table.insert(self.possibleOutputs, self.output1)
    table.insert(self.possibleOutputs, self.output2)
    table.insert(self.possibleOutputs, self.output3)
    table.insert(self.possibleOutputs, self.output4)
    table.insert(self.possibleOutputs, self.output5)
    table.insert(self.possibleOutputs, self.output6)
    table.insert(self.possibleOutputs, self.output7)
    table.insert(self.possibleOutputs, self.output8)
    table.insert(self.possibleOutputs, self.output9)
    table.insert(self.possibleOutputs, self.output10)
    
    if Server then
        InitMixin(self, LogicMixin)
        self.output_ids = {}
        self.outputList = self:GetUsedOutputs()
        if self.outputList then
            self:SetFindEntity()
        else
            Print("Error: No Output-Entity declared")
        end        
    end
    self:SetUpdates(false)    
    
end


function LogicMultiplier:FindEntitys(wrongIds)
    // find the output entity
    local rightIds = {}
    // this is needed cause we can't use # with generic tables
    local tableLength = 0
    // find the output entity
    local entitys = self:GetEntityList()
    
    for name, entityId in pairs(entitys) do    
  
        for i, outputName in ipairs (wrongIds or self.outputList) do
            if name == outputName then
                self.output_ids[outputName] = entityId
                rightIds[outputName] = entityId
                
                table.remove(wrongIds or self.outputList, i)
                tableLength = tableLength + 1
                break                
            end
        end     
        
        if #self.outputList == 0 then
            if wrongIds then
                if #wrongIds == 0 then
                    break 
                end
            else 
                break
            end            
        end
        
    end
    
    if wrongIds then
        if #wrongIds > 0 then
            for name, entityId in pairs(wrongIds) do
                Print("Error: Couldn't find Id for " .. name .. " !")
            end
        end
    end
    
    if tableLength > 0 then
        return rightIds
    end
    
end

// todo research door trigger
function LogicMultiplier:OnLogicTrigger(missingTable)
    local wrongIds = {}
    
    for name, entityId in pairs(missingTable or self.output_ids) do
        local entity = Shared.GetEntity(entityId)       
        if entity then
            entity:OnLogicTrigger()
        else
            table.insert(wrongIds, name)
            self.output_ids[name] = nil
        end
    end  
    
    if #wrongIds > 0 then 
        if not missingTable then
            // something is wrong     
            local newIds = self:FindEntitys(wrongIds)
            if newIds then
                self:OnLogicTrigger(newIds)
            end
        else
            // we allready tried to research the entities, abbort
            for name, entityId in pairs(missingTable) do
                Print("Error: Couldn't find entity " .. name .. " to trigger it!")
            end
        end 
    end
    
end

Shared.LinkClassToMap("LogicMultiplier", LogicMultiplier.kMapName, networkVars)