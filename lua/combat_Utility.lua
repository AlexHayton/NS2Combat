//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Utility.lua

/**
 * Returns the spawn point on success, nil on failure.
 */
local function ValidateSpawnPoint(spawnPoint, capsuleHeight, capsuleRadius, filter, origin)

    local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)
    local spawnPointCenter = spawnPoint + center
    
    // Make sure capsule isn't interpenetrating something.
    local spawnPointBlocked = Shared.CollideCapsule(spawnPointCenter, capsuleRadius, capsuleHeight, CollisionRep.Default, PhysicsMask.AllButPCs, nil)
    if not spawnPointBlocked then

        // Trace capsule to ground, making sure we're not on something like a player or structure
        local trace = Shared.TraceCapsule(spawnPointCenter, spawnPoint - Vector(0, 10, 0), capsuleRadius, capsuleHeight, CollisionRep.Move, PhysicsMask.AllButPCs)            
        if trace.fraction < 1 and (trace.entity == nil or not trace.entity:isa("ScriptActor")) then
        
            VectorCopy(trace.endPoint, spawnPoint)
            
            local endPoint = trace.endPoint + Vector(0, capsuleHeight / 2, 0)
            // Trace in both directions to make sure no walls are being ignored.
            trace = Shared.TraceRay(endPoint, origin, CollisionRep.Move, PhysicsMask.AllButPCs, filter)
            local traceOriginToEnd = Shared.TraceRay(origin, endPoint, CollisionRep.Move, PhysicsMask.AllButPCs, filter)
            
            if trace.fraction == 1 and traceOriginToEnd.fraction == 1 then
                return spawnPoint - Vector(0, capsuleHeight / 2, 0)
            end
            
        end
        
    end
    
    return nil
    
end


// Find place for player to spawn, within range of origin. Makes sure that a line can be traced between the two points
// without hitting anything, to make sure you don't spawn on the other side of a wall. Returns nil if it can't find a 
// spawn point after a few tries.
function GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, minRange, maxRange, filter)

    ASSERT(capsuleHeight > 0)
    ASSERT(capsuleRadius > 0)
    ASSERT(origin ~= nil)
    ASSERT(type(minRange) == "number")
    ASSERT(type(maxRange) == "number")
    ASSERT(maxRange > minRange)
    ASSERT(minRange > 0)
    ASSERT(maxRange > 0)
    
    local maxHeight = 10
    
    for i = 1, kSpawnMaxRetries do
    
        local spawnPoint = nil
        local points = GetRandomPointsWithinRadius(origin, minRange, minRange*2 + ((maxRange-minRange*2) * i / kSpawnMaxRetries), kSpawnMaxVertical, 1, 1)
        if #points == 1 then
            spawnPoint = points[1]
        else
        end
        
        if spawnPoint then
        
        
            // The spawn point returned by GetRandomPointsWithinRadius() may be too close to the ground.
            // Move it up a bit so there is some "wiggle" room. ValidateSpawnPoint() traces down anyway.
            spawnPoint = spawnPoint + Vector(0, 0.5, 0)
            local validSpawnPoint = ValidateSpawnPoint(spawnPoint, capsuleHeight, capsuleRadius, filter, origin)
            if validSpawnPoint then
                return validSpawnPoint
            end
            
        end
        
    end
    
	Print("GetRandomPointsWithinRadius() failed to find a suitable point inside of GetRandomSpawnForCapsule()")
    return nil
    
end

// Used to send messages to all players.
function SendGlobalChatMessage(message)
	local allPlayers = Shared.GetEntitiesWithClassname("Player")
	for index, player in ientitylist(allPlayers) do
		player:SendDirectMessage(message)
	end
	
	// Also output to the console for admins.
	Shared.Message(message)
end

function GetTimeText(timeInSeconds)

	ASSERT(timeInSeconds >= 0)
	local timeLeftText = ""
	timeNumericSeconds = tonumber(timeInSeconds)
	if (timeNumericSeconds > 60) then
		timeLeftText = math.ceil(timeNumericSeconds/60) .." minutes"
	elseif (timeNumericSeconds == 60) then
		timeLeftText = "1 minute"
	elseif (timeNumericSeconds == 1) then
		timeLeftText = "1 second"
	else
		timeLeftText = timeNumericSeconds .." seconds"
	end
	return timeLeftText

end