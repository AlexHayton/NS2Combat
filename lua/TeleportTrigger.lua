//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// TeleportTrigger.lua
// Entity for mappers to create teleporters

class 'TeleportTrigger' (Trigger)

TeleportTrigger.kMapName = "teleport_trigger"

local networkVars =
{
}

local function TransformPlayerCoordsForPhaseGate(player, srcCoords, dstCoords)

    local viewCoords = player:GetViewCoords()
    
    // If we're going through the backside of the phase gate, orient us
    // so we go out of the front side of the other gate.
    if Math.DotProduct(viewCoords.zAxis, srcCoords.zAxis) < 0 then
    
        srcCoords.zAxis = -srcCoords.zAxis
        srcCoords.xAxis = -srcCoords.xAxis
        
    end
    
    // Redirect player velocity relative to gates
    local invSrcCoords = srcCoords:GetInverse()
    local invVel = invSrcCoords:TransformVector(player:GetVelocity())
    local newVelocity = dstCoords:TransformVector(invVel)
    player:SetVelocity(newVelocity)
    
    local viewCoords = dstCoords * (invSrcCoords * viewCoords)
    local viewAngles = Angles()
    viewAngles:BuildFromCoords(viewCoords)
    
    player:SetOffsetAngles(viewAngles)
    
end

local function TeleportEntity(self, entity)

    if Server then        
        if self.enabled then
            if self.destinationId then      
                local time = Shared.GetTime()
                if (not entity.timeOfLastPhase) or (time >= (entity.timeOfLastPhase + self.waitDelay)) then
                    local destinationEntity = Shared.GetEntity(self.destinationId)  
                    local destOrigin = destinationEntity:GetOrigin()
                    local destAnlges = destinationEntity:GetAngles()
                    
                    entity.timeOfLastPhase = time  
                    // that the sound is also getting played for aliens
                    entity:TriggerEffects("teleport", {classname = "Marine"})  
                    
                    TransformPlayerCoordsForPhaseGate(entity, self:GetCoords(), destinationEntity:GetCoords())
                    entity:SetOrigin(destOrigin)
                end
            else
                if not self.exitonly then
                    Print("Error: TeleportTrigger " .. self.name .. " destination not found")
                end
            end
        // Just do nothing if the teleporter isn't enabled (exit only)
        end
    end
    
end

local function TeleportAllInTrigger(self)

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        TeleportEntity(self, entity)
    end
    
end

local function FindDestinationEntity(self)

    if Server then
        // when the 2nd teleportrigger isnt loaded by the engine, this will be called a 2nd. time with the OnUpdate function
        for _, trigger in ientitylist(Shared.GetEntitiesWithClassname("TeleportTrigger")) do
            if trigger.name == self.destination then
                self.destinationId = trigger:GetId()
                break                
            end
        end
        
    end
    
end

function TeleportTrigger:OnCreate()
 
    Trigger.OnCreate(self)  
    
    if Server then
        self:SetUpdates(true)  
    end
    
end

function TeleportTrigger:OnInitialized()

    Trigger.OnInitialized(self)    
    self:SetTriggerCollisionEnabled(true) 
    self.CheckDestinationTime = Shared.GetTime()
    
    if Server then
        if self.exitonly then
            self:SetUpdates(false)
            self.enabled = false
        elseif not self.destination then
            Print("Error: TeleportTrigger " .. self.name .. " has no destination")
            DestroyEntity(self)
        end
    end 
    
end

function TeleportTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    if self.enabled then
         TeleportEntity(self, enterEnt)
    end
    
end

//Addtimedcallback had not worked, so lets search it this way
function TeleportTrigger:OnUpdate(deltaTime)

    // only check after some time so we can be sure everything was loaded
    if Shared.GetTime() >= self.CheckDestinationTime + 6 then
        if not self.destinationId then
            self.CheckDestinationTime = Shared.GetTime()
            FindDestinationEntity(self)            
        end
    end
    
    TeleportAllInTrigger(self)
    
end

Shared.LinkClassToMap("TeleportTrigger", TeleportTrigger.kMapName, networkVars)