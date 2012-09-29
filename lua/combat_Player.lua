//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Player.lua

// Load the Upgrade functions too...
Script.Load("lua/combat_Player_Upgrades.lua")

//___________________
// New functions,
// not hooked
//___________________


// check for FastReload

function Player:GotFastReload()
    
    local fastReload = false
    
    if self.combatTable.hasFastReload then
        fastReload = true
    end
    
    return fastReload

end

// check focus upgrade and weapon

function Player:GotFocus()

    local gotFocus = false
    
    // disabled for onos due to bugs
    if self.combatTable.hasFocus then
        // check the weapon
        local activeWeapon = self:GetActiveWeapon()
        if activeWeapon then
            // only give focus when primary attacking, every weapon has itsn own attribute so its a bit dirty, but it works
            // there is a primaryAttacking on every weapon, but only on bite its getting true
            if (activeWeapon.primaryAttacking == true or activeWeapon.firingPrimary == true or activeWeapon.attacking == true or activeWeapon.attackButtonPressed == true) then
                local hudSlot = activeWeapon.GetHUDSlot()                
                if hudSlot == 1 then
                    gotFocus = true 
                end 
            end 
  
        end
   
    end
    
    
    return gotFocus
end


// function for spawn protect

function Player:SetSpawnProtect()

    self.combatTable.activeSpawnProtect = true
	self.combatTable.deactivateSpawnProtect = nil
    
end

function Player:DeactivateSpawnProtect()

    self:SetHealth( self:GetMaxHealth() )
    self:SetArmor( self:GetMaxArmor() )

    self.combatTable.activeSpawnProtect = nil
    self.gotSpawnProtect = nil
    
    if self.combatNanoShieldEnt then
        DestroyEntity(self.combatNanoShieldEnt)
    end
    
    self.combatNanoShieldEnt = nil
	
end

function Player:PerformSpawnProtect()

    self:SetHealth(10000)
    self:SetArmor(10000)
        
    // only make the effects once
    if not self.gotSpawnProtect then
        
        if self:isa("Marine") then
        
            local nanoShield = CreateEntity(NanoShield.kMapName, self:GetOrigin(), self:GetTeamNumber())
            nanoShield:SetParent(self)
            self:ActivateNanoShield()
            self.combatNanoShieldEnt = nanoShield
			
        elseif self:isa("Alien") then
		
			local spawnProtectTimeLeft = self.combatTable.deactivateSpawnProtect - Shared.GetTime()
            //self:TriggerCatalyst(spawnProtectTimeLeft)
            self:SetHasUmbra(true, spawnProtectTimeLeft)       

        end
     
        self.gotSpawnProtect = true
		
    end    
	
 end


// Resup and Scan function

function Player:ScanNow()

    local position = self:GetOrigin()
    
    CreateEntity(Scan.kMapName, position, self:GetTeamNumber())
    StartSoundEffectAtOrigin(Observatory.kScanSound, position)  

    return true
    
end

function Player:NeedsResupply()
	
    // Ammo packs give ammo to clip as well (so pass true to GetNeedsAmmo())
    // check every weapon the player got
    local weapon = self:GetActiveWeapon()
    local needsHealth = not GetIsVortexed(self) and self:GetHealth() < self:GetMaxHealth()
    local needsAmmo = false

    for i = 0, self:GetNumChildren() - 1 do
    
        local child = self:GetChildAtIndex(i)
        if child:isa("ClipWeapon") then
            
            needsAmmo = child ~= nil and child:GetNeedsAmmo(false) and not GetIsVortexed(self)
            if needsAmmo then
                break
            end      
                
        end
        
    end
        
	return needsAmmo or needsHealth

end

function Player:ResupplyNow()

    local success = false
    local mapNameHealth = LookupTechData(kTechId.MedPack, kTechDataMapName) 
    local position = self:GetOrigin()

	if (mapNameHealth) then
    
		local droppackHealth = CreateEntity(mapNameHealth, position, self:GetTeamNumber())
		// dont drop a ammo pack, give ammo via a new function
		self:GiveAllAmmo()
		
		StartSoundEffectAtOrigin(MedPack.kHealthSound, self:GetOrigin())
		success = true
		
		//Destroy them so they can't be used by somebody else (if they are unused)
		DestroyEntity(droppackHealth)		
	end

    return success

end

function Player:GiveAllAmmo()

    for i = 0, self:GetNumChildren() - 1 do

        local child = self:GetChildAtIndex(i)
        if child:isa("ClipWeapon") then
            
            if child:GetNeedsAmmo(false) then
                child:GiveAmmo(AmmoPack.kNumClips, false)
            end
                
        end
        
    end

    StartSoundEffectAtOrigin(AmmoPack.kPickupSound, self:GetOrigin())

end

function Player:CatalystNow()
	
	local success = false
	local globalSound = CatPack.kPickupSound
	local localSound = "sound/NS2.fev/marine/common/mine_warmup"
	
	// Use one sound for global, another for local player to give more of an effect!
	StartSoundEffectAtOrigin(globalSound, self:GetOrigin())
	StartSoundEffectForPlayer(localSound, self)  
	self:ApplyCatPack()
	success = true
    self:SendDirectMessage("You got now catalyst for " .. CatPack.kDuration .. " sec!")
    return success

end

function Player:CheckCatalyst()
	
	local timeNow = Shared.GetTime()

    if self.combatTable.hasCatalyst then
        
        if (self.combatTable.lastCatalyst == 0) or (timeNow - self.combatTable.lastCatalyst >= kCatalystTimer) then            
            local success = self:CatalystNow()            
            if success then
                self.combatTable.lastCatalyst = timeNow
            end           
        end

    end 

end

function Player:EMPBlast()

    local empBlast = CreateEntity(EMPBlast.kMapName, self:GetOrigin(), self:GetTeamNumber())
        
end


function Player:TriggerInk()

    // Create ShadeInk entity in world at this position with a small offset
    CreateEntity(ShadeInk.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())

end


function Player:GetXp()
    if self.score then
        return self.score
    else
        return 0    
    end         
end

function Player:GetLvl()
    if self.combatTable then
        return Experience_GetLvl(self:GetXp())
    else
        return 1
    end
end

function Player:GetLvlFree()

    if self.combatTable then
        return self.resources
    else
        return 0
    end

end

function Player:AddLvlFree(amount)
        
	if amount == nil then
		amount = 1
	end
	
	self.resources = self.resources + amount

end

function Player:SubtractLvlFree(amount)

	if amount == nil then
		amount = 1
	end
	
	self.resources = self.resources - amount
	
	if self.resources < 0 then 
        self.resources = 0
    end

end

function Player:ClearLvlFree()

	self.resources = 0

end

function Player:GetCombatTechTree()

	return self.combatTable.techtree
	
end

function Player:ClearCombatData()

	// Blow away the old combatTable amd combatTechTree then re-run the check
	self.combatTable = nil
	self.combatTechTree = nil
	self:CheckCombatData()

end

function Player:CheckCombatData()

	// Initialise the Combat Tech Tree
	if not self.combatTable then
		self:Reset()
	end
	
	if not self.combatTechTree then
			
		// Also create a personal version of the tech tree.
	    local team = self:GetTeam()
		if team ~= nil and team:isa("PlayingTeam") then
			self.combatTechTree = TechTree()
			self.combatTechTree:CopyDataFrom(team:GetTechTree())
			self.combatTechTree:ComputeAvailability()
			self.sendTechTreeBase = true
		end
	
	end

end

function Player:UpdateTechTree()

    self:CheckCombatData()
	
	if self.combatTechTree then
		self.combatTechTree:Update({})
	end
	
end

function Player:AddXp(amount, suppressmessage)
	
    self:CheckCombatData()
	//self:TriggerEffects("issueOrderSounds")
	
	// check if amount isn't nil, could cause an error
	if amount and amount > 0 then
		if (amount > 10) then
			self:TriggerEffects("res_received")
		end
	
        // Make sure we don't go over the max XP.
        if (self:GetXp() + amount) > maxXp and not suppressmessage then
				self:SendDirectMessage("Max-XP reached")
		end
		
		// show the cool effect, no direct Message is needed anymore
		self:XpEffect(amount)
		self:CheckLvlUp(self.score, suppressmessage) 
		self:SetScoreboardChanged(true)
    end   
end

// Give XP to m8's around you when you kill an enemy
function Player:GiveXpMatesNearby(xp)

    xp = xp * mateXpAmount

    local playersInRange = GetEntitiesForTeamWithinRange("Player", self:GetTeamNumber(), self:GetOrigin(), mateXpRange)
    
	// Only give Xp to players who are alive!
    for _, player in ipairs(playersInRange) do
        if self ~= player and player:GetIsAlive() then
            player:AddXp(xp)    
        end
    end

end

// cool effect for getting xp, also showing a new Lvl
function Player:XpEffect(xp, lvl)

    // Should only be called on the Server.
    if Server then
    
        if xp ~= nil and xp ~= 0 then
        
            self.score = Clamp(self.score + xp, 0, self:GetMixinConstants().kMaxScore or 100)
            local lastXpEffect = self.combatTable.lastXpEffect  
            // dont spam the player with xpeffects            
            if lastXpEffect == 0 or Shared.GetTime() >= ( lastXpEffect + kXPEffectTimer) then 
 
                // show also old xp award, but forget it after some time
                if self.combatTable.lastXpAmount > 0 and Shared.GetTime() < ( lastXpEffect + kXPForgetimer) then                            
                    xp = xp + self.combatTable.lastXpAmount  
                end      
           
                Server.SendCommand(self, string.format("points %s %s", tostring(xp), tostring(0)))                
                self.combatTable.lastXpEffect = Shared.GetTime() 
                self.combatTable.lastXpAmount = 0                        
            else
                // save the last XpAmount and sum it
                self.combatTable.lastXpAmount = self.combatTable.lastXpAmount + xp
            end
 
            
        end

    
    end

end

function Player:CheckLvlUp(xp, suppressmessage)
	
	if self:GetLvl() > self.combatTable.lvl then
		//Lvl UP
		// make sure that we get every lvl we've earned
	    local numberLevels = self:GetLvl() - self.combatTable.lvl
        self.resources = self.resources + numberLevels
		self.combatTable.lvl = self:GetLvl()
		
		// Trigger an effect sound on level up
		self:TriggerEffects("distress_beacon_spawn")
		self:TriggerEffects("distress_beacon_complete")
		
		local LvlName = Experience_GetLvlName(self:GetLvl(), self:GetTeamNumber())
		self:SendDirectMessage( "!! Level UP !! New Lvl: " .. LvlName .. " (" .. self:GetLvl() .. ")")
	end     
	
	if self:GetLvl() < maxLvl and not suppressmessage then
		// Fix the decimal places here...
		local currentXp = math.floor(self:GetXp())
		self:SendDirectMessage(currentXp .. " XP: " .. (XpList[self:GetLvl() + 1]["XP"] - currentXp).. " XP until next level!")
	end
	
end

function Player:spendlvlHints(hint, type)
// sends a hint to the player if co_spendlvl fails

    if not type then type = "" end

	if hint == "spectator" then
        self:SendDirectMessage("You can only apply upgrades once you've joined a team!")
		
	elseif hint == "dead" then
        self:SendDirectMessage("You cannot apply upgrades if you are dead!")
		
    elseif hint == "no_type" then
        self:SendDirectMessage("Usage: /buy upgradeName or co_spendlvl upgradeName - All upgrades for your team:")
        Server.ClientCommand(self, "co_upgrades")
               
    elseif hint == "wrong_type_marine" then        
        self:SendDirectMessage(  type .. " is not known. All upgrades for your team:")        
        Server.ClientCommand(self, "co_upgrades")
        
    elseif hint == "wrong_type_alien" then
        self:SendDirectMessage(  type .. " is not known. All upgrades for your team:")
        Server.ClientCommand(self, "co_upgrades")
        
    elseif hint == "neededOtherUp" then
        self:SendDirectMessage( "You need " .. type .. " first")       
    
    elseif hint == "neededLvl" then
        self:SendDirectMessage("You got only " .. self:GetLvlFree().. " but you need at least ".. type .. " free Lvl")
        
    elseif hint == "already_owned" then
        self:SendDirectMessage("You already own the upgrade " .. type)
        
    elseif hint == "no_room" then
        self:SendDirectMessage( type .." upgrade failed, maybe not enough room")   
        
	elseif hint == "wrong_team" then
		local teamtext = ""
		if type == "Alien" then
			teamtext = "an Alien"
		else
			teamtext = "a Marine"
		end
		self:SendDirectMessage( "Cannot take this upgrade. You are not " .. teamtext .. "!" )   
		
	elseif hint == "mutuallyExclusive" then
		self:SendDirectMessage( "Cannot buy this upgrade when you have the " .. type .. " upgrade!")
		
	elseif hint == "freeLvl" then
	    local lvlFree = self:GetLvlFree()
	    local upgradeWord = (lvlFree > 1) and "upgrades" or "upgrade"
	    self:SendDirectMessage("You have " .. lvlFree .. " " .. upgradeWord .. " to spend. Use \"/buy <upgrade>\" in chat to buy upgrades.")   
	
    end
end

function Player:SendDirectMessage(message)
	
	// Initialise queue if necessary
	if (self.directMessageQueue == nil) then
		self.directMessageQueue = {}
		self.timeOfLastDirectMessage = 0
		self.directMessagesActive = 0
	end

	// Queue messages that have been sent if there are too many...
	if (Shared.GetTime() - self.timeOfLastDirectMessage < kDirectMessageFadeTime and self.directMessagesActive + 1 > kDirectMessagesNumVisible) then
		table.insert(self.directMessageQueue, message)
	else
		// Otherwise we're good to send the message normally.
		self:BuildAndSendDirectMessage(message)
	end
	
	// Update the last sent timer if this is the first message sent.
	if (self.directMessagesActive == 0) then
		self.timeOfLastDirectMessage = Shared.GetTime()
	end
	self.directMessagesActive = self.directMessagesActive + 1
	
end

function Player:BuildAndSendDirectMessage(message)

	//Sending LVL Msg only to the Player  
	local playerName = "Combat: " .. self:GetName()
	local playerLocationId = -1
	local playerTeamNumber = kTeamReadyRoom
	local playerTeamType = kNeutralTeamType

	Server.SendNetworkMessage(self, "Chat", BuildChatMessage(true, playerName, playerLocationId, playerTeamNumber, playerTeamType, message), true)

end

function Player:ProcessTauntAbilities()

	if self.combatTable then
        if self.combatTable.hasEMP then
            if  self.combatTable.lastEMP == 0 or Shared.GetTime() >= ( self.combatTable.lastEMP + kEMPTimer) then
                self:EMPBlast()
                self.combatTable.lastEMP = Shared.GetTime()
            else
                local timeReady = math.ceil(self.combatTable.lastEMP + kEMPTimer - Shared.GetTime())
                self:SendDirectMessage("EMP-taunt is not ready, wait " .. timeReady .. " sec")
            end    
        elseif self.combatTable.hasInk then
            if  self.combatTable.lastInk == 0 or Shared.GetTime() >= ( self.combatTable.lastInk + kInkTimer) then
                self:TriggerInk()
                self.combatTable.lastInk = Shared.GetTime()
            else
                local timeReady = math.ceil(self.combatTable.lastInk + kInkTimer - Shared.GetTime())
                self:SendDirectMessage("Ink-taunt is not ready, wait " .. timeReady .. " sec")
            end   
        end    
    end
	
end