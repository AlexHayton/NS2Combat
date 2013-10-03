//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_Player_Upgrades.lua

//___________________
// New functions,
// not hooked
//___________________

function GetIsPrimaryWeapon(kMapName)
    local isPrimary = false
    
    if kMapName == Shotgun.kMapName or
        kMapName == Flamethrower.kMapName  or
        kMapName == GrenadeLauncher.kMapName or
        kMapName == Rifle.kMapName then
        
        isPrimary = true
    end
    
    return isPrimary
end

function Player:GetCombatTechTree()

	return self.combatTable.techtree
	
end

// Check if a player has a given upgrade.
function Player:GetHasCombatUpgrade(upgradeId)

	local hasUpgrade = false
	if self.combatTable then
		for index, upgrade in ipairs(self.combatTable.techtree) do
			if (upgrade:GetId() == upgradeId) then
				hasUpgrade = true
				break
			end
		end
	end
	
	return hasUpgrade

end

function Player:CoEnableUpgrade(upgrades)

	self:CheckCombatData()
	local validUpgrades = {}
	// support multiple upgrades
	
	for i, upgrade in ipairs(upgrades) do
	
        local alreadyGotUpgrade = false
        local noRoom = false
        local notInTechRange = false
		local heavyTechCooldown = false
		local mutuallyExclusive = false
		local hardCapped = upgrade:GetIsHardCapped(self)
		local mutuallyExclusiveDescription = ""
        local requirements = upgrade:GetRequirements()
        local techId = upgrade:GetTechId()
        local neededLvl = upgrade:GetLevels()
        local team = upgrade:GetTeam()
        
        // Loop over the other items in the player's tech tree.
        for number, entry in ipairs(self.combatTable.techtree) do
        
            // does this up needs other ups??
            if requirements then
                if entry:GetId() == requirements then
                // we got the needed Update
                    requirements = nil
                end
            end
        
            // do i have the Up already?
            if entry:GetId() == upgrade:GetId() then
               alreadyGotUpgrade = true
            end
			
			// Check for whether we have a mutually exclusive upgrade here...
			if upgrade:GetMutuallyExclusive() then
				for i, mutuallyExclusiveUpgrade in ipairs(upgrade:GetMutuallyExclusive()) do
					if entry:GetId() == mutuallyExclusiveUpgrade then
						mutuallyExclusive = true
						mutuallyExclusiveDescription = entry:GetDescription()
					end
				end
			end
        end

        // Check whether we have room to evolve and the player is near a hive/command station for evolving to onos/exo
        if self:isa("Alien") then
            local lifeFormTechId = kTechId.Skulk
            if self:GetIsAlive() then 
                if upgrade:GetType() == kCombatUpgradeTypes.Class then
                    lifeFormTechId = self:GetTechId()
                else
                    lifeFormTechId = techId
                end
            end
            
            if not self:HasRoomToEvolve(techId) then
                noRoom = true
            end
           
            if techId == kTechId.Onos and not hardCapped then
				if (Shared.GetTime() - self.combatTable.timeLastHeavyTech) < kHeavyTechCooldown then
					heavyTechCooldown = true
				else
					if #GetEntitiesWithinRange("Hive", self:GetOrigin(), kTechRange) == 0 then
						notInTechRange = true
					else
						self.combatTable.timeLastHeavyTech = Shared.GetTime()
					end
				end
			end
        else
            if techId == kTechId.DualMinigunExosuit and not hardCapped then
				if (Shared.GetTime() - self.combatTable.timeLastHeavyTech) < kHeavyTechCooldown then
					heavyTechCooldown = true
				else
					if #GetEntitiesWithinRange("CommandStation", self:GetOrigin(), kTechRange) == 0 then
						notInTechRange = true
					else
						self.combatTable.timeLastHeavyTech = Shared.GetTime()
					end
				end
            end				
        end

        // Sanity checks before we actually go further.
        if requirements then
            self:spendlvlHints("neededOtherUp", GetUpgradeFromId(requirements):GetTextCode())
        elseif (not self:isa(team)) and not (self:isa("Exo") and team == "Marine") then
            self:spendlvlHints("wrong_team", team)
		elseif hardCapped then
			self:spendlvlHints("hardCapped")
        elseif alreadyGotUpgrade then
            self:spendlvlHints("already_owned", upgrade:GetTextCode())
        elseif noRoom then
            self:spendlvlHints("no_room")
        elseif notInTechRange then
            self:spendlvlHints("not_in_techrange", team)
		elseif heavyTechCooldown then
            self:spendlvlHints("heavytech_cooldown", team)
        elseif self:GetLvlFree() < neededLvl then
            self:spendlvlHints("neededLvl", neededLvl)
		elseif mutuallyExclusive then
			self:spendlvlHints("mutuallyExclusive", mutuallyExclusiveDescription)
        else
            table.insert(validUpgrades, upgrade)
            // insert the up to the personal techtree
            table.insert(self.combatTable.techtree, upgrade)
            // subtract the needed lvl
            self:SubtractLvlFree(neededLvl)
            
            local pointText = (neededLvl > 1) and "points" or "point"
            self:SendDirectMessage(upgrade:GetDescription() .. " purchased for " .. neededLvl .. " upgrade " .. pointText)
            
            // Special logic for alien lifeforms
            if self:isa("Alien") and upgrade:GetType() == kCombatUpgradeTypes.Class then
                self.combatTable.currentLifeForm = upgrade
            end
        end            
	end		
	
	// Apply all missing upgrades.
    if table.maxn(validUpgrades) > 0 then
        if self:isa("Alien")  then
            // special treatment for aliens cause they will hatch with all upgrades)
            self:ApplyAllUpgrades(nil, validUpgrades)
        else
            for i, upgrade in ipairs(validUpgrades) do				
				// Refund the mutually exclusive upgrades if we bought e.g. exo...
				// call it first before ApplyAllUpgrades, or the efundMutuallyExclusiveUpgrades function is not getting called right
				self:RefundMutuallyExclusiveUpgrades(upgrade)				
                self:ApplyAllUpgrades(nil, upgrade)
            end    
        end
    end

end

// Refund any bought upgrades that the current class can't use...
function Player:RefundMutuallyExclusiveUpgrades(upgrade)

	local removals = {}
	for index, entry in ipairs(self.combatTable.techtree) do
		if entry:GetMutuallyExclusive() then
			for i, mutuallyExclusiveUpgrade in ipairs(entry:GetMutuallyExclusive()) do
				if upgrade:GetId() == mutuallyExclusiveUpgrade then
					table.insert(removals, index)
					self:AddLvlFree(entry:GetLevels())
					self:SendDirectMessage("Refunded " .. entry:GetLevels() .. " upgrade point(s) for your " .. entry:GetDescription())
				end
			end
		end
	end
	
	for index, indexToRemove in ipairs(removals) do
		table.remove(self.combatTable.techtree, indexToRemove)
	end
end

function Player:ApplyAllUpgrades(upgradeTypes, singleUpgrade)

	// By default do Classes first, then Weapons, then Tech
	if not upgradeTypes then 
		upgradeTypes = { kCombatUpgradeTypes.Class, kCombatUpgradeTypes.Weapon, kCombatUpgradeTypes.Tech }
	end
	
	self:CheckCombatData()
	local techTree = self:GetCombatTechTree()
    
    if self:GetHasUps() then 
        if not singleUpgrade then
            for index, upgradeType in ipairs(upgradeTypes) do
                
                local upgradesOfType = GetUpgradesOfType(techTree, upgradeType)
                
                for index, upgrade in ipairs(upgradesOfType) do
                    // Only apply the currently active lifeform upgrade...
                    if upgradeType == kCombatUpgradeTypes.Class then
                        if upgrade == self.combatTable.currentLifeForm then
                            upgrade:DoUpgrade(self)
                        else
                            // to enable jp and exo
                            if  self:isa("Marine") or self:isa("Exo") then
                                upgrade:DoUpgrade(self)
                            end
                        end
                    else
                        upgrade:DoUpgrade(self)
                    end
                end
                
            end            
                
            // send the Ups to the GUI
			// not necessary here, seems like working without
            // self:SendAllUpgrades()  
            
        else
            if type(singleUpgrade) == "table" then			
                // if its a table, special logic for aliens
                for i, upgrade in ipairs(singleUpgrade) do
                    upgrade:DoUpgrade(self)
                end
				
				singleUpgrade[1]:DoUpgrade(self)
				// send the Ups to the GUI
				self:SendUpgrades(singleUpgrade)
            else
                singleUpgrade:DoUpgrade(self)
				self:SendUpgrades(singleUpgrade)
            end
        end    
    end  
	
end

function Player:HasRoomToEvolve(techId)

    local success = false

    if not techId then
        techId = kTechId.Skulk
    end
    
    // Check for room
    local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
    local newAlienExtents = nil
    // Aliens will have a kTechDataMaxExtents defined, find it.
    newAlienExtents = LookupTechData(techId, kTechDataMaxExtents)
  
    // In case we aren't evolving to a new alien, using the current's extents.
    if not newAlienExtents then
        newAlienExtents = LookupTechData(self:GetTechId(), kTechDataMaxExtents)
    end
    
    local physicsMask = PhysicsMask.AllButPCsAndRagdolls
    local position = self:GetOrigin()
    
    //if self:GetIsOnGround() and
		if GetHasRoomForCapsule(eggExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self) and
		GetHasRoomForCapsule(newAlienExtents, position + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self) then
		
		success = true
		end
    //end
	
	return success
	
end
	
function Player:EvolveTo(newTechId)

	local success = false
	
	if not newTechId then
        newTechId = kTechId.Skulk
    end
	
	// Preserve existing health/armor when we're not changing lifeform
	local healthScalar = self:GetHealth() / self:GetMaxHealth()
    local armorScalar = self:GetArmor() / self:GetMaxArmor()
    
    local physicsMask = PhysicsMask.AllButPCsAndRagdolls
    local position = self:GetOrigin()

	if self:HasRoomToEvolve(newTechId) then
	
        newPlayer = self:Replace(Embryo.kMapName)
        position.y = position.y + Embryo.kEvolveSpawnOffset
        newPlayer:SetOrigin(position)
          
        // Clear angles, in case we were wall-walking or doing some crazy alien thing
        local angles = Angles(self:GetViewAngles())
        angles.roll = 0.0
        angles.pitch = 0.0
        newPlayer:SetAngles(angles)
		
		// Set up the third-person camera.
		newPlayer:SetCameraDistance(4)
        newPlayer:SetViewOffsetHeight(.5)

        // Eliminate velocity so that we don't slide or jump as an egg
        newPlayer:SetVelocity(Vector(0, 0, 0))
        newPlayer:DropToFloor()
		
		// Specify the list of tech Ids for the new entity to have.
		local myTechTree = self:GetCombatTechTree()
		local techIds = {}
		table.insert(techIds, newTechId)
		//self:GetUpgrades()
		for index, upgrade in ipairs(myTechTree) do
			if (upgrade:GetType() == kCombatUpgradeTypes.Tech) then
				table.insert(techIds, upgrade:GetTechId())
			end
		end
		
		newAlienExtents = LookupTechData(newTechId, kTechDataMaxExtents)
  
		// In case we aren't evolving to a new alien, using the current's extents.
		lifeform = self:GetTechId()
		if newAlienExtents then
			lifeform = newTechId
			self.combatTable.classEvolve = true
		end

		// Handle special upgrades.
		newPlayer:SetGestationData(techIds, lifeform, healthScalar, armorScalar)

        success = true
    end
    
    return success, newPlayer
	
end

// To refund Class upgrades.
function Player:RefundUpgrades()
	
	// Give player back his resources but take the upgrades away
	local upgrades = self.combatTable.techtree
		
	// For each class, find the upgrade and remove it, and take away the correct amount of lvlfree.
	for index, upgrade in ipairs(upgrades) do
		if (upgrade:GetRefundUpgrade()) then
			self:AddLvlFree(upgrade:GetLevels())
			
			for index, combatUpgrade in ipairs(self.combatTable.techtree) do
				if upgrade:GetId() == combatUpgrade:GetId() then
					table.remove(self.combatTable.techtree, index)
				end
			end
		end
	end

end

// return if the player got any ups or not
function Player:GetHasUps()
    
    self:CheckCombatData()    
    return not(table.maxn(self.combatTable.techtree) <= 0)
	
end
     
// Gimme my Ups back, called from "CopyPlayerData" 
function Player:GiveUpsBack()
      
    if self:isa("Alien") then
        if self:GetHasUps() then 
            self:RefundUpgrades({ kCombatUpgradeTypes.Class })
        else  
            // if we have no Ups, spawn in an egg
            self:DropToFloor()
			self:EvolveTo(self:GetTechId())
        end
	elseif self:isa("Marine") then
		self:RefundUpgrades({ kCombatUpgradeTypes.Class })
    end
    
    self:ApplyAllUpgrades({ kCombatUpgradeTypes.Weapon, kCombatUpgradeTypes.Tech })         
    self.isRespawning = false        
	
end

    
function Player:ResetCombatData()
		// don't initialise the Combat Data !!! we need to reset it
	self.combatTable = {} 

	// that we don't have to write everything in 3 different functions
	self:Reset_Lite() 

	self.combatTable.lvl = 1
	self:AddLvlFree(kCombatStartUpgradePoints)
	
	// getAvgXP is called before giving the score, so this needs to be implemented here
	self.score = 0
	
	// Set it to -kHeavyTechCooldown for buying exo/onos at the beginning
	self.combatTable.timeLastHeavyTech = -kHeavyTechCooldown
end      


// resetting some things, for team change
function Player:Reset_Lite()

	self:ClearLvlFree()
	self.combatTable.lastUpgradeNotify = 0
	self.combatTable.lastReminderNotify = 0
	self.combatTable.lastXpEffect = 0
	self.combatTable.lastXpAmount = 0
	self.combatTable.lastTauntTime = 0
	self.combatTable.hasCamouflage = false
	self.combatTable.twoHives = false
	self.combatTable.threeHives = false

	self.combatTwoHives = false
	self.combatThreeHives = false

	self.twoHives = false
	self.threeHives = false

    // scan and resupp values	
    self.combatTable.hasScan = false
    self.combatTable.lastScan = 0

    self.combatTable.hasResupply = false
    self.combatTable.lastResupply = 0
	
	self.combatTable.hasCatalyst = false
	self.combatTable.lastCatalyst = 0
	
	self.combatTable.hasEMP = false
	self.combatTable.lastEMP = 0
	
	self.combatTable.hasInk = false
	self.combatTable.lastInk = 0
	
	// for fastreload and focus
	self.combatTable.hasFastReload = false
	self.combatTable.hasFocus = false
	
	// delete everything from the spawnProtect system
	self.gotSpawnProtect = nil
    self.combatTable.activeSpawnProtect = false
	self.combatTable.deactivateSpawnProtect = nil
    
    self.combatTable.giveClassAfterRespawn = nil	
	
	// save the last team
	local teamNumber = self:GetTeamNumber()
	if teamNumber ~= 0 then
		self.combatTable.lastTeamNumber = teamNumber
	end
	
	self.combatTable.techtree = {}
	self:ClearCoUpgrades()
	Server.SendNetworkMessage(self, "ClearTechTree", {}, true)

end

// Refunds all the upgrades and resets them back as if they had just joined the team.
function Player:RefundAllUpgrades()

	self:Reset_Lite()
	self:AddLvlFree(self:GetLvl() - 1 + kCombatStartUpgradePoints)
	self:SendDirectMessage("All points refunded. You can choose your upgrades again!")
	
	// Kill the player when they do this. Prevents abuse!
	if (self:GetIsAlive()) then
		self:Kill(nil, nil, self:GetOrigin())
	end

end

// sends all upgrades to the player
function Player:SendAllUpgrades()

	self:CheckCombatData()    
    local combatTechTree = self:GetCombatTechTree()

    // clear all upgrades and send new ones
    self:ClearCoUpgrades()
    
    if combatTechTree then    
        for _, upgrade in pairs(combatTechTree) do
            if upgrade then
				SendCombatSetUpgrade(self, upgrade:GetId())
            end
        end
    end
      
end

// sends only the new upgrades
function Player:SendUpgrades(upgrades)
  
	self:CheckCombatData()    
    local combatTechTree = self:GetCombatTechTree()
    
    if combatTechTree then  

        if (type(upgrades) == "table") then  
            for _, upgrade in pairs(upgrades) do
                if upgrade then
					SendCombatSetUpgrade(self, upgrade:GetId())
                end
            end
        else
			SendCombatSetUpgrade(self, upgrades:GetId())
        end
    end
      
end

// clear all Combat Upgrades
function Player:ClearCoUpgrades()
	// seems like it works also without this, saves a lot network traffic
    //Server.SendCommand(self, "co_clearupgrades")
end

function Player:BalanceXp(avgXp)

	local xpDiff = avgXp - self:GetXp()
	if xpDiff > 0 then
		// get AvgXp 
		self:SendDirectMessage("Awarding " .. xpDiff .. " XP to help you catch up with your teammates...")
		self:AddXp(xpDiff)
	end

end