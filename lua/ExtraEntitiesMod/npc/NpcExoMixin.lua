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

function NpcExoMixin:AttackOverride(activeWeapon) 

    local leftWeapon = activeWeapon:GetLeftSlotWeapon()
    if leftWeapon:isa("Minigun") or leftWeapon:isa("Railgun") then
         attackLeft = true
    else
        attackLeft = false
    end
    
    if not self.fired then    
        if attackLeft then
            self:PressButton(Move.PrimaryAttack)
        end
        self:PressButton(Move.SecondaryAttack)
        
        self.fired = true
    else
        self.fired = false
    end    

end





