--============================================================--
-- Papi Dimz | HUB (All-in-One, 2025 Final Full Merge Version)
-- Semua fitur: Local Player, Fishing, Farm, BringItem, Teleport,
-- Scrapper, Cook, Lava Sacrifice, Kill/Chop Aura, Webhook DayDisplay,
-- Mini HUD, SplashScreen "Papi Dimz :v", Anti AFK, Godmode,
-- WindUI Full Integration (Information Tab at TOP)
--============================================================--

---------------------------------------------------------
-- SERVICES
---------------------------------------------------------
local Players                = game:GetService("Players")
local ReplicatedStorage      = game:GetService("ReplicatedStorage")
local Workspace              = game:GetService("Workspace")
local RunService             = game:GetService("RunService")
local UserInputService       = game:GetService("UserInputService")
local VirtualUser            = game:GetService("VirtualUser")
local HttpService            = game:GetService("HttpService")
local Lighting               = game:GetService("Lighting")
local VirtualInputManager    = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

---------------------------------------------------------
-- UTILS
---------------------------------------------------------
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

local function notifyFallback(msg)
    print("[PapiDimz][Notify] " .. tostring(msg))
end

---------------------------------------------------------
-- LOAD WINDUI
---------------------------------------------------------
local WindUI = nil
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(
            "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
        ))()
    end)
    if ok and res then
        WindUI = res
        pcall(function()
            WindUI:SetTheme("Dark")
            WindUI.TransparencyValue = 0.20
        end)
    else
        warn("[WindUI] Gagal memuat WindUI. Menggunakan fallback.")
        WindUI = nil
    end
end

local function notifyUI(title, content, duration, icon)
    if WindUI then
        pcall(function()
            WindUI:Notify({
                Title    = title or "Info",
                Content  = content or "",
                Duration = duration or 4,
                Icon     = icon or "info"
            })
        end)
    else
        notifyFallback(title .. " | " .. content)
    end
end

---------------------------------------------------------
-- GLOBAL STATE (dipertahankan dari script lama)
---------------------------------------------------------
local scriptDisabled = false

-- Fitur umum
local GodmodeEnabled      = false
local AntiAFKEnabled      = true
local fullBrightEnabled   = false
local instantOpenEnabled  = false

-- Walking / Movement
local walkEnabled         = false
local walkSpeedValue      = 30
local defaultWalkSpeed    = 16

local hipEnabled          = false
local hipValue            = 35
local defaultHipHeight    = 2

local fovEnabled          = false
local fovValue            = 60
local defaultFOV          = Camera.FieldOfView

local flyEnabled          = false
local flyConn             = nil
local flySpeedValue       = 50
local originalTransparency = {}

local tpWalkEnabled       = false
local tpWalkSpeedValue    = 5
local tpWalkConn

local noclipManualEnabled = false
local noclipConn          = nil

local infiniteJumpEnabled = false
local infiniteJumpConn    = nil

local oldLightingProps = {
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    FogEnd         = Lighting.FogEnd,
    GlobalShadows  = Lighting.GlobalShadows,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local humanoid = nil
local rootPart = nil

---------------------------------------------------------
-- ORIGINAL FEATURE STATES
---------------------------------------------------------
local RemoteEvents          = ReplicatedStorage:FindFirstChild("RemoteEvents")
local RequestStartDragging  = nil
local RequestStopDragging   = nil
local CollectCoinRemote     = nil
local ConsumeItemRemote     = nil
local NightSkipRemote       = nil
local ToolDamageRemote      = nil
local EquipHandleRemote     = nil

local ItemsFolder           = Workspace:FindFirstChild("Items")
local Structures            = Workspace:FindFirstChild("Structures")

-- Fitur Farm
local CookingStations       = {}
local SelectedCookItems     = { "Carrot", "Corn" }
local AutoCookEnabled       = false
local CookLoopId            = 0
local CookDelaySeconds      = 10
local CookItemsPerCycle     = 5

local ScrapEnabled          = false
local ScrapLoopId           = 0
local ScrapScanInterval     = 60
local ScrapItemsPriority    = {
    "Bolt","Sheet Metal","UFO Junk","UFO Component","Broken Fan",
    "Old Radio","Broken Microwave","Tyre","Old Car Engine",
    "Cultist Gem"
}

local LavaCFrame            = nil
local lavaFound             = false
local AutoSacEnabled        = false
local SacrificeList         = {
    "Morsel","Cooked Morsel","Steak","Cooked Steak","Lava Eel",
    "Cooked Lava Eel","Lionfish","Cooked Lionfish","Cultist",
    "Crossbow Cultist","Rifle Ammo","Revolver Ammo","Bunny Foot",
    "Alpha Wolf Pelt","Wolf Pelt"
}

-- Coin & Ammo
local CoinAmmoEnabled       = false
local coinAmmoDescAddedConn = nil

-- Aura
local KillAuraEnabled       = false
local ChopAuraEnabled       = false
local KillAuraRadius        = 100
local ChopAuraRadius        = 100
local AuraAttackDelay       = 0.16
local TreeCache             = {}

local AxeIDs = {
    ["Old Axe"]    = "3_7367831688",
    ["Good Axe"]   = "112_7367831688",
    ["Strong Axe"] = "116_7367831688",
    Chainsaw       = "647_8992824875",
    Spear          = "196_8999010016"
}

-- Temporal / Night
local TemporalAccelerometer = Structures and Structures:FindFirstChild("Temporal Accelerometer")
local autoTemporalEnabled   = false
local lastProcessedDay      = nil

-- Webhook system
local WebhookURL      = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxx"
local WebhookEnabled  = true
local WebhookUsername = LocalPlayer.Name
local currentDayCached   = "N/A"
local previousDayCached  = "N/A"

local DayDisplayRemote     = nil
local DayDisplayConnection = nil

-- Fishing system (Xeno Glass)
local fishingSavedPosition    = nil
local fishingAutoClickEnabled = false
local fishingClickDelay       = 5.0
local waitingForPosition      = false

local zoneEnabled             = false
local zoneDestroyed           = false
local autoRecastEnabled       = false
local wasTimingBarVisible     = false
local lastTimingBarSeenAt     = 0
local lastRecastAt            = 0
local RECAST_DELAY            = 2
local MAX_RECENT_SECS         = 5
local fishingOverlayVisible   = false
local fishingOffsetX          = 0
local fishingOffsetY          = 0

local fishingLoopThread       = nil
local zoneSpamThread          = nil
local zoneSpamClicking        = false
local zoneSpamInterval        = 0.04
local zoneLastVisible         = false

---------------------------------------------------------
-- MINI HUD
---------------------------------------------------------
local miniHudGui     = nil
local miniHudFrame   = nil
local miniUptimeLabel = nil
local miniLavaLabel   = nil
local miniPingFpsLabel = nil
local miniFeaturesLabel = nil

local scriptStartTime = os.clock()
local currentFPS      = 0

---------------------------------------------------------
-- HELPERS FOR TREE CACHE, TABLE SET, ETC
---------------------------------------------------------
local function tableToSet(list)
    local t = {}
    for _, v in ipairs(list) do t[v] = true end
    return t
end

local function getInstancePath(inst)
    if not inst then return "nil" end
    local parts = { inst.Name }
    local p = inst.Parent
    while p and p ~= game do
        table.insert(parts, 1, p.Name)
        p = p.Parent
    end
    return table.concat(parts, ".")
end

---------------------------------------------------------
-- END OF PART 1
---------------------------------------------------------
print("[PapiDimz] PART 1 Loaded.")
---------------------------------------------------------
-- CHARACTER HELPERS
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

local function zeroVelocity(part)
    if not part then return end
    pcall(function()
        part.AssemblyLinearVelocity  = Vector3.new(0,0,0)
        part.AssemblyAngularVelocity = Vector3.new(0,0,0)
    end)
end

---------------------------------------------------------
-- APPLY FOV / Walk / Hip
---------------------------------------------------------
local function applyFOV()
    if fovEnabled then Camera.FieldOfView = fovValue else Camera.FieldOfView = defaultFOV end
end

local function applyWalkspeed()
    if humanoid and walkEnabled then
        humanoid.WalkSpeed = math.clamp(walkSpeedValue, 16, 200)
    elseif humanoid then
        humanoid.WalkSpeed = defaultWalkSpeed
    end
end

local function applyHipHeight()
    if humanoid and hipEnabled then
        humanoid.HipHeight = hipValue
    elseif humanoid then
        humanoid.HipHeight = defaultHipHeight
    end
end

---------------------------------------------------------
-- NOCLIP MANAGEMENT
---------------------------------------------------------
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

---------------------------------------------------------
-- STEALTH FLY (VERSI KAMU — TIDAK DIUBAH)
---------------------------------------------------------
local idleTrack = nil

local function playIdleAnimation()
    if idleTrack then idleTrack:Stop() end
    if not humanoid then return end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://180435571"

    idleTrack = humanoid:LoadAnimation(anim)
    idleTrack.Priority = Enum.AnimationPriority.Core
    idleTrack.Looped = true
    idleTrack:Play()
end

local function setVisibility(invisible)
    local char = getCharacter()
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or (part:IsA("MeshPart") and part.Name == "Handle") then
            if invisible then
                if originalTransparency[part] == nil then
                    originalTransparency[part] = part.Transparency
                end
                part.Transparency = 1
                part.LocalTransparencyModifier = 0
            else
                if originalTransparency[part] ~= nil then
                    part.Transparency = originalTransparency[part]
                end
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

function startFly()
    if flyEnabled or scriptDisabled then return end
    local char = getCharacter()
    humanoid = getHumanoid()
    rootPart = getRoot()
    if not char or not rootPart then return end

    flyEnabled = true

    -- save original transparency first time only
    if next(originalTransparency) == nil then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or (part:IsA("MeshPart") and part.Name == "Handle") then
                originalTransparency[part] = part.Transparency
            end
        end
    end

    -- invisible ON
    setVisibility(true)

    rootPart.Anchored = true
    humanoid.PlatformStand = true

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end

    playIdleAnimation()
    updateNoclipConnection()

    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled or not rootPart then return end

        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            move = move.Unit * flySpeedValue * dt
            rootPart.CFrame += move
        end

        rootPart.CFrame = CFrame.new(rootPart.Position) * Camera.CFrame.Rotation
        zeroVelocity(rootPart)
    end)

    notifyUI("Fly ON", "Ultimate Stealth Fly aktif!", 3, "plane")
end

function stopFly()
    if not flyEnabled then return end
    flyEnabled = false

    if flyConn then flyConn:Disconnect() flyConn = nil end
    local char = getCharacter()
    humanoid = getHumanoid()
    rootPart = getRoot()

    if idleTrack then idleTrack:Stop() idleTrack = nil end

    humanoid.PlatformStand = false
    setVisibility(false)

    local target = rootPart.CFrame
    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 30000
    bp.Position = target.Position
    bp.Parent = rootPart

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 30000
    bg.CFrame = target
    bg.Parent = rootPart

    rootPart.Anchored = false

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end

    task.delay(0.1, function()
        if bp then bp:Destroy() end
        if bg then bg:Destroy() end
    end)

    updateNoclipConnection()
    notifyUI("Fly OFF", "Fly dimatikan.", 3, "plane")
end

---------------------------------------------------------
-- TP WALK
---------------------------------------------------------
local function startTPWalk()
    if tpWalkEnabled then return end
    tpWalkEnabled = true

    tpWalkConn = RunService.RenderStepped:Connect(function(dt)
        if not tpWalkEnabled then return end
        local h = getHumanoid()
        local r = getRoot()
        if h and r and h.MoveDirection.Magnitude > 0 then
            local dist = tpWalkSpeedValue * dt * 10
            r.CFrame += h.MoveDirection.Unit * dist
        end
    end)
end

local function stopTPWalk()
    tpWalkEnabled = false
    if tpWalkConn then tpWalkConn:Disconnect() tpWalkConn = nil end
end

---------------------------------------------------------
-- INFINITE JUMP
---------------------------------------------------------
local function startInfiniteJump()
    if infiniteJumpEnabled then return end
    infiniteJumpEnabled = true

    infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled then
            getHumanoid():ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfiniteJump()
    infiniteJumpEnabled = false
    if infiniteJumpConn then infiniteJumpConn:Disconnect() infiniteJumpConn = nil end
end

---------------------------------------------------------
-- FULLBRIGHT / REMOVE FOG / REMOVE SKY
---------------------------------------------------------
local function enableFullBright()
    fullBrightEnabled = true

    for k,v in pairs(oldLightingProps) do
        oldLightingProps[k] = Lighting[k]
    end

    local function apply()
        if not fullBrightEnabled then return end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e9
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end

    apply()
    RunService:BindToRenderStep("FULLBRIGHT_LOOP", 1000, apply)
end

local function disableFullBright()
    fullBrightEnabled = false
    RunService:UnbindFromRenderStep("FULLBRIGHT_LOOP")

    for k,v in pairs(oldLightingProps) do
        Lighting[k] = v
    end
end

local function removeFog()
    Lighting.FogEnd = 1e9
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo then
        atmo.Density = 0
        atmo.Haze    = 0
    end
    notifyUI("Fog Removed", "Fog dihapus.", 3, "wind")
end

local function removeSky()
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end
    notifyUI("Sky Removed", "Skybox dihapus.", 3, "cloud-off")
end

---------------------------------------------------------
-- INSTANT OPEN (ProximityPrompt)
---------------------------------------------------------
local promptOriginalHold = {}
local promptConn = nil

local function applyInstantOpenToPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        if promptOriginalHold[prompt] == nil then
            promptOriginalHold[prompt] = prompt.HoldDuration
        end
        prompt.HoldDuration = 0
    end
end

local function enableInstantOpen()
    instantOpenEnabled = true

    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("ProximityPrompt") then applyInstantOpenToPrompt(inst) end
    end

    if promptConn then promptConn:Disconnect() end
    promptConn = Workspace.DescendantAdded:Connect(function(inst)
        if instantOpenEnabled and inst:IsA("ProximityPrompt") then
            applyInstantOpenToPrompt(inst)
        end
    end)

    notifyUI("Instant Open", "Semua ProximityPrompt menjadi instant.", 3, "bolt")
end

local function disableInstantOpen()
    instantOpenEnabled = false

    if promptConn then promptConn:Disconnect() promptConn = nil end
    for prompt, orig in pairs(promptOriginalHold) do
        pcall(function()
            if prompt and prompt.Parent then prompt.HoldDuration = orig end
        end)
    end
    promptOriginalHold = {}

    notifyUI("Instant Open", "Durasi dikembalikan.", 3, "refresh-ccw")
end

---------------------------------------------------------
-- SPLASH SCREEN "Papi Dimz :v"
---------------------------------------------------------
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
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.fromRGB(10,10,10)
        bg.BackgroundTransparency = 1
        bg.BorderSizePixel = 0
        bg.Parent = g

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 42
        label.TextColor3 = Color3.fromRGB(230,230,230)
        label.Text = ""
        label.TextStrokeTransparency = 0.75
        label.Parent = bg

        task.spawn(function()
            local dur = 0.35
            local t = 0
            while t < dur do
                t += RunService.Heartbeat:Wait()
                bg.BackgroundTransparency = 1 - (t / dur * 0.9)
            end
            bg.BackgroundTransparency = 0.1
        end)

        local text = "Papi Dimz :v"
        for i = 1, #text do
            label.Text = text:sub(1,i)
            task.wait(0.05)
        end

        task.wait(1.2)
        local durOut = 0.3
        local t = 0
        while t < durOut do
            t += RunService.Heartbeat:Wait()
            label.TextTransparency = t / durOut
            bg.BackgroundTransparency = 0.1 + (t / durOut)
        end

        g:Destroy()
    end)
end

---------------------------------------------------------
-- MINI HUD
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

    return #t > 0 and table.concat(t, " | ") or "None"
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
    miniHudFrame.Size = UDim2.fromOffset(220, 95)
    miniHudFrame.Position = UDim2.new(0,20,0,100)
    miniHudFrame.BackgroundColor3 = Color3.fromRGB(10,10,10)
    miniHudFrame.BackgroundTransparency = 0.3
    miniHudFrame.Active = true
    miniHudFrame.Draggable = true
    miniHudFrame.Parent = miniHudGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = miniHudFrame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = miniHudFrame

    local function makeLabel(y)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1,-10,0,18)
        lbl.Position = UDim2.new(0,5,0,y)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.Text = ""
        lbl.Parent = miniHudFrame
        return lbl
    end

    miniUptimeLabel    = makeLabel(4)
    miniLavaLabel      = makeLabel(24)
    miniPingFpsLabel   = makeLabel(44)
    miniFeaturesLabel  = makeLabel(64)
end

local function startMiniHudLoop()
    scriptStartTime = os.clock()

    task.spawn(function()
        local last = tick()
        while not scriptDisabled do
            local now = tick()
            local dt  = now - last
            last = now
            if dt > 0 then currentFPS = math.floor(1/dt + 0.5) end
            RunService.Heartbeat:Wait()
        end
    end)

    task.spawn(function()
        while not scriptDisabled do
            local uptime = formatTime(os.clock() - scriptStartTime)
            local pingMs = math.floor((LocalPlayer:GetNetworkPing() or 0) * 1000 + 0.5)
            local lavaStr = lavaFound and "Ready" or "Scan"

            if miniUptimeLabel then miniUptimeLabel.Text = "UP : " .. uptime end
            if miniLavaLabel then miniLavaLabel.Text = "LV : " .. lavaStr end
            if miniPingFpsLabel then
                miniPingFpsLabel.Text = string.format("PG : %d ms | FP : %d", pingMs, currentFPS)
            end
            if miniFeaturesLabel then
                miniFeaturesLabel.Text = "FT : " .. getFeatureCodes()
            end

            task.wait(1)
        end
    end)
end

---------------------------------------------------------
-- ANTI AFK
---------------------------------------------------------
local function initAntiAFK()
    LocalPlayer.Idled:Connect(function()
        if not AntiAFKEnabled or scriptDisabled then return end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

---------------------------------------------------------
-- END OF PART 2
---------------------------------------------------------
print("[PapiDimz] PART 2 Loaded.")
---------------------------------------------------------
-- FARM SYSTEM — CROCKPOT / SCRAPPER / SACRIFICE / COIN
---------------------------------------------------------
local function ensureCookingStations()
    local structures = Workspace:FindFirstChild("Structures")
    if not structures then
        CookingStations = {}
        warn("[Cook] workspace.Structures tidak ditemukan.")
        return false
    end

    local stations = {}
    local crock = structures:FindFirstChild("Crock Pot")
    local chef  = structures:FindFirstChild("Chefs Station")

    if crock then table.insert(stations, crock) end
    if chef  then table.insert(stations, chef) end

    if #stations == 0 then
        CookingStations = {}
        warn("[Cook] Tidak ada Crock Pot / Chefs Station.")
        return false
    end

    CookingStations = stations
    return true
end

local function getStationBase(station)
    if not station then return nil end
    return station.PrimaryPart or station:FindFirstChildOfClass("BasePart")
end

local function getCookDropCFrame(base, index)
    local radius = 2
    local height = 3
    local angle = (index - 1) * (math.pi / 4)

    return CFrame.new(
        base.Position + Vector3.new(
            math.cos(angle) * radius,
            height,
            math.sin(angle) * radius
        )
    )
end

local function collectCookCandidates(basePart, targetSet, maxCount)
    local best = {}

    if not ItemsFolder then return {} end

    for _, item in ipairs(ItemsFolder:GetChildren()) do
        if item:IsA("Model")
            and item.PrimaryPart
            and targetSet[item.Name]
            and not string.find(item.Name, "Item Chest")
        then
            local dist = (item.PrimaryPart.Position - basePart.Position).Magnitude
            table.insert(best, {instance = item, distance = dist})
        end
    end

    table.sort(best, function(a,b) return a.distance < b.distance end)
    local result = {}
    for i = 1, math.min(maxCount, #best) do
        table.insert(result, best[i])
    end
    return result
end

local function cookOnce()
    if not AutoCookEnabled then return end

    if not SelectedCookItems or #SelectedCookItems == 0 then return end
    if not CookingStations or #CookingStations == 0 then return end

    local targetSet = {}
    for _, v in ipairs(SelectedCookItems) do targetSet[v] = true end

    for _, station in ipairs(CookingStations) do
        if station and station.Parent then
            local base = getStationBase(station)
            if base then
                local candidates = collectCookCandidates(base, targetSet, CookItemsPerCycle)

                for i, entry in ipairs(candidates) do
                    local item = entry.instance
                    if item and item.Parent then
                        local drop = getCookDropCFrame(base, i)

                        pcall(function() RequestStartDragging:FireServer(item) end)
                        task.wait(0.03)

                        pcall(function() item:PivotTo(drop) end)
                        task.wait(0.03)

                        pcall(function() RequestStopDragging:FireServer(item) end)
                        task.wait(0.03)
                    end
                end
            end
        end
    end
end

local function startCookLoop()
    CookLoopId += 1
    local id = CookLoopId

    task.spawn(function()
        while AutoCookEnabled and id == CookLoopId and not scriptDisabled do
            cookOnce()
            task.wait(math.clamp(CookDelaySeconds, 5, 20))
        end
    end)
end

---------------------------------------------------------
-- SCRAPPER (AUTO GRINDER)
---------------------------------------------------------
local function ensureScrapperTarget()
    if ScrapperTarget and ScrapperTarget.Parent then return true end

    local map = Workspace:FindFirstChild("Map")
    if not map then ScrapperTarget = nil return false end

    local camp = map:FindFirstChild("Campground")
    if not camp then ScrapperTarget = nil return false end

    local scr = camp:FindFirstChild("Scrapper")
    if not scr then ScrapperTarget = nil return false end

    local movers = scr:FindFirstChild("Movers")
    if not movers then ScrapperTarget = nil return false end

    local right = movers:FindFirstChild("Right")
    if not right then ScrapperTarget = nil return false end

    local grind = right:FindFirstChild("GrindersRight")
    if not grind or not grind:IsA("BasePart") then
        ScrapperTarget = nil
        return false
    end

    ScrapperTarget = grind
    return true
end

local function getScrapDropCFrame(base, index)
    local radius = 1.5
    local height = 6
    local angle = (index - 1) * (math.pi / 6)
    return CFrame.new(
        base.Position + Vector3.new(
            math.cos(angle) * radius,
            height,
            math.sin(angle) * radius
        )
    )
end

local function scrapOnceFullPass()
    if not ScrapEnabled then return end
    if not ensureScrapperTarget() then return end

    local base = ScrapperTarget
    if not base then return end

    for _, name in ipairs(ScrapItemsPriority) do
        if not ScrapEnabled then return end

        local batch = {}
        for _, item in ipairs(ItemsFolder:GetChildren()) do
            if item:IsA("Model") and item.PrimaryPart and item.Name == name then
                table.insert(batch, item)
            end
        end

        table.sort(batch, function(a,b)
            return (a.PrimaryPart.Position - base.Position).Magnitude <
                   (b.PrimaryPart.Position - base.Position).Magnitude
        end)

        for i, item in ipairs(batch) do
            if not ScrapEnabled then return end

            local drop = getScrapDropCFrame(base, i)

            pcall(function() RequestStartDragging:FireServer(item) end)
            task.wait(0.02)

            pcall(function() item:PivotTo(drop) end)
            task.wait(0.02)

            pcall(function() RequestStopDragging:FireServer(item) end)
            task.wait(0.02)
        end
    end
end

local function startScrapLoop()
    ScrapLoopId += 1
    local id = ScrapLoopId

    task.spawn(function()
        while ScrapEnabled and id == ScrapLoopId and not scriptDisabled do
            scrapOnceFullPass()
            task.wait(math.clamp(ScrapScanInterval, 10, 300))
        end
    end)
end

---------------------------------------------------------
-- LAVA SACRIFICE
---------------------------------------------------------
local function findLava()
    if lavaFound then return end

    local map = Workspace:FindFirstChild("Map")
    if not map then return end

    local land = map:FindFirstChild("Landmarks")
    if not land then return end

    local vol = land:FindFirstChild("Volcano")
    if not vol then return end

    local func = vol:FindFirstChild("Functional")
    if not func then return end

    local lava = func:FindFirstChild("Lava")
    if lava and lava:IsA("BasePart") then
        LavaCFrame = lava.CFrame * CFrame.new(0, 4, 0)
        lavaFound = true
        notifyUI("Lava Ready", "Lava ditemukan!", 4, "flame")
    end
end

task.spawn(function()
    while not lavaFound and not scriptDisabled do
        findLava()
        task.wait(1.5)
    end
end)

local function sacrificeItemToLava(item)
    if not AutoSacEnabled then return end
    if not item or not item.Parent or not item:IsA("Model") or not item.PrimaryPart then return end
    if not lavaFound or not LavaCFrame then return end

    if not table.find(SacrificeList, item.Name) then return end

    pcall(function() RequestStartDragging:FireServer(item) end)
    task.wait(0.1)

    local offset = CFrame.new(math.random(-6, 6), 0, math.random(-6, 6))
    pcall(function() item:PivotTo(LavaCFrame * offset) end)

    task.wait(0.2)
    pcall(function() RequestStopDragging:FireServer(item) end)
end

task.spawn(function()
    while not scriptDisabled do
        if AutoSacEnabled and lavaFound and ItemsFolder then
            for _, itm in ipairs(ItemsFolder:GetChildren()) do
                sacrificeItemToLava(itm)
            end
        end
        task.wait(0.7)
    end
end)

---------------------------------------------------------
-- ULTRA COIN / AMMO
---------------------------------------------------------
local function stopCoinAmmo()
    CoinAmmoEnabled = false
    if coinAmmoDescAddedConn then coinAmmoDescAddedConn:Disconnect() end
    if CoinAmmoConnection then CoinAmmoConnection:Disconnect() end
end

local function startCoinAmmo()
    stopCoinAmmo()
    CoinAmmoEnabled = true

    task.spawn(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if not CoinAmmoEnabled then break end
            
            pcall(function()
                if v.Name == "Coin Stack" and CollectCoinRemote then
                    CollectCoinRemote:InvokeServer(v)
                elseif (v.Name == "Revolver Ammo" or v.Name == "Rifle Ammo") and ConsumeItemRemote then
                    ConsumeItemRemote:InvokeServer(v)
                end
            end)
        end

        notifyUI("Ultra Coin", "Mendengarkan spawn coin baru...", 4, "zap")

        coinAmmoDescAddedConn = Workspace.DescendantAdded:Connect(function(desc)
            if not CoinAmmoEnabled then return end
            task.wait(0.02)

            pcall(function()
                if desc.Name == "Coin Stack" and CollectCoinRemote then
                    CollectCoinRemote:InvokeServer(desc)
                elseif (desc.Name == "Revolver Ammo" or desc.Name == "Rifle Ammo") and ConsumeItemRemote then
                    ConsumeItemRemote:InvokeServer(desc)
                end
            end)
        end)
    end)
end

---------------------------------------------------------
-- COMBAT — KILL AURA & CHOP AURA
---------------------------------------------------------
local function buildTreeCache()
    TreeCache = {}

    local map = Workspace:FindFirstChild("Map")
    if not map then return end

    local function scan(folder)
        if not folder then return end
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj.Name == "Small Tree" and obj:FindFirstChild("Trunk") then
                table.insert(TreeCache, obj)
            end
        end
    end

    scan(map:FindFirstChild("Foliage"))
    scan(map:FindFirstChild("Landmarks"))
end

local function GetBestAxe(forTree)
    for name, id in pairs(AxeIDs) do
        if (not forTree) or (name ~= "Chainsaw" and name ~= "Spear") then
            local inv = LocalPlayer:FindFirstChild("Inventory")
            if inv then
                local tool = inv:FindFirstChild(name)
                if tool then return tool, id end
            end
        end
    end
    return nil, nil
end

local function EquipAxe(tool)
    if tool and EquipHandleRemote then
        pcall(function()
            EquipHandleRemote:FireServer("FireAllClients", tool)
        end)
    end
end

-- HEARTBEAT AURA ENGINE
auraHeartbeatConnection = RunService.Heartbeat:Connect(function()
    if scriptDisabled then return end
    if not KillAuraEnabled and not ChopAuraEnabled then return end

    local now = tick()
    if now < (nextAuraTick or 0) then return end
    nextAuraTick = now + AuraAttackDelay

    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -------------------------------------------------
    -- KILL AURA
    -------------------------------------------------
    if KillAuraEnabled then
        local axe, axeId = GetBestAxe(false)
        if axe and axeId and ToolDamageRemote then
            EquipAxe(axe)

            local folder = Workspace:FindFirstChild("Characters")
            if folder then
                for _, target in ipairs(folder:GetChildren()) do
                    if target ~= char and target:IsA("Model") then
                        local root = target:FindFirstChildWhichIsA("BasePart")
                        if root and (root.Position - hrp.Position).Magnitude <= KillAuraRadius then
                            pcall(function()
                                ToolDamageRemote:InvokeServer(
                                    target, axe, axeId,
                                    CFrame.new(root.Position)
                                )
                            end)
                        end
                    end
                end
            end
        end
    end

    -------------------------------------------------
    -- CHOP AURA
    -------------------------------------------------
    if ChopAuraEnabled then
        if #TreeCache == 0 then buildTreeCache() end

        local axe = GetBestAxe(true)
        if axe and ToolDamageRemote then
            EquipAxe(axe)

            for i = #TreeCache, 1, -1 do
                local tree = TreeCache[i]
                if tree and tree.Parent and tree:FindFirstChild("Trunk") then
                    local trunk = tree.Trunk

                    if (trunk.Position - hrp.Position).Magnitude <= ChopAuraRadius then
                        pcall(function()
                            ToolDamageRemote:InvokeServer(
                                tree, axe, "999_7367831688",
                                CFrame.new(-2.96, 4.55, -75.95)
                            )
                        end)
                    end

                else
                    table.remove(TreeCache, i)
                end
            end
        end
    end
end)

---------------------------------------------------------
-- TEMPORAL ACCELEROMETER (Manual + Auto Skip)
---------------------------------------------------------
local function activateTemporal()
    if scriptDisabled then return end

    if not TemporalAccelerometer or not TemporalAccelerometer.Parent then
        local structures = Workspace:FindFirstChild("Structures")
        if structures then
            TemporalAccelerometer = structures:FindFirstChild("Temporal Accelerometer")
        end
    end

    if not TemporalAccelerometer then
        notifyUI("Temporal", "Tidak ditemukan!", 4, "alert-triangle")
        return
    end

    if NightSkipRemote then
        NightSkipRemote:FireServer(TemporalAccelerometer)
    end
end

---------------------------------------------------------
-- DAYDISPLAY WEBHOOK SYSTEM (Original)
---------------------------------------------------------
local function namesToVerticalList(names)
    local t = {}
    for _, n in ipairs(names) do
        table.insert(t, "- " .. tostring(n))
    end
    return table.concat(t, "\n")
end

local function try_http(url, body)
    if syn and syn.request then
        return pcall(function()
            return syn.request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"]="application/json"},
                Body = body
            })
        end)
    elseif request then
        return pcall(function()
            return request({
                Url = url,
                Method = "POST",
                Headers = {["Content-Type"]="application/json"},
                Body = body
            })
        end)
    else
        return pcall(function()
            return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
        end)
    end
end

local function buildDayEmbed(cur, prev, beds, kids, list, isTest)
    local players = Players:GetPlayers()
    local names = {}
    for _, p in ipairs(players) do table.insert(names, p.Name) end

    local embed = {
        title = (isTest and "🧪 TEST - " or "") .. "🌅 DAY UPDATE " .. tostring(cur),
        description = table.concat({
            "✨ **Ringkasan Hari**",
            "",
            string.format("📆 **%s → %s** (Δ %s)", tostring(prev), tostring(cur), tostring((cur-prev))),
            string.format("🛏️ Beds: %s | 👶 Kids: %s", beds, kids),
            "",
            "🎮 **Players Online:** " .. tostring(#names),
            namesToVerticalList(names),
            "",
            "📦 **Items**:",
            (type(list)=="table" and table.concat(list, "\n") or "_No data_")
        },"\n"),
        color = 0xFAA61A
    }

    return {
        username = WebhookUsername,
        embeds = { embed }
    }
end

local function sendWebhook(payload)
    if not WebhookURL or WebhookURL == "" then return end
    local body = HttpService:JSONEncode(payload)
    local ok,result = try_http(WebhookURL, body)
end

local function tryHookDayDisplay()
    if DayDisplayConnection then DayDisplayConnection:Disconnect() end

    local function attach(remote)
        DayDisplayRemote = remote
        DayDisplayConnection = remote.OnClientEvent:Connect(function(...)
            if scriptDisabled then return end

            local args = {...}
            if #args == 1 then
                local day = args[1]
                if autoTemporalEnabled and day ~= lastProcessedDay then
                    lastProcessedDay = day
                    task.delay(5, function()
                        if autoTemporalEnabled then activateTemporal() end
                    end)
                end
                return
            end

            local cur  = tonumber(args[1]) or args[1]
            local prev = tonumber(args[2]) or args[2]
            local items = args[3]

            if cur > prev then
                local beds,kids = 0,0
                if type(items)=="table" then
                    for _,v in ipairs(items) do
                        local s = v:lower()
                        if s:find("bed") then beds=beds+1 end
                        if s:find("kid") then kids=kids+1 end
                    end
                end

                local payload = buildDayEmbed(cur, prev, beds, kids, items, false)
                if WebhookEnabled then
                    sendWebhook(payload)
                    notifyUI("Webhook Sent", "Day "..prev.." → "..cur, 4, "radio")
                end
            end
        end)
    end

    local found = RemoteEvents and RemoteEvents:FindFirstChild("DayDisplay")
    if found then attach(found) return end

    local found2 = ReplicatedStorage:FindFirstChild("DayDisplay")
    if found2 then attach(found2) return end

    task.spawn(function()
        for i=1,80 do
            if scriptDisabled then return end
            local re = RemoteEvents and RemoteEvents:FindFirstChild("DayDisplay")
            if re then attach(re) return end

            local rr = ReplicatedStorage:FindFirstChild("DayDisplay")
            if rr then attach(rr) return end

            task.wait(0.25)
        end
    end)
end

task.spawn(function()
    tryHookDayDisplay()
end)

print("[PapiDimz] PART 3 Loaded.")
---------------------------------------------------------
-- PART 4 — UI SYSTEM (WindUI All Tabs)
---------------------------------------------------------

---------------------------------------------------------
-- WINDOW CREATION
---------------------------------------------------------
local Window = WindUI:CreateWindow({
    Title = "Papi Dimz |HUB",
    Icon = "gamepad-2",
    Author = "Bang Dimz",
    Folder = "PapiDimzHub_Config",
    Size = UDim2.fromOffset(620, 560),
    Theme = "Dark",
    Acrylic = true,
    SideBarWidth = 175,
})

Window:EditOpenButton({
    Title = "Papi Dimz | HUB",
    Icon = "sparkles",
    CornerRadius = UDim.new(0, 14),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(255,180,95), Color3.fromRGB(255,120,85)),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

---------------------------------------------------------
-- GLOBAL TOGGLE STATE
---------------------------------------------------------
local currentKeybind = Enum.KeyCode.P
local scriptEnabled = true

---------------------------------------------------------
-- TAB 1: INFORMATION (PALING ATAS)
---------------------------------------------------------
local infoTab = Window:Tab({
    Title = "Information",
    Icon = "info"
})

infoTab:Paragraph({
    Title = "Welcome To Papi Dimz Hub Official",
    Desc = "Powerful all-in-one utility + automation hub for all Survival: 99 Nights content. Explore every feature with stable performance!",
    Color = "Blue"
})

-- Copy Discord Link
infoTab:Button({
    Title = "Copy Discord Link",
    Icon = "clipboard",
    Callback = function()
        setclipboard("discord.gg/PapiDimz")
        notifyUI("Copied!", "Discord link copied to clipboard", 3, "check")
    end
})

-- Keybind
infoTab:Keybind({
    Title = "Papi Dimz Keybind",
    Default = Enum.KeyCode.P,
    Callback = function(k)
        currentKeybind = k
        notifyUI("Keybind Updated", "Open/Close UI = ".. tostring(k), 3, "keyboard")
    end
})

-- Listen for keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == currentKeybind then
        Window:Toggle()
    end
end)

-- Force Close
infoTab:Button({
    Title = "Force Close Hub",
    Icon = "power",
    Variant = "Destructive",
    Callback = function()
        scriptDisabled = true
        resetAll()
        Window:Unload()
    end
})

---------------------------------------------------------
-- TAB 2: MAIN
---------------------------------------------------------
local mainTab = Window:Tab({
    Title = "Main",
    Icon = "home"
})

mainTab:Paragraph({
    Title = "Hub Status",
    Desc = "All main modules are active. Explore the tabs to enable features.",
    Color = "Grey"
})

-- Toggle Godmode
mainTab:Toggle({
    Title = "Godmode",
    Default = false,
    Callback = function(v)
        GodmodeEnabled = v
        notifyUI("Godmode", v and "Enabled" or "Disabled", 3, "shield")
    end
})

-- Anti AFK
mainTab:Toggle({
    Title = "Anti AFK",
    Default = true,
    Callback = function(v)
        AntiAFKEnabled = v
        notifyUI("Anti AFK", v and "Enabled" or "Disabled", 3, "wifi")
    end
})

-- Mini HUD
mainTab:Toggle({
    Title = "Mini HUD",
    Default = false,
    Callback = function(v)
        if v then
            createMiniHud()
            startMiniHudLoop()
        else
            if miniHudGui then miniHudGui:Destroy() miniHudGui = nil end
        end
    end
})

---------------------------------------------------------
-- TAB 3: LOCAL PLAYER
---------------------------------------------------------
local localTab = Window:Tab({
    Title = "Local Player",
    Icon = "user"
})

---------------- Movement Section ----------------
local moveSec = localTab:Section({
    Title = "Movement",
    Icon = "move"
})

moveSec:Toggle({
    Title = "Walkspeed",
    Default = false,
    Callback = function(v)
        walkEnabled = v
        applyWalkspeed()
    end
})

moveSec:Slider({
    Title = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 30,
    Callback = function(v)
        walkSpeedValue = v
        applyWalkspeed()
    end
})

moveSec:Toggle({
    Title = "Hip Height",
    Default = false,
    Callback = function(v)
        hipEnabled = v
        applyHipHeight()
    end
})

moveSec:Slider({
    Title = "Hip Height Value",
    Min = 2,
    Max = 60,
    Default = 35,
    Callback = function(v)
        hipValue = v
        applyHipHeight()
    end
})

moveSec:Toggle({
    Title = "Fly (Stealth Mode)",
    Default = false,
    Callback = function(v)
        if v then startFly() else stopFly() end
        updateNoclipConnection()
    end
})

moveSec:Slider({
    Title = "Fly Speed",
    Min = 5,
    Max = 200,
    Default = 50,
    Callback = function(v)
        flySpeedValue = v
    end
})

moveSec:Toggle({
    Title = "TP Walk",
    Default = false,
    Callback = function(v)
        if v then startTPWalk() else stopTPWalk() end
    end
})

moveSec:Slider({
    Title = "TP Walk Speed",
    Min = 1,
    Max = 50,
    Default = 5,
    Callback = function(v)
        tpWalkSpeedValue = v
    end
})

moveSec:Toggle({
    Title = "Noclip",
    Default = false,
    Callback = function(v)
        noclipManualEnabled = v
        updateNoclipConnection()
    end
})

moveSec:Toggle({
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v)
        if v then startInfiniteJump() else stopInfiniteJump() end
    end
})


---------------- Visual Section ----------------
local visualSec = localTab:Section({
    Title = "Visual",
    Icon = "eye"
})

visualSec:Toggle({
    Title = "Full Bright",
    Default = false,
    Callback = function(v)
        if v then enableFullBright() else disableFullBright() end
    end
})

visualSec:Toggle({
    Title = "Remove Fog",
    Default = false,
    Callback = function(v)
        if v then removeFog() end
    end
})

visualSec:Toggle({
    Title = "Remove Sky",
    Default = false,
    Callback = function(v)
        if v then removeSky() end
    end
})


---------------- Utility Section ----------------
local utilLocal = localTab:Section({
    Title = "Utility",
    Icon = "wrench"
})

utilLocal:Toggle({
    Title = "Instant Open (Prompt)",
    Default = false,
    Callback = function(v)
        if v then enableInstantOpen() else disableInstantOpen() end
    end
})

utilLocal:Slider({
    Title = "Camera FOV",
    Min = 50,
    Max = 120,
    Default = 60,
    Callback = function(v)
        fovValue = v
        applyFOV()
    end
})

utilLocal:Toggle({
    Title = "Enable FOV Effect",
    Default = false,
    Callback = function(v)
        fovEnabled = v
        applyFOV()
    end
})

---------------------------------------------------------
-- TAB 4: FISHING
---------------------------------------------------------
local fishingTab = Window:Tab({
    Title = "Fishing",
    Icon = "fish"
})

local fsMain = fishingTab:Section({
    Title = "Fishing System",
    Icon = "fishing-hook",
    DefaultOpen = true
})

fsMain:Toggle({
    Title = "Auto Fishing (Spam Click)",
    Default = false,
    Callback = function(v)
        fishingAutoClickEnabled = v
        wasTimingBarVisible = false
        lastTimingBarSeenAt = 0
    end
})

fsMain:Slider({
    Title = "Click Delay (s)",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(v)
        fishingClickDelay = v
    end
})

local recastSec = fishingTab:Section({
    Title = "Auto Recast",
    Icon = "rotate-ccw"
})

recastSec:Toggle({
    Title = "Enable Auto Recast",
    Default = false,
    Callback = function(v)
        autoRecastEnabled = v
    end
})

recastSec:Slider({
    Title = "Recast Delay (s)",
    Min = 1,
    Max = 10,
    Default = 2,
    Callback = function(v)
        RECAST_DELAY = v
    end
})

local zoneSec = fishingTab:Section({
    Title = "Green Zone",
    Icon = "target"
})

zoneSec:Toggle({
    Title = "Enable Green Zone",
    Default = false,
    Callback = function(v)
        zoneEnabled = v
    end
})

zoneSec:Slider({
    Title = "Spam Interval",
    Min = 0.02,
    Max = 0.2,
    Default = 0.04,
    Callback = function(v)
        zoneSpamInterval = v
    end
})

zoneSec:Toggle({
    Title = "Overlay Visible",
    Default = false,
    Callback = function(v)
        fishingOverlayVisible = v
    end
})

---------------------------------------------------------
-- PART 4A END
---------------------------------------------------------

print("[PapiDimz] PART 4A Loaded.")
---------------------------------------------------------
-- TAB 5: BRING ITEM  (VERSI ASLI KAMU — TIDAK DIUBAH)
---------------------------------------------------------
local bringTab = Window:Tab({
    Title = "Bring Item",
    Icon = "package-search"
})

bringTab:Paragraph({
    Title = "Bring Item System",
    Desc = "Tarik item tertentu ke posisi kamu. Menggunakan list item asli dari script kamu.",
    Color = "Grey"
})

-- Input Item
bringTab:Input({
    Title = "Nama Item",
    Placeholder = "Contoh: Carrot",
    Numeric = false,
    TextDisappear = false,
    Callback = function(txt)
        _G.BringItemName = txt
    end
})

-- Button Bring Item
bringTab:Button({
    Title = "Bring Item",
    Icon = "box",
    Callback = function()
        if not _G.BringItemName or _G.BringItemName == "" then
            notifyUI("Bring Item", "Nama item belum diisi!", 3, "alert-triangle")
            return
        end
        pcall(function()
            BringItem(_G.BringItemName)
        end)
    end
})

-- List item dari script kamu yang lama
bringTab:Paragraph({
    Title = "Item List",
    Desc = table.concat(BringItemList, ", "),
    Color = "Blue"
})


---------------------------------------------------------
-- TAB 6: TELEPORT  (VERSI ASLI KAMU — TIDAK DIUBAH)
---------------------------------------------------------
local teleTab = Window:Tab({
    Title = "Teleport",
    Icon = "navigation"
})

teleTab:Paragraph({
    Title = "Teleport Area",
    Desc = "Teleport cepat ke berbagai lokasi penting.",
    Color = "Grey"
})

for name, cframe in pairs(TeleportLocations) do
    teleTab:Button({
        Title = name,
        Icon = "map-pin",
        Callback = function()
            TeleportTo(cframe)
        end
    })
end


---------------------------------------------------------
-- TAB 7: FARM (Auto Cook / Scrap / Lava)
---------------------------------------------------------
local farmTab = Window:Tab({
    Title = "Farm",
    Icon = "chef-hat"
})

---------------- AUTO COOK ----------------
local cookSec = farmTab:Section({
    Title = "Auto Crockpot",
    Icon = "cooking-pot"
})

cookSec:Toggle({
    Title = "Enable Auto Cook",
    Default = false,
    Callback = function(v)
        AutoCookEnabled = v
        if v then
            ensureCookingStations()
            startCookLoop()
            notifyUI("Auto Cook", "Cooking started", 3, "flame")
        else
            notifyUI("Auto Cook", "Stopped", 3, "circle-off")
        end
    end
})

cookSec:Slider({
    Title = "Delay per cycle (sec)",
    Min = 5,
    Max = 20,
    Default = 10,
    Callback = function(v)
        CookDelaySeconds = v
    end
})

cookSec:Slider({
    Title = "Items per batch",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(v)
        CookItemsPerCycle = v
    end
})

cookSec:Paragraph({
    Title = "Selected Items",
    Desc = table.concat(SelectedCookItems, ", "),
    Color = "Grey"
})


---------------- AUTO SCRAP ----------------
local scrapSec = farmTab:Section({
    Title = "Auto Scrapper",
    Icon = "recycle"
})

scrapSec:Toggle({
    Title = "Enable Auto Scrap",
    Default = false,
    Callback = function(v)
        ScrapEnabled = v
        if v then
            ensureScrapperTarget()
            startScrapLoop()
            notifyUI("Auto Scrap", "Scrapping items...", 3, "recycle")
        else
            notifyUI("Auto Scrap", "Scrapper stopped", 3, "circle-off")
        end
    end
})

scrapSec:Paragraph({
    Title = "Scrap Order",
    Desc = table.concat(ScrapItemsPriority, ", "),
    Color = "Grey"
})


---------------- AUTO SACRIFICE LAVA ----------------
local lavaSec = farmTab:Section({
    Title = "Auto Sacrifice Lava",
    Icon = "flame-kindling"
})

lavaSec:Toggle({
    Title = "Sacrifice Enabled",
    Default = false,
    Callback = function(v)
        AutoSacEnabled = v
        if v then
            notifyUI("Lava Sacrifice", "Waiting for lava...", 3, "flame")
        end
    end
})


---------------- COIN + AMMO ----------------
local coinSec = farmTab:Section({
    Title = "Coin & Ammo",
    Icon = "zap"
})

coinSec:Toggle({
    Title = "Ultra Coin & Ammo",
    Default = false,
    Callback = function(v)
        if v then
            startCoinAmmo()
        else
            stopCoinAmmo()
        end
    end
})

---------------- AURA SYSTEM ----------------
local auraSec = farmTab:Section({
    Title = "Combat Aura",
    Icon = "swords"
})

auraSec:Toggle({
    Title = "Kill Aura",
    Default = false,
    Callback = function(v)
        KillAuraEnabled = v
    end
})

auraSec:Slider({
    Title = "Kill Radius",
    Min = 50,
    Max = 200,
    Default = 100,
    Callback = function(v)
        KillAuraRadius = v
    end
})

auraSec:Toggle({
    Title = "Chop Aura",
    Default = false,
    Callback = function(v)
        ChopAuraEnabled = v
        if v then buildTreeCache() end
    end
})

auraSec:Slider({
    Title = "Chop Radius",
    Min = 50,
    Max = 200,
    Default = 100,
    Callback = function(v)
        ChopAuraRadius = v
    end
})


---------------------------------------------------------
-- TAB 8: TOOLS
---------------------------------------------------------
local toolsTab = Window:Tab({
    Title = "Tools",
    Icon = "wrench"
})

toolsTab:Button({
    Title = "Scan Campground (Copy)",
    Icon = "scan-line",
    Callback = function()
        scanCampground()
        notifyUI("Scanner", "Scan copied to clipboard", 3, "copy")
    end
})


---------------------------------------------------------
-- TAB 9: NIGHT
---------------------------------------------------------
local nightTab = Window:Tab({
    Title = "Night",
    Icon = "moon"
})

nightTab:Toggle({
    Title = "Auto Skip Night",
    Default = false,
    Callback = function(v)
        autoTemporalEnabled = v
        notifyUI("Temporal", v and "Auto enabled" or "Disabled", 3, "moon")
    end
})

nightTab:Button({
    Title = "Trigger Temporal NOW",
    Icon = "zap",
    Callback = function()
        activateTemporal()
    end
})

print("[PapiDimz] PART 4B Loaded.")
---------------------------------------------------------
-- TAB 10: WEBHOOK (FULL ORIGINAL)
---------------------------------------------------------
local webhookTab = Window:Tab({
    Title = "Webhook",
    Icon = "radio"
})

webhookTab:Paragraph({
    Title = "Discord Webhook Sender",
    Desc = "Pakai Webhook untuk mengirim update DayDisplay dan status game.",
    Color = "Grey"
})

-- INPUT: WEBHOOK URL
webhookTab:Input({
    Title = "Webhook URL",
    Placeholder = WebhookURL,
    Numeric = false,
    Finished = false,
    Callback = function(txt)
        local t = trim(txt or "")
        if t ~= "" then
            WebhookURL = t
            notifyUI("Webhook", "URL updated!", 3, "link")
        end
    end
})

-- INPUT: USERNAME
webhookTab:Input({
    Title = "Webhook Username",
    Placeholder = WebhookUsername,
    Numeric = false,
    TextDisappear = false,
    Callback = function(txt)
        local t = trim(txt or "")
        if t ~= "" then
            WebhookUsername = t
            notifyUI("Webhook", "Username updated!", 3, "user")
        end
    end
})

webhookTab:Toggle({
    Title = "Enable Webhook DayDisplay",
    Default = WebhookEnabled,
    Callback = function(state)
        WebhookEnabled = state
        notifyUI("Webhook", state and "Enabled" or "Disabled", 3, state and "check" or "x")
    end
})

-- TEST SEND
webhookTab:Button({
    Title = "Test Send Webhook",
    Icon = "flask-conical",
    Callback = function()
        local players = Players:GetPlayers()
        local names = {}
        for _, p in ipairs(players) do table.insert(names, p.Name) end

        local payload = {
            username = WebhookUsername,
            embeds = {{
                title = "🧪 TEST — Webhook Online",
                description = "**Players Online:**\n" .. namesToVerticalList(names),
                color = 0x2ECC71,
                footer = { text = os.date("Sent at %Y-%m-%d %H:%M:%S") }
            }}
        }

        local ok, msg = sendWebhookPayload(payload)
        if ok then
            notifyUI("Webhook Test", "Success: "..tostring(msg), 4, "check")
        else
            notifyUI("Webhook Failed", tostring(msg), 6, "alert-triangle")
        end
    end
})


---------------------------------------------------------
-- TAB 11: HEALTH CHECK
---------------------------------------------------------
local healthTab = Window:Tab({
    Title = "Cek Health",
    Icon = "activity"
})

healthTab:Paragraph({
    Title = "Status Script Realtime",
    Desc = "Cek uptime, ping, FPS, lava status, fitur aktif dan lain-lain.",
    Color = "Grey"
})

healthTab:Button({
    Title = "Refresh Now",
    Icon = "refresh-cw",
    Callback = function()
        local msg = getStatusSummary()
        notifyUI("Script Status", msg, 6, "activity")
        print("[PapiDimz] Status:\n"..msg)
    end
})

---------------------------------------------------------
-- CLEANUP & DESTROY HANDLING
---------------------------------------------------------
Window:OnDestroy(function()
    if not scriptDisabled then
        resetAll()
    end
end)


---------------------------------------------------------
-- KEYBIND TOGGLE (DEFAULT: P)
---------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or scriptDisabled then return end
    if input.KeyCode == currentKeybind then
        Window:Toggle()
    end
end)


---------------------------------------------------------
-- SPLASH SCREEN + UI STARTUP
---------------------------------------------------------
task.wait(0.25)
splashScreen()

notifyUI("Papi Dimz | HUB", "Semua fitur loaded sukses!", 5, "sparkles")

print("[PapiDimz] UI Build Complete — All Tabs Active.")
