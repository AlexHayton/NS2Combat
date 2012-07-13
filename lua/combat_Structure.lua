//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Structure.lua

local HotReload = CombatStructure
if(not HotReload) then
  CombatStructure = {}
end

ClassHooker:Mixin("CombatStructure")
    
function CombatStructure:OnLoad()
    
    ClassHooker:SetClassCreatedIn("Structure", "lua/Structure.lua") 
    self:PostHookClassFunction("Structure", "OnTakeDamage", "OnTakeDamage_Hook") 
    
end

// Give some XP to the damaging entity.
function CombatStructure:OnTakeDamage_Hook(self, damage, attacker, doer, point)

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
				
				// Award XP but suppress the message.
				pointOwner:AddXp(dmgXp, true)
			end
		end
	end
    
end

CombatStructure:OnLoad()