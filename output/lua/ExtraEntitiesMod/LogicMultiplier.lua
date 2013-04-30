//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// LogicMultiplier.lua
// Base entity for LogicMultiplier things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'LogicMultiplier' (Entity)

LogicMultiplier.kMapName = "logic_multiplier"


local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicMultiplier:OnCreate()
end

function LogicMultiplier:OnInitialized()   
    
    if Server then
        InitMixin(self, LogicMixin)     
    end
    self:SetUpdates(false)    
    
end


function LogicMultiplier:GetOutputNames()
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


function LogicMultiplier:OnLogicTrigger(player)
    self:TriggerOutputs(player)    
end

Shared.LinkClassToMap("LogicMultiplier", LogicMultiplier.kMapName, networkVars)