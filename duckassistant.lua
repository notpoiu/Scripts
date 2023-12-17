--[[
Duck script/assistant
its a duck that follows you around and helps you with stuff in doors.

made by upio

please do not steal this script and claim it as your own, thanks
]]--

local Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()

local runService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local tweenService = game:GetService("TweenService")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local entitynames = {"RushMoving","AmbushMoving","A60","A120","Eyes","JeffTheKiller"}

local overrideMovingPermission = false
local latestRoom = game:GetService("ReplicatedStorage").GameData.LatestRoom

local duck = game:GetObjects("rbxassetid://13675466339")[1]
duck.Parent = workspace

local pointLight = Instance.new("PointLight",duck)
pointLight.Color = Color3.fromRGB(255, 218, 8)
pointLight.Brightness = 0
pointLight.Range = 0

local guidingPointLight = Instance.new("PointLight",character.Head)
guidingPointLight.Color = Color3.fromRGB(255, 218, 8)
guidingPointLight.Brightness = 0
guidingPointLight.Range = 0

local overrideKeySound = false
local connections = {}

function sendCaption(message,time)
    firesignal(game:GetService("ReplicatedStorage").EntityInfo.Caption.OnClientEvent, message or "No Message Provided", true, time or 5)
end


function playSound(soundAssetID,properties)
    task.spawn(function()
        local sound = Instance.new("Sound",duck)
        sound.SoundId = LoadCustomAsset("rbxassetid://"..soundAssetID:gsub("rbxassetid://",""))

        if properties ~= nil then
            for Property, Value in next, properties do
                if Property ~= "SoundId" then
                    sound[Property] = Value
                end
            end
        end

        sound:Play()
        if sound.Looped then
            return sound
        end

        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

function moveDuck(position,direction,Orientation,distanceBehind)
	--local direction = chr.HumanoidRootPart.CFrame.LookVector

	local duckPosition = position - (direction * (distanceBehind or 3))

	duck.BodyPosition.Position = duckPosition
	tweenService:Create(duck,TweenInfo.new(0.5),{
		Orientation = Vector3.new(0, Orientation.Y, 0)
	}):Play()
	duck:FindFirstChildOfClass("BodyAngularVelocity").AngularVelocity = Vector3.new(0, 0, 0)

    task.spawn(function()
        repeat task.wait() until duck.BodyPosition == position
        return true
    end)
end

function getObjectPositionByOffsetInDirection(object,offset,movementDirecton)
    if movementDirecton == "back" then
        -- Get the object's orientation
        local objectOrientation = object.Orientation

        -- Convert the orientation to a rotation matrix
        local rotationMatrix = CFrame.fromEulerAnglesXYZ(math.rad(objectOrientation.X),
            math.rad(objectOrientation.Y),
            math.rad(objectOrientation.Z))

        -- Get the object's dimensions
        local objectSize = object.Size

        -- Calculate the back position based on the object's orientation and dimensions
        local backPosition = object.Position - (rotationMatrix.LookVector * (objectSize.Z / 2 + offset))

        return backPosition
    end

    if movementDirecton == "left" then
        -- Get the object's orientation
        local objectOrientation = object.Orientation

        -- Convert the orientation to a rotation matrix
        local rotationMatrix = CFrame.fromEulerAnglesXYZ(math.rad(objectOrientation.X),
                                                        math.rad(objectOrientation.Y),
                                                        math.rad(objectOrientation.Z))

        -- Get the object's dimensions
        local objectSize = object.Size

        -- Calculate the left position based on the object's orientation and dimensions
        local leftPosition = object.Position - (rotationMatrix.RightVector * (objectSize.X / 2 + offset))

        return leftPosition
    end

    if movementDirecton == "front" then
        -- Get the object's CFrame
        local objectCFrame = object.CFrame

        -- Calculate the front position based on the object's CFrame and dimensions
        local frontPosition = objectCFrame.Position + (objectCFrame.LookVector * -1 * (object.Size.Z / 2 + offset))

        return frontPosition
    end
end

connections.bodyposballer = duck.BodyPosition:GetPropertyChangedSignal("Position"):Connect(function()
    if player:DistanceFromCharacter(duck.BodyPosition.Position) <= pointLight.Range + 50 and workspace.CurrentRooms:FindFirstChild(game.Players.LocalPlayer:GetAttribute("CurrentRoom")):GetAttribute("IsDark") then
        local playerInSight = workspace.FindPartOnRayWithIgnoreList(workspace, Ray.new(duck.BodyPosition.Position, character.HumanoidRootPart.Position - duck.BodyPosition.Position), {duck, character}) == nil
        if not playerInSight and guidingPointLight.Range == 0 then
            sendCaption("you feel a presence guide you...",1.5)
            tweenService:Create(guidingPointLight,TweenInfo.new(1.5),{
                Brightness = 2,
                Range = 35
            }):Play()
        end
    else
        if guidingPointLight.Range ~= 0 then
            tweenService:Create(guidingPointLight,TweenInfo.new(0.5),{
                Brightness = 0,
                Range = 0
            }):Play()
        end
    end
end)

function findKeyInRoom(room)
    for _,v in ipairs(room:GetDescendants()) do
        if v.Name == "KeyObtain" or v.Name == "LeverForGate" then
            return v
        end
    end
    return
end

function doDuckLogic()
    local room = workspace.CurrentRooms[latestRoom.Value]

    if not string.find(string.lower(room:GetAttribute("OriginalName")),"seek") then
        overrideMovingPermission = false

        
        local isDupeRoom = false
        for _,v in ipairs(room:GetChildren()) do
            task.wait()
            if v.Name == "Closet" then
                if v:FindFirstChild("DoorFake") then
                    isDupeRoom = true
                    break
                end
            end
        end

        if room:GetAttribute("RequiresKey") then
            local key = findKeyInRoom(room) or room.Assets:FindFirstChild("KeyObtain")

            if key then
                overrideMovingPermission = true
                
                moveDuck(getObjectPositionByOffsetInDirection(key.PrimaryPart, 3,"front"), -character.HumanoidRootPart.CFrame.LookVector,-character.HumanoidRootPart.Orientation,-5)
    
                task.spawn(function()
                    if key.Name == "KeyObtain" then
                        task.wait(1)
                        repeat task.wait(0.25)
                            task.spawn(function()
                                task.wait(0.5)
                                if not overrideKeySound then
                                    ballers = 0
                                    playSound("5681935637")
                                end
                            end)
                        until (player.Character:FindFirstChild("Key") and player.Character:FindFirstChild("Key"):GetAttribute("LockID") == room.Door.Sign.Stinker.Text) or (player.Backpack:FindFirstChild("Key") and player.Backpack:FindFirstChild("Key"):GetAttribute("LockID") == room.Door.Sign.Stinker.Text) or room ~= workspace.CurrentRooms[latestRoom.Value]
                    else
                        key.PrimaryPart:WaitForChild("SoundToPlay").Played:Wait()
                    end
                    if not isDupeRoom then
                        overrideMovingPermission = false
                    end
                end)
            end
        end

        if isDupeRoom and not room ~= workspace.CurrentRooms[latestRoom.Value] and (room:GetAttribute("RequiresKey") and (player.Character:FindFirstChild("Key") and player.Character:FindFirstChild("Key"):GetAttribute("LockID") == room.Door.Sign.Stinker.Text) or (player.Backpack:FindFirstChild("Key") and player.Backpack:FindFirstChild("Key"):GetAttribute("LockID") == room.Door.Sign.Stinker.Text)) then
            overrideMovingPermission = true
            tweenService:Create(pointLight,TweenInfo.new(1.5),{
                Brightness = 2,
                Range = 35
            }):Play()
            moveDuck(getObjectPositionByOffsetInDirection(room.Door.Door, 3,"front"), -character.HumanoidRootPart.CFrame.LookVector,-character.HumanoidRootPart.Orientation,-5)
            playSound("5681935637")
            repeat task.wait() until latestRoom.Value ~= tonumber(room.Name)
            overrideMovingPermission = false
            tweenService:Create(pointLight,TweenInfo.new(1.5),{
                Brightness = 0,
                Range = 0
            }):Play()
        end
    end
    
    if string.find(string.lower(room:GetAttribute("OriginalName")),"seek") then
        overrideMovingPermission = true
        moveDuck(getObjectPositionByOffsetInDirection(room.Door.Door,3,"front"), -character.HumanoidRootPart.CFrame.LookVector,-character.HumanoidRootPart.Orientation,0)
        playSound("5681935637")
    end

    if latestRoom.Value == 50 then
        tweenService:Create(pointLight,TweenInfo.new(1.5),{
            Brightness = 2,
            Range = 35
        }):Play()
        overrideMovingPermission = true

        local books = {}
        for _,v in ipairs(room.Assets:GetDescendants()) do
            if v:IsA("Model") and (v.Name == "LiveHintBook") then
                table.insert(books,v)
            end
        end

        local playerPosition = character.PrimaryPart.Position

        table.sort(books, function(instanceA, instanceB)
            local positionA = instanceA.PrimaryPart.Position
            local positionB = instanceB.PrimaryPart.Position
            local distanceA = (positionA - playerPosition).Magnitude
            local distanceB = (positionB - playerPosition).Magnitude
            return distanceA < distanceB
        end)

        for _,v in pairs(books) do
            if v == nil or not v:IsDescendantOf(workspace) then
                continue
            end

            moveDuck(getObjectPositionByOffsetInDirection(v.PrimaryPart,3.5,"front"),-character.HumanoidRootPart.CFrame.LookVector,-character.HumanoidRootPart.Orientation,2.5)

            v.AncestryChanged:Connect(function()
                if not v:IsDescendantOf(room) then
                    table.remove(books,_)
                end
            end)

            v.AncestryChanged:Wait()
        end
    elseif latestRoom.Value == 51 then
        tweenService:Create(pointLight,TweenInfo.new(0.5),{
            Brightness = 0,
            Range = 0
        }):Play()
    end

    if latestRoom.Value == 100 then
        tweenService:Create(pointLight,TweenInfo.new(1.5),{
            Brightness = 2,
            Range = 35
        }):Play()
        overrideMovingPermission = true

        local books = {}
        for _,v in ipairs(room.Assets:GetDescendants()) do
            if v:IsA("Model") and (v.Name == "LiveBreakerPolePickup") then
                table.insert(books,v)
            end
        end

        local playerPosition = character.PrimaryPart.Position

        table.sort(books, function(instanceA, instanceB)
            local positionA = instanceA.PrimaryPart.Position
            local positionB = instanceB.PrimaryPart.Position
            local distanceA = (positionA - playerPosition).Magnitude
            local distanceB = (positionB - playerPosition).Magnitude
            return distanceA < distanceB
        end)

        for _,v in pairs(books) do
            if v == nil or not v:IsDescendantOf(workspace) then
                table.remove(books,_)
                continue
            end

            moveDuck(getObjectPositionByOffsetInDirection(v.PrimaryPart,3.5,"front"),-character.HumanoidRootPart.CFrame.LookVector,-character.HumanoidRootPart.Orientation,2.5)

            v.AncestryChanged:Connect(function()
                if not v:IsDescendantOf(room) then
                    table.remove(books,_)
                end
            end)

            v.AncestryChanged:Wait()
        end
    end
end

connections.entity = workspace.ChildAdded:Connect(function(v)
    if table.find(entitynames,v.Name) then
        repeat task.wait() until player:DistanceFromCharacter(v:GetPivot().Position) < 1000 or not v:IsDescendantOf(workspace)
        if v:IsDescendantOf(workspace) then
            overrideKeySound = true
            playSound("7317316612")
            task.spawn(function()
                repeat task.wait() until not v:IsDescendantOf(workspace)
                overrideKeySound = false
            end)
            
        end
    end
end)

connections.entityScreech = workspace.CurrentCamera.ChildAdded:Connect(function(v)
    if v.Name == "Screech" then
        overrideKeySound = true
        playSound("7317316612")
    end
end)

connections.entityScreechRemoving = workspace.CurrentCamera.ChildRemoved:Connect(function(v)
    if v.Name == "Screech" then
        overrideKeySound = false
    end
end)

connections.light = game.Players.LocalPlayer:GetAttributeChangedSignal("CurrentRoom"):Connect(function()
    local room = game.Players.LocalPlayer:GetAttribute("CurrentRoom")

    if workspace.CurrentRooms:FindFirstChild(room) then
        room = workspace.CurrentRooms:FindFirstChild(room)

        local roomConnect = room:GetAttributeChangedSignal("IsDark"):Connect(function()
            if (room:GetAttribute("IsDark")) then
                if pointLight.Range ~= 35 then
                    tweenService:Create(pointLight,TweenInfo.new(1.5),{
                        Brightness = 2,
                        Range = 35
                    }):Play()
                end
            else
                if pointLight.Range ~= 0 then
                    tweenService:Create(pointLight,TweenInfo.new(0.5),{
                        Brightness = 0,
                        Range = 0
                    }):Play()
                end
            end
        end)

        task.spawn(function()
            repeat task.wait() until tostring(game.Players.LocalPlayer:GetAttribute("CurrentRoom")) ~= room.Name
            roomConnect:Disconnect()
        end)
        
        if (room:GetAttribute("IsDark") or string.find(string.lower(room:GetAttribute("OriginalName")),"seek")) then
            if pointLight.Range ~= 35 then
                tweenService:Create(pointLight,TweenInfo.new(1.5),{
                    Brightness = 2,
                    Range = 35
                }):Play()
            end
        else
            if pointLight.Range ~= 0 then
                tweenService:Create(pointLight,TweenInfo.new(0.5),{
                    Brightness = 0,
                    Range = 0
                }):Play()
            end
        end
    end
end)

connections.doDuckLogicConnection = latestRoom:GetPropertyChangedSignal("Value"):Connect(doDuckLogic)
doDuckLogic()


function cleanup()
    for _,connection in pairs(connections) do
        connection:Disconnect()
    end

    doDuckLogic = function() end
    playSound = function() end
    moveDuck = function() end
    getObjectPositionByOffsetInDirection = function() end
    latestRoom = nil

    guidingPointLight:Destroy()
    duck:Destroy()

    return true
end

connections.playerwalking = game.Players.LocalPlayer.Character.Collision:GetPropertyChangedSignal("Position"):Connect(function()
    if not overrideMovingPermission and duck ~= nil and duck:IsDescendantOf(workspace) then
        if game.Players.LocalPlayer.Character.Humanoid.Health ~= 0 or game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            moveDuck(getObjectPositionByOffsetInDirection(character.HumanoidRootPart,3.5,"left"), character.HumanoidRootPart.CFrame.LookVector,-character.HumanoidRootPart.Orientation,-5)
        else
            cleanup()
        end
    end
end)
