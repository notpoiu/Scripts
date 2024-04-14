-- im too lazy to document allat
local module = {}
local TweenService = game:GetService("TweenService");

local MusicSFX = game:GetService("ReplicatedStorage").ClientModules.EntityModules.Shade.Music or Instance.new("Sound", game:GetService("ReplicatedStorage").ClientModules.EntityModules.Shade) do
	MusicSFX.Name = "Music"
	MusicSFX.SoundId = "rbxassetid://10014083534"
	MusicSFX.Volume = 2
end

local SoundSFX = game:GetService("ReplicatedStorage").ClientModules.EntityModules.Shade.Sound or Instance.new("Sound", game:GetService("ReplicatedStorage").ClientModules.EntityModules.Shade) do
	SoundSFX.Name = "Sound"
	SoundSFX.SoundId = "rbxassetid://9120425687"
	SoundSFX.Volume = 0.6
end

local SoundHurtSFX = game:GetService("ReplicatedStorage").ClientModules.EntityModules.Shade.SoundHurt or Instance.new("Sound", game:GetService("ReplicatedStorage").ClientModules.EntityModules.Shade) do
	SoundHurtSFX.Name = "SoundHurt"
	SoundHurtSFX.SoundId = "rbxassetid://9117059057"
	SoundHurtSFX.Volume = 0.4
end

function module.stuff(MainGame, RoomInstance)
	task.spawn(function()
		if MainGame.dead == true then
			return;
		end

		MainGame.camShaker:ShakeOnce(4, 15, 0.4, 1)
		MainGame.camShaker:ShakeOnce(2, 6, 0.6, 1)
		MainGame.camShaker:ShakeOnce(18, 0.5, 5, 20)
		MainGame.camShaker:ShakeOnce(3, 12, 5, 20)

		MusicSFX:Play()

		TweenService:Create(game:GetService("Lighting"), TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			FogEnd = 0, 
			FogStart = 0, 
			FogColor = Color3.new(0, 0.1, 0.1), 
			Ambient = Color3.new(0, 0.219608, 0.243137)
		}):Play()

		task.wait(1)

		MainGame.hideplayers = 1

		game:GetService("Lighting").Ambience_Shade.Enabled = true

		TweenService:Create(game:GetService("Lighting"), TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			FogEnd = 60, 
			FogStart = 15, 
			FogColor = Color3.new(0, 0, 0)
		}):Play()

		local Player = game.Players.LocalPlayer;
		local Character = Player.Character;
		local l__PrimaryPart__5 = Character.PrimaryPart;
		local RoomStartDirection = RoomInstance.RoomEntrance.CFrame.LookVector;
		local Raycast = Ray.new(RoomInstance.RoomEntrance.Position + Vector3.new(0, 1, 0), RoomStartDirection)

		local JumpscareShadeUI = Player.PlayerGui.MainUI.Jumpscare.Jumpscare_Shade;
		JumpscareShadeUI.Visible = true

		Character:PivotTo(CFrame.new(RoomInstance.RoomEntrance.CFrame.Position + RoomStartDirection * 10, RoomInstance.RoomEntrance.CFrame.Position + RoomStartDirection * 20));
		
		task.wait(0.5)
		
		local ShadeClone = game:GetService("ReplicatedStorage").Entities:WaitForChild("Shade"):Clone()
		ShadeClone.CFrame = MainGame.cam.CFrame + Vector3.new(0, 1000, 0)

		local u3 = RoomStartDirection
		local u4 = tick() + 4

		task.delay(2, function()
			local u5 = nil;
			task.spawn(function()
				if u5 then
					game:GetService("ReplicatedStorage"):FindFirstChild("Bricks"):FindFirstChild("ShadeResult"):FireServer(u5);
				end;
				if u3 == RoomStartDirection then
					u4 = tick() + math.random(30, 70) / 10;
					SoundSFX.Pitch = math.random(100, 130) / 100;
					ShadeClone.WhisperWeird.Pitch = math.random(50, 70) / 100;
				else
					u4 = tick() + math.random(20, 40) / 10;
					SoundSFX.Pitch = math.random(50, 70) / 100;
					ShadeClone.WhisperWeird.Pitch = math.random(100, 120) / 100;
				end;
				SoundSFX.TimePosition = 0.2;
				SoundSFX:Play();
				u3 = -u3;
				local v10 = Raycast:ClosestPoint(Player.Character.PrimaryPart.Position + Vector3.new(0, 2, 0) + u3 * 45);
				if ShadeClone.Parent == MainGame.cam then
					ShadeClone.BodyPosition.Position = ShadeClone.Position + Vector3.new(0, 100, 0);
					task.wait(0.5);
					ShadeClone.CFrame = CFrame.new(v10 + Vector3.new(0, 50, 0));
				else
					ShadeClone.CFrame = CFrame.new(v10 + Vector3.new(0, 50, 0));
				end;
				local v11 = 40 / (u4 - tick());
				ShadeClone.BodyVelocity.Velocity = Vector3.new(0, 0, 0);
				ShadeClone.BodyPosition.Position = v10;
				task.wait(0.5);
				ShadeClone.BodyVelocity.Velocity = u3 * -v11;
			end);
		end);
		ShadeClone.Parent = MainGame.cam;
		for i, v in pairs(ShadeClone:GetChildren()) do
			if v:IsA("Sound") then
				v:Play();
			end;
		end;
		local u6 = false;
		local u7 = nil;
		u7 = Player:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
			u6 = true;
			u7:Disconnect();
		end);
		while true do
			task.wait(0.016666666666666666);
			local l__Magnitude__14 = (ShadeClone.Position - l__PrimaryPart__5.Position).Magnitude;
			local l__Magnitude__15 = (l__PrimaryPart__5.Position - RoomInstance.RoomExit.Position).Magnitude;
			local l__Magnitude__16 = (l__PrimaryPart__5.Position - RoomInstance.RoomExit.Position).Magnitude;
			JumpscareShadeUI.Static.Position = UDim2.new(math.random(0, 1000) / 1000, 0, math.random(0, 1000) / 1000, 0);
			JumpscareShadeUI.Static.Rotation = 180 * math.random(0, 1);
			local RandomStaticImage = "";
			if math.random(1, 2) == 2 then
				RandomStaticImage = "rbxassetid://8681113503";
			else
				RandomStaticImage = "rbxassetid://8681113666";
			end;
			JumpscareShadeUI.Static.Image = RandomStaticImage;
			JumpscareShadeUI.Static.ImageTransparency = 0.6 + l__Magnitude__14 / 80;
			JumpscareShadeUI.Eyes.Visible = false;
			JumpscareShadeUI.Overlay.Visible = false;
			if u6 then
				break;
			end;
			if Character.Humanoid.health < 0.1 then
				break;
			end;
			if l__Magnitude__14 < 30 then
				if math.random(1, 55) == 5 then
					JumpscareShadeUI.Overlay.Position = UDim2.new(math.random(0, 1000) / 1000, 0, math.random(0, 1000) / 1000, 0);
					JumpscareShadeUI.Overlay.Visible = true;
				else
					JumpscareShadeUI.Overlay.Visible = false;
				end;
				if math.random(1, 45) == 5 then
					JumpscareShadeUI.Eyes.Position = UDim2.new(math.random(450, 550) / 1000, 0, math.random(450, 550) / 1000, 0);
					JumpscareShadeUI.Eyes.Visible = true;
				else
					JumpscareShadeUI.Eyes.Visible = false;
				end;
			end;
			if l__Magnitude__14 < 8 then
				ShadeClone.CFrame = ShadeClone.CFrame + Vector3.new(0, 50, 0);
				local u8 = true;
				task.spawn(function()
					if u8 then
						game:GetService("ReplicatedStorage"):FindFirstChild("Bricks"):FindFirstChild("ShadeResult"):FireServer(u8);
					end;
					if u3 == RoomStartDirection then
						u4 = tick() + math.random(30, 70) / 10;
						SoundSFX.Pitch = math.random(100, 130) / 100;
						ShadeClone.WhisperWeird.Pitch = math.random(50, 70) / 100;
					else
						u4 = tick() + math.random(20, 40) / 10;
						SoundSFX.Pitch = math.random(50, 70) / 100;
						ShadeClone.WhisperWeird.Pitch = math.random(100, 120) / 100;
					end;
					SoundSFX.TimePosition = 0.2;
					SoundSFX:Play();
					u3 = -u3;
					local v18 = Raycast:ClosestPoint(Player.Character.PrimaryPart.Position + Vector3.new(0, 2, 0) + u3 * 45);
					if ShadeClone.Parent == MainGame.cam then
						ShadeClone.BodyPosition.Position = ShadeClone.Position + Vector3.new(0, 100, 0);
						task.wait(0.5);
						ShadeClone.CFrame = CFrame.new(v18 + Vector3.new(0, 50, 0));
					else
						ShadeClone.CFrame = CFrame.new(v18 + Vector3.new(0, 50, 0));
					end;
					local v19 = 40 / (u4 - tick());
					ShadeClone.BodyVelocity.Velocity = Vector3.new(0, 0, 0);
					ShadeClone.BodyPosition.Position = v18;
					task.wait(0.5);
					ShadeClone.BodyVelocity.Velocity = u3 * -v19;
				end);
				SoundHurtSFX:Play();
				u8 = 1;
				for i = 1, 15 do
					task.wait(0.05);
					JumpscareShadeUI.Overlay.Position = UDim2.new(math.random(0, 1000) / 1000, 0, math.random(0, 1000) / 1000, 0);
					JumpscareShadeUI.Overlay.Visible = true;
					JumpscareShadeUI.Static.Position = UDim2.new(math.random(0, 1000) / 1000, 0, math.random(0, 1000) / 1000, 0);
					JumpscareShadeUI.Static.Rotation = 180 * math.random(0, 1);
					
					local SelectedStaticImage = "";
					
					if math.random(1, 2) == 2 then
						SelectedStaticImage = "rbxassetid://8681113503";
					else
						SelectedStaticImage = "rbxassetid://8681113666";
					end

					JumpscareShadeUI.Static.Image = SelectedStaticImage;
					JumpscareShadeUI.Static.ImageTransparency = math.random(1, 5) / 10;
					JumpscareShadeUI.Eyes.Visible = true;
					if math.random(1, 2) == 2 then
						JumpscareShadeUI.Eyes.Position = UDim2.new(math.random(450, 550) / 1000, 0, math.random(450, 550) / 1000, 0);
					end;
				end;
				JumpscareShadeUI.Eyes.Visible = false;
				JumpscareShadeUI.Overlay.Visible = false;
			elseif u4 <= tick() then
				local u9 = false;
				task.spawn(function()
					if u9 then
						game:GetService("ReplicatedStorage"):FindFirstChild("Bricks"):FindFirstChild("ShadeResult"):FireServer(u9);
					end;
					if u3 == RoomStartDirection then
						u4 = tick() + math.random(30, 70) / 10;
						SoundSFX.Pitch = math.random(100, 130) / 100;
						ShadeClone.WhisperWeird.Pitch = math.random(50, 70) / 100;
					else
						u4 = tick() + math.random(20, 40) / 10;
						SoundSFX.Pitch = math.random(50, 70) / 100;
						ShadeClone.WhisperWeird.Pitch = math.random(100, 120) / 100;
					end;
					SoundSFX.TimePosition = 0.2;
					SoundSFX:Play();
					u3 = -u3;
					local v21 = Raycast:ClosestPoint(Player.Character.PrimaryPart.Position + Vector3.new(0, 2, 0) + u3 * 45);
					if ShadeClone.Parent == MainGame.cam then
						ShadeClone.BodyPosition.Position = ShadeClone.Position + Vector3.new(0, 100, 0);
						wait(0.5);
						ShadeClone.CFrame = CFrame.new(v21 + Vector3.new(0, 50, 0));
					else
						ShadeClone.CFrame = CFrame.new(v21 + Vector3.new(0, 50, 0));
					end;
					local v22 = 40 / (u4 - tick());
					ShadeClone.BodyVelocity.Velocity = Vector3.new(0, 0, 0);
					ShadeClone.BodyPosition.Position = v21;
					task.wait(0.5);
					ShadeClone.BodyVelocity.Velocity = u3 * -v22;
				end)
				u9 = 1
				for i = 1, 4 do
					task.wait(0.05);
					JumpscareShadeUI.OverlayTurn.Position = UDim2.new(math.random(0, 1000) / 1000, 0, math.random(0, 1000) / 1000, 0);
					JumpscareShadeUI.OverlayTurn.Visible = true;
					JumpscareShadeUI.Static.Position = UDim2.new(math.random(0, 1000) / 1000, 0, math.random(0, 1000) / 1000, 0);
					JumpscareShadeUI.Static.Rotation = 180 * math.random(0, 1);
					
					local RandomStaticImg = ""

					if math.random(1, 2) == 2 then
						RandomStaticImg = "rbxassetid://8681113503"
					else
						RandomStaticImg = "rbxassetid://8681113666"
					end
					
					JumpscareShadeUI.Static.Image = RandomStaticImg;
					JumpscareShadeUI.Static.ImageTransparency = 0.4;
					if math.random(1, 4) == 2 then
						JumpscareShadeUI.Eyes.Position = UDim2.new(math.random(450, 550) / 1000, 0, math.random(450, 550) / 1000, 0);
						JumpscareShadeUI.Eyes.Visible = true;
					else
						JumpscareShadeUI.Eyes.Visible = false;
					end;
				end;
				JumpscareShadeUI.Eyes.Visible = false;
				JumpscareShadeUI.Overlay.Visible = false;
				JumpscareShadeUI.OverlayTurn.Visible = false;
			end;		
		end;
		MainGame.hideplayers = 0;
		MusicSFX:Stop();
		SoundSFX.Pitch = math.random(150, 170) / 100
		SoundSFX.TimePosition = 0.2
		SoundSFX:Play()

		for i = 1, 2 do
			task.wait(0.05)
			JumpscareShadeUI.Overlay.Position = UDim2.new(math.random(0, 1000) / 1000, 0, math.random(0, 1000) / 1000, 0);
			JumpscareShadeUI.Overlay.Visible = true;
			JumpscareShadeUI.Static.Position = UDim2.new(math.random(0, 1000) / 1000, 0, math.random(0, 1000) / 1000, 0);
			JumpscareShadeUI.Static.Rotation = 180 * math.random(0, 1);
			
			local RandomStaticImg = ""
			if math.random(1, 2) == 2 then
				RandomStaticImg = "rbxassetid://8681113503";
			else
				RandomStaticImg = "rbxassetid://8681113666";
			end

			JumpscareShadeUI.Static.Image = RandomStaticImg;
			JumpscareShadeUI.Static.ImageTransparency = math.random(1, 5) / 10;
			JumpscareShadeUI.Eyes.Visible = true;
			JumpscareShadeUI.Eyes.Position = UDim2.new(math.random(450, 550) / 1000, 0, math.random(450, 550) / 1000, 0);
		end

		JumpscareShadeUI.Eyes.Visible = false
		JumpscareShadeUI.Overlay.Visible = false
		JumpscareShadeUI.Visible = false
		ShadeClone:Destroy()

		TweenService:Create(game:GetService("Lighting"), TweenInfo.new(5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			FogEnd = 2000, 
			FogStart = 50
		}):Play()

		game:GetService("Lighting").Ambience_Shade.Enabled = false
	end);
end

return module;
