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
	self:ReplaceClassFunction("GUIAlienBuyMenu", "_InitializeSlots", "_InitializeSlots_Hook")
	self:ReplaceClassFunction("GUIAlienBuyMenu", "_InitializeUpgradeButtons", "_InitializeUpgradeButtons_Hook")
	self:ReplaceClassFunction("GUIAlienBuyMenu", "SendKeyEvent", "SendKeyEvent_Hook")
	self:ReplaceClassFunction("GUIAlienBuyMenu", "_HandleUpgradeClicked", "_HandleUpgradeClicked_Hook")
end

function CombatGUIAlienBuyMenu:Initialize_Hook(self)

	// Set overrides for GUIAlienBuyMenu globals here...
	GUIAlienBuyMenu.kMaxNumberOfUpgradeButtons = 10
	GUIAlienBuyMenu.kUpgradeButtonDistance = GUIScale(kCombatAlienBuyMenuUpgradeButtonDistance)

end

local function CreateSlot(self, category)

    local graphic = GUIManager:CreateGraphicItem()
    graphic:SetSize(Vector(GUIAlienBuyMenu.kSlotSize, GUIAlienBuyMenu.kSlotSize, 0))
    graphic:SetTexture(GUIAlienBuyMenu.kSlotTexture)
    graphic:SetLayer(kGUILayerPlayerHUDForeground3)
    graphic:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:AddChild(graphic)
    
    table.insert(self.slots, { Graphic = graphic, Category = category } )


end

function CombatGUIAlienBuyMenu:_InitializeSlots_Hook(self)
	 
	// For the first version of this, just make a slot for each upgrade.
	 self.slots = {}
    
	for i, upgrade in ipairs(UpsList) do
		if (upgrade:GetTeam() == "Alien" and upgrade:GetType() ~= kCombatUpgradeTypes.Class) then
			CreateSlot(self, upgrade:GetTechId())
		end
	end
    
    local anglePerSlot = (math.pi * kCombatAlienBuyMenuTotalAngle) / (#self.slots-1)
    
    for i = 1, #self.slots do
    
        local angle = (i-1) * anglePerSlot + math.pi * 0.1
        local distance = GUIAlienBuyMenu.kSlotDistance
        
        self.slots[i].Graphic:SetPosition( Vector( math.cos(angle) * distance - GUIAlienBuyMenu.kSlotSize * .5, math.sin(angle) * distance - GUIAlienBuyMenu.kSlotSize * .5, 0) )
        self.slots[i].Angle = angle
    
    end

end

function CombatGUIAlienBuyMenu:_InitializeUpgradeButtons_Hook(self)

    // There are purchased and unpurchased buttons. Both are managed in this list.
    self.upgradeButtons = { }
    
    local upgrades = AlienUI_GetPersonalUpgrades()
    
    for i = 1, #self.slots do
    
        local upgrades = AlienUI_GetUpgradesForCategory(self.slots[i].Category)
        local offsetAngle = self.slots[i].Angle
        local anglePerUpgrade = math.pi * 0.25 / 3
		anglePerUpgrade = anglePerUpgrade * 0.1
        local category = self.slots[i].Category
        
        for upgradeIndex = 1, #upgrades do
        
            local angle = offsetAngle + anglePerUpgrade * (upgradeIndex-1) - anglePerUpgrade
            local techId = upgrades[upgradeIndex]
            
            // Every upgrade has an icon.
            local buttonIcon = GUIManager:CreateGraphicItem()
            buttonIcon:SetAnchor(GUIItem.Middle, GUIItem.Center)
            buttonIcon:SetSize(Vector(GUIAlienBuyMenu.kUpgradeButtonSize, GUIAlienBuyMenu.kUpgradeButtonSize, 0))
            buttonIcon:SetPosition(Vector(-GUIAlienBuyMenu.kUpgradeButtonSize / 2, GUIAlienBuyMenu.kUpgradeButtonSize, 0))
            buttonIcon:SetTexture(GUIAlienBuyMenu.kBuyHUDTexture)
            
            local iconX, iconY = GetMaterialXYOffset(techId, false)
            iconX = iconX * GUIAlienBuyMenu.kUpgradeButtonTextureSize
            iconY = iconY * GUIAlienBuyMenu.kUpgradeButtonTextureSize        
            buttonIcon:SetTexturePixelCoordinates(iconX, iconY, iconX + GUIAlienBuyMenu.kUpgradeButtonTextureSize, iconY + GUIAlienBuyMenu.kUpgradeButtonTextureSize)
            
            // Render above the Alien image.
            buttonIcon:SetLayer(kGUILayerPlayerHUDForeground3)
            self.background:AddChild(buttonIcon)
            
            // The background is visible only inside the embryo.
            local buttonBackground = GUIManager:CreateGraphicItem()
            buttonBackground:SetSize(Vector(GUIAlienBuyMenu.kUpgradeButtonSize, GUIAlienBuyMenu.kUpgradeButtonSize, 0))
            buttonBackground:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
            buttonBackground:SetTexturePixelCoordinates(unpack(GUIAlienBuyMenu.kUpgradeButtonBackgroundTextureCoordinates))
            //buttonBackground:SetStencilFunc(GUIItem.NotEqual)
            buttonIcon:AddChild(buttonBackground)

            local unselectedPosition = Vector( math.cos(angle) * GUIAlienBuyMenu.kUpgradeButtonDistance - GUIAlienBuyMenu.kUpgradeButtonSize * .5, math.sin(angle) * GUIAlienBuyMenu.kUpgradeButtonDistance - GUIAlienBuyMenu.kUpgradeButtonSize * .5, 0 )
            
            buttonIcon:SetPosition(unselectedPosition)
            
            local purchased = AlienBuy_GetUpgradePurchased(techId)
            if purchased then
                table.insertunique(self.upgradeList, techId)
            end

            table.insert(self.upgradeButtons, { Background = buttonBackground, Icon = buttonIcon, TechId = techId, Category = techId,
                                                Selected = purchased, SelectedMovePercent = 0, Cost = GetUpgradeFromTechId(techId):GetLevels(), Purchased = purchased, Index = nil, 
                                                UnselectedPosition = unselectedPosition, SelectedPosition = self.slots[i].Graphic:GetPosition()  })
        
        
        end
    
    end

end

local function GetSelectedUpgradesCost(self)

    local cost = 0
	local purchasedTech = GetPurchasedTechIds()
	
	// Only count upgrades that we've selected and don't already own.
    for i, currentButton in ipairs(self.upgradeButtons) do
    
        if currentButton.Selected then
			
			local isPurchased = false
			
			for j, purchasedTechId in ipairs(purchasedTech) do
				if currentButton.TechId == purchasedTechId then
				    isPurchased = true
				end
			end
			
			// If the upgrade isn't purchased add the cost.
			if not isPurchased then
				cost = cost + currentButton.Cost
			end
			
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

local kDefaultColor = Color(1,1,1,1)
local kNotAvailableColor = Color(0.3, 0.3, 0.3, 1)
local kNotAllowedColor = Color(1, 0,0,1)

function CombatGUIAlienBuyMenu:Update_Hook(self, deltaTime)

	// Call our version of the evolve button script.
	UpdateEvolveButton(self)
	
	// Hide all the slots.
	for i, slot in ipairs(self.slots) do
		slot.Graphic:SetIsVisible(false)
	end
	
	local lvlFree = PlayerUI_GetPersonalResources()
	
	// Override the colours per our schema.
	// Always show, unless we can't afford the upgrade or it is not allowed.
	for i, currentButton in ipairs(self.upgradeButtons) do
		local useColor = kDefaultColor
		
		if currentButton.Cost > lvlFree then
			useColor = kNotAvailableColor 
		end
		
		if not currentButton.Selected and not AlienBuy_GetIsUpgradeAllowed(currentButton.TechId, self.upgradeList) then
			useColor = kNotAllowedColor
		end    
		
		currentButton.Icon:SetColor(useColor)
		
		if self:_GetIsMouseOver(currentButton.Icon) then
       
           local currentUpgradeInfoText = GetDisplayNameForTechId(currentButton.TechId)
           local tooltipText = GetTooltipInfoText(currentButton.TechId)
           
           if string.len(tooltipText) > 0 then
               currentUpgradeInfoText = currentUpgradeInfoText .. "\n" .. tooltipText
           end
           self:_ShowMouseOverInfo(currentUpgradeInfoText, currentButton.Cost)
           
       end
	end

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
    return false
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