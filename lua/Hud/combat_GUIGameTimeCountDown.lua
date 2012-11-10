//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIGameTimeCountDown.lua

Script.Load("lua/combat_Utility.lua")

class 'combat_GUIGameTimeCountDown' (GUIAnimatedScript)

combat_GUIGameTimeCountDown.kBackgroundTexture = "ui/alien_commander_background.dds"

combat_GUIGameTimeCountDown.kBackgroundWidth = GUIScale(210)
combat_GUIGameTimeCountDown.kBackgroundHeight = GUIScale(115)
combat_GUIGameTimeCountDown.kBackgroundOffsetX = GUIScale(0)
combat_GUIGameTimeCountDown.kBackgroundOffsetY = GUIScale(10)

combat_GUIGameTimeCountDown.kTitleOffset = Vector(0, GUIScale(30), 0)
combat_GUIGameTimeCountDown.kTitleFontName = "fonts/AgencyFB_small.fnt"
combat_GUIGameTimeCountDown.kTitleFontSize = 12

combat_GUIGameTimeCountDown.kTimeOffset = Vector(0, GUIScale(80), 0)
combat_GUIGameTimeCountDown.kTimeFontName = "fonts/AgencyFB_large.fnt"
combat_GUIGameTimeCountDown.kTimeFontSize = 30
combat_GUIGameTimeCountDown.kTimeBold = true

combat_GUIGameTimeCountDown.kBgCoords = {805, 15, 942, 87}

combat_GUIGameTimeCountDown.kBackgroundColor = Color(1, 1, 1, 0.8)
combat_GUIGameTimeCountDown.kMarineTextColor = Color(1.0, 1.0, 1.0, 1)
combat_GUIGameTimeCountDown.kAlienTextColor = Color(0.9, 0.7, 0.7, 1)

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
	self.timerBackground:SetColor( Color(1, 1, 1, 0) )
	self.timerBackground:SetIsVisible(false)
    
    // Time remaining title
    self.timeRemainingTitle = self:CreateAnimatedTextItem()
    self.timeRemainingTitle:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.timeRemainingTitle:SetPosition(combat_GUIGameTimeCountDown.kTitleOffset)
	self.timeRemainingTitle:SetLayer(kGUILayerPlayerHUDForeground1)
	self.timeRemainingTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.timeRemainingTitle:SetTextAlignmentY(GUIItem.Align_Center)
	self.timeRemainingTitle:SetText(Combat_ResolveString("TIME_REMAINING"))
	self.timeRemainingTitle:SetColor(Color(1,1,1,1))
	self.timeRemainingTitle:SetFontSize(combat_GUIGameTimeCountDown.kTitleFontSize)
    self.timeRemainingTitle:SetFontName(combat_GUIGameTimeCountDown.kTitleFontName)
	self.timeRemainingTitle:SetIsVisible(true)
	
	// Time remaining
    self.timeRemainingText = self:CreateAnimatedTextItem()
    self.timeRemainingText:SetAnchor(GUIItem.Middle, GUIItem.Top)
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
    self.timerBackground:AddChild(self.timeRemainingTitle)
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
	local newTeam = false
	if (self.playerTeam ~= GetTeamType()) then
		self.playerTeam = GetTeamType()
		newTeam = true
	end
	
	if (newTeam) then
		if (self.playerTeam == "Marines") then
			self.timerBackground:SetColor(Color(1,1,1,0))
			self.timeRemainingTitle:SetColor(combat_GUIGameTimeCountDown.kMarineTextColor)
			self.timeRemainingText:SetColor(combat_GUIGameTimeCountDown.kMarineTextColor)
			self.showTimer = true
		elseif (self.playerTeam == "Aliens") then
			self.timerBackground:SetColor(Color(1,1,1,1))
			self.timeRemainingTitle:SetColor(combat_GUIGameTimeCountDown.kAlienTextColor)
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
		self.timeRemainingText:SetText(TimeRemaining)
	else
		self.timerBackground:SetIsVisible(false)
	end

end


function combat_GUIGameTimeCountDown:Uninitialize()

	GUI.DestroyItem(self.timeRemainingText)
    GUI.DestroyItem(self.timeRemainingTitle)
	GUI.DestroyItem(self.timerBackground)
    GUI.DestroyItem(self.background)

end