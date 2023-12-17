repeat task.wait() until game:IsLoaded()
local SCRIPT_START_TIME = tick()

-- Script Vars
local ScriptVersion = "1.0.0"
local GameScript = "Example"
local ScriptTitle = "AlpHub (v"..ScriptVersion..") | "..GameScript.." > "..game:GetService("Players").LocalPlayer.DisplayName

-- exploit vars
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local getassetfunc = getcustomasset or getsynasset
local isnetowner = isnetworkowner or function(part) return part.ReceiveAge == 0 end

-- Vars
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- GUI
local Repository = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(Repository .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(Repository .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(Repository .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = ScriptTitle,
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    TabPadding = 0,
    MenuFadeTime = 0
})

-- Main Script Variables
local Script = {
    Connections = {},
    Functions = {
        Notify = function(message,timeArg)
            local notif = Instance.new("Sound")
            notif.Parent = game:GetService("SoundService")
            notif.SoundId = "rbxassetid://4590657391"
            notif.Volume = 1
            notif.PlayOnRemove = true
            notif:Destroy()
        
            Library:Notify(message, timeArg or 5)
        end,
        Log = function(message)
            print("Alphub (v"..ScriptVersion..") >",message)
        end,
        DisconnectConnection = function(RBXScriptConnection)
			if RBXScriptConnection == nil then return end
			if RBXScriptConnection and typeof(RBXScriptConnection) == "RBXScriptConnection" then
				RBXScriptConnection:Disconnect()
				RBXScriptConnection = nil
			end
		end
    },
    GUIElements = {
        Tabs = {
            Config = Window:AddTab('Config')
        },
        Groupboxes = {Tabs={},TabBoxes={}},
        Toggles = {},
        Keybinds = {},
        Colorpickers = {},
        Misc = {}
    }
}

Script.Functions.Log("Loading...")

-- Connections
function onDeath()

end

function onCharacterAdded(chr)
    character = chr

    Script.Functions.DisconnectConnection(Script.Connections.Died)
    Script.Connections.Died = character:WaitForChild("Humanoid").Died:Connect(onDeath)
end

Script.Connections.CharacterAdded = player.CharacterAdded:Connect(onCharacterAdded)
Script.Connections.Died = character:WaitForChild("Humanoid").Died:Connect(onDeath)

-- Watermark
Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('Alphub ('..ScriptVersion..') | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

-- Savemanager
Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    for i,v in pairs(Script.Connections) do
        Script.Functions.DisconnectConnection(v)
    end

    print('Unloaded!')
    Library.Unloaded = true
end)

local MenuGroup = Script.GUIElements.Tabs.Config:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

MenuGroup:AddToggle("ShowKeybinds", {Text = "Show Keybinds Menu", Default = false})
Toggles.ShowKeybinds:OnChanged(function(Value) Library.KeybindFrame.Visible = Value end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

ThemeManager:SetFolder('Alphub')
SaveManager:SetFolder('Alphub/'..GameScript)

SaveManager:BuildConfigSection(Script.GUIElements.Tabs.Config)

ThemeManager:ApplyToTab(Script.GUIElements.Tabs.Config)

SaveManager:LoadAutoloadConfig()

Script.Functions.Log("Successfully loaded Alphub in "..(tick() - SCRIPT_START_TIME).." seconds!")
