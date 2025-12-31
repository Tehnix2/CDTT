
CDTT.Core = CDTT.Core or {}

CDTT.Core.Version = 0.13
CDTT.Core.addonPrefix = "CDTT"
CDTT.Core.ActiveCooldowns = {}
CDTT.Core.MemberFrame = nil	
CDTT.Core.MemberCooldowns = {}	
CDTT.Core.CombatLogMode = true


-------------------------------------------------------------------
-- Color Constants
-------------------------------------------------------------------

CDTT.Core.ClassColors = {
    DRUID = {r = 1.00, g = 0.49, b = 0.04},
    HUNTER = {r = 0.67, g = 0.83, b = 0.45},
    MAGE = {r = 0.41, g = 0.80, b = 0.94},
    PALADIN = {r = 0.96, g = 0.55, b = 0.73},
    PRIEST = {r = 1.00, g = 1.00, b = 1.00},
    ROGUE = {r = 1.00, g = 0.96, b = 0.41},
    SHAMAN = {r = 0.00, g = 0.44, b = 0.87},
    WARLOCK = {r = 0.58, g = 0.51, b = 0.79},
    WARRIOR = {r = 0.78, g = 0.61, b = 0.43},
    HERO = {r = 1.00, g = 0.84, b = 0.00},
}

-------------------------------------------------------------------
-- Menu Button Layout parameters
-------------------------------------------------------------------

CDTT.Core.buttonWidth = 260
CDTT.Core.buttonHeight = 30
CDTT.Core.startY = -75
CDTT.Core.spacing = 10


-------------------------------------------------------------------
-- Cooldown Bar Layout parameters
-------------------------------------------------------------------

CDTT.Core.cooldownBarWidth = 100
CDTT.Core.cooldownBarHeight = 15
CDTT.Core.cooldownIconSize = 15
CDTT.Core.columnWidth = CDTT.Core.cooldownBarWidth + CDTT.Core.cooldownIconSize + 15
CDTT.Core.columnSpacing = 10



-------------------------------------------------------------------
-- Reload Persistence
-------------------------------------------------------------------

CDTT_Core_Settings = CDTT_Core_Settings or {}

if not CDTT_Core_Settings.trackedSpells then
    CDTT_Core_Settings.trackedSpells = {}
end

if CDTT_Core_Settings.enabled == nil then
    CDTT_Core_Settings.enabled = true
end

if CDTT_Core_Settings.trackAll == nil then
    CDTT_Core_Settings.trackAll = true
end


if not CDTT_Core_Settings.customCategories then
    CDTT_Core_Settings.customCategories = {}
end

if CDTT_Core_Settings.combatLogMode == nil then
    CDTT_Core_Settings.combatLogMode = true
end


if not CDTT_Core_Settings.barAlpha then
    CDTT_Core_Settings.barAlpha = 0.9
end

if not CDTT_Core_Settings.requestDelay then
    CDTT_Core_Settings.requestDelay = 5
end

if not CDTT_Core_Settings.profiles then
    CDTT_Core_Settings.profiles = {}
end

if not CDTT_Core_Settings.currentProfile then
    CDTT_Core_Settings.currentProfile = "Default"
end

if not CDTT_Core_Settings.customSpells then
    CDTT_Core_Settings.customSpells = {}
end

if CDTT_Core_Settings.groupOnlyTracking == nil then
    CDTT_Core_Settings.groupOnlyTracking = false
end


if not CDTT_Core_Settings.categoryFrames then
    CDTT_Core_Settings.categoryFrames = {
        A = { scale = 1, x = 0,    y = -100},
        B = { scale = 1, x = 150,  y = -100},
        C = { scale = 1, x = 300,  y = -100},
        D = { scale = 1, x = 450,  y = -100},
        E = { scale = 1, x = 600,  y = -100},
        F = { scale = 1, x = 750,  y = -100},
        G = { scale = 1, x = 900,  y = -100},
        H = { scale = 1, x = 1050, y = -100},
    }
end

-- Clean up old width/height values for testers who ran an older version
for key, settings in pairs(CDTT_Core_Settings.categoryFrames) do
    settings.width = nil
    settings.height = nil
end

for _, category in ipairs(CDTT.Data.Categories) do
    local key = category.key
    CDTT_Core_Settings.categoryFrames[key] = CDTT_Core_Settings.categoryFrames[key] or {}
    if CDTT_Core_Settings.categoryFrames[key].visible == nil then
        CDTT_Core_Settings.categoryFrames[key].visible = true
    end
end

-- Customization of bar appearance
if not CDTT_Core_Settings.barAppearance then
    CDTT_Core_Settings.barAppearance = {
        texture = "Interface\\TargetingFrame\\UI-StatusBar",
        borderTexture = "Interface\\Buttons\\UI-ActionButton-Border",
        font = "Fonts\\FRIZQT__.TTF",
        fontSize = 10,
        barColorMode = "class",  -- "class" or "custom"
        customBarColor = {r = 0.5, g = 0.5, b = 0.5},
    }
end




CDTT.Core.Settings = CDTT_Core_Settings


-------------------------------------------------------------------
-- Initialize cooldown tracker
-------------------------------------------------------------------


CDTT.Core.SpellCastFrame = nil
CDTT.Core.CombatLogFrame = nil


function CDTT.Core.Init()

    -- Load custom spells if they exist
    if CDTT.Data.LoadCustomSpells then
        CDTT.Data.LoadCustomSpells()
    end

    -- Create or reuse the spell cast frame (for addon message mode)
    if not CDTT.Core.SpellCastFrame then
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("UNIT_SPELLCAST_SENT")
        
        frame:SetScript("OnEvent", function(self, event, unit, spellName)
            if CDTT.Core.CombatLogMode then return end  -- Skip if in combat log mode
            
            if event == "UNIT_SPELLCAST_SENT" and unit == "player" then
                if CDTT.Data.TrackedSpells[spellName] then
                    CDTT.Messager.OnCooldownUsed(spellName)
                end
            end
        end)  
        CDTT.Core.SpellCastFrame = frame
    end

    -- Create or reuse the combat log frame
    if not CDTT.Core.CombatLogFrame then
        local combatLogFrame = CreateFrame("Frame")
         
        combatLogFrame:SetScript("OnEvent", function(self, event, timestamp, subEvent, _, playerName, _, _, _, _, spellID, spellName, _, _, _, _)
       
            -- Only track SPELL_CAST_SUCCESS subEvents for cooldown tracker spells
            if event ~= "COMBAT_LOG_EVENT_UNFILTERED" then return end
            if not CDTT.Core.CombatLogMode then return end
            if subEvent ~= "SPELL_CAST_SUCCESS" then return end                 
            if not playerName or not spellID or not spellName then return end 

            -- Check if this is a tracked cooldown spell
            local trackedSpellName = CDTT.Data.SpellIDMap[spellID]
            if not trackedSpellName then return end 
            
            -- Check if data for this spell exists
            local spellData = CDTT.Data.TrackedSpells[trackedSpellName]
            if not spellData then return end

            -- Filter by group/raid if enabled
            if CDTT_Core_Settings.groupOnlyTracking then
                local isInGroup = false
        
                -- Check if player is in our group/raid
                if UnitName("player") == playerName then
                    isInGroup = true
                elseif IsInRaid() then
                    for i = 1, 40 do
                        if UnitName("raid"..i) == playerName then
                            isInGroup = true
                            break
                        end
                    end
                elseif IsInGroup() then
                    for i = 1, 4 do
                        if UnitName("party"..i) == playerName then
                            isInGroup = true
                            break
                        end
                    end
                end
        
                if not isInGroup then return end
            end


            -- Create table for this player if it does not exist yet
            if not CDTT.Core.MemberCooldowns[playerName] then
                CDTT.Core.MemberCooldowns[playerName] = {}
            end

            -- Fill the table
            local now = GetTime()
            CDTT.Core.MemberCooldowns[playerName][trackedSpellName] = {
                spellName = trackedSpellName,
                usedAt = now,
                expiresAt = now + spellData.cd,
                cooldown = spellData.cd,
                icon = spellData.icon,
            }

            -- Update display
            if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
                CDTT.CategoryFrames.UpdateMemberDisplay()
            end
        end)
        
        CDTT.Core.CombatLogFrame = combatLogFrame
    end

    -- Register or unregister combat log events based on mode
    CDTT.Core.CombatLogMode = CDTT_Core_Settings.combatLogMode
    if CDTT.Core.CombatLogMode then
        CDTT.Core.CombatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        CDTT.Core.CombatLogFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
    
    print("|cff00ff00CDTT|r v" .. CDTT.Core.Version .. " loaded. Type /cd to open the menu.")
end



-------------------------------------------------------------------
-- Slash Commands
-------------------------------------------------------------------

SLASH_CDTT1 = "/cd"
SLASH_CDTTCLEAR1 = "/cdclear"
SLASH_CDTTRESET1 = "/cdreset"

SlashCmdList["CDTT"] = function(message)
    if message == "" then
        CDTT.UI.ToggleMenu()
    end
end

SlashCmdList["CDTTCLEAR"] = function(message)
    wipe(CDTT.Core.MemberCooldowns)
    if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
        CDTT.CategoryFrames.UpdateMemberDisplay()
    end
    print("|cff00ff00CDTT|r All cooldowns cleared.")
end

SlashCmdList["CDTTRESET"] = function(message)
    local now = GetTime()
    for playerName, spells in pairs(CDTT.Core.MemberCooldowns) do
        for spellName, data in pairs(spells) do
            data.expiresAt = now
        end
    end
    if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
        CDTT.CategoryFrames.UpdateMemberDisplay()
    end
    print("|cff00ff00CDTT|r All cooldowns set to READY.")
end


-------------------------------------------------------------------
-- Event Frame for Loading
-------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "CDTT" then
        CDTT.Core.Init()
    end
end)