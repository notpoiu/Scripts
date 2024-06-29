local console = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/MSDOORS/main/Utils/Console/Utility.lua"))()

-- Regular Print Example
-- args: message, image, color
console.custom_print("[MSHUB]: Example script 😎")
console.custom_print("[MSHUB]: Example script 😎", "", Color3.fromRGB(255, 0, 255))

-- Progressbar Example
local message = console.custom_console_progressbar("[MSHUB]: Authenticating...")
--[[
local message = create_progressbar({
    msg = "[MSHUB]: Authenticating...", -- REQUIRED
    img = "", -- DEFAULT IS ""
    clr = Color3.fromRGB(255, 255, 255), -- DEFAULT is white
    length = 10 -- progressbar steps (DEFAULT IS 10)
})]]

--[[
update_message_with_progress args:
- message (REQUIRED)
- progress index (optional if not provided will use the current progress registered)

message.update_message_with_progress("[MSHUB]: Connecting to MSHUB Servers...", 1)
message.update_message_with_progress("[MSHUB]: Checking HWID...") -- this would still be 10% if progressbar steps is 10
]]

for i = 1, 10 do
    message.update_progress(i)
    task.wait(.05)
end

message.update_message("[MSHUB]: Authenticated!", "rbxasset://textures/AudioDiscovery/done.png", Color3.fromRGB(51, 255, 85))
