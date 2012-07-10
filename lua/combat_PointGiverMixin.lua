//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_PointGiverMixin.lua


// Could not be hooked cause no Class is created anymore, but with this it's just getting replaced

function PointGiverMixin:OnKill(attacker, doer, point, direction)

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
		
			local XpValue = GetXpValue(self)
			pointOwner:AddXp(XpValue)
			// Add Xp to mates if the dead thing is a player.
			if self:isa("Player") then
				pointOwner:GiveXpMatesNearby(XpValue)
			end
			
        end
    end    

end
