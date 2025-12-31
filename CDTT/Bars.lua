CDTT.Bars = CDTT.Bars or {}

local cooldownBarWidth = CDTT.Core.cooldownBarWidth
local cooldownBarHeight = CDTT.Core.cooldownBarHeight
local cooldownIconSize = CDTT.Core.cooldownIconSize


-------------------------------------------------------------------
--- Cooldown Bar OnUpdate
-------------------------------------------------------------------

local function CooldownBar_OnUpdate(self)
    local cdData = CDTT.Core.MemberCooldowns[self.playerName]
    if not cdData or not cdData[self.spellName] then return end
    
    local currentAlpha = CDTT_Core_Settings.barAlpha or 0.9
    local remaining = cdData[self.spellName].expiresAt - GetTime()
    local totalCD = cdData[self.spellName].cooldown

    if remaining > 0 then
        self.barBg:SetVertexColor(self.classColor.r, self.classColor.g, self.classColor.b, currentAlpha * 0.5)
        local progress = 1 - (remaining / totalCD)
        self.barFill:SetWidth(math.max(1, self.maxWidth * progress))
        self.barFill:SetVertexColor(self.classColor.r, self.classColor.g, self.classColor.b, currentAlpha)
        
        local mins = math.floor(remaining / 60)
        local secs = math.floor(remaining % 60)
        if mins > 0 then
            self.timerText:SetText(string.format("%d:%02d", mins, secs))
        else
            self.timerText:SetText(string.format("%ds", math.ceil(secs)))
        end
        self.timerText:SetTextColor(1, 1, 1, currentAlpha)
    else
        self.barBg:SetVertexColor(self.classColor.r, self.classColor.g, self.classColor.b, currentAlpha)
        self.barFill:SetWidth(0)
        self.timerText:SetText("R")
        self.timerText:SetTextColor(0, 1, 0)
    end
end






-------------------------------------------------------------------
-- Create Cooldown Bar
-------------------------------------------------------------------

function CDTT.Bars.CreateCooldownBar(parent, playerName, spellName, cdData, yOffset)
    local spellData = CDTT.Data.TrackedSpells[spellName]
    if not spellData then return nil, yOffset end
    
    local scale = CDTT_Core_Settings.frameScale or 1
    local barWidth = cooldownBarWidth * scale
    local barHeight = cooldownBarHeight * scale
    local iconSize = cooldownIconSize * scale

    -- Get appearance settings
    local appearance = CDTT_Core_Settings.barAppearance
    
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetSize(barWidth + iconSize + 5, barHeight)
    bar:SetPoint("TOPLEFT", 5, yOffset+45)
    
    -- Spell icon
    local icon = bar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(iconSize, iconSize)
    icon:SetPoint("LEFT", 0, 0)
    icon:SetTexture("Interface\\Icons\\" .. spellData.icon)
    
    -- Icon border
    local iconBorder = bar:CreateTexture(nil, "OVERLAY")
    iconBorder:SetSize(iconSize, iconSize)
    iconBorder:SetPoint("LEFT", 0, 0)
    --iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    iconBorder:SetTexture(appearance.borderTexture)
    iconBorder:SetBlendMode("ADD")
    iconBorder:SetVertexColor(0.5, 0.5, 0.5, 0.8)
    
    -- Progress bar background with class color
    local barBg = bar:CreateTexture(nil, "BACKGROUND")
    barBg:SetPoint("LEFT", icon, "RIGHT", 3, 0)
    barBg:SetSize(barWidth, barHeight)
    barBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")

    -- Apply class color to background
    local classColor = CDTT.Core.ClassColors[spellData.class] or {r = 0.5, g = 0.5, b = 0.5}
    if appearance.barColorMode == "custom" then
        classColor = appearance.customBarColor
    end
    barBg:SetVertexColor(classColor.r, classColor.g, classColor.b, 0.8)

    -- Progress bar
    local barFill = bar:CreateTexture(nil, "BORDER")
    barFill:SetPoint("LEFT", barBg, "LEFT", 0, 0)
    barFill:SetSize(1, barHeight)
    --barFill:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    barFill:SetTexture(appearance.texture)
    barFill:SetVertexColor(classColor.r, classColor.g, classColor.b, 1.0)

    -- Player name
    local nameText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameText:SetPoint("LEFT", barBg, "LEFT", 3 * scale, 0)
    nameText:SetText(playerName)
    nameText:SetTextColor(1, 1, 1)
    nameText:SetJustifyH("LEFT")
    --nameText:SetFont("Fonts\\FRIZQT__.TTF", 10 * scale, "OUTLINE")
    nameText:SetFont(appearance.font, appearance.fontSize * scale, "OUTLINE")

    -- Timer text
    local timerText = bar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timerText:SetPoint("RIGHT", barBg, "RIGHT", -3 * scale, 0)
    timerText:SetTextColor(1, 1, 1)
    timerText:SetJustifyH("RIGHT")
    --timerText:SetFont("Fonts\\FRIZQT__.TTF", 10 * scale, "OUTLINE")
    timerText:SetFont(appearance.font, appearance.fontSize * scale, "OUTLINE")
    
    bar.icon = icon
    bar.iconBorder = iconBorder
    bar.barBg = barBg
    bar.barFill = barFill
    bar.nameText = nameText
    bar.timerText = timerText
    bar.playerName = playerName
    bar.spellName = spellName
    bar.maxWidth = barWidth
    bar.notifiedReady = false

    -- Store the class color on the bar object
    bar.classColor = classColor

    bar:SetScript("OnUpdate", CooldownBar_OnUpdate)

    bar:EnableMouse(true)
    bar:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            -- Request NOW
            if CDTT.CD_Request and CDTT.CD_Request.SendSpellRequest then
                CDTT.CD_Request.SendSpellRequest(self.playerName, self.spellName, 0)
            end
        elseif button == "RightButton" then
            -- Request in X seconds
            local delay = CDTT_Core_Settings.requestDelay or 5
            if CDTT.CD_Request and CDTT.CD_Request.SendSpellRequest then
                CDTT.CD_Request.SendSpellRequest(self.playerName, self.spellName, delay)
            end
        end
    end)

    bar:SetScript("OnEnter", function(self)
        local delay = CDTT_Core_Settings.requestDelay or 5
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.spellName, 1, 1, 1)
        GameTooltip:AddLine("Left-click: Request NOW", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Right-click: Request in ".. delay .." seconds", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    bar:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Apply alpha to bar elements
    local alpha = CDTT_Core_Settings.barAlpha or 0.9
    barBg:SetAlpha(alpha)
    barFill:SetAlpha(alpha)
    icon:SetAlpha(alpha)
    iconBorder:SetAlpha(alpha)
    nameText:SetAlpha(alpha)
    timerText:SetAlpha(alpha)

    return bar, yOffset - (barHeight + 3)
end