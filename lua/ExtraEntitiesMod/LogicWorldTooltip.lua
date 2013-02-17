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
    tooltipText = string.format("string (%d)", kMaxEntityStringLength),
    enabled = "boolean",
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
    
    self:SetUpdates(false)   
end

function LogicWorldTooltip:GetTooltipText()
    if self.enabled then
        local string = Locale.ResolveString(self.tooltipText)
        return SubstituteBindStrings(string)
    end
end 

function LogicWorldTooltip:OnLogicTrigger()
    if self.enabled then
        self.enabled = false 
    else
        self.enabled = true
    end     
end 


Shared.LinkClassToMap("LogicWorldTooltip", LogicWorldTooltip.kMapName, networkVars)