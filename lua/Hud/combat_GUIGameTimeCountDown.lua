//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIGameTimeCountDown.lua

Script.Load("lua/combat_Utility.lua")

class 'combat_GUIGameTimeCountDown' (GUIScript)

combat_GUIGameTimeCountDown.kBackgroundTexture = "ui/alien_commander_background.dds"

combat_GUIGameTimeCountDown.kBackgroundWidth = GUIScale(32)
combat_GUIGameTimeCountDown.kBackgroundHeight = GUIScale(144)
combat_GUIGameTimeCountDown.kBackgroundOffsetX = GUIScale(15)
combat_GUIGameTimeCountDown.kBackgroundOffsetY = GUIScale(-30)

combat_GUIGameTimeCountDown.kBoxWidth = GUIScale(130)
combat_GUIGameTimeCountDown.kBoxHeight = GUIScale(70)

combat_GUIGameTimeCountDown.kTitleOffset = Vector(0, GUIScale(10), 0)
combat_GUIGameTimeCountDown.kTitleFontName = "MicrogrammaDMedExt"
combat_GUIGameTimeCountDown.kTitleFontSize = 12

combat_GUIGameTimeCountDown.kTimeOffset = Vector(0, GUIScale(0), 0)
combat_GUIGameTimeCountDown.kTimeFontName = "MicrogrammaDBolExt"
combat_GUIGameTimeCountDown.kTimeFontSize = 30
combat_GUIGameTimeCountDown.kTimeBold = true

combat_GUIGameTimeCountDown.kBgCoords = {805, 15, 939, 87}

combat_GUIGameTimeCountDown.kBackgroundColor = Color(1, 1, 1, 0.8)
combat_GUIGameTimeCountDown.kMarineTextColor = Color(1.0, 1.0, 1.0, 1)
combat_GUIGameTimeCountDown.kAlienTextColor = Color(0.9, 0.7, 0.7, 1)

function combat_GUIGameTimeCountDown:Initialize()    
    
    // Timer display background
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(combat_GUIGameTimeCountDown.kBackgroundWidth, combat_GUIGameTimeCountDown.kBackgroundHeight, 0) )
    self.background:SetPosition(Vector(combat_GUIGameTimeCountDown.kBackgroundWidth / 2 + combat_GUIGameTimeCountDown.kBackgroundOffsetX, -combat_GUIGameTimeCountDown.kBackgroundHeight / 2 + combat_GUIGameTimeCountDown.kBackgroundOffsetY, 0))
    self.background:SetAnchor(GUIItem.Right, GUIItem.Top) 
    self.background:SetLayer(kGUILayerPlayerHUD)
    self.background:SetTexture(combat_GUIGameTimeCountDown.kBackgroundTexture)
    self.background:SetTexturePixelCoordinates(unpack(combat_GUIGameTimeCountDown.kBgCoords))
	self.background:SetIsVisible(false)
    
    // Time remaining title
    self.timeRemainingTitle = GUIManager:CreateGraphicItem()
    self.timeRemainingTitle:SetAnchor(GUIItem.Middle, GUIItem.Top)
    self.timeRemainingTitle:SetPosition(combat_GUIGameTimeCountDown.kTitleOffset)
	self.timeRemainingTitle:SetTextAlignmentX(GUIItem.Align_Center)
    self.timeRemainingTitle:SetTextAlignmentY(GUIItem.Align_Center)
	self.timeRemainingTitle:SetFontSize(combat_GUIGameTimeCountDown.kTitleFontSize)
    self.timeRemainingTitle:SetFontName(combat_GUIGameTimeCountDown.kTitleFontName)
	self.timeRemainingTitle:SetIsVisible(true)
	
	// Time remaining
    self.timeRemainingText = GUIManager:CreateGraphicItem()
    self.timeRemainingText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.timeRemainingText:SetPosition(combat_GUIGameTimeCountDown.kTimeOffset)
	self.timeRemainingText:SetTextAlignmentX(GUIItem.Align_Center)
    self.timeRemainingText:SetTextAlignmentY(GUIItem.Align_Center)
	self.timeRemainingText:SetFontSize(combat_GUIGameTimeCountDown.kTimeFontSize)
    self.timeRemainingText:SetFontName(combat_GUIGameTimeCountDown.kTimeFontName)
	self.timeRemainingText:SetFontIsBold(combat_GUIGameTimeCountDown.kTimeBold)
	self.timeRemainingText:SetIsVisible(true)
 
    self.background:AddChild(self.timeRemainingTitle)
	self.background:AddChild(self.timeRemainingText)
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
			self.background:SetIsVisible(true)
			/*
			self.experienceData.barPixelCoordsX1 = combat_GUIExperienceBar.kMarineBarTextureX1
			self.experienceData.barPixelCoordsX2 = combat_GUIExperienceBar.kMarineBarTextureX2
			self.experienceData.barPixelCoordsY1 = combat_GUIExperienceBar.kMarineBarTextureY1
			self.experienceData.barPixelCoordsY2 = combat_GUIExperienceBar.kMarineBarTextureY2
			self.experienceBarBackground:SetTexture(combat_GUIExperienceBar.kMarineTextureName)
			self.experienceBarBackground:SetTexturePixelCoordinates(combat_GUIExperienceBar.kMarineBarBackgroundTextureX1, combat_GUIExperienceBar.kMarineBarBackgroundTextureY1, combat_GUIExperienceBar.kMarineBarBackgroundTextureX2, combat_GUIExperienceBar.kMarineBarBackgroundTextureY2)
			self.experienceBarBackground:SetColor(combat_GUIExperienceBar.kMarineBackgroundGUIColor)
			self.experienceBar:SetTexture(combat_GUIExperienceBar.kMarineTextureName)
		    self.experienceBar:SetTexturePixelCoordinates(combat_GUIExperienceBar.kMarineBarTextureX1, combat_GUIExperienceBar.kMarineBarTextureY1, combat_GUIExperienceBar.kMarineBarTextureX2, combat_GUIExperienceBar.kMarineBarTextureY2)
			*/
			self.timeRemainingTitle:SetColor(combat_GUIGameTimeCountDown.kMarineTextColor)
			self.timeRemainingText:SetColor(combat_GUIGameTimeCountDown.kMarineTextColor)
			self.showTimer = true
		elseif (self.playerTeam == "Aliens") then
			self.background:SetIsVisible(true)
			/*
			self.experienceData.barPixelCoordsX1 = combat_GUIExperienceBar.kAlienBarTextureX1
			self.experienceData.barPixelCoordsX2 = combat_GUIExperienceBar.kAlienBarTextureX2
			self.experienceData.barPixelCoordsY1 = combat_GUIExperienceBar.kAlienBarTextureY1
			self.experienceData.barPixelCoordsY2 = combat_GUIExperienceBar.kAlienBarTextureY2
			self.experienceBarBackground:SetTexture(combat_GUIExperienceBar.kAlienTextureName)
			self.experienceBarBackground:SetTexturePixelCoordinates(combat_GUIExperienceBar.kAlienBarBackgroundTextureX1, combat_GUIExperienceBar.kAlienBarBackgroundTextureY1, combat_GUIExperienceBar.kAlienBarBackgroundTextureX2, combat_GUIExperienceBar.kAlienBarBackgroundTextureY2)
			self.experienceBarBackground:SetColor(combat_GUIExperienceBar.kAlienBackgroundGUIColor)
			self.experienceBar:SetTexture(combat_GUIExperienceBar.kAlienTextureName)
			self.experienceBar:SetTexturePixelCoordinates(combat_GUIExperienceBar.kAlienBarTextureX1, combat_GUIExperienceBar.kAlienBarTextureY1, combat_GUIExperienceBar.kAlienBarTextureX2, combat_GUIExperienceBar.kAlienBarTextureY2)
			*/
			self.timeRemainingTitle:SetColor(combat_GUIGameTimeCountDown.kAlienTextColor)
			self.timeRemainingText:SetColor(combat_GUIGameTimeCountDown.kAlienTextColor)
			self.showTimer = true
		else
			self.background:SetIsVisible(false)
			self.showTimer = false
		end
	end
    
	if (self.showTimer) then
		local TimeRemaining = PlayerUI_GetTimeRemaining()
		self.timeRemainingText:SetText(TimeRemaining)
	end

end


function combat_GUIGameTimeCountDown:Uninitialize()

	GUI.DestroyItem(self.timeRemainingText)
    GUI.DestroyItem(self.timeRemainingTitle)
    GUI.DestroyItem(self.background)

end