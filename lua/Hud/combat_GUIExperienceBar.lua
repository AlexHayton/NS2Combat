//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_combat_GUIExperience.lua

class 'combat_GUIExperience' (GUIScript)

combat_GUIExperience.kAlienTextureName = "ui/combat_experiencebar_alien.dds"
combat_GUIExperience.kMarineTextureName = "ui/combat_experiencebar_alien.dds"
combat_GUIExperience.kBackgroundTextureName = "ui/combat_experiencebar_background.dds"
combat_GUIExperience.kTextFontName = "MicrogrammaDBolExt"

combat_GUIExperience.kExperienceBackgroundWidth = 400
combat_GUIExperience.kExperienceBackgroundHeight = 20
combat_GUIExperience.kExperienceBackgroundMinimisedHeight = 10
combat_GUIExperience.kExperienceBackgroundOffset = Vector(-combat_GUIExperience.kExperienceBackgroundWidth/2, -combat_GUIExperience.kExperienceBackgroundHeight-10, 0)
combat_GUIExperience.kExperienceBackgroundColor = Color(0, 0, 0, 0.3)

combat_GUIExperience.kExperienceBorder = 3

combat_GUIExperience.kExperienceBarOffset = Vector(combat_GUIExperience.kExperienceBorder, combat_GUIExperience.kExperienceBorder, 0)
combat_GUIExperience.kExperienceBarWidth = combat_GUIExperience.kExperienceBackgroundWidth - combat_GUIExperience.kExperienceBorder*2
combat_GUIExperience.kExperienceBarHeight = combat_GUIExperience.kExperienceBackgroundHeight - combat_GUIExperience.kExperienceBorder*2
combat_GUIExperience.kExperienceBarMinimisedHeight = combat_GUIExperience.kExperienceBackgroundMinimisedHeight - combat_GUIExperience.kExperienceBorder*2
combat_GUIExperience.kExperienceBackgroundTextureX1 = 0
combat_GUIExperience.kExperienceBackgroundTextureY1 = 0
combat_GUIExperience.kExperienceBackgroundTextureX2 = 247
combat_GUIExperience.kExperienceBackgroundTextureY2 = 45

combat_GUIExperience.kExperienceBarTextureX1 = 0
combat_GUIExperience.kExperienceBarTextureY1 = 0
combat_GUIExperience.kExperienceBarTextureX2 = 247
combat_GUIExperience.kExperienceBarTextureY2 = 45

combat_GUIExperience.kMarineGUIColor = Color(0.0, 0.6, 1.0, 1)
combat_GUIExperience.kAlienGUIColor = Color(1.0, 0.4, 0.4, 1)
combat_GUIExperience.kMarineTextColor = Color(0.0, 0.6, 0.9, 1)
combat_GUIExperience.kAlienTextColor = Color(0.8, 0.4, 0.4, 1)
combat_GUIExperience.kExperienceTextFontSize = 15
combat_GUIExperience.kExperienceTextOffset = Vector(0, -10, 0)
combat_GUIExperience.kNormalAlpha = 1.0
combat_GUIExperience.kMinimisedTextAlpha = 0.6
combat_GUIExperience.kMinimisedAlpha = 0.4

combat_GUIExperience.kBarFadeInRate = 0.2
combat_GUIExperience.kBarFadeOutDelay = 0.4
combat_GUIExperience.kBarFadeOutRate = 0.05
combat_GUIExperience.kBackgroundBarRate = 80
combat_GUIExperience.kTextIncreaseRate = 30

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

function combat_GUIExperience:Initialize()

	self:CreateExperienceBar()
	self.rankIncreased = false
	self.currentExperience = 0
	self.showExperience = false
	self.experienceAlpha = combat_GUIExperience.kNormalAlpha
	self.experienceTextAlpha = combat_GUIExperience.kNormalAlpha
	self.barMoving = false
	self.playerTeam = "Spectator"
	self.fadeOutTime = Shared.GetTime()
	self.experienceData = {}
	
end

function combat_GUIExperience:CreateExperienceBar()

    self.experienceBarBackground = GUIManager.CreateGraphicItem()
    self.experienceBarBackground:SetSize(Vector(combat_GUIExperience.kExperienceBackgroundWidth, combat_GUIExperience.kExperienceBackgroundMinimisedHeight, 0))
    self.experienceBarBackground:SetAnchor(GUIItem.Center, GUIItem.Bottom)
    self.experienceBarBackground:SetPosition(combat_GUIExperience.kExperienceBackgroundOffset)
    self.experienceBarBackground:SetColor(combat_GUIExperience.kExperienceBackgroundColor)
    self.experienceBarBackground:SetTexture(combat_GUIExperience.kBackgroundTextureName)
    self.experienceBarBackground:SetTexturePixelCoordinates(combat_GUIExperience.kExperienceBackgroundTextureX1, combat_GUIExperience.kExperienceBackgroundTextureY1, combat_GUIExperience.kExperienceBackgroundTextureX2, combat_GUIExperience.kExperienceBackgroundTextureY2)
    self.experienceBarBackground:SetIsVisible(false)
    
    self.experienceBar = GUIManager.CreateGraphicItem()
    self.experienceBar:SetSize(Vector(combat_GUIExperience.kExperienceBarWidth, combat_GUIExperience.kExperienceBarHeight, 0))
    self.experienceBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.experienceBar:SetPosition(combat_GUIExperience.kExperienceBarOffset)
    self.experienceBar:SetTexturePixelCoordinates(combat_GUIExperience.kExperienceBarTextureX1, combat_GUIExperience.kExperienceBarTextureY1, combat_GUIExperience.kExperienceBarTextureX2, combat_GUIExperience.kExperienceBarTextureY2)
    self.experienceBar:SetIsVisible(false)
    self.experienceBarBackground:AddChild(self.experienceBar)
    
    self.experienceText = GUIManager.CreateTextItem()
    self.experienceText:SetFontSize(combat_GUIExperience.kExperienceTextFontSize)
    self.experienceText:SetFontName(combat_GUIExperience.kTextFontName)
    self.experienceText:SetFontIsBold(false)
    self.experienceText:SetAnchor(GUIItem.Center, GUIItem.Top)
    self.experienceText:SetTextAlignmentX(GUIItem.Align_Center)
    self.experienceText:SetTextAlignmentY(GUIItem.Align_Center)
    self.experienceText:SetPosition(combat_GUIExperience.kExperienceTextOffset)
    self.experienceText:SetIsVisible(false)
    self.experienceBarBackground:AddChild(self.experienceText)
	
end

function combat_GUIExperience:Update(deltaTime)

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
			self.experienceBar:SetTexture(combat_GUIExperience.kMarineTextureName)
			self.experienceBar:SetColor(combat_GUIExperience.kMarineGUIColor)
			self.experienceText:SetColor(combat_GUIExperience.kMarineTextColor)
			self.experienceAlpha = 1.0
			self.showExperience = true
		elseif (self.playerTeam == "Aliens") then
			self.experienceBarBackground:SetIsVisible(true)
			self.experienceBar:SetIsVisible(true)
			self.experienceText:SetIsVisible(true)
			self.experienceBar:SetTexture(combat_GUIExperience.kAlienTextureName)
			self.experienceBar:SetColor(combat_GUIExperience.kAlienGUIColor)	
			self.experienceText:SetColor(combat_GUIExperience.kAlienTextColor)
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

function combat_GUIExperience:CalculateExperienceData()

	local player = Client.GetLocalPlayer()
	self.experienceData.targetExperience = player:GetScore()
	self.experienceData.experienceToNextLevel = player:XpUntilNextLevel()
	self.experienceData.nextLevelExperience = player:GetNextLevelXP()
	self.experienceData.thisLevelName = Experience_GetLvlName(player:GetScore(), player:GetTeamNumber())
	self.experienceData.experiencePercent = self:GetLevelProgression()
	self.experienceData.experienceLastTick = self.experienceData.targetExperience

end

function combat_GUIExperience:UpdateExperienceBar(deltaTime)

    local expBarPercentage = self.experienceData.experiencePercent
	local calculatedBarWidth = combat_GUIExperience.kExperienceBarWidth * expBarPercentage
	local currentBarWidth = self.experienceBar:GetSize().x
	local targetBarWidth = calculatedBarWidth
	
	// Method to allow proper tweening visualisation when you go up a rank.
	// Currently detecting this by examining old vs new size.
	if (math.floor(calculatedBarWidth) < math.floor(currentBarWidth)) then
		self.rankIncreased = true
	end
	
	if (self.rankIncreased) then
		targetBarWidth = combat_GUIExperience.kExperienceBarWidth
		// Once we reach the end, reset the bar back to the beginning.
		if (currentBarWidth >= targetBarWidth) then
			self.rankIncreased = false
			currentBarWidth = 0
			targetBarWidth = calculatedBarWidth
		end
	end
	
	if (PlayerUI_GetPlayerExperience() == maxXp) then
		currentBarWidth = combat_GUIExperience.kExperienceBarWidth
		targetBarWidth = combat_GUIExperience.kExperienceBarWidth
		calculatedBarWidth = combat_GUIExperience.kExperienceBarWidth
		self.rankIncreased = false
	end
	
	self.experienceBar:SetSize(Vector(Slerp(currentBarWidth, targetBarWidth, deltaTime*combat_GUIExperience.kBackgroundBarRate), self.experienceBar:GetSize().y, 0))
	
	// Detect and register if the bar is moving
	if (math.abs(currentBarWidth - calculatedBarWidth) > 0.01) then
		self.barMoving = true
	else
		// Delay the fade out by a while
		if (self.barMoving) then
			self.fadeOutTime = Shared.GetTime() + combat_GUIExperience.kBarFadeOutDelay
		end
		self.barMoving = false
	end
	
end

function combat_GUIExperience:UpdateFading(deltaTime)

	local currentBarHeight = self.experienceBar:GetSize().y
	local currentBackgroundHeight = self.experienceBarBackground:GetSize().y
	local currentBarColor = self.experienceBar:GetColor()
	local currentTextColor = self.experienceText:GetColor()
	local targetBarHeight = currentBarHeight
	local targetBackgroundHeight = currentBackgroundHeight
	local targetBarColor = currentBarColor
	local targetAlpha = combat_GUIExperience.kNormalAlpha
	local targetTextAlpha = combat_GUIExperience.kNormalAlpha
		
	if (self.barMoving or Shared.GetTime() < self.fadeOutTime) then
		targetBarHeight = combat_GUIExperience.kExperienceBarHeight
		targetBackgroundHeight = combat_GUIExperience.kExperienceBackgroundHeight
	else
		targetBarHeight = combat_GUIExperience.kExperienceBarMinimisedHeight
		targetBackgroundHeight = combat_GUIExperience.kExperienceBackgroundMinimisedHeight
		targetAlpha = combat_GUIExperience.kMinimisedAlpha
		targetTextAlpha = combat_GUIExperience.kMinimisedTextAlpha
	end
	
	self.experienceAlpha = Slerp(self.experienceAlpha, targetAlpha, deltaTime*combat_GUIExperience.kBarFadeOutRate)
	self.experienceTextAlpha = Slerp(self.experienceTextAlpha, targetTextAlpha, deltaTime*combat_GUIExperience.kBarFadeOutRate)
	
	self.experienceBarBackground:SetSize(Vector(combat_GUIExperience.kExperienceBackgroundWidth, Slerp(currentBackgroundHeight, targetBackgroundHeight, deltaTime*combat_GUIExperience.kBackgroundBarRate), 0))
	self.experienceBar:SetSize(Vector(self.experienceBar:GetSize().x, Slerp(currentBarHeight, targetBarHeight, deltaTime*combat_GUIExperience.kBackgroundBarRate), 0))
	self.experienceBar:SetColor(Color(currentBarColor.r, currentBarColor.g, currentBarColor.b, self.experienceAlpha))
	self.experienceText:SetColor(Color(currentTextColor.r, currentTextColor.g, currentTextColor.b, self.experienceAlpha))
end

function combat_GUIExperience:UpdateText(deltaTime)
	// Tween the experience text too!
	self.currentExperience = Slerp(self.currentExperience, self.experienceData.targetExperience, deltaTime*combat_GUIExperience.kTextIncreaseRate)
	if (self.targetExperience >= maxXp) then
		self.experienceText:SetText(tostring(math.ceil(self.currentExperience)) .. " (" .. self.experienceData.thisLevelName .. ")")
	else
		self.experienceText:SetText(tostring(math.ceil(self.currentExperience)) .. " / " .. self.experienceData.nextLevelExperience .. " (" .. self.experienceData.thisLevelName .. ")")
	end
end

function combat_GUIExperience:Uninitialize()

	if self.experienceBar then
        GUIManager.DestroyItem(self.experienceBarBackground)
        self.experienceBar = nil
        self.experienceBarText = nil
        self.experienceBarBackground = nil
    end
    
end