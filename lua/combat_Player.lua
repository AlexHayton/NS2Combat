//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Player.lua

// Load the Upgrade functions too...
Script.Load("lua/combat_Player_Upgrades.lua")

//___________________
// New functions,
// not hooked
//___________________

// adaptet from function Alien:ProcessBuyAction(techIds)
function Player:CoEvolve(techId)

    if not techId then
        techId = kTechId.Skulk
    end
    
    local success = false
    local healthScalar = 1
    local armorScalar = 1
    
    // Check for room
    local eggExtents = LookupTechData(kTechId.Embryo, kTechDataMaxExtents)
    local newAlienExtents = nil
    // Aliens will have a kTechDataMaxExtents defined, find it.
    newAlienExtents = LookupTechData(techId, kTechDataMaxExtents)
  
    // In case we aren't evolving to a new alien, using the current's extents.
    if not newAlienExtents then
    
        newAlienExtents = LookupTechData(self:GetTechId(), kTechDataMaxExtents)
        // Preserve existing health/armor when we're not changing lifeform
        healthScalar = self:GetHealth() / self:GetMaxHealth()
        armorScalar = self:GetArmor() / self:GetMaxArmor()
        
    end
    
    local physicsMask = PhysicsMask.AllButPCsAndRagdolls
    local position = self:GetOrigin()
    
    if self:GetIsOnGround() and
		GetHasRoomForCapsule(eggExtents, position + Vector(0, eggExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self) and
		GetHasRoomForCapsule(newAlienExtents, position + Vector(0, newAlienExtents.y + Embryo.kEvolveSpawnOffset, 0), CollisionRep.Default, physicsMask, self) then
      
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
		newPlayer:SetGestationData(self:GetTechIds(techId), self:GetTechId(), healthScalar, armorScalar)

        success = true
    end
    
    return success, newPlayer
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

function Player:AddXp(amount)
	
    self:CheckCombatData()
    self:TriggerEffects("res_received")
	
	// Make sure we don't go over the max XP.
    if (self:GetXp() + amount) <= maxXp then

        // show the cool effect, no direct Message is needed anymore

        self:XpEffect(amount)
		self:CheckLvlUp(self.score) 

    else
        // Max Lvl reached
        self:SendDirectMessage("Max-XP reached")
        self.score = maxXp
        self:CheckLvlUp(self.score)
    end        
       
end

// Give XP to m8's around you when you kill an enemy
function Player:GiveXpMatesNearby(xp)

    xp = xp * mateXpAmount

    local playersInRange = GetEntitiesForTeamWithinRange("Player", self:GetTeamNumber(), self:GetOrigin(), mateXpRange)
    
    for _, player in ipairs(playersInRange) do
        if self ~= player then
            player:AddXp(xp)    
        end
    end

end

// cool effect for getting xp, also showing a new Lvl
function Player:XpEffect(xp, lvl)

    // Should only be called on the Server.
    if Server then
    
        // Tell client to display cool effect.
        if xp ~= nil and xp ~= 0 then
        
            Server.SendCommand(self, string.format("points %s %s", tostring(xp), tostring(0)))
            self.score = Clamp(self.score + xp, 0, self:GetMixinConstants().kMaxScore or 100)
            self:SetScoreboardChanged(true)

        end
    
    end

end

function Player:CheckLvlUp(xp)
	
	if self:GetLvl() > self.combatTable.lvl then
		//Lvl UP
		// make sure that we get every lvl we've earned
	    local numberLevels = self:GetLvl() - self.combatTable.lvl
        self.resources = self.resources + numberLevels
		self.combatTable.lvl = self:GetLvl()
		
		local LvlName = Experience_GetLvlName(self:GetLvl(), self:GetTeamNumber())
		self:SendDirectMessage( "!! Level UP !! New Lvl: " .. LvlName .. " (" .. self:GetLvl() .. ")")
	end     
	
	if self:GetLvl() < maxLvl then
		self:SendDirectMessage( self:GetXp() .. " XP: " .. (XpList[self:GetLvl() + 1]["XP"] - self:GetXp()).. " XP until next level!")
	end
	
end

function Player:spendlvlHints(hint, type)
// sends a hint to the player if co_spendlvl fails

    if not type then type = "" end

	if hint == "spectator" then
        self:SendDirectMessage("You can only apply updates once you've joined a team!")
		
    elseif hint == "no_type" then
        self:SendDirectMessage("Usage: co_spendlvl upgrade - All upgrades for your team:")
        // ToDo: make a short break before printing the ups        
        Server.ClientCommand(self, "co_upgrades")
               
    elseif hint == "wrong_type_marine" then        
        self:SendDirectMessage(  type .. " is not known. All upgrades for your team:")        
        // ToDo: make a short break before printing the ups        
        Server.ClientCommand(self, "co_upgrades")
        
    elseif hint == "wrong_type_alien" then
        self:SendDirectMessage(  type .. " is not known. All upgrades for your team:")
        // ToDo: make a short break before printing the ups
        Server.ClientCommand(self, "co_upgrades")
        
    elseif hint == "neededOtherUp" then
        self:SendDirectMessage( "You need " .. type .. " first")       
    
    elseif hint == "neededLvl" then
        self:SendDirectMessage("You got only " .. self:GetLvlFree().. " but you need at least ".. type .. " free Lvl")
        
    elseif hint == "already_owned" then
        self:SendDirectMessage("You already own the upgrade " .. type)
        
    elseif hint == "no_room" then
        self:SendDirectMessage( type .." upgrade failed, maybe not enough room")   
        
    end
end

function Player:SendDirectMessage(message)
//Sending LVL Msg only to the Player  
        local playerName = "Combat: " .. self:GetName()
        local playerLocationId = -1
        local playerTeamNumber = kTeamReadyRoom
        local playerTeamType = kNeutralTeamType

        Server.SendNetworkMessage(self, "Chat", BuildChatMessage(true, playerName, playerLocationId, playerTeamNumber, playerTeamType, message), true)
end