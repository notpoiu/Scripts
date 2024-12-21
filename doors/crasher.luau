local players = {}
for _, player in pairs(game.Players:GetPlayers()) do
    players[player.Name] = player.Name
end

local args = {
    ["Players"] = players,
    ["Items"] = {
        ["TipJar"] = "TipJar",
        ["Crucifix"] = "Crucifix",
        ["RiftSmoothie"] = "RiftSmoothie",
        ["Flashlight"] = "Flashlight",
        ["StarVial"] = "StarVial",
        ["StarJug"] = "StarJug",
        ["Vitamins"] = "Vitamins",
        ["Bulklight"] = "Bulklight",
        ["Smoothie"] = "Smoothie",
        ["Lighter"] = "Lighter",
        ["Shears"] = "Shears",
        ["BatteryPack"] = "BatteryPack",
        ["Candle"] = "Candle",
        ["Shakelight"] = "Shakelight",
        ["AlarmClock"] = "AlarmClock",
        ["Cheese"] = "Cheese",
        ["BandagePack"] = "BandagePack",
        ["StarBottle"] = "StarBottle",
        ["HolyGrenade"] = "HolyGrenade",
        ["GweenSoda"] = "GweenSoda",
        ["RiftCandle"] = "RiftCandle",
        ["Straplight"] = "Straplight",
        ["LaserPointer"] = "LaserPointer",
        ["Bread"] = "Bread",
        ["Lockpick"] = "Lockpick",
        ["SkeletonKey"] = "SkeletonKey",
        ["Glowsticks"] = "Glowsticks"
    }
}
local skibidiRemote = game:GetService("ReplicatedStorage"):WaitForChild("RemotesFolder"):WaitForChild("AdminPanelRunCommand")
while task.wait() do
    skibidiRemote:FireServer("Give Items", args)
end
