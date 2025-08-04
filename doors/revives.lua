--// 
--// Revive Duper Script by upio
--// Method found by lolcat
--// 

--// Services
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local VirtualInputManager = Instance.new("VirtualInputManager")

--// Remotes
local RemotesFolder = ReplicatedStorage.RemotesFolder
local ReviveFriendEvent = RemotesFolder.ReviveFriend
local ObtainReviveEvent = RemotesFolder.ObtainGiftedRevive

--// Player Variables
local LocalPlayer = Players.LocalPlayer
local OtherPlayer

--// Game Data
local LatestRoom = ReplicatedStorage.GameData.LatestRoom
local Revives = LocalPlayer.PlayerGui.TopbarUI.Topbar.StatsTopbarHandler.StatModules.Revives.RevivesVal

--// Constants
local IsMainAccount = LocalPlayer.Name == AccountToDuplicateTo
local DuplicationCount = DuplicationAmount or 1000
local Title = IsMainAccount and "Revive Dupe Helper (Main Account)" or "Revive Dupe Helper (Alt Account)"
local PacketPrefix = "ReviveDupe_"

--// Dupe State stuff
local IsOtherAccountInitialized = false
local IsGiftingRevive = false

--// Communication (Thank you vynixu for this textchatservice method :steamhappy:)
local Communication = TextChatService.TextChannels.RBXGeneral

local function SendPacket(PacketName)
    local PacketData = `{PacketPrefix}{PacketName}`
    Communication:SendAsync("", PacketData)
    return PacketData
end

TextChatService.MessageReceived:Connect(function(message: TextChatMessage)
    local packetData = message.Metadata
    local textSource = message.TextSource

    if
        not packetData or not textSource or
        packetData:sub(1, #PacketPrefix) ~= PacketPrefix or
        textSource.UserId == LocalPlayer.UserId
    then
        return
    end
    
    local sender = Players:GetPlayerByUserId(textSource.UserId)
    local packetName = packetData:sub(#PacketPrefix + 1)

    if packetName == "Init" then
        if IsOtherAccountInitialized then
            return
        end

        IsOtherAccountInitialized = true
        OtherPlayer = sender
        
        -- Replicate to other client that this account has been initialized
        SendPacket("Init")

        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = `{sender.Name} initialized, starting dupe process...`,
            Duration = 5
        })
    end
    
    if not IsOtherAccountInitialized then
        return
    end

    if packetName == "SendReviveStandardToMe" then
        IsGiftingRevive = true

        if OtherPlayer:GetAttribute("Alive") == true then
            StarterGui:SetCore("SendNotification", {
                Title = Title,
                Text = "Waiting for the other account to die...",
                Duration = 5
            })

            OtherPlayer:GetAttributeChangedSignal("Alive"):Wait()
        end

        task.wait(2.5)
        ReviveFriendEvent:FireServer(OtherPlayer.Name)

        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = "Revive sent to alt account. Now rejoin a new game with your alt account.",
            Duration = 5
        })
    end
end)

--// Send a message to the other account to initialize
SendPacket("Init")

StarterGui:SetCore("SendNotification", {
    Title = Title,
    Text = "Waiting for other account to initialize...",
    Duration = 5
})

repeat task.wait() until IsOtherAccountInitialized

--// Functions
local function AttemptToKillLocalPlayer()
    if LatestRoom.Value == 0 then
        StarterGui:SetCore("SendNotification", {
            Title = "Revive Dupe Helper",
            Text = "Please open a door",
            Duration = 5
        })

        LatestRoom:GetPropertyChangedSignal("Value"):Wait()
    end

    if replicatesignal then
        replicatesignal(LocalPlayer.Kill)
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Revive Dupe Helper",
            Text = "Your executor does not support replicatesignal, please die manually",
            Duration = 5
        })
        LocalPlayer.Character.Humanoid.Died:Wait()
    end

    StarterGui:SetCore("SendNotification", {
        Title = "Revive Dupe Helper",
        Text = "Make your alt account try and revive you. (Click more than once)",
        Duration = 5
    })
end

--// Main Logic

--// Gifting 1 revive to alt account process
if Revives.Value == 0 and not IsMainAccount then
    SendPacket("SendReviveStandardToMe")
    IsGiftingRevive = true

    AttemptToKillLocalPlayer()
    
    StarterGui:SetCore("SendNotification", {
        Title = Title,
        Text = "Waiting for the other account to gift you a revive...",
        Duration = 5
    })
    
    local AcceptReviveThread = task.spawn(function()
        while task.wait() do
            VirtualInputManager:SendKeyEvent(
                true,
                Enum.KeyCode.Return,
                false,
                game
            )
        end
    end)

    Revives:GetPropertyChangedSignal("Value"):Wait()
    coroutine.close(AcceptReviveThread)
    task.wait(0.05)
    game:Shutdown()
    return
end

--// We account for delays in communication, so we send a notification to the user
--// If the ping is too high, heh.. skill issue
StarterGui:SetCore("SendNotification", {
    Title = Title,
    Text = "Please wait for 5 seconds to ensure proper communication has been established.",
    Duration = 5
})
task.wait(5)

--// If its gifting, we don't want to interrupt the gifting process
if IsGiftingRevive then
    return
end

--// Main account has to die.
if IsMainAccount then
    local ReviveObtainedAmount = 0
    local function OnObtainRevive(...)
        ReviveObtainedAmount += 1

        if ReviveObtainedAmount > (DuplicationCount * 0.85) then
            return true
        end

        task.wait(9e9)

        return true
    end

    if hookmetamethod then
        local mtHook; mtHook = hookmetamethod(game, "__newindex", function(...)
            local self, key = ...
    
            if rawequal(self, ObtainReviveEvent) and key == "OnClientInvoke" then
                if not checkcaller() then
                    return
                end
            end
    
            return mtHook(...)
        end)
    else
        -- might not work i have no clue honestly
        task.defer(function()
            while task.wait() do
                ObtainReviveEvent.OnClientInvoke = OnObtainRevive
            end
        end)
    end

    ObtainReviveEvent.OnClientInvoke = OnObtainRevive

    AttemptToKillLocalPlayer()
else
    if OtherPlayer:GetAttribute("Alive") then
        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = "Waiting for the other account to die...",
            Duration = 5
        })

        OtherPlayer:GetAttributeChangedSignal("Alive"):Wait()
    end

    for i = 1, 5 do
        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = `Duping in {6 - i} seconds...`,
            Duration = 1
        })
        task.wait(1)
    end

    for i = 1, DuplicationCount do
        ReviveFriendEvent:FireServer(OtherPlayer.Name)
    end

    StarterGui:SetCore("SendNotification", {
        Title = Title,
        Text = "Duping completed!",
        Duration = 5
    })
end
