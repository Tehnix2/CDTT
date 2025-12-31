CDTT.Utils = CDTT.Utils or {}


-------------------------------------------------------------------
-- Function to get the category for a spell (custom or default)
-------------------------------------------------------------------

function CDTT.Utils.GetSpellCategory(spellName)
    local spellData = CDTT.Data.TrackedSpells[spellName]
    if not spellData then return nil end

    if not CDTT_Core_Settings then
        CDTT_Core_Settings = {}
    end

    if not CDTT_Core_Settings.customCategories then
        CDTT_Core_Settings.customCategories = {}
    end
    
    -- Check for custom category first
    if CDTT_Core_Settings.customCategories[spellName] then
        return CDTT_Core_Settings.customCategories[spellName]
    end
    
    -- Return default category
    return spellData.category
end




-------------------------------------------------------------------
-- Check if spell is tracked
-------------------------------------------------------------------

function CDTT.Utils.IsSpellTracked(spellName)
    if CDTT_Core_Settings.trackAll then
        return true
    end
    return CDTT_Core_Settings.trackedSpells[spellName] == true
end





-------------------------------------------------------------------
-- Function to find which Raid ID a player belongs to
-------------------------------------------------------------------


function CDTT.Utils.GetRaidUnitID(playerName)
    -- Check if it's you
    if UnitName("player") == playerName then 
        return "player" 
    end
    
    -- Check if in raid
    if IsInRaid() then
        for i = 1, 40 do
            local unit = "raid"..i
            if UnitName(unit) == playerName then
                return unit
            end
        end
    end
    
    -- Check if in party (dungeon group)
    if IsInGroup() then
        for i = 1, 4 do
            local unit = "party"..i
            if UnitName(unit) == playerName then
                return unit
            end
        end
    end
    
    return nil
end






-------------------------------------------------------------------
-- Find Raid Frame for Unit
-------------------------------------------------------------------

function CDTT.Utils.FindRaidFrame(unitID)
    if not unitID then return nil end
    
    -- Blizzard Compact Raid Frames (Ascension / Backported Style)
    -- We loop through 8 groups, and 5 members per group
    for g = 1, 8 do
        local groupFrame = _G["CompactRaidGroup"..g]
        if groupFrame then
            for m = 1, 5 do
                local frame = _G["CompactRaidGroup"..g.."Member"..m]
                -- Check if frame exists and matches the unitID
                if frame and frame.unit and UnitIsUnit(frame.unit, unitID) then
                    return frame
                end
            end
        end
    end

    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember"..i]
        if frame and frame.unit and UnitIsUnit(frame.unit, unitID) then
            return frame
        end
    end


    
    -- Blizzard Party Frames
    for i = 1, 4 do
        local frame = _G["PartyMemberFrame"..i]
        if frame and frame.unit == unitID then
            return frame
        end
    end
    
    -- Player frame for self-cast
    if unitID == "player" and PlayerFrame then
        return PlayerFrame
    end
    
    -- Grid/Grid2 
    if Grid2 then
        -- Grid2 frames are in Grid2Layout
        for _, frame in pairs(Grid2:GetModule("Grid2Frame").registeredFrames or {}) do
            if frame.unit == unitID then
                return frame
            end
        end
    end
    
    -- VuhDo
    if VuhDoFrame1 then
        for i = 1, 40 do
            local frame = _G["Vd1H"..i]
            if frame and UnitName(frame.unit) == UnitName(unitID) then
                return frame
            end
        end
    end
    
    -- ElvUI 
    if ElvUF then
        for _, frame in pairs(ElvUF.objects or {}) do
            if type(frame) == "table" and frame.unit == unitID then
                return frame
            end
        end
    end
    
    -- Check for ElvUI raid/raid40 frames directly
    if _G.ElvUF_Raid then
        for i = 1, 40 do
            for j = 1, 5 do
                local frame = _G["ElvUF_RaidGroup"..i.."UnitButton"..j]
                if frame and type(frame) == "table" and frame.unit == unitID then
                    return frame
                end
            end
        end
    end
    
    if _G.ElvUF_Raid40 then
        for i = 1, 8 do
            for j = 1, 5 do
                local frame = _G["ElvUF_Raid40Group"..i.."UnitButton"..j]
                if frame and type(frame) == "table" and frame.unit == unitID then
                    return frame
                end
            end
        end
    end

    -- Shadowed Unit Frames (SUF)
    if ShadowUF then
        for _, frame in pairs(ShadowUF.Units.frameList or {}) do
            if type(frame) == "table" and frame.unit == unitID then
                return frame
            end
        end
    end
    
    -- oUF-based addons (includes SUF and others)
    if oUF then
        for _, frame in pairs(oUF.objects or {}) do
            if frame.unit == unitID then
                return frame
            end
        end
    end

    -- X-Perl
    if XPerl_Raid_Grp1Unit1 then
        for i = 1, 9 do -- Groups 1-9
            for j = 1, 5 do -- Units 1-5
                local frameName = "XPerl_Raid_Grp"..i.."Unit"..j
                local frame = _G[frameName]
                if frame and frame:IsVisible() then
                    -- X-Perl usually stores the unit in .partyid or attribute
                    local fUnit = frame.partyid or frame:GetAttribute("unit")
                    if fUnit == unitID then return frame end
                    
                    -- Fallback: check name if unitIDs are messed up
                    if UnitName(fUnit) == UnitName(unitID) then return frame end
                end
            end
        end
    end

    return nil
end




