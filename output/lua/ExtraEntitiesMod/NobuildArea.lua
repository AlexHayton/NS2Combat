//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________
// NobuildArea.lua
// Entity for mappers to create teleporters

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'NobuildArea' (Entity)

NobuildArea.kMapName = "nobuild_area"

local networkVars =
	{
	    scale = "vector",
	    enabled = "boolean"
	}
	
AddMixinNetworkVars(LogicMixin, networkVars)


function NobuildArea:OnCreate() 
end

function NobuildArea:OnInitialized()
    self.startEnabled = self.enabled
    local extents = self.scale * 0.2
    extents.y = math.max(extents.y, 1)
    Pathing.SetPolyFlags(self:GetOrigin(), extents, Pathing.PolyFlag_NoBuild)
end

function NobuildArea:Reset()
    self.enabled = self.startEnabled  
end

function NobuildArea:OnLogicTrigger()
    if self.enabled then
         self.enabled = false
    else
         self.enabled = true
    end
end


Shared.LinkClassToMap("NobuildArea", NobuildArea.kMapName, networkVars)
