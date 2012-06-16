
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUICombatTest.lua
//
// Created by: Brian Cronin (brianc@unknownworlds.com)
//
// Manages the text request menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUICombatTest' (GUIScript)

// Background constants.
GUICombatTest.kBackgroundXOffset = 0
GUICombatTest.kBackgroundYOffset = GUIScale(-200)
GUICombatTest.kBackgroundWidth = 200
GUICombatTest.kBackgroundColor = Color(0.1, 0.1, 0.1, 0.5)
// How many seconds for the background to fade in.
GUICombatTest.kBackgroundFadeRate = 0.25

// Text constants.
GUICombatTest.kTextFontSize = 18
GUICombatTest.kTextSayingColor = Color(1, 1, 1, 1)
// This is how much of a buffer around the text the background extends.
GUICombatTest.kTextBackgroundWidthBuffer = 4
GUICombatTest.kTextBackgroundHeightBuffer = 2
// This is the amount of space between text background items.
GUICombatTest.kTextBackgroundItemBuffer = 2
GUICombatTest.kTextBackgroundColor = Color(0.4, 0.4, 0.4, 1)

function GUICombatTest:Initialize()
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetAnchor(GUIItem.Left, GUIItem.Bottom)
    // Start off-screen.
    self.background:SetPosition(Vector(GUICombatTest.kBackgroundXOffset, GUICombatTest.kBackgroundYOffset, 0))
    self.background:SetSize(Vector(GUICombatTest.kBackgroundWidth, 0, 0))
    self.background:SetColor(GUICombatTest.kBackgroundColor)
    self.background:SetIsVisible(false)
    self.background:SetLayer(kGUILayerPlayerHUDForeground3)
    
    self.textSayings = { }
    self.reuseSayingItems = { }

end

function GUICombatTest:Uninitialize()


    GUI.DestroyItem(self.background)
    self.background = nil
    
end

function GUICombatTest:Update(deltaTime)

    PROFILE("GUICombatTest:Update")
    
    local visible = PlayerUI_ShowSayings()
    if visible then
        local sayings = PlayerUI_GetSayings()
        self:UpdateSayings(sayings)
    end
    
    self:UpdateFading(deltaTime, visible)
    
end

function GUICombatTest:UpdateFading(deltaTime, visible)
    
    if visible then
        self.background:SetIsVisible(true)
        self.background:SetColor(GUICombatTest.kBackgroundColor)
    end
    
    local fadeAmt = deltaTime * (1 / GUICombatTest.kBackgroundFadeRate)
    local currentColor = self.background:GetColor()
    if not visible and currentColor.a ~= 0 then
        currentColor.a = Slerp(currentColor.a, 0, fadeAmt)
        self.background:SetColor(currentColor)
        if currentColor.a == 0 then
            self.background:SetIsVisible(false)
        end
    end
    
end

function GUICombatTest:UpdateSayings(sayings)

    if sayings ~= nil then
        if table.count(self.textSayings) ~= table.count(sayings) then
            self:ResizeSayingsList(sayings)
        end

        local currentYPos = 0
        for i, textSaying in ipairs(self.textSayings) do
            textSaying["Text"]:SetText(sayings[i])
            
            currentYPos = currentYPos + GUICombatTest.kTextBackgroundItemBuffer + GUICombatTest.kTextBackgroundHeightBuffer
            textSaying["Background"]:SetPosition(Vector(0, currentYPos, 0))
            currentYPos = currentYPos + GUICombatTest.kTextFontSize + GUICombatTest.kTextBackgroundItemBuffer + GUICombatTest.kTextBackgroundHeightBuffer
            
            local totalWidth = GUICombatTest.kBackgroundWidth - (GUICombatTest.kTextBackgroundWidthBuffer * 2)
            local totalHeight = GUICombatTest.kTextFontSize + (GUICombatTest.kTextBackgroundHeightBuffer * 2)
            textSaying["Background"]:SetSize(Vector(totalWidth, totalHeight, 0))
        end
        
        local totalBackgroundHeight = GUICombatTest.kTextFontSize + (GUICombatTest.kTextBackgroundItemBuffer * 2) + (GUICombatTest.kTextBackgroundHeightBuffer * 2)
        totalBackgroundHeight = (table.count(self.textSayings) * totalBackgroundHeight) + (GUICombatTest.kTextBackgroundItemBuffer * 2)
        self.background:SetSize(Vector(GUICombatTest.kBackgroundWidth, totalBackgroundHeight, 0))
    end

end

function GUICombatTest:ResizeSayingsList(sayings)
    
    while table.count(sayings) > table.count(self.textSayings) do
        local newSayingItem = self:CreateSayingItem()
        table.insert(self.textSayings, newSayingItem)
        self.background:AddChild(newSayingItem["Background"])
        newSayingItem["Background"]:SetIsVisible(true)
    end
    
    while table.count(sayings) < table.count(self.textSayings) do
        self.background:RemoveChild(self.textSayings[1]["Background"])
        self.textSayings[1]["Background"]:SetIsVisible(false)
        table.insert(self.reuseSayingItems, self.textSayings[1])
        table.remove(self.textSayings, 1)
    end

end

function GUICombatTest:CreateSayingItem()
    
    // Reuse an existing player item if there is one.
    if table.count(self.reuseSayingItems) > 0 then
        local returnSayingItem = self.reuseSayingItems[1]
        table.remove(self.reuseSayingItems, 1)
        return returnSayingItem
    end
    
    local textBackground = GUIManager:CreateGraphicItem()
    textBackground:SetAnchor(GUIItem.Left, GUIItem.Top)
    textBackground:SetColor(GUICombatTest.kTextBackgroundColor)
    textBackground:SetInheritsParentAlpha(true)
    
    local newSayingItem = GUIManager:CreateTextItem()
    newSayingItem:SetFontSize(GUICombatTest.kTextFontSize)
    newSayingItem:SetAnchor(GUIItem.Left, GUIItem.Center)
    newSayingItem:SetPosition(Vector(GUICombatTest.kTextBackgroundWidthBuffer, 0, 0))
    newSayingItem:SetTextAlignmentX(GUIItem.Align_Min)
    newSayingItem:SetTextAlignmentY(GUIItem.Align_Center)
    newSayingItem:SetColor(GUICombatTest.kTextSayingColor)
    newSayingItem:SetInheritsParentAlpha(true)
    textBackground:AddChild(newSayingItem)
    
    return { Background = textBackground, Text = newSayingItem }
    
end
