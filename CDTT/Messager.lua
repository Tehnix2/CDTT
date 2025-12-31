CDTT.Messager = CDTT.Messager or {}

-------------------------------------------------------------------
-- Message Handling
-------------------------------------------------------------------

function CDTT.Messager.OnMemberCooldownReceived(msg)
    local cmd, raw = msg:match("^([^:]+):(.*)$")

    if cmd == "COOLDOWN_USED" then 
        local parts = {}
        for p in raw:gmatch("[^:]+") do
            table.insert(parts, p)
        end
    
        if #parts < 4 then return end

        local playerName = parts[1]
        local icon = parts[#parts]
        local cooldown = tonumber(parts[#parts - 1])

        local spellParts = {}
        for i = 2, (#parts - 2) do
            table.insert(spellParts, parts[i])
        end
        local spellName = table.concat(spellParts, ":")

        if not CDTT.Core.MemberCooldowns[playerName] then
            CDTT.Core.MemberCooldowns[playerName] = {}
        end

        local now = GetTime()
        CDTT.Core.MemberCooldowns[playerName][spellName] = {
            spellName = spellName,
            usedAt = now,
            expiresAt = now + cooldown,
            cooldown = cooldown,
            icon = icon,
        }

        if CDTT.CategoryFrames and CDTT.CategoryFrames.UpdateMemberDisplay then
            CDTT.CategoryFrames.UpdateMemberDisplay()
        end
        
    elseif cmd == "COOLDOWN_REQUEST" then
        local requester, rest = raw:match("([^:]+):(.+)")
        if requester and rest then
            local spellName, delayStr = rest:match("([^:]+):(%d+)")
            local delay = tonumber(delayStr) or 0
            if CDTT.CD_Request and CDTT.CD_Request.OnSpellRequestReceived then
                CDTT.CD_Request.OnSpellRequestReceived(requester, spellName, delay)
            end
        end
    end
end

-------------------------------------------------------------------
-- Send Cooldown Message
-------------------------------------------------------------------

function CDTT.Messager.OnCooldownUsed(spellName)
    local spellData = CDTT.Data.TrackedSpells[spellName]
    if not spellData then return end

    -- Remove any active request overlays for this spell
    if CDTT.CD_Request and CDTT.CD_Request.FulfillRequest then
        CDTT.CD_Request.FulfillRequest(spellName)
    end

    C_Timer.After(0.5, function()
        local start, duration, enabled = GetSpellCooldown(spellName)
        
        local actualCooldown = spellData.cd
        if duration and duration > 0 then
            actualCooldown = duration
        end

        local playerName = UnitName("player")
        local msg = string.format(
            "COOLDOWN_USED:%s:%s:%d:%s",  
            playerName,
            spellName,  
            actualCooldown,
            spellData.icon
        )

        SendAddonMessage(CDTT.Core.addonPrefix, msg, "RAID")
    end)
end
