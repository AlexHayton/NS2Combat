//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// MapSettings.lua
// Base entity for MapSettings things


class 'MapSettings' (Entity)

MapSettings.kMapName = "map_settings"

local networkVars =
{
    networkViewDistance  = "private integer (0 to 2048)",  
}


function MapSettings:OnCreate()
end

function MapSettings:OnInitialized()
    // this need to be loaded via client and Server, so we need to save it in a networkVar
    if self.viewDistance then
        self.networkViewDistance = self.viewDistance
    end
    
    if self.networkViewDistance then
        kMaxRelevancyDistance = self.networkViewDistance 
    end
    
    if self.fallDmg then
        //setFalldmg == true
        kFallDamage = true
    end
end


Shared.LinkClassToMap("MapSettings", MapSettings.kMapName, networkVars)