//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcExoMixin = CreateMixin( NpcExoMixin )
NpcExoMixin.type = "NpcExo"

NpcExoMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcExoMixin.expectedCallbacks =
{
}


NpcExoMixin.networkVars =  
{
}


function NpcExoMixin:__initmixin()   
end

function NpcExoMixin:CheckImportantEvents()
end

function NpcExoMixin:GetAttackDistanceOverride()
    if self.target and self:GetTarget() then
        if self:GetTarget():isa("Egg") then
            // walk onto the egg to smash it
            return 0
        end
    end
    
    local activeWeapon = self:GetActiveWeapon()

    if activeWeapon then
        return math.min(activeWeapon:GetRange(), 40)
    end  
end

function NpcExoMixin:AttackOverride(activeWeapon) 

    local leftWeapon = activeWeapon:GetLeftSlotWeapon()
    if leftWeapon:isa("Minigun") or leftWeapon:isa("Railgun") then
         attackLeft = true
    else
        attackLeft = false
    end
    
    if attackLeft then
        self:PressButton(Move.PrimaryAttack)
    end
    self:PressButton(Move.SecondaryAttack)        

end





