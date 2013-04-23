//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcLerkMixin = CreateMixin( NpcLerkMixin )
NpcLerkMixin.type = "NpcLerk"

NpcLerkMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcLerkMixin.expectedCallbacks =
{
}


NpcLerkMixin.networkVars =  
{
}


function NpcLerkMixin:__initmixin()   
end

// let lerk hover over the ground
function NpcLerkMixin:AiSpecialLogic()

     if self:GetCurrentOrder() then
        if not self.inTargetRange then
        
            if not self.nextFlyStop then
                self.nextFlyStop = Shared.GetTime() + 1.5 
            end
            
            if Shared.GetTime() < self.nextFlyStop then
                self:PressButton(Move.Jump) 
            else
                self.nextFlyStop = nil
            end
        end  
    end

end

function NpcLerkMixin:UpdateOrderLogic()

    local order = self:GetCurrentOrder()             
    local activeWeapon = self:GetActiveWeapon()

    if order ~= nil then
        if (order:GetType() == kTechId.Attack) then
        
            local target = Shared.GetEntity(order:GetParam())
            if target then
            
                if activeWeapon then          
                    // attack with spikes also, when seeing the entitiy
                    if GetCanSeeEntity(self, target) then
                        self:PressButton(Move.SecondaryAttack)                   
                    end
                end              

            end
        end
    end   
    
end


function NpcLerkMixin:GetAttackDistanceOverride()
    return 1.2
end

function NpcLerkMixin:GetIsFlying()
    return true
end

function NpcLerkMixin:GetHoverHeight()    
    return MAC.kHoverHeight
end

function NpcLerkMixin:CheckImportantEvents()
end





