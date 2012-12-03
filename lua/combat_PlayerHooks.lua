//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_PlayerHooks.lua

  CombatPlayer = CombatPlayer or {}
  ClassHooker:Mixin("CombatPlayer")

    
function CombatPlayer:OnLoad()
   
    ClassHooker:SetClassCreatedIn("Player", "lua/Player.lua") 
    self:PostHookClassFunction("Player", "Reset", "Reset_Hook")
    self:PostHookClassFunction("Player", "CopyPlayerDataFrom", "CopyPlayerDataFrom_Hook") 
	self:ReplaceClassFunction("Player", "GetTechTree", "GetTechTree_Hook") 
	self:PostHookClassFunction("Player", "OnUpdatePlayer", "OnUpdatePlayer_Hook")
	self:PostHookClassFunction("Player", "OnCreate", "OnCreate_Hook")
	self:PostHookClassFunction("Player", "UpdateArmorAmount", "UpdateArmorAmount_Hook")
	self:PostHookClassFunction("Player", "GetCanTakeDamageOverride", "GetCanTakeDamageOverride_Hook"):SetPassHandle(true)
	self:PostHookClassFunction("Player", "AdjustMove", "AdjustMove_Hook")

    self:ReplaceFunction("GetIsTechAvailable", "GetIsTechAvailable_Hook")
    
end


// Implement lvl and XP
function CombatPlayer:Reset_Hook(self)
  
	// don't initialise the Combat Data !!! we need to reset it
	self.combatTable = {} 

	// that we don't have to write everything in 3 different functions
	self:Reset_Lite() 

	self.combatTable.lvl = 1
	self:AddLvlFree(kCombatStartUpgradePoints)
	
	// getAvgXP is called before giving the score, so this needs to be implemented here
	self.score = 0
	    
end

// Copy old lvl and XP when respawning 
function CombatPlayer:CopyPlayerDataFrom_Hook(self, player)    

	self.combatTable = player.combatTable

	// For marines, give tech upgrades so that the new player has the right armor etc.
	if (self:isa("Marine") or self:isa("Exo")) and (self:GetTeamNumber() ~= kTeamReadyRoom) then
		self:ApplyAllUpgrades({ kCombatUpgradeTypes.Tech })
	end
	
end

function CombatPlayer:GetTechTree_Hook(self)

	self:CheckCombatData()
	
    return self.combatTechTree

end

function CombatPlayer:OnCreate_Hook(self)

	// Set up the timers for repetitive check events.
	// This should improve performance somewhat as well.
	self:AddTimedCallback(CombatHandleQueuedMessages, 1)
	self.lastReminderNotify = Shared.GetTime()

end

function CombatHandleQueuedMessages(self)

	// Handle queued direct messages.
	if (self.directMessagesActive ~= nil and self.directMessagesActive > 0) then
		if (Shared.GetTime() - self.timeOfLastDirectMessage > kDirectMessageFadeTime) then
		
			// After the fade time has passed, clear old messages from the queue.
			for msgIndex = 1, math.min(self.directMessagesActive, kDirectMessagesNumVisible) do
				self.directMessagesActive = self.directMessagesActive - 1
			end
			
			// Send any waiting messages, up to kDirectMessagesNumVisible.
			if (#self.directMessageQueue > 0) then
				for msgIndex = 1, math.min(#self.directMessageQueue, kDirectMessagesNumVisible) do
					local message = table.remove(self.directMessageQueue, 1)
					self:BuildAndSendDirectMessage(message)
				end
				
				self.timeOfLastDirectMessage = Shared.GetTime()
			end
			
		end
	end
	
	return true
	
end

// Various updates and timers in here.
function CombatPlayer:OnUpdatePlayer_Hook(self, deltaTime)
		
	// Spawn Protect
	self:CheckCombatData()
	if self.combatTable.activeSpawnProtect then
	
		if self:GetIsAlive() and (self:GetTeamNumber() == 1 or self:GetTeamNumber() == 2) then
		
			if not self.combatTable.deactivateSpawnProtect then
				// set the real spawn protect time here
				self.combatTable.deactivateSpawnProtect = Shared.GetTime() +  kCombatMarineSpawnProtectTime
			end
			
			if Shared.GetTime() >= self.combatTable.deactivateSpawnProtect then
				// end spawn protect
				self:DeactivateSpawnProtect()
			else
				if not self.gotSpawnProtect then
					self:PerformSpawnProtect()
				end
			end
		end
		
	end
	
	// Putting this here to try and fix the giving xp on join.
	// Also helps us write the xp balancing function later.
	if self:GetIsPlaying() then
		if self.combatTable.setAvgXp then
			local avgXp = Experience_GetAvgXp(self)
			// Send the avg as a message to the player (%d doesn't work with SendDirectMessage)
			self:BalanceXp(avgXp)
			
			// Reset the average Xp flag.
			self.combatTable.setAvgXp = false
		end
	end
	
	// only trigger Scan and Resupply when player is alive
	if self:GetIsAlive() then

		if self.combatTable.hasCamouflage then
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

		// Provide scan and resupply function
		if self.combatTable.hasScan then
			// SCAN!!
			if (self.combatTable.lastScan + deltaTime >= kScanTimer) then
				
				local success = self:ScanNow()
				
				if success then
					self.combatTable.lastScan = 0	            
				end
				
			else
				self.combatTable.lastScan = self.combatTable.lastScan + deltaTime
			end
		end 
		
		if self.combatTable.hasResupply then
			if (self.combatTable.lastResupply + deltaTime >= kResupplyTimer) then
				
				// Keep the timer going, even if we don't need to resupply.
				local success = false
				if (self:NeedsResupply()) then
					success = self:ResupplyNow()
				else
					success = true
				end
				
				if success then
					self.combatTable.lastResupply = 0
				end
			   
			else
				self.combatTable.lastResupply = self.combatTable.lastResupply + deltaTime
			end
	
		end 
    end
end

function CombatPlayer:UpdateArmorAmount_Hook(self)

	// Always set the hives back to false, so that later on we can enable tier 2/3 even after embryo.
	if (self:isa("Alien") and self:GetTeamNumber() ~= kTeamReadyRoom) then
		self.twoHives = false
		self.threeHives = false
	end

end

function CombatPlayer:GetCanTakeDamageOverride_Hook(handle, self)

	local canTakeDamage = handle:GetReturn() and not self.gotSpawnProtect	
	handle:SetReturn(canTakeDamage)

end

function CombatPlayer:AdjustMove_Hook(self)

	if self.combatTable.lastTauntTime == nil then
		self.combatTable.lastTauntTime = 0
	end

	// Allow child classes to affect how much input is allowed at any time
	if self.mode == kPlayerMode.Taunt and Shared.GetTime() - self.combatTable.lastTauntTime > kCombatTauntCheckInterval then
		ProcessTauntAbilities()
		self.combatTable.lastTauntTime = Shared.GetTime()
	end

end

//___________________
// Hooks Alien_Upgrade
//___________________

// Hook GetIsTechAvailable so Aliens can get Ups Like cara, cele etc.
function CombatPlayer:GetIsTechAvailable_Hook(self, teamNumber, techId)

    return true

end

if (not HotReload) then
	CombatPlayer:OnLoad()
end