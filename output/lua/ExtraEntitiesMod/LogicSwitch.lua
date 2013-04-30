//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// LogicSwitch.lua
// Base entity for LogicSwitch things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'LogicSwitch' (Entity)

LogicSwitch.kMapName = "logic_switch"


local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicSwitch:OnCreate()
end

function LogicSwitch:OnInitialized()   
    
    if Server then
        InitMixin(self, LogicMixin)  
        self.currentOutput = 1 
        if self.startOutput == 1 then
            self.currentOutput = math.random(self.outputSize)
        end
    end
    self:SetUpdates(false)    
    
end

function LogicSwitch:Reset() 
    self.currentOutput = 1 
    if self.startOutput == 1 then
        self.currentOutput = math.random(self.outputSize)
    end
end

function LogicSwitch:GetOutputNames(number)
    local returnNames = {}
    if not self.outputNames then   
        self.outputNames = {}     
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
                table.insert(self.outputNames, name)
            end
        end
        
        self.outputSize = #self.outputNames
    end
    
    if number then
        returnNames = self.outputNames[number]
    else
        returnNames = self.outputNames
    end
    
    return {returnNames}
end


function LogicSwitch:OnLogicTrigger(player)
    self:TriggerOutputs(player, self.currentOutput)  

    if self.switchType == 0 then
        self.currentOutput = self.currentOutput + 1 
        self.currentOutput = ConditionalValue(self.currentOutput > self.outputSize, 1, self.currentOutput)
    elseif self.switchType == 1 then
        self.currentOutput = self.currentOutput - 1
        self.currentOutput = ConditionalValue(self.currentOutput < 1, self.outputSize, self.currentOutput)    
    elseif self.switchType == 2 then
        self.currentOutput = math.random(self.outputSize)
    end
  
end

Shared.LinkClassToMap("LogicSwitch", LogicSwitch.kMapName, networkVars)