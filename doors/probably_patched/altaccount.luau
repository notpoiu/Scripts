-- FOR ALT ACCOUNT

repeat task.wait() until game:IsLoaded()

local remotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("RemotesFolder")
local targetPlayerName = game:GetService("Players"):GetNameFromUserIdAsync(shared.MainAccountUserID or 3347106500)

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

-- Lobby Handler
if game.PlaceId == 6516141723 then
    local elevators = workspace:WaitForChild("Lobby"):WaitForChild("LobbyElevators")
    remotesFolder:WaitForChild("ShopCode"):FireServer("SIX2025")
    
    local targetElevator = nil
    repeat task.wait()
        for _, elevator in pairs(elevators:GetChildren()) do
            if elevator.Name:match(targetPlayerName) then
                targetElevator = elevator
                break
            end
        end
    until targetElevator

    remotesFolder:WaitForChild("ElevatorJoin"):FireServer(targetElevator)
    return
end

-- In Game Handler
local localPlayer = game:GetService("Players").LocalPlayer
local targetPlayer = game:GetService("Players"):WaitForChild(targetPlayerName)
local mainUI = localPlayer.PlayerGui:WaitForChild("MainUI")

-- wait for game load
if localPlayer.PlayerGui:FindFirstChild("LoadingUI") and localPlayer.PlayerGui:FindFirstChild("LoadingUI").Enabled then
    repeat task.wait() until not localPlayer.PlayerGui:FindFirstChild("LoadingUI") and true or not localPlayer.PlayerGui.LoadingUI.Enabled
end

mainUI:WaitForChild("ItemShop").Visible = false
task.wait(1.5)
remotesFolder:WaitForChild("PreRunShop"):FireServer({}, true)

local skipPrompt = workspace:WaitForChild("CurrentRooms"):WaitForChild("0"):WaitForChild("StarterElevator"):WaitForChild("Model"):WaitForChild("Model"):WaitForChild("SkipButton"):WaitForChild("SkipPrompt")
local preRun = game:GetService("ReplicatedStorage"):WaitForChild("GameData"):WaitForChild("PreRun")
repeat task.wait()
    fireprox(skipPrompt)
until not preRun.Value

repeat task.wait() until not targetPlayer:GetAttribute("Alive")
task.wait(2.5)
remotesFolder:WaitForChild("ReviveFriend"):FireServer(targetPlayerName)
