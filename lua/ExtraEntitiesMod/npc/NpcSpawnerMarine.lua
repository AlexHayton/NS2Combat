//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// base class for spawning npcs
Script.Load("lua/ExtraEntitiesMod/npc/NpcSpawner.lua")

class 'NpcSpawnerMarine' (NpcSpawner)

NpcSpawnerMarine.kMapName = "npc_spawner_marine"
  
local networkVars =
{
}

if Server then

    function NpcSpawnerMarine:OnCreate()
        NpcSpawner.OnCreate(self)
    end

    function NpcSpawnerMarine:OnInitialized()
        NpcSpawner.OnInitialized(self)
    end
    
    function NpcSpawnerMarine:GetTechId()
        return kTechId.Marine
    end    

    function NpcSpawnerMarine:Spawn()
        local values = self:GetValues()                    

        local entity = Server.CreateEntity(Marine.kMapName, values)
        InitMixin(entity, NpcMixin)
        
        // destroy all weapons and give them our weapons
        entity:DestroyWeapons()        
        
        local items = {}             
        
        // always include builder
        table.insert(items, Builder.kMapName)
      
        if self.weapons == 0 then
            table.insert(items, Pistol.kMapName)
            table.insert(items, Axe.kMapName)  
            table.insert(items, Rifle.kMapName)     
        elseif self.weapons == 1 then
            table.insert(items, Axe.kMapName)  
            table.insert(items, Pistol.kMapName)                 
        elseif self.weapons == 2 then
            table.insert(items, Axe.kMapName)
        elseif self.weapons == 3 then
            table.insert(items, GrenadeLauncher.kMapName)
        elseif self.weapons == 4 then
            table.insert(items, Flamethrower.kMapName)
        end   
        
        for i, item in ipairs(items) do
            entity:GiveItem(item)
        end

        self:SetWayPoint(entity)        

    end
    
end

Shared.LinkClassToMap("NpcSpawnerMarine", NpcSpawnerMarine.kMapName, networkVars)

