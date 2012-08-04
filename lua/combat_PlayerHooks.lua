//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
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
	self:PostHookClassFunction("Player", "Taunt", "Taunt_Hook")

    self:ReplaceFunction("GetIsTechAvailable", "GetIsTechAvailable_Hook")
    self:ReplaceClassFunction("Alien", "LockTierTwo",function() end)
    self:ReplaceClassFunction("Alien", "UpdateNumHives","UpdateNumHives_Hook")
    
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
	self.twoHives = player.twoHives
	self.threeHives = player.threeHives

	// For marines, give tech upgrades so that the new player has the right armor etc.
	if (self:isa("Marine") and self:GetTeamNumber() ~= kTeamReadyRoom) then
		self:ApplyAllUpgrades({ kCombatUpgradeTypes.Tech })
	end
	
end

function CombatPlayer:GetTechTree_Hook(self)

	self:CheckCombatData()
	
    return self.combatTechTree

end

// Various updates and timers in here.
function CombatPlayer:OnUpdatePlayer_Hook(self, deltaTime)
	
	// don't remind players in the ReadyRoom
	if (self:GetTeamNumber() ~= kTeamReadyRoom) and (self:GetTeamNumber() ~= kSpectatorIndex) then
	    // set ArmsLab always true so the up icons are white and not red	    
	    self.hasArmsLab = true
	    
        // Remind players once every so often when they have upgrades to spend.        
        local lvlFree = self:GetLvlFree()
        if lvlFree > 0 then
            if (self.combatTable.lastUpgradeNotify + deltaTime > kUpgradeNotifyInterval) then
                self.combatTable.lastUpgradeNotify = 0
                self:spendlvlHints("freeLvl")
            else
                self.combatTable.lastUpgradeNotify = self.combatTable.lastUpgradeNotify + deltaTime
            end
        end
		
		// If the player hasn't spent their upgrades at all, remind them again
		// that this is combat mode after a longer interval.
        if (self:GetLvl() - 1) + kCombatStartUpgradePoints == self:GetLvlFree() then
            if (self.combatTable.lastReminderNotify + deltaTime > kReminderNotifyInterval) then
                self.combatTable.lastReminderNotify = 0
				for i, message in ipairs(combatWelcomeMessage) do
					self:SendDirectMessage(message)  
				end	
            else
                self.combatTable.lastReminderNotify = self.combatTable.lastReminderNotify + deltaTime
            end
        end
        
        // Spawn Protect
        if self.combatSpawnProtect then
            if self:GetIsAlive() then
                if self.combatSpawnProtect == 1 then
                    // set the real spawn protect time here
                    self.combatSpawnProtect = Shared.GetTime() +  kCombatSpawnProtectTime
                elseif
                    Shared.GetTime() >= self.combatSpawnProtect then
                    // end spawn protect
                    self:DeactivateSpawnProtect()
                else
                    self:PerformSpawnProtect()
                end
            end
        end
        
        if self.combatTable then
            // only trigger Scan and Ressuply when player is alive
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
                    if (self.combatTable.lastScan + deltaTime > kScanTimer) then
                        
                        local success = self:ScanNow()
                        
                        if success then
                            self.combatTable.lastScan = 0	            
                        end
                        
                    else
                        self.combatTable.lastScan = self.combatTable.lastScan + deltaTime
                    end
                end 
                
                if self.combatTable.hasResupply then
                    if (self.combatTable.lastResupply + deltaTime > kResupplyTimer) then
                        
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
end


function CombatPlayer:Taunt_Hook(self)

    if self.combatTable then
        if self.combatTable.hasEMP then
            if  self.combatTable.lastEMP == 0 or Shared.GetTime() > ( self.combatTable.lastEMP + kEMPTimer) then
                self:EMPBlast()
                self.combatTable.lastEMP = Shared.GetTime()
            else
                local timeReady = math.ceil(self.combatTable.lastEMP + kEMPTimer - Shared.GetTime())
                self:SendDirectMessage("EMP-taunt is not ready, wait " .. timeReady .. " sec")
            end    
        elseif self.combatTable.hasInk then
            if  self.combatTable.lastInk == 0 or Shared.GetTime() > ( self.combatTable.lastInk + kInkTimer) then
                self:TriggerInk()
                self.combatTable.lastInk = Shared.GetTime()
            else
                local timeReady = math.ceil(self.combatTable.lastInk + kInkTimer - Shared.GetTime())
                self:SendDirectMessage("Ink-taunt is not ready, wait " .. timeReady .. " sec")
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

function CombatPlayer:UpdateNumHives_Hook(self)

    local time = Shared.GetTime()
    if self.timeOfLastNumHivesUpdate == nil or (time > self.timeOfLastNumHivesUpdate + .5) then

        if self.twoHives then
            self:UnlockTierTwo()   
        end
        
        if self.threeHives then
            self:UnlockTierThree()
        end
        
        self.timeOfLastNumHivesUpdate = time
        
    end
end


if(hotreload) then
    CombatPlayer:OnLoad()
end