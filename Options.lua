local WCS = _G.WarbandCooldownSettings;
if (not WCS) then return; end

local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");

-- Class file names for RAID_CLASS_COLORS lookup
local CLASS_FILES = {
    [1]  = "WARRIOR",
    [2]  = "PALADIN",
    [3]  = "HUNTER",
    [4]  = "ROGUE",
    [5]  = "PRIEST",
    [6]  = "DEATHKNIGHT",
    [7]  = "SHAMAN",
    [8]  = "MAGE",
    [9]  = "WARLOCK",
    [10] = "MONK",
    [11] = "DRUID",
    [12] = "DEMONHUNTER",
    [13] = "EVOKER",
};

local STATUS_LABELS = {
    none      = "|cff808080No template|r",
    available = "|cffffff00Available|r",
    applied   = "|cff00ff00Applied|r",
    updated   = "|cffffff00Updated|r",
};

local function GetClassColoredName(classID)
    local className = GetClassInfo(classID) or ("Class " .. classID);
    local classFile = CLASS_FILES[classID];
    local color = classFile and RAID_CLASS_COLORS[classFile];
    if (color) then
        return color:WrapTextInColorCode(className);
    end
    return className;
end

local args = {
    description = {
        order = 1,
        type = "description",
        name = "Pre-configured Advanced Cooldown Settings templates. Apply a template to set up your cooldown viewer layout.\n\nTemplates are per-class and cover all specs. You can only apply the template for your current class.\n",
        fontSize = "medium",
    },
    templatesHeader = {
        order = 2,
        type = "header",
        name = "Templates",
    },
};

for classID = 1, 13 do
    local baseOrder = 10 + classID;

    args["class" .. classID .. "Desc"] = {
        order = baseOrder,
        type = "description",
        name = function()
            local name = GetClassColoredName(classID);
            local status = WCS:GetStatus(classID);
            return name .. "  —  " .. STATUS_LABELS[status];
        end,
        fontSize = "medium",
        width = "double",
    };

    args["class" .. classID .. "Apply"] = {
        order = baseOrder + 0.01,
        type = "execute",
        name = function()
            local status = WCS:GetStatus(classID);
            if (status == "applied") then return "Applied"; end
            if (status == "updated") then return "Update"; end
            return "Apply";
        end,
        desc = function()
            local className = GetClassInfo(classID) or ("Class " .. classID);
            return "Apply the " .. className .. " template.";
        end,
        width = "half",
        func = function()
            WCS:Apply();
        end,
        disabled = function()
            local playerClassID = select(3, UnitClass("player"));
            if (classID ~= playerClassID) then return true; end
            local status = WCS:GetStatus(classID);
            return status == "none" or status == "applied";
        end,
    };

    args["class" .. classID .. "Spacer"] = {
        order = baseOrder + 0.02,
        type = "description",
        name = "",
        width = "full",
    };
end

local options = {
    type = "group",
    name = "Warband Cooldown Settings",
    args = args,
};

AceConfig:RegisterOptionsTable("WarbandCooldownSettings", options);
AceConfigDialog:AddToBlizOptions("WarbandCooldownSettings", "Warband Cooldown Settings");
