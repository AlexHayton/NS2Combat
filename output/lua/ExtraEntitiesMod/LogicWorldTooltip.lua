//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// modified from WorlToolTop

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'LogicWorldTooltip' (Entity)

LogicWorldTooltip.kMapName            = "logic_worldtooltip"

local networkVars = { 
    tooltipText = string.format("string (%d)", 256),
    enabled = "boolean",
    shownOnce = "boolean",
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicWorldTooltip:OnCreate()

    Entity.OnCreate(self)
    
end

function LogicWorldTooltip:OnInitialized()
    self.tooltipText = self.tooltip    
    
    if Server then
        InitMixin(self, LogicMixin)     
    end
    self.shownPlayers = {}
    self:SetUpdates(false)   
end

function LogicWorldTooltip:Reset()
    self.shownPlayers = {}  
end

function LogicWorldTooltip:GetTooltipText(player)    
    if self.enabled then
        local showOk = true
        local playerId = player:GetId()
        if self.shownOnce then 
            for i, shownPlayerId in ipairs(self.shownPlayers) do            
                if shownPlayerId == playerId  then
                    showOk = false
                    break
                end
            end
        end
        
        if showOk then
            local string = Locale.ResolveString(self.tooltipText)
            table.insertunique(self.shownPlayers, playerId )
            
            return SubstituteBindStrings(string)
        else
            return nil
        end
    end
end 

function LogicWorldTooltip:OnLogicTrigger()
	self:OnTriggerAction()
end 


Shared.LinkClassToMap("LogicWorldTooltip", LogicWorldTooltip.kMapName, networkVars)