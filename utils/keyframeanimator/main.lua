local KeyframeAnimator = {}
local RunService = game:GetService("RunService")

function KeyframeAnimator:InitAnimation(model, keyframeSequence, looped)
    local keyframes = keyframeSequence:GetChildren()
    table.sort(keyframes, function(a, b)
        return a.Time < b.Time
    end)

    local timeOffset = keyframes[1].Time or 0

    local animationData = {}
    for _, keyframe in ipairs(keyframes) do
        local time = keyframe.Time - timeOffset

        local poseData = {}

        for _, pose in ipairs(keyframe:GetDescendants()) do
            if pose:IsA("Pose") then
                poseData[pose.Name] = pose.CFrame
            end
        end

        table.insert(animationData, {Time = time, Poses = poseData})
    end

    local startTime = tick()
    local duration = animationData[#animationData].Time
    local motor6Ds = {}
    local isPaused = true
    local pauseTime = 0

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("Motor6D") and descendant.Part1 then
            motor6Ds[descendant.Part1.Name] = descendant
        elseif descendant:IsA("Motor6D") then
			motor6Ds[descendant.Name] = descendant
        end
    end

    local controller = {}

    controller.Looped = looped or false
    controller.AnimationFinished = Instance.new("BindableEvent")
    controller.PlaybackSpeed = 1 -- a negative playback speed should play the animation in reverse

    local function updateAnimation()
        local elapsedTime = tick() - startTime

        if isPaused then
            elapsedTime = pauseTime
        end

        local currentTime = elapsedTime * controller.PlaybackSpeed

        if controller.Looped then
            currentTime = currentTime % duration
            if currentTime < 0 then
                currentTime = currentTime + duration
            end
        else
            if controller.PlaybackSpeed > 0 and currentTime > duration then
                controller:Stop()
                controller.AnimationFinished:Fire()
                return
            elseif controller.PlaybackSpeed < 0 and currentTime < 0 then
                controller:Stop()
                controller.AnimationFinished:Fire()
                return
            end
        end

        if currentTime < 0 then
            local firstKeyframe = animationData[1]
            for jointName, motor in pairs(motor6Ds) do
                local pose = firstKeyframe.Poses[jointName]
                if pose then
                    motor.Transform = pose
                else
                    motor.Transform = CFrame.new()
                end
            end
            return
        elseif currentTime > duration then
            local lastKeyframe = animationData[#animationData]
            for jointName, motor in pairs(motor6Ds) do
                local pose = lastKeyframe.Poses[jointName]
                if pose then
                    motor.Transform = pose
                else
                    motor.Transform = CFrame.new()
                end
            end
            return
        end

        local prevKeyframe, nextKeyframe
        for i = 1, #animationData - 1 do
            if currentTime >= animationData[i].Time and currentTime <= animationData[i + 1].Time then
                prevKeyframe = animationData[i]
                nextKeyframe = animationData[i + 1]
                break
            end
        end

        if not prevKeyframe or not nextKeyframe then
            -- shoudnt happen but redundancy :content:
            return
        end

        local timeDelta = nextKeyframe.Time - prevKeyframe.Time
        local alpha = (currentTime - prevKeyframe.Time) / timeDelta

        for jointName, motor in pairs(motor6Ds) do
            local prevPose = prevKeyframe.Poses[jointName]
            local nextPose = nextKeyframe.Poses[jointName]
            if prevPose and nextPose then
                local interpolatedCFrame = prevPose:Lerp(nextPose, alpha)
                motor.Transform = interpolatedCFrame
            elseif prevPose then
                motor.Transform = prevPose
            elseif nextPose then
                motor.Transform = nextPose
            else
                motor.Transform = CFrame.new()
            end
        end
    end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not isPaused then
            updateAnimation()
        end
    end)

    function controller:Play()
        startTime = tick()
        isPaused = false
    end

    function controller:Pause()
        isPaused = true
        pauseTime = (tick() - startTime)
    end

    function controller:Resume()
        isPaused = false
        startTime = tick() - pauseTime
    end

    function controller:Stop()
        isPaused = true
        if connection then
            connection:Disconnect()
            connection = nil
        end
        for _, motor in pairs(motor6Ds) do
            motor.Transform = CFrame.new()
        end
    end

    return controller
end

return KeyframeAnimator
