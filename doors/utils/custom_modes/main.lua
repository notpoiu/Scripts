repeat task.wait() until game:IsLoaded()

-- Services
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local gameData = replicatedStorage:WaitForChild("GameData")
local latestRoom = gameData:WaitForChild("LatestRoom")

local previousIndex = nil
local randomSeed = string.gsub(game.JobId, '%D+', '')
local randomGenerator = Random.new(randomSeed + 1)

-- tables
local module = {
    Events = {["_internal_events"] = {}},
    Connections = {}
}

-- functions
function module.Events:CreateEvent(callback)
    assert(typeof(callback) == "function", "Expected function as first argument to create event but got " .. typeof(callback))
    table.insert(module.Events["_internal_events"], callback)
end

-- Synchronization was broken :(
assert(latestRoom.Value == 0, "Was unable to synchronize all clients, did you execute on door 0?")

module.Connections["RNGConnection"] = latestRoom:GetPropertyChangedSignal("Value"):Connect(function()
    local randomlyGeneratedIndex
    repeat
        randomlyGeneratedIndex = randomGenerator:NextInteger(1, #events)
    until randomlyGeneratedIndex ~= previousIndex

    previousIndex = randomlyGeneratedIndex

    task.spawn(module.Events["_internal_events"][randomlyGeneratedIndex])
end)

return module
