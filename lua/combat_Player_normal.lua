//________________________________
//
//   	Combat Mod     
//	Made by JimWest, 2012
//
//	Version 0.1
//	
//________________________________

// combat_Player_normal.lua

//___________________
// New functions,
// not hooked
//___________________


// XP-List
XpList = {}  

//Table for 
//    LVL,  needed XP to reach, RineName, AlienName, givenXP to killer     
XpList[1] = {0,	"Private", "Hatchling", 60}
XpList[2] = {100, "Private First Class" , "Xenoform", 70}
XpList[3] = {250, "Corporal" ,"Minion", 80}
XpList[4] = {250, "Sergeant", "Ambusher", 90}
XpList[5] = {700, "Lieutenant", "Attacker", 100}
XpList[6] = {1000 ,"Captain" ,"Rampager", 110}
XpList[7] = {1350 ,"Commander" ,"Slaughterer", 120}
XpList[8] = {1750 ,"Major", "Eliminator", 130}
XpList[9] = {2200 ,"Field Marshal", "Nightmare", 140}
XpList[10] = {2700, "General", "Behemoth", 150}

// List with possible Upgrades
UpsList = {}
UpsList.Marine = {}
UpsList.Marine.Weapons = { "mines", "sg", "flame", "gl", "welder"}
UpsList.Marine.others = {"dmg1", "dmg2", "dmg3", "arm1", "arm2", "arm3", "nano", "jp"}
                    
                  
UpsList.Alien = {"tier2", "tier3", "gorge", "lerk", "fade", "onos",
                 "carapace", "regen", "silence", "camo"}
     


function CombatGetKMapName(type)

    local KMapName = {mines=LayMines.kMapName , sg=Shotgun.kMapName, flame=Flamethrower.kMapName, gl=GrenadeLauncher.kMapName, welder=Welder.kMapName            
    
    } 
   
    if type then 
        return KMapName[type]
    end

end            


function Player:CoCheckUpgradeWeapon(type)
//manages the upgrades, called by console via co_spendlvl type; Type is vaild
    if (self:GetLvlFree() >= 1) then
        //Lvls are free, do the upgrade
        if self:GetIsAlive() then
            Player.InitWeapons(self)
            self:DestroyWeapons()
            self:GiveItem(CombatGetKMapName(type))
        end
        // insert the weapon to the personal techtree
        table.insert(self.combatTable.techtree, "sg")
        //subtrate one lvl
        self.combatTable.lvlfree = self.combatTable.lvlfree - 1
    else
        Shared.Message("No free Lvl")
    end

end

function Player:CoCheckUpgradeOther(type)
//manages the upgrades, called by console via co_spendlvl type; Type is vaild
    if (self:GetLvlFree() >= 1) then
        //Lvls are free, do the upgrade
        
    else
        Shared.Message("No free Lvl")
    end

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

    if amount then
        if self:GetXp() then        
            self.combatTable.xp = self.combatTable.xp + amount
        else
            self.combatTable.xp = amount
        end     
    end        
    self:CheckLvlUp(self.combatTable.xp)    
end


function Player:CheckLvlUp(xp)
//ToDo: Levels and XP System
    if xp and (self:GetLvl() < 10 ) then
        
        if (xp >= XpList[self:GetLvl()+1][1]) then
        //Lvl UP
            self.combatTable.lvl =  self.combatTable.lvl + 1
            self:SendDirectMessage( "!! Level UP !! New Lvl: " .. self:GetLvl()) 
            self.combatTable.lvlfree = self.combatTable.lvlfree + 1
            // ToDo find out if rine or Alien and do a different name
            self:SendDirectMessage(XpList[self:GetLvl()][2])       
            self:SendDirectMessage( self:GetXp() .. " XP; " .. (XpList[self.combatTable.lvl + 1][1] - self:GetXp()).. " XP missing")
        else        
            self:SendDirectMessage( self:GetXp() .. " XP; " .. (XpList[self.combatTable.lvl + 1][1] - self:GetXp()).. " XP missing")
        end     
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