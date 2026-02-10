local WCS = _G.WarbandCooldownSettings;
if (not WCS) then return; end

-- Pre-built cooldown layout templates keyed by classID.
-- The C_CooldownViewer API stores a single blob per class (covers all specs).
-- Paste the raw string from C_CooldownViewer.GetLayoutData() as the value.
WCS.templates = {
    [1]  = nil, -- Warrior
    [2]  = nil, -- Paladin
    [3]  = nil, -- Hunter
    [4]  = nil, -- Rogue
    [5]  = nil, -- Priest
    [6]  = nil, -- Death Knight
    [7]  = nil, -- Shaman
    [8]  = nil, -- Mage
    [9]  = nil, -- Warlock
    [10] = nil, -- Monk
    [11] = nil, -- Druid
    [12] = nil, -- Demon Hunter
    [13] = nil, -- Evoker
};
