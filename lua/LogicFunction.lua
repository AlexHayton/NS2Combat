//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// LogicFunction.lua
// Base entity for LogicFunction things

Script.Load("lua/LogicMixin.lua")


class 'LogicFunction' (Entity)

LogicFunction.kMapName = "logic_function"


local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicFunction:OnCreate()
end


function LogicFunction:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)
    end
    
end


function LogicFunction:Reset()
end


function LogicFunction:OnLogicTrigger()

    if self.callFunction == 0 then
        Print("Test")
    elseif self.callFunction == 1 then
        local gamerules = GetGamerules()
        gamerules:EndGame(gamerules.team1 )
    elseif self.callFunction == 2 then
        local gamerules = GetGamerules()
        gamerules:EndGame(gamerules.team2 )
    end
    
end


Shared.LinkClassToMap("LogicFunction", LogicFunction.kMapName, networkVars)