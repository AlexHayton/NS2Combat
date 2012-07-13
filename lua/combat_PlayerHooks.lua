//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_PlayerHooks.lua

local HotReload = CombatPlayer
if(not HotReload) then
  CombatPlayer = {}
end

local HotReload = ClassHooker:Mixin("CombatPlayer")
    
function CombatPlayer:OnLoad()
   
    ClassHooker:SetClassCreatedIn("Player", "lua/Player.lua") 
    self:PostHookClassFunction("Player", "Reset", "Reset_Hook")
    self:PostHookClassFunction("Player", "CopyPlayerDataFrom", "CopyPlayerDataFrom_Hook") 
	self:ReplaceClassFunction("Player", "GetTechTree", "GetTechTree_Hook") 
	self:PostHookClassFunction("Player", "OnUpdatePlayer", "OnUpdatePlayer_Hook")

    self:ReplaceFunction("GetIsTechAvailable", "GetIsTechAvailable_Hook")
    self:ReplaceClassFunction("Alien", "LockTierTwo",function() end)
    self:ReplaceClassFunction("Alien", "UpdateNumHives","UpdateNumHives_Hook")
    
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
	
	self.twoHives = false
	self.threeHives = false

    // scan and resupp values	
    self.combatTable.hasScan = false
    self.combatTable.lastScan = 0

    self.combatTable.hasResupply = false
    self.combatTable.lastResupply = 0
    
    self.combatTable.giveClassAfterRespawn = nil
	
	// getAvgXP is called before giving the score, so this needs to be implemented here
	self.score = 0
	
	self.combatTable.techtree = {}
	Server.SendNetworkMessage(self, "ClearTechTree", {}, true)
	self:SendUpgrades()
	    
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
	if (self:GetTeamNumber() ~= kTeamReadyRoom) then
	    // set ArmsLab always true so the up icons are white and not red	    
	    self.hasArmsLab = true
	    
        // Remind players once every so often when they have upgrades to spend.        
        local lvlFree = self:GetLvlFree()
        if lvlFree > 0 then
            if (self.combatTable.lastNotify + deltaTime > kUpgradeNotifyInterval) then
                self.combatTable.lastNotify = 0
                self:spendlvlHints("freeLvl")
            else
                self.combatTable.lastNotify = self.combatTable.lastNotify + deltaTime
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
                                    
                        local success = self:ResupplyNow()
                        
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

CombatPlayer:OnLoad()
