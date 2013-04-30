//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// base class for spawning npcs
Script.Load("lua/ExtraEntitiesMod/npc/NpcSpawner.lua")

class 'NpcSpawnerMarineExo' (NpcSpawner)

NpcSpawnerMarineExo.kMapName = "npc_spawner_marine_exo"
  
local networkVars =
{
}

if Server then

    function NpcSpawnerMarineExo:OnCreate()
        NpcSpawner.OnCreate(self)
    end

    function NpcSpawnerMarineExo:OnInitialized()
        NpcSpawner.OnInitialized(self)
    end
    
    function NpcSpawnerMarineExo:GetTechId()
        return kTechId.Marine
    end    

    function NpcSpawnerMarineExo:Spawn()
        local values = self:GetValues()  
        
         // handle weapons before spawn
        if self.weapons == 0 then
            self.layout = "ClawMinigun"
        elseif self.weapons == 1 then
            self.layout = "MinigunMinigun"             
        elseif self.weapons == 2 then
            self.layout = "ClawRailgun"
        elseif self.weapons == 3 then
            self.layout = "RailgunRailgun"
        end
        
        values.layout = self.layout
        
        local entity = Server.CreateEntity(Exo.kMapName, values)
        InitMixin(entity, NpcMixin)
        
        self:SetWayPoint(entity)
        
       
    end
    
end

Shared.LinkClassToMap("NpcSpawnerMarineExo", NpcSpawnerMarineExo.kMapName, networkVars)

