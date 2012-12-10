//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// LogicLua.lua
// Base entity for LogicLua things

Script.Load("lua/LogicMixin.lua")


class 'LogicLua' (Entity)

LogicLua.kMapName = "logic_lua"


local networkVars =
{
    luaFile = "string (128)",
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicLua:OnCreate()
end


function LogicLua:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)
    end
    
    if self.luaFile then
        Script.Load(self.kLuaFile)
    end
    
end


function LogicLua:Reset()
end


function LogicLua:OnLogicTrigger()    
end


Shared.LinkClassToMap("LogicLua", LogicLua.kMapName, networkVars)