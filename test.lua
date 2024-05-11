local console = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSDOORS/main/Utils/Console/Utility.lua"))()
local message = console.custom_console_progressbar("[MSHUB]: Authenticating...")

for i = 1, 10 do
    message.update_message_with_progress("[MSHUB]: Passing Checkpoint " .. i, i)
    task.wait(.05)
end

message.update_message("[MSHUB]: Authenticated!", "rbxasset://textures/AudioDiscovery/done.png", Color3.fromRGB(51, 255, 85))
