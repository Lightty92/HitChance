-- Rapid Fire
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ToggleEnabled = false
local LastClick = 0
local ClickSpeed = 0.05

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.T then
        ToggleEnabled = not ToggleEnabled
        print("Rapid Fire:", ToggleEnabled and "ON" or "OFF")
    end
end)

RunService.RenderStepped:Connect(function()
    if ToggleEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local now = tick()
        if now - LastClick >= ClickSpeed then
            mouse1click()
            LastClick = now
        end
    end
end)

print("Rapid Fire Loaded! Press T to toggle.")
