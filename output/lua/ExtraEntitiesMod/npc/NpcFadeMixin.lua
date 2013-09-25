//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

Script.Load("lua/FunctionContracts.lua")
Script.Load("lua/PathingUtility.lua")

NpcFadeMixin = CreateMixin( NpcFadeMixin )
NpcFadeMixin.type = "NpcFade"

NpcFadeMixin.expectedMixins =
{
    Npc = "Required to work"
}

NpcFadeMixin.expectedCallbacks =
{
}


NpcFadeMixin.networkVars =  
{
}


function NpcFadeMixin:__initmixin()   
end

// use shadow step sometimes
function NpcFadeMixin:AiSpecialLogic(deltaTime)
    local order = self:GetCurrentOrder()
    if order then
        if self.points and self.index and #self.points >= self.index then
            if ((self:GetOrigin() - self.points[self.index]):GetLengthXZ() > 2) and not self.usedShadowStep then
                // shadow step will bring you faster forward
                // only random
                if math.random(1, 100) < 10 then                    
                    self.usedShadowStep = true
                end
            else     
                if ((self:GetOrigin() - self.points[self.index]):GetLengthXZ() < 2) and self.usedShadowStep  then
                    // hold it if they point is far away
                    self.usedShadowStep = false
                end
            end
        end
        
        if self.usedShadowStep and not self.inTargetRange then
            self:PressButton(Move.SecondaryAttack)
        end
        
    end
end

function NpcFadeMixin:GetAttackDistanceOverride()
    return SwipeBlink.kRange
end

function NpcFadeMixin:CheckImportantEvents()
end





