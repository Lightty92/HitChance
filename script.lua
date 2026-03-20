run_on_thread(getactorthreads()[1], [=[

--// Logger (EXIL HIT CHANCE - Improved)
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local WebhookURL = "https://discord.com/api/webhooks/1484544625447534735/MySiAAmu6AmW0_0-xlZ5clBrnQjxNIvf2Q6_qhLcSwWWLlWfXohp2x6GhlyBMEf-dywp"

-- auto request support (works on more executors)
local req = (syn and syn.request) or request or http_request

local function getTime()
    return os.date("%I:%M %p"):gsub("^0", "")
end

task.spawn(function()
    if WebhookURL and WebhookURL ~= "" and req then
        local gameName = "Unknown"
        pcall(function()
            gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
        end)

        local profileLink = "https://www.roblox.com/users/" .. LocalPlayer.UserId .. "/profile"
        local avatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"

        local data = {
            ["embeds"] = {{
                ["title"] = "EXIL HIT CHANCE",
                ["description"] = "**Used by:** [" .. LocalPlayer.Name .. "](" .. profileLink .. ")",
                ["color"] = 0000,

                ["thumbnail"] = {
                    ["url"] = avatar
                },

                ["fields"] = {
                    {
                        ["name"] = "UserId",
                        ["value"] = tostring(LocalPlayer.UserId),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Game",
                        ["value"] = gameName,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Execution Time",
                        ["value"] = getTime(),
                        ["inline"] = false
                    }
                },

                ["footer"] = {
                    ["text"] = "EXIL LOGGER"
                }
            }}
        }

        local body = HttpService:JSONEncode(data)

        pcall(function()
            req({
                Url = WebhookURL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = body
            })
        end)
    end
end)

-- ORIGINAL SCRIPT BELOW (UNCHANGED)

local function GetService(Name)
    return cloneref(game.GetService(game, Name));
end

local PlayerService = GetService("Players");
local UserInputService = GetService("UserInputService");
local Workspace = GetService("Workspace");

local LocalPlayer = PlayerService.LocalPlayer;
local Camera = Workspace.CurrentCamera;

local Modules = { }; do
    local Required = { };
    local RequestedModules = {
        ["firstPerson"] = {["1"] = "cam", ["2"] = "signals", ["3"] = "nodes", ["4"] = "chars", ["5"] = "collisionCheck", ["6"] = "firstPersonCam", ["7"] = "localChar", ["8"] = "breath", ["9"] = "charConfig", ["10"] = "equipment", ["11"] = "players", ["12"] = "mouse", ["13"] = "networkEvents", ["14"] = "gamepad", ["15"] = "mathLib"},
        ["bullet"] = {["2"] = "charData"},
    };

    function Modules:Require(Name)
        local NilInstances = getnilinstances();
        for Index = 1, #NilInstances do
            local Module = NilInstances[Index];
            if (Module.Name == Name) then
                return require(Module);
            end
        end
    end

    function Modules:Get(Module)
        local RequiredModule = Required[Module];
        if (not RequiredModule) then
            RequiredModule = self:Require(Module);
        end
        return RequiredModule;
    end

    function Modules:Initiate()
        for Module, Data in RequestedModules do
            local Initiator = self:Require(Module);
            if (not Initiator) then continue; end
            Initiator = Initiator.setup;
            for Index, Name in Data do
                Required[Name] = debug.getupvalue(Initiator, Index);
            end
        end
    end
    
    Modules:Initiate();
end

local Signals = Modules:Get("signals");
local firstPersonCam = Modules:Get("firstPersonCam");
local cam = Modules:Get("cam");

-- Fast Scope
if firstPersonCam then
    local oldSetup = firstPersonCam.setup
    firstPersonCam.setup = function(...)
        local result = oldSetup(...)
        firstPersonCam.scopeSpeed = 0.001
        firstPersonCam.zoomSpeed = 0.001
        firstPersonCam.transitionTime = 0.1
        return result
    end
end

-- No Spread
if cam then
    local oldUpdate = cam.update
    cam.update = function(...)
        local args = {...}
        if args[2] then
            args[2].spread = 0
            args[2].recoil = 0
        end
        return oldUpdate(table.unpack(args))
    end
end

-- Bullet Correction (Always Active)
InvokeEvent = hookfunction(Signals.invoke, function(...)
    local Arguments = { ... };
    
    local Origin = Arguments[2]
    local LookVector = Arguments[3]
    
    if Origin and LookVector then
        local Direction = Camera.CFrame.LookVector
        Arguments[3] = Direction
    end
    
    return InvokeEvent(table.unpack(Arguments));
end)

print("=================================")
print("Loaded!")
print("- Fast Scope")
print("- No Spread")
print("- No Recoil")
print("- Bullet Correction (Always)")
print("=================================")

]=])
