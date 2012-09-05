//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Utility.lua

local HotReload = CombatUtility
if(not HotReload) then
  CombatUtility = {}
  ClassHooker:Mixin("CombatUtility")
end

function CombatUtility:OnLoad()

    self:ReplaceFunction("GetRandomSpawnForCapsule", "GetRandomSpawnForCapsule_Hook")
	
end

// Find place for player to spawn, within range of origin. Makes sure that a line can be traced between the two points
// without hitting anything, to make sure you don't spawn on the other side of a wall. Returns nil if it can't find a 
// spawn point after a few tries.
function CombatUtility:GetRandomSpawnForCapsule_Hook(capsuleHeight, capsuleRadius, origin, minRange, maxRange, filter)

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
        local points = GetRandomPointsWithinRadius(origin, minRange, (maxRange * i / kSpawnMaxRetries), maxHeight, 1, 1)
        if #points == 1 then
            spawnPoint = points[1]
        else
            Print("GetRandomPointsWithinRadius() failed inside of GetRandomSpawnForCapsule()")
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
    
    return nil
    
end

if (not CombatUtility) then
	CombatPlayingTeam:OnLoad()
end