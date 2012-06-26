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

function Player:ExecuteTechUpgrade(techId)

	local techTree = self:GetTechTree()
	local node = techTree:GetTechNode(techId)
	if node == nil then
    
        Print("Player:ExecuteTechUpgrade(): Couldn't find tech node %d", techId)
        return false
        
    end

    node:SetResearched(true)
	node:SetHasTech(true)
	techTree:SetTechNodeChanged(node)
	techTree:SetTechChanged()
	
	if techId == kTechId.Armor1 or techId == kTechId.Armor2 or techId == kTechId.Armor3 then
		self:UpdateArmorAmount()
	end

end

function Player:CoEnableUpgrade(upgrade)

	self:CheckCombatData()    
	local alreadyGotUpgrade = false
	local noRoom = false
	local requirements = upgrade:GetRequirements()
	local techId = upgrade:GetTechId()
	
	// do i have the Up already?
	for number, entry in ipairs(self.combatTable.techtree) do
	
		// does this up needs other ups??
		if requirements then
			if entry:GetId() == requirements then
			// we got the needed Update
				requirements = nil
			end
		end
	
		if entry:GetId() == upgrade:GetId() then
		   alreadyGotUpgrade = true
		end
	end
	
	// Check whether we have room to evolve
	if self:isa("Alien") and upgrade:GetType() == then
		if not self:HasRoomToEvolve(techId) then
			noRoom = true
		end
	end

	// Sanity checks before we actually go further.
	if requirements then
		self:spendlvlHints("neededOtherUp", requirements:GetText())
	elseif alreadyGotUpgrade then
	    self:spendlvlHints("already_owned", upgrade:GetText())
	elseif noRoom then
		self:spendlvlHints("no_room")
    elseif self:GetFreeLvl() < neededLvl then
		self:spendlvlHints("neededLvl", neededLvl)
	else
		// insert the up to the personal techtree
		table.insert(self.combatTable.techtree, upgrade)
		// subtract the needed lvl
		self:SubtractLvlFree(neededLvl)
		
		local pointText = (neededLvl > 1) and "points" or "point"
		self:SendDirectMessage(techName .. " purchased for " .. neededLvl .. " upgrade " .. pointText)
		
		// Apply all missing upgrades.
		if not self.respawning then
			self:ApplyAllUpgrades()
		end
	end

end

function Player:ApplyAllUpgrades()

	self:CheckCombatData()

	for index, upgrade in ipairs(self.combatTable.techtree) do
		if not upgrade:GetIsApplied() then
			upgrade:DoUpgrade(self)
		end
	end
		
	// Update the tech tree and send updates to the client
	self:GetTechTree():ComputeAvailability()
	self:GetTechTree():SendTechTreeUpdates({self})
	
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
	
function Player:EvolveTo(techId)

	local success = false
	
	// Preserve existing health/armor when we're not changing lifeform
	local healthScalar = self:GetHealth() / self:GetMaxHealth()
    local armorScalar = self:GetArmor() / self:GetMaxArmor()

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

		// Handle special upgrades.
		success = self:HandleSpecialUpgrades(newPlayer, techId)
		newPlayer:SetGestationData({}, self:GetTechId(), healthScalar, armorScalar)
		newPlayer:ApplyAllUpgrades()

        success = true
    end
    
    return success, newPlayer
end
     
// Gimme my Ups back, called from "CopyPlayerData" 
function Player:GiveUpsBack()
    
	self:ApplyAllUpgrades()
    self.isRespawning = false
	
end