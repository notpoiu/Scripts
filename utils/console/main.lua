--[[
    ©️ 2024-2025 upio

    Console Utils, a utility made to help with logging dynamic messages in roblox console.
    https://www.upio.dev/
    https://www.mspaint.cc/

    Please do not redistribute or claim the code as your own.
    However you may use it anywhere without any credits (but credits are appreciated <3)
--]]

local global_env = (getgenv and getgenv()) or shared or _G or {}
if global_env["console_utils"] then return global_env.console_utils end

--// services \\--
local cloneref = (cloneref or clonereference or function(instance: any) return instance end)
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

--// module table \\--
local MAX_LINES = 2048 --// taken from corescripts roblox repo
local library = {
    custom_prints = {};
    render_stepped_conn = nil;
}

--// variables \\--
local ClientLog = nil;

if not global_env._console_message_counter then
    global_env._console_message_counter = 3000
end

--// functions \\--
function _find_first_child(root, paths)
    local instance = root

    for _, path in ipairs(paths) do
        instance = instance:FindFirstChild(path)
        if not instance then
            return false, nil
        end
    end

    return true, instance
end

function _internal_get_guid()
    global_env._console_message_counter = global_env._console_message_counter + 1
    return tostring(global_env._console_message_counter) .. tostring(tick())
end

function _internal_get_console()
    return _find_first_child(CoreGui, { "DevConsoleMaster", "DevConsoleWindow", "DevConsoleUI", "MainView", "ClientLog" })
end

--// module functions \\--
function library.custom_print(...)
    local custom_print = {
        message = "",
        image = "",
        color = Color3.fromRGB(255, 255, 255),
        timestamp = os.date("%H:%M:%S"),
        UMID = _internal_get_guid()
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

    --// for main loop \\--
    local logData = nil;
    local logName = nil;
    local logCooldown = false;

	--// insert into prints table, also cut old prints if over max lines \\--
	while #library.custom_prints > MAX_LINES do table.remove(library.custom_prints, 1); end
    table.insert(library.custom_prints, custom_print)

    custom_print.update = function(ClientLogChildren)
        if not ClientLog then return end
        
        --// Get the instance \\--
        if not logName then
            if logCooldown then return end
            logCooldown = true;

            for _, logFrame in ClientLogChildren do
				local msgInst = logFrame:FindFirstChild("msg")
                if not (msgInst and string.match(msgInst.Text, tostring(custom_print.UMID) .. "$")) then continue end

                logName = logFrame.Name;
                break;
            end

            task.delay(math.random() / 5, function() logCooldown = false; end)
            return;
        end

        if not (logData and logData.frame and logData.frame.Parent) then
            logData = nil;

            local logFrame = ClientLog:FindFirstChild(logName);
            if not logFrame then return end

            local msgInst, imgInst = logFrame:FindFirstChild("msg"), logFrame:FindFirstChild("image");
            if not (msgInst and imgInst) then return end

            if not string.match(msgInst.Text, tostring(custom_print.UMID) .. "$") then return end

            logData = {
                frame = logFrame;
                msg = msgInst;
                img = imgInst;
            };
            return
        end

        --// Update the message \\--
        if logData.msg then
            logData.msg.Text = custom_print.timestamp .. " -- " .. custom_print.message
            logData.msg.TextColor3 = custom_print.color
            logData.msg.TextWrapped = true
        end

        --// Update the image \\--
        if logData.img then
            logData.img.Image = custom_print.image
            logData.img.ImageColor3 = custom_print.color
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
                update_timestamp = data.update_timestamp
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

            if typeof(update) == "boolean" then
                update_timestamp = update
            end
        end

        if update_timestamp then
            custom_print.timestamp = os.date("%H:%M:%S")
        end
    end

    log_module.cleanup = function()
        for i, print_data in pairs(library.custom_prints) do
            if print_data.UMID == custom_print.UMID then
                table.remove(library.custom_prints, i)
                break
            end
        end

        custom_print.update = function() end
    end

    -- unique message id
    print(custom_print.UMID)
    return log_module
end

function library.custom_console_progressbar(params)
    if typeof(params) == "string" then
        params = {msg = params}
    end

    local msg = params["msg"] or params["message"]
    local clr = params["clr"] or params["color"]
    local img = params["img"] or params["image"]

    local progressbar_length = params["length"] or 10

    local progressbar_char = "█"
    local progressbar_empty = "░"

    local message = library.custom_print(msg, img, clr)
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

        for i = 1, 10 do
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
library.render_stepped_conn = RunService.RenderStepped:Connect(function()
    if #library.custom_prints == 0 then return end

    --// update client log \\--
    if not (ClientLog and ClientLog.Parent) then
        local exists, newClientLog = _internal_get_console()
        if not (exists and newClientLog) then return end

        ClientLog = newClientLog;
    end

    --// prints update \\--
	local ClientLogChildren = ClientLog:GetChildren()
    for _, print_data in next, library.custom_prints do
        print_data.update(ClientLogChildren)
    end
end)

--// return the module \\--
global_env.console_utils = library
return library
