-- Papi Dimz |HUB (All-in-One: Local Player + XENO GLASS Fishing + Bring Stuff + Teleport + Original Features)
-- Versi: 1.4 (Fixed UI Issue)
-- WARNING: Use at your own risk.
---------------------------------------------------------
-- SERVICES
---------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
---------------------------------------------------------
-- UTIL: NON-BLOCKING FIND HELPERS
---------------------------------------------------------
local function findWithTimeout(parent, name, timeout, pollInterval)
    timeout = timeout or 6
    pollInterval = pollInterval or 0.25
    local t0 = tick()
    while tick() - t0 < timeout do
        local v = parent:FindFirstChild(name)
        if v then return v end
        task.wait(pollInterval)
    end
    return nil
end
local function backgroundFind(parent, name, callback, pollInterval)
    pollInterval = pollInterval or 0.5
    task.spawn(function()
        while true do
            local v = parent:FindFirstChild(name)
            if v then
                pcall(callback, v)
                break
            end
            task.wait(pollInterval)
        end
    end)
end
---------------------------------------------------------
-- LOAD WINDUI with Better Error Handling
---------------------------------------------------------
local WindUI = nil
local function createFallbackNotify(msg)
    print("[PapiDimz][FALLBACK NOTIFY] " .. tostring(msg))
end
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if ok and res then
        WindUI = res
        pcall(function()
            WindUI:SetTheme("Dark")
            WindUI.TransparencyValue = 0.2
        end)
    else
        warn("[UI] Gagal load WindUI. Menggunakan fallback minimal.")
        WindUI = nil
    end
end
---------------------------------------------------------
-- STATE & CONFIG (Gabung dari Kedua Script, Hilangkan Duplikasi)
---------------------------------------------------------
local scriptDisabled = false
-- Remotes / folders
local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
local RequestStartDragging, RequestStopDragging, CollectCoinRemote, ConsumeItemRemote, NightSkipRemote, ToolDamageRemote, EquipHandleRemote
local ItemsFolder = Workspace:FindFirstChild("Items")
local Structures = Workspace:FindFirstChild("Structures")
-- Bring & Teleport State (dari Bring Stuff)
local BringHeight = 20
local selectedLocation = "Player"
local ScrapperTarget = nil
-- Original features state
local CookingStations = {}
local AutoCookEnabled = false
local CookLoopId = 0
local CookDelaySeconds = 10
local CookItemsPerCycle = 5
local SelectedCookItems = { "Carrot", "Corn" }
local ScrapEnabled = false
local ScrapLoopId = 0
local ScrapScanInterval = 60
local ScrapItemsPriority = {"Bolt","Sheet Metal","UFO Junk","UFO Component","Broken Fan","Old Radio","Broken Microwave","Tyre","Old Car Engine","Cultist Gem"}
local LavaCFrame = nil
local lavaFound = false
local AutoSacEnabled = false
local SacrificeList = {"Morsel","Cooked Morsel","Steak","Cooked Steak","Lava Eel","Cooked Lava Eel","Lionfish","Cooked Lionfish","Cultist","Crossbow Cultist","Rifle Ammo","Revolver Ammo","Bunny Foot","Alpha Wolf Pelt","Wolf Pelt"}
local GodmodeEnabled = false
local AntiAFKEnabled = true
local CoinAmmoEnabled = false
local coinAmmoDescAddedConn = nil
local CoinAmmoConnection = nil
local TemporalAccelerometer = Structures and Structures:FindFirstChild("Temporal Accelerometer")
local autoTemporalEnabled = false
local lastProcessedDay = nil
local DayDisplayRemote = nil
local DayDisplayConnection = nil
local WebhookURL = "https://discord.com/api/webhooks/1445120874033447068/aHmIofSu6jf7JctLjpRmbGYvwWX0MFtJw4Fnhqd6Hxyo4QQB7a_8UASNZsbpKMH4Jrvz"
local WebhookEnabled = true
local WebhookUsername = (LocalPlayer and LocalPlayer.Name) or "Player"
local currentDayCached = "N/A"
local previousDayCached = "N/A"
local KillAuraEnabled = false
local ChopAuraEnabled = false
local KillAuraRadius = 100
local ChopAuraRadius = 100
local AuraAttackDelay = 0.16
local AxeIDs = {["Old Axe"] = "3_7367831688",["Good Axe"] = "112_7367831688",["Strong Axe"] = "116_7367831688",Chainsaw = "647_8992824875",Spear = "196_8999010016"}
local TreeCache = {}
-- Local Player state
local defaultFOV = Camera.FieldOfView
local fovEnabled = false
local fovValue = 60
local walkEnabled = false
local walkSpeedValue = 30
local defaultWalkSpeed = 16
local flyEnabled = false
local flySpeedValue = 50
local flyConn = nil
local originalTransparency = {}
local idleTrack = nil
local tpWalkEnabled = false
local tpWalkSpeedValue = 5
local tpWalkConn = nil
local noclipManualEnabled = false
local noclipConn = nil
local infiniteJumpEnabled = false
local infiniteJumpConn = nil
local fullBrightEnabled = false
local fullBrightConn = nil
local oldLightingProps = {Brightness = Lighting.Brightness,ClockTime = Lighting.ClockTime,FogEnd = Lighting.FogEnd,GlobalShadows = Lighting.GlobalShadows,Ambient = Lighting.Ambient,OutdoorAmbient = Lighting.OutdoorAmbient}
local hipEnabled = false
local hipValue = 35
local defaultHipHeight = 2
local instantOpenEnabled = false
local promptOriginalHold = {}
local promptConn = nil
local humanoid = nil
local rootPart = nil
-- Fishing state
local fishingClickDelay = 5.0
local fishingAutoClickEnabled = false
local waitingForPosition = false
local fishingSavedPosition = nil
local fishingOverlayVisible = false
local fishingOffsetX, fishingOffsetY = 0, 0
local zoneEnabled = false
local zoneDestroyed = false
local zoneLastVisible = false
local zoneSpamClicking = false
local zoneSpamThread = nil
local zoneSpamInterval = 0.04
local autoRecastEnabled = false
local lastTimingBarSeenAt = 0
local wasTimingBarVisible = false
local lastRecastAt = 0
local RECAST_DELAY = 2
local MAX_RECENT_SECS = 5
local fishingLoopThread = nil
-- UI & HUD
local Window
local mainTab, localTab, bringTab, teleportTab, fishingTab, farmTab, utilTab, nightTab, webhookTab, healthTab
local miniHudGui, miniHudFrame, miniUptimeLabel, miniLavaLabel, miniPingFpsLabel, miniFeaturesLabel
local scriptStartTime = os.clock()
local currentFPS = 0
local auraHeartbeatConnection = nil
---------------------------------------------------------
-- GENERIC HELPERS
---------------------------------------------------------
local function tableToSet(list)
    local t = {}
    for _, v in ipairs(list) do t[v] = true end
    return t
end
local function trim(s)
    if type(s) ~= "string" then return s end
    return s:match("^%s*(.-)%s*$")
end
local function getGuiParent()
    local parent
    pcall(function()
        if gethui then parent = gethui() end
    end)
    if not parent then
        parent = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    end
    return parent
end
local function getInstancePath(inst)
    if not inst then return "nil" end
    local parts = { inst.Name }
    local parent = inst.Parent
    while parent and parent ~= game do
        table.insert(parts, 1, parent.Name)
        parent = parent.Parent
    end
    return table.concat(parts, ".")
end
local function notifyUI(title, content, duration, icon)
    if WindUI then
        pcall(function()
            WindUI:Notify({ Title = title or "Info", Content = content or "", Duration = duration or 4, Icon = icon or "info" })
        end)
    else
        createFallbackNotify(string.format("%s - %s", tostring(title), tostring(content)))
    end
end
---------------------------------------------------------
-- MINI HUD & SPLASH
---------------------------------------------------------
local function formatTime(seconds)
    seconds = math.floor(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end
local function getFeatureCodes()
    local t = {}
    if GodmodeEnabled then table.insert(t, "G") end
    if AntiAFKEnabled then table.insert(t, "AFK") end
    if AutoCookEnabled then table.insert(t, "CK") end
    if ScrapEnabled then table.insert(t, "SC") end
    if AutoSacEnabled then table.insert(t, "LV") end
    if CoinAmmoEnabled then table.insert(t, "CA") end
    if autoTemporalEnabled then table.insert(t, "NT") end
    if KillAuraEnabled then table.insert(t, "KA") end
    if ChopAuraEnabled then table.insert(t, "CH") end
    if flyEnabled then table.insert(t, "FLY") end
    if fishingAutoClickEnabled then table.insert(t, "FS") end
    if zoneEnabled then table.insert(t, "ZH") end
    return (#t > 0) and table.concat(t, " | ") or "None"
end
local function splashScreen()
    local parent = getGuiParent()
    if not parent then return end
    local ok, gui = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name = "PapiDimz_Splash"
        g.IgnoreGuiInset = true
        g.ResetOnSpawn = false
        g.Parent = parent
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        bg.BackgroundTransparency = 1
        bg.BorderSizePixel = 0
        bg.Parent = g
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 42
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.Text = ""
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.TextStrokeTransparency = 0.75
        label.TextStrokeColor3 = Color3.fromRGB(10, 10, 10)
        label.Parent = bg
        task.spawn(function()
            local durBg = 0.35
            local t = 0
            while t < durBg do
                t += RunService.Heartbeat:Wait()
                local alpha = math.clamp(t / durBg, 0, 1)
                bg.BackgroundTransparency = 1 - (alpha * 0.9)
            end
            bg.BackgroundTransparency = 0.1
        end)
        local text = "Papi Dimz :v"
        local speed = 0.05
        for i = 1, #text do
            label.Text = string.sub(text, 1, i)
            task.wait(speed)
        end
        local remain = 2 - (#text * speed)
        if remain > 0 then task.wait(remain) end
        local durOut = 0.3
        task.spawn(function()
            local t = 0
            while t < durOut do
                t += RunService.Heartbeat:Wait()
                local alpha = math.clamp(t / durOut, 0, 1)
                bg.BackgroundTransparency = 0.1 + alpha
                label.TextTransparency = alpha
            end
            g:Destroy()
        end)
        return g
    end)
end
local function createMiniHud()
    if miniHudGui then return end
    local parent = getGuiParent()
    if not parent then return end
    miniHudGui = Instance.new("ScreenGui")
    miniHudGui.Name = "PapiDimz_MiniHUD"
    miniHudGui.ResetOnSpawn = false
    miniHudGui.Parent = parent
    miniHudFrame = Instance.new("Frame")
    miniHudFrame.Size = UDim2.fromOffset(220, 90)
    miniHudFrame.Position = UDim2.new(0, 20, 0, 100)
    miniHudFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    miniHudFrame.BackgroundTransparency = 0.3
    miniHudFrame.BorderSizePixel = 0
    miniHudFrame.Active = true
    miniHudFrame.Draggable = true
    miniHudFrame.Parent = miniHudGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = miniHudFrame
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = miniHudFrame
    local function makeLabel(yOffset)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -10, 0, 18)
        lbl.Position = UDim2.new(0, 5, 0, yOffset)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        lbl.Text = ""
        lbl.Parent = miniHudFrame
        return lbl
    end
    miniUptimeLabel = makeLabel(4)
    miniLavaLabel = makeLabel(24)
    miniPingFpsLabel = makeLabel(44)
    miniFeaturesLabel = makeLabel(64)
end
local function startMiniHudLoop()
    scriptStartTime = os.clock()
    task.spawn(function()
        local last = tick()
        while not scriptDisabled do
            local now = tick()
            local dt = now - last
            last = now
            if dt > 0 then currentFPS = math.floor(1 / dt + 0.5) end
            RunService.Heartbeat:Wait()
        end
    end)
    task.spawn(function()
        while not scriptDisabled do
            local uptimeStr = formatTime(os.clock() - scriptStartTime)
            local pingMs = math.floor((LocalPlayer:GetNetworkPing() or 0) * 1000 + 0.5)
            local lavaStr = lavaFound and "Ready" or "Scan"
            local featStr = getFeatureCodes()
            if miniUptimeLabel then miniUptimeLabel.Text = "UP : " .. uptimeStr end
            if miniLavaLabel then miniLavaLabel.Text = "LV : " .. lavaStr end
            if miniPingFpsLabel then miniPingFpsLabel.Text = string.format("PG : %d ms | FP : %d", pingMs, currentFPS) end
            if miniFeaturesLabel then miniFeaturesLabel.Text = "FT : " .. featStr end
            task.wait(1)
        end
    end)
end
---------------------------------------------------------
-- BRING & TELEPORT FUNCTIONS (Dari Bring Stuff + Teleport.lua)
---------------------------------------------------------
local function getScrapperTarget()
    if ScrapperTarget and ScrapperTarget.Parent then
        return ScrapperTarget
    end

    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end

    local camp = map:FindFirstChild("Campground")
    if not camp then return nil end

    local scrapper = camp:FindFirstChild("Scrapper")
    if not scrapper then return nil end

    local movers = scrapper:FindFirstChild("Movers")
    if not movers then return nil end

    local right = movers:FindFirstChild("Right")
    if not right then return nil end

    local grindersRight = right:FindFirstChild("GrindersRight")
    if not grindersRight or not grindersRight:IsA("BasePart") then return nil end

    ScrapperTarget = grindersRight
    return ScrapperTarget
end

local function getTargetPosition(location)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        notifyUI("Error", "Karakter belum load! Default ke Vector3(0,0,0)", 5, "alert-triangle")
        return Vector3.new(0, 100, 0)
    end

    if location == "Player" then
        return hrp.Position + Vector3.new(0, BringHeight + 3, 0)
    elseif location == "Workbench" then
        local scrapperPart = getScrapperTarget()
        if scrapperPart then
            return scrapperPart.Position + Vector3.new(0, BringHeight, 0)
        else
            notifyUI("Warning", "Scrapper tidak ditemukan! Default ke Player", 6, "alert-circle")
            return hrp.Position + Vector3.new(0, BringHeight + 3, 0)
        end
    elseif location == "Fire" then
        local firePath = Workspace:FindFirstChild("Map")
            and Workspace.Map:FindFirstChild("Campground")
            and Workspace.Map.Campground:FindFirstChild("MainFire")
            and Workspace.Map.Campground.MainFire:FindFirstChild("OuterTouchZone")
        if firePath then
            return firePath.Position + Vector3.new(0, BringHeight, 0)
        else
            notifyUI("Warning", "Fire tidak ditemukan! Default ke Player", 6, "alert-circle")
            return hrp.Position + Vector3.new(0, BringHeight + 3, 0)
        end
    end
    return hrp.Position + Vector3.new(0, BringHeight + 3, 0)
end

local function getDropCFrame(basePos, index)
    local angle = (index - 1) * (math.pi * 2 / 12)
    local radius = 3
    local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
    return CFrame.new(basePos + offset)
end

local function bringItems(sectionItemList, selectedItems, location)
    local targetPos = getTargetPosition(location)
    local wantedNames = {}

    if table.find(selectedItems, "All") then
        for _, name in ipairs(sectionItemList) do
            if name ~= "All" then table.insert(wantedNames, name) end
        end
    else
        wantedNames = selectedItems
    end

    local candidates = {}
    for _, item in ipairs(ItemsFolder:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart and table.find(wantedNames, item.Name) then
            table.insert(candidates, item)
        end
    end

    if #candidates == 0 then
        notifyUI("Info", "Item tidak ditemukan", 4, "search")
        return
    end

    notifyUI("Bringing", #candidates.." item → "..location, 5, "zap")

    for i, item in ipairs(candidates) do
        local cf = getDropCFrame(targetPos, i)
        pcall(function() RequestStartDragging:FireServer(item) end)
        task.wait(0.03)
        pcall(function() item:PivotTo(cf) end)
        task.wait(0.03)
        pcall(function() RequestStopDragging:FireServer(item) end)
        task.wait(0.02)
    end

    notifyUI("Selesai!", #candidates.." item berhasil dibawa!", 4, "check-circle")
end

local function teleportToCFrame(targetCF)
    if not targetCF then
        notifyUI("Error", "Lokasi tidak ditemukan!", 5, "alert-triangle")
        return
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = targetCF + Vector3.new(0, 4, 0)  -- Sedikit di atas biar aman
        notifyUI("Teleport!", "Berhasil teleport!", 4, "navigation")
    end
end
---------------------------------------------------------
-- RESET / CLEANUP
---------------------------------------------------------
function resetAll()
    scriptDisabled = true
    AutoCookEnabled = false
    ScrapEnabled = false
    AutoSacEnabled = false
    GodmodeEnabled = false
    AntiAFKEnabled = false
    CoinAmmoEnabled = false
    autoTemporalEnabled = false
    KillAuraEnabled = false
    ChopAuraEnabled = false
    TreeCache = {}
    CookLoopId += 1
    ScrapLoopId += 1
    stopCoinAmmo()
    stopFly()
    stopTPWalk()
    stopInfiniteJump()
    disableFullBright()
    disableInstantOpen()
    stopZone()
    fishingAutoClickEnabled = false
    if DayDisplayConnection then DayDisplayConnection:Disconnect(); DayDisplayConnection = nil end
    if auraHeartbeatConnection then auraHeartbeatConnection:Disconnect(); auraHeartbeatConnection = nil end
    if coinAmmoDescAddedConn then coinAmmoDescAddedConn:Disconnect(); coinAmmoDescAddedConn = nil end
    if miniHudGui then pcall(function() miniHudGui:Destroy() end); miniHudGui = nil end
    if Window then pcall(function() Window:Destroy() end); Window = nil end
    print("[PapiDimz] Semua fitur dimatikan & UI dibersihkan.")
end

---------------------------------------------------------
-- LOCAL PLAYER FUNCTIONS (Dari Main.lua)
---------------------------------------------------------
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end
local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function zeroVelocities(part)
    if part and part:IsA("BasePart") then
        pcall(function()
            part.AssemblyLinearVelocity = Vector3.new(0,0,0)
            part.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end)
    end
end
local function applyFOV()
    if fovEnabled then Camera.FieldOfView = fovValue else Camera.FieldOfView = defaultFOV end
end
local function applyWalkspeed()
    if humanoid and walkEnabled then humanoid.WalkSpeed = math.clamp(walkSpeedValue, 16, 200) else if humanoid then humanoid.WalkSpeed = defaultWalkSpeed end end
end
local function applyHipHeight()
    if humanoid and hipEnabled then humanoid.HipHeight = hipValue else if humanoid then humanoid.HipHeight = defaultHipHeight end end
end
local function updateNoclipConnection()
    local should = (noclipManualEnabled or flyEnabled)
    if should and not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            local char = getCharacter()
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    elseif not should and noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end
local function setVisibility(on)
    local char = getCharacter()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or (part:IsA("MeshPart") and part.Name == "Handle") then
            if on then
                part.Transparency = 1
                part.LocalTransparencyModifier = 0
            else
                part.Transparency = originalTransparency[part] or 0
                part.LocalTransparencyModifier = 0
            end
        end
    end
end
local function playIdleAnimation()
    if idleTrack then idleTrack:Stop() end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://180435571"
    idleTrack = humanoid:LoadAnimation(anim)
    idleTrack.Priority = Enum.AnimationPriority.Core
    idleTrack.Looped = true
    idleTrack:Play()
end
local function startFly()
    if flyEnabled then return end
    flyEnabled = true
    updateNoclipConnection()
    local char = getCharacter()
    rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Parent = rootPart
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bg.CFrame = rootPart.CFrame
    bg.Parent = rootPart
    flyConn = RunService.Heartbeat:Connect(function()
        zeroVelocities(rootPart)
        local dir = Vector3.new()
        local camLook = Camera.CFrame.LookVector
        local camRight = Camera.CFrame.RightVector
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camLook end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camRight end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camRight end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then
            dir = dir.Unit * flySpeedValue
            bv.Velocity = dir
            bg.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + dir)
        else
            bv.Velocity = Vector3.new(0,0.1,0)
        end
    end)
end
local function stopFly()
    flyEnabled = false
    updateNoclipConnection()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if rootPart then
        pcall(function() rootPart.BodyVelocity:Destroy() end)
        pcall(function() rootPart.BodyGyro:Destroy() end)
    end
end
local function startTPWalk()
    if tpWalkEnabled then return end
    tpWalkEnabled = true
    tpWalkConn = RunService.Heartbeat:Connect(function()
        if humanoid.MoveDirection.Magnitude > 0 then
            local char = getCharacter()
            if char then
                char:TranslateBy(humanoid.MoveDirection * tpWalkSpeedValue)
            end
        end
    end)
end
local function stopTPWalk()
    tpWalkEnabled = false
    if tpWalkConn then tpWalkConn:Disconnect() tpWalkConn = nil end
end
local function startInfiniteJump()
    if infiniteJumpEnabled then return end
    infiniteJumpEnabled = true
    infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end
local function stopInfiniteJump()
    infiniteJumpEnabled = false
    if infiniteJumpConn then infiniteJumpConn:Disconnect() infiniteJumpConn = nil end
end
local function enableFullBright()
    if fullBrightEnabled then return end
    fullBrightEnabled = true
    fullBrightConn = RunService.RenderStepped:Connect(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(128,128,128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    end)
end
local function disableFullBright()
    fullBrightEnabled = false
    if fullBrightConn then fullBrightConn:Disconnect() fullBrightConn = nil end
    Lighting.Brightness = oldLightingProps.Brightness
    Lighting.ClockTime = oldLightingProps.ClockTime
    Lighting.FogEnd = oldLightingProps.FogEnd
    Lighting.GlobalShadows = oldLightingProps.GlobalShadows
    Lighting.Ambient = oldLightingProps.Ambient
    Lighting.OutdoorAmbient = oldLightingProps.OutdoorAmbient
end
local function removeFog()
    Lighting.FogEnd = math.huge
end
local function removeSky()
    pcall(function()
        Lighting:FindFirstChildOfClass("Sky"):Destroy()
    end)
end
local function enableInstantOpen()
    if instantOpenEnabled then return end
    instantOpenEnabled = true
    promptConn = game:GetService("ProximityPromptService").PromptShown:Connect(function(prompt)
        if prompt.Style == Enum.ProximityPromptStyle.Default then
            prompt.HoldDuration = 0
        end
    end)
end
local function disableInstantOpen()
    instantOpenEnabled = false
    if promptConn then promptConn:Disconnect() promptConn = nil end
end
---------------------------------------------------------
-- FISHING FUNCTIONS (Dari Main.lua)
---------------------------------------------------------
local function fishingShowOverlay(x, y)
    if not fishingOverlayVisible then return end
    local gui = LocalPlayer.PlayerGui:FindFirstChild("XenoPositionOverlay")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "XenoPositionOverlay"
        gui.ResetOnSpawn = false
        gui.Parent = LocalPlayer.PlayerGui
        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 40, 0, 40)
        frame.BackgroundTransparency = 0.5
        frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(0, 200, 0)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "ZONE"
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
    end
    local frame = gui.Frame
    frame.Position = UDim2.new(0, x + fishingOffsetX - 20, 0, y + fishingOffsetY - 20)
    frame.Visible = true
end

local function fishingHideOverlay()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("XenoPositionOverlay")
    if gui then
        gui.Frame.Visible = false
    end
end

local function startZone()
    if zoneEnabled then return end
    zoneEnabled = true
    notifyUI("Zone Hack", "100% Success Rate AKTIF", 4, "zap")
    zoneSpamThread = task.spawn(function()
        while zoneEnabled do
            if zoneSpamClicking then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
            task.wait(zoneSpamInterval)
        end
    end)
    -- Deteksi timing bar dan spam click saat muncul
    task.spawn(function()
        while zoneEnabled do
            local pgui = LocalPlayer.PlayerGui
            local timingBar = pgui:FindFirstChild("TimingBar", true)
            if timingBar and timingBar.Visible then
                if not zoneLastVisible then
                    zoneSpamClicking = true
                    zoneLastVisible = true
                end
            else
                if zoneLastVisible then
                    zoneSpamClicking = false
                    zoneLastVisible = false
                end
            end
            task.wait(0.03)
        end
    end)
end

local function stopZone()
    if not zoneEnabled then return end
    zoneEnabled = false
    zoneSpamClicking = false
    if zoneSpamThread then
        task.cancel(zoneSpamThread)
        zoneSpamThread = nil
    end
    notifyUI("Zone Hack", "100% Success Rate DIMATIKA", 4, "toggle-left")
end

-- Auto Recast Loop (jika diaktifkan)
task.spawn(function()
    while true do
        if autoRecastEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool and tool.Name:find("Rod") then
                tool.Parent = LocalPlayer.Character
                task.wait(0.2)
                tool:Activate()
                task.wait(RECAST_DELAY)
            end
        end
        task.wait(1)
    end
end)

-- Auto Clicker sederhana
task.spawn(function()
    while true do
        if fishingAutoClickEnabled then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            task.wait(fishingClickDelay)
        else
            task.wait(0.5)
        end
    end
end)

---------------------------------------------------------
-- FARM FUNCTIONS (Dari Main.lua)
---------------------------------------------------------
local function ensureCookingStations()
    CookingStations = {}
    for _, struct in ipairs(Structures:GetChildren()) do
        if struct.Name == "Crock Pot" or struct.Name == "Chefs Station" then
            table.insert(CookingStations, struct)
        end
    end
    return #CookingStations > 0
end

local function startCookLoop()
    task.spawn(function()
        while AutoCookEnabled do
            for _, station in ipairs(CookingStations) do
                if not AutoCookEnabled then break end
                local items = ItemsFolder:GetChildren()
                local count = 0
                for _, item in ipairs(items) do
                    if count >= CookItemsPerCycle then break end
                    if table.find(SelectedCookItems, item.Name) and item:IsA("Model") and item.PrimaryPart then
                        count += 1
                        pcall(function()
                            RequestStartDragging:FireServer(item)
                            task.wait(0.03)
                            item:PivotTo(station.PrimaryPart.CFrame + Vector3.new(0, 5, 0))
                            task.wait(0.03)
                            RequestStopDragging:FireServer(item)
                        end)
                        task.wait(0.05)
                    end
                end
            end
            task.wait(CookDelaySeconds)
        end
    end)
end

local function ensureScrapperTarget()
    ScrapperTarget = getScrapperTarget()  -- menggunakan fungsi dari Bring Stuff
    return ScrapperTarget ~= nil
end

local function startScrapLoop()
    task.spawn(function()
        while ScrapEnabled do
            local prioritySet = tableToSet(ScrapItemsPriority)
            local candidates = {}
            for _, item in ipairs(ItemsFolder:GetChildren()) do
                if item:IsA("Model") and item.PrimaryPart and prioritySet[item.Name] then
                    table.insert(candidates, item)
                end
            end
            for _, item in ipairs(candidates) do
                if not ScrapEnabled then break end
                pcall(function()
                    RequestStartDragging:FireServer(item)
                    task.wait(0.03)
                    item:PivotTo(ScrapperTarget.CFrame + Vector3.new(0, 5, 0))
                    task.wait(0.03)
                    RequestStopDragging:FireServer(item)
                end)
                task.wait(0.1)
            end
            task.wait(ScrapScanInterval)
        end
    end)
end

-- Auto Sacrifice Lava
task.spawn(function()
    while true do
        if AutoSacEnabled and lavaFound and LavaCFrame then
            local sacSet = tableToSet(SacrificeList)
            for _, item in ipairs(ItemsFolder:GetChildren()) do
                if sacSet[item.Name] and item:IsA("Model") and item.PrimaryPart then
                    pcall(function()
                        RequestStartDragging:FireServer(item)
                        task.wait(0.03)
                        item:PivotTo(LavaCFrame + Vector3.new(math.random(-3,3), 10, math.random(-3,3)))
                        task.wait(0.03)
                        RequestStopDragging:FireServer(item)
                    end)
                    task.wait(0.1)
                end
            end
        end
        task.wait(2)
    end
end)

-- Coin & Ammo Ultra Fast
local function startCoinAmmo()
    stopCoinAmmo()
    CoinAmmoEnabled = true
    task.spawn(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if not CoinAmmoEnabled or scriptDisabled then break end
            pcall(function()
                if v.Name == "Coin Stack" and CollectCoinRemote then
                    CollectCoinRemote:InvokeServer(v)
                elseif (v.Name == "Revolver Ammo" or v.Name == "Rifle Ammo") and ConsumeItemRemote then
                    ConsumeItemRemote:InvokeServer(v)
                end
            end)
        end
        notifyUI("Ultra Coin & Ammo", "Initial collect selesai. Listening spawn baru...", 4, "zap")
        coinAmmoDescAddedConn = Workspace.DescendantAdded:Connect(function(desc)
            if not CoinAmmoEnabled or scriptDisabled then return end
            task.wait(0.01)
            pcall(function()
                if desc.Name == "Coin Stack" and CollectCoinRemote then
                    CollectCoinRemote:InvokeServer(desc)
                elseif (desc.Name == "Revolver Ammo" or desc.Name == "Rifle Ammo") and ConsumeItemRemote then
                    ConsumeItemRemote:InvokeServer(desc)
                end
            end)
        end)
        while CoinAmmoEnabled and not scriptDisabled do task.wait(0.5) end
        stopCoinAmmo()
        print("[CoinAmmo] Dimatikan.")
    end)
end

local function stopCoinAmmo()
    CoinAmmoEnabled = false
    if coinAmmoDescAddedConn then coinAmmoDescAddedConn:Disconnect(); coinAmmoDescAddedConn = nil end
    if CoinAmmoConnection then CoinAmmoConnection:Disconnect(); CoinAmmoConnection = nil end
end

-- Kill Aura & Chop Aura
task.spawn(function()
    while true do
        if KillAuraEnabled or ChopAuraEnabled then
            local char = LocalPlayer.Character
            if char and rootPart then
                if KillAuraEnabled then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local dist = (rootPart.Position - hrp.Position).Magnitude
                                if dist <= KillAuraRadius then
                                    -- Damage logic - fire remote jika ada equipped tool, atau direct damage
                                    if ToolDamageRemote then
                                        local tool = char:FindFirstChildOfClass("Tool")
                                        if tool then
                                            ToolDamageRemote:FireServer(plr.Character.Humanoid, tool)
                                        else
                                            -- Fallback: direct take damage (bisa tidak work jika anti-cheat)
                                            pcall(function()
                                                plr.Character.Humanoid:TakeDamage(100)
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if ChopAuraEnabled then
                    -- Chop tree logic (small trees)
                    for _, tree in ipairs(TreeCache) do
                        if tree and tree.Parent and tree:FindFirstChild("Health") then
                            local dist = (rootPart.Position - tree.PrimaryPart.Position).Magnitude
                            if dist <= ChopAuraRadius then
                                if ToolDamageRemote then
                                    local axe = char:FindFirstChildOfClass("Tool")
                                    if axe and AxeIDs[axe.Name] then
                                        ToolDamageRemote:FireServer(tree, axe)
                                    end
                                end
                            end
                        end
                    end
                    -- Refresh cache jika kosong
                    if #TreeCache == 0 then
                        buildTreeCache()
                    end
                end
            end
        end
        task.wait(AuraAttackDelay)
    end
end)

-- Fungsi pendukung untuk Chop Aura (buildTreeCache)
local function buildTreeCache()
    TreeCache = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "SmallTree" or obj.Name == "Tree" or (obj:IsA("Model") and obj:FindFirstChild("Health") and obj:FindFirstChild("Wood")) then
            if obj.PrimaryPart then
                table.insert(TreeCache, obj)
            end
        end
    end
end

---------------------------------------------------------
-- TOOLS, NIGHT, WEBHOOK, HEALTH FUNCTIONS (Dari Main.lua)
---------------------------------------------------------
local function scanCampground()
    local map = Workspace:FindFirstChild("Map")
    if not map then
        warn("[Scan] workspace.Map tidak ditemukan.")
        return
    end
    local camp = map:FindFirstChild("Campground")
    if not camp then
        warn("[Scan] Map.Campground tidak ditemukan.")
        return
    end
    local descendants = camp:GetDescendants()
    local lines = {}
    table.insert(lines, string.format("[Scan] Map.Campground - total %d descendants\n", #descendants))
    for _, inst in ipairs(descendants) do
        local path = getInstancePath(inst)
        local line = string.format("%s | %s", path, inst.ClassName)
        table.insert(lines, line)
    end
    local text = table.concat(lines, "\n")
    print(text)
    if typeof(setclipboard) == "function" then
        pcall(setclipboard, text)
        print("[Scan] List Campground dicopy ke clipboard.")
    else
        print("[Scan] setclipboard tidak tersedia, copy manual dari console.")
    end
end

local function activateTemporal()
    if scriptDisabled then return end
    if not TemporalAccelerometer or not TemporalAccelerometer.Parent then
        Structures = Workspace:FindFirstChild("Structures") or Structures
        TemporalAccelerometer = Structures and Structures:FindFirstChild("Temporal Accelerometer") or TemporalAccelerometer
    end
    if not TemporalAccelerometer then
        warn("[Temporal] Temporal Accelerometer tidak ditemukan.")
        notifyUI("Temporal", "Temporal Accelerometer belum tersedia.", 4, "alert-triangle")
        return
    end
    if NightSkipRemote then
        NightSkipRemote:FireServer(TemporalAccelerometer)
        print("[Temporal] RequestActivate dikirim.")
    end
end

---------------------------------------------------------
-- WEBHOOK HELPERS
---------------------------------------------------------
local function namesToVerticalList(names)
    if type(names) ~= "table" or #names == 0 then return "_Tidak ada pemain aktif_" end
    local lines = {}
    for _, n in ipairs(names) do table.insert(lines, "- " .. tostring(n)) end
    return table.concat(lines, "\n")
end
local function try_syn_request(url, body)
    if not syn or not syn.request then return false, "syn.request not available" end
    local ok, res = pcall(function()
        return syn.request({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
    if not ok then return false, res end
    return true, res
end
local function try_request(url, body)
    if not request then return false, "request not available" end
    local ok, res = pcall(function()
        return request({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
    if not ok then return false, res end
    return true, res
end
local function try_httpservice_post(url, body)
    local ok, res = pcall(function()
        return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
    end)
    return ok, res
end
local function buildDayEmbed(currentDay, previousDay, bedCount, kidCount, itemsList, isTest)
    local players = Players:GetPlayers()
    local names = {}
    for _, p in ipairs(players) do table.insert(names, p.Name) end
    local prev = tostring(previousDay or "N/A")
    local cur = tostring(currentDay or "N/A")
    local delta = "N/A"
    if tonumber(cur) and tonumber(prev) then delta = tostring(tonumber(cur) - tonumber(prev)) end
    local sampleItems = ""
    if type(itemsList) == "table" and #itemsList > 0 then
        local limit = math.min(#itemsList, 6)
        for i = 1, limit do sampleItems = sampleItems .. "• `" .. tostring(itemsList[i]) .. "`\n" end
        if #itemsList > limit then sampleItems = sampleItems .. "• `...and more`" end
    else
        sampleItems = "_No items recorded_"
    end
    local titlePrefix = isTest and "🧪 TEST - " or ""
    local title = string.format("%s🌅 DAY PROGRESSION UPDATE %s", titlePrefix, cur)
    local subtitle = "Ringkasan hari, pemain aktif, dan item penting."
    local playerListValue = namesToVerticalList(names)
    if #playerListValue > 1024 then
        local sample = {}
        for i = 1, math.min(#names, 15) do table.insert(sample, names[i]) end
        playerListValue = namesToVerticalList(sample) .. "\n- ...and more"
    end
    local embed = {
        title = title,
        description = table.concat({
            "✨ **" .. subtitle .. "**",
            "",
            string.format("📆 **Progress:** `%s → %s` • **Δ**: `%s` hari", prev, cur, delta),
            string.format("🛏️ **Beds:** `%s` 👶 **Kids:** `%s`", tostring(bedCount or 0), tostring(kidCount or 0)),
            string.format("🎮 **Players Online:** `%s`", tostring(#names)),
            "",
            "🎒 **Item Highlights:**",
            sampleItems
        }, "\n"),
        color = 0xFAA61A,
        fields = {
            { name = "📈 Perubahan Hari", value = string.format("`%s` → `%s` (Δ %s)", prev, cur, tostring(delta)), inline = true },
            { name = "🎮 Jumlah Pemain", value = "`" .. tostring(#names) .. "`", inline = true },
            { name = "🧍 Pemain Aktif (list)", value = playerListValue, inline = false },
        },
        footer = { text = "🕒 Update generated at " .. os.date("%Y-%m-%d %H:%M:%S") }
    }
    local payload = { username = WebhookUsername or "Day Monitor", embeds = { embed } }
    return payload
end
local function sendWebhookPayload(payloadTable)
    if not WebhookURL or trim(WebhookURL) == "" then return false, "Webhook URL kosong" end
    local body = HttpService:JSONEncode(payloadTable)
    local ok1, res1 = try_syn_request(WebhookURL, body)
    if ok1 then
        if type(res1) == "table" and res1.StatusCode then
            if res1.StatusCode >= 200 and res1.StatusCode < 300 then return true, ("syn.request: HTTP %d"):format(res1.StatusCode) end
            return false, ("syn.request: HTTP %d"):format(res1.StatusCode)
        end
        return true, "syn.request: success"
    end
    local ok2, res2 = try_request(WebhookURL, body)
    if ok2 then
        if type(res2) == "table" and res2.StatusCode then
            if res2.StatusCode >= 200 and res2.StatusCode < 300 then return true, ("request: HTTP %d"):format(res2.StatusCode) end
            return false, ("request: HTTP %d"):format(res2.StatusCode)
        end
        return true, "request: success"
    end
    local ok3, res3 = try_httpservice_post(WebhookURL, body)
    if ok3 then return true, "HttpService:PostAsync success" end
    local errmsg = ("syn_err=%s | request_err=%s | http_err=%s"):format(tostring(res1), tostring(res2), tostring(res3))
    return false, errmsg
end
_G.SendManualDay = function(cur, prev, items)
    local curN, prevN = tonumber(cur) or cur, tonumber(prev) or prev
    local beds, kids = 0, 0
    if type(items) == "table" then
        for _, v in ipairs(items) do
            if type(v) == "string" then
                local s = v:lower()
                if s:find("bed") then beds = beds + 1 end
                if s:find("child") or s:find("kid") then kids = kids + 1 end
            end
        end
    end
    local payload = buildDayEmbed(curN, prevN, beds, kids, items, false)
    local ok, msg = sendWebhookPayload(payload)
    print("Manual send result:", ok, msg)
    return ok, msg
end

local function getStatusSummary()
    local uptimeStr = formatTime(os.clock() - scriptStartTime)
    local pingMs = math.floor((LocalPlayer:GetNetworkPing() or 0) * 1000 + 0.5)
    local lavaStr = lavaFound and "Ready" or "Scanning..."
    local featStr = getFeatureCodes()
    local msg = table.concat({
        "UPTIME : " .. uptimeStr,
        "LAVA : " .. lavaStr,
        string.format("PING : %d ms", pingMs),
        string.format("FPS : %d", currentFPS),
        "FITUR : " .. featStr
    }, "\n")
    return msg
end

---------------------------------------------------------
-- GODMODE, ANTI-AFK, AURA, DLL. LOOPS (Dari Main.lua)
---------------------------------------------------------
---------------------------------------------------------
-- GODMODE, ANTI-AFK, AURA, DLL. LOOPS (Dari Main.lua asli - lengkap)
---------------------------------------------------------

-- Anti-AFK (mencegah kick karena idle)
local function initAntiAFK()
    if not AntiAFKEnabled then return end
    local vu = VirtualUser
    game:GetService("RunService").Heartbeat:Connect(function()
        if AntiAFKEnabled then
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end
    end)
end

-- Godmode (heal terus-menerus agar tidak mati)
local function startGodmodeLoop()
    task.spawn(function()
        while task.wait(1) do
            if GodmodeEnabled and humanoid and humanoid.Health > 0 then
                pcall(function()
                    humanoid.Health = humanoid.MaxHealth
                    humanoid:TakeDamage(-999999)  -- heal besar-besaran
                end)
            end
        end
    end)
end

-- Kill Aura & Chop Aura (loop utama)
task.spawn(function()
    while task.wait(AuraAttackDelay) do
        if not (KillAuraEnabled or ChopAuraEnabled) then continue end
        local char = LocalPlayer.Character
        if not char or not rootPart then continue end

        -- Kill Aura (serang player lain)
        if KillAuraEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                local targetChar = plr.Character
                if not targetChar then continue end
                local targetHum = targetChar:FindFirstChild("Humanoid")
                local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
                if not targetHum or not targetHRP or targetHum.Health <= 0 then continue end

                local distance = (rootPart.Position - targetHRP.Position).Magnitude
                if distance <= KillAuraRadius then
                    if ToolDamageRemote then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            pcall(function()
                                ToolDamageRemote:FireServer(targetHum, tool)
                            end)
                        end
                    else
                        -- Fallback jika remote tidak ada
                        pcall(function()
                            targetHum:TakeDamage(50)
                        end)
                    end
                end
            end
        end

        -- Chop Aura (tebang pohon otomatis)
        if ChopAuraEnabled then
            -- Build cache jika kosong
            if #TreeCache == 0 then
                TreeCache = {}
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Health") and obj.PrimaryPart then
                        local name = obj.Name
                        if name:find("Tree") or name:find("Log") or obj:FindFirstChild("Wood") then
                            table.insert(TreeCache, obj)
                        end
                    end
                end
            end

            local axeEquipped = false
            local axeTool = char:FindFirstChildOfClass("Tool")
            if axeTool and AxeIDs[axeTool.Name] then
                axeEquipped = true
            end

            for _, tree in ipairs(TreeCache) do
                if tree and tree.Parent and tree:FindFirstChild("Health") and tree.PrimaryPart then
                    local dist = (rootPart.Position - tree.PrimaryPart.Position).Magnitude
                    if dist <= ChopAuraRadius and axeEquipped then
                        if ToolDamageRemote then
                            pcall(function()
                                ToolDamageRemote:FireServer(tree, axeTool)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Sacrifice ke Lava (jika Lava ditemukan)
task.spawn(function()
    while task.wait(3) do
        if not AutoSacEnabled then continue end
        if not lavaFound or not LavaCFrame then
            -- Cari lava jika belum ketemu
            local lavaPart = Workspace:FindFirstChild("Map") 
                and Workspace.Map:FindFirstChild("Landmarks") 
                and Workspace.Map.Landmarks:FindFirstChild("LavaPool")
            if lavaPart then
                LavaCFrame = lavaPart.PrimaryPart and lavaPart.PrimaryPart.CFrame or lavaPart.CFrame
                lavaFound = true
                notifyUI("Auto Sacrifice", "Lava ditemukan! AutoSac aktif.", 5, "flame-kindling")
            end
            continue
        end

        local sacSet = tableToSet(SacrificeList)
        for _, item in ipairs(ItemsFolder:GetChildren()) do
            if sacSet[item.Name] and item:IsA("Model") and item.PrimaryPart then
                pcall(function()
                    RequestStartDragging:FireServer(item)
                    task.wait(0.03)
                    item:PivotTo(LavaCFrame + Vector3.new(math.random(-5,5), 15, math.random(-5,5)))
                    task.wait(0.03)
                    RequestStopDragging:FireServer(item)
                end)
                task.wait(0.1)
            end
        end
    end
end)

-- Auto Temporal Accelerometer (skip malam otomatis)
task.spawn(function()
    while task.wait(5) do
        if autoTemporalEnabled and TemporalAccelerometer then
            if currentDayCached ~= previousDayCached then
                pcall(function()
                    NightSkipRemote:FireServer()  -- atau cara aktivasi sesuai game
                end)
                previousDayCached = currentDayCached
            end
        end
    end
end)

-- Webhook Day Display Update (kirim progress ke Discord)
task.spawn(function()
    while task.wait(60) do  -- setiap menit
        if WebhookEnabled and WebhookURL ~= "" then
            local players = Players:GetPlayers()
            local playerNames = {}
            for _, p in ipairs(players) do table.insert(playerNames, p.Name) end
            local payload = {
                username = WebhookUsername,
                embeds = {{
                    title = "Day Progress Update",
                    description = ("**Day:** `%s`\n**Players Online:** %d\n**List:**\n%s"):format(
                        currentDayCached, #players, table.concat(playerNames, "\n")
                    ),
                    color = 0x00FF00,
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            }
            pcall(function()
                HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(payload))
            end)
        end
    end
end)

-- Ultra Fast Coin & Ammo (jika ada remote)
task.spawn(function()
    while task.wait(0.1) do
        if CoinAmmoEnabled then
            if CollectCoinRemote then
                pcall(function() CollectCoinRemote:FireServer() end)
            end
            if ConsumeItemRemote then
                -- Logic ammo infinite jika diperlukan
            end
        end
    end
end)

-- Hook Day Display untuk Webhook & Temporal (contoh)
local function tryHookDayDisplay()
    -- Cari TextLabel atau remote yang menampilkan Day
    backgroundFind(Workspace, "DayDisplay", function(display)
        DayDisplayConnection = display:GetPropertyChangedSignal("Text"):Connect(function()
            currentDayCached = display.Text:match("%d+") or currentDayCached
        end)
    end)
end
---------------------------------------------------------
-- CREATE MAIN UI (Gabung Tab Bring dan Teleport)
---------------------------------------------------------
local function createMainUI()
    if not WindUI then
        warn("[UI] WindUI tidak loaded. UI tidak bisa dibuat.")
        return
    end
    local ok, err = pcall(function()
        Window = WindUI:CreateWindow({
            Title = "Papi Dimz HUB",
            Icon = "zap",
            Author = "Dimz",
            Size = UDim2.fromOffset(620, 580),
            Theme = "Dark",
            Acrylic = true,
            Visible = true,
            Enabled = true,
            Draggable = true,
        })
        mainTab = Window:Tab({ Title = "Main", Icon = "settings-2" })
        localTab = Window:Tab({ Title = "Local Player", Icon = "user" })
        bringTab = Window:Tab({ Title = "Bring Item", Icon = "hand" })
        teleportTab = Window:Tab({ Title = "Teleport", Icon = "navigation" })
        fishingTab = Window:Tab({ Title = "Fishing", Icon = "fish" })
        farmTab = Window:Tab({ Title = "Farm", Icon = "chef-hat" })
        utilTab = Window:Tab({ Title = "Tools", Icon = "wrench" })
        nightTab = Window:Tab({ Title = "Night", Icon = "moon" })
        webhookTab = Window:Tab({ Title = "Webhook", Icon = "radio" })
        healthTab = Window:Tab({ Title = "Cek Health", Icon = "activity" })
        -- MAIN TAB (Dari Main.lua)
        mainTab:Paragraph({ Title = "Papi Dimz HUB", Desc = "Godmode, AntiAFK, Auto Sacrifice Lava, Auto Farm, Aura, Webhook DayDisplay.\nHotkey PC: P untuk toggle UI.", Color = "Grey" })
        mainTab:Toggle({ Title = "GodMode (Damage -∞)", Icon = "shield", Default = false, Callback = function(state) GodmodeEnabled = state end })
        mainTab:Toggle({ Title = "Anti AFK", Icon = "mouse-pointer-2", Default = true, Callback = function(state) AntiAFKEnabled = state end })
        mainTab:Button({ Title = "Tutup UI & Matikan Script", Icon = "power", Variant = "Destructive", Callback = resetAll })
        
        -- LOCAL PLAYER TAB
        localTab:Paragraph({ Title = "Self", Desc = "Atur FOV kamera.", Color = "Grey" })
        localTab:Toggle({ Title = "FOV", Icon = "zoom-in", Default = false, Callback = function(state) fovEnabled = state; applyFOV() end })
        localTab:Slider({ Title = "FOV", Description = "40 - 120", Step = 1, Value = { Min = 40, Max = 120, Default = 60 }, Callback = function(v) fovValue = v; applyFOV() end })
        localTab:Paragraph({ Title = "Movement", Desc = "WalkSpeed, Fly, TP Walk, Noclip, Infinite Jump, Hip Height.", Color = "Grey" })
        localTab:Toggle({ Title = "Speed", Icon = "rabbit", Default = false, Callback = function(state) walkEnabled = state; applyWalkspeed() end })
        localTab:Slider({ Title = "Walk Speed", Description = "16 - 200", Step = 1, Value = { Min = 16, Max = 200, Default = 30 }, Callback = function(v) walkSpeedValue = v; applyWalkspeed() end })
        localTab:Toggle({ Title = "Fly", Icon = "plane", Default = false, Callback = function(state) if state then startFly() else stopFly() end end })
        localTab:Slider({ Title = "Fly Speed", Description = "16 - 200", Step = 1, Value = { Min = 16, Max = 200, Default = 50 }, Callback = function(v) flySpeedValue = v end })
        localTab:Toggle({ Title = "TP Walk", Icon = "mouse-pointer-2", Default = false, Callback = function(state) if state then startTPWalk() else stopTPWalk() end end })
        localTab:Slider({ Title = "TP Walk Speed", Description = "1 - 30", Step = 1, Value = { Min = 1, Max = 30, Default = 5 }, Callback = function(v) tpWalkSpeedValue = v end })
        localTab:Toggle({ Title = "Noclip", Icon = "ghost", Default = false, Callback = function(state) noclipManualEnabled = state; updateNoclipConnection() end })
        localTab:Toggle({ Title = "Infinite Jump", Icon = "chevron-up", Default = false, Callback = function(state) if state then startInfiniteJump() else stopInfiniteJump() end end })
        localTab:Toggle({ Title = "Hip Height", Icon = "align-vertical-justify-center", Default = false, Callback = function(state) hipEnabled = state; applyHipHeight() end })
        localTab:Slider({ Title = "Hip Height Value", Description = "0 - 60", Step = 1, Value = { Min = 0, Max = 60, Default = 35 }, Callback = function(v) hipValue = v; applyHipHeight() end })
        localTab:Paragraph({ Title = "Visual", Desc = "Fullbright, Remove Fog/Sky.", Color = "Grey" })
        localTab:Toggle({ Title = "Fullbright", Icon = "sun", Default = false, Callback = function(state) if state then enableFullBright() else disableFullBright() end end })
        localTab:Button({ Title = "Remove Fog", Icon = "wind", Callback = removeFog })
        localTab:Button({ Title = "Remove Sky", Icon = "cloud-off", Callback = removeSky })
        localTab:Paragraph({ Title = "Misc", Desc = "Instant Open, Reset.", Color = "Grey" })
        localTab:Toggle({ Title = "Instant Open (ProximityPrompt)", Icon = "bolt", Default = false, Callback = function(state) if state then enableInstantOpen() else disableInstantOpen() end end })

        -- ==============================================
        -- Bring Item Tab (tetap sama)
        -- ==============================================
        local settingSec = bringTab:Section({Title = "Bring Setting", Icon = "settings", Collapsible = true, DefaultOpen = true})
        settingSec:Dropdown({Title = "Location", Desc = "Player / Workbench (Scrapper) / Fire", Values = {"Player", "Workbench", "Fire"}, Value = "Player", Callback = function(v) selectedLocation = v end})
        settingSec:Input({Title = "Bring Height", Placeholder = "20", Default = "20", Numeric = true, Callback = function(v) BringHeight = tonumber(v) or 20 end})

        local cultistSec = bringTab:Section({Title = "Bring Cultist", Icon = "skull", Collapsible = true})
        local cultistList = {"All", "Crossbow Cultist", "Cultist"}
        local selCultist = {"All"}
        cultistSec:Dropdown({Title="Pilih Cultist", Values=cultistList, Value={"All"}, Multi=true, AllowNone=true, Callback=function(o) selCultist=o or {"All"} end})
        cultistSec:Button({Title="Bring Cultist", Callback=function() bringItems(cultistList, selCultist, selectedLocation) end})

        local meteorSec = bringTab:Section({Title = "Bring Meteor Items", Icon = "zap", Collapsible = true})
        local meteorList = {"All", "Raw Obsidiron Ore", "Gold Shard", "Meteor Shard", "Scalding Obsidiron Ingot"}
        local selMeteor = {"All"}
        meteorSec:Dropdown({Title="Pilih Item", Values=meteorList, Value={"All"}, Multi=true, AllowNone=true, Callback=function(o) selMeteor=o or {"All"} end})
        meteorSec:Button({Title="Bring Meteor", Callback=function() bringItems(meteorList, selMeteor, selectedLocation) end})

        local fuelSec = bringTab:Section({Title = "Fuels", Icon = "flame", Collapsible = true})
        local fuelList = {"All", "Log", "Coal", "Chair", "Fuel Canister", "Oil Barrel"}
        local selFuel = {"All"}
        fuelSec:Dropdown({Title="Pilih Fuel", Values=fuelList, Value={"All"}, Multi=true, AllowNone=true, Callback=function(o) selFuel=o or {"All"} end})
        fuelSec:Button({Title="Bring Fuels", Callback=function() bringItems(fuelList, selFuel, selectedLocation) end})
        fuelSec:Button({Title="Bring Logs Only", Callback=function() bringItems(fuelList, {"Log"}, selectedLocation) end})

        local foodSec = bringTab:Section({Title = "Food", Icon = "drumstick", Collapsible = true})
        local foodList = {"All", "Sweet Potato", "Stuffing", "Turkey Leg", "Carrot", "Pumkin", "Mackerel", "Salmon", "Swordfish", "Berry", "Ribs", "Stew", "Steak Dinner", "Morsel", "Steak", "Corn", "Cooked Morsel", "Cooked Steak", "Chilli", "Apple", "Cake"}
        local selFood = {"All"}
        foodSec:Dropdown({Title="Pilih Food", Values=foodList, Value={"All"}, Multi=true, AllowNone=true, Callback=function(o) selFood=o or {"All"} end})
        foodSec:Button({Title="Bring Food", Callback=function() bringItems(foodList, selFood, selectedLocation) end})

        local healSec = bringTab:Section({Title = "Healing", Icon = "heart", Collapsible = true})
        local healList = {"All", "Medkit", "Bandage"}
        local selHeal = {"All"}
        healSec:Dropdown({Title="Pilih Healing", Values=healList, Value={"All"}, Multi=true, AllowNone=true, Callback=function(o) selHeal=o or {"All"} end})
        healSec:Button({Title="Bring Healing", Callback=function() bringItems(healList, selHeal, selectedLocation) end})

        local gearSec = bringTab:Section({Title = "Gears (Scrap)", Icon = "wrench", Collapsible = true})
        local gearList = {"All", "Bolt", "Tyre", "Sheet Metal", "Old Radio", "Broken Fan", "Broken Microwave", "Washing Machine", "Old Car Engine", "UFO Scrap", "UFO Component", "UFO Junk", "Cultist Gem", "Gem of the Forest"}
        local selGear = {"All"}
        gearSec:Dropdown({Title="Pilih Gear", Values=gearList, Value={"All"}, Multi=true, AllowNone=true, Callback=function(o) selGear=o or {"All"} end})
        gearSec:Button({Title="Bring Gears", Callback=function() bringItems(gearList, selGear, selectedLocation) end})

        local gunSec = bringTab:Section({Title = "Guns & Ammo", Icon = "swords", Collapsible = true})
        local gunList = {"All", "Infernal Sword", "Morningstar", "Crossbow", "Infernal Crossbow", "Laser Sword", "Raygun", "Ice Axe", "Ice Sword", "Chainsaw", "Strong Axe", "Axe Trim Kit", "Spear", "Good Axe", "Revolver", "Rifle", "Tactical Shotgun", "Revolver Ammo", "Rifle Ammo", "Alien Armour", "Frog Boots", "Leather Body", "Iron Body", "Thorn Body", "Riot Shield", "Armour Trim Kit", "Obsidiron Boots"}
        local selGun = {"All"}
        gunSec:Dropdown({Title="Pilih Weapon", Values=gunList, Value={"All"}, Multi=true, AllowNone=true, Callback=function(o) selGun=o or {"All"} end})
        gunSec:Button({Title="Bring Guns & Ammo", Callback=function() bringItems(gunList, selGun, selectedLocation) end})

        local otherSec = bringTab:Section({Title = "Bring Other", Icon = "package", Collapsible = true})
        local otherList = {"All", "Purple Fur Tuft", "Halloween Candle", "Candy", "Frog Key", "Feather", "Wildfire", "Sacrifice Totem", "Old Rod", "Flower", "Coin Stack", "Infernal Sack", "Giant Sack", "Good Sack", "Seed Box", "Chainsaw", "Old Flashlight", "Strong Flashlight", "Bunny Foot", "Wolf Pelt", "Bear Pelt", "Mammoth Tusk", "Alpha Wolf Pelt", "Bear Corpse", "Meteor Shard", "Gold Shard", "Raw Obsidiron Ore", "Gem of the Forest", "Diamond", "Defense Blueprint"}
        local selOther = {"All"}
        otherSec:Dropdown({Title="Pilih Item", Values=otherList, Value={"All"}, Multi=true, AllowNone=true, Callback=function(o) selOther=o or {"All"} end})
        otherSec:Button({Title="Bring Other", Callback=function() bringItems(otherList, selOther, selectedLocation) end})

        -- ==============================================
        -- Teleport Tab
        -- ==============================================
        -- Lost Child (seperti sebelumnya)
        local lostChildSec = teleportTab:Section({Title = "Teleport Lost Child", Icon = "baby", Collapsible = true, DefaultOpen = true})
        local childOptions = {"DinoKid", "KoalaKid", "KrakenKid", "SquidKid"}
        local selectedChild = "DinoKid"
        lostChildSec:Dropdown({Title = "Select Child", Values = childOptions, Value = "DinoKid", Callback = function(v) selectedChild = v end})
        lostChildSec:Button({
            Title = "Teleport To Child",
            Callback = function()
                local hrp = nil
                if selectedChild == "DinoKid" then
                    hrp = Workspace.Characters:FindFirstChild("Lost Child") and Workspace.Characters["Lost Child"]:FindFirstChild("HumanoidRootPart")
                elseif selectedChild == "KoalaKid" then
                    hrp = Workspace.Characters:FindFirstChild("Lost Child4") and Workspace.Characters["Lost Child4"]:FindFirstChild("HumanoidRootPart")
                elseif selectedChild == "KrakenKid" then
                    hrp = Workspace.Characters:FindFirstChild("Lost Child2") and Workspace.Characters["Lost Child2"]:FindFirstChild("HumanoidRootPart")
                elseif selectedChild == "SquidKid" then
                    hrp = Workspace.Characters:FindFirstChild("Lost Child3") and Workspace.Characters["Lost Child3"]:FindFirstChild("HumanoidRootPart")
                end
                if hrp then
                    teleportToCFrame(hrp.CFrame)
                else
                    WindUI:Notify({Title="Error", Content=selectedChild.." tidak ditemukan!", Icon="alert-triangle"})
                end
            end
        })

        -- Structure Teleport (BARU!)
        local structureSec = teleportTab:Section({
            Title = "Structure Teleport",
            Icon = "castle",            -- Icon bangunan / structure
            Collapsible = true,
            DefaultOpen = false
        })

        -- Teleport to Camp (ke Fire)
        structureSec:Button({
            Title = "Teleport to Camp",
            Callback = function()
                local firePath = Workspace:FindFirstChild("Map")
                    and Workspace.Map:FindFirstChild("Campground")
                    and Workspace.Map.Campground:FindFirstChild("MainFire")
                    and Workspace.Map.Campground.MainFire:FindFirstChild("OuterTouchZone")
                if firePath then
                    teleportToCFrame(firePath.CFrame)
                else
                    WindUI:Notify({Title="Error", Content="Camp (Fire) tidak ditemukan!", Icon="alert-triangle"})
                end
            end
        })

        -- Teleport to Cultist Generator Base (asumsi path dari game, sesuaikan kalau ada info lebih)
        structureSec:Button({
            Title = "Teleport to Cultist Generator Base",
            Callback = function()
                -- Contoh path umum, sesuaikan kalau tahu exact
                local cultistBase = Workspace:FindFirstChild("Map")
                    and Workspace.Map:FindFirstChild("Landmarks")
                    and Workspace.Map.Landmarks:FindFirstChild("CultistGenerator")
                if cultistBase and cultistBase.PrimaryPart then
                    teleportToCFrame(cultistBase.PrimaryPart.CFrame)
                else
                    WindUI:Notify({Title="Error", Content="Cultist Generator Base tidak ditemukan!", Icon="alert-triangle"})
                end
            end
        })

        -- Teleport to Stronghold (prioritas Diamond Chest kalau ada)
        structureSec:Button({
            Title = "Teleport to Stronghold",
            Callback = function()
                local diamondChest = Workspace:FindFirstChild("Items")
                    and Workspace.Items:FindFirstChild("Stronghold Diamond Chest")
                    and Workspace.Items["Stronghold Diamond Chest"]:FindFirstChild("ChestLid")
                    and Workspace.Items["Stronghold Diamond Chest"].ChestLid:FindFirstChild("Meshes/diamondchest_Cube.005")
                if diamondChest then
                    teleportToCFrame(diamondChest.CFrame)
                    return
                end

                local sign = Workspace:FindFirstChild("Map")
                    and Workspace.Map:FindFirstChild("Landmarks")
                    and Workspace.Map.Landmarks:FindFirstChild("Stronghold")
                    and Workspace.Map.Landmarks.Stronghold:FindFirstChild("Building")
                    and Workspace.Map.Landmarks.Stronghold.Building:FindFirstChild("Sign")
                    and Workspace.Map.Landmarks.Stronghold.Building.Sign:FindFirstChild("Main")
                if sign then
                    teleportToCFrame(sign.CFrame)
                else
                    WindUI:Notify({Title="Error", Content="Stronghold tidak ditemukan!", Icon="alert-triangle"})
                end
            end
        })

        -- Teleport to Stronghold Diamond Chest (pisah button)
        structureSec:Button({
            Title = "Teleport to Stronghold Diamond Chest",
            Callback = function()
                local diamondChest = Workspace:FindFirstChild("Items")
                    and Workspace.Items:FindFirstChild("Stronghold Diamond Chest")
                    and Workspace.Items["Stronghold Diamond Chest"]:FindFirstChild("ChestLid")
                    and Workspace.Items["Stronghold Diamond Chest"].ChestLid:FindFirstChild("Meshes/diamondchest_Cube.005")
                if diamondChest then
                    teleportToCFrame(diamondChest.CFrame)
                else
                    WindUI:Notify({Title="Error", Content="Stronghold Diamond Chest tidak ditemukan!", Icon="alert-triangle"})
                end
            end
        })

        -- Teleport to Caravan
        structureSec:Button({
            Title = "Teleport to Caravan",
            Callback = function()
                local caravan = Workspace:FindFirstChild("Map")
                    and Workspace.Map:FindFirstChild("Landmarks")
                    and Workspace.Map.Landmarks:FindFirstChild("Caravan")
                if caravan and caravan.PrimaryPart then
                    teleportToCFrame(caravan.PrimaryPart.CFrame)
                else
                    WindUI:Notify({Title="Error", Content="Caravan tidak ditemukan!", Icon="alert-triangle"})
                end
            end
        })

        -- Teleport to Fairy
        structureSec:Button({
            Title = "Teleport to Fairy",
            Callback = function()
                local fairyHRP = Workspace:FindFirstChild("Map")
                    and Workspace.Map:FindFirstChild("Landmarks")
                    and Workspace.Map.Landmarks:FindFirstChild("Fairy House")
                    and Workspace.Map.Landmarks["Fairy House"]:FindFirstChild("Fairy")
                    and Workspace.Map.Landmarks["Fairy House"].Fairy:FindFirstChild("HumanoidRootPart")
                if fairyHRP then
                    teleportToCFrame(fairyHRP.CFrame)
                else
                    WindUI:Notify({Title="Error", Content="Fairy tidak ditemukan!", Icon="alert-triangle"})
                end
            end
        })

        -- Teleport to Anvil
        structureSec:Button({
            Title = "Teleport to Anvil",
            Callback = function()
                local anvil = Workspace:FindFirstChild("Map")
                    and Workspace.Map:FindFirstChild("Landmarks")
                    and Workspace.Map.Landmarks:FindFirstChild("ToolWorkshop")
                    and Workspace.Map.Landmarks.ToolWorkshop:FindFirstChild("Functional")
                    and Workspace.Map.Landmarks.ToolWorkshop.Functional:FindFirstChild("ToolBench")
                    and Workspace.Map.Landmarks.ToolWorkshop.Functional.ToolBench:FindFirstChild("Hammer")
                if anvil then
                    teleportToCFrame(anvil.CFrame)
                else
                    WindUI:Notify({Title="Error", Content="Anvil tidak ditemukan!", Icon="alert-triangle"})
                end
            end
        })
        -- FISHING TAB
        fishingTab:Paragraph({ Title = "Fishing & Macro", Desc = "Sistem fishing otomatis dengan 100% success rate (zona hijau), auto recast, dan auto clicker.", Color = "Grey" })
        fishingTab:Toggle({ Title = "100% Success Rate", Default = false, Callback = function(state) if state then startZone() else stopZone() end end })
        fishingTab:Toggle({ Title = "Auto Recast", Default = false, Callback = function(state) autoRecastEnabled = state end })
        fishingTab:Input({ Title = "Recast Delay (s)", Placeholder = "2", Default = "2", Callback = function(text) local n = tonumber(text) if n and n >= 0.01 and n <= 60 then RECAST_DELAY = n end end })
        fishingTab:Toggle({ Title = "View Position Overlay", Default = false, Callback = function(state) fishingOverlayVisible = state if state and fishingSavedPosition then fishingShowOverlay(fishingSavedPosition.x, fishingSavedPosition.y) else fishingHideOverlay() end end })
        fishingTab:Button({ Title = "Set Position", Callback = function() waitingForPosition = not waitingForPosition notifyUI("Set Position", waitingForPosition and "Klik layar untuk set posisi." or "Dibatalkan.", 3) end })
        fishingTab:Toggle({ Title = "Auto Clicker", Default = false, Callback = function(state) fishingAutoClickEnabled = state end })
        fishingTab:Input({ Title = "Delay (s)", Placeholder = "5", Default = "5", Callback = function(text) local n = tonumber(text) if n and n >= 0.01 and n <= 600 then fishingClickDelay = n end end })
        fishingTab:Button({ Title = "Calibrate", Callback = function()
            local cam = Workspace.CurrentCamera
            local cx = cam.ViewportSize.X / 2
            local cy = cam.ViewportSize.Y / 2
            notifyUI("Calibrate", "Klik titik merah di tengah layar.", 4)
            local gui = Instance.new("ScreenGui")
            gui.Name = "Xeno_Calib"
            gui.Parent = LocalPlayer.PlayerGui
            local marker = Instance.new("Frame", gui)
            marker.Size = UDim2.new(0,24,0,24)
            marker.Position = UDim2.new(0,cx-12,0,cy-12)
            marker.AnchorPoint = Vector2.new(0.5,0.5)
            marker.BackgroundColor3 = Color3.fromRGB(255,0,0)
            Instance.new("UICorner", marker).CornerRadius = UDim.new(1,0)
            local conn
            conn = UserInputService.InputBegan:Connect(function(inp,gp)
                if gp then return end
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local loc = UserInputService:GetMouseLocation()
                    fishingOffsetX = cx - loc.X
                    fishingOffsetY = cy - loc.Y
                    notifyUI("Calibrate Done", ("Offset X=%.1f Y=%.1f"):format(fishingOffsetX, fishingOffsetY), 4)
                    conn:Disconnect()
                    gui:Destroy()
                    if fishingOverlayVisible and fishingSavedPosition then fishingShowOverlay(fishingSavedPosition.x, fishingSavedPosition.y) end
                end
            end)
        end })
        fishingTab:Button({ Title = "Clean Fishing", Variant = "Destructive", Callback = function()
            fishingAutoClickEnabled = false
            waitingForPosition = false
            fishingSavedPosition = nil
            stopZone()
            fishingHideOverlay()
            pcall(function() LocalPlayer.PlayerGui.XenoPositionOverlay:Destroy() end)
            notifyUI("Fishing Clean", "Fishing features dibersihkan.", 3)
        end })

                -- FARM TAB (original)
        farmTab:Toggle({ Title = "Auto Crockpot (Carrot + Corn)", Icon = "flame", Default = false, Callback = function(state)
            if scriptDisabled then return end
            if state then
                local ok = ensureCookingStations()
                if not ok then AutoCookEnabled = false; notifyUI("Auto Crockpot", "Crock Pot / Chefs Station tidak ditemukan.", 4, "alert-triangle"); return end
                AutoCookEnabled = true; startCookLoop()
            else AutoCookEnabled = false end
        end })
        farmTab:Toggle({ Title = "Auto Scrapper → Grinder", Icon = "recycle", Default = false, Callback = function(state)
            if scriptDisabled then return end
            if state then
                local ok = ensureScrapperTarget()
                if not ok then ScrapEnabled = false; notifyUI("Auto Scrapper", "Scrapper target tidak ditemukan.", 4, "alert-triangle"); return end
                ScrapEnabled = true; startScrapLoop()
            else ScrapEnabled = false end
        end })
        farmTab:Toggle({ Title = "Auto Sacrifice Lava (Ikan & Loot)", Icon = "flame-kindling", Default = false, Callback = function(state)
            if scriptDisabled then return end
            if state and not lavaFound then notifyUI("Auto Sacrifice", "Lava belum ditemukan, script akan aktif begitu lava ready.", 4, "alert-triangle") end
            AutoSacEnabled = state
        end })
        farmTab:Toggle({ Title = "Ultra Fast Coin & Ammo", Icon = "zap", Default = false, Callback = function(state) if scriptDisabled then return end; if state then startCoinAmmo() else stopCoinAmmo() end end })
        farmTab:Paragraph({ Title = "Scrap Priority", Desc = table.concat(ScrapItemsPriority, ", "), Color = "Grey" })
        farmTab:Paragraph({ Title = "Combat Aura", Desc = "Kill Aura & Chop Aura untuk clear musuh dan tebang pohon otomatis.\nRadius bisa diatur dari 50 sampai 200.", Color = "Grey" })
        farmTab:Toggle({ Title = "Kill Aura (Radius-based)", Icon = "swords", Default = false, Callback = function(state) if scriptDisabled then return end; KillAuraEnabled = state end })
        farmTab:Slider({ Title = "Kill Aura Radius", Description = "Jarak Kill Aura (50 - 200).", Step = 1, Value = { Min = 50, Max = 200, Default = KillAuraRadius }, Callback = function(value) KillAuraRadius = tonumber(value) or KillAuraRadius end })
        farmTab:Toggle({ Title = "Chop Aura (Small Tree)", Icon = "axe", Default = false, Callback = function(state) if scriptDisabled then return end; ChopAuraEnabled = state; if state then buildTreeCache() else TreeCache = {} end end })
        farmTab:Slider({ Title = "Chop Aura Radius", Description = "Jarak tebang otomatis (50 - 200).", Step = 1, Value = { Min = 50, Max = 200, Default = ChopAuraRadius }, Callback = function(value) ChopAuraRadius = tonumber(value) or ChopAuraRadius end })

        -- TOOLS TAB (original)
        utilTab:Button({ Title = "Scan Map.Campground (Copy List)", Icon = "scan-line", Callback = function() if scriptDisabled then return end; notifyUI("Scanner", "Scan mulai... cek console / clipboard.", 4, "radar"); scanCampground() end })

        -- NIGHT TAB (original)
        nightTab:Toggle({ Title = "Auto Skip Malam (Temporal)", Icon = "moon-star", Default = false, Callback = function(state)
            if scriptDisabled then return end
            autoTemporalEnabled = state
            notifyUI("Auto Skip Malam", state and "Aktif: auto trigger saat Day naik." or "Dimatikan.", 4, state and "moon" or "toggle-left")
        end })
        nightTab:Button({ Title = "Trigger Temporal Sekali (Manual)", Icon = "zap", Callback = function() if scriptDisabled then return end; activateTemporal() end })

        -- WEBHOOK TAB (original)
        webhookTab:Input({ Title = "Discord Webhook URL", Icon = "link", Placeholder = WebhookURL, Numeric = false, Finished = false, Callback = function(txt) local t = trim(txt or "") if t ~= "" then WebhookURL = t; notifyUI("Webhook", "URL disimpan.", 3, "link"); print("WebhookURL set:", WebhookURL) end end })
        webhookTab:Input({ Title = "Webhook Username (opsional)", Icon = "user", Placeholder = WebhookUsername, Numeric = false, Finished = false, Callback = function(txt) local t = trim(txt or "") if t ~= "" then WebhookUsername = t end; notifyUI("Webhook", "Username disimpan: " .. tostring(WebhookUsername), 3, "user") end })
        webhookTab:Toggle({ Title = "Enable Webhook DayDisplay", Icon = "radio", Default = WebhookEnabled, Callback = function(state) WebhookEnabled = state; notifyUI("Webhook", state and "Webhook diaktifkan." or "Webhook dimatikan.", 3, state and "check-circle-2" or "x-circle") end })
        webhookTab:Button({ Title = "Test Send Webhook", Icon = "flask-conical", Callback = function()
            if scriptDisabled then return end
            local players = Players:GetPlayers(); local names = {}
            for _, p in ipairs(players) do table.insert(names, p.Name) end
            local payload = { username = WebhookUsername, embeds = {{ title = "🧪 TEST - Webhook Aktif " .. tostring(WebhookUsername), description = ("**Webhook Aktif %s**\n\n**Progress:** `%s`\n\n**Pemain Aktif:**\n%s"):format(tostring(WebhookUsername), tostring(currentDayCached), namesToVerticalList(names)), color = 0x2ECC71, footer = { text = "Test sent: " .. os.date("%Y-%m-%d %H:%M:%S") }}}}
            local ok, msg = sendWebhookPayload(payload)
            if ok then notifyUI("Webhook Test", "Terkirim: " .. tostring(msg), 5, "check-circle-2"); print("Webhook Test success:", msg)
            else notifyUI("Webhook Test Failed", tostring(msg), 8, "alert-triangle"); warn("Webhook Test failed:", msg) end
        end})

        -- HEALTH TAB (original)
        healthTab:Paragraph({ Title = "Cek Health Script", Desc = "Klik tombol di bawah buat lihat status terbaru:\n- Uptime\n- Lava Ready / Scanning\n- Ping\n- FPS\n- Fitur aktif (Godmode, AFK, Farm, Aura, dll)\n\nMini panel di kiri layar juga selalu update realtime.", Color = "Grey" })
        healthTab:Button({ Title = "Refresh Status Sekarang", Icon = "activity", Callback = function() if scriptDisabled then return end; local msg = getStatusSummary(); notifyUI("Status Script", msg, 7, "activity"); print("[PapiDimz] Status:\n" .. msg) end })
        
        -- Hotkey & Cleanup
        UserInputService.InputBegan:Connect(function(input, gp)
            if gp or scriptDisabled then return end
            if input.KeyCode = Enum.KeyCode.P then
                pcall(function() Window:Toggle() end)
            end
        end)
        Window:OnDestroy(resetAll)
    end)
    if not ok then
        warn("[UI Error] Gagal create UI: " .. tostring(err))
    end
end
---------------------------------------------------------
-- INIT
---------------------------------------------------------
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    defaultWalkSpeed = humanoid.WalkSpeed
    defaultHipHeight = humanoid.HipHeight
    applyWalkspeed()
    applyHipHeight()
    applyFOV()
    if flyEnabled then task.delay(0.2, startFly) end
end)
if LocalPlayer.Character then
    humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoid then defaultWalkSpeed = humanoid.WalkSpeed; defaultHipHeight = humanoid.HipHeight end
end

print("[PapiDimz] HUB Loaded - All-in-One")
splashScreen()
createMainUI()
createMiniHud()
startMiniHudLoop()
initAntiAFK()
-- INITIAL NON-BLOCKING RESOURCE WATCHERS (Dari Main.lua)
backgroundFind(ReplicatedStorage, "RemoteEvents", function(re)
    RemoteEvents = re
    notifyUI("Init", "RemoteEvents ditemukan.", 3, "radio")
    RequestStartDragging = re:FindFirstChild("RequestStartDraggingItem")
    RequestStopDragging = re:FindFirstChild("StopDraggingItem")
    CollectCoinRemote = re:FindFirstChild("RequestCollectCoints")
    ConsumeItemRemote = re:FindFirstChild("RequestConsumeItem")
    NightSkipRemote = re:FindFirstChild("RequestActivateNightSkipMachine")
    ToolDamageRemote = re:FindFirstChild("ToolDamageObject")
    EquipHandleRemote = re:FindFirstChild("EquipItemHandle")
    tryHookDayDisplay()
end)
backgroundFind(Workspace, "Items", function(it)
    ItemsFolder = it
    notifyUI("Init", "Items folder ditemukan.", 3, "archive")
end)
backgroundFind(Workspace, "Structures", function(st)
    Structures = st
    notifyUI("Init", "Structures ditemukan.", 3, "layers")
    TemporalAccelerometer = st:FindFirstChild("Temporal Accelerometer")
end)
task.spawn(function() tryHookDayDisplay() end)
startGodmodeLoop()

notifyUI("Papi Dimz |HUB", "Semua fitur loaded: Main, Local Player, Bring, Teleport, Fishing, Farm, Tools, Night, Webhook, Health", 6, "sparkles")
