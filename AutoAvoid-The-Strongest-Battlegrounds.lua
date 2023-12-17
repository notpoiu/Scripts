shared.BlockOrCounterKeycode = Enum.KeyCode.Four
shared.Range = 6

print("loaded")
if shared.DebugConnections ~= nil then
    for i,v in pairs(shared.DebugConnections) do
        v:Disconnect()
        v = nil
    end
end

-- services
local RunService = game:GetService("RunService")
local players = game:GetService("Players")

-- vars
local player = game.Players.LocalPlayer

-- tables
local validTargets = {}
-- "UsedDash"
local ignoreAccessories = {"FinalDeath","Ragdoll","RagdollSim","Small Debris","Freeze"}

-- functions
function stringstarts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

-- keypress functions
local vim = game:GetService('VirtualInputManager')
input = {
    hold = function(key, time)
        vim:SendKeyEvent(true, key, false, nil)
        task.wait(time)
        vim:SendKeyEvent(false, key, false, nil)
    end,
    press = function(key)
        vim:SendKeyEvent(true, key, false, nil)
	task.wait(0.005)
        vim:SendKeyEvent(false, key, false, nil)
    end
}

shared.DebugConnections = {}

local debounce = false
shared.DebugConnections["RunService"] = RunService.RenderStepped:Connect(function()
    for i,v in pairs(players:GetPlayers()) do
        if v ~= player then
            local pos,playerPos
            if not v.Character or not player.Character then return end

            if v.Character:FindFirstChild("HumanoidRootPart") then 
                pos = v.Character.HumanoidRootPart.Position
            else
                pos = v.Character:GetPivot().Position
            end

            if player.Character:FindFirstChild("HumanoidRootPart") then
                playerPos = player.Character.HumanoidRootPart.Position
            else
                playerPos = player.Character:GetPivot().Position
            end
            if (pos - playerPos).Magnitude <= (shared.Range or 6) then
                if not table.find(validTargets,v) then
                    validTargets[#validTargets + 1] = v
                    
                    local connections = {}
                    connections["LeavePlayer"] = v.CharacterRemoving:Connect(function()
                        table.remove(validTargets,table.find(validTargets,v))

                        for i,connect in pairs(connections) do
                            if shared.DebugConnections[v.Name..i] then
                                shared.DebugConnections[v.Name..i]:Disconnect()
                                shared.DebugConnections[v.Name..i] = nil
                            end

                            if connect then
                                connect:Disconnect()
                                connect = nil
                            end
                        end
                    end)

                    connections["LeaveRange"] = RunService.Heartbeat:Connect(function()
                        local pos = v.Character.HumanoidRootPart.Position or v.Character:GetPivot().Position
                        if (pos - players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > (shared.Range or 6) then
                            print("leaving range "..v.Name)
                            table.remove(validTargets,table.find(validTargets,v))
                            for i,connect in pairs(connections) do
                                if shared.DebugConnections[v.Name..i] then
                                    shared.DebugConnections[v.Name..i]:Disconnect()
                                    shared.DebugConnections[v.Name..i] = nil
                                end

                                if connect then
                                    connect:Disconnect()
                                    connect = nil
                                end
                            end
                        end
                    end)

                    connections["newAbilityUsed"] = v.Character.ChildAdded:Connect(function(child)
                        print("new ability used")
                        if not child:IsA("Accessory") then return end
                        print("real1")
                        for a,b in pairs(ignoreAccessories) do if child.Name:lower():match(b:lower()) then return end end
                        print("real2")
                        if stringstarts(child.Name,"#ACCESSORY") or child.Name:lower():match("counter") then return end
                        print("real3")

                        if not debounce then
                            debounce = true
                            print(child.Name.." and path: "..child:GetFullName())
                            input.hold(shared.BlockOrCounterKeycode or Enum.KeyCode.Four,0.15)
                            debounce = false
                        end
                    end)

                    for i,connect in pairs(connections) do
                        shared.DebugConnections[v.Name..i] = connect
                    end
                end
            end
        end
    end
end)

shared.DebugConnections["PlayerLeave"] = players.PlayerDisconnecting:Connect(function(player)
    if table.find(validTargets,player) then
        table.remove(validTargets,table.find(validTargets,player))
    end
end)

shared.DebugConnections["HumanoidDied"] = player.Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
    for i,v in pairs(validTargets) do
        table.remove(validTargets,i)
    end
end)

shared.DebugConnections["PlayerRespawn"] = player.CharacterAdded:Connect(function(char)
    for i,v in pairs(validTargets) do
        table.remove(validTargets,i)
    end
    
    task.spawn(function()
        char:WaitForChild("Humanoid",math.huge)

        shared.DebugConnections["HumanoidDied"]:Disconnect()
        shared.DebugConnections["HumanoidDied"] = player.Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
            for i,v in pairs(validTargets) do
                table.remove(validTargets,i)
            end

            for i,v in pairs(shared.DebugConnections) do
                if i:match("newAbilityUsed") or i:match("LeaveRange") or i:match("LeavePlayer") then
                    v:Disconnect()
                    v = nil
                end
            end
        end)
    end) 
end)
