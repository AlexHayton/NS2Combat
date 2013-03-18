//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// base class for spawning npcs

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcMixin.lua")

class 'NpcManager' (Entity)

NpcManager.kMapName = "npc_wave_manager"
  
local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

if Server then

    function NpcManager:OnCreate()
        Entity.OnCreate(self)
    end

    function NpcManager:OnInitialized()
        InitMixin(self, LogicMixin) 
        self.npcNumber = self.npcNumber or 5
        self.waveTime = self.waveTime or 20
        self.maxWaveNumber = self.maxWaveNumber or 5
        self.active = false
        self.currentWave = 1
        self:SetUpdates(true)
    end    
        
    function NpcManager:GetTechId()
        return kTechId.Marine
    end    

    function NpcManager:Reset() 
        self.active = false
        self.lastWaveSpawn = nil
        self.currentWave = 1
    end

    function NpcManager:OnLogicTrigger(player) 
        self.active = true
    end
    
    function NpcManager:OnUpdate(deltaTime) 
        if self.active then
            local time = Shared.GetTime()
            if not self.lastWaveSpawn or time - self.lastWaveSpawn >= self.waveTime then
                // spawn npcs
                local waypoint = nil
                if self.waypoint then
                    waypoint = self:GetLogicEntityWithName(self.waypoint)
                end
                for i = 1, self.npcNumber do
                    self:Spawn(waypoint)
                end
                self.lastWaveSpawn = time
                self.currentWave = self.currentWave + 1
                
                if self.currentWave >= self.maxWaveNumber then
                    // max wave reached
                    self:Reset()
                end
                
            end
        end 
    end
    
    function NpcManager:GetClearSpawn()
    
        local extents = LookupTechData(self:GetTechId(), kTechDataMaxExtents) or Vector(1,1,1)

        // search clear spawn pos
        for index = 1, 50 do
            position = GetRandomSpawnForCapsule(extents.y, extents.x , self:GetOrigin(), 0, 4, EntityFilterOne(self))
            if position then
                break                
            end
        end
            
        return position
        
    end

    function NpcManager:GetValues()
        local spawnOrigin = self:GetClearSpawn()
        // values every npc needs for the npc mixin
        local values = { 
                        origin = spawnOrigin,
                        angles = self:GetAngles(),
                        team = self.team,
                        startsActive = true,
                        isaNpc = true,
                        }
        return values
    end

    function NpcManager:Spawn(waypoint)
        local values = self:GetValues() 
        local entity = Server.CreateEntity(Skulk.kMapName, values)
        // init the xp mixin for the new npc
        InitMixin(entity, NpcMixin)
        if waypoint then
            entity:GiveOrder(kTechId.Move , waypoint:GetId(), waypoint:GetOrigin(), nil, true, true)
            entity.mapWaypoint = waypoint:GetId()
        end
    end
    
end

Shared.LinkClassToMap("NpcManager", NpcManager.kMapName, networkVars)
