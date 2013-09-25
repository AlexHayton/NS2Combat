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

// make stomp a bit better for bots
local function StompEnemies(self)
    
    local enemyTeamNum = GetEnemyTeamNumber(self:GetTeamNumber())
    local stompOrigin = self:GetOrigin()

    for index, ent in ipairs(GetEntitiesWithMixinForTeamWithinRange("Stun", enemyTeamNum, stompOrigin, 5)) do
    
        if math.abs(ent:GetOrigin().y - stompOrigin.y) < self:GetAttackDistanceOverride() + 1 then
            ent:SetStun(kDisruptMarineTime)
        end
        
    end
    return false
end


function NpcOnosMixin:__initmixin() 
    // can use stomp    
    self.twoHives = true 
    self.threeHives = true 
end


// run to the enemy if near and see it
function NpcOnosMixin:AiSpecialLogic(deltaTime)
    local order = self:GetCurrentOrder()
    if order then
        if self.target and self:GetTarget() then            
        
            if GetCanSeeEntity(self, self:GetTarget()) then
                local distance = (self:GetOrigin() - self:GetTarget():GetOrigin()):GetLengthXZ() 
                if (distance > 6 or self.nextSprintStop) then
            
                    // only random
                    if not self.nextSprintStop and math.random(1, 100) < 10 then
                        self.nextSprintStop = Shared.GetTime() + 3 
                    end
                    
                    if self.nextSprintStop then
                        if Shared.GetTime() < self.nextSprintStop then
                            self:PressButton(Move.MovementModifier) 
                        else    
                            self.sprintStop = nil
                        end
                    end   
                    
                end
                
                if (distance <= self:GetAttackDistanceOverride() + 1) then
                    if math.random(1, 100) < 5 then
                        self:PressButton(Move.SecondaryAttack) 
                        self:AddTimedCallback(StompEnemies, 1)
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





