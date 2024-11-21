--[[
©️ 2024 upio

Console Utils, a utility made to help with logging dynamic messages in roblox console.
https://www.upio.dev/
https://www.mspaint.cc/

Please do not redistribute or claim the code as your own.
However you may use it anywhere without any credits (but credits are appreciated <3)

]]

local global_env = getgenv() or shared or _G or {}
local cloneref = (cloneref or clonereference or function(instance: any) return instance end)

local RunService = cloneref(game:GetService("RunService"))
local LogService = cloneref(game:GetService("LogService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

if not global_env._console_message_counter then
    global_env._console_message_counter = 3000
end

local module = {}

function _internal_get_guid()
    global_env._console_message_counter = global_env._console_message_counter + 1
    return tostring(global_env._console_message_counter) .. tostring(tick())
end

function _internal_get_message_index(UMID)
    local message_index = -1
    
    repeat task.wait(.05)
        for idx, data in pairs(LogService:GetLogHistory()) do
            if tostring(data.message) ~= tostring(UMID) then continue end
            
            message_index = idx + 1
            break
        end
    until message_index ~= -1

    return message_index
end

function _internal_is_console_open()
    local console_master = CoreGui:FindFirstChild("DevConsoleMaster")
        
    if not console_master then
        return false
    end

    local window = console_master:FindFirstChild("DevConsoleWindow")

    if not window then
        return false
    end

    local dev_console_ui = window:FindFirstChild("DevConsoleUI")

    if not dev_console_ui then
        return false
    end

    return (dev_console_ui:FindFirstChild("MainView") and dev_console_ui.MainView:FindFirstChild("ClientLog"))
end

function module.custom_print(...)
    local message = ""
    local image = ""
    local color = Color3.fromRGB(255, 255, 255)
    local timestamp = os.date("%H:%M:%S")

    if typeof(select(1, ...)) == "table" then
        local data = select(1, ...)

        if typeof(data.message) == "string" then
            message = data.message
        end

        if typeof(data.image) == "string" then
            image = data.image
        end

        if typeof(data.color) == "Color3" then
            color = data.color
        end

    else
        local msg = select(1, ...)
        local img = select(2, ...)
        local clr = select(3, ...)

        if typeof(msg) == "string" then
            message = msg
        end

        if typeof(img) == "string" then
            image = img
        end
        
        if typeof(clr) == "Color3" then
            color = clr
        end
    end
    
    -- unique message id
    local UMID = _internal_get_guid()
    print(UMID)
    
    local message_index = _internal_get_message_index(UMID)
    
    local ConsoleUI;
    local conn; conn = RunService.RenderStepped:Connect(function()
        if _internal_is_console_open() then
            if not ConsoleUI or not ConsoleUI.Parent or not ConsoleUI:IsDescendantOf(CoreGui) then
                ConsoleUI = CoreGui.DevConsoleMaster.DevConsoleWindow.DevConsoleUI
            end
            
            local log = ConsoleUI.MainView.ClientLog:FindFirstChild(tostring(message_index))
            
            if not log then
                return
            end

            local msg = log:FindFirstChild("msg")
            local img = log:FindFirstChild("image")

            if not msg or not img then
                return
            end

            msg.Text = timestamp .. " -- " .. message
            msg.TextColor3 = color

            img.Image = image
            img.ImageColor3 = color
        end
    end)

    local log_module = {}

    function log_module.update_message(...)
        if typeof(select(1, ...)) == "table" then
            local data = select(1, ...)

            if typeof(data.message) == "string" then
                message = data.message
            end

            if typeof(data.image) == "string" then
                image = data.image
            end

            if typeof(data.color) == "Color3" then
                color = data.color
            end
        else
            local msg = select(1, ...)
            local img = select(2, ...)
            local clr = select(3, ...)

            if typeof(msg) == "string" then
                message = msg
            end

            if typeof(img) == "string" then
                image = img
            end
            
            if typeof(clr) == "Color3" then
                color = clr
            end
        end

        timestamp = os.date("%H:%M:%S")
    end

    function log_module.cleanup()
        conn:Disconnect()
    end

    return log_module
end


function module.custom_console_progressbar(params)
    if typeof(params) == "string" then
        params = {msg = params}
    end

    local msg = params["msg"]
    local clr = params["clr"]
    local img = params["img"]

    local progressbar_length = params["length"] or 10

    local progressbar_char = "█"
    local progressbar_empty = "░"

    local message = module.custom_print(msg, img, clr)
    local progress = 0

    local progressbar_module = {}

    function progressbar_module.update_message(_message, _image, _color)
        message.update_message(_message, _image, _color)
    end

    function progressbar_module.update_progress(_progress)
        progress = _progress
        local progressbar_string = ""

        local normalized_progress = math.floor(progress / progressbar_length * 100)

        for i=1, 10 do
            if i <= progress / progressbar_length * 10 then
                progressbar_string = progressbar_string .. progressbar_char
            else
                progressbar_string = progressbar_string .. progressbar_empty
            end
        end

        message.update_message(msg .. " [" .. progressbar_string .. "] " .. normalized_progress .. "%", img, clr)
    end

    function progressbar_module.update_message_with_progress(_message,_progress)
        _progress = _progress or progress

        msg = _message
        progressbar_module.update_progress(_progress)
    end

    function progressbar_module.cleanup()
        message.cleanup()
    end

    return progressbar_module
end

return module
