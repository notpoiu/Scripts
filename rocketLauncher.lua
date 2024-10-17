local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()

local debrisService = game:GetService("Debris")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local rocketLauncher = game:GetObjects("rbxassetid://13602301356")[1]
local BoomSound = rocketLauncher:WaitForChild("Boom")
local SwooshSound = rocketLauncher:WaitForChild("Swoosh")

local Rocket = Instance.new("Part") do
    Rocket.Name = "Rocket"
    Rocket.FormFactor = Enum.FormFactor.Custom
    Rocket.Size = Vector3.new(1.2, 1.2, 3.27)
    Rocket.CanCollide = false
    
    local mesh = Instance.new("SpecialMesh", Rocket)
    mesh.MeshId = "rbxassetid://2251534"
    mesh.Scale = Vector3.new(0.35, 0.35, 0.25)
    
    local fire = Instance.new("Fire", Rocket)
    fire.Heat = 5
    fire.Size = 2
    
    local bodyForce = Instance.new("BodyForce", Rocket)
    bodyForce.Force = Vector3.new(0, Rocket:GetMass() * workspace.Gravity, 0)
end

rocketLauncher.Parent = player.Backpack

rocketLauncher.Activated:Connect(function()
    local swooshSoundClone = SwooshSound:Clone()
    swooshSoundClone.Parent = game:GetService("ReplicatedStorage")
    local boomSoundClone = BoomSound:Clone()
    boomSoundClone.Parent = game:GetService("ReplicatedStorage")

    local Pos = mouse.Hit.p

    local rocketClone = Rocket:Clone()
	rocketClone.BrickColor = BrickColor.Gray()
    debrisService:AddItem(rocketClone, 10)

    swooshSoundClone:Play()

    local spawnPosition = (rocketLauncher.Handle.CFrame * CFrame.new(5, 0, 0)).p
    rocketClone.CFrame = CFrame.new(spawnPosition, Pos)
    rocketClone.Velocity = rocketClone.CFrame.lookVector * 60
    rocketClone.Parent = workspace
    
    task.spawn(function()
        repeat task.wait() until not rocketClone:IsDescendantOf(workspace) or rocketClone == nil
        swooshSoundClone.Volume = 0
        swooshSoundClone:Stop()
        swooshSoundClone:Destroy()

        if not boomSoundClone.isPlaying then
            boomSoundClone:Stop()
            boomSoundClone:Destroy()
        end
    end)

    rocketClone.Touched:Connect(function()
        local rocketCloneCFrame = rocketClone.CFrame
        local rocketClonePos = rocketClone.Position

        rocketClone:Destroy()
        task.spawn(function()
            swooshSoundClone.Volume = 0
            swooshSoundClone:Stop()
            swooshSoundClone:Destroy()

            boomSoundClone:Play()
            boomSoundClone.Ended:Wait()

            boomSoundClone.Volume = 0
            boomSoundClone:Stop()
            boomSoundClone:Destroy()
        end)

        local explosion = Instance.new('Explosion')
		explosion.BlastPressure = 0
		explosion.BlastRadius = 8
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Position = rocketClonePos
		explosion.Parent = workspace

        local parts = workspace:GetPartBoundsInBox(rocketCloneCFrame,Vector3.new(10,10,10))
        local forceTable = {}

        for _, part in ipairs(parts) do
			if string.find(part.Name,"Wall") or string.find(part.Name,"Floor") then
				continue
			end

            part.Anchored = false

            local bodyforce = Instance.new("BodyVelocity",part)
            bodyforce.Velocity = (((15 - (part.Position - rocketClonePos).Magnitude) * 100) * (part.Position - rocketClonePos).Unit)

            table.insert(forceTable,bodyforce)
            part.CFrame = part.CFrame * CFrame.new(math.random(1,5),0,math.random(1,5))
		end
        task.wait(0.25)

        for _,force in pairs(forceTable) do
            force:Destroy()
        end
    end)
end)

local function check(room)
    local Assets = room:WaitForChild("Assets",2)
    
    if Assets then
        for _,obj in ipairs(Assets:GetChildren()) do
            if string.match(obj.Name,"Painting") or string.match(obj.Name,"painting") then
                for _,instance in ipairs(obj:GetDescendants()) do
                    if instance:IsA("BasePart") or instance:IsA("Part") or instance:IsA("MeshPart") then
                        instance.CanTouch = true
                    end
                end
            end
        end
    end
end

local addconnect
addconnect = workspace.CurrentRooms.ChildAdded:Connect(function(room)
    check(room)
end)

for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
    check(v)
end

task.spawn(function()
    repeat task.wait() until rocketLauncher == nil or not (rocketLauncher:IsDescendantOf(player.Character) or rocketLauncher:IsDescendantOf(player.Backpack))
    addconnect:Disconnect()
    Rocket:Destroy()
end)
