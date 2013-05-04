//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

Script.Load("lua/Player.lua")
Script.Load("lua/Weapons/Marines/DevouredViewModel.lua")

class 'DevouredPlayer' (Marine)

DevouredPlayer.kMapName = "DevouredPlayer"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/devour_goop.surface_shader")

local networkVars =
{
    devouringPercentage = "integer (0 to 100)",
	isOnosDying = "boolean",
}

local function AddCorrodeMaterial(self)

    if self._renderModel and not self.devourMaterial then
		local material = Client.CreateRenderMaterial()
		material:SetMaterial("cinematics/vfx_materials/devour_goop.material")

		local viewMaterial = Client.CreateRenderMaterial()
		viewMaterial:SetMaterial("cinematics/vfx_materials/devour_goop.material")
		
		self.devourEntities = {}
		self.devourMaterial = material
		self.devourMaterialViewMaterial = viewMaterial
		AddMaterialEffect(self, material, viewMaterial, self.devourEntities)
	elseif Client and not self._renderModel then
		return true
	end
	
	return false
    
end

function DevouredPlayer:OnCreate()

    Marine.OnCreate(self)
    
 end


function DevouredPlayer:OnInitialized()

    Marine.OnInitialized(self)
    
    self:SetIsVisible(false)       
  
    // Remove physics
    self:DestroyController()    
    // Other players never see a DevouredPlayer.
    self:SetPropagate(Entity.Propagate_Never) 

    self.devouringPercentage = 0
	self.isOnosDying = false
    
    if Server then
        self:TriggerEffects("player_start_gestate")
	else
		self:AddTimedCallback(AddCorrodeMaterial, 0.1)
    end
    
end

function DevouredPlayer:OnDestroy()
    Marine.OnDestroy(self) 
    if Server then
        self:TriggerEffects("player_end_gestate")
    end
    self:SetViewModel(nil, nil)    
	
	if Client and self.devourMaterial then
		RemoveMaterialEffect(self.devourEntities, self.devourMaterial, self.devourMaterialViewMaterial)
		Client.DestroyRenderMaterial(self.devourMaterial)
		Client.DestroyRenderMaterial(self.devourMaterialViewMaterial)
		self.devourMaterial = nil
		self.devourMaterialViewMaterial = nil
		self.devourEntities = nil
	end
end


// let the player chat, but but nove
function DevouredPlayer:OverrideInput(input)
  
		ClampInputPitch(input)
		
		// Completely override movement and commands
		input.move.x = 0
		input.move.y = 0
		input.move.z = 0
		
	return input
    
end


function DevouredPlayer:InitWeapons()
    self:GiveItem(DevouredViewModel.kMapName)
    self:SetActiveWeapon(DevouredViewModel.kMapName)
end

function DevouredPlayer:GetDevourPercentage()
    return self.devouringPercentage
end

function DevouredPlayer:GetPlayFootsteps()
    return false
end

function DevouredPlayer:GetMovePhysicsMask()
    return PhysicsMask.All
end

function DevouredPlayer:GetTraceCapsule()
    return 0, 0
end

function DevouredPlayer:GetCanTakeDamageOverride()
    return true
end

function DevouredPlayer:GetCanDieOverride()
	if self:GetHealth() <= 0 then
		return true
	end
end

function DevouredPlayer:AdjustGravityForce(input, gravity)
    return 0
end

-- ERASE OR REFACTOR
// Handle player transitions to egg, new lifeforms, etc.
function DevouredPlayer:OnEntityChange(oldEntityId, newEntityId)

    if oldEntityId ~= Entity.invalidId and oldEntityId ~= nil then
    
        if oldEntityId == self.specTargetId then
            self.specTargetId = newEntityId
        end
        
        if oldEntityId == self.lastTargetId then
            self.lastTargetId = newEntityId
        end
        
    end
    
end

function DevouredPlayer:GetPlayerStatusDesc()
    return kPlayerStatus.Player
end

function DevouredPlayer:GetTechId()
    return kTechId.Marine
end

function DevouredPlayer:OnTag(tagName)
    //Print(tagName)
end

function DevouredPlayer:SetIsOnosDying(newValue)
	self.isOnosDying = newValue
end

function DevouredPlayer:GetIsOnosDying()
	return self.isOnosDying
end

function DevouredPlayer:OnUpdatePoseParameters()    
        
    local viewModel = self:GetViewModelEntity()
    if viewModel ~= nil then
    
        local activeWeapon = self:GetActiveWeapon()
        if activeWeapon and activeWeapon.UpdateViewModelPoseParameters then
            activeWeapon:UpdateViewModelPoseParameters(viewModel, input)
        end
        
    end

end

Shared.LinkClassToMap("DevouredPlayer", DevouredPlayer.kMapName, networkVars)

if Server then
    local function OnCommandChangeClass(client)
        
        local player = client:GetControllingPlayer()
        if Shared.GetCheatsEnabled() then
            player:Replace(DevouredPlayer.kMapName, player:GetTeamNumber(), false, player:GetOrigin())
        end
        
    end

    Event.Hook("Console_devoured_player", OnCommandChangeClass)
end
