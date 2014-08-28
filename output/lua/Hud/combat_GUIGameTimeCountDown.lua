//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIGameTimeCountDown.lua

Script.Load("lua/combat_Utility.lua")

class 'combat_GUIGameTimeCountDown' (GUIAnimatedScript)

combat_GUIGameTimeCountDown.kBackgroundTexture = "ui/combat_count_down_bg.dds"

combat_GUIGameTimeCountDown.kBackgroundWidth = GUIScale(135)
combat_GUIGameTimeCountDown.kBackgroundHeight = GUIScale(50)
combat_GUIGameTimeCountDown.kBackgroundOffsetX = GUIScale(0)
combat_GUIGameTimeCountDown.kBackgroundOffsetY = GUIScale(0)

combat_GUIGameTimeCountDown.kTimeOffset = Vector(0, GUIScale(-5), 0)
combat_GUIGameTimeCountDown.kTimeFontName = Fonts.kAgencyFB_Small
combat_GUIGameTimeCountDown.kTimeFontSize = 16
combat_GUIGameTimeCountDown.kTimeBold = true

combat_GUIGameTimeCountDown.kBgCoords = {14, 0, 112, 34}

combat_GUIGameTimeCountDown.kBackgroundColor = Color(1, 1, 1, 0.7)
combat_GUIGameTimeCountDown.kMarineTextColor = kMarineFontColor
combat_GUIGameTimeCountDown.kAlienTextColor = kAlienFontColor

function combat_GUIGameTimeCountDown:Initialize()    

	GUIAnimatedScript.Initialize(self)
    
	// Used for Global Offset
	self.background = self:CreateAnimatedGraphicItem()
    self.background:SetIsScaling(false)
    self.background:SetSize( Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0) )
    self.background:SetPosition( Vector(0, 0, 0) ) 
    self.background:SetIsVisible(true)
    self.background:SetLayer(kGUILayerPlayerHUDBackground)
    self.background:SetColor( Color(1, 1, 1, 0) )
	
    // Timer display background
    self.timerBackground = self:CreateAnimatedGraphicItem()
    self.timerBackground:SetSize( Vector(combat_GUIGameTimeCountDown.kBackgroundWidth, combat_GUIGameTimeCountDown.kBackgroundHeight, 0) )
    self.timerBackground:SetPosition(Vector(combat_GUIGameTimeCountDown.kBackgroundOffsetX - (combat_GUIGameTimeCountDown.kBackgroundWidth / 2), combat_GUIGameTimeCountDown.kBackgroundOffsetY, 0))
    self.timerBackground:SetAnchor(GUIItem.Middle, GUIItem.Top) 
    self.timerBackground:SetLayer(kGUILayerPlayerHUD)
    self.timerBackground:SetTexture(combat_GUIGameTimeCountDown.kBackgroundTexture)
    self.timerBackground:SetTexturePixelCoordinates(unpack(combat_GUIGameTimeCountDown.kBgCoords))
	self.timerBackground:SetColor( combat_GUIGameTimeCountDown.kBackgroundColor )
	self.timerBackground:SetIsVisible(false)
	
	// Time remaining
    self.timeRemainingText = self:CreateAnimatedTextItem()
    self.timeRemainingText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.timeRemainingText:SetPosition(combat_GUIGameTimeCountDown.kTimeOffset)
	self.timeRemainingText:SetLayer(kGUILayerPlayerHUDForeground1)
	self.timeRemainingText:SetTextAlignmentX(GUIItem.Align_Center)
    self.timeRemainingText:SetTextAlignmentY(GUIItem.Align_Center)
	self.timeRemainingText:SetText("")
	self.timeRemainingText:SetColor(Color(1,1,1,1))
	self.timeRemainingText:SetFontSize(combat_GUIGameTimeCountDown.kTimeFontSize)
    self.timeRemainingText:SetFontName(combat_GUIGameTimeCountDown.kTimeFontName)
	self.timeRemainingText:SetFontIsBold(combat_GUIGameTimeCountDown.kTimeBold)
	self.timeRemainingText:SetIsVisible(true)
 
	self.background:AddChild(self.timerBackground)
	self.timerBackground:AddChild(self.timeRemainingText)
    self:Update(0)

end

local function GetTeamType()

	local player = Client.GetLocalPlayer()
	
	if not player:isa("ReadyRoomPlayer") then	
		local teamnumber = player:GetTeamNumber()
		if teamnumber == kAlienTeamType then
			return "Aliens"
		elseif teamnumber == kMarineTeamType then
			return "Marines"
		elseif teamnumber == kNeutralTeamType then 
			return "Spectator"
		else
			return "Unknown"
		end
	else
		return "Ready Room"
	end
	
end

function combat_GUIGameTimeCountDown:Update(deltaTime)

    local player = Client.GetLocalPlayer()
	
	// Alter the display based on team, status.
	if player then
		local newTeam = false
		if (self.playerTeam ~= GetTeamType()) then
			self.playerTeam = GetTeamType()
			newTeam = true
		end
		
		if (newTeam) then
			if (self.playerTeam == "Marines") then
				self.timeRemainingText:SetColor(combat_GUIGameTimeCountDown.kMarineTextColor)
				self.showTimer = true
			elseif (self.playerTeam == "Aliens") then
				self.timeRemainingText:SetColor(combat_GUIGameTimeCountDown.kAlienTextColor)
				self.showTimer = true
			else
				self.timerBackground:SetIsVisible(false)
				self.showTimer = false
			end
		end
		
		// Update the client-side clock.
		kCombatTimeSinceGameStart = kCombatTimeSinceGameStart + deltaTime
		
		local player = Client.GetLocalPlayer()
		if (self.showTimer and player:GetIsAlive()) then
			self.timerBackground:SetIsVisible(true)
			local TimeRemaining = PlayerUI_GetTimeRemaining()
			if TimeRemaining == "00:00:00" then		    
				self.timeRemainingText:SetText("Overtime")
			else
				self.timeRemainingText:SetText(TimeRemaining)
			end
			
			self:RemindTime(player)
			
		else
			self.timerBackground:SetIsVisible(false)
		end
		
	end

end


function combat_GUIGameTimeCountDown:RemindTime(player)
		
    // send timeleft chat things now here, all client sided
    if (kCombatTimeLimit ~= nil) then
        local timeLeft = math.ceil((kCombatTimeLimit - kCombatTimeSinceGameStart))
        if  timeLeft > 0 and
            ((timeLeft % kCombatTimeReminderInterval) == 0 or 
             (timeLeft == 60) or (timeLeft == 30) or
             (timeLeft == 20) or (timeLeft == 10) or
             (timeLeft <= 5)) then
            
            local timeLeftText = GetTimeText(timeLeft)
            local team1Message = ""
            local team2Message = ""
            
            if not lastTimeLeftText or timeLeftText ~= lastTimeLeftText then
            
                if kCombatDefaultWinner == kTeam2Index then
                    team1Message = " left until Marines have lost!"
                    team2Message = " left until Aliens have won!"						
                else
                    team1Message = " left until Marines have won!"
                    team2Message = " left until Aliens have lost!"											
                end
                
                if timeLeft >= 0 and kCombatAllowOvertime then
                    team1Message = " left until overtime!"
                    team2Message = " left until overtime!"
                end

                if player:GetTeamNumber() == 1 then
                    ChatUI_AddSystemMessage(timeLeftText .. team1Message)
                else
                    ChatUI_AddSystemMessage(timeLeftText .. team2Message)
                end
                
                lastTimeLeftText = timeLeftText
                
            end
            
        end	
    end
    
end


function combat_GUIGameTimeCountDown:Uninitialize()

	GUI.DestroyItem(self.timeRemainingText)
	GUI.DestroyItem(self.timerBackground)
    GUI.DestroyItem(self.background)

end