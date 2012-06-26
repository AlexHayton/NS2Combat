//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_PlayerHooks.lua

if(not CombatPlayer) then
    CombatPlayer = {}
end


local HotReload = ClassHooker:Mixin("CombatPlayer")
    
function CombatPlayer:OnLoad()
   
    ClassHooker:SetClassCreatedIn("Player", "lua/Player.lua") 
    self:PostHookClassFunction("Player", "Reset", "Reset_Hook")
    self:PostHookClassFunction("Player", "CopyPlayerDataFrom", "CopyPlayerDataFrom_Hook") 
	self:ReplaceClassFunction("Player", "GetTechTree", "GetTechTree_Hook") 
	self:PostHookClassFunction("Player", "OnUpdatePlayer", "OnUpdatePlayer_Hook") 
	self:PostHookClassFunction("Player", "UpdateSharedMisc", "UpdateSharedMisc_Hook") 

    self:ReplaceFunction("GetIsTechAvailable", "GetIsTechAvailable_Hook")
    
end

// Implement lvl and XP
function CombatPlayer:Reset_Hook(self)
  
	// don't initialise the Combat Data !!! we need to reset it
        self.combatTable = {}  
		self.combatTable.lvl = 1
		self:ClearLvlFree()
		self:AddLvlFree(1)
		self.combatTable.lastNotify = 0
		self.combatTable.hasCamouflage = false
		
		// getAvgXP is called before giving the score, so this needs to be implemented here
		self.score = 0
		
		self.combatTable.techtree = {}
    
end

// Copy old lvl and XP when respawning 
function CombatPlayer:CopyPlayerDataFrom_Hook(self, player)    

	self.combatTable = player.combatTable

	// Give the ups back, but just when respawing
	if player and player.isRespawning then
		  self:GiveUpsBack()
	end
    
end

function CombatPlayer:GetTechTree_Hook(self)

	self:CheckCombatData()
	
    return self.combatTechTree

end

// Various updates and timers in here.
function CombatPlayer:OnUpdatePlayer_Hook(self, deltaTime)
	
	// Remind players once every so often when they have upgrades to spend.
	local lvlFree = self:GetLvlFree()
	if lvlFree > 0 then
		if (self.combatTable.lastNotify + deltaTime > kUpgradeNotifyInterval) then
			self.combatTable.lastNotify = 0
			local upgradeWord = (lvlFree > 1) and "upgrades" or "upgrade"
			self:SendDirectMessage("You have " .. lvlFree .. " " .. upgradeWord .. " to spend. Use co_spendlvl in chat to buy upgrades.")
		else
			self.combatTable.lastNotify = self.combatTable.lastNotify + deltaTime
		end
	end
	
	// Provide a camouflage function
	if self.combatTable and self.combatTable.hasCamouflage then
		if HasMixin(self, "Cloakable") then
			self:SetIsCloaked(true, 1, false)
	
			// Trigger uncloak when you reach a certain speed, based on lifeform's max speed.
			local velocity = self:GetVelocity():GetLength()
			
			if velocity >= (self:GetMaxSpeed(true) * kCamouflageUncloakFactor) then
				self:SetIsCloaked(false)
				self.cloakChargeTime = kCamouflageTime
			end
		end
	end
	
end

//___________________
// Hooks Alien_Upgrade
//___________________

// Hook GetIsTechAvailable so Aliens can get Ups Like cara, cele etc.
function CombatPlayer:GetIsTechAvailable_Hook(self, teamNumber, techId)

    return true

end

// Provide a camouflage function
function CombatPlayer:UpdateSharedMisc_Hook(self, input)

	// Do nothing

end

if(hotreload) then
    CombatPlayer:OnLoad()
end