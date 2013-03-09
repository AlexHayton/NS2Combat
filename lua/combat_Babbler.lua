//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

local originalOnUpdate = Babbler.OnUpdate
function Babbler:OnUpdate(deltaTime)
    originalOnUpdate(self, deltaTime)
    // check if the owner is still a gorge
    if self.ownerId then
        local owner = Shared.GetEntity(self.ownerId)
        if owner then
            if not owner:isa("Gorge") then
                // start a timer, if the player is still no gorge when the timer is 0, kill the hydras
                if not self.killTime then
                    self.killTime = Shared.GetTime() + kHydraKillTime
                end
                
                if Shared.GetTime() >= self.killTime then
                    self:Kill()
                end
                
            else
                self.killTime = nil
            end 
        else
            self:Kill()
        end   
    end    
end

local originalOnKill = Babbler.OnKill
function Babbler:OnKill(attacker, doer, point, direction)
    // Give XP to killer.
    local pointOwner = attacker
    
    // If the pointOwner is not a player, award it's points to it's owner.
    if pointOwner ~= nil and not HasMixin(pointOwner, "Scoring") and pointOwner.GetOwner then
        pointOwner = pointOwner:GetOwner()
    end    
        
    // Give Xp for Players - only when on opposing sides.
    // to fix a bug, check before if the pointOwner is a Player
   if pointOwner and pointOwner:isa("Player") then
        if(pointOwner:GetTeamNumber() ~= self:GetTeamNumber()) then
			// Only add Xp if killing a player or player structure. Structures now get partial Xp for damage.
			if not GetTrickleXp(self) then
				local XpValue = GetXpValue(self)
				pointOwner:AddXp(XpValue)
				pointOwner:GiveXpMatesNearby(XpValue)
			end			
        end
    end
    originalOnKill(self)    
end