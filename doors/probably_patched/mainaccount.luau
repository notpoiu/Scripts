-- FOR MAIN ACCOUNT
-- PROC ID: 19920

repeat task.wait() until game:IsLoaded()

local remotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemotesFolder")

-- is lobby
if game.PlaceId == 6516141723 then
    remotesFolder:WaitForChild("CreateElevator"):FireServer({
        ["Mods"] = {
            "EyesFour",
            "PlayerFast",
            "PlayerDamageMost"
        },
        ["Settings"] = {},
        ["Destination"] = "Hotel",
        ["FriendsOnly"] = true,
        ["MaxPlayers"] = "2"
    })

    return
end

-- In Game Handler
local localPlayer = game:GetService("Players").LocalPlayer

-- wait for game load
if localPlayer.PlayerGui:FindFirstChild("LoadingUI") and localPlayer.PlayerGui:FindFirstChild("LoadingUI").Enabled then
    repeat task.wait() until not localPlayer.PlayerGui:FindFirstChild("LoadingUI") and true or not localPlayer.PlayerGui.LoadingUI.Enabled
end

local mainUI = localPlayer.PlayerGui:WaitForChild("MainUI")
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

function fireprox(prompt: ProximityPrompt)
    if not prompt:IsA("ProximityPrompt") then
        return error("ProximityPrompt expected, got " .. typeof(prompt))
    end

    local connection
    local promptPosition = prompt.Parent:GetPivot().Position

    local originalEnabled = prompt.Enabled
    local originalHold = prompt.HoldDuration
    local originalLineOfSight = prompt.RequiresLineOfSight
    local originalCamCFrame = workspace.CurrentCamera.CFrame

    prompt.Enabled = true
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0

    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, promptPosition)
    connection = workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, promptPosition)
    end)

    task.wait()

    prompt:InputHoldEnd()
    prompt:InputHoldBegin()
    task.wait(prompt.HoldDuration + 0.05)
    prompt:InputHoldEnd()

    if connection then connection:Disconnect() end

    prompt.Enabled = originalEnabled
    prompt.HoldDuration = originalHold
    prompt.RequiresLineOfSight = originalLineOfSight
    workspace.CurrentCamera.CFrame = originalCamCFrame
end

-- UD asf real
local VIM = Instance.new("VirtualInputManager")
function HoldKey(key, time)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(time)
    VIM:SendKeyEvent(false, key, false, game)
end

function distFromChar(position: Instance | Vector3, getPositionFromCamera: boolean | nil)
    if not position then return 9e9 end
    if typeof(position) == "Instance" then
        position = position:GetPivot().Position
    end

    if getPositionFromCamera and (workspace.CurrentCamera) then
        local cameraPosition = workspace.CurrentCamera.CFrame.Position

        return (cameraPosition - position).Magnitude
    end

    if character.PrimaryPart then
        return (character.PrimaryPart.Position - position).Magnitude
    elseif workspace.CurrentCamera then
        return (workspace.CurrentCamera.CFrame.Position - position).Magnitude
    end

    return 9e9
end

mainUI:WaitForChild("ItemShop").Visible = false
remotesFolder:WaitForChild("PreRunShop"):FireServer({}, false)

local room = workspace:WaitForChild("CurrentRooms"):WaitForChild("0")
local key = room:WaitForChild("Assets"):WaitForChild("KeyObtain")
repeat task.wait()
    character:PivotTo(key:GetPivot())
    fireprox(key.ModulePrompt)
until character:FindFirstChild("Key") or localPlayer.Backpack:FindFirstChild("Key")

local keyTool = character:FindFirstChild("Key") or localPlayer.Backpack:FindFirstChild("Key")
if keyTool.Parent ~= character then
    keyTool.Parent = character
end

task.wait(0.25)

local door = room:WaitForChild("Door")
local doorRoot = door:WaitForChild("Door")
local prompt = door:WaitForChild("Lock"):WaitForChild("UnlockPrompt")

task.wait()
character:PivotTo(doorRoot.CFrame * CFrame.new(0, 0, 5))
repeat task.wait()
    character:PivotTo(doorRoot.CFrame * CFrame.new(0, 0, 5))
    if keyTool.Parent ~= character then
        -- LOCKED Property error Fix
        pcall(function() keyTool.Parent = character end)
    end
    fireprox(prompt)
until game:GetService("ReplicatedStorage").GameData.LatestRoom.Value == 1 or not keyTool:IsDescendantOf(game)

repeat task.wait()
    character:PivotTo(doorRoot.CFrame * CFrame.new(0, 0, 5))
    door.ClientOpen:FireServer()
until door:GetAttribute("Opened")

task.spawn(HoldKey, Enum.KeyCode.W, 0.5)

-- Reviving
local oldReviveCount = localPlayer.PlayerGui.TopbarUI.Topbar.Revives.Text
repeat task.wait() until mainUI:FindFirstChild("FriendReviveLive") and mainUI:FindFirstChild("FriendReviveLive").Visible
task.wait(2)
remotesFolder:WaitForChild("Revive"):FireServer()
repeat task.wait() until localPlayer.PlayerGui.TopbarUI.Topbar.Revives.Text ~= oldReviveCount
game:Shutdown()
