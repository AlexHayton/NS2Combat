//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// base class for spawning npcs
Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcMixin.lua")

class 'NpcSpawner' (Entity)

NpcSpawner.kMapName = "npc_spawner"
  
local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

if Server then

    function NpcSpawner:OnCreate()
        Entity.OnCreate(self)
    end

    function NpcSpawner:OnInitialized()
        InitMixin(self, LogicMixin) 
        if self.spawnDirectly then
            self:Spawn()
        end        
    end    
        
    function NpcSpawner:GetTechId()
        return kTechId.Marine
    end    

    function NpcSpawner:Reset() 
    end

    function NpcSpawner:OnLogicTrigger(player) 
        // spawn npc
        self:Spawn()
    end
    
    function NpcSpawner:GetClearSpawn()
    
        local extents = LookupTechData(self:GetTechId(), kTechDataMaxExtents) or Vector(1,1,1)
        local position = GetRandomSpawnForCapsule(extents.y, extents.x , self:GetOrigin(), 0, 0.1, EntityFilterOne(self))
        if not position then 
            // search clear spawn pos
            for index = 1, 50 do
                position = GetRandomSpawnForCapsule(extents.y, extents.x , self:GetOrigin(), 0, 2, EntityFilterOne(self))
                if position then
                    break                
                end
            end
            
        end
            
        return position
        
    end

    function NpcSpawner:GetValues()
        local spawnOrigin = self:GetClearSpawn()
        local values = { 
                        origin = spawnOrigin,
                        angles = self:GetAngles(),
                        name1 = self.name,
                        team = self.team,
                        startsActive = self.startsActive,
                        isaNpc = true,
                        }
        return values
    end

    function NpcSpawner:Spawn()
    end
    
    function NpcSpawner:SetWayPoint(entity)
        local waypoint = nil
        if self.waypoint then
            waypoint = self:GetLogicEntityWithName(self.waypoint)
        end
        
        if waypoint then
            entity:GiveOrder(kTechId.Move , waypoint:GetId(), waypoint:GetOrigin(), nil, true, true)
            entity.mapWaypoint = waypoint:GetId()
        end        
    end
    
end

Shared.LinkClassToMap("NpcSpawner", NpcSpawner.kMapName, networkVars)
