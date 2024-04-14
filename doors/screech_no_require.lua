-- why is krampus like this :(

local Player = game:GetService("Players").LocalPlayer
local MainUI = Player.PlayerGui:FindFirstChild("MainUI")

if not getgenv().ScreechRenderSteppedCounter then
    getgenv().ScreechRenderSteppedCounter = 0
end

local TweenService = game:GetService("TweenService")

local AttackSFX = MainUI.Initiator.Main_Game.RemoteListener.Modules.Screech.Attack or Instance.new("Sound", game:GetService("ReplicatedStorage")) do
    AttackSFX.Name = "Attack"
    AttackSFX.SoundId = "rbxassetid://10494285863"
    AttackSFX.Volume = 1.1
end

local CaughtSFX = MainUI.Initiator.Main_Game.RemoteListener.Modules.Screech.Caught or Instance.new("Sound", game:GetService("ReplicatedStorage")) do
    CaughtSFX.Name = "Caught"
    CaughtSFX.SoundId = "rbxassetid://10494286066"
    CaughtSFX.Volume = 1.1
end

return function(MainGame)
    local ScreechClone = game.ReplicatedStorage.Entities.Screech:Clone()

    local ScreechYPos = math.random(-1, 1) * 2

    if ScreechYPos < 0 then
        ScreechYPos = -1.1
    end

    getgenv().ScreechRenderSteppedCounter = getgenv().ScreechRenderSteppedCounter + 1

    local CurrentID = getgenv().ScreechRenderSteppedCounter

    local ScreechRandomizedPos = (MainGame.finalCamCFrame.LookVector * Vector3.new(-1, 0, -1) + Vector3.new(0, ScreechYPos, 0)).unit
    local CurrentPos = MainGame.finalCamCFrame.p

    ScreechClone:SetPrimaryPartCFrame(CFrame.new(CurrentPos + ScreechRandomizedPos * 4, CurrentPos) * CFrame.new(0, 0.5, 0))
    ScreechClone.Parent = MainGame.cam

    local Animations = {}
    for i, v in pairs(ScreechClone.Animations:GetChildren()) do
        if v:IsA("Animation") then
            Animations[v.Name] = ScreechClone.AnimationController:LoadAnimation(v)
        end
    end

    Animations.Idle:Play()
    task.delay(math.random(1, 10) / 5, function()
        -- psst
        ScreechClone.Root.Sound:Play()
    end)


    local StartTick = tick()
    local ScreechLookatTime = 5 + math.random(1, 10) / 5

    local IsScreechAnimFinished = false

    local StartScreechCFrame = ScreechClone.PrimaryPart.CFrame

    local ScreechLight = ScreechClone.Base.Attachment.PointLight
    local TimeStaredAtScreech = 0
    local IsScreechCaught = false

    game:GetService("RunService"):BindToRenderStep("CustomScreech_" .. CurrentID, 100, function(DeltaTime)
        if not IsScreechAnimFinished then
            ScreechClone.PrimaryPart.CFrame = StartScreechCFrame
        else
            game:GetService("RunService"):UnbindFromRenderStep("CustomScreech_" .. CurrentID)
        end

        if not IsScreechCaught then
            local CameraDistToScreech = (MainGame.finalCamCFrame.LookVector.unit - ScreechRandomizedPos).Magnitude * 100
            ScreechLight.Brightness = math.clamp(50 - CameraDistToScreech, 0, 50) / 50

            if CameraDistToScreech < 35 then
                TimeStaredAtScreech = TimeStaredAtScreech + DeltaTime
            end

            if TimeStaredAtScreech >= 0.1 then
                IsScreechCaught = true
            end
        end
    end)

    MainGame.camShaker:ShakeOnce(0.5, 12, 3, 1)

    for i = 1, 1000000 do
        task.wait()
        local CamPos = MainGame.finalCamCFrame.p
        StartScreechCFrame = CFrame.new(CamPos + ScreechRandomizedPos * 3.5, CamPos) * CFrame.new(0, 0.5, 0)
        
        if StartTick + ScreechLookatTime < tick() then
            break
        end
        
        if IsScreechCaught then
            break
        end
    end

    local CaughtTick = tick()
    local CaughtScreechCFrame = ScreechClone.PrimaryPart.CFrame

    if IsScreechCaught then
        Animations.Caught:Play()
        CaughtSFX:Play()
    else
        Animations.Attack:Play()
        AttackSFX:Play()
    end

    MainGame.camShaker:ShakeOnce(8, 42, 0, 1)

    ScreechClone.Root.Sound:Stop()
    ScreechLight.Brightness = 1

    local ScreechY, ScreechX, ScreechZ = CFrame.new(Vector3.new(0, 0, 0), ScreechRandomizedPos):ToOrientation()

    if math.abs(MainGame.ax - math.deg(ScreechX)) > 180 then
        MainGame.ax_t = MainGame.ax_t - 360
    end

    MainGame.ax_t = math.deg(ScreechX)
    MainGame.ay_t = math.deg(ScreechY)

    game.ReplicatedStorage.RemotesFolder.Screech:FireServer(IsScreechCaught)

    for i = 1, 1000000 do
        task.wait()
        local CurrentCamCFrame = MainGame.finalCamCFrame.p

        StartScreechCFrame = CaughtScreechCFrame:Lerp(CFrame.new(CurrentCamCFrame + ScreechRandomizedPos * 3.5, CurrentCamCFrame) * CFrame.new(0, 0.5, 0), (TweenService:GetValue((tick() - CaughtTick) / 0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In)))
        if CaughtTick + 0.1 < tick() then
            break
        end
    end

    local CurrentTick = tick()
    for i = 1, 1000000 do
        task.wait()
        StartScreechCFrame = CFrame.new(MainGame.finalCamCFrame.Position + MainGame.finalCamCFrame.LookVector * 3, MainGame.finalCamCFrame.Position) * CFrame.new(0, 0.5, 0)
        
        if CurrentTick + 2 < tick() then
            break
        end
    end
    IsScreechAnimFinished = true

    ScreechClone:Destroy()
    game:GetService("RunService"):UnbindFromRenderStep("CustomScreech_" .. CurrentID)
end

