//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________


function NpcUtility_GetClearSpawn(origin, className)
    
    local techId = LookupTechId(class, kTechDataMapName, kTechId.None) 
    local extents = Vector(0.17, 0.2, 0.17)
    if techId  then
         extents = LookupTechData(techId , kTechDataMaxExtents) or  extents 
    end
    // origin of entity is on ground, so make it higher
    local position = origin + Vector(0, extents.y, 0)        
    
    if not GetHasRoomForCapsule(extents, position, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterAll()) then
        // search clear spawn pos
        for index = 1, 50 do
            randomSpawn = GetRandomSpawnForCapsule(extents.y, extents.x , position , 1, 5, EntityFilterAll())
            if position then
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

            
            if player then
                // trace along players zAxis and spawn the item there
                local startPoint = player:GetEyePos()
                local endPoint = startPoint + player:GetViewCoords().zAxis * 100
                
                local trace = Shared.TraceRay(startPoint, endPoint,  CollisionRep.Default, PhysicsMask.Bullets, EntityFilterAll())
                origin = trace.endPoint or origin
            end
            
                                    
            local values = { 
                    origin = origin,                    
                    team = team or player:GetTeamNumber(),
                    startsActive = true,
                    }

            if class then
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
                    
                else
                    Print("Class: ".. class .. " is unknown, spawning a skulk instead.")
                end      
            end
            
            NpcUtility_Spawn(origin, className, values, nil)
            
        end
    end

    Event.Hook("Console_addnpc",         OnConsoleAddNpc)

end
    



