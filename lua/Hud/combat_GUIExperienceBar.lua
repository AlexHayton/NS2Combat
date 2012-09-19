//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIExperienceBar.lua

class 'combat_GUIExperienceBar' (GUIScript)

combat_GUIExperienceBar.kTextureName = "ui/combat_experiencebar.dds"
combat_GUIExperienceBar.kTextFontName = "MicrogrammaDBolExt"

combat_GUIExperienceBar.kExperienceBackgroundWidth = 400
combat_GUIExperienceBar.kExperienceBackgroundHeight = 20
combat_GUIExperienceBar.kExperienceBackgroundMinimisedHeight = 10
combat_GUIExperienceBar.kExperienceBackgroundOffset = Vector(-combat_GUIExperienceBar.kExperienceBackgroundWidth/2, -combat_GUIExperienceBar.kExperienceBackgroundHeight-10, 0)
combat_GUIExperienceBar.kExperienceBackgroundColor = Color(0, 0, 0, 0.3)

combat_GUIExperienceBar.kExperienceBorder = 3

combat_GUIExperienceBar.kExperienceBarOffset = Vector(combat_GUIExperienceBar.kExperienceBorder, combat_GUIExperienceBar.kExperienceBorder, 0)
combat_GUIExperienceBar.kExperienceBarWidth = combat_GUIExperienceBar.kExperienceBackgroundWidth - combat_GUIExperienceBar.kExperienceBorder*2
combat_GUIExperienceBar.kExperienceBarHeight = combat_GUIExperienceBar.kExperienceBackgroundHeight - combat_GUIExperienceBar.kExperienceBorder*2
combat_GUIExperienceBar.kExperienceBarMinimisedHeight = combat_GUIExperienceBar.kExperienceBackgroundMinimisedHeight - combat_GUIExperienceBar.kExperienceBorder*2

// Texture Coords
combat_GUIExperienceBar.kExperienceBackgroundTextureX1 = 0
combat_GUIExperienceBar.kExperienceBackgroundTextureX2 = 256
combat_GUIExperienceBar.kExperienceBackgroundTextureY1 = 50
combat_GUIExperienceBar.kExperienceBackgroundTextureY2 = 99
combat_GUIExperienceBar.kExperienceBarTextureX1 = 0
combat_GUIExperienceBar.kExperienceBarTextureX2 = 256
combat_GUIExperienceBar.kExperienceBarTextureY1 = 0
combat_GUIExperienceBar.kExperienceBarTextureY2 = 49
combat_GUIExperienceBar.kMarineBarTextureX1 = 0
combat_GUIExperienceBar.kMarineBarTextureX2 = 256
combat_GUIExperienceBar.kMarineBarTextureY1 = 0
combat_GUIExperienceBar.kMarineBarTextureY2 = 49
combat_GUIExperienceBar.kAlienBarTextureX1 = 0
combat_GUIExperienceBar.kAlienBarTextureX2 = 256
combat_GUIExperienceBar.kAlienBarTextureY1 = 0
combat_GUIExperienceBar.kAlienBarTextureY2 = 49

combat_GUIExperienceBar.kMarineGUIColor = Color(0.0, 0.6, 1.0, 1)
combat_GUIExperienceBar.kAlienGUIColor = Color(1.0, 0.4, 0.4, 1)
combat_GUIExperienceBar.kMarineTextColor = Color(0.0, 0.6, 0.9, 1)
combat_GUIExperienceBar.kAlienTextColor = Color(0.8, 0.4, 0.4, 1)
combat_GUIExperienceBar.kExperienceTextFontSize = 15
combat_GUIExperienceBar.kExperienceTextOffset = Vector(0, -10, 0)
combat_GUIExperienceBar.kNormalAlpha = 1.0
combat_GUIExperienceBar.kMinimisedTextAlpha = 0.6
combat_GUIExperienceBar.kMinimisedAlpha = 0.4

combat_GUIExperienceBar.kBarFadeInRate = 0.2
combat_GUIExperienceBar.kBarFadeOutDelay = 0.4
combat_GUIExperienceBar.kBarFadeOutRate = 0.05
combat_GUIExperienceBar.kBackgroundBarRate = 80
combat_GUIExperienceBar.kTextIncreaseRate = 30

local function GetTeamType()

	local player = Client.GetLocalPlayer()
	if player:isa("Alien") then 
		return "Alien"
	elseif player:isa("Marine") or player:isa("Exo") then
		return "Marine"
	else
		return "Spectator"
	end
	
end

function combat_GUIExperienceBar:Initialize()

	self:CreateExperienceBar()
	self.rankIncreased = false
	self.currentExperience = 0
	self.showExperience = false
	self.experienceAlpha = combat_GUIExperienceBar.kNormalAlpha
	self.experienceTextAlpha = combat_GUIExperienceBar.kNormalAlpha
	self.barMoving = false
	self.playerTeam = "Spectator"
	self.fadeOutTime = Shared.GetTime()
	self.experienceData = {}
	
end

function combat_GUIExperienceBar:CreateExperienceBar()

    self.experienceBarBackground = GUIManager.CreateGraphicItem()
    self.experienceBarBackground:SetSize(Vector(combat_GUIExperienceBar.kExperienceBackgroundWidth, combat_GUIExperienceBar.kExperienceBackgroundMinimisedHeight, 0))
    self.experienceBarBackground:SetAnchor(GUIItem.Center, GUIItem.Bottom)
    self.experienceBarBackground:SetPosition(combat_GUIExperienceBar.kExperienceBackgroundOffset)
    self.experienceBarBackground:SetColor(combat_GUIExperienceBar.kExperienceBackgroundColor)
    self.experienceBarBackground:SetTexture(combat_GUIExperienceBar.kTextureName)
    self.experienceBarBackground:SetTexturePixelCoordinates(combat_GUIExperienceBar.kExperienceBackgroundTextureX1, combat_GUIExperienceBar.kExperienceBackgroundTextureY1, combat_GUIExperienceBar.kExperienceBackgroundTextureX2, combat_GUIExperienceBar.kExperienceBackgroundTextureY2)
	self.experienceBarBackground:SetLayer(kGUILayerPlayerHUDBackground)
    self.experienceBarBackground:SetIsVisible(false)
    
    self.experienceBar = GUIManager.CreateGraphicItem()
    self.experienceBar:SetSize(Vector(combat_GUIExperienceBar.kExperienceBarWidth, combat_GUIExperienceBar.kExperienceBarHeight, 0))
    self.experienceBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.experienceBar:SetPosition(combat_GUIExperienceBar.kExperienceBarOffset)
	self.experienceBar:SetTexture(combat_GUIExperienceBar.kTextureName)
    self.experienceBar:SetTexturePixelCoordinates(combat_GUIExperienceBar.kExperienceBarTextureX1, combat_GUIExperienceBar.kExperienceBarTextureY1, combat_GUIExperienceBar.kExperienceBarTextureX2, combat_GUIExperienceBar.kExperienceBarTextureY2)
    self.experienceBar:SetIsVisible(false)
    self.experienceBarBackground:AddChild(self.experienceBar)
    
    self.experienceText = GUIManager.CreateTextItem()
    self.experienceText:SetFontSize(combat_GUIExperienceBar.kExperienceTextFontSize)
    self.experienceText:SetFontName(combat_GUIExperienceBar.kTextFontName)
    self.experienceText:SetFontIsBold(false)
    self.experienceText:SetAnchor(GUIItem.Center, GUIItem.Top)
    self.experienceText:SetTextAlignmentX(GUIItem.Align_Center)
    self.experienceText:SetTextAlignmentY(GUIItem.Align_Center)
    self.experienceText:SetPosition(combat_GUIExperienceBar.kExperienceTextOffset)
    self.experienceText:SetIsVisible(false)
    self.experienceBarBackground:AddChild(self.experienceText)
	
end

function combat_GUIExperienceBar:Update(deltaTime)

	// Alter the display based on team, status.
	local newTeam = false
	if (self.playerTeam ~= GetTeamType()) then
		self.playerTeam = GetTeamType()
		newTeam = true
	end
	
	// We have switched teams.
	if (newTeam) then
		if (self.playerTeam == "Marines") then
			self.experienceBarBackground:SetIsVisible(true)
			self.experienceBar:SetIsVisible(true)
			self.experienceText:SetIsVisible(true)
		    self.experienceBar:SetTexturePixelCoordinates(combat_GUIExperienceBar.kMarineBarTextureX1, combat_GUIExperienceBar.kMarineBarTextureY1, combat_GUIExperienceBar.kMarineBarTextureX2, combat_GUIExperienceBar.kMarineBarTextureY2)
			self.experienceBar:SetColor(combat_GUIExperienceBar.kMarineGUIColor)
			self.experienceText:SetColor(combat_GUIExperienceBar.kMarineTextColor)
			self.experienceAlpha = 1.0
			self.showExperience = true
		elseif (self.playerTeam == "Aliens") then
			self.experienceBarBackground:SetIsVisible(true)
			self.experienceBar:SetIsVisible(true)
			self.experienceText:SetIsVisible(true)
			self.experienceBar:SetTexturePixelCoordinates(combat_GUIExperienceBar.kAlienBarTextureX1, combat_GUIExperienceBar.kAlienBarTextureY1, combat_GUIExperienceBar.kAlienBarTextureX2, combat_GUIExperienceBar.kAlienBarTextureY2)
			self.experienceBar:SetColor(combat_GUIExperienceBar.kAlienGUIColor)	
			self.experienceText:SetColor(combat_GUIExperienceBar.kAlienTextColor)
			self.experienceAlpha = 1.0
			self.showExperience = true
		else
			self.experienceBarBackground:SetIsVisible(false)
			self.experienceBar:SetIsVisible(false)
			self.experienceText:SetIsVisible(false)
			self.showExperience = false
		end
	end
		
	// Recalculate, tween and fade
	if (self.showExperience) then
		self:CalculateExperienceData()
		self:UpdateExperienceBar(deltaTime)
		self:UpdateFading(deltaTime)
		self:UpdateText(deltaTime)
	end
	
end

function combat_GUIExperienceBar:CalculateExperienceData()

	local player = Client.GetLocalPlayer()
	self.experienceData.targetExperience = player:GetScore()
	self.experienceData.experienceToNextLevel = player:XpUntilNextLevel()
	self.experienceData.nextLevelExperience = player:GetNextLevelXP()
	self.experienceData.thisLevelName = Experience_GetLvlName(player:GetScore(), player:GetTeamNumber())
	self.experienceData.experiencePercent = self:GetLevelProgression()
	self.experienceData.experienceLastTick = self.experienceData.targetExperience

end

function combat_GUIExperienceBar:UpdateExperienceBar(deltaTime)

    local expBarPercentage = self.experienceData.experiencePercent
	local calculatedBarWidth = combat_GUIExperienceBar.kExperienceBarWidth * expBarPercentage
	local currentBarWidth = self.experienceBar:GetSize().x
	local targetBarWidth = calculatedBarWidth
	
	// Method to allow proper tweening visualisation when you go up a rank.
	// Currently detecting this by examining old vs new size.
	if (math.floor(calculatedBarWidth) < math.floor(currentBarWidth)) then
		self.rankIncreased = true
	end
	
	if (self.rankIncreased) then
		targetBarWidth = combat_GUIExperienceBar.kExperienceBarWidth
		// Once we reach the end, reset the bar back to the beginning.
		if (currentBarWidth >= targetBarWidth) then
			self.rankIncreased = false
			currentBarWidth = 0
			targetBarWidth = calculatedBarWidth
		end
	end
	
	if (PlayerUI_GetPlayerExperience() == maxXp) then
		currentBarWidth = combat_GUIExperienceBar.kExperienceBarWidth
		targetBarWidth = combat_GUIExperienceBar.kExperienceBarWidth
		calculatedBarWidth = combat_GUIExperienceBar.kExperienceBarWidth
		self.rankIncreased = false
	end
	
	self.experienceBar:SetSize(Vector(Slerp(currentBarWidth, targetBarWidth, deltaTime*combat_GUIExperienceBar.kBackgroundBarRate), self.experienceBar:GetSize().y, 0))
	
	// Detect and register if the bar is moving
	if (math.abs(currentBarWidth - calculatedBarWidth) > 0.01) then
		self.barMoving = true
	else
		// Delay the fade out by a while
		if (self.barMoving) then
			self.fadeOutTime = Shared.GetTime() + combat_GUIExperienceBar.kBarFadeOutDelay
		end
		self.barMoving = false
	end
	
end

function combat_GUIExperienceBar:UpdateFading(deltaTime)

	local currentBarHeight = self.experienceBar:GetSize().y
	local currentBackgroundHeight = self.experienceBarBackground:GetSize().y
	local currentBarColor = self.experienceBar:GetColor()
	local currentTextColor = self.experienceText:GetColor()
	local targetBarHeight = currentBarHeight
	local targetBackgroundHeight = currentBackgroundHeight
	local targetBarColor = currentBarColor
	local targetAlpha = combat_GUIExperienceBar.kNormalAlpha
	local targetTextAlpha = combat_GUIExperienceBar.kNormalAlpha
		
	if (self.barMoving or Shared.GetTime() < self.fadeOutTime) then
		targetBarHeight = combat_GUIExperienceBar.kExperienceBarHeight
		targetBackgroundHeight = combat_GUIExperienceBar.kExperienceBackgroundHeight
	else
		targetBarHeight = combat_GUIExperienceBar.kExperienceBarMinimisedHeight
		targetBackgroundHeight = combat_GUIExperienceBar.kExperienceBackgroundMinimisedHeight
		targetAlpha = combat_GUIExperienceBar.kMinimisedAlpha
		targetTextAlpha = combat_GUIExperienceBar.kMinimisedTextAlpha
	end
	
	self.experienceAlpha = Slerp(self.experienceAlpha, targetAlpha, deltaTime*combat_GUIExperienceBar.kBarFadeOutRate)
	self.experienceTextAlpha = Slerp(self.experienceTextAlpha, targetTextAlpha, deltaTime*combat_GUIExperienceBar.kBarFadeOutRate)
	
	self.experienceBarBackground:SetSize(Vector(combat_GUIExperienceBar.kExperienceBackgroundWidth, Slerp(currentBackgroundHeight, targetBackgroundHeight, deltaTime*combat_GUIExperienceBar.kBackgroundBarRate), 0))
	self.experienceBar:SetSize(Vector(self.experienceBar:GetSize().x, Slerp(currentBarHeight, targetBarHeight, deltaTime*combat_GUIExperienceBar.kBackgroundBarRate), 0))
	self.experienceBar:SetColor(Color(currentBarColor.r, currentBarColor.g, currentBarColor.b, self.experienceAlpha))
	self.experienceText:SetColor(Color(currentTextColor.r, currentTextColor.g, currentTextColor.b, self.experienceAlpha))
end

function combat_GUIExperienceBar:UpdateText(deltaTime)
	// Tween the experience text too!
	self.currentExperience = Slerp(self.currentExperience, self.experienceData.targetExperience, deltaTime*combat_GUIExperienceBar.kTextIncreaseRate)
	if (self.targetExperience >= maxXp) then
		self.experienceText:SetText(tostring(math.ceil(self.currentExperience)) .. " (" .. self.experienceData.thisLevelName .. ")")
	else
		self.experienceText:SetText(tostring(math.ceil(self.currentExperience)) .. " / " .. self.experienceData.nextLevelExperience .. " (" .. self.experienceData.thisLevelName .. ")")
	end
end

function combat_GUIExperienceBar:Uninitialize()

	if self.experienceBar then
        GUIManager.DestroyItem(self.experienceBarBackground)
        self.experienceBar = nil
        self.experienceBarText = nil
        self.experienceBarBackground = nil
    end
    
end