//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_ClipWeapon.lua

// for fast reload

local HotReload = CombatClipWeapon
if(not HotReload) then
  CombatClipWeapon = {}
  ClassHooker:Mixin("CombatClipWeapon")
end
    
function CombatClipWeapon:OnLoad()

    self:PostHookClassFunction("ClipWeapon", "OnUpdateAnimationInput", "OnUpdateAnimationInput_Hook")
	
end

// for fast reloading
function CombatClipWeapon:OnUpdateAnimationInput_Hook(self, modelMixin)
   
    local player = self:GetParent()
    if player then
    
        if kCombatModActive then
            modelMixin:SetAnimationInput("reload_time", player:GotFastReload() and kCombatFastRelaodTime or kClassicReloadTime)
        else
            modelMixin:SetAnimationInput("reload_time", 1)
        end
    end
            
end

if (not HotReload) then
	CombatClipWeapon:OnLoad()
end