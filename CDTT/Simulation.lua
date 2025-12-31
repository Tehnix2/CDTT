CDTT.Simulation = CDTT.Simulation or {}

-------------------------------------------------------------------
-- Test Command to Fill Cooldown Tracker with Simulated Cooldowns
-------------------------------------------------------------------

function CDTT.Simulation.SimulateRandomCooldown()
    -- Random player names
    local playerNames = {
        "JoreBear", "MoksTheRat", "Jahjahjah", "Onamia", "Despresso",
        "90gGuy", "Tekknix", "GDKPgirl", "TreahHealGod", "DomoSuicider",
        "Dutch", "Marshy", "MC=dead", "GDKPTnerd", "OoggaDPSMonkey",
        "Nuss", "QTnever100", "SkankyMitchee", "McDoublez", "WorldchatHatesGDKP",
        "PrincessLaura", "KirmithTheFrog", "GDKPT=Ban", "BestICanDo", "YkraMissU",
        "PeeWeeDee", "GigaCheapBro", "Larz2Gorehowl", "ApiBrazil", "FrixMyBINDING",
    }
    
    -- Get all tracked spells
    local allSpells = {}
    for spellName, spellData in pairs(CDTT.Data.TrackedSpells) do
        table.insert(allSpells, spellName)
    end
    
    -- Pick random player and spell
    local playerName = playerNames[math.random(#playerNames)]
    local spellName = allSpells[math.random(#allSpells)]
    local spellData = CDTT.Data.TrackedSpells[spellName]
    
    -- Create the addon message format
    local msg = string.format(
        "COOLDOWN_USED:%s:%s:%d:%s",
        playerName,
        spellName,
        spellData.cd,
        spellData.icon
    )
    
    -- Simulate receiving the message
    if CDTT.Messager and CDTT.Messager.OnMemberCooldownReceived then
        CDTT.Messager.OnMemberCooldownReceived(msg)
    end
    
    return playerName, spellName
end

function CDTT.Simulation.FillWithTestData(numEntries)
    numEntries = numEntries or 50
    
    print("|cff00ff00CDTT|r Simulating " .. numEntries .. " cooldown uses...")
    
    -- Show frame first
    if not CDTT.Core.MemberFrame then
        CDTT.CategoryFrames.CreateMainFrame()
    end
    CDTT.Core.MemberFrame:Show()
    
    -- Simulate cooldowns with small delays to avoid overwhelming the system
    local delay = 0.1
    for i = 1, numEntries do
        C_Timer.After(delay, function()
            local player, spell = CDTT.Simulation.SimulateRandomCooldown()
            
            -- Print progress every 10 entries
            if i % 10 == 0 then
                print("|cff00ff00CDTT|r Progress: " .. i .. "/" .. numEntries)
            end
            
            -- Final message
            if i == numEntries then
                print("|cff00ff00CDTT|r Test data complete! Filled with " .. numEntries .. " cooldowns.")
            end
        end)
        
        -- Small delay between each simulation (0.05 seconds = 50ms)
        delay = delay + 0.05
    end
end