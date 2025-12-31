CDTT.CD_Request = CDTT.CD_Request or {}

CDTT.CD_Request.RequestFrame = nil
CDTT.CD_Request.ActiveRequests = {}

-------------------------------------------------------------------
-- Create Overlay on Raid Frame
-------------------------------------------------------------------

local function CreateRaidFrameOverlay(raidFrame, spellName, spellIcon, requester, delay)
    if not raidFrame then 
        print("|cff00ff00CDTT|r raidFrame not found, tell Tehnix which raid frames you use please!")
        return nil 
    end
    
    -- Remove old overlay if exists
    if raidFrame.CDTTSpellRequest then
        raidFrame.CDTTSpellRequest:Hide()
        raidFrame.CDTTSpellRequest = nil
    end
    
   -- Create overlay frame
    local overlay = CreateFrame("Frame", nil, raidFrame)
    overlay:SetAllPoints(raidFrame)
    overlay:SetFrameStrata("HIGH")
    overlay:SetFrameLevel(raidFrame:GetFrameLevel() + 20)

    
    -- Spell icon (large, centered)
    local icon = overlay:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("CENTER", 0, 0)
    icon:SetTexture("Interface\\Icons\\" .. spellIcon)
    
    -- Spell name text (top)
    local spellText = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    spellText:SetPoint("BOTTOM", icon, "TOP", 0, 2)
    spellText:SetText(spellName)
    spellText:SetTextColor(0, 1, 0)
    spellText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    
    -- Timer bar background
    local timerBarBg = overlay:CreateTexture(nil, "BORDER")
    timerBarBg:SetSize(60, 8)
    timerBarBg:SetPoint("TOP", icon, "BOTTOM", 0, -2)
    timerBarBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    timerBarBg:SetVertexColor(0.2, 0.2, 0.2, 0.8)
    
    -- Timer bar fill
    local timerBar = overlay:CreateTexture(nil, "ARTWORK")
    timerBar:SetSize(60, 8)
    timerBar:SetPoint("LEFT", timerBarBg, "LEFT", 0, 0)
    timerBar:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    timerBar:SetVertexColor(1, 0.8, 0, 1)
    
    -- Timer text
    local timerText = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timerText:SetPoint("TOP", timerBarBg, "BOTTOM", 0, -2)
    timerText:SetTextColor(1, 1, 0)
    timerText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")

    -- Store reference to the raid frame so we can track it
    overlay.raidFrame = raidFrame
    overlay.requester = requester

    -- Pulsing animation
    local pulseTime = 0
    overlay:SetScript("OnUpdate", function(self, elapsed)
        pulseTime = pulseTime + elapsed
        
        -- Pulse the glow
        local alpha = 0.3 + (math.sin(pulseTime * 3) * 0.2)
        
        -- Pulse icon border
        local scale = 1 + (math.sin(pulseTime * 4) * 0.1)
        
        -- Update timer
        if delay > 0 then
            local remaining = (self.startTime + delay) - GetTime()
            if remaining > 0 then
                timerText:SetText(string.format("%.1fs", remaining))
                -- Update bar width
                local progress = remaining / delay
                timerBar:SetWidth(60 * progress)
            else
                timerText:SetText("NOW!")
                timerBar:SetWidth(60)
                timerBar:SetVertexColor(0, 1, 0, 1)
            end
        else
            timerText:SetText("NOW!")
            timerBar:SetWidth(60)
        end
    end)
    
    overlay.startTime = GetTime()
    overlay:Show()
    
    -- Store reference on the raid frame
    raidFrame.CDTTSpellRequest = overlay
    
    return overlay
end

-------------------------------------------------------------------
-- Create Alert Text (Top of Screen)
-------------------------------------------------------------------

local function CreateAlertText()
    if CDTT.CD_Request.AlertFrame then
        return CDTT.CD_Request.AlertFrame
    end
    
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(400, 60)
    frame:SetFrameStrata("HIGH")

    -- Load Saved Position or Default
    if CDTT_Core_Settings.alertFramePos then
        local pos = CDTT_Core_Settings.alertFramePos
        frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    else
        frame:SetPoint("TOP", UIParent, "TOP", 0, -150)
    end

    frame:Hide()
    
    -- Make Moveable & Save Position on Stop
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        -- Save to SavedVariables
        CDTT_Core_Settings.alertFramePos = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y
        }
    end)
    frame:SetClampedToScreen(true)

    -- Text
    frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    frame.text:SetPoint("CENTER", 0, 0)
    frame.text:SetTextColor(0, 1, 0)

    -- Dynamic Timer Logic
    frame:SetScript("OnUpdate", function(self, elapsed)
        if self.activeRequest then
            local remaining = self.activeRequest.endTime - GetTime()
            if remaining > 0 then
                -- Countdown Mode
                self.text:SetText(string.format("%s wants %s in %ds", self.activeRequest.requester, self.activeRequest.spell, math.ceil(remaining)))
                self.text:SetTextColor(1, 1, 0) -- Yellow
            else
                -- NOW Mode
                self.text:SetText(string.format("%s wants %s NOW!", self.activeRequest.requester, self.activeRequest.spell))
                self.text:SetTextColor(0, 1, 0) -- Green
            end
        end
    end)
    
    CDTT.CD_Request.AlertFrame = frame
    return frame
end

-------------------------------------------------------------------
-- Handle Spell Request
-------------------------------------------------------------------

function CDTT.CD_Request.OnSpellRequestReceived(requester, spellName, delay)
    delay = delay or 0

    -- Validate spell
    local spellData = CDTT.Data.TrackedSpells[spellName]
    if not spellData then 
        print("|cff00ff00CDTT|r Spell data not found!")
        return 
    end
    
    -- Check class match
    local _, playerClass = UnitClass("player")
    --if spellData.class ~= playerClass then return end
    
    -- Find unit
    local unitID = CDTT.Utils.GetRaidUnitID(requester)
    if not unitID then 
        print("|cff00ff00CDTT|r Could not find unit ID for " .. requester)
        return 
    end
    

    -- Find raid frame and apply overlay
    local raidFrame = CDTT.Utils.FindRaidFrame(unitID)
    if not raidFrame then
        print("|cff00ff00CDTT|r Could not find raid frame for " .. unitID)
    end

    local overlay = nil
    if raidFrame then
        overlay = CreateRaidFrameOverlay(raidFrame, spellName, spellData.icon, requester, delay)
    end
    
    -- Show Alert Text (with data for dynamic timer)
    local alertFrame = CreateAlertText()
    alertFrame.activeRequest = {
        requester = requester,
        spell = spellName,
        endTime = GetTime() + delay
    }
    alertFrame:Show()
    
    -- Auto-hide Alert fallback
    local requestTimestamp = GetTime()
    alertFrame.lastRequestTime = requestTimestamp

    C_Timer.After(delay + 5, function()
        if alertFrame and alertFrame:IsShown() and alertFrame.lastRequestTime == requestTimestamp then
            alertFrame:Hide()
        end
    end)
    
    -- Auto-hide Overlay fallback
    if overlay then
        C_Timer.After(delay + 5, function()
            if overlay then overlay:Hide() end
        end)
    end
    
    -- Store active request for cleanup
    table.insert(CDTT.CD_Request.ActiveRequests, {
        requester = requester,
        spell = spellName,
        unitID = unitID,
        time = GetTime(),
        delay = delay
    })
end

-------------------------------------------------------------------
-- Send Request
-------------------------------------------------------------------

function CDTT.CD_Request.SendSpellRequest(targetPlayer, spellName, delay)
    delay = delay or 0
    local msg = string.format("COOLDOWN_REQUEST:%s:%s:%d", UnitName("player"), spellName, delay)
    SendAddonMessage(CDTT.Core.addonPrefix, msg, "WHISPER", targetPlayer)

    if delay == 0 then 
        SendChatMessage(string.format("%s NOW please!", spellName), "WHISPER", nil, targetPlayer)
    else 
        SendChatMessage(string.format("%s in %d seconds please!", spellName, delay), "WHISPER", nil, targetPlayer)
    end
end

-------------------------------------------------------------------
-- When a requested spell is cast kill the overlay
-------------------------------------------------------------------

function CDTT.CD_Request.FulfillRequest(spellName)
    -- Iterate active requests, if spell matches, find that unit's frame and kill the overlay
    for i = #CDTT.CD_Request.ActiveRequests, 1, -1 do
        local req = CDTT.CD_Request.ActiveRequests[i]
        if req.spell == spellName then
            -- Find frame
            local raidFrame = CDTT.Utils.FindRaidFrame(req.unitID)
            if raidFrame and raidFrame.CDTTSpellRequest then
                raidFrame.CDTTSpellRequest:Hide()
                raidFrame.CDTTSpellRequest = nil
            end
            -- Remove from table
            table.remove(CDTT.CD_Request.ActiveRequests, i)
        end
    end

    -- Remove Alert Frame Text if it matches the cast spell
    local alertFrame = CDTT.CD_Request.AlertFrame
    if alertFrame and alertFrame:IsShown() and alertFrame.activeRequest then
        if alertFrame.activeRequest.spell == spellName then
            alertFrame:Hide()
            alertFrame.activeRequest = nil
        end
    end
end