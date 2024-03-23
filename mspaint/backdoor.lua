repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local mainui = player.PlayerGui:WaitForChild("MainUI")
local maingame = mainui.Initiator.Main_Game

local camera = workspace.CurrentCamera
local remote_folder = ReplicatedStorage.RemotesFolder

local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = "mspaint > Doors (the backdoor) | "..player.DisplayName,
    Center = true,
    AutoShow = true,
    TabPadding = 5.5,
    MenuFadeTime = 0
})

local ESPTable = {
    Objectives = {},
    Wardrobe = {},
    Entity = {},
    Doors = {}
}

local connections = {}

local temp = {
    timerhastenotified = false
}

local notification_msg = {
    BackdoorLookman = "Lookman spawned, look away!",
    BackdoorRush = "Blitz has spawned, quick find a hiding spot!"
}

local clock_screengui = Instance.new("ScreenGui") do
    local Frame = Instance.new("Frame")
    local TextLabel = Instance.new("TextLabel")
    local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

    clock_screengui.Parent = ReplicatedStorage
    clock_screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Frame.Parent = clock_screengui
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Library.MainColor
    Frame.BorderColor3 = Library.AccentColor
    Frame.BorderSizePixel = 2
    Frame.Position = UDim2.new(0.5, 0, 0.8, 0)
    Frame.Size = UDim2.new(0, 200, 0, 75)

    TextLabel.Parent = Frame
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Font = Enum.Font.Code
    TextLabel.Text = "Not started"
    TextLabel.TextColor3 = Library.FontColor
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14
    TextLabel.TextWrapped = true

    UITextSizeConstraint.Parent = TextLabel
    UITextSizeConstraint.MaxTextSize = 35
end

-- Functions
function notify(msg, t)
    Library:Notify(msg, t or 5)

    task.spawn(function()
        local sound = Instance.new("Sound", ReplicatedStorage)
        sound.SoundId = "rbxassetid://4590657391"
        sound.Volume = 2
        sound:Play()

        sound.Ended:Wait()
        sound:Destroy()
    end)
end

function ESP(table)
    -- yall better not skid this 💀
    if typeof(table.Object) ~= "Instance" then assert("ESP function expected a Instance, not "..typeof(table.Object)) end
    if typeof(table.Text) ~= "string" then table.Text = "Unable to assign name\ndue to type error" end
    if typeof(table.Color) ~= "Color3" then table.Color = Color3.fromRGB(255,255,255) end

    local distanceFromPlayer = 0
    local colorOverride = table.Color
    local textOverride = table.Text

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = colorOverride
    Tracer.Thickness = 1
    Tracer.Transparency = 1

    function Create(Class, Properties)
        local _Instance = Class

        if type(Class) == "string" then
            _Instance = Instance.new(Class)
        end

        for Property, Value in next, Properties do
            _Instance[Property] = Value
        end

        return _Instance
    end

    local BillboardGui = Create("BillboardGui",{
        Size = UDim2.new(0, 1, 0, 1),
        MaxDistance = 2000,
        AlwaysOnTop = true,

        Parent = (table.Object:IsA("Model") and table.Object.PrimaryPart or table.Object)
    })

    local TextLabel = Create("TextLabel",{
        Text = textOverride,
        FontFace = Font.new("rbxassetid://11702779517"),
        TextColor3 = colorOverride,
        TextSize = 15,

        Size = UDim2.new(0, 1, 0, 1),
        Parent = BillboardGui
    })

    local Highlight
    if not table.entity then
        Highlight = Create("Highlight", {
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            OutlineColor = colorOverride,
            FillColor = colorOverride,
            FillTransparency = 0.5,
            OutlineTransparency = 0.25,
            Name = "_mspaintESP",

            Parent = table.Object
        })
    else
        Highlight = Create("CylinderHandleAdornment", {
            CFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(0, 1, 0)),
            Radius = (table.Object.PrimaryPart.Size.X) / 1.85,
            Height = (table.Object.PrimaryPart.Size.Y) * 1.5,

            Color3 = colorOverride,
            
            AlwaysOnTop = true,
            Transparency = 0.45,
            ZIndex = 10,
            Name = "_mspaintESP",

            Adornee = table.Object,
            Parent = table.Object
        })
    end

    local rsconnection
    local ret = {}

    function ret.setText(newText)
        textOverride = newText
    end

    function ret.setColor(color)
        colorOverride = color
    end

    function ret.getHiglightedInstance()
        return table.Object
    end

    function ret.getLine()
        return Tracer
    end

    function ret.delete()
        rsconnection:Disconnect()

        if BillboardGui then
            BillboardGui:Destroy()
        end

        if Highlight then
            Highlight:Destroy()
        end

        if Tracer then
            Tracer.Visible = false

            if Tracer.Remove then
                Tracer:Remove()
            elseif Tracer.Destroy then
                Tracer:Destroy()
            end
        end
    end

    rsconnection = RunService.RenderStepped:Connect(function()
        local pos = nil
        if table.Object:IsA("Model") then
            if (table.Object.PrimaryPart and table.Object.PrimaryPart.Position ~= nil) then
                pos = table.Object.PrimaryPart.Position
            else
                pos = table.Object:GetPivot().Position
            end
        else
            pos = table.Object.Position
        end

        if table.Object == nil or not table.Object:IsDescendantOf(workspace) or pos == nil then
            ret.delete()
        else
            distanceFromPlayer = math.floor(game:GetService("Players").LocalPlayer:DistanceFromCharacter(pos))

            TextLabel.TextColor3 = colorOverride
            if Toggles.distanceEspToggle and Toggles.distanceEspToggle.Value then
                TextLabel.Text = textOverride.."\n[ "..distanceFromPlayer.." ]"
            else
                TextLabel.Text = textOverride
            end
            Tracer.Color = colorOverride
            
            if Toggles.tracerEspToggle.Value then
                local Vector, OnScreen = camera:worldToViewportPoint(pos)

                if OnScreen then
                    Tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 1)
                    Tracer.To = Vector2.new(Vector.X, Vector.Y)
                    Tracer.Visible = true
                else
                    Tracer.Visible = false
                end
            else
                Tracer.Visible = false
            end

            if not table.entity then
                Highlight.FillColor = colorOverride
                Highlight.OutlineColor = colorOverride
                
                if game.Players.LocalPlayer.PlayerGui:WaitForChild("MainUI").Initiator.Main_Game.PromptService.Highlight.Adornee == table.Object or game.Players.LocalPlayer.PlayerGui:WaitForChild("MainUI").Initiator.Main_Game.PromptServiceHint.Highlight.Adornee == table.Object then
                    Highlight.Adornee = nil
                    Highlight.Adornee = table.Object
                end
            else
                Highlight.Color3 = colorOverride
            end
        end
    end)

    return ret
end

function format_timer(seconds)
	local minutes = seconds / 60
	local seconds = seconds % 60

    -- too lazy to do string.format
    if seconds < 10 then
        seconds = "0" .. tostring(seconds)
    end
	
	return tostring(math.floor(minutes)) .. ":" .. tostring(seconds)
end

-- people didnt check console so uh yea
--assert(ReplicatedStorage.GameData.Floor.Value == "Backdoor", "You are not in the backdoor gamemode")
if not ReplicatedStorage.GameData.Floor.Value == "Backdoor" then
    notify("You are not in the backdoor gamemode")
    return
end


-- Tabs
local player_tab = Window:AddTab("Player")
local exploit_tab = Window:AddTab("Exploits")
local visual_tab = Window:AddTab("Visuals")
local config_tab = Window:AddTab("Config")

-- Group boxes
local movement_group = player_tab:AddLeftGroupbox("Movement")
local bypass_group = exploit_tab:AddLeftGroupbox("Removal")
local main_visual_group = visual_tab:AddRightGroupbox("Visuals")
local esp_group = visual_tab:AddLeftGroupbox("ESP")
local esp_settings_group = visual_tab:AddLeftGroupbox("ESP Settings")
local config_group = config_tab:AddLeftGroupbox("Menu")

movement_group:AddSlider("speed_boost", {
    Text = "Speed Boost",
    Min = 0,
    Max = 7,
    Default = 0,
    Rounding = 1,
    Compact = true
})

bypass_group:AddToggle("anti_jumpscare", {
    Text = "Anti Haste Jumpscare",
    Default = false,
    Tooltip = "Prevents you from from getting jumpscared by the haste"
})

bypass_group:AddToggle("anti_vacuum", {
    Text = "Anti Vacuum",
    Default = false,
    Tooltip = "Prevents you from from dying to fake doors"
})

bypass_group:AddToggle("anti_lookman", {
    Text = "Anti Lookman",
    Default = false,
    Tooltip = "Prevents you from from dying to lookman"
})

main_visual_group:AddToggle("haste_clock", {
    Text = "Haste Clock",
    Default = false,
    Tooltip = "Enables clock indicating how much time is left in the game",
})

main_visual_group:AddToggle("fullbright", {
    Text = "Fullbright",
    Default = false,
    Tooltip = "enables fullbright",
})

main_visual_group:AddToggle("notify_entity", {
    Text = "Notify Entity",
    Default = false,
    Tooltip = "Notifies when entities spawn",
})

main_visual_group:AddSlider("fov_slider", {
    Text = "Field of view",
    Min = 30,
    Max = 120,
    Default = 70,
    Rounding = 1,
    Compact = false
})

esp_group:AddToggle("objective_esp", {
    Text = "Objective ESP",
    Default = false,
    Tooltip = "Shows ESP on levers & keys",
})

esp_group:AddToggle("door_esp", {
    Text = "Door ESP",
    Default = false,
    Tooltip = "Shows ESP on Doors",
})

esp_group:AddToggle("wardrobe_esp", {
    Text = "Wardrobe ESP",
    Default = false,
    Tooltip = "Shows ESP on wardrobes",
})

esp_group:AddToggle("entity_esp", {
    Text = "Entity ESP",
    Default = false,
    Tooltip = "Shows ESP on entities",
})

esp_settings_group:AddToggle("distanceEspToggle", {
    Text = "Distance ESP",
    Default = false,
    Tooltip = "Shows distance from player to object"
})

esp_settings_group:AddToggle("tracerEspToggle", {
    Text = "Tracer ESP",
    Default = false,
    Tooltip = "Shows a line from the object to the center of the screen"
})

local haste = ReplicatedStorage.FloorClientStuff.ClientRemote.Haste
Toggles.anti_jumpscare:OnChanged(function(value)
    if value then
        haste.Parent = game:GetService("CoreGui")
    else
        haste.Parent = ReplicatedStorage.FloorClientStuff.ClientRemote
    end
end)

Toggles.fullbright:OnChanged(function(value)
    if value then
        temp.ambient = game.Lighting.Ambient
        game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)

        connections["fullbright"] = game.Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
            temp.ambient = game.Lighting.Ambient
            game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        end)
    else
        if connections["fullbright"] then
            connections["fullbright"]:Disconnect()
            connections["fullbright"] = nil
        end

        game.Lighting.Ambient = temp.ambient or Color3.fromRGB(0,0,0)
    end
end)

local timer = ReplicatedStorage.FloorClientStuff.DigitalTimer
local timerlabel = clock_screengui.Frame.TextLabel

connections["HasteTimer"] = timer:GetPropertyChangedSignal("Value"):Connect(function()
    if Toggles.haste_clock.Value then
        timerlabel.Text = format_timer(timer.Value)
    end
    
    if Toggles.notify_entity.Value then
        if timer.Value == 0 and not temp["timerhastenotified"] then
            notify("Haste has spawned, please find a lever ASAP")
            temp["timerhastenotified"] = true
        elseif timer.Value ~= 0 and temp["timerhastenotified"] then
            temp["timerhastenotified"] = false
        end
    end
end)

Toggles.haste_clock:OnChanged(function(value)
    if value then
        clock_screengui.Parent = gethui() or game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
    else
        clock_screengui.Parent = ReplicatedStorage
    end    
end)

local esp_target_names = {
    Entity = {"BackdoorLookman", "BackdoorRush"},
}

function handle_esp(obj, options)
    local is_toggle_callback = options.is_toggle_callback ~= nil
    local is_descendant = options.is_descendant_connection ~= nil
    local is_entity = options.is_entity_connection ~= nil
    
    local function add_esp(esp_obj, esp_options)
        --[[
            esp_options = {
                Text = "Lever",
                Color = Color3.fromRGB(50, 168, 82),
                Table = "Levers"
            }
        ]]
    
        local highlight = esp_obj:FindFirstChildOfClass("Highlight")
        local key_name = esp_options.Table
    
        if highlight and highlight.Name == "_mspaintESP" then
            return
        end
    
        local ESP_Object = ESP({
            Object = esp_obj,
            Text = esp_options.Text,
            Color = esp_options.Color,

            entity = (esp_options.entity or false)
        })
        
        ESPTable[key_name][#ESPTable[key_name]+1] = ESP_Object
    end

    local function prettify_module_name(name)
        return name:gsub("Obtain",""):gsub("Timer","")
    end

    local function apply_room_esp(room)
        local Assets = room:WaitForChild("Assets",3)

        -- we can also iterate over the children and check if they have the attribute "LoadModule"
        for i,v in pairs(Assets:GetChildren()) do
            if v:IsA("Model") and v:GetAttribute("LoadModule") ~= nil and Toggles.objective_esp.Value then
                local esp_text = prettify_module_name(v:GetAttribute("LoadModule"))

                if esp_text == "Wardrobe" then
                    continue
                end

                add_esp(v, {
                    Text = esp_text,
                    Color = Color3.fromRGB(50, 168, 82),
                    
                    Table = "Objectives"
                })
            end
        end

        if Toggles.door_esp.Value then
            local Door = room:WaitForChild("Door",1)

            add_esp(Door.Door, {
                Text = "Door",
                Color = Color3.new(1, 0.941176, 0),
                
                Table = "Doors"
            })
        end

        if Toggles.wardrobe_esp.Value then
            for i,v in pairs(Assets:GetChildren()) do
                if v.Name == "Backdoor_Wardrobe" then
                    add_esp(v, {
                        Text = "Wardrobe",
                        Color = Color3.fromRGB(160,190,255),
                        
                        Table = "Wardrobe"
                    })
                end
            end
        end

        if Toggles.wardrobe_esp.Value then
            for i,v in pairs(Assets:GetChildren()) do
                if v.Name == "Backdoor_Wardrobe" then
                    add_esp(v, {
                        Text = "Wardrobe",
                        Color = Color3.fromRGB(160,190,255),
                        
                        Table = "Wardrobe"
                    })
                end
            end
        end
    end

    local function apply_descendant_esp(descendant)
        if Toggles.door_esp.Value and descendant.Name == "Door" and descendant:IsA("Model") then
            descendant:WaitForChild("Door", math.huge)
            descendant.Door:WaitForChild("Hit", math.huge)

            add_esp(descendant.Door, {
                Text = "Door",
                Color = Color3.new(1, 0.941176, 0),
                
                Table = "Doors"
            })

            return
        end

        if Toggles.wardrobe_esp.Value and descendant.Name == "Backdoor_Wardrobe" then
            descendant:WaitForChild("Main", math.huge)

            add_esp(descendant, {
                Text = "Wardrobe",
                Color = Color3.fromRGB(160,190,255),
                
                Table = "Wardrobe"
            })

            return
        end

        local is_a_objective = descendant:GetAttribute("LoadModule") ~= nil
        if Toggles.objective_esp.Value and is_a_objective then
            descendant:WaitForChild("Hitbox", math.huge)
            
            add_esp(descendant, {
                Text = prettify_module_name(descendant:GetAttribute("LoadModule")),
                Color = Color3.fromRGB(50, 168, 82),
                
                Table = "Objectives"
            })

            return
        end
    end

    local function apply_entity_esp(entity)
        if not table.find(esp_target_names.Entity, entity.Name) then return end

        if Toggles.notify_entity.Value then
            notify(notification_msg[entity.Name], entity)
        end

        local primary = entity:WaitForChild("Core", 1.5) or entity:WaitForChild("Main", 1.5)
        if Toggles.entity_esp.Value and primary then
            add_esp(entity, {
                Text = entity.Name,
                Color = Color3.fromRGB(255, 0, 0),
                
                Table = "Entity",
                entity = true
            })
        end
    end

    if is_toggle_callback then
        apply_room_esp(obj)
    end

    if is_descendant then
        apply_descendant_esp(obj)
    end

    if is_entity then
        apply_entity_esp(obj)
    end
end

Toggles.objective_esp:OnChanged(function(value)
    if value then
        for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
            handle_esp(v, {
                is_toggle_callback = true
            })
        end
    else
        for _, ESP in pairs(ESPTable.Objectives) do
            ESP.delete()
        end
    end
end)

Toggles.door_esp:OnChanged(function(value)
    if value then
        for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
            handle_esp(v, {
                is_toggle_callback = true
            })
        end
    else
        for _, ESP in pairs(ESPTable.Doors) do
            ESP.delete()
        end
    end
end)

Toggles.wardrobe_esp:OnChanged(function(value)
    if value then
        for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
            handle_esp(v, {
                is_toggle_callback = true
            })
        end
    else
        for _, ESP in pairs(ESPTable.Wardrobe) do
            ESP.delete()
        end
    end
end)

Toggles.entity_esp:OnChanged(function(value)
    if value then
        for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
            handle_esp(v, {
                is_toggle_callback = true
            })
        end
    else
        for _, ESP in pairs(ESPTable.Entity) do
            ESP.delete()
        end
    end
end)

local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
connections["main"] = RunService.RenderStepped:Connect(function()

    require(maingame).fovtarget = Options.fov_slider.Value

    if player:GetAttribute("Alive") then
        humanoid:SetAttribute("SpeedBoostBehind", Options.speed_boost.Value)
    end

    if workspace:FindFirstChild("BackdoorLookman") and Toggles.anti_lookman.Value then
        remote_folder.MotorReplication:FireServer(0,-90,0, false)
    end

end)

connections["esp_connection"] = workspace.CurrentRooms.DescendantAdded:Connect(function(descendant)
    local is_in_parts = (descendant:FindFirstAncestorOfClass("Folder") ~= nil and descendant:FindFirstAncestorOfClass("Folder").Name == "Parts")
    local is_parts = descendant.Name == "Parts"
    local is_in_assets = descendant.Parent.Name == "Assets" and descendant.Parent:IsA("Folder")

    if (is_parts or is_in_parts) or (not is_in_assets and not descendant.Name == "Door") then return end
    handle_esp(descendant, {
        is_descendant_connection = true
    })
end)

connections["entity_connection"] = workspace.ChildAdded:Connect(function(entity)
    handle_esp(entity, {
        is_entity_connection = true
    })
end)

connections["exploit_childadded"] = workspace.CurrentRooms.ChildAdded:Connect(function(room)
    
    -- anti vacuum
    if room:WaitForChild("ClosetSpace", 2) and Toggles.anti_vacuum.Value then
        local fake_doors = {}
        for i,v in pairs(room:GetChildren()) do
            if v.Name == "ClosetSpace" then
                fake_doors[#fake_doors+1] = v
            end
        end

        local function handle_door(door)
            door:WaitForChild("Collision")
                
            while not Library.Unloaded and door ~= nil and door:IsDescendantOf(workspace) do
                door.Collision.CanTouch = not Toggles.anti_vacuum.Value
                door.Collision.CanCollide = not Toggles.anti_vacuum.Value
                task.wait()
            end

            if Library.Unloaded and door and door:IsDescendantOf(workspace) then
                door.Collision.CanTouch = true
                door.Collision.CanCollide = true
            end
        end

        for _,door in pairs(fake_doors) do
            task.spawn(handle_door, door)
        end
    end


end)

for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
    handle_esp(v, {
        is_toggle_callback = true
    })
end

Library:OnUnload(function()
    for _, ESPCategory in pairs(ESPTable) do
        for _, ESP in pairs(ESPCategory) do
            ESP.delete()
        end
    end

    for i, connections in pairs(connections) do
        connections:Disconnect()
    end

    game.Lighting.Ambient = temp.ambient or Color3.fromRGB(0,0,0)

    table.clear(connections)

    if Toggles.anti_jumpscare.Value then
        haste.Parent = ReplicatedStorage.FloorClientStuff.ClientRemote
    end

    clock_screengui:Destroy()
    Library.Unloaded = true
end)

config_group:AddButton("Unload", function()
    Library:Unload()
end)

config_group:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind"})
Library.ToggleKeybind = Options.MenuKeybind

config_group:AddToggle("Keybinds", {
    Text = "Keybinds",
    Default = false,
    Tooltip = "Displays keybinds",

    Callback = function(val)
        Library.KeybindFrame.Visible = val
    end
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ "Keybinds" })

ThemeManager:SetFolder("mspaint")
SaveManager:SetFolder("mspaint/backdoors")

SaveManager:BuildConfigSection(config_tab)

ThemeManager:ApplyToTab(config_tab)

SaveManager:LoadAutoloadConfig()

notify("mspaint v1.0.2 loaded successfully!\nMade by upio (www.upio.dev)", 6)
print("https://www.upio.dev/nick/nickeh")
