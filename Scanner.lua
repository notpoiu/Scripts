local Scanner = game:GetObjects("rbxassetid://12594482248")[1]
Scanner.Parent = game.Players.LocalPlayer.Backpack

local target_fps = _G.scanner_fps or 30
local disable_static = _G.disable_static or false

-- Variables
local Storage = Scanner:WaitForChild("Storage")
local Handle = Scanner:WaitForChild("Handle", 1)
local ScannerViewportFrame = Storage.ScreenUI

local ScannerActivateTickDelay = tick()

local ScannerCamera = Instance.new("Camera")

local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

local LastScannedRoom = -1
local CalculatedFPSWait = (1 / target_fps)

local IsScannerOpened = false
local Equipped = false

-- tables
local ScannerObjectives = {
    "KeyObtain",
    "LeverForGate",
    "LiveBreakerPolePickup",
    "LiveHintBook",
    "FuseObtain",
    "MinesAnchor",
    "WaterPump",
    "TimerLever"
}

local StaticImageUrl = {
    "rbxassetid://8681113666",
    "rbxassetid://8681113503"
}

local LoadedAnimations = {}


-- Animation Functions
local function ScannerStaticStart()
	ScannerViewportFrame.OffScreen.Visible = false

	ScannerViewportFrame.Static1.ImageTransparency = 0
	ScannerViewportFrame.Static2.ImageTransparency = 0

	TweenService:Create(ScannerViewportFrame.Static1, TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		ImageTransparency = 0.9
	}):Play()

	TweenService:Create(ScannerViewportFrame.Static2, TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		ImageTransparency = 1
	}):Play()

	ScannerViewportFrame.ViewSpecial.ImageColor3 = Color3.fromRGB(217, 255, 206)

	TweenService:Create(ScannerViewportFrame.ViewSpecial, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 10, true), {
		ImageColor3 = Color3.fromRGB(53, 93, 52)
	}):Play()

	ScannerCamera.FieldOfView = 1

	TweenService:Create(ScannerCamera, TweenInfo.new(3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
		FieldOfView = 30
	}):Play()

	Scanner.Handle.Use:Play()
	Scanner.Handle.Idle:Play()
end

local function ScannerStaticStop()
	ScannerViewportFrame.OffScreen.Visible = true
	ScannerViewportFrame.OffScreen.Frame.Size = UDim2.new(1, 0, 1, 0)

	TweenService:Create(ScannerViewportFrame.OffScreen.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 0.1, 0)
	}):Play()

	task.delay(0.31, function()
		TweenService:Create(ScannerViewportFrame.OffScreen.Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0), {
			Size = UDim2.new(0, 0, 0.1, 0)
		}):Play()
	end)

	ScannerViewportFrame.OffScreen.BackgroundColor3 = Color3.fromRGB(39, 59, 33)
	TweenService:Create(ScannerViewportFrame.OffScreen, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0), {
		BackgroundColor3 = Color3.fromRGB(3, 6, 2)
	}):Play()

	Scanner.Handle.Disable:Play()
	Scanner.Handle.Idle:Stop()
end

local function ScannerAnimateStatic()
	ScannerViewportFrame.Static1.Position = UDim2.new(0.5, math.random(-28, 28) * 6, 0.5, math.random(-18, 18) * 6)
	ScannerViewportFrame.Static2.Position = UDim2.new(0.5, math.random(-28, 28) * 6, 0.5, math.random(-18, 18) * 6)

	local static_image = StaticImageUrl[math.random(1, #StaticImageUrl)]
	ScannerViewportFrame.Static1.Image = static_image
end

-- Essential Functions

local function SetupScannerView(room)
	local ScannerRoomView = Instance.new("Model", ScannerViewportFrame.ViewNormal)
	ScannerRoomView.Name = room.Name

	local function SetupCloneRoomPart(instance)
		if instance:IsA("BasePart") and instance.Transparency ~= 1 and instance.Size.Magnitude > 0.2 then
			local current_room_part = instance:Clone()

			current_room_part.CanQuery = false
			current_room_part.Parent = ScannerRoomView

			if not instance.Anchored then
				task.spawn(function()
					while task.wait(0.5) do
						if not instance or not instance.Parent then
							break
						end
					
						current_room_part.Position = instance.Position
					end
					
					current_room_part:Destroy()
				end)
			end
		end

		if instance:IsA("Model") and table.find(ScannerObjectives, instance.Name) then
			local StarObjective = Storage.Star:Clone()

			StarObjective.CFrame = instance.PrimaryPart.CFrame or instance:GetPivot()
			StarObjective.Parent = ScannerViewportFrame.ViewSpecial
		end
	end

	-- clone of all visible parts in the room
	for _, v in pairs(room:GetDescendants()) do
		SetupCloneRoomPart(v)
	end

	local connection = room.DescendantAdded:Connect(function(part)
		SetupCloneRoomPart(part)
	end)

	ScannerRoomView.AncestryChanged:Connect(function()
		connection:Disconnect()
	end)
end

local function CleanupScannerView()
    for _, v in pairs(ScannerViewportFrame.ViewNormal:GetChildren()) do
        if v:IsA("Model") then
            v:Destroy()
        end
    end
    
    for _, v in pairs(ScannerViewportFrame.ViewSpecial:GetChildren()) do
        if v:IsA("BasePart") then
            v:Destroy()
        end
    end
end

-- Init Scanner
ScannerCamera.Parent = ScannerViewportFrame
ScannerCamera.FieldOfView = 50

ScannerViewportFrame.ViewNormal.CurrentCamera = ScannerCamera
ScannerViewportFrame.ViewSpecial.CurrentCamera = ScannerCamera

Scanner.Activated:Connect(function()
	if not (ScannerActivateTickDelay <= tick()) then
		return
	end

	if ScannerActivateTickDelay <= tick() then
		ScannerActivateTickDelay = tick() + 0.5

		LoadedAnimations.fire:Play(0.05, 1, 1)

		task.wait(0.2)

		IsScannerOpened = not IsScannerOpened

		if not IsScannerOpened then
			return ScannerStaticStop()
		end
	end

	ScannerStaticStart()
end)

Scanner.Equipped:Connect(function()
	for _, anim in pairs(Scanner:WaitForChild("Animations"):GetChildren()) do
		LoadedAnimations[anim.Name] = player.Character.Humanoid:LoadAnimation(anim)
	end

	LoadedAnimations.equip:Play()
	LoadedAnimations.idle:Play()

	ScannerViewportFrame.Parent = player.PlayerGui
	ScannerViewportFrame.Enabled = true
	ScannerViewportFrame.Adornee = Scanner:WaitForChild("Handle"):WaitForChild("Screen")

	local target_room = player:GetAttribute("CurrentRoom")
	LastScannedRoom = target_room

	local room_instance = workspace.CurrentRooms:FindFirstChild(target_room)
	if room_instance and ScannerViewportFrame.ViewNormal:FindFirstChild(target_room) == nil then
		SetupScannerView(room_instance)
	end

	task.wait(0.2)

	Equipped = true
	IsScannerOpened = true

	ScannerStaticStart()

	while Equipped do
		if IsScannerOpened then
			-- NO WAY ITS MSTDUIO45 😨😨
			local success, errormsg = pcall(function()
				target_room = player:GetAttribute("CurrentRoom")

				if not disable_static then
					ScannerCamera.CFrame = Scanner.Handle.Screen.CFrame * CFrame.Angles(0, 3.15, 0)
					ScannerViewportFrame.ViewNormal.LightDirection = ScannerCamera.CFrame.LookVector - Vector3.new(0, 1, 0)
					
					ScannerAnimateStatic()
				end

				if disable_static and not ScannerViewportFrame.Static1.Visible then
					ScannerViewportFrame.Static1.Visible = false
					ScannerViewportFrame.Static2.Visible = false
				end

				for _, v in pairs(ScannerViewportFrame.ViewSpecial:GetChildren()) do
					if v:IsA("BasePart") then
						v.CFrame = CFrame.new(v.Position, ScannerCamera.CFrame.Position)
					end
				end

				if target_room ~= LastScannedRoom then
					LastScannedRoom = target_room

					ScannerStaticStart()
					CleanupScannerView()

					room_instance = workspace.CurrentRooms:FindFirstChild(target_room)
					if room_instance and ScannerViewportFrame.ViewNormal:FindFirstChild(target_room) == nil then
						SetupScannerView(room_instance)
					end
				end
			end)
			
			if errormsg then
				warn(errormsg)
			end
		end

		if not Equipped then
			break
		end

		task.wait(CalculatedFPSWait)
	end
end)

Scanner.Unequipped:Connect(function()
	ScannerViewportFrame.Parent = script
	ScannerViewportFrame.Enabled = false

	Equipped = false

	-- Disable all sounds
	for _, v in pairs(Handle:GetChildren()) do
		if v:IsA("Sound") then
			v:Stop()
		end
	end

	Scanner.Handle.Disable:Play()

	CleanupScannerView()

	LoadedAnimations.equip:Stop()
	LoadedAnimations.idle:Stop()
end)
