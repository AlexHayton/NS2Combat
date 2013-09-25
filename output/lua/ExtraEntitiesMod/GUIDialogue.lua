//________________________________
//
//   	NS2 CustomEntitesMod   
//	Made by JimWest 2012
//
//________________________________

// modified from GuiExploreHint


Script.Load("lua/GUIScript.lua")
Script.Load("lua/NS2Utility.lua")

class 'GUIDialogue' (GUIScript)

local kFadeMode = enum({ 'FadeIn', 'FadeOut', 'Normal' })

GUIDialogue.kDialogBoxTexture = "ui/dialogue/dialog_box.dds"
GUIDialogue.kPortraitBoxTexture = "ui/dialogue/portrait_box.dds"
GUIDialogue.kDefaultPortraitTexture = "ui/dialogue/portrait_default.dds"

GUIDialogue.kRightOffset = GUIScale(50)
GUIDialogue.kTopOffset = GUIScale(50)
GUIDialogue.kPortraitBackgroundScale = Vector(GUIScale(200), GUIScale(256), 0)
GUIDialogue.kPortraitBackgroundPos = Vector( -GUIDialogue.kPortraitBackgroundScale.x -GUIDialogue.kRightOffset, GUIDialogue.kTopOffset, 0 )
GUIDialogue.kPortraitBackgroundCoords = { X1 = 0, Y1 = 0, X2 = 362, Y2 = 512 }
GUIDialogue.kDialogueBackgroundScale = Vector(GUIScale(360), GUIScale(180), 0)
GUIDialogue.kDialogueBackgroundScalePerLine = Vector(GUIScale(360), GUIScale(36), 0)
GUIDialogue.kDialogueBackgroundPos = Vector( -GUIDialogue.kDialogueBackgroundScale.x -GUIDialogue.kPortraitBackgroundScale.x -GUIDialogue.kRightOffset, GUIDialogue.kTopOffset, 0 )
GUIDialogue.kDialogueBackgroundCoords = { X1 = 0, Y1 = 0, X2 = 512, Y2 = 256 }
GUIDialogue.kDialogueTextPos = Vector( GUIScale(20), GUIScale(-18), 0 )
GUIDialogue.kDialogueTextColor = Color(1.0, 1.0, 1.0, 1.0)
GUIDialogue.kDialogueTextLineHeight = GUIScale(36)
GUIDialogue.kDialogueTextLineChars = 42
GUIDialogue.kPortraitIconPos = Vector( GUIScale(8), GUIScale(5), 0)
GUIDialogue.kPortraitIconScale = Vector(GUIScale(196), GUIScale(210), 0)
GUIDialogue.kPortraitIconCoords = { X1 = 0, Y1 = 0, X2 = 256, Y2 = 256 }
GUIDialogue.kPortraitTextPos = Vector( GUIScale(52), GUIScale(-28), 0 )
GUIDialogue.kPortraitTextColor = Color(1.0, 1.0, 1.0, 1.0)
GUIDialogue.kPortraitTextFontName = "fonts/Arial_17.fnt"
GUIDialogue.kPortraitTextFontSize = 15

GUIDialogue.kBackgroundExtraXOffset = 20
GUIDialogue.kBackgroundExtraYOffset = 20

GUIDialogue.kTextXOffset = 30
GUIDialogue.kTextYOffset = 17

GUIDialogue.kMaxAlpha = 0.9
GUIDialogue.kMinAlpha = 0.1
GUIDialogue.kFadeOutRate = 0.3

function GUIDialogue:Initialize()

    self.textureName = GUIDialogue.kMarineBackgroundTexture
    if PlayerUI_IsOnAlienTeam() then
        self.textureName = GUIDialogue.kAlienBackgroundTexture
    end
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize(Vector(Client.GetScreenWidth(), Client.GetScreenHeight(), 0))
    self.background:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.background:SetColor(Color(0, 0, 0, 0))
    // 1 above main menu,    
    self.background:SetLayer(kGUILayerMainMenu - 1)
    
    // Initialise the portrait
    self:InitializePortrait()
    self:InitializeDialogue()
    
    // Set up fading
    self.fadeOutTime = 0
    self.fadeMode = kFadeMode.Normal
    self:SetIsVisible(false)
    
end

function GUIDialogue:InitializePortrait()

    self.portraitBackground = GUIManager:CreateGraphicItem()
    self.portraitBackground:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.portraitBackground:SetSize(GUIDialogue.kPortraitBackgroundScale)
    self.portraitBackground:SetPosition(GUIDialogue.kPortraitBackgroundPos)
    self.portraitBackground:SetTexture(GUIDialogue.kPortraitBoxTexture)
    GUISetTextureCoordinatesTable(self.portraitBackground, GUIDialogue.kPortraitBackgroundCoords)
    self.background:AddChild(self.portraitBackground)
    
    self.portraitIcon = GUIManager:CreateGraphicItem()
    self.portraitIcon:SetAnchor(GUIItem.Left, GUIItem.Top)
	self.portraitIcon:SetPosition(GUIDialogue.kPortraitIconPos)
    self.portraitIcon:SetSize(GUIDialogue.kPortraitIconScale)
    self.portraitIcon:SetTexture(GUIDialogue.kDefaultPortraitTexture)
	GUISetTextureCoordinatesTable(self.portraitIcon, GUIDialogue.kPortraitIconCoords)
	self.portraitIcon:SetInheritsParentAlpha(true)
    self.portraitBackground:AddChild(self.portraitIcon)
    
    self.portraitText = GUIManager:CreateTextItem()
    self.portraitText:SetAnchor(GUIItem.Left, GUIItem.Bottom)
	self.portraitText:SetPosition(GUIDialogue.kPortraitTextPos)
    self.portraitText:SetTextAlignmentX(GUIItem.Align_Center)
    self.portraitText:SetTextAlignmentY(GUIItem.Align_Min)
    self.portraitText:SetColor(GUIDialogue.kPortraitTextColor)
	self.portraitText:SetFontSize(GUIDialogue.kPortraitTextFontSize)
	self.portraitText:SetFontName(GUIDialogue.kPortraitTextFontName)
    self.portraitText:SetText("Unknown")
    self.portraitText:SetFontIsBold(true)
    self.portraitText:SetIsVisible(true)
    self.portraitText:SetInheritsParentAlpha(true)
	self.portraitBackground:AddChild(self.portraitText)

end

function GUIDialogue:InitializeDialogue()

    self.dialogueBackground = GUIManager:CreateGraphicItem()
    self.dialogueBackground:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.dialogueBackground:SetSize(GUIDialogue.kDialogueBackgroundScale)
    self.dialogueBackground:SetPosition(GUIDialogue.kDialogueBackgroundPos)
    self.dialogueBackground:SetTexture(GUIDialogue.kDialogBoxTexture)
    GUISetTextureCoordinatesTable(self.dialogueBackground, GUIDialogue.kDialogueBackgroundCoords)
    self.background:AddChild(self.dialogueBackground)
	
	self.dialogueText = {}
	self:MakeDialogueTextLines({"Dialogue"})
	self:AdjustDialogueBoxHeight(1)

end

function GUIDialogue:SetPortraitTexture(newTexture)
	if newTexture then
		self.portraitIcon:SetTexture(newTexture)
	else
		self.portraitIcon:SetTexture(GUIDialogue.kDefaultPortraitTexture)
	end
end

function GUIDialogue:ClearDialogueTextLines()

	for index, textLine in ipairs(self.dialogueText) do
		
		GUI.DestroyItem(textLine)
		
	end
	
	self.dialogueText = {}

end

function GUIDialogue:MakeDialogueTextLines(newTextLines)
    
	for index, line in ipairs(newTextLines) do
    	local dialogueTextLine = GUIManager:CreateTextItem()
 	    dialogueTextLine:SetAnchor(GUIItem.Top, GUIItem.Left)
 	    local position = Vector(GUIDialogue.kDialogueTextPos.x, GUIDialogue.kDialogueTextPos.y, GUIDialogue.kDialogueTextPos.z)
 	    position.y = position.y + GUIDialogue.kDialogueTextLineHeight * index
		dialogueTextLine:SetPosition(position)
	    dialogueTextLine:SetTextAlignmentX(GUIItem.Align_Min)
	    dialogueTextLine:SetTextAlignmentY(GUIItem.Align_Min)
	    dialogueTextLine:SetColor(GUIDialogue.kDialogueTextColor)
	    dialogueTextLine:SetText(line)
	    dialogueTextLine:SetFontIsBold(false)
	    dialogueTextLine:SetIsVisible(true)
	    dialogueTextLine:SetInheritsParentAlpha(true)
		self.dialogueBackground:AddChild(dialogueTextLine)
	    table.insert(self.dialogueText, dialogueTextLine)
    end
end

function GUIDialogue:AdjustDialogueBoxHeight(lineCount)

	local newScale = Vector(GUIDialogue.kDialogueBackgroundScalePerLine.x, GUIDialogue.kDialogueBackgroundScalePerLine.y, GUIDialogue.kDialogueBackgroundScalePerLine.z)
	newScale.y = newScale.y * math.min(lineCount + 1, 5)
	self.dialogueBackground:SetSize(newScale)
	
end

function GUIDialogue:SetDialogueText(newText)

	local textBuffer = newText
	local newLines = {}
	self:ClearDialogueTextLines()	

	// Split the buffer into lines, at whitespace
	while string.len(textBuffer) > 0 do
		// If we can fit the whole buffer on this line, do so and blank all subsequent lines
		if string.len(textBuffer) <= GUIDialogue.kDialogueTextLineChars then
			table.insert(newLines, textBuffer)
			textBuffer = ""
		else
			// Otherwise, read in to the nearest whole word and then display the rest on the next line.
			local lineBuffer = string.sub(textBuffer, 1, GUIDialogue.kDialogueTextLineChars)
			// Search backwards and find the nearest whitespace
			local pattern = ".* "
			local lastSpace = string.len(lineBuffer) - string.find(lineBuffer:reverse(), " ")
			if lastSpace ~= nil then
				lineBuffer = string.sub(lineBuffer, 1, lastSpace + 1)
			end
			table.insert(newLines, lineBuffer)
			textBuffer = string.sub(textBuffer, string.len(lineBuffer) + 1)
		end
	end
	
	self:MakeDialogueTextLines(newLines)
	self:AdjustDialogueBoxHeight(#newLines)
	
end

function GUIDialogue:SetPortraitText(newText)
	self.portraitText:SetText(newText)
end

function GUIDialogue:SetIsVisible(value)

	self.background:SetIsVisible(value)

end

function GUIDialogue:GetAlpha()
	return self.portraitBackground:GetColor().a
end

function GUIDialogue:GetTargetAlpha()
	if self.fadeMode == kFadeMode.FadeIn then
		return GUIDialogue.kMaxAlpha
	elseif self.fadeMode == kFadeMode.FadeOut then
		return GUIDialogue.kMinAlpha
	else
		return self:GetAlpha()
	end
end

function GUIDialogue:SetAlpha(alphaVal)

	local portraitColor = self.portraitBackground:GetColor()
	portraitColor.a = alphaVal
	self.portraitBackground:SetColor(portraitColor)
	
	local dialogueColor = self.dialogueBackground:GetColor()
	dialogueColor.a = alphaVal
	self.dialogueBackground:SetColor(dialogueColor)

end

function GUIDialogue:Uninitialize()

    // Everything is attached to the background so uninitializing it will destroy all items.
    if self.background then
        GUI.DestroyItem(self.background)
    end
    
end

function GUIDialogue:StartFadeIn(fadeIn)
	if fadeIn then
		self.fadeMode = kFadeMode.FadeIn
	else
		self.fadeMode = kFadeMode.Normal
		self:SetAlpha(GUIDialogue.kMaxAlpha)
		self:SetIsVisible(true)
	end
end

function GUIDialogue:SetFadeoutTime(newTime)
	self.fadeOutTime = newTime
end

function GUIDialogue:StartFadeout(fadeOut)
	if fadeOut then
		self.fadeMode = kFadeMode.FadeOut
	else
		self.fadeMode = kFadeMode.Normal
		self:SetAlpha(GUIDialogue.kMinAlpha)
		self:SetIsVisible(false)
	end
end

function GUIDialogue:GetIsFading()

	return self.fadeMode ~= kFadeMode.Normal
	
end

function GUIDialogue:Update(deltaTime)

	if self.fadeOutTime > 0 and self.fadeOutTime <= Shared.GetTime() then
		self:StartFadeout()
		self.fadeOutTime = 0
	end

	if self:GetIsFading() then
		self:UpdateFading(deltaTime)
	end

end

function GUIDialogue:UpdateFading(deltaTime)

	// Increase/Decrease alpha
	local currentAlpha = self:GetAlpha()
	local targetAlpha = self:GetTargetAlpha()
	if currentAlpha == targetAlpha then
		self.fadeMode = kFadeMode.Normal
	else
		local nextAlpha = Slerp(currentAlpha, targetAlpha, GUIDialogue.kFadeOutRate)
		self:SetAlpha(nextAlpha)
		currentAlpha = nextAlpha
	end
	
	// Update visibility
	local visible = currentAlpha > GUIDialogue.kMinAlpha
	self:SetIsVisible(visible)

end