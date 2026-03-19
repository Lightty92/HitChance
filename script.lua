-- Settings
local Hotkey = "t"
local HotkeyToggle = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Enabled = false
local RightClickHeld = false
local CurrentlyPressed = false

Mouse.KeyDown:Connect(function(key)
    key = key:lower()

    if key == Hotkey:lower() then
        if HotkeyToggle then
            Enabled = not Enabled
            print("Autotrigger:", Enabled and "ON" or "OFF")
        else
            Enabled = true
        end
    end
end)

Mouse.KeyUp:Connect(function(key)
    key = key:lower()

    if not HotkeyToggle and key == Hotkey:lower() then
        Enabled = false
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightClickHeld = false

        if HoldClick and CurrentlyPressed then
            CurrentlyPressed = false
            mouse1release()
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Enabled and RightClickHeld then
        if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
            if HoldClick then
                if not CurrentlyPressed then
                    CurrentlyPressed = true
                    mouse1press()
                end
            else
                mouse1click()
            end
        else
            if HoldClick and CurrentlyPressed then
                CurrentlyPressed = false
                mouse1release()
            end
        end
    else
        if HoldClick and CurrentlyPressed then
            CurrentlyPressed = false
            mouse1release()
        end
    end
end)