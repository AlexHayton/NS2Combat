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
                self.nextFlyStop = Shared.GetTime() + 2    
            end

            if not ((self.nextFlyStop - Shared.GetTime()) >  2)  then
                self:PressButton(Move.Jump) 
                self.nextFlyStop = Shared.GetTime() + 2                 
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





