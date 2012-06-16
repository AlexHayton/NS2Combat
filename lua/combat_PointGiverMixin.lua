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
   if pointOwner and (pointOwner:GetTeamNumber() ~= self:GetTeamNumber()) then
        if self:isa("Player") then
                if self.combatTable then
                    pointOwner:AddXp(XpList[self.combatTable.lvl]["GivenXP"])
                else
                    // if enemy dont got a combatTable, get standard Value for Lvl 1
                    pointOwner:AddXp(XpList[1]["GivenXP"])
                end
        else    
		
			// Give XP for killing structures
            pointOwner:AddXp(XpValues[self:GetClassName()])
        end
    end    

end
