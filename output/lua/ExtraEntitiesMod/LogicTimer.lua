//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// LogicTimer.lua
// Base entity for LogicTimer things

Script.Load("lua/ExtraEntitiesMod/LogicMixin.lua")

class 'LogicTimer' (Entity)

LogicTimer.kMapName = "logic_timer"
LogicTimer.kGUIScript = "ExtraEntitiesMod/GUILogicTimer"

local kDefaultWaitDelay = 10

local networkVars =
{
    //output1_id  = "entityid",    
    enabled = "boolean",
    unlockTime = "time",
    showGUI = "boolean",
}

AddMixinNetworkVars(LogicMixin, networkVars)

function LogicTimer:OnCreate()
	self.unlockTime = 0
	self.unlockTimeClient = nil
end


function LogicTimer:OnInitialized()
    
    if Server then
        InitMixin(self, LogicMixin)
        
        if not self.waitDelay then
            self.waitDelay = kDefaultWaitDelay 
        end  
    end
	
	self:SetUpdates(true)   
    
end

function LogicTimer:Reset() 
    self.unlockTime = 0
	// Stop the GUI hanging around if it is active between round resets.
	if g_GUITimer then
		GetGUIManager():DestroyGUIScript(g_GUITimer)
		g_GUITimer = nil
	end
end


function LogicTimer:OnUpdate(deltaTime)
      
	if self.enabled then
        if Server and GetGamerules():GetGameStarted() then
            self:CheckTimer()             
        elseif Client then        
            local player = Client.GetLocalPlayer()
            if player:GetGameStarted() then
                self:CheckGUI()
            end				
        end
        
    end 

    
end


function LogicTimer:CheckTimer()

    if self.enabled then
        if self.unlockTime == 0 then
            self.unlockTime = Shared.GetTime() + self.waitDelay
        end
        if Shared.GetTime() >= self.unlockTime then
            self:OnTime()
        end 
    end

end


function LogicTimer:OnLogicTrigger(player)
    self:OnTriggerAction()     
end


function LogicTimer:OnTime()
    self:TriggerOutputs()
    // to reset the timer
    if self.onTimeAction == 0 or self.onTimeAction == nil then
        self.enabled = false
        self.unlockTime = nil
    elseif self.onTimeAction == 1 then
        self:Reset()
    elseif self.onTimeAction == 2 then 
        self.unlockTime = Shared.GetTime() + self.waitDelay
    end
end

if Client then
    function LogicTimer:CheckGUI()

        local showGUI = (self.enabled and self.unlockTime ~= nil and self.showGUI)
        if not g_GUITimer then
            g_GUITimer = GetGUIManager():CreateGUIScript(LogicTimer.kGUIScript)			
        end
        
        if g_GUITimer then
            g_GUITimer:SetIsVisible(showGUI)
            
            if showGUI then
        
                local unlockTimeChanged = (self.unlockTime ~= self.unlockTimeClient)
                if unlockTimeChanged then
                    self.unlockTimeClient = self.unlockTime
                    g_GUITimer:SetEndTime(self:GetId(), self.unlockTime)
                end
                
            end
        end
    end
end


Shared.LinkClassToMap("LogicTimer", LogicTimer.kMapName, networkVars)