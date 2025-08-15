--[[

    DOORS Character Fixer
    By upio

]]

local Character = game.Players.LocalPlayer.Character
local RootPart = Character.HumanoidRootPart

local CollisionPart = Instance.new("Part", Character)
do
    CollisionPart.Name = "CollisionPart"
    CollisionPart.Size = Vector3.new(1, 1, 1)
    CollisionPart.Shape = "Ball"
    CollisionPart.CanCollide = false
    CollisionPart.Transparency = 1
    CollisionPart.CFrame = RootPart.CFrame
    
    local RotationWeld = Instance.new("Weld", CollisionPart)
    RotationWeld.Part0 = RootPart
    RotationWeld.Part1 = CollisionPart

    local BodyGyro = Instance.new("BodyGyro", CollisionPart)
end

local Collision = RootPart:Clone()
do
    Collision.Name = "Collision"
    Collision.Parent = Character
    Collision.Size = Vector3.new(5.5, 3, 3)
    Collision.CollisionGroup = "Player"

    local CollisionCrouch = Collision:Clone()
    do
        CollisionCrouch.Parent = Collision
        CollisionCrouch.Size = Vector3.new(3, 3, 3)
        CollisionCrouch.CollisionGroup = "Player"
        CollisionCrouch.Name = "CollisionCrouch"
        
        local CrouchWeld = Instance.new("ManualWeld", CollisionCrouch)
        CollisionWeld.Part0 = CollisionCrouch
        CollisionWeld.Part1 = Collision
    end

    local CollisionWeld = Instance.new("ManualWeld", Collision)
    CollisionWeld.Part0 = Collision
    CollisionWeld.Part1 = CollisionPart
    CollisionWeld.C1 = CFrame.new(-9.15527344e-05, 6.89029694e-05, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
end
