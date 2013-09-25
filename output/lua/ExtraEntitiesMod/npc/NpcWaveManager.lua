//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// base class for spawning npcs

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/ExtraEntitiesMod/npc/NpcMixin.lua")

class 'NpcManager' (ScriptActor)

NpcManager.kMapName = "npc_wave_manager"
  
local networkVars =
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

if Server then

    function NpcManager:OnCreate()
        ScriptActor.OnCreate(self)
    end

    function NpcManager:OnInitialized()
	    self.enabled = true
        InitMixin(self, LogicMixin) 
        self.npcNumber = self.npcNumber or 5
        self.waveTime = self.waveTime or 20
        self.maxWaveNumber = self.maxWaveNumber or 5
        self.active = false
        self.currentWave = 0
        self:SetUpdates(true)
    end    
        
    function NpcManager:GetTechId()
        return kTechId.Skulk
    end    

    function NpcManager:ResetWaves() 
		self.enabled = true
        self.active = false
        self.lastWaveSpawn = nil
        self.currentWave = 0
    end
    
    function NpcManager:Reset()
        self:ResetWaves()
    end
    
    function NpcManager:OnLogicTrigger(player)
        if not self.active and self.enabled then
            self.active = true
        else
            if self.onTriggerAction and self.onTriggerAction == 0 then
                self.active = false
            end
        end
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
                    NpcUtility_Spawn(self:GetOrigin(), self:GetSpawnClass(), self:GetValues(), waypoint)
                end
                self.lastWaveSpawn = time
                self.currentWave = self.currentWave + 1
                
                if self.currentWave >= self.maxWaveNumber then
                    if self.maxWaveNumber ~= 99 then
                        // max wave reached
                        self:TriggerOutputs()
                        self:ResetWaves()
                    else
                        // infinite wave until triggered
                        self.currentWave = 0
                    end
                end
                
            end
        end 
    end
   
    function NpcManager:GetSpawnClass()
        if not self.spawnClass then
        
            local class = Skulk.kMapName
            if self.class then
                if self.class == 1 then
                    class = Gorge.kMapName
                elseif self.class == 2 then
                    class = Lerk.kMapName 
                elseif self.class == 3 then
                    class = Fade.kMapName
                elseif self.class == 4 then
                    class = Onos.kMapName
                elseif self.class == 5 then
                    class = Marine.kMapName
                elseif self.class == 6 then
                    class = Exo.kMapName
                elseif self.class == 7 then
                    class = Exo.kMapName
                end
            end
                
            self.spawnClass = class
            return class
            
        else
            return self.spawnClass
        end

    end
        

    function NpcManager:GetValues()
        // values every npc needs for the npc mixin
        
        local layout = ""
        if self.class == 6 then
            layout = "ClawMinigun"
        elseif self.class == 7 then
            layout = "MinigMinigun"
        end
        
        local values = { 
                        angles = self:GetAngles(),
                        team = self.team,
                        startsActive = true,
                        isaNpc = true,
                        timedLife = self.timedLife,
                        baseDifficulty = self.baseDifficulty,
                        layout = layout,
                        disabledTargets = self.disabledTargets
                        }
        return values
    end
    
end

Shared.LinkClassToMap("NpcManager", NpcManager.kMapName, networkVars)
