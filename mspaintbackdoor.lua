repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local camera = workspace.CurrentCamera

local remote_folder = ReplicatedStorage.RemotesFolder

assert(ReplicatedStorage.GameData.Floor.Value == "Backdoor", "You are not in the backdoor gamemode")

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
    Levers = {},
    Doors = {},
    Key = {},
    Wardrobe = {},
    Entity = {}
}

local connections = {}

local temp = {}

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
    Library:Notify(msg, t or 2)

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

-- Tabs
local visual_tab = Window:AddTab("Visuals")
local config_tab = Window:AddTab("Config")

-- Group boxes
local main_visual_group = visual_tab:AddRightGroupbox("Visuals")
local esp_group = visual_tab:AddLeftGroupbox("ESP")
local esp_settings_group = visual_tab:AddLeftGroupbox("ESP Settings")
local config_group = config_tab:AddLeftGroupbox("Menu")

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

esp_group:AddToggle("lever_esp", {
    Text = "Lever ESP",
    Default = false,
    Tooltip = "Shows ESP on levers",
})

esp_group:AddToggle("key_esp", {
    Text = "Key ESP",
    Default = false,
    Tooltip = "Shows ESP on keys",
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

Toggles.fullbright:OnChanged(function(value)
    if value then
        temp.ambient = game.Lighting.Ambient
        game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)

        connections["fullbright"] = game.Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
            temp.ambient = game.Lighting.Ambient
            game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        end)
    else
        game.Lighting.Ambient = temp.ambient or Color3.fromRGB(0,0,0)

        if connections["fullbright"] then
            connections["fullbright"]:Disconnect()
            connections["fullbright"] = nil
        end
    end
end)

Toggles.haste_clock:OnChanged(function(value)
    if value then
        clock_screengui.Parent = gethui() or game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
        
        task.spawn(function()
        
            repeat task.wait() until ReplicatedStorage.FloorClientStuff.ScaryStartsNow.Value or not Toggles.haste_clock.Value
            
            if not Toggles.haste_clock.Value then
                clock_screengui.Parent = ReplicatedStorage
                return
            end

            local timer = ReplicatedStorage.FloorClientStuff.DigitalTimer
            local timerlabel = clock_screengui.Frame.TextLabel

            timerlabel.Text = format_timer(timer.Value)
            local conn = timer:GetPropertyChangedSignal("Value"):Connect(function()
                timerlabel.Text = format_timer(timer.Value)
            end)
            
            connections["HasteTimerClock"] = conn
        end)
    else
        clock_screengui.Parent = ReplicatedStorage

        if connections["HasteTimerClock"] then
            connections["HasteTimerClock"]:Disconnect()
            connections["HasteTimerClock"] = nil
        end
    end    
end)

Toggles.lever_esp:OnChanged(function(value)
    if value then
        connections["lever_esp"] = workspace.CurrentRooms.DescendantAdded:Connect(function(descendant)
            local is_in_parts = (descendant:FindFirstAncestorOfClass("Folder") ~= nil and descendant:FindFirstAncestorOfClass("Folder").Name == "Parts")
            if descendant.Name == "Parts" or is_in_parts then return end
            
            if descendant.Name == "TimerLever" then
                local highlight = descendant:FindFirstChildOfClass("Highlight")
                if highlight and highlight.Name == "_mspaintESP" then
                    return
                end

                local ESP = ESP({
                    Object = descendant,
                    Text = "Lever",
                    Color = Color3.fromRGB(255, 0, 0)
                })

                table.insert(ESPTable.Levers, ESP)
            end
        end)

        for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
            handle_esp(v, {leveresp = true})
        end

    else
        for _, ESP in pairs(ESPTable.Levers) do
            ESP.delete()
        end

        if connections["lever_esp"] then
            connections["lever_esp"]:Disconnect()
            connections["lever_esp"] = nil
        end
    end
end)

Toggles.key_esp:OnChanged(function(value)
    if value then
        for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
            handle_esp(v)
        end
    else
        for _, ESP in pairs(ESPTable.Key) do
            ESP.delete()
        end
    end
end)

Toggles.door_esp:OnChanged(function(value)
    if value then
        for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
            handle_esp(v)
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
            handle_esp(v)
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
            handle_esp(v)
        end
    else
        for _, ESP in pairs(ESPTable.Entity) do
            ESP.delete()
        end
    end
end)

function handle_esp(room,table)
    local Assets = room:WaitForChild("Assets",3)
    if not Assets then
        -- Entity Notify + ESP
        local entity = room -- so its easier to read
        if not (entity.Name == "BackdoorLookman" or entity.Name == "BackdoorRush") then return end

        if Toggles.entity_esp.Value then
            local EntityESP = ESP({
                Object = entity,
                Text = entity.Name,
                Color = Color3.fromRGB(255, 0, 0),
                entity = true
            })

            table.insert(ESPTable.Entity, EntityESP)
        end

        if Toggles.notify_entity.Value then
            notify(notification_msg[entity.Name], entity)
        end

        return
    end

    -- we can also iterate over the children and check if they have the attribute "LoadModule"
    -- if they do then thats something the player can interact with but im too lazy to do that

    if table ~= nil and table.leveresp then
        task.spawn(function()
            local TimerLever = Assets:WaitForChild("TimerLever",3)

            if TimerLever then
                local highlight = TimerLever:FindFirstChildOfClass("Highlight")
                if highlight and highlight.Name == "_mspaintESP" then
                    return
                end

                local TimerESP = ESP({
                    Object = TimerLever,
                    Text = "Lever",
                    Color = Color3.fromRGB(50, 168, 82)
                })

                table.insert(ESPTable.Levers, TimerESP)
            end
        end)
    end

    if Toggles.key_esp.Value and room:GetAttribute("RequiresKey") then
        task.spawn(function()
            local Key = Assets:WaitForChild("KeyObtain")
            
            if Key then
                local highlight = Key:FindFirstChildOfClass("Highlight")
                if highlight and highlight.Name == "_mspaintESP" then
                    return
                end

                local KeyESP = ESP({
                    Object = Key,
                    Text = "Key",
                    Color = Color3.fromRGB(50, 168, 82)
                })
    
                table.insert(ESPTable.Key, KeyESP)
            end
        end)
    end

    if Toggles.door_esp.Value then
        task.spawn(function()
            local Door = room:WaitForChild("Door",1)

            if Door then
                Door:WaitForChild("Door",1)

                local highlight = Door.Door:FindFirstChildOfClass("Highlight")
                if highlight and highlight.Name == "_mspaintESP" then
                    return
                end

                local DoorESP = ESP({
                    Object = Door.Door,
                    Text = "Door",
                    Color = Color3.new(1, 0.941176, 0)
                })

                table.insert(ESPTable.Doors, DoorESP)
            end
        end)
    end

    if Toggles.wardrobe_esp.Value then
        -- task.spawn cuz if i do return it will stop the whole function
        task.spawn(function()
            local Wardrobe = Assets:WaitForChild("Backdoor_Wardrobe",1)

            if not Wardrobe then return end
            
            local highlight = Wardrobe:FindFirstChildOfClass("Highlight")
            if not (highlight and highlight.Name == "_mspaintESP") then
                local WardrobeESP = ESP({
                    Object = Wardrobe,
                    Text = "Wardrobe",
                    Color = Color3.fromRGB(160,190,255)
                })
    
                table.insert(ESPTable.Wardrobe, WardrobeESP)
            end

            for i,v in pairs(Assets:GetChildren()) do
                if v.Name == "Backdoor_Wardrobe" then
                    local highlight = v:FindFirstChildOfClass("Highlight")
                    if highlight and highlight.Name == "_mspaintESP" then
                        continue
                    end

                    local WardrobeESP = ESP({
                        Object = v,
                        Text = "Wardrobe",
                        Color = Color3.fromRGB(160,190,255)
                    })

                    table.insert(ESPTable.Wardrobe, WardrobeESP)
                end
            end            
        end)
    end
end

connections["childadded"] = workspace.ChildAdded:Connect(function(room)
    handle_esp(room)
end)

connections["espchildadded"] = workspace.CurrentRooms.ChildAdded:Connect(function(room)
    handle_esp(room)
end)

for i,v in pairs(workspace.CurrentRooms:GetChildren()) do
    handle_esp(v)
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