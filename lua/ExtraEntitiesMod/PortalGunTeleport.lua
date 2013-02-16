//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// TeleportTrigger.lua
// Entity for mappers to create teleporters

class 'PortalGunTeleport' (TeleportTrigger)

PortalGunTeleport.kMapName = "portalgun_teleport"

local kPortalLoopingCinematic0 = PrecacheAsset("cinematics/portal.cinematic")
local kPortalLoopingCinematic1 = PrecacheAsset("cinematics/portal_blue.cinematic")
local kPortalLoopingCinematic2 = PrecacheAsset("cinematics/portal_red.cinematic")

local defaultCinematic = kPortalLoopingCinematic0

local networkVars =
	{
	    cinematicType = "integer (0 to 10)",
	    cinematicTypeOld = "integer (0 to 10)",
	}
	

function PortalGunTeleport:OnCreate()
 
    Trigger.OnCreate(self)  
    
    if Server then
        self:SetUpdates(true)  
    end
    
end

function PortalGunTeleport:OnInitialized()

    // TODO: get the invert angels of the wall
    //self:SetAngles(Angles(90,0,0))
    local angles = self:GetAngles()
    self.scale = Vector(1,1,1)
    self.waitDelay = 0.8
    Trigger.OnInitialized(self)    
    self:SetTriggerCollisionEnabled(true) 
    
    if Server then
        self.enabled = false     
    
    elseif Client then
  
        if not self.portalCinematic then
            self:CreateCinematic(0)
        end
        
    end    

end

function PortalGunTeleport:OnDestroy()

    TeleportTrigger.OnDestroy(self)
    
    if self.portalCinematic then
        
        Client.DestroyCinematic(self.portalCinematic)
        self.portalCinematic = nil
            
    end
        
end

function PortalGunTeleport:OnTriggerEntered(enterEnt, triggerEnt)

    if self.enabled then
         self:TeleportEntity(enterEnt)
    end
    
end


function PortalGunTeleport:SetDestination(newDestinationId)

    if newDestinationId then
        self.destinationId = newDestinationId
        self.enabled = true 
    end
    
end

function PortalGunTeleport:SetType(type)
    // Todo: CHange color    
    self.cinematicType = type      
    
end


//Addtimedcallback had not worked, so lets search it this way
function PortalGunTeleport:OnUpdate(deltaTime)

    if self.enabled then
        self:TeleportAllInTrigger()
    end
    
    if Client then
        if self.cinematicTypeOld ~= self.cinematicType then
            self:CreateCinematic(self.cinematicType)
        end
    end
    
end

if Client then
    function PortalGunTeleport:CreateCinematic(type)

            // Todo: change only the cinematic when the type changes
            if not self.portalCinematic or type ~= self.cinematicType then
                self.portalCinematic = Client.CreateCinematic(RenderScene.Zone_Default)    
                self.portalCinematic:SetCinematic(self:GetCinematicName())
                self.portalCinematic:SetRepeatStyle(Cinematic.Repeat_Endless)
            
                local coords = self:GetCoords()    
                coords.xAxis = coords.xAxis * self.scale.x
                coords.yAxis = coords.yAxis * self.scale.y
                coords.zAxis = coords.zAxis * self.scale.z
            
                self.portalCinematic:SetCoords(coords)
                self.cinematicTypeOld = type
            end                
    end
    
    function PortalGunTeleport:GetCinematicName()

        if self.cinematicType == 0 then
            return kPortalLoopingCinematic0
        elseif self.cinematicType == 1 then
            return kPortalLoopingCinematic1
        elseif self.cinematicType  == 2 then
            return kPortalLoopingCinematic2
        else
            return defaultCinematic
        end

    end
end

Shared.LinkClassToMap("PortalGunTeleport", PortalGunTeleport.kMapName, networkVars)