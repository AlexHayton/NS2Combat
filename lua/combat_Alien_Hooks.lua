//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Alien.lua

local HotReload = CombatAlien
if(not HotReload) then
    CombatAlien = {}
	ClassHooker:Mixin("CombatAlien")
end
    
function CombatAlien:OnLoad()
   
    if Server then
        self:ReplaceClassFunction("Alien", "GetHasTwoHives","GetHasTwoHives_Hook")
        self:ReplaceClassFunction("Alien", "GetHasThreeHives","GetHasThreeHives_Hook")
        self:PostHookClassFunction("Alien", "GetCanTakeDamageOverride", "GetCanTakeDamageOverride_Hook"):SetPassHandle(true)
    end
    
	self:PostHookClassFunction("Alien", "OnUpdateAnimationInput","OnUpdateAnimationInput_Hook")    
	
end

if Server then

    function CombatAlien:GetHasTwoHives_Hook(self)
        self:CheckCombatData()
        return self.combatTable.twoHives
    end

    function CombatAlien:GetHasThreeHives_Hook(self)
        self:CheckCombatData()
        return self.combatTable.threeHives
    end

    function CombatAlien:GetCanTakeDamageOverride_Hook(handle, self)

        local canTakeDamage = handle:GetReturn() and not self.gotSpawnProtect
        handle:SetReturn(canTakeDamage)

    end

end


function CombatAlien:OnUpdateAnimationInput_Hook(self, modelMixin)
  
    if self:GotFocus() then
        modelMixin:SetAnimationInput("attack_speed", kCombatFocusAttackSpeed)        
    else
        // standard attack speed is 1, but the variable is local so we cant use it
        modelMixin:SetAnimationInput("attack_speed", self:GetIsEnzymed() and kEnzymeAttackSpeed or 1.0)
    end
    
end

if (not HotReload) then
	CombatAlien:OnLoad()
end