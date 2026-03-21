run_on_thread(getactorthreads()[1], [=[
local function GetService(Name)
    return cloneref(game.GetService(game, Name));
end

local PlayerService = GetService("Players");
local UserInputService = GetService("UserInputService");
local Workspace = GetService("Workspace");
local RunService = GetService("RunService");

local LocalPlayer = PlayerService.LocalPlayer;
local Camera = Workspace.CurrentCamera;

local RightClickHeld = false
local Smoothness = 0.08
local HitChance = 0.65

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = false
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

if firstPersonCam then
    local oldSetup = firstPersonCam.setup
    firstPersonCam.setup = function(...)
        local result = oldSetup(...)
        firstPersonCam.scopeSpeed = 0
        firstPersonCam.zoomSpeed = 0
        firstPersonCam.transitionTime = 0
        return result
    end
end

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

-- Get Closest Target Parts
local function getTargetParts()
    local targets = {}
    
    local Characters = Modules:Get("chars")
    if Characters then
        for PlayerName, Data in Characters do
            local Player = PlayerService:FindFirstChild(PlayerName)
            if Player and Player ~= LocalPlayer then
                local Character = Data.bodyModel
                if Character then
                    local head = Character:FindFirstChild("head")
                    local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("HumanoidRootPart")
                    
                    if head and torso then
                        local headScreen = Camera:WorldToViewportPoint(head.Position)
                        local torsoScreen = Camera:WorldToViewportPoint(torso.Position)
                        local center = Camera.ViewportSize / 2
                        
                        local headDist = (Vector2.new(headScreen.X, headScreen.Y) - center).Magnitude
                        local torsoDist = (Vector2.new(torsoScreen.X, torsoScreen.Y) - center).Magnitude
                        
                        table.insert(targets, {part = head, distance = headDist})
                        table.insert(targets, {part = torso, distance = torsoDist})
                    end
                end
            end
        end
    end
    
    return targets
end

-- Silent Aim (65% Hit Chance)
RunService.RenderStepped:Connect(function()
    if RightClickHeld then
        if math.random() <= HitChance then
            local targets = getTargetParts()
            local closest = nil
            local closestDist = math.huge
            
            for _, target in ipairs(targets) do
                if target.distance < closestDist then
                    closestDist = target.distance
                    closest = target.part
                end
            end
            
            if closest then
                local TargetCF = CFrame.new(Camera.CFrame.Position, closest.Position)
                Camera.CFrame = Camera.CFrame:Lerp(TargetCF, Smoothness)
            end
        end
    end
end)

InvokeEvent = hookfunction(Signals.invoke, function(...)
    local Arguments = { ... };
    
    if Arguments[2] and Arguments[3] then
        Arguments[3] = Camera.CFrame.LookVector
    end
    
    if Arguments[4] then
        Arguments[4].velocity = 99999
        Arguments[4].cooldown = 0
    end
    
    return InvokeEvent(table.unpack(Arguments));
end)
]=])
