run_on_thread(getactorthreads()[1], [=[
local function GetService(Name)
    return cloneref(game.GetService(game, Name));
end

local PlayerService = GetService("Players");
local UserInputService = GetService("UserInputService");
local Workspace = GetService("Workspace");

local ToggleEnabled = false
local LocalPlayer = PlayerService.LocalPlayer;
local Camera = Workspace.CurrentCamera;

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.T then
        ToggleEnabled = not ToggleEnabled
        print("All Features:", ToggleEnabled and "ON" or "OFF")
    end
end)

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
local breath = Modules:Get("breath");

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

-- No Breath
if breath then
    local oldUpdate = breath.update
    breath.update = function(...)
        return
    end
end

-- Bullet Correction
InvokeEvent = hookfunction(Signals.invoke, function(...)
    local Arguments = { ... };
    
    if not ToggleEnabled then
        return InvokeEvent(table.unpack(Arguments));
    end
    
    local Origin = Arguments[2]
    local LookVector = Arguments[3]
    
    if Origin and LookVector then
        local Direction = Camera.CFrame.LookVector
        Arguments[3] = Direction
    end
    
    return InvokeEvent(table.unpack(Arguments));
end)

print("=================================")
print("ALL FEATURES LOADED!")
print("Press T to toggle")
print("- Fast Scope (0.1s)")
print("- No Spread")
print("- No Recoil")
print("- No Breath")
print("- Bullet Correction")
print("=================================")
]=])
