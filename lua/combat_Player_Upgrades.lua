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
     
// Do Upgrade, called by console, type and team is checked and is valid
// ToDo: what happens if I wanna have another weapon -> use last chosen weapon
// ToDo: do i have everything necessery?
function Player:CoCheckUpgrade_Marine(upgrade, respawning, position)
    
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
	
	// Update the tech tree and send updates to the client
	if not respawning then
		self:GetTechTree():ComputeAvailability()
		self:GetTechTree():SendTechTreeUpdates({self})
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
						upgradeOK = self:HandleSpecialUpgrades(self, techId)
						if not upgradeOK then				
							// no evolving when respawning
							self:ExecuteTechUpgrade(techId)
							self:GetTechTree():GiveUpgrade(kMapName)
							self:GiveUpgrade(kMapName)
						end
					else    
						upgradeOK, newPlayer = self:CoEvolve(kMapName)
					end
				end
				
			elseif type == "class" then
				if self:GetIsAlive() then
					if respawning then
						// Just gimme the Lvl back
						self:AddLvlFree(neededLvl)
						table.remove(self.combatTable.techtree, position)
					else
						upgradeOK, newPlayer = self:CoEvolve(kMapName)            
					end
				end
			end
	 
			if not respawning then
				if  upgradeOK then
					// insert the up to the personal techtree
					table.insert(self.combatTable.techtree, upgrade)
					// subtrate the needed lvl
					newPlayer:SubtractLvlFree(neededLvl)					     
					local pointText = (neededLvl > 1) and "points" or "point"
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
	
	// Update the tech tree and send updates to the client
	if not respawning then
		self:GetTechTree():ComputeAvailability()
		self:GetTechTree():SendTechTreeUpdates({self})
	end
	
end

function Player:HandleSpecialUpgrades(self, techId)
	
	local upgraded = false
	
	// Tier one and two don't need to evolve, you just unlock it.
	if techId == kTechId.TwoHives then
		self:UnlockTierTwo()
		upgraded = true
	elseif techId == kTechId.ThreeHives then
		self:UnlockTierThree()
		upgraded = true
	elseif techId == kTechId.Shade then
		self.combatTable.hasCamouflage = true
		upgraded = true
	end

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
	
	// Don't allow the delegate function to update the tech tree - we will do it ourselves later.
	if self:isa("Marine") then  
		// do it for every up in the table      
		for i, entry in pairs(self.combatTable.techtree) do 
			self:CoCheckUpgrade_Marine(entry, true, i) 
		end
	elseif self:isa("Alien") then
		for i, entry in pairs(self.combatTable.techtree) do 
			// TODO: just get lvl back when you got a other class
			self:CoCheckUpgrade_Alien(entry, true, i)   
		end
	end            
	
	// Send updates to the client in one go.
	self:GetTechTree():ComputeAvailability()
	self:GetTechTree():SendTechTreeUpdates({self})
    self.isRespawning = false
end