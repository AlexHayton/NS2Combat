//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// GUILogicTimer.lua

Script.Load("lua/Factions/Factions_Utility.lua")

class 'GUILogicTimer' (GUIAnimatedScript)

GUILogicTimer.kBackgroundTexture = "ui/Factions/timer/timer_bg.dds"

GUILogicTimer.kBackgroundWidth = GUIScale(135)
GUILogicTimer.kBackgroundHeight = GUIScale(50)
GUILogicTimer.kBackgroundOffsetX = GUIScale(0)
GUILogicTimer.kBackgroundOffsetY = GUIScale(0)

GUILogicTimer.kTimeOffset = Vector(0, GUIScale(-5), 0)
GUILogicTimer.kTimeFontName = "fonts/Arial_20.fnt"
GUILogicTimer.kTimeFontSize = 20
GUILogicTimer.kTimeBold = true

GUILogicTimer.kBgCoords = {14, 0, 112, 34}

GUILogicTimer.kBackgroundColor = Color(1, 1, 1, 0.7)
GUILogicTimer.kMarineTextColor = kMarineFontColor
GUILogicTimer.kAlienTextColor = kAlienFontColor

local function GetTeamType()

	local player = Client.GetLocalPlayer()
	
	if not player:isa("ReadyRoomPlayer") then	
		local teamnumber = player:GetTeamNumber()
		local teamType = GetGamerulesInfo():GetTeamType(teamnumber)
		if teamType == kMarineTeamType then
			return "Marines"
		elseif teamType == kAlienTeamType then
			return "Aliens"
		elseif teamType == kNeutralTeamType then 
			return "Spectator"
		else
			return "Unknown"
		end
	else
		return "Ready Room"
	end
	
end


function GUILogicTimer:Initialize()    

	GUIAnimatedScript.Initialize(self)
	
	self.timers = {}
    
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
    self.timerBackground:SetSize( Vector(GUILogicTimer.kBackgroundWidth, GUILogicTimer.kBackgroundHeight, 0) )
    self.timerBackground:SetPosition(Vector(GUILogicTimer.kBackgroundOffsetX - (GUILogicTimer.kBackgroundWidth / 2), GUILogicTimer.kBackgroundOffsetY, 0))
    self.timerBackground:SetAnchor(GUIItem.Middle, GUIItem.Top) 
    self.timerBackground:SetLayer(kGUILayerPlayerHUD)
    self.timerBackground:SetTexture(GUILogicTimer.kBackgroundTexture)
    self.timerBackground:SetTexturePixelCoordinates(unpack(GUILogicTimer.kBgCoords))
	self.timerBackground:SetColor( GUILogicTimer.kBackgroundColor )
	self.timerBackground:SetIsVisible(false)
	
	// Time remaining
    self.timeRemainingText = self:CreateAnimatedTextItem()
    self.timeRemainingText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.timeRemainingText:SetPosition(GUILogicTimer.kTimeOffset)
	self.timeRemainingText:SetLayer(kGUILayerPlayerHUDForeground1)
	self.timeRemainingText:SetTextAlignmentX(GUIItem.Align_Center)
    self.timeRemainingText:SetTextAlignmentY(GUIItem.Align_Center)
	self.timeRemainingText:SetText("")
	self.timeRemainingText:SetColor(Color(1,1,1,1))
	self.timeRemainingText:SetFontSize(GUILogicTimer.kTimeFontSize)
    self.timeRemainingText:SetFontName(GUILogicTimer.kTimeFontName)
	self.timeRemainingText:SetFontIsBold(GUILogicTimer.kTimeBold)
	self.timeRemainingText:SetIsVisible(true)
 
	self.background:AddChild(self.timerBackground)
	self.timerBackground:AddChild(self.timeRemainingText)
    self:Update(0)

end

function GUILogicTimer:GetTimeRemaining()
	local timeLeft = 0
	if self.endTime then
		timeLeft = self.endTime - Shared.GetTime()
	end
	return timeLeft
end

function GUILogicTimer:GetTimers()
	return self.timers
end

function GUILogicTimer:GetTimer(timerName)
	return self.timers[timerName]
end

function GUILogicTimer:AddTimer(timerName, endTime)
	self.timers[timerName] = { Name = timerName, EndTime = endTime }
end

function GUILogicTimer:GetEndTime(timerName)
	local timer = self:GetTimer(timerName)
	local endTime = 0
	if timer then
		endTime = timer.EndTime
	end
end

function GUILogicTimer:SetEndTime(timerName, newTime)
	local timer = self:GetTimer(timerName)
	if timer then
		timer.EndTime = newTime
	else
		self:AddTimer(timerName, endTime)
	end
end

// Gets the time in the format "mm:ss:ms"
local function GetTimeDigital(timeInSeconds, showMinutes, showMilliseconds)

	local timeLeftText = ""
	timeNumericSeconds = tonumber(timeInSeconds)
	if (timeNumericSeconds < 0) then 
		timeLeftText = "- "
	end
	timeNumericSeconds = math.abs(tonumber(timeInSeconds))
	
	if showMinutes then
		local timeLeftMinutes = math.floor(timeNumericSeconds/60)
		if (timeLeftMinutes < 10) then
			timeLeftText = timeLeftText .. "0" .. timeLeftMinutes
		else
			timeLeftText = timeLeftText .. timeLeftMinutes
		end
	
		timeLeftText = timeLeftText .. ":"
	end
	
	timeLeftSeconds = math.floor(timeNumericSeconds % 60)
	if (timeLeftSeconds < 10) then
		timeLeftText = timeLeftText .. "0" .. timeLeftSeconds
	else
		timeLeftText = timeLeftText .. timeLeftSeconds
	end
	
	// Disable milliseconds by default. They are *really* annoying.
	if showMilliseconds then
		timeLeftText = timeLeftText .. ":"
	
		local timeLeftMilliseconds = math.ceil((timeNumericSeconds * 100) % 100)
		if (timeLeftMilliseconds < 10) then
			timeLeftText = timeLeftText .. "0" .. timeLeftMilliseconds
		else
			timeLeftText = timeLeftText .. timeLeftMilliseconds
		end
	end
	
	return timeLeftText

end

function GUILogicTimer:GetTimeRemainingDigital()
	local timer = self:GetTimer(timerName)
	local timeRemaining = "-"
	if timer then
		timeRemaining = GetTimeDigital(timer.EndTime - Shared.GetTime(), true, false)
	end
	return timeRemaining
end

function GUILogicTimer:Update(deltaTime)

    local player = Client.GetLocalPlayer()
	
	// Alter the display based on team, status.
	local newTeam = false
	if (self.playerTeam ~= GetTeamType()) then
		self.playerTeam = GetTeamType()
		newTeam = true
	end
	
	if (newTeam) then
		if (self.playerTeam == "Marines") then
			self.timeRemainingText:SetColor(GUILogicTimer.kMarineTextColor)
			self.showTimer = true
		elseif (self.playerTeam == "Aliens") then
			self.timeRemainingText:SetColor(GUILogicTimer.kAlienTextColor)
			self.showTimer = true
		else
			self.timerBackground:SetIsVisible(false)
			self.showTimer = false
		end
	end
    
	local player = Client.GetLocalPlayer()
	if (self.showTimer and player:GetIsAlive()) then
		self.timerBackground:SetIsVisible(true)
		local TimeRemaining = self:GetTimeRemainingDigital()
		self.timeRemainingText:SetText(TimeRemaining)
	else
		self.timerBackground:SetIsVisible(false)
	end

end


function GUILogicTimer:Uninitialize()

	GUI.DestroyItem(self.timeRemainingText)
	GUI.DestroyItem(self.timerBackground)
    GUI.DestroyItem(self.background)

end