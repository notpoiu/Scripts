--[[
    ©️ 2024-2025 upio

    Console Utils, a utility made to help with logging dynamic messages in roblox console.
    https://www.upio.dev/
    https://www.mspaint.cc/

    Please do not redistribute or claim the code as your own.
    However you may use it anywhere without any credits (but credits are appreciated <3)
--]]

local global_env = getgenv() or shared or _G or {}
if global_env["console_utils"] then return global_env.console_utils end

--// module table \\--
local module = {
    custom_prints = {},
    render_stepped_conn = nil,
}

--// services \\--
local cloneref = (cloneref or clonereference or function(instance: any) return instance end)
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

--// variables \\--
local ClientLog = nil;

if not global_env._console_message_counter then
    global_env._console_message_counter = 3000
end

--// functions \\--
function _internal_get_guid()
    global_env._console_message_counter = global_env._console_message_counter + 1
    return tostring(global_env._console_message_counter) .. tostring(tick())
end

function _internal_get_console()
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

    local _ClientLog = (dev_console_ui:FindFirstChild("MainView") and dev_console_ui.MainView:FindFirstChild("ClientLog"))
    return _ClientLog ~= nil, _ClientLog
end

--// module functions \\--
function module.custom_print(...)
    local custom_print = {
        message = "",
        image = "",
        color = Color3.fromRGB(255, 255, 255),
        timestamp = os.date("%H:%M:%S"),
        UMID = -1
    }

    --// fetch data \\--
    if typeof(select(1, ...)) == "table" then
        local data = select(1, ...)

        if typeof(data.message) == "string" then
            custom_print.message = data.message
        end

        if typeof(data.image) == "string" then
            custom_print.image = data.image
        end

        if typeof(data.color) == "Color3" then
            custom_print.color = data.color
        end
    else
        local msg = select(1, ...)
        local img = select(2, ...)
        local clr = select(3, ...)

        if typeof(msg) == "string" then
            custom_print.message = msg
        end

        if typeof(img) == "string" then
            custom_print.image = img
        end

        if typeof(clr) == "Color3" then
            custom_print.color = clr
        end
    end

    -- unique message id
    local UMID = _internal_get_guid()
    print(UMID)

    --// for main loop \\--
    local logData;

    table.insert(module.custom_prints, custom_print)
    custom_print.update = function()
        if not ClientLog then return end

        if logData and logData.inst and logData.inst:IsDescendantOf(ClientLog) then
            if logData.msg then
                -- Update the message
                logData.msg.Text = custom_print.timestamp .. " -- " .. custom_print.message
                logData.msg.TextColor3 = custom_print.color
                logData.msg.TextWrapped = true
            end

            if logData.img then
                logData.img.Image = custom_print.image
                logData.img.ImageColor3 = custom_print.color
            end
        else
            for _, newlog in pairs(ClientLog:GetChildren()) do
                if not (newlog:FindFirstChild("msg") and newlog:FindFirstChild("image")) then continue end
                if tostring(newlog.msg.Text):split(" -- ")[2] ~= tostring(UMID) then continue end

                logData = {
                    inst = newlog,
                    msg = newlog:FindFirstChild("msg"),
                    img = newlog:FindFirstChild("image")
                };

                break
            end
        end
    end

    --// print functions \\--
    local log_module = {}

    log_module.update_message = function(...)
        local update_timestamp = true

        if typeof(select(1, ...)) == "table" then
            local data = select(1, ...)

            if typeof(data.message) == "string" then
                custom_print.message = data.message
            end

            if typeof(data.image) == "string" then
                custom_print.image = data.image
            end

            if typeof(data.color) == "Color3" then
                custom_print.color = data.color
            end

            if typeof(data.update_timestamp) == "boolean" then
                update_timestamp = data.timestamp
            end
        else
            local msg = select(1, ...)
            local img = select(2, ...)
            local clr = select(3, ...)
            local update = select(4, ...)

            if typeof(msg) == "string" then
                custom_print.message = msg
            end

            if typeof(img) == "string" then
                custom_print.image = img
            end

            if typeof(clr) == "Color3" then
                custom_print.color = clr
            end

            if typeof(update_timestamp) == "boolean" then
                update_timestamp = update
            end
        end

        if update_timestamp then
            custom_print.timestamp = os.date("%H:%M:%S")
        end
    end

    log_module.cleanup = function()
        for i, print_data in pairs(module.custom_prints) do
            if print_data.UMID == UMID then
                table.remove(module.custom_prints, i)
                break
            end
        end

        custom_print.update = function() end
    end

    return log_module
end

function module.custom_console_progressbar(params)
    if typeof(params) == "string" then
        params = {msg = params}
    end

    local msg = params["msg"] or params["message"]
    local clr = params["clr"] or params["color"]
    local img = params["img"] or params["image"]

    local progressbar_length = params["length"] or 10

    local progressbar_char = "█"
    local progressbar_empty = "░"

    local message = module.custom_print(msg, img, clr)
    local progress = 0

    --// print module \\--
    local progressbar_module = {}

    progressbar_module.update_message = function(_message, _image, _color)
        message.update_message({
            message = _message,
            image = _image,
            color = _color,
            update_timestamp = false
        })
    end

    progressbar_module.update_progress = function(_progress)
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

        message.update_message(msg .. " [" .. progressbar_string .. "] " .. normalized_progress .. "%", img, clr, false)
    end

    progressbar_module.update_message_with_progress = function(_message, _progress)
        _progress = _progress or progress

        msg = _message
        progressbar_module.update_progress(_progress)
    end

    progressbar_module.cleanup = message.cleanup

    return progressbar_module
end

--// update loop \\--
module.render_stepped_conn = RunService.RenderStepped:Connect(function()
    if #module.custom_prints == 0 then return end

    -- update client log --
    local vis, log = _internal_get_console()
    if not vis then return end
    ClientLog = log;

    -- prints update --
    for _, print_data in pairs(module.custom_prints) do
        print_data.update()
    end
end)

-- return the module --
global_env.console_utils = module
return module
