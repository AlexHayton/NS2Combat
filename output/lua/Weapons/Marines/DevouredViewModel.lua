//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

Script.Load("lua/Weapons/Weapon.lua")

class 'DevouredViewModel' (Weapon)

DevouredViewModel.kMapName = "devoured_view_model"

DevouredViewModel.kViewModelName = PrecacheAsset("models/alien/onos/Onos_stomach_view.model")
local kAnimationGraph = PrecacheAsset("models/alien/onos/onos_stomach_view.animation_graph")
local kPunchSoundLeft = PrecacheAsset("sound/combat.fev/combat/abilities/stomach_punch_l")
local kPunchSoundRight = PrecacheAsset("sound/combat.fev/combat/abilities/stomach_punch_r")

local kWoundSound = PrecacheAsset("sound/NS2.fev/marine/common/wound")
local kRange = 0.0001

local networkVars =
{
}

function DevouredViewModel:OnCreate()
    Weapon.OnCreate(self)
end

function DevouredViewModel:OnInitialized()

    Weapon.OnInitialized(self)    

end

function DevouredViewModel:GetViewModelName()
    return DevouredViewModel.kViewModelName
end

function DevouredViewModel:GetAnimationGraphName()
    return kAnimationGraph
end

function DevouredViewModel:GetHUDSlot()
    return kTertiaryWeaponSlot
end

function DevouredViewModel:GetRange()
    return kRange
end

function DevouredViewModel:GetShowDamageIndicator()
    return true
end

function DevouredViewModel:GetSprintAllowed()
    return false
end

function DevouredViewModel:GetDeathIconIndex()
    return kDeathMessageIcon.DevouredViewModel
end

function DevouredViewModel:OnDraw(player, previousWeaponMapName)

    Weapon.OnDraw(self, player, previousWeaponMapName)
    
    // Attach weapon to parent's hand
    self:SetAttachPoint(Weapon.kHumanAttachPoint)
    
end

function DevouredViewModel:OnHolster(player)

    Weapon.OnHolster(self, player)
    self.primaryAttacking = false
    
end

function DevouredViewModel:OnPrimaryAttack(player)

    if not self.attacking then
        self.primaryAttacking = true        
    end

end

function DevouredViewModel:OnPrimaryAttackEnd(player)
    self.primaryAttacking = false
end

function DevouredViewModel:GetHasSecondary(player)
    return true
end

function DevouredViewModel:GetSecondaryAttackRequiresPress()
    return true
end

function DevouredViewModel:OnSecondaryAttack(player)

    if not self.attacking then
        self.secondaryAttacking = true        
    end

end

function DevouredViewModel:OnSecondaryAttackEnd(player)
    self.secondaryAttacking = false
end


function DevouredViewModel:OnTag(tagName)  
    if tagName == "attack_left_start" then
        self:PlaySound(kPunchSoundLeft) 
    elseif tagName == "attack_right_start" then
        self:PlaySound(kPunchSoundRight)
    elseif tagName == "attack_left_end" or tagName == "attack_right_end" then
        //self:PlaySound(kWoundSound)        
    end
end

function DevouredViewModel:UpdateViewModelPoseParameters(viewModel)
    viewModel:SetPoseParam("devour_percent", self:GetParent():GetDevourPercentage())
end


function DevouredViewModel:OnUpdateAnimationInput(modelMixin)

    local activity = "idle1"
	if self:GetParent():GetIsOnosDying() then 
		activity = "freedom"
    elseif self.primaryAttacking then
        activity = "primary"
	elseif self.secondaryAttacking then
		activity = "secondary"
	end
	
    modelMixin:SetAnimationInput("activity", activity)     
    
end

Shared.LinkClassToMap("DevouredViewModel", DevouredViewModel.kMapName, networkVars)