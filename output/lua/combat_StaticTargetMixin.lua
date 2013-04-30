//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_StaticTargetMixin.lua

local function setDecimalPlaces(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult) / mult
    else return math.ceil(num * mult) / mult end
end

// Give some XP to the damaging entity.
function StaticTargetMixin:OnTakeDamage(damage, attacker, doer, point)

    // Give XP to attacker.
    local pointOwner = attacker
    
    // If the pointOwner is not a player, award it's points to it's owner.
    if pointOwner ~= nil and not HasMixin(pointOwner, "Scoring") and pointOwner.GetOwner then
        pointOwner = pointOwner:GetOwner()
    end
	
	// Give Xp for Players - only when on opposing sides.
    // to fix a bug, check before if the pointOwner is a Player
	if pointOwner and pointOwner:isa("Player") then
		if(pointOwner:GetTeamNumber() ~= self:GetTeamNumber()) then
			if GetTrickleXp(self) then
				local maxXp = GetXpValue(self)
				local dmgXp = setDecimalPlaces(maxXp * damage / self:GetMaxHealth(), 1)
				
				// Award XP
				pointOwner:AddXp(dmgXp)
			end
		end
	end
    
end