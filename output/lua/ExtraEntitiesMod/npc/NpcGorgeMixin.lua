//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcGorgeMixin = CreateMixin( NpcGorgeMixin )
NpcGorgeMixin.type = "NpcGorge"

NpcGorgeMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcGorgeMixin.expectedCallbacks =
{
}


NpcGorgeMixin.networkVars =  
{
}


function NpcGorgeMixin:__initmixin()   
end

function NpcGorgeMixin:GetAttackDistanceOverride()
    return 40
end

function NpcGorgeMixin:CheckImportantEvents()
   
    if self.lastAttacker then
        // jump sometimes if getting attacked
        if Shared.GetRandomInt(0, 100) <= 10 then
            self:PressButton(Move.Jump)
        end
        self.lastAttacker = nil
    end    
       
    local activeWeapon = self:GetActiveWeapon()

    if self:GetHealth() < self:GetMaxHealth() then
        // heal us
        local activeWeapon = self:GetActiveWeapon()
        if activeWeapon and activeWeapon:isa("SpitSpray") then
            self:PressButton(Move.SecondaryAttack)
        end
    end    
    
end


function NpcGorgeMixin:UpdateOrderLogic()

    local order = self:GetCurrentOrder()             
    if order ~= nil then
        if order:GetType() == kTechId.Heal or order:GetType() == kTechId.AutoHeal then
            // go to entity and heal it
        end
    end
    
end
    







