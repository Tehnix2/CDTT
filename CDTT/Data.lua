CDTT = CDTT or {}
CDTT.Data = CDTT.Data or {}

-------------------------------------------------------------------
-- Default Category definitions (players can customize these ingame)
-------------------------------------------------------------------

-- Default Categories
-- A: Offensive 
-- B: Defensive 
-- C: Healing 
-- D: Mana 
-- E: Utility
-- F: Interrupts & Silence
-- G: Stuns, Disorients, Roots, Freezes, Fears
-- H: Absorbs

CDTT.Data.Categories = {
    { key = "A", name = "A", color = {r = 1.0, g = 0.3, b = 0.3} },
    { key = "B", name = "B", color = {r = 0.3, g = 0.5, b = 1.0} },
    { key = "C", name = "C", color = {r = 0.3, g = 1.0, b = 0.3} },
    { key = "D", name = "D", color = {r = 0.4, g = 0.7, b = 1.0} },
    { key = "E", name = "E", color = {r = 0.9, g = 0.9, b = 0.3} },
    { key = "F", name = "F", color = {r = 1.0, g = 0.6, b = 0.2} },
    { key = "G", name = "G", color = {r = 0.8, g = 0.4, b = 1.0} },
    { key = "H", name = "H", color = {r = 0.3, g = 1.0, b = 1.0} },
}


-------------------------------------------------------------------
-- List of tracked cooldowns with their default values
-- Default cd is only needed for combat log mode, for addon-based 
-- tracking the cooldown is sent and received as addonmessage
-------------------------------------------------------------------

CDTT.Data.TrackedSpells = {
    ["Innervate"]            = { cd = 180, class = "DRUID", icon = "Spell_Nature_Lightning", category = "D" },
    ["Efflorescence"]        = { cd = 60,  class = "DRUID", icon = "inv_misc_herb_talandrasrose", category = "C" },
    ["Rebirth"]              = { cd = 600, class = "DRUID", icon = "spell_nature_reincarnation", category = "E" },
    ["Tranquility"]          = { cd = 480, class = "DRUID", icon = "spell_nature_tranquility", category = "C" },
    ["Barkskin"]             = { cd = 60,  class = "DRUID", icon = "spell_nature_stoneclawtotem", category = "B"},
    ["Survival Instincts"]   = { cd = 180, class = "DRUID", icon = "ability_druid_tigersroar", category = "B"},
    ["Frenzied Regeneration"]= { cd = 180, class = "DRUID", icon = "ability_bullrush", category = "B"},
    ["Flow of Life"]         = { cd = 48,  class = "DRUID", icon = "custom_t_nhance_rpg_icons_tranquilityorb_border", category = "C"}, 
    ["Solar Beam"]           = { cd = 60,  class = "DRUID", icon = "ability_vehicle_sonicshockwave", category = "F"},
    ["Feral Charge"]         = { cd = 15,  class = "DRUID", icon = "ability_hunter_pet_bear" , category = "F"},
    ["Nature's Grasp"]       = { cd = 60,  class = "DRUID", icon = "spell_nature_natureswrath", category = "G"},
    ["Berserk"]              = { cd = 180, class = "DRUID", icon = "ability_druid_berserk", category = "B"},
    ["Bash"]                 = { cd = 60,  class = "DRUID", icon = "ability_druid_bash", category = "G"},
    ["Maim"]                 = { cd = 10,  class = "DRUID", icon = "ability_druid_mangle-tga", category = "G"},
    ["Mass Entanglement"]    = { cd = 35,  class = "DRUID", icon = "spell_druid_massentanglement", category = "G"},
    ["Growl"]                = { cd = 8,   class = "DRUID", icon = "ability_physical_taunt", category = "E"},
    ["Challenging Roar"]     = { cd = 180, class = "DRUID", icon = "ability_druid_challangingroar", category = "E"},

    ["Ice Block"]            = { cd = 300, class = "MAGE", icon = "spell_frost_frost", category = "B" }, 
    ["Mass Invisibility"]    = { cd = 180, class = "MAGE", icon = "ability_mage_massinvisibility", category = "E" },
    ["Counterspell"]         = { cd = 24,  class = "MAGE", icon = "spell_frost_iceshock", category = "F"},
    ["Dragon's Breath"]      = { cd = 20,  class = "MAGE", icon = "inv_misc_head_dragon_01", category = "G"},
    ["Deep Freeze"]          = { cd = 30,  class = "MAGE", icon = "ability_mage_deepfreeze", category = "G"},
    ["Frost Nova"]           = { cd = 20,  class = "MAGE", icon = "spell_frost_frostnova", category = "G"},
    ["Ice Barrier"]          = { cd = 30,  class = "MAGE", icon = "spell_ice_lament", category = "H"},
    ["Fire Ward"]            = { cd = 30,  class = "MAGE", icon = "spell_fire_firearmor", category = "H"},
    ["Frost Ward"]           = { cd = 30,  class = "MAGE", icon = "spell_frost_frostward", category = "H"},

    ["Misdirection"]         = { cd = 30, class = "HUNTER", icon = "ability_hunter_misdirection", category = "E" },
    ["Intimidation"]         = { cd = 60, class = "HUNTER", icon = "ability_devour", category = "G"},
    ["Scare Beast"]          = { cd = 30, class = "HUNTER", icon = "ability_druid_cower", category = "G"},
    ["Silencing Shot"]       = { cd = 20, class = "HUNTER", icon = "ability_theblackarrow", category = "F"},
    ["Chimera Shot"]         = { cd = 60, class = "HUNTER", icon = "ability_hunter_chimerashot2", category = "E"},

    ["Divine Sacrifice"]     = { cd = 120, class = "PALADIN", icon = "Spell_Holy_PowerWordBarrier", category = "B" },
    ["Hand of Salvation"]    = { cd = 60,  class = "PALADIN", icon = "spell_holy_sealofsalvation", category = "E" },
    ["Hand of Protection"]   = { cd = 300, class = "PALADIN", icon = "Spell_Holy_SealOfProtection", category = "B" },
    ["Holy Shield"]          = { cd = 30,  class = "PALADIN", icon = "spell_holy_blessingofprotection", category = "B"},
    ["Aura Mastery"]         = { cd = 120, class = "PALADIN", icon = "spell_holy_auramastery", category = "E"},
    ["Hammer of Justice"]    = { cd = 60,  class = "PALADIN", icon = "spell_holy_sealofmight" , category = "G"},
    ["Holy Wrath"]           = { cd = 30,  class = "PALADIN", icon = "spell_holy_excorcism", category = "G"},
    ["Avenger's Shield"]     = { cd = 30,  class = "PALADIN", icon = "spell_holy_avengersshield", category = "F"},
    ["Repentance"]           = { cd = 60,  class = "PALADIN", icon = "spell_holy_prayerofhealing", category = "G"},
    ["Divine Illumination"]  = { cd = 120, class = "PALADIN", icon = "spell_holy_searinglight", category = "D"},
    ["Divine Favor"]         = { cd = 120, class = "PALADIN", icon = "spell_holy_heal", category = "B"},


    ["Divine Hymn"]          = { cd = 480, class = "PRIEST", icon = "Spell_Holy_DivineHymn", category = "C" },
    ["Hymn of Hope"]         = { cd = 360, class = "PRIEST", icon = "spell_holy_symbolofhope", category = "D" },
    ["Pain Suppression"]     = { cd = 180, class = "PRIEST", icon = "Spell_Holy_PainSupression", category = "B" },
    ["Guardian Spirit"]      = { cd = 180, class = "PRIEST", icon = "spell_holy_guardianspirit", category = "B" },
    ["Halo"]                 = { cd = 45,  class = "PRIEST", icon = "ability_priest_halo", category = "C" },
    ["Power Word: Barrier"]  = { cd = 120, class = "PRIEST", icon = "spell_holy_powerwordbarrier", category = "B" },
    ["Psychic Horror"]       = { cd = 120, class = "PRIEST", icon = "spell_shadow_psychichorrors", category = "E"},
    ["Silence"]              = { cd = 45,  class = "PRIEST", icon = "spell_shadow_impphaseshift", category = "F"},
    ["Psychic Scream"]       = { cd = 30,  class = "PRIEST", icon = "spell_shadow_psychicscream", category = "G"},

    ["Tricks of the Trade"]  = { cd = 30,  class = "ROGUE", icon = "ability_rogue_tricksofthetrade", category = "A" },
    ["Smoke Bomb"]           = { cd = 180, class = "ROGUE", icon = "ability_rogue_smoke", category = "E" },
    ["Dismantle"]            = { cd = 60,  class = "ROGUE", icon = "ability_rogue_dismantle", category = "E"},
    ["Kick"]                 = { cd = 10,  class = "ROGUE", icon = "ability_kick", category = "F"},
    ["Gouge"]                = { cd = 10,  class = "ROGUE", icon = "ability_gouge", category = "G"},
    ["Blind"]                = { cd = 180, class = "ROGUE", icon = "spell_shadow_mindsteal", category = "G"},

    ["Earth Elemental Totem"]= { cd = 600, class = "SHAMAN", icon = "Spell_Nature_EarthElemental_Totem", category = "B" },
    ["Mana Tide Totem"]      = { cd = 180, class = "SHAMAN", icon = "Spell_Frost_SummonWaterElemental", category = "D" },
    ["Bloodlust"]            = { cd = 300, class = "SHAMAN", icon = "spell_nature_bloodlust", category = "A" },
    ["Heroism"]              = { cd = 300, class = "SHAMAN", icon = "ability_shaman_heroism", category = "A"},
    ["Astral Plane"]         = { cd = 120, class = "SHAMAN", icon = "_EnslaveSpell_Astral", category = "B"},
    ["Wind Shear"]           = { cd = 6,   class = "SHAMAN", icon = "spell_nature_cyclone", category = "F"}, 
    ["Stoneclaw Totem"]      = { cd = 30,  class = "SHAMAN", icon = "spell_nature_stoneclawtotem", category = "H"},

    ["Shield Wall"]          = { cd = 300, class = "WARRIOR", icon = "Ability_Warrior_ShieldWall", category = "B" },
    ["Disarm"]               = { cd = 60,  class = "WARRIOR", icon = "Ability_Warrior_Disarm", category = "E" },
    ["Last Stand"]           = { cd = 120, class = "WARRIOR", icon = "spell_holy_ashestoashes", category = "B"},
    ["Shield Block"]         = { cd = 60,  class = "WARRIOR", icon = "ability_defend", category = "B"},
    ["Enraged Regeneration"] = { cd = 120, class = "WARRIOR", icon = "", category = "B"},
    ["Shockwave"]            = { cd = 20,  class = "WARRIOR", icon = "ability_warrior_shockwave", category = "G"},
    ["Shield Bash"]          = { cd = 12,  class = "WARRIOR", icon = "ability_warrior_shieldbash", category = "F"},
    ["Pummel"]               = { cd = 10,  class = "WARRIOR", icon = "inv_gauntlets_04", category = "F"},
    ["Spell Reflection"]     = { cd = 10,  class = "WARRIOR", icon = "ability_warrior_shieldreflection", category = "B"},
    ["Intercept"]            = { cd = 30,  class = "WARRIOR", icon = "ability_rogue_sprint", category = "G"},
    ["Intimidating Shout"]   = { cd = 120, class = "WARRIOR", icon = "ability_golemthunderclap", category = "G"}, 
    ["Bulwark"]              = { cd = 45,  class = "WARRIOR", icon = "ability_warrior_shieldguard", category = "B"},
    ["Storm Bolt"]           = { cd = 40,  class = "WARRIOR", icon = "warrior_talent_icon_stormbolt", category = "G"},
    ["Taunt"]                = { cd = 8,   class = "WARRIOR", icon = "spell_nature_reincarnation", category = "E"},
    ["Mocking Blow"]         = { cd = 60,  class = "WARRIOR", icon = "ability_warrior_punishingblow", category = "E"},
    ["Challenging Shout"]    = { cd = 180, class = "WARRIOR", icon = "ability_bullrush", category = "E"},
}



-------------------------------------------------------------------
-- Mapping of spell IDs to spell names for combat log tracking
-------------------------------------------------------------------

CDTT.Data.SpellIDMap = {
    [1129166] = "Innervate",
    [1186384] = "Efflorescence",
    [1120748] = "Rebirth",
    [1109863] = "Tranquility",
    [1586139] = "Flow of Life",
    [1122812] = "Barkskin",
    [1161336] = "Survival Instincts",
    [1122842] = "Frenzied Regeneration",
    [1145438] = "Ice Block",
    [1398175] = "Mass Invisibility",
    [1134477] = "Misdirection",
    [1164205] = "Divine Sacrifice",
    [1101038] = "Hand of Salvation",
    [1110278] = "Hand of Protection",
    [1120925] = "Holy Shield",
    [1164843] = "Divine Hymn",
    [1164901] = "Hymn of Hope",
    [1133206] = "Pain Suppression",
    [1147788] = "Guardian Spirit",
    [2304897] = "Halo",
    [1180520] = "Power Word: Barrier",
    [1157934] = "Tricks of the Trade",
    [2304501] = "Smoke Bomb",
    [1102062] = "Earth Elemental Totem",
    [1116190] = "Mana Tide Totem",
    [1102825] = "Bloodlust",
    [1132182] = "Heroism",
    [1182049] = "Astral Plane", 
    [1100871] = "Shield Wall",
    [1100676] = "Disarm",
    [1112975] = "Last Stand",
    [1164044] = "Psychic Horror",
    [1151722] = "Dismantle",
    [1131821] = "Aura Mastery",
    [1398202] = "Solar Beam",
    [1149377] = "Feral Charge",
    [1102139] = "Counterspell",
    [1131661] = "Dragon's Breath",
    [1144572] = "Deep Freeze",
    [1100122] = "Frost Nova",
    [1113033] = "Ice Barrier",
    [1110225] = "Fire Ward",
    [1128609] = "Frost Ward",
    [1116689] = "Nature's Grasp",
    [1150334] = "Berserk",
    [1105211] = "Bash",
    [1122570] = "Maim",
    [1398192] = "Mass Entanglement",
    [1119577] = "Intimidation",
    [1114327] = "Scare Beast",
    [1134490] = "Silencing Shot",
    [1153209] = "Chimera Shot",
    [1110308] = "Hammer of Justice",
    [1110318] = "Holy Wrath",
    [1132699] = "Avenger's Shield",
    [1115487] = "Silence",
    [1110890] = "Psychic Scream",
    [1157994] = "Wind Shear", 
    [1110428] = "Stoneclaw Totem",
    [1102565] = "Shield Block",
    [1155694] = "Enraged Regeneration",
    [1146968] = "Shockwave",
    [1100072] = "Shield Bash",
    [1106552] = "Pummel",
    [1123920] = "Spell Reflection",
    [1120252] = "Intercept",
    [1105246] = "Intimidating Shout",
    [1574754] = "Bulwark",
    [1572740] = "Storm Bolt",
    [1120066] = "Repentance",
    [1131842] = "Divine Illumination",
    [1120216] = "Divine Favor",
    [1101766] = "Kick",
    [1101776] = "Gouge",
    [1102094] = "Blind",
    [1100355] = "Taunt",
    [1100694] = "Mocking Blow",
    [1101161] = "Challenging Shout",
    [1106795] = "Growl",
    [1105209] = "Challenging Roar",
}






-------------------------------------------------------------------
-- Add Custom Spell
-------------------------------------------------------------------

function CDTT.Data.AddCustomSpell(spellName, cd, class, icon, category, spellID)
    if not spellName or spellName == "" then
        return false, "Spell name is required"
    end
    
    if CDTT.Data.TrackedSpells[spellName] then
        return false, "Spell already exists"
    end
    
    cd = tonumber(cd) or 60
    class = class or "WARRIOR"
    icon = icon or "INV_Misc_QuestionMark"
    category = category or "E"
    
    CDTT.Data.TrackedSpells[spellName] = {
        cd = cd,
        class = class,
        icon = icon,
        category = category,
        custom = true
    }
    
    if spellID and tonumber(spellID) then
        CDTT.Data.SpellIDMap[tonumber(spellID)] = spellName
    end
    
    CDTT_Core_Settings.customSpells[spellName] = {
        cd = cd,
        class = class,
        icon = icon,
        category = category,
        spellID = spellID
    }
    
    return true, "Spell added successfully"
end

function CDTT.Data.LoadCustomSpells()
    if not CDTT_Core_Settings.customSpells then return end
    
    for spellName, data in pairs(CDTT_Core_Settings.customSpells) do
        CDTT.Data.TrackedSpells[spellName] = {
            cd = data.cd,
            class = data.class,
            icon = data.icon,
            category = data.category,
            custom = true
        }
        
        if data.spellID then
            CDTT.Data.SpellIDMap[tonumber(data.spellID)] = spellName
        end
    end
end