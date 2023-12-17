local character = game.Players.LocalPlayer.Character
local transparencyConnections = {}

-- enable
for i,v in pairs(character:GetChildren()) do
    if v:IsA("Accessory") then
        v.Handle.LocalTransparencyModifier = 0

        transparencyConnections[#transparencyConnections + 1] = v.Handle:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
            v.Handle.LocalTransparencyModifier = 0
        end)
    end

    if v.Name == "Head" then
        v.LocalTransparencyModifier = 0

        transparencyConnections[#transparencyConnections + 1] = v:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
            v.LocalTransparencyModifier = 0
        end)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    game.Workspace.CurrentCamera.CFrame = (game.Players.LocalPlayer.Character.Head.CFrame * CFrame.Angles(math.rad(-10),0,0)) * CFrame.new(0, 1.5, 10)
end)
