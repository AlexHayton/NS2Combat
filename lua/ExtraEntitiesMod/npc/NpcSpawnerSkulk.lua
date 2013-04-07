//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// base class for spawning npcs
Script.Load("lua/ExtraEntitiesMod/npc/NpcSpawner.lua")

class 'NpcSpawnerSkulk' (NpcSpawner)

NpcSpawnerSkulk.kMapName = "npc_spawner_skulk"
  
local networkVars =
{
}

if Server then

    function NpcSpawnerSkulk:OnCreate()
        NpcSpawner.OnCreate(self)
    end

    function NpcSpawnerSkulk:OnInitialized()
        NpcSpawner.OnInitialized(self)
    end
    
    function NpcSpawnerSkulk:GetTechId()
        return kTechId.Marine
    end    

    function NpcSpawnerSkulk:Spawn()
        local values = self:GetValues() 
        local entity = Server.CreateEntity(Skulk.kMapName, values)
        // init the xp mixin for the new npc
        InitMixin(entity, NpcMixin)	
        self:SetWayPoint(entity)
    end
    
end

Shared.LinkClassToMap("NpcSpawnerSkulk", NpcSpawnerSkulk.kMapName, networkVars)

