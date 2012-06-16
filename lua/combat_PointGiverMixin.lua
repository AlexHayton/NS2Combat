//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_PointGiverMixin.lua

if(not CombatPointGiverMixin) then
  CombatPointGiverMixin = {}
end

local HotReload = ClassHooker:Mixin("CombatPointGiverMixin")

function CombatPointGiverMixin:OnLoad()

    ClassHooker:SetClassCreatedIn("PointGiverMixin", "lua/PointGiverMixin.lua")
    self:PostHookClassFunction("PointGiverMixin", "OnKill", "OnKill_Hook")
	
end

function CombatPointGiverMixin:OnKill_Hook(self, damage, attacker, doer, point, direction)

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

if(HotReload) then
    CombatPointGiverMixin:OnLoad()
end