//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// MapChange.lua
// Base entity for MapChange things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'MapChange' (Entity)

MapChange.kMapName = "map_change"

local networkVars = 
{
    level = "string (128)",
}

AddMixinNetworkVars(LogicMixin, networkVars)

function MapChange:OnCreate()
end

function MapChange:OnInitialized()    
    if Server then
        InitMixin(self, LogicMixin)
    end
end

function MapChange:OnLogicTrigger()    
    if self.level ~= "" then
        local _, _, filename = string.find(self.level, "maps/(.*).level")
        local mapName = string.lower(filename)
        
        // get mods
        local mods = {}
        for s = 1, Server.GetNumActiveMods() do     
            table.insert(mods, Server.GetActiveModId(s))
        end
        
        Server.StartWorld(mods, mapName)
    end
end


Shared.LinkClassToMap("MapChange", MapChange.kMapName, networkVars)