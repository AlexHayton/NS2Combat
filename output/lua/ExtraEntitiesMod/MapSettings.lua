//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
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
    
    if Server then
        if self.maxNpcs then
            kMaxNpcs = self.maxNpcs
        end
        
        if self.maxNpcsSameTime then
            kMaxNpcsSameTime = self.maxNpcsSameTime
        end
        
        if self.delaySpawnTime then
            kDelaySpawnTime = self.delaySpawnTime 
        end  
    end
    
end


Shared.LinkClassToMap("MapSettings", MapSettings.kMapName, networkVars)