//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// TeleportTrigger.lua
// Entity for mappers to create teleporters

Script.Load("lua/LogicMixin.lua")

class 'TeleportTrigger' (Trigger)

TeleportTrigger.kMapName = "teleport_trigger"

local networkVars =
	{
	}
	
AddMixinNetworkVars(LogicMixin, networkVars)

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


function TeleportTrigger:OnCreate()
 
    Trigger.OnCreate(self)       
    if Server then
        self:SetUpdates(true)  
    end
    
end

function TeleportTrigger:OnInitialized()

    Trigger.OnInitialized(self)    
    self:SetTriggerCollisionEnabled(true) 
    
    if Server then
        if self.exitonly then
            self:SetUpdates(false)
            self.enabled = false
        elseif not self.destination then
            Print("Error: TeleportTrigger " .. self.name .. " has no destination")
            DestroyEntity(self)
        end  
        // call it here so we got the correct enabled value
        InitMixin(self, LogicMixin) 
        // search destination after MapLoad
        self:SetFindEntity()        
    end 
    
end

function TeleportTrigger:OnTriggerEntered(enterEnt, triggerEnt)

    if self.enabled then
         self:TeleportEntity(enterEnt)
    end
    
end


function TeleportTrigger:SetDestination(newDestinationId)

    if newDestinationId then
         self.destinationId = newDestinationId         
    end
    
end


//Addtimedcallback had not worked, so lets search it this way
function TeleportTrigger:OnUpdate(deltaTime)    
    self:TeleportAllInTrigger()    
end


function TeleportTrigger:FindEntitys()

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


function TeleportTrigger:TeleportEntity(entity)

    if Server then        
        if self.enabled then
        
            if self.destinationId then      
                local time = Shared.GetTime()
                if (not entity.timeOfLastPhase) or (time >= (entity.timeOfLastPhase + self.waitDelay)) then
                    local destinationEntity = Shared.GetEntity(self.destinationId)  
                    local destOrigin = destinationEntity:GetOrigin()
                    local destAnlges = destinationEntity:GetAngles()
                    local extents = LookupTechData(entity:GetTechId(), kTechDataMaxExtents)
                    local antiStuckVector = Vector(0,0,0)
                    
                    entity.timeOfLastPhase = time  
                    // that the sound is also getting played for aliens
                    entity:TriggerEffects("teleport", {classname = "Marine"})  
                    
                    TransformPlayerCoordsForPhaseGate(entity, self:GetCoords(), destinationEntity:GetCoords())
                    
                    // make sure nothing blocks us
                    local teleportPointBlocked = Shared.CollideCapsule(destOrigin, extents.y, math.max(extents.x, extents.z), CollisionRep.Default, PhysicsMask.AllButPCs, nil)
                    if teleportPointBlocked then
                        // move it a bit so we're not getting blocked
                        antiStuckVector.z = math.cos(destAnlges.yaw)
                        antiStuckVector.x = math.sin(destAnlges.yaw)
                        antiStuckVector.y = 0.5
                    end
                    entity:SetOrigin(destOrigin + antiStuckVector)
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

function TeleportTrigger:TeleportAllInTrigger()

    for _, entity in ipairs(self:GetEntitiesInTrigger()) do
        self:TeleportEntity(entity)
    end
    
end


function TeleportTrigger:OnLogicTrigger()

    if not self.exitonly then
        if self.enabled == true then
            self.enabled = false
        else
            self.enabled = true
        end
        
        if Server then
            self:SetUpdates(true)
        end
    end
    
end


Shared.LinkClassToMap("TeleportTrigger", TeleportTrigger.kMapName, networkVars)