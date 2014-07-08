//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIExperienceBar.lua

class 'combat_GUIExperienceBar' (GUIScript)

combat_GUIExperienceBar.kMarineBarTextureName = "ui/combat_xpbar_marine.png"
combat_GUIExperienceBar.kMarineBackgroundTextureName = "ui/combat_xpbarbg_marine.png"
combat_GUIExperienceBar.kAlienBarTextureName = "ui/combat_xpbar_alien.png"
combat_GUIExperienceBar.kAlienBackgroundTextureName = "ui/combat_xpbarbg_alien.png"
combat_GUIExperienceBar.kTextFontName = Fonts.kArial_17

combat_GUIExperienceBar.kExperienceBackgroundWidth = 450
combat_GUIExperienceBar.kExperienceBackgroundHeight = 30
combat_GUIExperienceBar.kExperienceBackgroundMinimisedHeight = 30
combat_GUIExperienceBar.kExperienceBackgroundOffset = Vector(-combat_GUIExperienceBar.kExperienceBackgroundWidth/2, -combat_GUIExperienceBar.kExperienceBackgroundHeight-10, 0)

combat_GUIExperienceBar.kExperienceBorder = 0

combat_GUIExperienceBar.kExperienceBarOffset = Vector(combat_GUIExperienceBar.kExperienceBorder, combat_GUIExperienceBar.kExperienceBorder, 0)
combat_GUIExperienceBar.kExperienceBarWidth = combat_GUIExperienceBar.kExperienceBackgroundWidth - combat_GUIExperienceBar.kExperienceBorder*2
combat_GUIExperienceBar.kExperienceBarHeight = combat_GUIExperienceBar.kExperienceBackgroundHeight - combat_GUIExperienceBar.kExperienceBorder*2
combat_GUIExperienceBar.kExperienceBarMinimisedHeight = combat_GUIExperienceBar.kExperienceBackgroundMinimisedHeight - combat_GUIExperienceBar.kExperienceBorder*2

// Texture Coords
combat_GUIExperienceBar.kMarineBarTextureX1 = 12
combat_GUIExperienceBar.kMarineBarTextureX2 = 500
combat_GUIExperienceBar.kMarineBarTextureY1 = 0
combat_GUIExperienceBar.kMarineBarTextureY2 = 31
combat_GUIExperienceBar.kMarineBarBackgroundTextureX1 = 12
combat_GUIExperienceBar.kMarineBarBackgroundTextureX2 = 500
combat_GUIExperienceBar.kMarineBarBackgroundTextureY1 = 0
combat_GUIExperienceBar.kMarineBarBackgroundTextureY2 = 31
combat_GUIExperienceBar.kAlienBarTextureX1 = 13
combat_GUIExperienceBar.kAlienBarTextureX2 = 498
combat_GUIExperienceBar.kAlienBarTextureY1 = 0
combat_GUIExperienceBar.kAlienBarTextureY2 = 31
combat_GUIExperienceBar.kAlienBarBackgroundTextureX1 = 13
combat_GUIExperienceBar.kAlienBarBackgroundTextureX2 = 498
combat_GUIExperienceBar.kAlienBarBackgroundTextureY1 = 0
combat_GUIExperienceBar.kAlienBarBackgroundTextureY2 = 31

combat_GUIExperienceBar.kMarineBackgroundGUIColor = Color(1.0, 1.0, 1.0, 0.2)
combat_GUIExperienceBar.kMarineGUIColor = Color(1.0, 1.0, 1.0, 0.9)
combat_GUIExperienceBar.kAlienBackgroundGUIColor = Color(1.0, 1.0, 1.0, 0.4)
combat_GUIExperienceBar.kAlienGUIColor = Color(1.0, 1.0, 1.0, 0.9)
combat_GUIExperienceBar.kMarineTextColor = Color(1.0, 1.0, 1.0, 1)
combat_GUIExperienceBar.kAlienTextColor = Color(0.9, 0.7, 0.7, 1)
combat_GUIExperienceBar.kExperienceTextFontSize = 15
combat_GUIExperienceBar.kExperienceTextOffset = Vector(0, -10, 0)
combat_GUIExperienceBar.kNormalAlpha = 0.9
combat_GUIExperienceBar.kMinimisedTextAlpha = 0.7
combat_GUIExperienceBar.kMinimisedAlpha = 0.6

combat_GUIExperienceBar.kBarFadeInRate = 0.2
combat_GUIExperienceBar.kBarFadeOutDelay = 0.5
combat_GUIExperienceBar.kBarFadeOutRate = 0.1
combat_GUIExperienceBar.kBackgroundBarRate = 90
combat_GUIExperienceBar.kBackgroundBarFastRate = 250
combat_GUIExperienceBar.kTextIncreaseRate = 200

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

function combat_GUIExperienceBar:Initialize()

	self:CreateExperienceBar()
	self.rankIncreased = false
	self.currentExperience = 0
	self.showExperience = false
	self.experienceAlpha = combat_GUIExperienceBar.kNormalAlpha
	self.experienceTextAlpha = combat_GUIExperienceBar.kNormalAlpha
	self.barMoving = false
	self.playerTeam = "Ready Room"
	self.fadeOutTime = Shared.GetTime()
	self.experienceData = {}
	
end

function combat_GUIExperienceBar:CreateExperienceBar()

    self.experienceBarBackground = GUIManager.CreateGraphicItem()
    self.experienceBarBackground:SetSize(Vector(combat_GUIExperienceBar.kExperienceBackgroundWidth, combat_GUIExperienceBar.kExperienceBackgroundMinimisedHeight, 0))
    self.experienceBarBackground:SetAnchor(GUIItem.Center, GUIItem.Bottom)
    self.experienceBarBackground:SetPosition(combat_GUIExperienceBar.kExperienceBackgroundOffset)
	self.experienceBarBackground:SetLayer(kGUILayerPlayerHUDBackground)
    self.experienceBarBackground:SetIsVisible(false)
    
    self.experienceBar = GUIManager.CreateGraphicItem()
    self.experienceBar:SetSize(Vector(combat_GUIExperienceBar.kExperienceBarWidth, combat_GUIExperienceBar.kExperienceBarHeight, 0))
    self.experienceBar:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.experienceBar:SetPosition(combat_GUIExperienceBar.kExperienceBarOffset)
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
			self.experienceData.barPixelCoordsX1 = combat_GUIExperienceBar.kMarineBarTextureX1
			self.experienceData.barPixelCoordsX2 = combat_GUIExperienceBar.kMarineBarTextureX2
			self.experienceData.barPixelCoordsY1 = combat_GUIExperienceBar.kMarineBarTextureY1
			self.experienceData.barPixelCoordsY2 = combat_GUIExperienceBar.kMarineBarTextureY2
			self.experienceBarBackground:SetTexture(combat_GUIExperienceBar.kMarineBackgroundTextureName)
			self.experienceBarBackground:SetTexturePixelCoordinates(combat_GUIExperienceBar.kMarineBarBackgroundTextureX1, combat_GUIExperienceBar.kMarineBarBackgroundTextureY1, combat_GUIExperienceBar.kMarineBarBackgroundTextureX2, combat_GUIExperienceBar.kMarineBarBackgroundTextureY2)
			self.experienceBarBackground:SetColor(combat_GUIExperienceBar.kMarineBackgroundGUIColor)
			self.experienceBar:SetTexture(combat_GUIExperienceBar.kMarineBarTextureName)
		    self.experienceBar:SetTexturePixelCoordinates(combat_GUIExperienceBar.kMarineBarTextureX1, combat_GUIExperienceBar.kMarineBarTextureY1, combat_GUIExperienceBar.kMarineBarTextureX2, combat_GUIExperienceBar.kMarineBarTextureY2)
			self.experienceBar:SetColor(combat_GUIExperienceBar.kMarineGUIColor)
			self.experienceText:SetColor(combat_GUIExperienceBar.kMarineTextColor)
			self.experienceAlpha = 1.0
			self.showExperience = true
		elseif (self.playerTeam == "Aliens") then
			self.experienceBarBackground:SetIsVisible(true)
			self.experienceBar:SetIsVisible(true)
			self.experienceText:SetIsVisible(true)
			self.experienceData.barPixelCoordsX1 = combat_GUIExperienceBar.kAlienBarTextureX1
			self.experienceData.barPixelCoordsX2 = combat_GUIExperienceBar.kAlienBarTextureX2
			self.experienceData.barPixelCoordsY1 = combat_GUIExperienceBar.kAlienBarTextureY1
			self.experienceData.barPixelCoordsY2 = combat_GUIExperienceBar.kAlienBarTextureY2
			self.experienceBarBackground:SetTexture(combat_GUIExperienceBar.kAlienBackgroundTextureName)
			self.experienceBarBackground:SetTexturePixelCoordinates(combat_GUIExperienceBar.kAlienBarBackgroundTextureX1, combat_GUIExperienceBar.kAlienBarBackgroundTextureY1, combat_GUIExperienceBar.kAlienBarBackgroundTextureX2, combat_GUIExperienceBar.kAlienBarBackgroundTextureY2)
			self.experienceBarBackground:SetColor(combat_GUIExperienceBar.kAlienBackgroundGUIColor)
			self.experienceBar:SetTexture(combat_GUIExperienceBar.kAlienBarTextureName)
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
		self:UpdateVisible(deltaTime)
	end
	
end

function combat_GUIExperienceBar:CalculateExperienceData()

	local player = Client.GetLocalPlayer()
	self.experienceData.isVisible = player:GetIsAlive()
	self.experienceData.targetExperience = player:GetScore()
	self.experienceData.experienceToNextLevel = player:XPUntilNextLevel()
	self.experienceData.nextLevelExperience = player:GetNextLevelXP()
	self.experienceData.thisLevel = Experience_GetLvl(player:GetScore())
	self.experienceData.thisLevelName = Experience_GetLvlName(Experience_GetLvl(player:GetScore()), player:GetTeamNumber())
	self.experienceData.experiencePercent = player:GetLevelProgression()
	self.experienceData.experienceLastTick = self.experienceData.targetExperience

end

function combat_GUIExperienceBar:UpdateExperienceBar(deltaTime)

    local expBarPercentage = self.experienceData.experiencePercent
	local calculatedBarWidth = combat_GUIExperienceBar.kExperienceBarWidth * expBarPercentage
	local currentBarWidth = self.experienceBar:GetSize().x
	local targetBarWidth = calculatedBarWidth
	
	// Method to allow proper tweening visualisation when you go up a rank.
	// Currently detecting this by examining old vs new size.
	if (math.ceil(calculatedBarWidth) < math.floor(currentBarWidth)) then
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
	
	if (self.experienceData.targetExperience >= maxXp) then
		currentBarWidth = combat_GUIExperienceBar.kExperienceBarWidth
		targetBarWidth = combat_GUIExperienceBar.kExperienceBarWidth
		calculatedBarWidth = combat_GUIExperienceBar.kExperienceBarWidth
		self.rankIncreased = false
	end

	local increaseRate = combat_GUIExperienceBar.kBackgroundBarRate
	if currentBarWidth <= targetBarWidth - 50 then
		increaseRate = combat_GUIExperienceBar.kBackgroundBarFastRate
	end
	self.experienceBar:SetSize(Vector(Slerp(currentBarWidth, targetBarWidth, deltaTime*increaseRate), self.experienceBar:GetSize().y, 0))
	local texCoordX2 = self.experienceData.barPixelCoordsX1 + (Slerp(currentBarWidth, targetBarWidth, deltaTime*increaseRate) / combat_GUIExperienceBar.kExperienceBarWidth * (self.experienceData.barPixelCoordsX2 - self.experienceData.barPixelCoordsX1))
	self.experienceBar:SetTexturePixelCoordinates(self.experienceData.barPixelCoordsX1, self.experienceData.barPixelCoordsY1, texCoordX2, self.experienceData.barPixelCoordsY2)
	
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

	local currentBarColor = self.experienceBar:GetColor()
	local currentTextColor = self.experienceText:GetColor()
	local targetAlpha = combat_GUIExperienceBar.kNormalAlpha
	local targetTextAlpha = combat_GUIExperienceBar.kNormalAlpha
		
	if (self.barMoving or Shared.GetTime() < self.fadeOutTime) then
		targetAlpha = combat_GUIExperienceBar.kMinimisedAlpha
		targetTextAlpha = combat_GUIExperienceBar.kMinimisedTextAlpha
	end
	
	self.experienceAlpha = Slerp(self.experienceAlpha, targetAlpha, deltaTime*combat_GUIExperienceBar.kBarFadeOutRate)
	self.experienceTextAlpha = Slerp(self.experienceTextAlpha, targetTextAlpha, deltaTime*combat_GUIExperienceBar.kBarFadeOutRate)
	
	self.experienceBar:SetColor(Color(currentBarColor.r, currentBarColor.g, currentBarColor.b, self.experienceAlpha))
	self.experienceText:SetColor(Color(currentTextColor.r, currentTextColor.g, currentTextColor.b, self.experienceTextAlpha))
	
end

function combat_GUIExperienceBar:UpdateText(deltaTime)
	local updateRate = combat_GUIExperienceBar.kTextIncreaseRate
	// Handle the case when the experience jumps up by a huge amount
	if self.experienceData.targetExperience > self.currentExperience and
	   self.experienceData.targetExperience - self.currentExperience > combat_GUIExperienceBar.kTextIncreaseRate*2 then
	   updateRate = combat_GUIExperienceBar.kTextIncreaseRate * 10
	end
	   
	// Tween the experience text too!
	self.currentExperience = Slerp(self.currentExperience, self.experienceData.targetExperience, deltaTime*updateRate)
	
	// Handle the case when the round changes and we are set back to 0 experience.
	if self.currentExperience > self.experienceData.targetExperience then
		self.currentExperience = 0
	end
	
	if (self.experienceData.targetExperience >= maxXp) then
		self.experienceText:SetText("Level " .. self.experienceData.thisLevel .. " / " .. maxLvl .. ": " .. tostring(math.ceil(self.currentExperience)) .. " (" .. self.experienceData.thisLevelName .. ")")
	else
		self.experienceText:SetText("Level " .. self.experienceData.thisLevel .. " / " .. maxLvl .. ": " .. tostring(math.ceil(self.currentExperience)) .. " / " .. self.experienceData.nextLevelExperience .. " (" .. self.experienceData.thisLevelName .. ")")
	end
end

function combat_GUIExperienceBar:UpdateVisible(deltaTime)

	// Hide the experience bar if the player is dead.
	self.experienceBarBackground:SetIsVisible(self.experienceData.isVisible)
	
end

function combat_GUIExperienceBar:Uninitialize()

	if self.experienceBar then
        GUIManager.DestroyItem(self.experienceBarBackground)
        self.experienceBar = nil
        self.experienceBarText = nil
        self.experienceBarBackground = nil
    end
    
end