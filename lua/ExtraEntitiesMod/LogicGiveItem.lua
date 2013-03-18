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
            player.hudAllowed = true            
        end
        
        for i, item in ipairs(items) do
            player:GiveItem(item)
        end
    end
    
end


Shared.LinkClassToMap("LogicGiveItem", LogicGiveItem.kMapName, networkVars)