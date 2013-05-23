//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// base class for spawning npcs

class 'NpcQueueManager' (Entity)

NpcQueueManager.kMapName = "npc_queue_manager"
  
local networkVars =
{
}

if Server then

    local function UpdateQueue(self)
        if #self.kNpcQueue > 0 and NpcUtility_GetCanSpawnNpc() then
            for i, entry in ipairs(self.kNpcQueue) do
                NpcUtility_Spawn(entry.origin, entry.className, entry.values, entry.waypoint)
                table.remove(self.kNpcQueue, i)
                if not NpcUtility_GetCanSpawnNpc() then
                    break
                end
            end            
        end
        return true        
    end

    function NpcQueueManager:OnCreate()
    end

    function NpcQueueManager:OnInitialized()
        self.kNpcQueue = {}
        self:AddTimedCallback(UpdateQueue, 1)
    end   
    
    function NpcQueueManager:AddToQueue(values)
        table.insert(self.kNpcQueue, values)
    end
    
    function NpcQueueManager:Reset()
        kLastSpawnTime = 0
        kSpawnedNpcs = 0
        kNpcList = {}
        self.kNpcQueue = {}
    end

end

Shared.LinkClassToMap("NpcQueueManager", NpcQueueManager.kMapName, networkVars)

