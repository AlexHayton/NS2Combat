//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
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

function Player:CoEnableUpgrade(upgrade)

	self:CheckCombatData()
	local alreadyGotUpgrade = false
	local noRoom = false
	local requirements = upgrade:GetRequirements()
	local techId = upgrade:GetTechId()
	local neededLvl = upgrade:GetLevels()
	
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
	end
	
	// Check whether we have room to evolve
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
	end

	// Sanity checks before we actually go further.
	if requirements then
		self:spendlvlHints("neededOtherUp", GetUpgradeFromId(requirements):GetTextCode())
	elseif alreadyGotUpgrade then
	    self:spendlvlHints("already_owned", upgrade:GetTextCode())
	elseif noRoom then
		self:spendlvlHints("no_room")
    elseif self:GetLvlFree() < neededLvl then
		self:spendlvlHints("neededLvl", neededLvl)
	else
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
		
		// Apply all missing upgrades.
		if not self.respawning then
			self:ApplyAllUpgrades()
		end
	end

end

function Player:ApplyAllUpgrades(upgradeTypes)

	// By default do Classes first, then Weapons, then Tech
	if not upgradeTypes then 
		upgradeTypes = { kCombatUpgradeTypes.Class, kCombatUpgradeTypes.Weapon, kCombatUpgradeTypes.Tech }
	end
	
	self:CheckCombatData()
	local techTree = self:GetCombatTechTree()

	for index, upgradeType in ipairs(upgradeTypes) do
		
		local upgradesOfType = GetUpgradesOfType(techTree, upgradeType)
		
		for index, upgrade in ipairs(upgradesOfType) do
			//if not upgrade:GetIsApplied() then
			
			// Only apply the currently active lifeform upgrade...
			if upgradeType == kCombatUpgradeTypes.Class then
				if upgrade == self.combatTable.currentLifeForm then
					upgrade:DoUpgrade(self)
				end
			else
				upgrade:DoUpgrade(self)
			end
			//end
		end
		
	end
		
	// Update the tech tree and send updates to the client
	//self:GetTechTree():ComputeAvailability()
	//self:GetTechTree():SendTechTreeUpdates({self})
	
end

function Player:HasRoomToEvolve(techId)

    if not techId then
        techId = kTechId.Skulk
    end
    
    local success = false
    
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
    
    if self:GetIsOnGround() and
		GetHasRoomForCapsule(eggExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self) and
		GetHasRoomForCapsule(newAlienExtents, position + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self) then
		
		success = true
    end
	
	return success
	
end
	
function Player:EvolveTo(techId)

	local success = false
	
	if not techId then
        techId = kTechId.Skulk
    end
    
    local success = false
	
	// Preserve existing health/armor when we're not changing lifeform
	local healthScalar = self:GetHealth() / self:GetMaxHealth()
    local armorScalar = self:GetArmor() / self:GetMaxArmor()
    
    local physicsMask = PhysicsMask.AllButPCsAndRagdolls
    local position = self:GetOrigin()

	if self:HasRoomToEvolve(techId) then
	
        newPlayer = self:Replace(Embryo.kMapName)
        position.y = position.y + Embryo.kEvolveSpawnOffset
        newPlayer:SetOrigin(position)
          
        // Clear angles, in case we were wall-walking or doing some crazy alien thing
        local angles = Angles(self:GetViewAngles())
        angles.roll = 0.0
        angles.pitch = 0.0
        newPlayer:SetAngles(angles)

        // Eliminate velocity so that we don't slide or jump as an egg
        newPlayer:SetVelocity(Vector(0, 0, 0))
        newPlayer:DropToFloor()
		
		// Specify the list of tech Ids for the new entity to have.
		local techIds = self:GetUpgrades()
		table.insert(techIds, techId)

		// Handle special upgrades.
		newPlayer:SetGestationData(techIds, self:GetTechId(), healthScalar, armorScalar)
		
		// Apply all other upgrades.
		newPlayer:ApplyAllUpgrades({ kCombatUpgradeTypes.Weapon, kCombatUpgradeTypes.Tech })

        success = true
    end
    
    return success, newPlayer
	
end

function Player:RefundUpgrades(upgradeTypes)
	if not upgradeTypes then 
		upgradeTypes = { kCombatUpgradeTypes.Class }
	end
	
	// Give player back his exp but take the upgrades away
	for upgradeType in ipairs(upgradeTypes) do
		local upgrades = GetUpgradesOfType(self.combatTable.techtree, upgradeType)
		
		for upgrade in ipairs(upgrades) do
			self:AddLvlFree(upgrade:GetLevels())
			table.remove(self.combatTable.techtree, upgrade)
		end
	end
end
     
// Gimme my Ups back, called from "CopyPlayerData" 
function Player:GiveUpsBack()
    
	if self:isa("Alien") then
		self:RefundUpgrades({ kCombatUpgradeTypes.Class })
	end
	self:ApplyAllUpgrades({ kCombatUpgradeTypes.Weapon, kCombatUpgradeTypes.Tech })
    self.isRespawning = false
	
end