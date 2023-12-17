repeat task.wait() until game:IsLoaded()
local SCRIPT_START_TIME = tick()

-- Script Vars
local ScriptLoaded = false

local ScriptVersion = "1.0.0"
local GameScript = "DOORS"
local ScriptTitle = "AlpHub (v"..ScriptVersion..") | "..GameScript.." > "..game:GetService("Players").LocalPlayer.DisplayName

-- exploit vars
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local getassetfunc = getcustomasset or getsynasset
local isnetowner = isnetworkowner or function(part) return part.ReceiveAge == 0 end

-- Vars
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer
local isPlayerDead = false
local character = player.Character or player.CharacterAdded:Wait()
local collision = character:WaitForChild("Collision")

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
		end,
        PrettyEntityName = function(EntityInstance)
            if EntityInstance == nil then return end
            if typeof(EntityInstance) ~= "Instance" then return end
            
            local ignorePrettyNameCheck = {"A60","A90","Eyes","JeffTheKiller"}

            local Name = EntityInstance.Name:gsub("Moving",""):gsub("New",""):gsub("TheKiller","")
            local PrimaryName = EntityInstance.PrimaryPart.Name:gsub("Moving",""):gsub("New",""):gsub("TheKiller","")

            if table.find(ignorePrettyNameCheck,Name) then
                return Name
            end

            if Name ~= PrimaryName then
                return PrimaryName
            end

			return Name
		end
    },
    GUIElements = {
        Tabs = {},
        Groupboxes = {Tabs={},TabBoxes={}},
        Toggles = {}
    }
}

Script.Functions.Log("Loading...")
--[[
    Script UI Code
]]

-- Tabs
Script.GUIElements.Tabs.Main = Window:AddTab('Main')

-- Tabboxes
Script.GUIElements.Groupboxes.TabBoxes.Automation = Script.GUIElements.Tabs.Main:AddLeftTabbox()
Script.GUIElements.Groupboxes.TabBoxes.Player = Script.GUIElements.Tabs.Main:AddLeftTabbox()

-- Tabbox Tabs
Script.GUIElements.Groupboxes.Tabs.Automation = Script.GUIElements.Groupboxes.TabBoxes.Automation:AddTab('Automation')
Script.GUIElements.Groupboxes.Tabs.Player = Script.GUIElements.Groupboxes.TabBoxes.Player:AddTab('Player')

-- Automation Tab
Script.GUIElements.Toggles.InstantInteract = Script.GUIElements.Groupboxes.Tabs.Automation:AddToggle('InstantInteractToggle', {
    Text = 'Instant Interact',
    Default = false,
    Tooltip = 'Allows you to interact with no delay'
})

Script.GUIElements.Toggles.Godmode = Script.GUIElements.Groupboxes.Tabs.Player:AddToggle('GodmodeToggle', {
    Text = 'Godmode & Noclip Bypass',
    Default = false,
    Tooltip = 'Makes you invincible, but invisible to others'
})

--[[
    Script Code
]]
Script.GUIElements.Toggles.Godmode:OnChanged(function(Value)
    if not ScriptLoaded or isPlayerDead then return end
    collision.CanCollide = not Value

    if Value then
        collision.Position = collision.Position - Vector3.new(0,7.5,0)
    else
        collision.Position = collision.Position + Vector3.new(0,7.5,0)
    end
end)

-- Connections
Script.Connections.PromptShown = ProximityPromptService.PromptShown:Connect(function(Prompt)
    if not ScriptLoaded or isPlayerDead then return end
    if not Prompt:GetAttribute("OldPromptTime") then Prompt:SetAttribute("OldPromptTime", Prompt.HoldDuration) end

    if Script.GUIElements.Toggles.InstantInteract.Value then
        Prompt.HoldDuration = 0
    end
end)

Script.Connections.PromptHidden = ProximityPromptService.PromptHidden:Connect(function(Prompt)
    if not ScriptLoaded or isPlayerDead then return end

    if Script.GUIElements.Toggles.InstantInteract.Value then
        Prompt.HoldDuration = Prompt:GetAttribute("OldPromptTime")
    end
end)

-- Death Connections
function onDeath()
    isPlayerDead = true
end

function onCharacterAdded(chr)
    isPlayerDead = false
    character = chr
    collision = chr:WaitForChild("Collision")

    Script.Functions.DisconnectConnection(Script.Connections.Died)
    Script.Connections.Died = character:WaitForChild("Humanoid").Died:Connect(onDeath)
end

Script.Connections.CharacterAdded = player.CharacterAdded:Connect(onCharacterAdded)
Script.Connections.Died = character:WaitForChild("Humanoid").Died:Connect(onDeath)

-- Watermark
Script.GUIElements.Tabs.Config = Window:AddTab('Config')
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

    for i,v in pairs(Toggles) do
        v:SetValue(false)
    end

    Script.Functions.Log('Unloaded!')
    ScriptLoaded = false
    Library.Unloaded = true
end)

local MenuGroup = Script.GUIElements.Tabs.Config:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'Delete', NoUI = true, Text = 'Menu keybind' })

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

ScriptLoaded = true

local ScriptEnd = tick()
local ScriptTime = (math.floor((ScriptEnd - SCRIPT_START_TIME)*100))/100
Script.Functions.Log("Successfully loaded Alphub in "..ScriptTime.." seconds!")
Script.Functions.Notify("Successfully loaded Alphub in "..ScriptTime.." seconds!")
