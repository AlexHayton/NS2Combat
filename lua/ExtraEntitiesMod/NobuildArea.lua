//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// NobuildArea.lua
// Entity for mappers to create teleporters

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")
Script.Load("lua/PathingMixin.lua")

class 'NobuildArea' (Trigger)

NobuildArea.kMapName = "nobuild_area"

local networkVars =
	{
	    enabled = "boolean",
	}
	
AddMixinNetworkVars(LogicMixin, networkVars)


function NobuildArea:OnCreate() 
    Trigger.OnCreate(self)
    InitMixin(self, PathingMixin)
    self:SetPathingFlags(Pathing.PolyFlag_NoBuild)
end

function NobuildArea:OnInitialized()

    Trigger.OnInitialized(self)
    self.startEnabled = self.enabled

end

function NobuildArea:Reset()
    self.enabled = self.startEnabled  
end

function NobuildArea:GetIsFlying()
    return false
end

function NobuildArea:OnLogicTrigger()
    if self.enabled then
         self.enabled = false
    else
         self.enabled = true
    end
end


Shared.LinkClassToMap("NobuildArea", NobuildArea.kMapName, networkVars)
