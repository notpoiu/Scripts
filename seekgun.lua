-- hi, this is old code
-- i wont bother to create a raycast for the jeff puddle, im too lazy

local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
local CustomShop = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Doors/Custom%20Shop%20Items/Source.lua"))()

local tweenService = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local mainui = player.PlayerGui.MainUI
local mouse = player:GetMouse()

local seekGun = game:GetObjects("rbxassetid://13386404155")[1] or LoadCustomInstance("https://raw.githubusercontent.com/persopoiu/scripts/main/SeekGunAssets/SeekPistol.rbxm")
local seekAmmo = game:GetObjects("rbxassetid://13386436753")[1] or LoadCustomInstance("https://raw.githubusercontent.com/persopoiu/scripts/main/SeekGunAssets/SeekAmmo.rbxm")
local seekPuddle = game:GetObjects("rbxassetid://13398815770")[1] or LoadCustomInstance("https://raw.githubusercontent.com/persopoiu/scripts/main/SeekGunAssets/SeekPuddle.rbxm")
seekPuddle.Size = Vector3.new(0.001, 0.001, 0.001)

if mainui.ItemShop and mainui.ItemShop.Visible then
    CustomShop.CreateItem(seekGun, {
        Title = _G.ShopName or "Seek Gun",
        Desc = _G.ShopDescription or "Seekifies Anything that it shoots",
        Image = "rbxassetid://13390436314",
        Price = _G.ShopPrice or 300,
        Stack = 1,
    })
end

seekGun.Parent = player.Backpack

function playSound(rbxassetid,part)
    task.spawn(function()
        local sound = Instance.new("Sound",part or game:GetService("ReplicatedStorage"))
        sound.SoundId = LoadCustomAsset(rbxassetid)
        sound:Play()
        sound.Ended:Wait()
        sound:Destroy()
    end)
end

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
    repeat task.wait() until seekGun == nil or not (seekGun:IsDescendantOf(player.Character) or seekGun:IsDescendantOf(player.Backpack))
    addconnect:Disconnect()
    seekAmmo:Destroy()
end)

function playPuddleAnimationOverModel(model)
    task.spawn(function()
        local seekPuddleClone = seekPuddle:Clone()

        seekPuddleClone.Position = model["Left Leg"].Position - Vector3.new(0,0.8,0)
        
        seekPuddleClone.CanCollide = true
        seekPuddleClone.Anchored = true
        seekPuddleClone.Parent = workspace

        tweenService:Create(seekPuddleClone,TweenInfo.new(1.5,Enum.EasingStyle.Sine),{
            ["Size"] = Vector3.new(10, 0.636, 10)
        }):Play()
    end)
end

seekGun.Activated:Connect(function()
    local seekAmmoClone = seekAmmo:Clone()
    local spawnPos = workspace.CurrentCamera.CFrame:ToWorldSpace(CFrame.new(0,0,-3) * CFrame.lookAt(Vector3.new(0, 0, 0), workspace.CurrentCamera.CFrame.LookVector))
    
    local Attachment = Instance.new("Attachment", seekAmmoClone)
    local LV = Instance.new("LinearVelocity", Attachment)
    LV.MaxForce = math.huge
    LV.VectorVelocity = mouse.Hit.LookVector * 0.5 * ((_G.launchForce or 20) * 10)
    LV.Attachment0 = Attachment

    seekAmmoClone.Parent = workspace
    seekAmmoClone.CFrame = spawnPos

    playSound("rbxassetid://9119460421")

    seekAmmoClone.Touched:Connect(function(hit)
        seekAmmoClone:Destroy()
        
        task.spawn(function()
            if not (game.Players:GetPlayerFromCharacter(hit.Parent)) and hit.Name ~= "Hidden" then
                local model = hit:FindFirstAncestorWhichIsA("Model")

                if model ~= nil and not (workspace.CurrentRooms:FindFirstChild(model.Name)) and model ~= workspace then
                    playSound("rbxassetid://344167846")

                    for _,instance in ipairs(model:GetDescendants()) do
                        if instance:IsA("BasePart") or instance:IsA("Part") or instance:IsA("MeshPart") then
                            instance.Anchored = false
                            instance.Material = "Foil"
                            instance.Color = Color3.fromRGB(0,0,0)
                        end

                        if instance:IsA("TextLabel") then
                            instance.TextColor3 = Color3.fromRGB(255,255,255)
                        end
                    end

                    if model.Name == "JeffTheKiller" then
                        local humanoid = model:FindFirstChildOfClass("Humanoid")

                        if humanoid.Health ~= 0 then
                            playPuddleAnimationOverModel(model)
                            playSound("rbxassetid://1196653896")
                        end
                        
                        humanoid.Health = 0
                    end
                end

                if hit.Name == "BananaPeel" and hit:IsDescendantOf(workspace) then
                    playSound("rbxassetid://344167846")
                    
                    hit.Color = Color3.fromRGB(0,0,0)
                    hit.Material = "Foil"

                    local mesh = hit:FindFirstChildOfClass("SpecialMesh")
                    mesh.TextureId = ""
                end
            end
        end)
    end)
end)
