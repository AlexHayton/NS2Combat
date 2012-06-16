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
     
// Do Upgrade, called by console, type and team is checked and is valid
// ToDo: what happens if I wanna have another weapon -> erase other weapon ot of the personal table
// ToDo: do i have everything necessery?
function Player:CoCheckUpgrade_Marine(upgrade, respawning)
    
    local doUpgrade = false
    
    if UpsList.Marine[upgrade] then
    
        local type = UpsList.Marine[upgrade][4]
        local neededLvl = UpsList.Marine[upgrade][3]
        local neededOtherUp = UpsList.Marine[upgrade][2]
        local kMapName =  UpsList.Marine[upgrade][1]
        doUpgrade = true

        // do i have the Up already?
        if self.combatTable then
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
                     
            if ((self.combatTable.lvlfree >=  neededLvl and doUpgrade and not neededOtherUp) or respawning) then
            

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
                        
                        self:GiveItem(kMapName)
                    end       
                
                elseif type == "tech" then
                    // ToDo: There's still a bug, everbody get my tech                    

                    self:GetTechTree():GiveUpgrade(kMapName)  
                    
                elseif type == "class" then
                    if self:GetIsAlive() then
                        // can't replace somebody who's respawning at the moment, give him the class later
                        if not respawning then
                            // Jps get the lmg back, so get the old weapon (but only directly after up, after dying its all OK)
                            // TODO; when EXO finished, what happen with it?
                            
                            self:GiveJetpack() 
                            self.combatTable.giveClassAfterRespawn = kMapName

                        end
                    end
                end

                if not respawning then
                    // insert the up to the personal techtree
                    table.insert(self.combatTable.techtree, upgrade)
                    // subtract the needed lvl
                    self.combatTable.lvlfree = self.combatTable.lvlfree -  neededLvl
                end
              
            else
                if doUpgrade then
                    if neededOtherUp then
                        Shared.Message("You need " .. neededOtherUp .. " first")
                        self:SendDirectMessage("You need " .. neededOtherUp .. " first")
                    else
                        Shared.Message("No free Lvl, you need at last ".. neededLvl .. " free Lvl")
                        self:SendDirectMessage("No free Lvl, you need at last ".. neededLvl .. " free Lvl")
                    end
                else
                    Shared.Message("You already own that Upgrade")
                    self:SendDirectMessage("You already own that Upgrade")
                end
            end        
        end
    end
end

// Special treatment for alien evolutions (eggs etc.)

//ToDo: there is a bug where aliens cant get tech, cara etc.
function Player:CoCheckUpgrade_Alien(upgrade, respawning, position)

    local doUpgrade = false
    
    if UpsList.Alien[upgrade] then
  
        local type = UpsList.Alien[upgrade][4]
        local neededLvl = UpsList.Alien[upgrade][3]
        local neededOtherUp = UpsList.Alien[upgrade][2]
        local kMapName =  UpsList.Alien[upgrade][1]
        doUpgrade = true
        // this is needed if there is no room for an egg
        upgradeOK = true

        // do i have the Up already?
        if self.combatTable then
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
                     
            if ((self.combatTable.lvlfree >=  neededLvl and doUpgrade and not neededOtherUp) or respawning) then

                    
                if type == "tech" then
                    if self:GetIsAlive() then
                        if respawning then
                            // no evolving when respawning
                            success = self:GetTechTree():GiveUpgrade(kMapName)
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
                            self.combatTable.lvlfree = self.combatTable.lvlfree + neededLvl
                            table.remove(self.combatTable.techtree, position)
                        else
                            //self:Replace(kMapName, self:GetTeamNumber(), false)  
                            upgradeOK = self:CoEvolve(kMapName)            
                        end
                    end
                end
         
                if not respawning then
                    if  upgradeOK then
                        // insert the up to the personal techtree
                        table.insert(self.combatTable.techtree, upgrade)
                        // subtrate the needed lvl
                        self.combatTable.lvlfree = self.combatTable.lvlfree - neededLvl
                    else
                        Shared.Message("Upgrade failed, maybe not enough room") 
                        self:SendDirectMessage("Upgrade failed, maybe not enough room") 
                    end  
                end
          
            else
                if doUpgrade then
                    if neededOtherUp then
                        Shared.Message("You need " .. neededOtherUp .. " first")
                        self:SendDirectMessage("You need " .. neededOtherUp .. " first")
                    else
                        Shared.Message("No free Lvl, you need at last ".. neededLvl .. " free Lvl")
                        self:SendDirectMessage("No free Lvl, you need at last ".. neededLvl .. " free Lvl")
                    end
                else
                    Shared.Message("You already own that Upgrade")
                    self:SendDirectMessage("You already own that Upgrade")
                end
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

        // SetGestationData needs a table, so give him one
        local techIds = {}
        table.insert(techIds, techId)
        newPlayer:SetGestationData(techIds, self:GetTechId(), healthScalar, armorScalar)

        success = true
    end
    
    return success
end


// Gimme my Ups back, called from "CopyPlayerData" 
function Player:GiveUpsBack()
    if self.combatTable then          
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
    end
    
    self.isRespawning = false
end


function Player:GetXp()
    if self.combatTable then
        return self.combatTable.xp
    else
        return 0    
    end         
end

function Player:GetLvl()
    if self.combatTable then
        return self.combatTable.lvl
    else
        return 1
    end
end

function Player:GetLvlFree()
    if self.combatTable then
        return self.combatTable.lvlfree
    else
        return 0
    end

end

function Player:AddXp(amount)

    if amount and (self:GetLvl() < 10 )  then
        if self:GetXp() and self.combatTable then 

            // For testing the xp System
            self:SendDirectMessage(amount .. " XP gained")       
            
            self.combatTable.xp = self.combatTable.xp + amount
            self:CheckLvlUp(self.combatTable.xp) 
        else
            // due to a bug, we need to set the combatTable here (calling replace_hook doesn't work
            self.combatTable = {}  
            self.combatTable.xp = 0
            self.combatTable.lvl = 1
            self.combatTable.lvlfree = 0
            
            self.combatTable.techtree = {}
            
            // save every Update in the personal techtree            
            self.combatTable.xp = amount
            self:CheckLvlUp(self.combatTable.xp) 
        end     
    else
        // Max Lvl reached
    end        
       
end


function Player:CheckLvlUp(xp)
//ToDo: Levels and XP System
    if xp and (self:GetLvl() < 10 ) then
       
        if (xp >= XpList[self:GetLvl()+1]["XP"]) then
			//Lvl UP
								
            self.combatTable.lvl =  self.combatTable.lvl + 1
            self:SendDirectMessage( "!! Level UP !! New Lvl: " .. self:GetLvl()) 
            self.combatTable.lvlfree = self.combatTable.lvlfree + 1
            // ToDo find out if rine or Alien and do a different name
			local RankName = ""
			if (self:GetTeamNumber() == 1) then
				RankName = XpList[self:GetLvl()]["MarineName"]
			else
				RankName = XpList[self:GetLvl()]["AlienName"]
			end
			self:SendDirectMessage(RankName)
			
			// Stop errors when you reach the max level
			if (self:GetLvl() < 10) then
				self:SendDirectMessage( self:GetXp() .. " XP: " .. (XpList[self.combatTable.lvl + 1]["XP"] - self:GetXp()).. " XP missing")
			end
						
            // make sure that we get every lvl we've earned
			local restXp = 0
            restXp = xp - XpList[self:GetLvl()+1]["XP"] 
            
            if restXp > 0 then
                self:CheckLvlUp(restXp)
			end
			
        else        
            self:SendDirectMessage( self:GetXp() .. " XP: " .. (XpList[self.combatTable.lvl + 1]["XP"] - self:GetXp()).. " XP missing")
        end     
    end
end

function Player:GetAvgXp()

    local avgXp = 0
    local allXp = 0
    // the new joined player doesn't count here
    local playerNumbers = table.maxn(GetGamerules().team1.playerIds) + table.maxn(GetGamerules().team2.playerIds) -1
    
    for i, player in ientitylist(Shared.GetEntitiesWithClassname("Player")) do      
        allXp = allXp + (player:GetXp() or 0)
    end
    
    if allXp > 0 and playerNumbers > 0 then
        avgXp =  math.floor((allXp /  playerNumbers) * avgXpAmount)   
    end
    
    return avgXp

end

function Player:SendDirectMessage(message)
//Sending LVL Msg only to the Player  
        local playerName = "Combat: " .. self:GetName()
        local playerLocationId = -1
        local playerTeamNumber = kTeamReadyRoom
        local playerTeamType = kNeutralTeamType

        Server.SendNetworkMessage(self, "Chat", BuildChatMessage(true, playerName, playerLocationId, playerTeamNumber, playerTeamType, message), true)
end