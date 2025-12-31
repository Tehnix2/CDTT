CDTT.CategoryFrames = CDTT.CategoryFrames or {}

-------------------------------------------------------------------
-- Create Main Frame with Column Layout
-------------------------------------------------------------------

function CDTT.CategoryFrames.CreateMainFrame()
    -- Instead of one big frame, create individual frames for each category
    CDTT.CategoryFrames.Frames = {}
    
    for _, category in ipairs(CDTT.Data.Categories) do
        local categoryKey = category.key
        local settings = CDTT_Core_Settings.categoryFrames[categoryKey]
        
        -- Create independent frame for this category
        local frame = CreateFrame("Frame", "CDTTCooldown_"..categoryKey, UIParent)
        frame:SetSize(200,200)
        frame:ClearAllPoints()
        frame:SetScale(settings.scale or 1)
        frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", settings.x or 0, settings.y or -100)
        frame:EnableMouse(false)
        frame:SetMovable(false)
        frame:RegisterForDrag("LeftButton")
        frame:SetClampedToScreen(true)
        frame:Hide()
        
        frame.categoryKey = categoryKey
        frame.category = category
        
        -- Create scrollable content
        local content = CreateFrame("Frame", nil, frame)
        content:SetPoint("TOPLEFT", 10, -25)
        content:SetPoint("BOTTOMRIGHT", -10, 10)
        content:EnableMouseWheel(true)
        content.scrollOffset = 0
        content:SetScript("OnMouseWheel", function(self, delta)
            local maxScroll = math.max(0, self.contentHeight - self:GetHeight())
            self.scrollOffset = math.max(0, math.min(maxScroll, self.scrollOffset - (delta * 20)))
            CDTT.CategoryFrames.UpdateMemberDisplay()
        end)
        
        frame.content = content
        frame.bars = {}
        
        -- Category header
        local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        header:SetPoint("TOP", 0, 10)
        header:SetText(category.name)
        header:SetTextColor(category.color.r, category.color.g, category.color.b)
        frame.header = header
        if not CDTT.UI.isEditMode then header:Hide() end

        -- Close button
        local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        closeBtn:SetSize(18, 18)
        closeBtn:SetPoint("TOPRIGHT", -4, -4)

        closeBtn:SetScript("OnClick", function()
            CDTT_Core_Settings.categoryFrames[categoryKey].visible = false
            frame:Hide()
        end)

        frame.closeBtn = closeBtn
        if not CDTT.UI.isEditMode then closeBtn:Hide() end
 
        
        -- Drag script for moving
        frame:SetScript("OnDragStart", function(self)
            if CDTT.UI.isEditMode then
                self:StartMoving()
            end
        end)
        
        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()

            local scale = self:GetScale() or 1

            -- Get position and convert to unscaled coordinates
            local x = self:GetLeft() * scale
            local y = (self:GetTop() - UIParent:GetTop() / scale) * scale
            
            -- Save these normalized coordinates
            CDTT_Core_Settings.categoryFrames[categoryKey].x = x / scale
            CDTT_Core_Settings.categoryFrames[categoryKey].y = y / scale
        end)
        
        CDTT.CategoryFrames.Frames[categoryKey] = frame
    end
    
    -- Compatibility: use first frame as "MemberFrame" reference
    CDTT.Core.MemberFrame = CDTT.CategoryFrames.Frames["A"]
    
    -- Listener for cooldown broadcasts
    local listener = CreateFrame("Frame")
    listener:RegisterEvent("CHAT_MSG_ADDON")
    listener:SetScript("OnEvent", function(self, event, prefix, msg, channel, sender)
        if prefix ~= CDTT.Core.addonPrefix then return end
        if msg:match("^COOLDOWN_USED:") or msg:match("^COOLDOWN_REQUEST:") then
            if CDTT.Messager and CDTT.Messager.OnMemberCooldownReceived then
                CDTT.Messager.OnMemberCooldownReceived(msg)
            end
        end
    end)
end


-------------------------------------------------------------------
-- Update Display with Column Layout
-------------------------------------------------------------------

function CDTT.CategoryFrames.UpdateMemberDisplay()
    if not CDTT.CategoryFrames.Frames then
        CDTT.CategoryFrames.CreateMainFrame()
    end
    
    -- Clear old bars from all category frames
    for categoryKey, frame in pairs(CDTT.CategoryFrames.Frames) do
        if frame.bars then
            for _, bar in ipairs(frame.bars) do
                bar:Hide()
            end
        end
        frame.bars = {}
    end
    
    -- Organize cooldowns by category
    local cooldownsByCategory = {}
    for _, category in ipairs(CDTT.Data.Categories) do
        cooldownsByCategory[category.key] = {}
    end
    
    for playerName, spells in pairs(CDTT.Core.MemberCooldowns) do
        for spellName, cdData in pairs(spells) do
            if CDTT.Utils.IsSpellTracked(spellName) then
                local category = CDTT.Utils.GetSpellCategory(spellName)
                if category and cooldownsByCategory[category] then
                    table.insert(cooldownsByCategory[category], {
                        playerName = playerName,
                        spellName = spellName,
                        cdData = cdData,
                    })
                end
            end
        end
    end
    
    -- Sort each category
    for category, cooldowns in pairs(cooldownsByCategory) do
        table.sort(cooldowns, function(a, b)
            local aRemaining = a.cdData.expiresAt - GetTime()
            local bRemaining = b.cdData.expiresAt - GetTime()
            local aReady = aRemaining <= 0
            local bReady = bRemaining <= 0
            
            if aReady ~= bReady then return aReady end
            if math.abs(aRemaining - bRemaining) > 0.1 then
                return aRemaining < bRemaining
            end
            return a.playerName < b.playerName
        end)
    end

    for categoryKey, frame in pairs(CDTT.CategoryFrames.Frames) do
        local settings = CDTT_Core_Settings.categoryFrames[categoryKey]

        if not settings or not settings.visible then
            frame:Hide()
        else
            frame:Show()
        end
    end

    
    -- Create bars for each category frame
    for categoryKey, frame in pairs(CDTT.CategoryFrames.Frames) do
        local cooldowns = cooldownsByCategory[categoryKey]
        local yOffset = -30 + frame.content.scrollOffset  -- Start below header
        
        for _, cd in ipairs(cooldowns) do
            if CDTT.Bars and CDTT.Bars.CreateCooldownBar then
                local bar, newY = CDTT.Bars.CreateCooldownBar(frame.content, cd.playerName, cd.spellName, cd.cdData, yOffset)
                if bar then
                    table.insert(frame.bars, bar)
                    local scale = CDTT_Core_Settings.categoryFrames[categoryKey].scale or 1
                    yOffset = newY - (3 * scale)
                end
            end
        end
        
        frame.content.contentHeight = math.abs(yOffset) + 30
    end
end

-------------------------------------------------------------------
-- Toggle Frame
-------------------------------------------------------------------

function CDTT.CategoryFrames.ToggleMemberFrame()
    if not CDTT.Core.MemberFrame then
        CDTT.CategoryFrames.CreateMainFrame()
    end
    
    if CDTT.Core.MemberFrame:IsVisible() then
        CDTT.Core.MemberFrame:Hide()
    else
        CDTT.Core.MemberFrame:Show()
        CDTT.CategoryFrames.UpdateMemberDisplay()
    end
end

-- Export to global CDTT namespace for backward compatibility
CDTT.CategoryFrames = CDTT.CategoryFrames or {}

-- Make the Frames accessible globally for UI module
if not CDTT.CategoryFrames then
    CDTT.CategoryFrames = {}
end


