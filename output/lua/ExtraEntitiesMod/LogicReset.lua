//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// LogicReset.lua
// Base entity for LogicReset things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'LogicReset' (Entity)

LogicReset.kMapName = "logic_reset"


local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicReset:OnCreate()
end

function LogicReset:OnInitialized()   
    
    if Server then
        InitMixin(self, LogicMixin)  
    end
    self:SetUpdates(false)    
    
end

function LogicReset:Reset() 
end

function LogicReset:GetOutputNames(number)
    local outputNames = {}
    local possibleOutputs = {}
    table.insert(possibleOutputs, self.output1)
    table.insert(possibleOutputs, self.output2)
    table.insert(possibleOutputs, self.output3)
    table.insert(possibleOutputs, self.output4)
    table.insert(possibleOutputs, self.output5)
    table.insert(possibleOutputs, self.output6)
    table.insert(possibleOutputs, self.output7)
    table.insert(possibleOutputs, self.output8)
    table.insert(possibleOutputs, self.output9)
    table.insert(possibleOutputs, self.output10)
    
    for i, name in ipairs(possibleOutputs) do
        if name ~= "" then
            table.insert(outputNames, name)
        end
    end
    
    return outputNames
end


function LogicReset:OnLogicTrigger(player)
    self:TriggerOutputs(player, nil, "reset") 
end

Shared.LinkClassToMap("LogicReset", LogicReset.kMapName, networkVars)