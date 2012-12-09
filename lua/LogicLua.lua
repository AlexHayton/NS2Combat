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
    kLuaFile = "string (" .. 128 .. ")",
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicLua:OnCreate()
end


function LogicLua:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)
    end
    
    if self.luaFile then
        // predict and client wont get the name from the map, so save it in a networkvariable
        self.kLuaFile = self.luaFile        
    end
    
    if self.kLuaFile then
        Script.Load(self.kLuaFile)
    end
    
end


function LogicLua:Reset()
end


function LogicLua:OnLogicTrigger()


    
end


Shared.LinkClassToMap("LogicLua", LogicLua.kMapName, networkVars)