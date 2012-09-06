//________________________________
//
//   	NS2 Combat Mod     
//	Made by JimWest and MCMLXXXIV, 2012
//
//________________________________

// combat_GUIAlienBuyMenu.lua

local HotReload = CombatGUIAlienBuyMenu
if(not HotReload) then
  CombatGUIAlienBuyMenu = {}
  ClassHooker:Mixin("CombatGUIAlienBuyMenu")
end
    
function CombatGUIAlienBuyMenu:OnLoad()

    ClassHooker:SetClassCreatedIn("GUIAlienBuyMenu", "lua/GUIAlienBuyMenu.lua") 
    self:RawHookClassFunction("GUIAlienBuyMenu", "Initialize", "Initialize_Hook")
	self:PostHookClassFunction("GUIAlienBuyMenu", "Update", "Update_Hook")
	self:ReplaceClassFunction("GUIAlienBuyMenu", "_UpdateUpgrades", "_UpdateUpgrades_Hook")
	self:ReplaceClassFunction("GUIAlienBuyMenu", "SendKeyEvent", "SendKeyEvent_Hook")
	self:ReplaceClassFunction("GUIAlienBuyMenu", "_HandleUpgradeClicked", "_HandleUpgradeClicked_Hook")
end

function CombatGUIAlienBuyMenu:Initialize_Hook(self)

	GUIAlienBuyMenu.kMaxNumberOfUpgradeButtons = 10

end


local function GetSelectedUpgradesCost(self)

    local cost = 0
    for i, currentButton in ipairs(self.upgradeButtons) do
    
        if currentButton.Selected then
            cost = cost + currentButton.Cost
        end
        
    end
    
    return cost
    
end

local function GetNumberOfSelectedUpgrades(self)

    local numSelected = 0
    for i, currentButton in ipairs(self.upgradeButtons) do
    
        if currentButton.Selected and not currentButton.Purchased then
            numSelected = numSelected + 1
        end
        
    end
    
    return numSelected
    
end

local function GetCanAffordAlienTypeAndUpgrades(self, alienType)

    local alienCost = AlienBuy_GetAlienCost(alienType)
    local upgradesCost = GetSelectedUpgradesCost(self)
    // Cannot buy the current alien without upgrades.
    if alienType == AlienBuy_GetCurrentAlien() then
        alienCost = 0
    end
    
    return PlayerUI_GetPlayerResources() >= alienCost + upgradesCost - AlienBuy_GetHyperMutationCostReduction(self.selectedAlienType)
    
end

/**
 * Returns true if the player has a different Alien or any upgrade selected.
 */
local function GetAlienOrUpgradeSelected(self)
    return self.selectedAlienType ~= AlienBuy_GetCurrentAlien() or GetNumberOfSelectedUpgrades(self) > 0
end

local function UpdateEvolveButton(self)

    local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(GUIAlienBuyMenu.kAlienTypes[self.selectedAlienType].Index)
    local selectedUpgradesCost = GetSelectedUpgradesCost(self)
    local numberOfSelectedUpgrades = GetNumberOfSelectedUpgrades(self)
    local evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonTextureCoordinates
    
    evolveText = Locale.ResolveString("ABM_SELECT_UPGRADES")
    
    // If the current alien is selected with no upgrades, cannot evolve.
    if self.selectedAlienType == AlienBuy_GetCurrentAlien() and numberOfSelectedUpgrades == 0 then
        evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonNeedResourcesTextureCoordinates
    elseif researching then
    
        // If researching, cannot evolve.
        evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonNeedResourcesTextureCoordinates
        evolveText = "Researching..."
        
    elseif not GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType) then
    
        // If cannot afford selected alien type and/or upgrades, cannot evolve.
        evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonNeedResourcesTextureCoordinates
        evolveText = Locale.ResolveString("ABM_NEED")
        evolveCost = AlienBuy_GetAlienCost(self.selectedAlienType) + selectedUpgradesCost - AlienBuy_GetHyperMutationCostReduction(self.selectedAlienType)
        
    else
    
        // Evolution is possible! Darwin would be proud.
        local totalCost = selectedUpgradesCost
        
        // Cannot buy the current alien.
        if self.selectedAlienType ~= AlienBuy_GetCurrentAlien() then
            totalCost = totalCost + AlienBuy_GetAlienCost(self.selectedAlienType)
        end
        
        evolveText = Locale.ResolveString("ABM_EVOLVE_FOR")
        evolveCost = totalCost - AlienBuy_GetHyperMutationCostReduction(self.selectedAlienType) // shows also negative values
        
    end
            
    self.evolveButtonBackground:SetTexturePixelCoordinates(unpack(evolveButtonTextureCoords))
    self.evolveButtonText:SetText(evolveText)
    self.evolveResourceIcon:SetIsVisible(evolveCost ~= nil)
    local totalEvolveButtonTextWidth = 0
    
    if evolveCost ~= nil then
    
        local evolveCostText = ToString(evolveCost)
        self.evolveButtonResAmount:SetText(evolveCostText)
        totalEvolveButtonTextWidth = totalEvolveButtonTextWidth + self.evolveResourceIcon:GetSize().x +
                                     self.evolveButtonResAmount:GetTextWidth(evolveCostText)
        
    end
    
    self.evolveButtonText:SetPosition(Vector(-totalEvolveButtonTextWidth / 2, 0, 0))
    
    local allowedToEvolve = not researching and GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType) and hasGameStarted
    allowedToEvolve = allowedToEvolve and GetAlienOrUpgradeSelected(self)
    local veinsAlpha = 0
    self.evolveButtonBackground:SetScale(Vector(1, 1, 0))
    
    if allowedToEvolve then
    
        if self:_GetIsMouseOver(self.evolveButtonBackground) then
        
            veinsAlpha = 1
            self.evolveButtonBackground:SetScale(Vector(1.1, 1.1, 0))
            
        else
            veinsAlpha = (math.sin(Shared.GetTime() * 4) + 1) / 2
        end
        
    end
    
    self.evolveButtonVeins:SetColor(Color(1, 1, 1, veinsAlpha))
    
end

function CombatGUIAlienBuyMenu:Update_Hook(self, deltaTime)

	UpdateEvolveButton(self)

end
















function CombatGUIAlienBuyMenu:_UpdateUpgrades_Hook(self, deltaTime)

    for i, currentButton in ipairs(self.upgradeButtons) do
        currentButton.Icon:SetIsVisible(false)
    end
    
    local allUpgrades = { }
    
    local upgradeIndex = 0
    
    local numElementsPerPurchasedUpgrades = 7
    local purchasedUpgrades = AlienBuy_GetPurchasedUpgrades(self.selectedAlienType)
    numPurchasedUpgrades = table.count(purchasedUpgrades) / numElementsPerPurchasedUpgrades
    for i = 0, numPurchasedUpgrades - 1 do
        local currentIndex = i * numElementsPerPurchasedUpgrades + 1
        local currentUpgrade = { }
        currentUpgrade.IconXOffset = purchasedUpgrades[currentIndex] * GUIAlienBuyMenu.kUpgradeButtonTextureSize
        currentUpgrade.IconYOffset = purchasedUpgrades[currentIndex + 1] * GUIAlienBuyMenu.kUpgradeButtonTextureSize
        currentUpgrade.Name = purchasedUpgrades[currentIndex + 2]
        currentUpgrade.Tooltip = purchasedUpgrades[currentIndex + 3]
        currentUpgrade.Purchased = true
        currentUpgrade.TechId = purchasedUpgrades[currentIndex + 4]
        currentUpgrade.Available = purchasedUpgrades[currentIndex + 5]
        
        if self.initialSelect == true then
            currentUpgrade.Selected = true
            currentUpgrade.Initialized = true
        end
        
        currentUpgrade.Index = upgradeIndex
        upgradeIndex = upgradeIndex + 1
        
        table.insert(allUpgrades, currentUpgrade)
    end
    
    local numElementsPerUnpurchasedUpgrades = 8
    local unpurchasedUpgrades = AlienBuy_GetUnpurchasedUpgrades(self.selectedAlienType)
    local numUnpurchasedUpgrades = table.count(unpurchasedUpgrades) / numElementsPerUnpurchasedUpgrades
    for i = 0, numUnpurchasedUpgrades - 1 do
        local currentIndex = i * numElementsPerUnpurchasedUpgrades + 1
        local currentUpgrade = { }
        currentUpgrade.IconXOffset = unpurchasedUpgrades[currentIndex] * GUIAlienBuyMenu.kUpgradeButtonTextureSize
        currentUpgrade.IconYOffset = unpurchasedUpgrades[currentIndex + 1] * GUIAlienBuyMenu.kUpgradeButtonTextureSize
        currentUpgrade.Name = unpurchasedUpgrades[currentIndex + 2]
        currentUpgrade.Tooltip = unpurchasedUpgrades[currentIndex + 3]
        currentUpgrade.ResearchPercent = unpurchasedUpgrades[currentIndex + 4]
        currentUpgrade.Cost = unpurchasedUpgrades[currentIndex + 5]
        currentUpgrade.Purchased = false
        currentUpgrade.Index = upgradeIndex
        currentUpgrade.TechId = unpurchasedUpgrades[currentIndex + 6]
        // All ups are available
        currentUpgrade.Available = AlienBuy_GetGotRequirements(currentUpgrade.TechId)
        upgradeIndex = upgradeIndex + 1
        table.insert(allUpgrades, currentUpgrade)
    end
    
    local numberOfUpgrades = table.count(allUpgrades)
    ASSERT(numberOfUpgrades <= GUIAlienBuyMenu.kMaxNumberOfUpgradeButtons)

    local offsetAmount = math.pi / 9
    local buttonAngles = {  math.pi / 2, 
                            math.pi / 2 + offsetAmount, 
                            math.pi / 2 - offsetAmount,
                            math.pi / 2 + offsetAmount * 2, 
                            math.pi / 2 - offsetAmount * 2,
                            math.pi / 2 + offsetAmount * 3, 
                            math.pi / 2 - offsetAmount * 3,
                            math.pi / 2 + offsetAmount * 4 ,
                            math.pi / 2 - offsetAmount * 4 ,
                            math.pi / 2 + offsetAmount * 5 
                        }
                        
    local numSelected = 0

    for i, currentUpgrade in ipairs(allUpgrades) do
    
        local currentButton = self.upgradeButtons[i + 1]
        currentButton.Cost = (currentUpgrade.Cost ~= nil and currentUpgrade.Cost) or 0
        currentButton.Purchased = currentUpgrade.Purchased
        currentButton.Index = currentUpgrade.Index
        currentButton.Icon:SetIsVisible(true)
        local xOffset = currentUpgrade.IconXOffset
        local yOffset = currentUpgrade.IconYOffset
        currentButton.Icon:SetTexturePixelCoordinates(xOffset, yOffset, xOffset + GUIAlienBuyMenu.kUpgradeButtonTextureSize, yOffset + GUIAlienBuyMenu.kUpgradeButtonTextureSize)

        // The movementScaleAdjust will make the button get smaller the closer it is to the center of the movement.
        local movementScaleAdjust = 0
        local buttonDistance = GUIAlienBuyMenu.kUpgradeButtonDistance
        currentButton.Available = currentUpgrade.Available
        
        if currentUpgrade.Initialized then
        
            buttonDistance = buttonDistance - GUIAlienBuyMenu.kUpgradeButtonDistanceInside
            currentUpgrade.Initialized = false
            local currentTweener = self:_GetUpgradeTweener(currentButton)
            currentTweener.setCurrent(1)
            currentTweener.setMode("forward")
            currentButton.Selected = true
            currentButton.SelectedMovePercent = 1
            
        else
        
            currentButton.SelectedMovePercent = self:_GetUpgradeTweener(currentButton).getCurrentProperties().percent
            local distanceToCenter = math.abs(0.5 - currentButton.SelectedMovePercent)
            // Percent goes from 0 - 1 - 0 when moving to center and then back out.
            local distanceToCenterPercent = 1 - (distanceToCenter / 0.5)
            // Get smaller the closer to the center.
            movementScaleAdjust = -(distanceToCenterPercent * 0.5)
            buttonDistance = buttonDistance - GUIAlienBuyMenu.kUpgradeButtonDistanceInside * currentButton.SelectedMovePercent
            
        end
        
        local positionOffset = Vector(math.cos(buttonAngles[i]) * buttonDistance, math.sin(buttonAngles[i]) * buttonDistance, 0)
        local buttonPosition = Vector(positionOffset.x - GUIAlienBuyMenu.kUpgradeButtonSize / 2, positionOffset.y - GUIAlienBuyMenu.kUpgradeButtonSize / 2, 0)
        currentButton.Icon:SetPosition(buttonPosition)
        
        // Do not show backgrounds for purchased buttons.
        currentButton.Background:SetIsVisible(not currentUpgrade.Purchased)
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        local mouseOverButton = self:_GetIsMouseOver(currentButton.Icon)
        
        local iconColor = ConditionalValue(currentButton.Available, Color(1,1,1,1), Color(1,0,0,1))
        
        // Only moused over, unpurchased upgrades should look clickable (scale up).
        local mouseOverScale = ((mouseOverButton) and (Vector(1.1, 1.1, 0) ) ) or (Vector(1, 1, 0) )
        currentButton.Icon:SetScale(mouseOverScale + Vector(movementScaleAdjust, movementScaleAdjust, 0))
        currentButton.Icon:SetColor(iconColor)
        
        if mouseOverButton then
        
            local currentUpgradeInfoText = currentUpgrade.Name
            if string.len(currentUpgrade.Tooltip) > 0 then
                currentUpgradeInfoText = currentUpgradeInfoText .. "\n" .. currentUpgrade.Tooltip
            end
            self:_ShowMouseOverInfo(currentUpgradeInfoText, currentUpgrade.Cost)
            currentButton.Background:SetScale(mouseOverScale)
            
        else
            currentButton.Background:SetScale(Vector(1, 1, 0))
        end
        
        if currentButton.Selected == true then
            numSelected = numSelected + 1
        end
        
        currentButton.TechId = currentUpgrade.TechId
        
        i = i + 1
        
    end
    
    self.initialSelect = false
    self.numSelectedUpgrades = numSelected

end

function CombatGUIAlienBuyMenu:SendKeyEvent_Hook(self, key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
    
        self.mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
        
            // Check if the evolve button was selected.
            local allowedToEvolve = GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType)
            allowedToEvolve = allowedToEvolve and GetAlienOrUpgradeSelected(self)
            if allowedToEvolve and self:_GetIsMouseOver(self.evolveButtonBackground) then
            
                local purchases = { }
                // Buy the selected alien if we have a different one selected.
                
                if self.selectedAlienType ~= AlienBuy_GetCurrentAlien() then
                    if AlienBuy_GetCurrentAlien() == 5 then
                        // only buy another calss when youre a skulk
                        table.insert(purchases, AlienBuy_GetTechIdForAlien(self.selectedAlienType))
                    end
                else
                
                    // Buy all selected upgrades.
                    for i, currentButton in ipairs(self.upgradeButtons) do
                    
                        if currentButton.Selected then
                            table.insert(purchases, currentButton.TechId)
                        end
                        
                    end
                
                end
                
                self:_DeselectAllUpgrades()
                
                closeMenu = true
                inputHandled = true
                
                if table.maxn(purchases)  > 0 then
                    AlienBuy_Purchase(purchases)
                end
                
                AlienBuy_OnPurchase()
                
            end
            
            inputHandled = self:_HandleUpgradeClicked(mouseX, mouseY) or inputHandled
            
            if not inputHandled then
            
                // Check if an alien was selected.
                for k, buttonItem in ipairs(self.alienButtons) do
                    
                    local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(buttonItem.TypeData.Index)
                    if (researched or researching) and self:_GetIsMouseOver(buttonItem.Button) then
                        
                        if (AlienBuy_GetCurrentAlien() == 5) then
                            // Deselect all upgrades when a different alien type is selected.
                            if self.selectedAlienType ~= buttonItem.TypeData.Index  then
                                AlienBuy_OnSelectAlien(GUIAlienBuyMenu.kAlienTypes[buttonItem.TypeData.Index].Name)
                            end
                            
                            self.selectedAlienType = buttonItem.TypeData.Index
                            inputHandled = true
                            break
    
                        end
                        
                    end
                    
                end
                
                // Check if the close button was pressed.
                if self:_GetIsMouseOver(self.closeButton) then
                
                    closeMenu = true
                    inputHandled = true
                    AlienBuy_OnClose()
                    
                end
                
            end
            
        end
        
    end
    
    // AlienBuy_Close() must be the last thing called.
    if closeMenu then
    
        self.closingMenu = true
        AlienBuy_Close()
        
    end
    
    return inputHandled
    
end

// only 1 upgrade should be selectable
local function _GetHasMaximumSelected(self)
    // only 1 upgrade should be selectable, but already bought ups are OK
    return self.numSelectedUpgrades - numPurchasedUpgrades >= 20
end

function CombatGUIAlienBuyMenu:_HandleUpgradeClicked_Hook(self, mouseX, mouseY)

    local inputHandled = false
    
    for i, currentButton in ipairs(self.upgradeButtons) do
        // Can't select if it has been purchased already.
        if (not _GetHasMaximumSelected(self) or currentButton.Selected == true) and self:_GetIsMouseOver(currentButton.Icon) then
            currentButton.Selected = not currentButton.Selected
            inputHandled = true
            if currentButton.Selected then AlienBuy_OnUpgradeSelected() else AlienBuy_OnUpgradeDeselected() end
            // Setup a tweener based on the state of the button so it moves to the correct spot.
            local currentTweener = self:_GetUpgradeTweener(currentButton)
            currentTweener.setCurrent((currentButton.Selected and 1) or 2)
            currentTweener.setMode((currentButton.Selected and "forward") or "backward")
        end
    end
    
    return inputHandled

end

if (not HotReload) then
	CombatGUIAlienBuyMenu:OnLoad()
end