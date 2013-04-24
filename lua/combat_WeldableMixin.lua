//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_WeldableMixin.lua

local function setDecimalPlaces(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult) / mult
    else return math.ceil(num * mult) / mult end
end


// Give some XP to the damaging entity.
function WeldableMixin:OnWeld(doer, elapsedTime, player)

    if self:GetCanBeWelded(doer) then
    
    	if self:isa("Structure") and GetHasTimeLimitPassed() then
    	 // No effect!
        elseif self.OnWeldOverride then
            self:OnWeldOverride(doer, elapsedTime)
        elseif doer:isa("MAC") then
            self:AddHealth(MAC.kRepairHealthPerSecond * elapsedTime)
        elseif doer:isa("Welder") then
            self:AddHealth(doer:GetRepairRate(self) * elapsedTime)
			
			local maxXp = GetXpValue(self)
			
			local healXp = 0
			if self:isa("Player") then
				healXp = setDecimalPlaces(maxXp * kPlayerHealXpRate * kHealXpRate * doer:GetRepairRate(self) * elapsedTime / self:GetMaxHealth(), 1)
			else
				healXp = setDecimalPlaces(maxXp * kHealXpRate * doer:GetRepairRate(self) * elapsedTime / self:GetMaxHealth(), 1)
			end
				
			// Award XP.
			local doerPlayer = doer:GetParent()
			doerPlayer:AddXp(healXp)
        end
		
		if player and player.OnWeldTarget then
            player:OnWeldTarget(self)
        end
        
    end
    
end