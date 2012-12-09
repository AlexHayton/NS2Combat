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
    viewDistance  = "integer (0 to 2048)",  
    fallDmg = "boolean",
}


function MapSettings:OnCreate()
end

function MapSettings:OnInitialized()
    
    if self.viewDistance then
        kMaxRelevancyDistance = self.viewDistance 
    end
    
    if self.fallDmg then
        //setFalldmg == true
        kFallDamage = true
    end
end


Shared.LinkClassToMap("MapSettings", MapSettings.kMapName, networkVars)