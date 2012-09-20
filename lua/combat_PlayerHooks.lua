//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_PlayerHooks.lua

local HotReload = CombatPlayer
if(not HotReload) then
  CombatPlayer = {}
  ClassHooker:Mixin("CombatPlayer")
end
    
function CombatPlayer:OnLoad()
   
    ClassHooker:SetClassCreatedIn("Player", "lua/Player.lua") 
    self:PostHookClassFunction("Player", "Reset", "Reset_Hook")
    self:PostHookClassFunction("Player", "CopyPlayerDataFrom", "CopyPlayerDataFrom_Hook") 
	self:ReplaceClassFunction("Player", "GetTechTree", "GetTechTree_Hook") 
	self:PostHookClassFunction("Player", "OnUpdatePlayer", "OnUpdatePlayer_Hook")
	self:PostHookClassFunction("Player", "Taunt", "Taunt_Hook")
	self:PostHookClassFunction("Player", "OnCreate", "OnCreate_Hook")
	self:PostHookClassFunction("Player", "UpdateArmorAmount", "UpdateArmorAmount_Hook")

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
	self:AddTimedCallback(CombatHandleUpgradeNotifications, kCombatUpgradeNotifyInterval)
	self:AddTimedCallback(CombatHandleNewPlayerReminder, kCombatReminderNotifyInterval)
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

function CombatHandleUpgradeNotifications(self)

	// don't remind players in the ReadyRoom
	if (self:GetTeamNumber() ~= kTeamReadyRoom) and (self:GetTeamNumber() ~= kSpectatorIndex) then
	    
        // Remind players once every so often when they have upgrades to spend.        
        local lvlFree = self:GetLvlFree()
        if lvlFree > 0 then
            self:spendlvlHints("freeLvl")
        end

	end
	
	return true
	
end

function CombatHandleNewPlayerReminder(self)

	// If the player hasn't spent their upgrades at all, remind them again
	// that this is combat mode after a longer interval.
	self:CheckCombatData()
	if (self:GetLvl() - 1) + kCombatStartUpgradePoints == self:GetLvlFree() then
		if (Shared.GetTime() - self.lastReminderNotify > kCombatReminderNotifyInterval) then
			self.combatTable.lastReminderNotify = Shared.GetTime()
			for i, message in ipairs(combatWelcomeMessage) do
				self:SendDirectMessage(message)  
			end	
		end
	end
	
	return true
	
end

// Various updates and timers in here.
function CombatPlayer:OnUpdatePlayer_Hook(self, deltaTime)
            
	// set ArmsLab always true so the up icons are white and not red	    
	self.hasArmsLab = true
		
	// Spawn Protect
	self:CheckCombatData()
	if self.combatTable.activeSpawnProtect then
	
		if self:GetIsAlive() and (self:GetTeamNumber() == 1 or self:GetTeamNumber() == 2) then
		
			if not self.combatTable.deactivateSpawnProtect then
				// set the real spawn protect time here
				self.combatTable.deactivateSpawnProtect = Shared.GetTime() +  kCombatMarineSpawnProtectTime
			elseif Shared.GetTime() >= self.combatTable.deactivateSpawnProtect then
				// end spawn protect
				self:DeactivateSpawnProtect()
			else
				if not self.gotSpawnProtect then
				self:PerformSpawnProtect()
				end
			end
		end
		
	end
	
	if self.combatTable then
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
end

function CombatPlayer:Taunt_Hook(self)

   self:ProcessTauntAbilities()
    
end

function CombatPlayer:UpdateArmorAmount_Hook(self)

	// Always set the hives back to false, so that later on we can enable tier 2/3 even after embryo.
	if (self:isa("Alien") and self:GetTeamNumber() ~= kTeamReadyRoom) then
		self.twoHives = false
		self.threeHives = false
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