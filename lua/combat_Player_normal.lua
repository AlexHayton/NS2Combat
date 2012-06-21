//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//	
//________________________________

// combat_Player_normal.lua

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
	techTree:ComputeAvailability()
	techTree:SendTechTreeUpdates({ self })
	
	if techId == kTechId.Armor1 or techId == kTechId.Armor2 or techId == kTechId.Armor3 then
		self:UpdateArmorAmount()
	end

end
     
// Do Upgrade, called by console, type and team is checked and is valid
// ToDo: what happens if I wanna have another weapon -> use last chosen weapon
// ToDo: do i have everything necessery?
function Player:CoCheckUpgrade_Marine(upgrade, respawning)
    
    local doUpgrade = false
	self:CheckCombatData()
    
    if UpsList.Marine[upgrade] then
    
        local type = UpsList.Marine[upgrade]["Type"]
        local neededLvl = UpsList.Marine[upgrade]["Levels"]
        local neededOtherUp = UpsList.Marine[upgrade]["Requires"]
        local kMapName = UpsList.Marine[upgrade]["UpgradeName"]
		local techId = UpsList.Marine[upgrade]["UpgradeTechId"]
		local techName = UpsList.Marine[upgrade]["UpgradeText"]
        doUpgrade = true

        // do i have the Up already?
		for number, entry in ipairs(self.combatTable.techtree) do
		
			// do the up needs other ups??
			if neededOtherUp then
				if entry == neededOtherUp then
				// we got the needed Update
					neededOtherUp = nil
				end
			end
		
			if entry == upgrade then
			   doUpgrade = false
			end
		end
				 
		if ((self:GetLvlFree() >=  neededLvl and doUpgrade and not neededOtherUp) or respawning) then

			// check type(weapon, class, tech)
			if type == "weapon" then
			
				if self:GetIsAlive() or self:isa("Marine") then
					Player.InitWeapons(self)
					
					// if primary weapon, destroy old (only rifle)                
					if GetIsPrimaryWeapon(kMapName) then
						local weapon = self:GetWeaponInHUDSlot(1)
						self:RemoveWeapon(weapon)
						DestroyEntity(weapon)
					end
					
					// Execute the tech upgrade so you can switch the weapon at the armory.
					self:ExecuteTechUpgrade(techId)
					self:GiveItem(kMapName)					
				end       
			
			elseif type == "tech" then            
				self:ExecuteTechUpgrade(techId)
				
			elseif type == "class" then
				if self:GetIsAlive() then
					// can't replace somebody who's respawning at the moment, give him the class later
					if not respawning then
						// Jps get the lmg back, so get the old weapon (but only directly after up, after dying its all OK)
						// TODO; when EXO finished, what happen with it?
						
						// its not needed to ExecuteTechUpgrade when its a class
						self:GiveJetpack() 						
						self.combatTable.giveClassAfterRespawn = kMapName																		
					end
				end
			end

			if not respawning then
				// insert the up to the personal techtree
				table.insert(self.combatTable.techtree, upgrade)
				// subtract the needed lvl
				self:SubtractLvlFree(neededLvl)
				
				local pointText = (neededLvl > 1) and "points" or "point"
				self:SendDirectMessage(techName .. " purchased for " .. neededLvl .. " upgrade " .. pointText)
			end
		  
		else
            if doUpgrade then
                if neededOtherUp then
                    self:spendlvlHints("neededOtherUp", neededOtherUp)
                else
                    self:spendlvlHints("neededLvl", neededLvl)
                end
            else
                self:spendlvlHints("already_owned", upgrade)
            end
		end    
    end
end

// Special treatment for alien evolutions (eggs etc.)

//ToDo: there is a bug where aliens cant get tech, cara etc.
function Player:CoCheckUpgrade_Alien(upgrade, respawning, position)

    local doUpgrade = false
	self:CheckCombatData()
    
    if UpsList.Alien[upgrade] then
  
        local type = UpsList.Alien[upgrade]["Type"]
        local neededLvl = UpsList.Alien[upgrade]["Levels"]
        local neededOtherUp = UpsList.Alien[upgrade]["Requires"]
        local kMapName = UpsList.Alien[upgrade]["UpgradeName"]
		local techId = UpsList.Alien[upgrade]["UpgradeTechId"]
		local techName = UpsList.Alien[upgrade]["UpgradeText"]
        doUpgrade = true
        // this is needed if there is no room for an egg
        upgradeOK = true

        // do i have the Up already?
		for number, entry in ipairs(self.combatTable.techtree) do
		
			// do the up needs other ups??
			if neededOtherUp then
				if entry == neededOtherUp then
				// we got the needed Update
					neededOtherUp = nil
				end
			end
		
			if entry == upgrade then
			   doUpgrade = false
			end
		end
				 
		if ((self:GetLvlFree() >= neededLvl and doUpgrade and not neededOtherUp) or respawning) then
				
			if type == "tech" then
				if self:GetIsAlive() then
					if respawning then
						// no evolving when respawning
						success = self:GetTechTree():GiveUpgrade(kMapName)
						self:ExecuteTechUpgrade(techId)
					else    
						upgradeOK = self:CoEvolve(kMapName)
						if upgradeOK then
							//success = self:GetTechTree():GiveUpgrade(kMapName)
						end
					end
				end
				
			elseif type == "class" then
				if self:GetIsAlive() then
					if respawning then
						// Just gimme the Lvl back
						self:AddLvlFree(neededLvl)
						table.remove(self.combatTable.techtree, position)
					else
						//self:Replace(kMapName, self:GetTeamNumber(), false)  
						// its not needed to ExecuteTechUpgrade when its a class
						upgradeOK = self:CoEvolve(kMapName)            
					end
				end
			end
	 
			if not respawning then
				if  upgradeOK then
					// insert the up to the personal techtree
					table.insert(self.combatTable.techtree, upgrade)
					// subtrate the needed lvl
					self:SubtractLvlFree(neededLvl)
					self:SendDirectMessage(techName .. " purchased for " .. neededLvl .. " upgrade " .. pointText)
				else
					self:spendlvlHints("no_room", upgrade) 
				end  
			end
	  
		else
            if doUpgrade then
                if neededOtherUp then
                    self:spendlvlHints("neededOtherUp", neededOtherUp)
                else
                    self:spendlvlHints("neededLvl", neededLv)
                end
            else
                self:spendlvlHints("already_owned", upgrade)
            end
		end        
    end
end

// adaptet from function Alien:ProcessBuyAction(techIds)
function Player:CoEvolve(techId)
    
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
      
        local newPlayer = self:Replace(Embryo.kMapName)
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


        newPlayer:SetGestationData(self:GetTechIds(techId), self:GetTechId(), healthScalar, armorScalar)

        success = true
    end
    
    return success
end


// get all TechIds the player currently got (when you got carapace and then go gorge you would lose it without this function)
function Player:GetTechIds(techId)

    local techIds = {}
    if techId then
        table.insert(techIds, techId)
    end
    
    if self.combatTable.techtree then    // only used by aliens, so only Aliens Uplist
        for i, entry in ipairs(self.combatTable.techtree) do
            if entry then
                table.insert(techIds, UpsList.Alien[entry]["UpgradeTechId"])
            end
        end
    end
    
    return techIds
    
end


// Gimme my Ups back, called from "CopyPlayerData" 
function Player:GiveUpsBack()
    
	self:CheckCombatData()
	
	if self:isa("Marine") then  
		// do it for every up in the table      
		for i, entry in pairs(self.combatTable.techtree) do 
			self:CoCheckUpgrade_Marine(entry, true) 
		end
	elseif self:isa("Alien") then
		for i, entry in pairs(self.combatTable.techtree) do 
			// TODO: just get lvl back when you got a other class
			self:CoCheckUpgrade_Alien(entry, true, i)   
		end
	end            
    
    self.isRespawning = false
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

function Player:SubtractLvlFree()

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

    if hint == "no_type" then
        self:SendDirectMessage("No type defined, usage is: co_spendlvl type") 
               
    elseif hint == "wrong_type_marine" then        
        self:SendDirectMessage(  type .. " is not known, all upgrades for your team:")        
        // ToDo: make a short break before printing the ups        
        Server.ClientCommand(self, "co_upgrades")
        
    elseif hint == "wrong_type_alien" then
        self:SendDirectMessage(  type .. " is not known, all upgrades for your team:")
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