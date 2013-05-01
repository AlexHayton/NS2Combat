//________________________________
//
//   	NS2 Single-Player Mod   
//  	Made by JimWest, 2012
//
//________________________________

// LogicGiveItem.lua
// Base entity for LogicGiveItem things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'LogicGiveItem' (Entity)

LogicGiveItem.kMapName = "logic_give_item"

local networkVars = 
{
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicGiveItem:OnCreate()
end

function LogicGiveItem:OnInitialized()    
    if Server then
        InitMixin(self, LogicMixin)
    end
end

function LogicGiveItem:OnLogicTrigger(player)    

    if player then
        local items = {}     
      
        if self.type == 0 then
            table.insert(items, Axe.kMapName)        
        elseif self.type == 1 then
            // due to a bug we need to get axe first
            if not player:GetWeaponInHUDSlot(3) then
                table.insert(items, Axe.kMapName) 
            end
            table.insert(items, Welder.kMapName)        
        elseif self.type == 2 then
            table.insert(items, Pistol.kMapName)
        elseif self.type == 3 then
            table.insert(items, Rifle.kMapName)
        elseif self.type == 4 then
            table.insert(items, Rifle.kMapName)
            table.insert(items, Pistol.kMapName)
            table.insert(items, Axe.kMapName)
        elseif self.type == 5 then
            table.insert(items, Shotgun.kMapName)
        elseif self.type == 6 then
            table.insert(items, FlameThrower.kMapName)
        elseif self.type == 7 then
            table.insert(items, GrenadeLauncher.kMapName)
        elseif self.type == 8 then
            table.insert(items, LayMines.kMapName)
        elseif self.type == 9 then
            local exoMarine = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, player:GetOrigin(), { layout = "ClawMinigun" })
        elseif self.type == 10 then
            local exoMarine = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, player:GetOrigin(), { layout = "MinigunMinigun" })
        elseif self.type == 11 then
            local exoMarine = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, player:GetOrigin(), { layout = "ClawRailgun" })
        elseif self.type == 12 then
            local exoMarine = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, player:GetOrigin(), { layout = "RailgunRailgun" })
        elseif self.type == 13 then
            local jetpackMarine = self:Replace(JetpackMarine.kMapName, self:GetTeamNumber(), true, Vector(self:GetOrigin()))
        
        elseif self.type == 99 then
            player.hudAllowed = true            
        end
        
        for i, item in ipairs(items) do
            player:GiveItem(item)
        end
    end
    
end


Shared.LinkClassToMap("LogicGiveItem", LogicGiveItem.kMapName, networkVars)