//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_StaticTarget.lua

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
				local dmgXp = math.floor(maxXp * damage / self:GetMaxHealth())
				// Always enforce a minimum Xp of 1.				
				if dmgXp == 0 then 
					dmgXp = 1
				end
				
				// Award XP but suppress the message.
				pointOwner:AddXp(dmgXp, true)
			end
		end
	end
    
end