//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

LogicMixin = CreateMixin( LogicMixin )
LogicMixin.type = "Logic"

kLogicEntityList = {}
kLogicEntityList.Length = 0

LogicMixin.expectedMixins =
{
}

LogicMixin.expectedCallbacks =
{
    OnLogicTrigger = "Called when the entity is output of a timer etc."
}


LogicMixin.optionalCallbacks =
{
    FindEntitys = "Looks after output entities when map is loaded (called by NS2Gamerules_hook)."
}



LogicMixin.networkVars =  
{
}

function LogicMixin:__initmixin() 
    self.initialEnabled = self.enabled
end

function LogicMixin:Reset() 
    self.enabled = self.initialEnabled
    kLogicEntityList = {}
    kLogicEntityList.Length = 0
end

// faster to save all entitys with a name in a List and just give that List back
function LogicMixin:GetEntityList()

    if kLogicEntityList.Length == 0 then
        for _, entity in ientitylist(Shared.GetEntitiesWithClassname("Entity")) do
            if entity.name then
                kLogicEntityList[entity.name] = entity:GetId()
                kLogicEntityList.Length = kLogicEntityList.Length + 1              
            end            
        end
    end
    
    return kLogicEntityList
    
end

function LogicMixin:SetFindEntity()
    table.insert(kFindEntitiesAfterLoad, self:GetId())
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
