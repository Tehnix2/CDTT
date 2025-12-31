CDTT.SpellConfig = CDTT.SpellConfig or {}


-------------------------------------------------------------------
-- Function to create config check boxes
-------------------------------------------------------------------

function CDTT.SpellConfig.CreateConfigCheckboxes()
    local config = CDTT.SpellConfig.ConfigFrame
    local scrollChild = config.scrollChild
    
    -- Clear existing children
    if config.checkboxes then
        for _, child in ipairs({scrollChild:GetChildren()}) do
            child:Hide()
        end
    end
    config.checkboxes = {}

    local sortedSpells = {}
    for spell, data in pairs(CDTT.Data.TrackedSpells) do
        table.insert(sortedSpells, {name = spell, data = data})
    end
    table.sort(sortedSpells, function(a, b)
        if a.data.class ~= b.data.class then
            return a.data.class < b.data.class
        end
        return a.name < b.name
    end)
    
    local yOffset = -5
    local lastClass = nil
    
    for _, spell in ipairs(sortedSpells) do
        if spell.data.class ~= lastClass then
            local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header:SetPoint("TOPLEFT", 5, yOffset)
            header:SetText(spell.data.class)
            local color = CDTT.Core.ClassColors[spell.data.class] or {r = 1, g = 1, b = 1}
            header:SetTextColor(color.r, color.g, color.b)
            table.insert(config.checkboxes, header)
            yOffset = yOffset - 20
            lastClass = spell.data.class
        end
        
        local checkbox = CreateFrame("CheckButton", nil, scrollChild, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 10, yOffset)
        checkbox:SetSize(20, 20)
        checkbox.spellName = spell.name

        checkbox:SetScript("OnClick", function(self)
            if CDTT_Core_Settings.trackAll then
                CDTT_Core_Settings.trackAll = false
                for spellName, _ in pairs(CDTT.Data.TrackedSpells) do
                    CDTT_Core_Settings.trackedSpells[spellName] = true
                end
            end
    
            if self:GetChecked() then
                CDTT_Core_Settings.trackedSpells[self.spellName] = true
            else
                CDTT_Core_Settings.trackedSpells[self.spellName] = nil
            end

            if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
                CDTT.CategoryFrames.UpdateMemberDisplay()
            end
        end)


        checkbox:SetScript("OnEnter", function(self)
            local spellData = CDTT.Data.TrackedSpells[self.spellName]
            if spellData then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        
                -- 1. Find the Spell ID by searching your SpellIDMap
                local foundID = nil
                for id, name in pairs(CDTT.Data.SpellIDMap) do
                    if name == self.spellName then
                        foundID = id
                        break
                    end
                end

                -- 2. Show the official Game Tooltip
                if foundID then
                    -- SetHyperlink is the most reliable way to show a specific spell in 3.3.5
                    GameTooltip:SetHyperlink("spell:" .. foundID)
                else
                    -- Fallback if ID isn't found in your map
                    GameTooltip:SetSpell(self.spellName)
                end

                -- 3. Add your custom Addon info at the bottom
                GameTooltip:AddLine(" ") -- Spacer
                GameTooltip:AddLine("<CDTT Configuration>", 1, 0.8, 0)
        
                -- Show Class with color
                local color = CDTT.Core.ClassColors[spellData.class] or {r = 1, g = 1, b = 1}
                GameTooltip:AddLine("Class: " .. spellData.class, color.r, color.g, color.b)
        
                GameTooltip:AddLine("Base Cooldown: " .. spellData.cd .. "s", 0.7, 0.7, 0.7)

                local category = CDTT.Utils.GetSpellCategory(self.spellName)
                if category then
                    for _, cat in ipairs(CDTT.Data.Categories) do
                        if cat.key == category then
                            GameTooltip:AddLine("Category: " .. cat.name, cat.color.r, cat.color.g, cat.color.b)
                            break
                        end
                    end
                end

                GameTooltip:Show()
            end
        end)

        checkbox:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)



        
        local label = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        label:SetText(spell.name)

        -- Category Dropdown
        local categoryDropdown = CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
        categoryDropdown:SetSize(80, 20)
        categoryDropdown:SetPoint("LEFT", checkbox, "RIGHT", 200, 0)
        categoryDropdown:SetNormalFontObject("GameFontNormalSmall")
        categoryDropdown.spellName = spell.name

        -- Function to update dropdown text
        local function UpdateDropdownText()
            local currentCategory = CDTT.Utils.GetSpellCategory(spell.name)
            if currentCategory then
                -- Find the category name from the key
                for _, cat in ipairs(CDTT.Data.Categories) do
                    if cat.key == currentCategory then
                        categoryDropdown:SetText(cat.name)
                        return
                    end
                end
            end
        end

        UpdateDropdownText()
        categoryDropdown.UpdateText = UpdateDropdownText
        
        categoryDropdown:SetScript("OnClick", function(self)
            -- Create dropdown menu
            local menu = CreateFrame("Frame", "CategoryDropdownMenu", UIParent, "UIDropDownMenuTemplate")
            local menuList = {}
            
            for _, category in ipairs(CDTT.Data.Categories) do
                table.insert(menuList, {
                    text = category.name,
                    func = function()
                        CDTT_Core_Settings.customCategories[self.spellName] = category.key
                        self:SetText(category.name)
                        
                        if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
                            CDTT.CategoryFrames.UpdateMemberDisplay()
                        end
                    end
                })
            end
            
            EasyMenu(menuList, menu, "cursor", 0, 0, "MENU")
        end)
        
        table.insert(config.checkboxes, checkbox)

        -- Store dropdown reference so we can update it later
        categoryDropdown.checkbox = checkbox
        table.insert(config.checkboxes, categoryDropdown)
        yOffset = yOffset - 25
    end
    
    scrollChild:SetHeight(math.abs(yOffset))
end





-------------------------------------------------------------------
-- Function to update config check boxes
-------------------------------------------------------------------

function CDTT.SpellConfig.UpdateConfigCheckboxes()
    local config = CDTT.SpellConfig.ConfigFrame
    if not config then return end

    CDTT_Core_Settings = CDTT_Core_Settings or {}
    CDTT_Core_Settings.trackedSpells = CDTT_Core_Settings.trackedSpells or {}

    for _, item in ipairs(config.checkboxes) do
        if item.spellName then
            -- Check if this is a checkbox (has SetChecked method)
            if item.SetChecked then
                -- Update checkbox state
                if CDTT_Core_Settings.trackAll then
                    item:SetChecked(true)
                else
                    item:SetChecked(CDTT_Core_Settings.trackedSpells[item.spellName] == true)
                end
            end
            
            -- Update dropdown text if it has the function
            if item.UpdateText then
                item:UpdateText()
            end
        end
    end
end


-------------------------------------------------------------------
-- Function that shows the config menu
-------------------------------------------------------------------


function CDTT.SpellConfig.ShowConfigWindow()
    if CDTT.SpellConfig.ConfigFrame and CDTT.SpellConfig.ConfigFrame:IsVisible() then
        CDTT.SpellConfig.ConfigFrame:Hide()
        return
    end
    
    if not CDTT.SpellConfig.ConfigFrame then
        local config = CreateFrame("Frame", "CDTTCooldownConfigFrame", UIParent)
        config:SetSize(400, 600)
        config:SetPoint("RIGHT", CDTT.UI.MenuFrame, "RIGHT", 175, 0)
        config:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        config:SetBackdropColor(0, 0, 0, 0.95)
        config:EnableMouse(true)
        config:SetMovable(true)
        config:RegisterForDrag("LeftButton")
        config:SetScript("OnDragStart", config.StartMoving)
        config:SetScript("OnDragStop", config.StopMovingOrSizing)
        config:SetClampedToScreen(true)
        
        local title = config:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -15)
        title:SetText("Configure Tracked Cooldowns")
        
        local closeBtn = CreateFrame("Button", nil, config, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", -5, -5)
        closeBtn:SetScript("OnClick", function() config:Hide() end)
        
        -- Profile Management Section
        local profileLabel = config:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        profileLabel:SetPoint("TOPLEFT", 15, -45)
        profileLabel:SetText("Profile:")

        local profileEditBox = CreateFrame("EditBox", "CDTTProfileEditBox", config, "InputBoxTemplate")
        profileEditBox:SetSize(100, 20)
        profileEditBox:SetPoint("LEFT", profileLabel, "RIGHT", 5, 0)
        profileEditBox:SetAutoFocus(false)
        profileEditBox:SetText(CDTT_Core_Settings.currentProfile or "Default")

        -- Dropdown Button for selecting profiles
        local profileDropDownBtn = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
        profileDropDownBtn:SetSize(20, 20)
        profileDropDownBtn:SetPoint("LEFT", profileEditBox, "RIGHT", 2, 0)
        profileDropDownBtn:SetText("v")
        profileDropDownBtn:SetScript("OnClick", function(self)
            local menu = CreateFrame("Frame", "CDTTProfileMenu", UIParent, "UIDropDownMenuTemplate")
            local menuList = {}
            
            -- Ensure profiles exists
            CDTT_Core_Settings.profiles = CDTT_Core_Settings.profiles or {}
            
            -- Add an entry for every saved profile
            for pName, _ in pairs(CDTT_Core_Settings.profiles) do
                table.insert(menuList, {
                    text = pName,
                    func = function() 
                        profileEditBox:SetText(pName)
                    end
                })
            end
            
            if #menuList == 0 then
                table.insert(menuList, { text = "No profiles saved", disabled = true })
            end

            EasyMenu(menuList, menu, "cursor", 0, 0, "MENU")
        end)

        local saveProfileBtn = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
        saveProfileBtn:SetSize(50, 20)
        saveProfileBtn:SetPoint("LEFT", profileDropDownBtn, "RIGHT", 5, 0)
        saveProfileBtn:SetText("Save")
        saveProfileBtn:SetScript("OnClick", function()
            CDTT.SpellConfig.SaveProfile(profileEditBox:GetText())
        end)

        local loadProfileBtn = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
        loadProfileBtn:SetSize(50, 20)
        loadProfileBtn:SetPoint("LEFT", saveProfileBtn, "RIGHT", 5, 0)
        loadProfileBtn:SetText("Load")
        loadProfileBtn:SetScript("OnClick", function()
            CDTT.SpellConfig.LoadProfile(profileEditBox:GetText())
        end)

        local deleteProfileBtn = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
        deleteProfileBtn:SetSize(60, 20)
        deleteProfileBtn:SetPoint("LEFT", loadProfileBtn, "RIGHT", 5, 0)
        deleteProfileBtn:SetText("Delete")
        deleteProfileBtn:SetScript("OnClick", function()
            local profileName = profileEditBox:GetText()
            if profileName == "" then
                print("|cff00ff00CDTT|r Profile name cannot be empty.")
                return
            end
            if profileName == "Default" then
                print("|cff00ff00CDTT|r Cannot delete Default profile.")
                return
            end
    
            -- Confirmation
            StaticPopupDialogs["CDTT_DELETE_PROFILE"] = {
                text = "Delete profile '" .. profileName .. "'?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    CDTT.SpellConfig.DeleteProfile(profileName)
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
            }
            StaticPopup_Show("CDTT_DELETE_PROFILE")
        end)


        
        local selectAllBtn = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
        selectAllBtn:SetSize(80, 22)
        selectAllBtn:SetPoint("TOPLEFT", 15, -70)
        selectAllBtn:SetText("Select All")
        selectAllBtn:SetNormalFontObject("GameFontNormalSmall")

        selectAllBtn:SetScript("OnClick", function()
            CDTT_Core_Settings.trackAll = true
            wipe(CDTT_Core_Settings.trackedSpells)
            print("|cff00ff00CDTT|r Tracking all spells")
            CDTT.SpellConfig.UpdateConfigCheckboxes()
            if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
                CDTT.CategoryFrames.UpdateMemberDisplay()
            end
        end)
        
        local deselectAllBtn = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
        deselectAllBtn:SetSize(90, 22)
        deselectAllBtn:SetPoint("LEFT", selectAllBtn, "RIGHT", 5, 0)
        deselectAllBtn:SetText("Deselect All")
        deselectAllBtn:SetNormalFontObject("GameFontNormalSmall")

        deselectAllBtn:SetScript("OnClick", function()
            CDTT_Core_Settings.trackAll = false
            wipe(CDTT_Core_Settings.trackedSpells)
            print("|cff00ff00CDTT|r Deselected all spells")
            CDTT.SpellConfig.UpdateConfigCheckboxes()
            if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
                CDTT.CategoryFrames.UpdateMemberDisplay()
            end
        end)

        local resetCatsBtn = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
        resetCatsBtn:SetSize(120, 22)
        resetCatsBtn:SetPoint("LEFT", deselectAllBtn, "RIGHT", 5, 0)
        resetCatsBtn:SetText("Reset Categories")
        resetCatsBtn:SetNormalFontObject("GameFontNormalSmall")

        resetCatsBtn:SetScript("OnClick", function()
            -- Reset the table
            CDTT_Core_Settings.customCategories = {}
            print("|cff00ff00CDTT|r Custom categories reset to default.")
            
            -- Re-draw the checkboxes to update the dropdown text
            CDTT.SpellConfig.CreateConfigCheckboxes()
            CDTT.SpellConfig.UpdateConfigCheckboxes()
            
            -- Update main display
            if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
                CDTT.CategoryFrames.UpdateMemberDisplay()
            end
        end)

        --[[
        -- Add Custom Spell Button
        local addSpellBtn = CreateFrame("Button", nil, config, "UIPanelButtonTemplate")
        addSpellBtn:SetSize(120, 22)
        addSpellBtn:SetPoint("LEFT", selectAllBtn, "LEFT", 0, -25)
        addSpellBtn:SetText("Add New Spell")
        addSpellBtn:SetNormalFontObject("GameFontNormalSmall")
        addSpellBtn:SetScript("OnClick", function()
            CDTT.SpellConfig.ShowAddSpellWindow()
        end)
        ]]


        local scrollFrame = CreateFrame("ScrollFrame", nil, config, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 15, -115)
        scrollFrame:SetPoint("BOTTOMRIGHT", -30, 15)
        
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(1, 1)
        scrollFrame:SetScrollChild(scrollChild)
        config.scrollChild = scrollChild
        config.checkboxes = {}
        
        CDTT.SpellConfig.ConfigFrame = config
        CDTT.SpellConfig.CreateConfigCheckboxes()
    end
    
    CDTT.SpellConfig.UpdateConfigCheckboxes()
    CDTT.SpellConfig.ConfigFrame:Show()
end




-------------------------------------------------------------------
-- Profile Management
-------------------------------------------------------------------

function CDTT.SpellConfig.SaveProfile(profileName)
    -- Initialize the profiles table if it doesn't exist
    CDTT_Core_Settings.profiles = CDTT_Core_Settings.profiles or {}

    if not profileName or profileName == "" then
        print("|cff00ff00CDTT|r Profile name cannot be empty.")
        return
    end
    
    CDTT_Core_Settings.profiles[profileName] = {
        trackedSpells = {},
        trackAll = CDTT_Core_Settings.trackAll,
        customCategories = {}
    }
    
    for spell, tracked in pairs(CDTT_Core_Settings.trackedSpells) do
        CDTT_Core_Settings.profiles[profileName].trackedSpells[spell] = tracked
    end
    
    for spell, cat in pairs(CDTT_Core_Settings.customCategories) do
        CDTT_Core_Settings.profiles[profileName].customCategories[spell] = cat
    end
    
    print("|cff00ff00CDTT|r Profile '" .. profileName .. "' saved.")
end

function CDTT.SpellConfig.LoadProfile(profileName)
    local profile = CDTT_Core_Settings.profiles[profileName]
    if not profile then
        print("|cff00ff00CDTT|r Profile '" .. profileName .. "' not found.")
        return
    end
    
    wipe(CDTT_Core_Settings.trackedSpells)
    wipe(CDTT_Core_Settings.customCategories)
    
    CDTT_Core_Settings.trackAll = profile.trackAll
    
    for spell, tracked in pairs(profile.trackedSpells) do
        CDTT_Core_Settings.trackedSpells[spell] = tracked
    end
    
    for spell, cat in pairs(profile.customCategories) do
        CDTT_Core_Settings.customCategories[spell] = cat
    end
    
    CDTT_Core_Settings.currentProfile = profileName
    
    CDTT.SpellConfig.UpdateConfigCheckboxes()
    if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
        CDTT.CategoryFrames.UpdateMemberDisplay()
    end
    
    print("|cff00ff00CDTT|r Profile '" .. profileName .. "' loaded.")
end

function CDTT.SpellConfig.DeleteProfile(profileName)
    if profileName == "Default" then
        print("|cff00ff00CDTT|r Cannot delete Default profile.")
        return
    end
    
    if not CDTT_Core_Settings.profiles[profileName] then
        print("|cff00ff00CDTT|r Profile '" .. profileName .. "' does not exist.")
        return
    end
    
    CDTT_Core_Settings.profiles[profileName] = nil
    print("|cff00ff00CDTT|r Profile '" .. profileName .. "' deleted.")
end



-------------------------------------------------------------------
-- Add Custom Spell Window (TODO)
-------------------------------------------------------------------

function CDTT.SpellConfig.ShowAddSpellWindow()
    if CDTT.SpellConfig.AddSpellFrame then
        CDTT.SpellConfig.AddSpellFrame:Show()
        return
    end
    
    local frame = CreateFrame("Frame", "CDTTAddSpellFrame", UIParent)
    frame:SetSize(300, 350)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
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
    title:SetText("Add Custom Spell")
    
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    
    -- Spell Name
    local nameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", 20, -50)
    nameLabel:SetText("Spell Name:")
    
    local nameBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    nameBox:SetSize(200, 20)
    nameBox:SetPoint("LEFT", nameLabel, "RIGHT", 10, 0)
    nameBox:SetAutoFocus(false)
    
    -- Cooldown
    local cdLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cdLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -20)
    cdLabel:SetText("Cooldown (sec):")
    
    local cdBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    cdBox:SetSize(200, 20)
    cdBox:SetPoint("LEFT", cdLabel, "RIGHT", 10, 0)
    cdBox:SetAutoFocus(false)
    cdBox:SetNumeric(true)
    
    -- Class
    local classLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    classLabel:SetPoint("TOPLEFT", cdLabel, "BOTTOMLEFT", 0, -20)
    classLabel:SetText("Class:")
    
    local classBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    classBox:SetSize(200, 20)
    classBox:SetPoint("LEFT", classLabel, "RIGHT", 10, 0)
    classBox:SetAutoFocus(false)
    
    -- Icon
    local iconLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    iconLabel:SetPoint("TOPLEFT", classLabel, "BOTTOMLEFT", 0, -20)
    iconLabel:SetText("Icon Name:")
    
    local iconBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    iconBox:SetSize(200, 20)
    iconBox:SetPoint("LEFT", iconLabel, "RIGHT", 10, 0)
    iconBox:SetAutoFocus(false)
    
    -- Category
    local categoryLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    categoryLabel:SetPoint("TOPLEFT", iconLabel, "BOTTOMLEFT", 0, -20)
    categoryLabel:SetText("Category:")
    
    local categoryBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    categoryBox:SetSize(200, 20)
    categoryBox:SetPoint("LEFT", categoryLabel, "RIGHT", 10, 0)
    categoryBox:SetAutoFocus(false)
    categoryBox:SetMaxLetters(1)
    
    -- Spell ID (optional)
    local idLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    idLabel:SetPoint("TOPLEFT", categoryLabel, "BOTTOMLEFT", 0, -20)
    idLabel:SetText("Spell ID (optional):")
    
    local idBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    idBox:SetSize(200, 20)
    idBox:SetPoint("LEFT", idLabel, "RIGHT", 10, 0)
    idBox:SetAutoFocus(false)
    idBox:SetNumeric(true)
    
    -- Add Button
    local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    addBtn:SetSize(100, 30)
    addBtn:SetPoint("BOTTOM", 0, 20)
    addBtn:SetText("Add Spell")
    addBtn:SetScript("OnClick", function()
        local success, msg = CDTT.Data.AddCustomSpell(
            nameBox:GetText(),
            tonumber(cdBox:GetText()),
            classBox:GetText(),
            iconBox:GetText(),
            categoryBox:GetText(),
            idBox:GetText()
        )
        
        if success then
            print("|cff00ff00CDTT|r " .. msg)
            CDTT.SpellConfig.CreateConfigCheckboxes()
            CDTT.SpellConfig.UpdateConfigCheckboxes()
            frame:Hide()
        else
            print("|cff00ff00CDTT|r Error: " .. msg)
        end
    end)
    
    CDTT.SpellConfig.AddSpellFrame = frame
    frame:Show()
end





