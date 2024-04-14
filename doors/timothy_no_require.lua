-- krampus be like:
-- cannot require a non robloxscript module from a robloxscript 🗣️🗣️

local TweenService = game:GetService("TweenService")

local Player = game:GetService("Players").LocalPlayer
local MainUI = Player.PlayerGui:FindFirstChild("MainUI")

local JumpscareSFX = MainUI.Initiator.Main_Game.RemoteListener.Modules.SpiderJumpscare.Scare or Instance.new("Sound", game:GetService("ReplicatedStorage")) do
    JumpscareSFX.Name = "Scare"
    JumpscareSFX.SoundId = "rbxassetid://10337055816"
    JumpscareSFX.Volume = 0.7
end

return function(MainGame, Drawer, Delay)
    local TimothyClone = game.ReplicatedStorage.Entities.Spider:Clone();
    TimothyClone.Parent = MainGame.cam;

    local JumpAnim = TimothyClone.AnimationController:LoadAnimation(TimothyClone.Animations.Jump)
    local StartTick = tick()

    for i = 1, 100 do
        if JumpAnim.Length > 0 then
            break
        end

        task.wait()
    end

    local TimothySpawnPosX = math.ceil(Drawer.Main.Size.X * 10) - 2;
    local TimothySpawnPosZ = math.ceil(Drawer.Main.Size.Z * 10) - 2;

    local SpawnPosOffset = Vector3.new(math.random(-TimothySpawnPosX, TimothySpawnPosX) / 22, 0, math.random(-TimothySpawnPosZ, TimothySpawnPosZ) / 22);

    local RandomRotation = CFrame.Angles(0, math.rad(math.random(0, 360)), 0)
    TimothyClone:SetPrimaryPartCFrame((Drawer.Main.CFrame + SpawnPosOffset) * RandomRotation)

    for i = 1, 1000000 do
        task.wait()
        TimothyClone.PrimaryPart.CFrame = (Drawer.Main.CFrame + SpawnPosOffset) * RandomRotation
        if StartTick + Delay < tick() then
            break
        end
    end

    TimothyClone.PrimaryPart.Sound:Play()
    JumpscareSFX:Play()
    JumpAnim:Play()

    local JumpscareStartTick = tick();
    local JumpscareStartCFrame = TimothyClone.PrimaryPart.CFrame

    MainGame.camShaker:ShakeOnce(5, 6, 0.3, 0.6)

    for i = 1, 1000000 do
        task.wait()
        TimothyClone.PrimaryPart.CFrame = JumpscareStartCFrame:Lerp(CFrame.new(MainGame.cam.CFrame.Position + MainGame.cam.CFrame.LookVector * 0.35, MainGame.cam.CFrame.Position), (TweenService:GetValue((tick() - JumpscareStartTick) / 0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In)));
        
        if JumpscareStartTick + 0.2 < tick() then
            break
        end
    end

    MainGame.camShaker:ShakeOnce(3, 24, 0, 1)

    local JumpscareEndTick = tick()

    for i = 1, 1000000 do
        task.wait()
        TimothyClone.PrimaryPart.CFrame = CFrame.new(MainGame.cam.CFrame.Position + MainGame.cam.CFrame.LookVector * 0.35, MainGame.cam.CFrame.Position);
        
        if JumpscareEndTick + 0.6 < tick() then
            break
        end
    end

    TimothyClone:Destroy()
end
