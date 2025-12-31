CDTT.UI = CDTT.UI or {} 

CDTT.UI.MenuFrame = nil
CDTT.UI.isEditMode = false


-------------------------------------------------------------------
-- Function that is called when clicking on the combat log checkbox
-------------------------------------------------------------------


function CDTT.UI.OnCombatLogCheckboxClick(self)
    CDTT_Core_Settings.combatLogMode = self:GetChecked()
    CDTT.Core.CombatLogMode = self:GetChecked()

    if self:GetChecked() then
        print("|cff00ff00CDTT|r Combat Log tracking enabled. Cooldowns will be tracked from combat log.")
        CDTT.Core.CombatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        print("|cff00ff00CDTT|r Combat Log tracking disabled. Using addon messages only.")
        CDTT.Core.CombatLogFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end




-------------------------------------------------------------------
-- Function that is called when clicking on the show tracker button
-------------------------------------------------------------------

function CDTT.UI.OnShowTrackerClicked(self)
    -- Create frames if they don't exist
    if not CDTT.CategoryFrames.Frames then
        CDTT.CategoryFrames.CreateMainFrame()
    end

    if not CDTT.UI.isEditMode then
        -- Enter edit mode
        CDTT.UI.isEditMode = true

        for categoryKey, frame in pairs(CDTT.CategoryFrames.Frames) do
            CDTT_Core_Settings.categoryFrames[categoryKey].visible = true
            local settings = CDTT_Core_Settings.categoryFrames[categoryKey]
            if settings then
                frame:ClearAllPoints()
                frame:SetScale(settings.scale or 1)
                frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", settings.x, settings.y)
                frame:SetSize(200,200)
            end

            frame:Show()
            frame:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true,
                tileSize = 32,
                edgeSize = 32,
                insets = { left = 8, right = 8, top = 8, bottom = 8 }
            })
            frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
            frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
            frame:SetMovable(true)
            frame:EnableMouse(true)
            frame:RegisterForDrag("LeftButton")
            if frame.resizeButton then
                frame.resizeButton:Show()
            end
            if frame.header then
                frame.header:Show()
                frame.closeBtn:Show()
            end
        end

        self:SetText("Save Position & Hide Background")
        print("|cff00ff00CDTT|r Edit mode enabled.")
    else
        -- Exit edit mode
        CDTT.UI.isEditMode = false

        for _, frame in pairs(CDTT.CategoryFrames.Frames) do
            frame:SetBackdrop(nil)
            frame:SetMovable(false)
            frame:EnableMouse(false)
            if frame.resizeButton then
                frame.resizeButton:Hide()
            end
            if frame.header then
                frame.header:Hide()
                frame.closeBtn:Hide()
            end
        end

        self:SetText("Show Tracker")
        print("|cff00ff00CDTT|r Position saved.")
    end
end





-------------------------------------------------------------------
-- Function that is called when clicking on the hide tracker button
-------------------------------------------------------------------

function CDTT.UI.OnHideTrackerClicked()
    if not CDTT.CategoryFrames.Frames then return end

    for _, frame in pairs(CDTT.CategoryFrames.Frames) do
        frame:Hide()
        frame.closeBtn:Hide()
    end

    CDTT.UI.isEditMode = false

    if CDTT.UI.MenuFrame and CDTT.UI.MenuFrame.showTrackerBtn then
        CDTT.UI.MenuFrame.showTrackerBtn:SetText("Show Tracker")
    end

    print("|cff00ff00CDTT|r Cooldown Tracker hidden.")
end


-------------------------------------------------------------------
-- Function that is called when clicking on the fill test data button
-------------------------------------------------------------------

function CDTT.UI.OnFillTestDataClicked()
    wipe(CDTT.Core.MemberCooldowns)
    if CDTT.Simulation and CDTT.Simulation.FillWithTestData then
        CDTT.Simulation.FillWithTestData(50)
    end
    print("|cff00ff00CDTT|r Filling cooldown tracker with test data...")
end




-------------------------------------------------------------------
-- Function to reset all tracked spells to READY
-------------------------------------------------------------------

function CDTT.UI.ResetAllToReady()
    local now = GetTime()
    for playerName, spells in pairs(CDTT.Core.MemberCooldowns) do
        for spellName, data in pairs(spells) do
            -- Set expiration to now, effectively making it ready
            data.expiresAt = now
        end
    end
    if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
        CDTT.CategoryFrames.UpdateMemberDisplay()
    end
end



-------------------------------------------------------------------
-- Function that is called when clicking on the reset to ready button
-------------------------------------------------------------------

function CDTT.UI.OnResetReadyClicked()
    CDTT.UI.ResetAllToReady()
    print("|cff00ff00CDTT|r All cooldowns set to READY.")
end



-------------------------------------------------------------------
-- Function that is called when clicking on the clear button
-------------------------------------------------------------------

function CDTT.UI.OnClearClicked()
    wipe(CDTT.Core.MemberCooldowns)
    if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
        CDTT.CategoryFrames.UpdateMemberDisplay()
    end
    print("|cff00ff00CDTT|r Cleared all cooldown data.")
end




-------------------------------------------------------------------
-- Function that is called when changing the alpha slider
-------------------------------------------------------------------

function CDTT.UI.OnAlphaSliderChanged(self, value)
    CDTT_Core_Settings.barAlpha = value
    _G[self:GetName() .. "Text"]:SetText(string.format("%.0f%%", value * 100))
    if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
        CDTT.CategoryFrames.UpdateMemberDisplay()
    end
end



-------------------------------------------------------------------
-- Function that is called when changing the request delay slider
-------------------------------------------------------------------


function CDTT.UI.OnRequestDelayChanged(self, value)
    local val = math.floor(value + 0.5)
    CDTT_Core_Settings.requestDelay = val
    _G[self:GetName() .. "Text"]:SetText(val)
end





-------------------------------------------------------------------
-- Function that creates category size sliders
-------------------------------------------------------------------

function CDTT.UI.CreateCategorySliders(menu, category, yPos, scaleLabel)

        if not CDTT_Core_Settings.categoryFrames then
            CDTT_Core_Settings.categoryFrames = {}
        end

        if not CDTT_Core_Settings.categoryFrames[category.key] then
            CDTT_Core_Settings.categoryFrames[category.key] = {
                scale = 1,
                x = (string.byte(category.key) - string.byte("A")) * 150,
                y = -100,
                width = 200,
                height = 200
            }
        end

        local catLabel = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        catLabel:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 10, yPos - 10)
        catLabel:SetText(category.name .. ":")
        catLabel:SetTextColor(category.color.r, category.color.g, category.color.b)

        local slider = CreateFrame("Slider", "CDTTCooldownScale" .. category.key, menu, "OptionsSliderTemplate")
        slider:SetPoint("LEFT", catLabel, "RIGHT", 10, 0)
        slider:SetMinMaxValues(0.5, 2.0)
        slider:SetValueStep(0.1)
        slider:SetWidth(80)

        -- Set up the text labels first before setting value
        local sliderName = slider:GetName()
        _G[sliderName .. "Low"]:SetText("0.5")
        _G[sliderName .. "High"]:SetText("2.0")
        _G[sliderName .. "Text"]:SetText(
            string.format("%.1f", CDTT_Core_Settings.categoryFrames[category.key].scale or 1)
        )
        _G[sliderName .. "Value"]:Hide()

        -- Set the value
        slider:SetValue(CDTT_Core_Settings.categoryFrames[category.key].scale or 1)

        slider.categoryKey = category.key -- Store reference
       

        slider:SetScript("OnValueChanged", function(self, value)
            -- Update the text display
            local name = self:GetName()
            if name and _G[name .. "Text"] then
                _G[name .. "Text"]:SetText(string.format("%.1f", value))
            end

            -- Double check the table still exists
            if not CDTT_Core_Settings.categoryFrames then
                CDTT_Core_Settings.categoryFrames = {}
            end
            if not CDTT_Core_Settings.categoryFrames[self.categoryKey] then
                CDTT_Core_Settings.categoryFrames[self.categoryKey] = {
                    scale = 1,
                    x = 0,
                    y = -100,
                    width = 200,
                    height = 200
                }
            end

            CDTT_Core_Settings.categoryFrames[self.categoryKey].scale = value
            if CDTT.CategoryFrames and CDTT.CategoryFrames[self.categoryKey] then
                CDTT.CategoryFrames[self.categoryKey]:SetScale(value)
            end
        end)

        return yPos - 35

end




-------------------------------------------------------------------
-- Function that creates the main UI menu
-------------------------------------------------------------------




function CDTT.UI.CreateMenu()

    if CDTT.UI.MenuFrame then
        return CDTT.UI.MenuFrame
    end

    local menu = CreateFrame("Frame", "CDTTCooldownMenu", UIParent)
    menu:SetSize(600, 425)
    menu:SetPoint("CENTER")
    menu:SetBackdrop(
        {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = {left = 8, right = 8, top = 8, bottom = 8}
        }
    )
    menu:SetBackdropColor(0, 0, 0, 0.95)
    menu:EnableMouse(true)
    menu:SetMovable(true)
    menu:RegisterForDrag("LeftButton")
    menu:SetScript("OnDragStart", menu.StartMoving)
    menu:SetScript("OnDragStop", menu.StopMovingOrSizing)
    menu:SetClampedToScreen(true)
    menu:Hide()

    -- Title
    local title = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("|cff00ff00CDTT" .. " v" .. CDTT.Core.Version .. "|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, menu, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript(
        "OnClick",
        function()
            menu:Hide()
        end
    )

    -- Button dimensions
    local buttonWidth = CDTT.Core.buttonWidth
    local buttonHeight = CDTT.Core.buttonHeight
    local startY = CDTT.Core.startY
    local spacing = CDTT.Core.spacing


    -- Combat Log Mode Checkbox
    local combatLogCheckbox = CreateFrame("CheckButton", nil, menu, "UICheckButtonTemplate")
    combatLogCheckbox:SetPoint("TOPLEFT", menu, "TOPLEFT", 30, -30)
    combatLogCheckbox:SetSize(20, 20)
    combatLogCheckbox:SetChecked(CDTT_Core_Settings.combatLogMode or false)

    local combatLogLabel = menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    combatLogLabel:SetPoint("LEFT", combatLogCheckbox, "RIGHT", 5, 0)
    combatLogLabel:SetText("Combat Log Mode")
    combatLogCheckbox:SetScript("OnClick", CDTT.UI.OnCombatLogCheckboxClick)

    combatLogCheckbox:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Combat Log Mode", 1, 1, 1)
        GameTooltip:AddLine("ON: Tracks cooldowns from combat log events. More performance heavy and combatlog - range dependent, but works for everyone who does not have the addon. Shown cooldowns are based on default values.", 0.7, 0.7, 0.7, true)
        GameTooltip:AddLine("OFF: Uses addon messages. Only tracks players who have CDTT installed, unlimited range, accurate cooldowns which take talents and mystic enchants into consideration.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)

    combatLogCheckbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)


    -- Group/Raid Only Checkbox (shown only when combat log is enabled)
    local groupOnlyCheckbox = CreateFrame("CheckButton", nil, menu, "UICheckButtonTemplate")
    groupOnlyCheckbox:SetPoint("TOPLEFT", combatLogCheckbox, "BOTTOMLEFT", 20, -5)
    groupOnlyCheckbox:SetSize(20, 20)
    groupOnlyCheckbox:SetChecked(CDTT_Core_Settings.groupOnlyTracking or false)

    local groupOnlyLabel = menu:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    groupOnlyLabel:SetPoint("LEFT", groupOnlyCheckbox, "RIGHT", 5, 0)
    groupOnlyLabel:SetText("Track Group/Raid Only")

    groupOnlyCheckbox:SetScript("OnClick", function(self)
        CDTT_Core_Settings.groupOnlyTracking = self:GetChecked()
    end)

    -- Update visibility based on combat log mode
    combatLogCheckbox:SetScript("OnClick", function(self)
        CDTT.UI.OnCombatLogCheckboxClick(self)
        if self:GetChecked() then
            groupOnlyCheckbox:Show()
            groupOnlyLabel:Show()
        else
            groupOnlyCheckbox:Hide()
            groupOnlyLabel:Hide()
        end
    end)

    -- Initial visibility
    if not combatLogCheckbox:GetChecked() then
        groupOnlyCheckbox:Hide()
        groupOnlyLabel:Hide()
    end

    -- Show/Edit Tracker Button
    local showTrackerBtn = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    showTrackerBtn:SetSize(buttonWidth, buttonHeight)
    showTrackerBtn:SetPoint("TOPLEFT", 50, startY)
    showTrackerBtn:SetText("Show Tracker")
    showTrackerBtn:SetScript("OnClick", CDTT.UI.OnShowTrackerClicked)
    menu.showTrackerBtn = showTrackerBtn

    -- Hide Tracker Button
    local hideTrackerBtn = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    hideTrackerBtn:SetSize(buttonWidth, buttonHeight)
    hideTrackerBtn:SetPoint("TOP", showTrackerBtn, "BOTTOM", 0, -spacing)
    hideTrackerBtn:SetText("Hide Tracker")
    hideTrackerBtn:SetScript("OnClick", CDTT.UI.OnHideTrackerClicked)


    -- Config Button
    local configBtn = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    configBtn:SetSize(buttonWidth, buttonHeight)
    configBtn:SetPoint("TOP", hideTrackerBtn, "BOTTOM", 0, -spacing)
    configBtn:SetText("Configure Tracked Spells")
    configBtn:SetScript("OnClick", CDTT.SpellConfig.ShowConfigWindow)


    -- Fill Test Data Button
    local testBtn = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    testBtn:SetSize(buttonWidth, buttonHeight)
    testBtn:SetPoint("TOP", configBtn, "BOTTOM", 0, -spacing)
    testBtn:SetText("Fill with Test Data")
    testBtn:SetScript("OnClick", CDTT.UI.OnFillTestDataClicked)


    -- Reset to Ready Button
    local resetReadyBtn = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    resetReadyBtn:SetSize(buttonWidth, buttonHeight)
    resetReadyBtn:SetPoint("TOP", testBtn, "BOTTOM", 0, -spacing)
    resetReadyBtn:SetText("Reset All to Ready")
    resetReadyBtn:SetScript("OnClick", CDTT.UI.OnResetReadyClicked)

    -- Clear Data Button
    local clearBtn = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    clearBtn:SetSize(buttonWidth, buttonHeight)
    clearBtn:SetPoint("TOP", resetReadyBtn, "BOTTOM", 0, -spacing)
    clearBtn:SetText("Clear All Cooldowns")
    clearBtn:SetScript("OnClick", CDTT.UI.OnClearClicked)


    -- alpha bar slider

    local alphaLabel = menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    alphaLabel:SetPoint("BOTTOM", clearBtn, "BOTTOM", -65, -30)
    alphaLabel:SetText("Cooldown Bar Opacity:")

    local alphaSlider = CreateFrame("Slider", "CDTTCooldownAlphaSlider", menu, "OptionsSliderTemplate")
    alphaSlider:SetPoint("LEFT", alphaLabel, "RIGHT", 30, 0)
    alphaSlider:SetMinMaxValues(0.1, 1.0)
    alphaSlider:SetValue(CDTT_Core_Settings.barAlpha or 0.9)
    alphaSlider:SetValueStep(0.1)
    alphaSlider:SetWidth(100)
    _G[alphaSlider:GetName() .. "Low"]:SetText("10%")
    _G[alphaSlider:GetName() .. "High"]:SetText("100%")
    _G[alphaSlider:GetName() .. "Text"]:SetText(
        string.format("%.0f%%", (CDTT_Core_Settings.barAlpha or 0.9) * 100)
    )
    alphaSlider:SetScript("OnValueChanged", CDTT.UI.OnAlphaSliderChanged)



    --  Request Delay Slider
    local delayLabel = menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    delayLabel:SetPoint("TOPLEFT", alphaLabel, "BOTTOMLEFT", 0, -30)
    delayLabel:SetText("Request Countdown:")

    local delaySlider = CreateFrame("Slider", "CDTTCooldownDelaySlider", menu, "OptionsSliderTemplate")
    delaySlider:SetPoint("LEFT", delayLabel, "RIGHT", 40, 0)
    delaySlider:SetMinMaxValues(1, 30)
    delaySlider:SetValue(CDTT_Core_Settings.requestDelay or 5)
    delaySlider:SetValueStep(1)
    delaySlider:SetWidth(100)
    _G[delaySlider:GetName() .. "Low"]:SetText("1")
    _G[delaySlider:GetName() .. "High"]:SetText("30")
    _G[delaySlider:GetName() .. "Text"]:SetText(string.format("%d", CDTT_Core_Settings.requestDelay or 5))

    delaySlider:SetScript("OnValueChanged",CDTT.UI.OnRequestDelayChanged)

    -- Category Size Scalers
    local scaleLabel = menu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    scaleLabel:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -75, startY)
    scaleLabel:SetText("Category Size Scale")

    local yPos = -10
    for _, category in ipairs(CDTT.Data.Categories) do
        yPos = CDTT.UI.CreateCategorySliders(menu, category, yPos, scaleLabel)
    end
    

    -- Appearance Button
    local appearanceBtn = CreateFrame("Button", nil, menu, "UIPanelButtonTemplate")
    appearanceBtn:SetSize(buttonWidth-20, buttonHeight)
    appearanceBtn:SetPoint("CENTER", scaleLabel, "CENTER", 0, yPos-25)
    appearanceBtn:SetText("Customize Bar Appearance")
    appearanceBtn:SetScript("OnClick", function()
        CDTT.UI.ShowAppearanceWindow()
    end)

    CDTT.UI.MenuFrame = menu
    return menu   
end





-------------------------------------------------------------------
-- Appearance Customization Window
-------------------------------------------------------------------


function CDTT.UI.ShowAppearanceWindow()
    if not CDTT_Core_Settings.barAppearance then
        CDTT_Core_Settings.barAppearance = {
            texture = "Interface\\TargetingFrame\\UI-StatusBar",
            borderTexture = "Interface\\Buttons\\UI-ActionButton-Border",
            font = "Fonts\\FRIZQT__.TTF",
            fontSize = 10,
            barColorMode = "class",
            customBarColor = {r = 0.5, g = 0.5, b = 0.5},
        }
    end

    if CDTT.UI.AppearanceFrame and CDTT.UI.AppearanceFrame:IsVisible() then
        CDTT.UI.AppearanceFrame:Hide()
        return
    end
    
    if not CDTT.UI.AppearanceFrame then
        local frame = CreateFrame("Frame", "CDTTAppearanceFrame", UIParent)
        frame:SetSize(400, 520) -- Slightly taller to fit preview better
        frame:SetPoint("LEFT", CDTT.UI.MenuFrame, "RIGHT", 10, 0)
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        frame:SetBackdropColor(0, 0, 0, 0.95)
        frame:EnableMouse(true)
        frame:SetMovable(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetClampedToScreen(true)
        
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -15)
        title:SetText("Bar Appearance")
        
        local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", -5, -5)
        closeBtn:SetScript("OnClick", function() frame:Hide() end)
        
        local yOffset = -50
        
        -- Bar Texture
        local textureLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        textureLabel:SetPoint("TOPLEFT", 20, yOffset)
        textureLabel:SetText("Bar Texture:")
        
        local textureBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        textureBtn:SetSize(180, 25)
        textureBtn:SetPoint("LEFT", textureLabel, "RIGHT", 10, 0)
        textureBtn:SetText(CDTT.UI.GetTextureName(CDTT_Core_Settings.barAppearance.texture))
        
        textureBtn:SetScript("OnClick", function(self)
            local textures = {
                {name = "Blizzard", path = "Interface\\TargetingFrame\\UI-StatusBar"},
                {name = "Smooth", path = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar"},
                {name = "Charcoal", path = "Interface\\Buttons\\WHITE8X8"},
                {name = "Otravi", path = "Interface\\AddOns\\CDTT\\Textures\\Otravi"},
                {name = "Minimalist", path = "Interface\\AddOns\\CDTT\\Textures\\Minimalist"},
            }
            
            local menu = CreateFrame("Frame", "CDTTTextureMenu", UIParent, "UIDropDownMenuTemplate")
            local menuList = {}
            for _, tex in ipairs(textures) do
                table.insert(menuList, {
                    text = tex.name,
                    func = function()
                        CDTT_Core_Settings.barAppearance.texture = tex.path
                        self:SetText(tex.name)
                        frame.CreatePreviewBar() -- Update preview immediately
                        if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
                            CDTT.CategoryFrames.UpdateMemberDisplay()
                        end
                    end
                })
            end
            EasyMenu(menuList, menu, "cursor", 0, 0, "MENU")
        end)
        
        yOffset = yOffset - 40

        -- Font & Size
        local fontLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fontLabel:SetPoint("TOPLEFT", 20, yOffset)
        fontLabel:SetText("Font:")
        
        local fontBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        fontBtn:SetSize(180, 25)
        fontBtn:SetPoint("LEFT", fontLabel, "RIGHT", 10, 0)
        fontBtn:SetText(CDTT.UI.GetFontName(CDTT_Core_Settings.barAppearance.font))
        
        fontBtn:SetScript("OnClick", function(self)
            local fonts = {
                {name = "Friz Quadrata", path = "Fonts\\FRIZQT__.TTF"},
                {name = "Arial", path = "Fonts\\ARIALN.TTF"},
                {name = "Skurri", path = "Fonts\\skurri.ttf"},
                {name = "Morpheus", path = "Fonts\\MORPHEUS.TTF"},
            }
            
            local menu = CreateFrame("Frame", "CDTTFontMenu", UIParent, "UIDropDownMenuTemplate")
            local menuList = {}
            for _, font in ipairs(fonts) do
                table.insert(menuList, {
                    text = font.name,
                    func = function()
                        CDTT_Core_Settings.barAppearance.font = font.path
                        self:SetText(font.name)
                        frame.CreatePreviewBar()
                        if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
                            CDTT.CategoryFrames.UpdateMemberDisplay()
                        end
                    end
                })
            end
            EasyMenu(menuList, menu, "cursor", 0, 0, "MENU")
        end)
        
        yOffset = yOffset - 40
        
        local fontSizeSlider = CreateFrame("Slider", "CDTTFontSizeSlider", frame, "OptionsSliderTemplate")
        fontSizeSlider:SetPoint("TOPLEFT", 120, yOffset - 10)
        fontSizeSlider:SetMinMaxValues(6, 20)
        fontSizeSlider:SetValue(CDTT_Core_Settings.barAppearance.fontSize or 10)
        fontSizeSlider:SetValueStep(1)
        fontSizeSlider:SetWidth(150)
        _G[fontSizeSlider:GetName() .. "Text"]:SetText("Font Size: " .. (CDTT_Core_Settings.barAppearance.fontSize or 10))
        
        fontSizeSlider:SetScript("OnValueChanged", function(self, value)
            local val = math.floor(value + 0.5)
            CDTT_Core_Settings.barAppearance.fontSize = val
            _G[self:GetName() .. "Text"]:SetText("Font Size: " .. val)
            frame.CreatePreviewBar()
            if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
                CDTT.CategoryFrames.UpdateMemberDisplay()
            end
        end)
        
        yOffset = yOffset - 60
        
        -- Color Mode
        local classColorRadio = CreateFrame("CheckButton", "CDTTClassColorRadio", frame, "UIRadioButtonTemplate")
        classColorRadio:SetPoint("TOPLEFT", 20, yOffset)
        _G[classColorRadio:GetName() .. "Text"]:SetText("Use Class Colors")
        
        local customColorRadio = CreateFrame("CheckButton", "CDTTCustomColorRadio", frame, "UIRadioButtonTemplate")
        customColorRadio:SetPoint("TOPLEFT", 20, yOffset - 30)
        _G[customColorRadio:GetName() .. "Text"]:SetText("Use Custom Color")

        local customColorBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        customColorBtn:SetSize(80, 22)
        customColorBtn:SetPoint("LEFT", customColorRadio, "RIGHT", 120, 0)
        customColorBtn:SetText("Pick Color")

        classColorRadio:SetScript("OnClick", function(self)
            CDTT_Core_Settings.barAppearance.barColorMode = "class"
            self:SetChecked(true)
            customColorRadio:SetChecked(false)
            customColorBtn:Disable()
            frame.CreatePreviewBar()
            if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then CDTT.CategoryFrames.UpdateMemberDisplay() end
        end)

        customColorRadio:SetScript("OnClick", function(self)
            CDTT_Core_Settings.barAppearance.barColorMode = "custom"
            self:SetChecked(true)
            classColorRadio:SetChecked(false)
            customColorBtn:Enable()
            frame.CreatePreviewBar()
            if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then CDTT.CategoryFrames.UpdateMemberDisplay() end
        end)

        customColorBtn:SetScript("OnClick", function()
            local c = CDTT_Core_Settings.barAppearance.customBarColor
    
            -- Store old colors in case of clicking Cancel
            local oldR, oldG, oldB = c.r, c.g, c.b
            local lastUpdate = 0 -- Timer to prevent crashes

            ColorPickerFrame.func = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                CDTT_Core_Settings.barAppearance.customBarColor = {r = r, g = g, b = b}
        
                -- Always update the small Preview Bar immediately 
                frame.CreatePreviewBar()
        
                -- Throttle the UI update so it doesn't crash the game
                local now = GetTime()
                if (now - lastUpdate) > 0.2 then -- Only update real bars every 0.2 seconds
                    if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then 
                        CDTT.CategoryFrames.UpdateMemberDisplay() 
                    end
                    lastUpdate = now
                end
            end

            ColorPickerFrame.cancelFunc = function()
                CDTT_Core_Settings.barAppearance.customBarColor = {r = oldR, g = oldG, b = oldB}
                frame.CreatePreviewBar()
                if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then 
                    CDTT.CategoryFrames.UpdateMemberDisplay() 
                end
            end

            ColorPickerFrame:SetColorRGB(c.r, c.g, c.b)
            ColorPickerFrame:Show()
        end)

        -- Initialize Radios
        if CDTT_Core_Settings.barAppearance.barColorMode == "class" then
            classColorRadio:SetChecked(true)
            customColorBtn:Disable()
        else
            customColorRadio:SetChecked(true)
        end

        yOffset = yOffset - 80
        
        -- Preview
        local previewLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        previewLabel:SetPoint("TOPLEFT", 20, yOffset)
        previewLabel:SetText("Preview:")
        
        frame.previewContainer = CreateFrame("Frame", nil, frame)
        frame.previewContainer:SetSize(300, 40)
        frame.previewContainer:SetPoint("TOPLEFT", 20, yOffset - 20)

        frame.CreatePreviewBar = function()
            local appearance = CDTT_Core_Settings.barAppearance
            if not frame.pBar then
                frame.pBar = CreateFrame("StatusBar", nil, frame.previewContainer)
                frame.pBar:SetSize(200, 15)
                frame.pBar:SetPoint("LEFT", 25, 0)
                
                frame.pIcon = frame.pBar:CreateTexture(nil, "OVERLAY")
                frame.pIcon:SetSize(15, 15)
                frame.pIcon:SetPoint("RIGHT", frame.pBar, "LEFT", -5, 0)
                frame.pIcon:SetTexture("Interface\\Icons\\Spell_Nature_Lightning")
                
                frame.pBorder = frame.pBar:CreateTexture(nil, "OVERLAY", nil, 7)
                frame.pBorder:SetAllPoints(frame.pIcon)

                frame.pText = frame.pBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                frame.pText:SetPoint("LEFT", 5, 0)
                frame.pText:SetText("Preview Player")
            end

            frame.pBar:SetStatusBarTexture(appearance.texture)
            frame.pBorder:SetTexture(appearance.borderTexture)
            frame.pText:SetFont(appearance.font, appearance.fontSize, "OUTLINE")
            
            local color = (appearance.barColorMode == "class") and {r=1, g=0.5, b=0} or appearance.customBarColor
            frame.pBar:SetStatusBarColor(color.r, color.g, color.b)
            frame.pBar:SetValue(70) -- Static 70% for preview
        end
        
        frame.CreatePreviewBar()
        CDTT.UI.AppearanceFrame = frame
    end
    
    CDTT.UI.AppearanceFrame:Show()
end




-------------------------------------------------------------------
-- Helper Functions for Appearance Names
-------------------------------------------------------------------

function CDTT.UI.GetTextureName(path)
    local textures = {
        ["Interface\\TargetingFrame\\UI-StatusBar"] = "Blizzard",
        ["Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar"] = "Smooth",
        ["Interface\\Buttons\\WHITE8X8"] = "Charcoal",
        ["Interface\\AddOns\\CDTT\\Textures\\Otravi"] = "Otravi",
        ["Interface\\AddOns\\CDTT\\Textures\\Minimalist"] = "Minimalist",
    }
    return textures[path] or "Custom"
end

function CDTT.UI.GetBorderName(path)
    local borders = {
        ["Interface\\Buttons\\UI-ActionButton-Border"] = "Default",
        ["Interface\\AddOns\\CDTT\\Textures\\ThinBorder"] = "Thin",
        [""] = "None",
    }
    return borders[path] or "Custom"
end

function CDTT.UI.GetFontName(path)
    local fonts = {
        ["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata",
        ["Fonts\\ARIALN.TTF"] = "Arial",
        ["Fonts\\skurri.ttf"] = "Skurri",
        ["Fonts\\MORPHEUS.TTF"] = "Morpheus",
    }
    return fonts[path] or "Custom"
end






-------------------------------------------------------------------
-- Function for showing the CooldownTracker Menu
-------------------------------------------------------------------



function CDTT.UI.ShowMenu()

    local menu = CDTT.UI.MenuFrame
    
    -- Update button text based on current state
    if CDTT.UI.isEditMode then
        menu.showTrackerBtn:SetText("Save Position")
    else
        menu.showTrackerBtn:SetText("Show Tracker")
    end
    
    menu:Show()
end




-------------------------------------------------------------------
-- Function that is called from /cd
-------------------------------------------------------------------


function CDTT.UI.ToggleMenu()

    if not CDTT.UI.MenuFrame then
        CDTT.UI.CreateMenu()
    end
    
    if CDTT.UI.MenuFrame:IsVisible() then
        CDTT.UI.MenuFrame:Hide()
    else
        CDTT.UI.ShowMenu()
    end
end