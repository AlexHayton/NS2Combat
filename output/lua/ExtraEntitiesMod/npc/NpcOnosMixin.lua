//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcOnosMixin = CreateMixin( NpcOnos )
NpcOnosMixin.type = "NpcMarine"

NpcOnosMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcOnosMixin.expectedCallbacks =
{
}


NpcOnosMixin.networkVars =  
{
}


function NpcOnosMixin:__initmixin()   
end

// run to the enemy if near and see it
function NpcOnosMixin:AiSpecialLogic()
    local order = self:GetCurrentOrder()
    if order then
        if self.target and self:GetTarget() then
        
            if GetCanSeeEntity(self, self:GetTarget()) and (((self:GetOrigin() - self:GetTarget():GetOrigin()):GetLengthXZ() > 8) or self.sprintStop) then
            
                // only random
                if not self.nextSprintStop and math.random(1, 100) < 10 then
                    self.nextSprintStop = Shared.GetTime() + 3 
                end
                
                if self.sprintStop then
                    if Shared.GetTime() < self.sprintStop then
                        self:PressButton(Move.MovementModifier) 
                    else    
                        self.sprintStop = nil
                    end
                end                
                
            end
            
        end
    end
end

function NpcOnosMixin:GetAttackDistanceOverride()
    return 2.4
end

function NpcOnosMixin:CheckImportantEvents()
end





