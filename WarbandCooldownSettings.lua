local ADDON_NAME = "WarbandCooldownSettings";

local WCS = {};
_G.WarbandCooldownSettings = WCS;

local frame = CreateFrame("Frame");

local function Print(msg)
    print("|cff33ccff[WCS]|r " .. msg);
end

local function InitDB()
    if (not WarbandCooldownSettingsDB) then
        WarbandCooldownSettingsDB = {};
    end
    local db = WarbandCooldownSettingsDB;
    db.applied = db.applied or {};
    return db;
end

function WCS:GetDB()
    return WarbandCooldownSettingsDB;
end

function WCS:GetTemplate(classID)
    if (not self.templates) then return nil; end
    return self.templates[classID];
end

function WCS:GetStatus(classID)
    local template = self:GetTemplate(classID);
    if (not template) then return "none"; end

    local db = self:GetDB();
    if (not db) then return "available"; end

    local appliedLength = db.applied[classID];
    if (not appliedLength) then return "available"; end

    if (appliedLength == #template) then return "applied"; end

    return "updated";
end

function WCS:Apply()
    if (not C_CooldownViewer or not C_CooldownViewer.SetLayoutData) then
        Print("Cooldown viewer API is not available.");
        return;
    end

    if (not C_CooldownViewer.IsCooldownViewerAvailable()) then
        Print("Cooldown viewer is not available right now.");
        return;
    end

    local classID = select(3, UnitClass("player"));
    local className = GetClassInfo(classID) or ("Class " .. classID);
    local template = self:GetTemplate(classID);

    if (not template) then
        Print("No template available for " .. className .. ".");
        return;
    end

    C_CooldownViewer.SetLayoutData(template);

    local db = self:GetDB();
    if (db) then
        db.applied[classID] = #template;
    end

    Print("Applied template for " .. className .. ". You may need to /reload for changes to take effect.");
end

function WCS:Export()
    if (not C_CooldownViewer or not C_CooldownViewer.GetLayoutData) then
        Print("Cooldown viewer API is not available.");
        return;
    end

    if (not C_CooldownViewer.IsCooldownViewerAvailable()) then
        Print("Cooldown viewer is not available right now.");
        return;
    end

    local data = C_CooldownViewer.GetLayoutData();
    if (not data or data == "") then
        Print("No cooldown layout data found.");
        return;
    end

    local db = self:GetDB();
    if (not db) then return; end

    local classID = select(3, UnitClass("player"));
    local className = GetClassInfo(classID) or ("Class " .. classID);

    db.export = data;

    Print("Exported " .. className .. " layout (" .. #data .. " chars). /reload then grab it from:");
    Print("WTF/Account/<ACCOUNT>/SavedVariables/WarbandCooldownSettings.lua");
    Print("Look for the \"export\" key in WarbandCooldownSettingsDB.");
end

function WCS:Status()
    local classID = select(3, UnitClass("player"));
    local className = GetClassInfo(classID) or ("Class " .. classID);
    local status = self:GetStatus(classID);

    Print("--- Status ---");
    Print("Your class: " .. className .. " (" .. status .. ")");
    Print("--- All Templates ---");

    for id = 1, 13 do
        local name = GetClassInfo(id) or ("Class " .. id);
        local s = self:GetStatus(id);
        Print("  " .. name .. ": " .. s);
    end
end

-- Slash commands
SLASH_WCS1 = "/wcs";
SlashCmdList["WCS"] = function(msg)
    local cmd = strtrim(msg):lower();

    if (cmd == "apply") then
        WCS:Apply();
    elseif (cmd == "export") then
        WCS:Export();
    elseif (cmd == "status") then
        WCS:Status();
    else
        Print("Commands:");
        Print("  /wcs apply — Apply the template for your class");
        Print("  /wcs export — Export your class layout to SavedVariables");
        Print("  /wcs status — Show template status for all classes");
    end
end

-- Event handling
frame:RegisterEvent("ADDON_LOADED");

frame:SetScript("OnEvent", function(self, event, ...)
    if (event == "ADDON_LOADED") then
        local addonName = ...;
        if (addonName == ADDON_NAME) then
            InitDB();
            self:UnregisterEvent("ADDON_LOADED");
        end
    end
end);
