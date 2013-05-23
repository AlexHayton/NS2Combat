//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

LogicMixin = CreateMixin( LogicMixin )
LogicMixin.type = "Logic"

// table with all logic entities in it
kLogicEntityList = {}
kLogicEntitiesSearched = false

LogicMixin.expectedMixins =
{
}


LogicMixin.optionalCallbacks =
{
    OnLogicTrigger = "Called when the entity is output of a timer etc."
}


LogicMixin.networkVars =  
{
}

local function searchEntities(self)
    // clear the entity list and rewrite it
    kLogicEntityList = {}
    for index, entity in ipairs(GetEntitiesWithMixin("Logic")) do
        if entity.name and entity.name ~= "" then   
            kLogicEntityList[entity.name] = entity:GetId()
        end
    end
    kLogicEntitiesSearched = true
end


function LogicMixin:__initmixin() 
    self.initialEnabled = self.enabled
    /*
    table.insert(kLogicEntityList, {
                                    name = self.name,
                                    id = self:GetId(),
                                    } )
    */  
    if self.name and self.name ~= "" then                              
        kLogicEntityList[self.name] = self:GetId()
    end
end


function LogicMixin:Reset() 
    self.enabled = self.initialEnabled
    kLogicEntitiesSearched = false
end


function LogicMixin:OnEntityChange(oldId, newId)
    // change the id in the list
    if not kLogicEntityList then
        kLogicEntityList = {}
    end
    
    for name, id in pairs(kLogicEntityList) do
        if old == id then
            kLogicEntityList[name] = newId
            break
        end
    end   

end


function LogicMixin:GetLogicEntityWithName(name) 

    local entity = nil
    if kLogicEntityList[name] then
        entity = Shared.GetEntity(kLogicEntityList[name])
    end  
 
    return entity
end


// normal output, but entities can override it
function LogicMixin:GetOutputNames()
    return {self.output1}
end


function LogicMixin:TriggerOutputs(player, number, func, retryList)   
 
    local retryTriggerEntities = {}
    for i, name in ipairs(retryList or self:GetOutputNames(number)) do 
        if name ~= "" then
            local entity = self:GetLogicEntityWithName(name)
            if entity then
                if  HasMixin(entity, "Logic") then
                    if func then
                        // custom output functions
                        if func == "reset" then
                            entity:Reset()
                        end
                    else
                        entity:OnLogicTrigger(player)
                    end
                else
                    Print("Error: Entity " .. name .. " has no Logic function!")
                end
            else
                if kLogicEntitiesSearched then
                    Print("Error: Can't find output " .. name .. " for entity " .. self.name)
                    Print("Deleting " .. self.name .. " !")
                    DestroyEntity(self)
                else
                   table.insert(retryTriggerEntities, name)
                end
            end
        end
    end

    if #retryTriggerEntities > 0 then
        // Try to search the entities again (doors sometimes change their id)
        searchEntities(self) 
        self:TriggerOutputs(nil, nil, nil, retryTriggerEntities)
    end
end

// needed when we have more than 1 output
function LogicMixin:GetUsedOutputs()
    local outputs = {}
    for i, output in ipairs(self.possibleOutputs) do
        if output ~= "" then
            table.insert(outputs, output)
        end
    end
    
    return outputs
end


// entities can override this
function LogicMixin:OnLogicTrigger(player) 
end


// some entities have special functions, but others just switches on, off etc
function LogicMixin:OnTriggerAction()
    if self.onTriggerAction == 0 or self.onTriggerAction == nil then
        // toggle
        self.enabled = not self.enabled
    elseif self.onTriggerAction == 1 then
        // stay on
        self.enabled = true
    elseif self.onTriggerAction == 2 then
        // stay off
        self.enabled = off
    end  
end
