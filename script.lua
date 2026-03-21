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

-- Smooth Aim Assist (Legit Follow)
RunService.RenderStepped:Connect(function()
    if RightClickHeld then
        local ClosestTarget = nil
        local ClosestDistance = math.huge
        
        local Characters = Modules:Get("chars")
        if Characters then
            for PlayerName, Data in Characters do
                local Player = PlayerService:FindFirstChild(PlayerName)
                if Player and Player ~= LocalPlayer then
                    local Character = Data.bodyModel
                    if Character then
                        local Root = Character:FindFirstChild("root")
                        if Root then
                            local ScreenPos = Camera:WorldToViewportPoint(Root.Position)
                            local Center = Camera.ViewportSize / 2
                            local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                            
                            if Distance < ClosestDistance then
                                ClosestDistance = Distance
                                ClosestTarget = Root.Position
                            end
                        end
                    end
                end
            end
        end
        
        if ClosestTarget then
            local TargetCF = CFrame.new(Camera.CFrame.Position, ClosestTarget)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCF, Smoothness)
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
