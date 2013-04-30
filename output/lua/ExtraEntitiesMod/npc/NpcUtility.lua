//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// only take targets from mates that near that distance
kSwarmLogicMaxDistance = 10
kSwarmLogicMaxTime = 4
kSwarmLogicTargets = {}

// table for team 1 and 2
kSwarmLogicTargets[1] = {}
kSwarmLogicTargets[2] = {}
kSwarmLogicMaxListEntrys = 20


// if nearby mates already got a target, use the same
function NpcUtility_AcquireTarget(self)

    local teamNumber = self:GetTeamNumber()
    local origin = self:GetOrigin()
    local target = nil
    
    // first check if we find a valid target in the list (maybe somebody has searched targets secs ago
    
    if #kSwarmLogicTargets[teamNumber] > 0 then
        local deleteEntry = false
        for i, entry in ipairs(kSwarmLogicTargets[teamNumber]) do

            // don't take targets that are to old 
            if (Shared.GetTime() - entry.time) < kSwarmLogicMaxTime then
                if (entry.origin - origin):GetLengthXZ() < kSwarmLogicMaxDistance then
                    local oldTarget = Shared.GetEntity(entry.target)
                    if oldTarget and oldTarget:GetIsAlive() then
                        target = oldTarget
                        break
                    else
                        deleteEntry = true
                    end
                end
            else
                deleteEntry = true
            end
            
            if deleteEntry then
                // delete him from the table
                 table.remove(kSwarmLogicTargets[teamNumber], i)
                 i = i - 1
                 deleteEntry = false
            end
            
        end    
    end
    
    // if we got no target, search one
    target = target or self.targetSelector:AcquireTarget()     
    
    if target then
        NpcUtility_InformTeam(self, target)  
        return true
    end
    
    return false
end


// tell our members we're getting attacked
function NpcUtility_InformTeam(self, attacker)
    local origin = self:GetOrigin()
    local teamNumber = self:GetTeamNumber()
    
    for _, player in ipairs(GetEntitiesWithMixinForTeamWithinRange("Npc", teamNumber, origin, kSwarmLogicMaxDistance)) do
        // give all team members the order to attack the same target
        local target = nil
        if player.target then 
            target = player:GetTarget()
        end
        
        if not target or not target:isa("Player") then 
            player:GiveOrder(kTechId.Attack, attacker:GetId(), attacker:GetOrigin(), nil, true, true)
            player.target = attacker:GetId()
        end        
    end 
    
    // save the target in the targets list
    table.insert(kSwarmLogicTargets[teamNumber], {
                        target = attacker:GetId(),
                        origin = origin,
                        time = Shared.GetTime()
                    })
                    
    // out of list, delete it
    if #kSwarmLogicTargets[teamNumber] >= kSwarmLogicMaxListEntrys then
        table.remove(kSwarmLogicTargets[teamNumber], 1)
    end
end



function NpcUtility_GetClearSpawn(origin, className)
    
    local techId = LookupTechId(class, kTechDataMapName, kTechId.None) 
    local extents = Vector(0.17, 0.2, 0.17)
    if techId  then
         extents = LookupTechData(techId , kTechDataMaxExtents) or  extents 
    end
    // origin of entity is on ground, so make it higher
    local position = origin
    if not GetHasRoomForCapsule(extents, origin , CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterAll()) then
        // search clear spawn pos
        for index = 1, 100 do
            randomSpawn = GetRandomSpawnForCapsule(extents.y, extents.x , origin , 1, 5, EntityFilterAll())
            if randomSpawn then
                position = randomSpawn
                break                
            end
        end
    end
        
    return position        

end

function NpcUtility_Spawn(origin, className, values, waypoint)

    local spawnOrigin = NpcUtility_GetClearSpawn(origin, className)
    values.origin = spawnOrigin
    values.isaNpc = true
    
    if values.origin then      
        local entity = Server.CreateEntity(className, values)
        entity:DropToFloor()
        // init the xp mixin for the new npc
        InitMixin(entity, NpcMixin)	
        if waypoint then
            entity:GiveOrder(kTechId.Move , waypoint:GetId(), waypoint:GetOrigin(), nil, true, true)
            entity.mapWaypoint = waypoint:GetId()
        end
    else
        Print("Found no position for npc!")
    end
    
end




if Server then

    function OnConsoleAddNpc(client, class, team, amount)
    
        if Shared.GetCheatsEnabled() or Shared.GetDevMode() then
            local player = client:GetControllingPlayer()
            local className = Skulk.kMapName
            local origin = Vector(0,0,0) 
            team = tonumber(team) or player:GetTeamNumber()
            amount = tonumber(amount) or 1
            
            if not class then
                class = "skulk"
            else
                class = string.lower(class)
            end
            
            if team > 2 then
                team = 2
            elseif team < 1 then
                team = 1
            end
            
            if player then
                // trace along players zAxis and spawn the item there
                local startPoint = player:GetEyePos()
                local endPoint = startPoint + player:GetViewCoords().zAxis * 100
                
                local trace = Shared.TraceRay(startPoint, endPoint,  CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
                origin = trace.endPoint or origin
            end
            
                                    
            local values = { 
                    origin = origin,                    
                    team = team,
                    startsActive = true,
                    }

            if class ~= "skulk" then
                if class == "lerk" then
                    className = Lerk.kMapName
                elseif class == "gorge" then  
                    className = Gorge.kMapName
                elseif class == "fade" then  
                    className = Fade.kMapName
                elseif class == "onos" then  
                    className = Onos.kMapName
                elseif class == "marine" then
                    className = Marine.kMapName
                elseif class == "exo" then
                    className = Exo.kMapName
                    values.layout = "ClawMinigun"
                else
                    Print("Class: ".. class .. " is unknown, spawning a skulk instead.")
                end      
            end
            
            for i = 1, amount do
                NpcUtility_Spawn(origin, className, values, nil)
            end
            
        end
    end

    Event.Hook("Console_addnpc",         OnConsoleAddNpc)

end
    



