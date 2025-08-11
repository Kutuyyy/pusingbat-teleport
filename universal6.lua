----https://chatgpt.com/c/68985bf8-76b4-8325-b145-39421e01fda5
--[[
    Pusingbat Hub — Server-only (Ngrok) + Vector3 JSON Patch + Import Panel (Load/Delete)
    Tabs: Main • Misc • Teleport • Config

    ▶︎ Letakkan sebagai LocalScript di StarterPlayer > StarterPlayerScripts
]]--

-- ========== KONFIG SERVER ==========
local SERVER_BASE = "https://deep-factual-goat.ngrok-free.app"  -- GANTI dengan URL ngrok kamu
local API_KEY     = "asdasdasdasdasdasdasdasd"             -- GANTI dengan API key server.py kamu

-- ========== Services ==========
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local USERNAME = LocalPlayer and LocalPlayer.Name or "unknown"

-- ========== Util ==========
local function dprint(...) -- aktifkan jika perlu
    -- print("[PB]", ...)
end

-- HTTP helper untuk executor (synapse/krnl/etc)
local function rawRequest(opts)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        return req({
            Url = opts.Url,
            Method = opts.Method or "GET",
            Headers = opts.Headers or {},
            Body = opts.Body
        })
    else
        if (opts.Method or "GET") == "GET" and not opts.Body then
            local ok, body = pcall(function()
                return game:HttpGet(opts.Url)
            end)
            if ok then return { StatusCode = 200, Body = body } end
        end
        return { StatusCode = 0, Body = "" }
    end
end

local function jsonEncode(t) return HttpService:JSONEncode(t) end
local function jsonDecode(s) local ok,res=pcall(function() return HttpService:JSONDecode(s) end); return ok and res or nil end

-- ========== Vector3 <-> JSON ==========
local function packVec3(v)
    if typeof(v) == "Vector3" then
        return { x = v.X, y = v.Y, z = v.Z }
    elseif type(v) == "table" and v.x and v.y and v.z then
        return { x = v.x, y = v.y, z = v.z }
    end
    return nil
end
local function unpackVec3(t)
    if typeof(t) == "Vector3" then return t end
    if type(t) == "table" and t.x and t.y and t.z then
        return Vector3.new(t.x, t.y, t.z)
    end
    return nil
end
local function normalizeExportsForSend(exports)
    local out = {}
    for setName, arr in pairs(exports or {}) do
        local packedArr = {}
        for _, loc in ipairs(arr) do
            local p = packVec3(loc.position)
            if p then table.insert(packedArr, { name = loc.name, position = p }) end
        end
        out[setName] = packedArr
    end
    return out
end

-- ========== State ==========
local MIN_WALK, MAX_WALK = 8, 200
local MIN_JUMP, MAX_JUMP = 25, 300
local walkSpeed = 16
local jumpPower = 50

local fly = false
local noclip = false
local infJumpMobile = false
local infJumpPC = false
local noFallDamage = false

-- Misc
local fullBright = false
local removeFog = false
local defaultFOV = 70

local char, root, hum
local lv, align
local lastFreefallHealth, lastFreefallT

-- Lighting originals
local savedLighting
local savedAtmos

-- Teleport (lokal, export/import ke server)
local savedLocations = {}
local exportedSets = {} -- name -> array { {name, position:{x,y,z}}, ... }
local autoRespawnAfterTour = false

-- Configs via server
local configs = {}
local autoloadName = nil
local serverOnline = false

-- ========== HWID ==========
local function getHWID()
    local id
    pcall(function()
        if syn and syn.get_hwid then id = syn.get_hwid() return end
        if gethwid then id = gethwid() return end
        if get_hwid then id = get_hwid() return end
        id = RbxAnalyticsService:GetClientId()
    end)
    id = tostring(id or (LocalPlayer and LocalPlayer.UserId) or "unknown")
    id = id:gsub("[^%w%-_]", "-")
    return id
end
local HWID = getHWID()

-- ========== API Client ==========
local function apiHeaders()
    return { ["Content-Type"] = "application/json", ["X-API-Key"] = API_KEY }
end
local function apiGetUser(hwid)
    local res = rawRequest({
        Url = string.format("%s/v1/users/%s", SERVER_BASE, hwid),
        Method = "GET",
        Headers = apiHeaders()
    })
    if res and res.StatusCode == 200 then return true, jsonDecode(res.Body) end
    dprint("GET /v1/users status:", res and res.StatusCode, "body:", res and res.Body)
    return false, res
end

local function apiPutUser(hwid, bodyTbl)
    local res = rawRequest({
        Url = string.format("%s/v1/users/%s", SERVER_BASE, hwid),
        Method = "PUT",
        Headers = apiHeaders(),
        Body = jsonEncode(bodyTbl)
    })
    return (res and res.StatusCode == 200) and true or false, res
end
local function apiPostUsage(username, hwid)
    local res = rawRequest({
        Url = string.format("%s/v1/usage", SERVER_BASE),
        Method = "POST",
        Headers = apiHeaders(),
        Body = jsonEncode({ username = username, hwid = hwid })
    })
    return (res and res.StatusCode == 200)
end

local function tryLoadFromServer()
    local ok, dataOrRes = apiGetUser(HWID)
    if not ok then
        serverOnline = false
        dprint("Server offline atau error saat GET user. Cek StatusCode di log di atas.")
        return
    end
    local data = dataOrRes
    serverOnline = true
    autoloadName = data.autoload
    configs = data.configs or {}
    exportedSets = data.exports or {}
    apiPostUsage(USERNAME, HWID)
end


-- ========== Character helpers ==========
local function getCharacter()
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
    return char, root, hum
end
local function ensurePhysics()
    if not hum then return end
    hum.WalkSpeed = walkSpeed
    pcall(function() hum.UseJumpPower = true end)
    hum.JumpPower = jumpPower
    local g = workspace.Gravity
    local h = (jumpPower * jumpPower) / math.max(2*g, 1)
    pcall(function() hum.JumpHeight = h end)
end
local function cleanupFly()
    if lv then lv:Destroy() lv = nil end
    if align then align:Destroy() align = nil end
end
local function attachFly()
    getCharacter()
    cleanupFly()
    lv = Instance.new("LinearVelocity")
    lv.Name = "FlyVelocity"
    lv.Attachment0 = root:WaitForChild("RootAttachment")
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.MaxForce = math.huge
    lv.VectorVelocity = Vector3.zero
    lv.Enabled = false
    lv.Parent = root
    ensurePhysics()
end

-- ========== Fly ==========
local function setFly(state)
    fly = state and true or false
    if not hum then return end
    if fly then
        if not align then
            align = Instance.new("AlignOrientation")
            align.Name = "FlyAlign"
            align.RigidityEnabled = true
            align.Responsiveness = 200
            align.Mode = Enum.OrientationAlignmentMode.OneAttachment
            align.Attachment0 = root:WaitForChild("RootAttachment")
            align.CFrame = root.CFrame
            align.Parent = root
        end
        hum.AutoRotate = false
        hum.PlatformStand = true
        if lv then lv.Enabled = true end
    else
        if lv then
            lv.VectorVelocity = Vector3.zero
            lv.Enabled = false
        end
        if align then align:Destroy() align = nil end
        hum.PlatformStand = false
        hum.AutoRotate = true
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

RunService.RenderStepped:Connect(function()
    if not fly or not root or not hum or not lv then return end
    local cam = workspace.CurrentCamera
    if not cam then return end

    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector
    local flatLook = Vector3.new(look.X, 0, look.Z)
    local flatRight = Vector3.new(right.X, 0, right.Z)
    if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
    if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end

    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + flatLook end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - flatLook end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - flatRight end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + flatRight end

    local vertical = 0
    if UIS:IsKeyDown(Enum.KeyCode.Space) then vertical = 1 end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vertical = -1 end

    local vSpeed = walkSpeed * 0.9
    local velocity = Vector3.new(0, vertical * vSpeed, 0)
    if dir.Magnitude > 0 then
        velocity = velocity + dir.Unit * walkSpeed
    end
    lv.VectorVelocity = velocity
    root.AssemblyAngularVelocity = Vector3.zero
end)

-- ========== Noclip ==========
local function setNoclip(state) noclip = state and true or false end
RunService.Stepped:Connect(function()
    if not char or not root then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if noclip then part.CanCollide = false end
        end
    end
    if not noclip and root then root.CanCollide = true end
end)

-- ========== Inf Jump ==========
UIS.JumpRequest:Connect(function()
    if not hum then return end
    if UIS.TouchEnabled and infJumpMobile then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    elseif (not UIS.TouchEnabled) and infJumpPC then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and (not UIS.TouchEnabled) and infJumpPC and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ========== No Fall Damage ==========
local function hookFallDamage()
    if not hum then return end
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Freefall then
            lastFreefallHealth = hum.Health
            lastFreefallT = tick()
        elseif new == Enum.HumanoidStateType.Landed then
            if noFallDamage and lastFreefallHealth and hum.Health < lastFreefallHealth then
                hum.Health = math.max(hum.Health, lastFreefallHealth)
            end
        end
    end)
    hum.HealthChanged:Connect(function(h)
        if noFallDamage and lastFreefallT and (tick() - lastFreefallT) < 2.5 then
            if lastFreefallHealth and h < lastFreefallHealth then hum.Health = lastFreefallHealth end
        else
            lastFreefallHealth = h
        end
    end)
end

-- ========== MISC ==========
local function setFullBright(state)
    fullBright = state and true or false
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if fullBright then
        if not savedLighting then
            savedLighting = {
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                GlobalShadows = Lighting.GlobalShadows,
                FogEnd = Lighting.FogEnd,
                FogStart = Lighting.FogStart,
            }
            if atm then savedAtmos = {Density = atm.Density, Haze = atm.Haze, Color = atm.Color} end
        end
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.GlobalShadows = false
        Lighting.FogStart = 0
        Lighting.FogEnd = 1e6
        if atm then atm.Density = 0; atm.Haze = 0 end
    else
        if savedLighting then
            Lighting.Brightness = savedLighting.Brightness
            Lighting.ClockTime = savedLighting.ClockTime
            Lighting.Ambient = savedLighting.Ambient
            Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
            Lighting.GlobalShadows = savedLighting.GlobalShadows
            Lighting.FogStart = savedLighting.FogStart
            Lighting.FogEnd = savedLighting.FogEnd
        end
        if savedAtmos then
            local a = Lighting:FindFirstChildOfClass("Atmosphere")
            if a then a.Density = savedAtmos.Density; a.Haze = savedAtmos.Haze; a.Color = savedAtmos.Color end
        end
    end
end

local function setRemoveFog(state)
    removeFog = state and true or false
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if removeFog then
        Lighting.FogStart = 0
        Lighting.FogEnd = 1e6
        if atm then atm.Density = 0; atm.Haze = 0 end
    else
        if not fullBright and savedLighting then
            Lighting.FogStart = savedLighting.FogStart
            Lighting.FogEnd = savedLighting.FogEnd
            if savedAtmos then
                local a = Lighting:FindFirstChildOfClass("Atmosphere")
                if a then a.Density = savedAtmos.Density; a.Haze = savedAtmos.Haze end
            end
        end
    end
end

local function setFOV(value)
    defaultFOV = value
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = defaultFOV end
end

-- ========== UI ==========
local MainGUI
local ShowPillGUI

-- ========= Shared Teleport Settings (mode, duration, easing) =========
-- dipakai oleh teleport ke Player dan teleport ke Location
local tpMode = "Instant"
local tweenDuration = 1.0
local easeStyles = {
    {"QuadOut",  Enum.EasingStyle.Quad,    Enum.EasingDirection.Out},
    {"QuadIn",   Enum.EasingStyle.Quad,    Enum.EasingDirection.In},
    {"SineOut",  Enum.EasingStyle.Sine,    Enum.EasingDirection.Out},
    {"Linear",   Enum.EasingStyle.Linear,  Enum.EasingDirection.InOut},
    {"BackOut",  Enum.EasingStyle.Back,    Enum.EasingDirection.Out},
    {"CubicOut", Enum.EasingStyle.Cubic,   Enum.EasingDirection.Out},
}
local easeIdx = 1
local teleporting = false
local function teleportToPosition(dest)
    if not root then return end
    if tpMode == "Instant" then
        root.CFrame = CFrame.new(dest)
        return
    end
    if teleporting then return end
    teleporting = true
    local wasFly = fly
    if wasFly then setFly(false) end
    local info = TweenInfo.new(
        math.max(0.05, tweenDuration),
        easeStyles[easeIdx][2],
        easeStyles[easeIdx][3],
        0,false,0
    )
    local tw = TweenService:Create(root, info, {CFrame = CFrame.new(dest)})
    tw:Play()
    tw.Completed:Connect(function()
        teleporting = false
        if wasFly then setFly(true) end
    end)
end

local function teleportToPositionAndWait(dest)
    if not root then return end
    if tpMode == "Instant" then
        root.CFrame = CFrame.new(dest)
        return
    end

    local wasFly = fly
    if wasFly then setFly(false) end
    local info = TweenInfo.new(
        math.max(0.05, tweenDuration),
        easeStyles[easeIdx][2],
        easeStyles[easeIdx][3],
        0,false,0
    )
    local tw = TweenService:Create(root, info, {CFrame = CFrame.new(dest)})
    tw:Play()
    -- tunggu tween selesai
    pcall(function() tw.Completed:Wait() end)
    if wasFly then setFly(true) end
end

local function showPill()
    if ShowPillGUI then ShowPillGUI:Destroy() end
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "PusingPill"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(160, 46)
    btn.Position = UDim2.new(0, 20, 0, 80)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,48)
    btn.TextColor3 = Color3.fromRGB(230,230,240)
    btn.Text = "Show Pusing"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BorderSizePixel = 0
    btn.Parent = sg
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)

    btn.MouseButton1Click:Connect(function()
        if MainGUI then MainGUI.Enabled = true end
        if ShowPillGUI then ShowPillGUI:Destroy() ShowPillGUI=nil end
    end)

    ShowPillGUI = sg
end

local function createUI()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- Loading overlay 5 detik
    local overlay = Instance.new("ScreenGui")
    overlay.Name = "PusingbatLoading"
    overlay.ResetOnSpawn = false
    overlay.IgnoreGuiInset = true
    overlay.Parent = PlayerGui

    local dim = Instance.new("Frame")
    dim.Size = UDim2.fromScale(1,1)
    dim.BackgroundColor3 = Color3.new(0,0,0)
    dim.BackgroundTransparency = 0.5
    dim.BorderSizePixel = 0
    dim.Parent = overlay

    local textBg = Instance.new("Frame")
    textBg.AnchorPoint = Vector2.new(0.5,0.5)
    textBg.Position = UDim2.fromScale(0.5,0.5)
    textBg.Size = UDim2.fromOffset(520,100)
    textBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    textBg.BackgroundTransparency = 0.5
    textBg.BorderSizePixel = 0
    textBg.Parent = overlay
    Instance.new("UICorner", textBg).CornerRadius = UDim.new(0,18)

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.Text = "Created by Pusingbat"
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 42
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.Parent = textBg

    -- Panel utama
    if MainGUI then MainGUI:Destroy() end
    MainGUI = Instance.new("ScreenGui")
    MainGUI.Name = "PusingbatController"
    MainGUI.ResetOnSpawn = false
    MainGUI.IgnoreGuiInset = true
    MainGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGUI.Parent = PlayerGui
    MainGUI.Enabled = false

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.fromOffset(420, 360)
    frame.Position = UDim2.new(0, 24, 0, 120)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = true
    frame.Parent = MainGUI
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Parent = frame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -220, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Text = "Created by pusingbat"
    title.Parent = header

    local searchBtn = Instance.new("ImageButton")
    searchBtn.Size = UDim2.fromOffset(26, 26)
    searchBtn.Position = UDim2.new(1, -96, 0.5, -13)
    searchBtn.BackgroundTransparency = 1
    searchBtn.Image = "rbxassetid://6031075938"
    searchBtn.ImageColor3 = Color3.fromRGB(220,220,220)
    searchBtn.Parent = header

    local btnMin = Instance.new("TextButton")
    btnMin.Size = UDim2.fromOffset(26, 26)
    btnMin.Position = UDim2.new(1, -64, 0.5, -13)
    btnMin.Text = "–"
    btnMin.Font = Enum.Font.GothamBlack
    btnMin.TextSize = 18
    btnMin.TextColor3 = Color3.fromRGB(255,255,255)
    btnMin.BackgroundColor3 = Color3.fromRGB(70,70,80)
    btnMin.BorderSizePixel = 0
    btnMin.Parent = header
    Instance.new("UICorner", btnMin).CornerRadius = UDim.new(1,0)

    local btnClose = Instance.new("TextButton")
    btnClose.Size = UDim2.fromOffset(26, 26)
    btnClose.Position = UDim2.new(1, -32, 0.5, -13)
    btnClose.Text = "x"
    btnClose.Font = Enum.Font.GothamBlack
    btnClose.TextSize = 16
    btnClose.TextColor3 = Color3.fromRGB(255,255,255)
    btnClose.BackgroundColor3 = Color3.fromRGB(90,50,50)
    btnClose.BorderSizePixel = 0
    btnClose.Parent = header
    Instance.new("UICorner", btnClose).CornerRadius = UDim.new(1,0)

    -- Search panel
    local searchPanel = Instance.new("Frame")
    searchPanel.Size = UDim2.fromOffset(220, 36)
    searchPanel.Position = UDim2.new(1, -346, 0, 42)
    searchPanel.BackgroundColor3 = Color3.fromRGB(45,45,50)
    searchPanel.Visible = false
    searchPanel.Parent = frame
    Instance.new("UICorner", searchPanel).CornerRadius = UDim.new(0, 8)

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -12, 1, -12)
    searchBox.Position = UDim2.new(0, 6, 0, 6)
    searchBox.BackgroundColor3 = Color3.fromRGB(55,55,60)
    searchBox.PlaceholderText = "Search feature"
    searchBox.Text = ""
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 14
    searchBox.TextColor3 = Color3.fromRGB(230,230,230)
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchPanel
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

    searchBtn.MouseButton1Click:Connect(function()
        searchPanel.Visible = not searchPanel.Visible
        if searchPanel.Visible then searchBox:CaptureFocus() end
    end)

    -- Drag area
    local drag = Instance.new("Frame")
    drag.BackgroundTransparency = 1
    drag.Size = UDim2.new(1, -240, 1, 0)
    drag.Position = UDim2.new(0, 0, 0, 0)
    drag.Parent = header

    -- Tabs
    local tabs = Instance.new("Frame")
    tabs.Size = UDim2.new(1, -16, 0, 30)
    tabs.Position = UDim2.new(0, 8, 0, 44)
    tabs.BackgroundTransparency = 1
    tabs.Parent = frame

    local function makeTabButton(text, xOffset)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(100, 28)
        b.Position = UDim2.new(0, xOffset, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(45,45,50)
        b.TextColor3 = Color3.fromRGB(230,230,230)
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.BorderSizePixel = 0
        b.Parent = tabs
        Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
        return b
    end

    local tabMainBtn = makeTabButton("Main", 0)
    local tabMiscBtn = makeTabButton("Misc", 108)
    local tabTpBtn   = makeTabButton("Teleport", 216)
    local tabCfgBtn  = makeTabButton("Config", 324)

    -- Scroll builder
    local function makeScroll()
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -16, 1, -88)
        scroll.Position = UDim2.new(0, 8, 0, 78)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        scroll.ScrollBarThickness = 6
        scroll.Visible = false
        scroll.ClipsDescendants = true
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
        scroll.Parent = frame

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingBottom = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 4)
        pad.PaddingRight = UDim.new(0, 4)
        pad.Parent = scroll

        local function recalc()
            scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + pad.PaddingBottom.Offset)
        end
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(recalc)
        return scroll, layout, recalc
    end

    local mainScroll, _, recalcMain = makeScroll()
    local miscScroll, _, recalcMisc = makeScroll()
    local tpScroll, _, recalcTp = makeScroll()
    local cfgScroll, _, recalcCfg = makeScroll()

    local function createRow(parent, height)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, height)
        row.BackgroundColor3 = Color3.fromRGB(38,38,42)
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        return row
    end

    local function makeSwitch(parent, labelText, initial, callback)
        local row = createRow(parent, 40)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -120, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(235,235,235)
        lbl.Text = labelText
        lbl.Parent = row

        local switch = Instance.new("Frame")
        switch.Size = UDim2.fromOffset(58, 24)
        switch.Position = UDim2.new(1, -70, 0.5, -12)
        switch.BackgroundColor3 = initial and Color3.fromRGB(60,180,75) or Color3.fromRGB(120,120,120)
        switch.BorderSizePixel = 0
        switch.Parent = row
        Instance.new("UICorner", switch).CornerRadius = UDim.new(1,0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(20,20)
        knob.Position = initial and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob.BorderSizePixel = 0
        knob.Parent = switch
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local value = initial
        local function redraw()
            switch.BackgroundColor3 = value and Color3.fromRGB(60,180,75) or Color3.fromRGB(120,120,120)
            knob:TweenPosition(value and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        end
        switch.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                value = not value
                redraw()
                if callback then task.spawn(callback, value) end
            end
        end)

        row:SetAttribute("label", labelText)
        return {Row=row, Set=function(v) value=v and true or false; redraw(); if callback then task.spawn(callback, value) end end}
    end

    local function makeSlider(parent, labelText, minV, maxV, initial, callback)
        local row = createRow(parent, 58)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.Position = UDim2.new(0, 10, 0, 6)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(235,235,235)
        lbl.Text = string.format("%s: %d", labelText, initial)
        lbl.Parent = row

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -20, 0, 8)
        bar.Position = UDim2.new(0, 10, 0, 34)
        bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
        bar.BorderSizePixel = 0
        bar.Parent = row
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0,8)

        local pct0 = (initial - minV) / (maxV - minV)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(pct0, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,8)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(18,18)
        knob.Position = UDim2.new(pct0, -9, 0.5, -9)
        knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
        knob.BorderSizePixel = 0
        knob.Parent = bar
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local dragging = false
        local function setFromPct(pct)
            pct = math.clamp(pct, 0, 1)
            local val = math.floor(minV + (maxV - minV) * pct + 0.5)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -9, 0.5, -9)
            lbl.Text = string.format("%s: %d", labelText, val)
            if callback then callback(val) end
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                setFromPct(rel)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                setFromPct(rel)
            end
        end)
        bar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        row:SetAttribute("label", labelText)
        return {Row=row, Set=function(v) local pct=(math.clamp(v,minV,maxV)-minV)/(maxV-minV); setFromPct(pct) end}
    end

-- ===== MAIN =====
    local flySw = makeSwitch(mainScroll, "Fly", false, function(v) setFly(v) end)
    local ncSw  = makeSwitch(mainScroll, "NoClip (tembus)", false, function(v) setNoclip(v) end)
    local wsSl  = makeSlider(mainScroll, "Walk Speed (studs)", MIN_WALK, MAX_WALK, walkSpeed, function(v) walkSpeed = v; ensurePhysics() end)
    local jpSl  = makeSlider(mainScroll, "Jump Power (studs)", MIN_JUMP, MAX_JUMP, jumpPower, function(v) jumpPower = v; ensurePhysics() end)
    local ijmSw = makeSwitch(mainScroll, "Inf Jump (Mobile)", false, function(v) infJumpMobile = v end)
    local ijpSw = makeSwitch(mainScroll, "Inf Jump (PC)", false, function(v) infJumpPC = v end)
    local nfdSw = makeSwitch(mainScroll, "No Fall Damage", false, function(v) noFallDamage = v end)

    -- ===== MISC =====
    local fbSw  = makeSwitch(miscScroll, "Fullbright (Terang Terus)", false, function(v) setFullBright(v) end)
    local fovSl = makeSlider(miscScroll, "Field of View", 60, 120, defaultFOV, function(v) setFOV(v) end)
    local rfSw  = makeSwitch(miscScroll, "Remove Fog", false, function(v) setRemoveFog(v) end)

    -- ===== TELEPORT =====
    local function createTpRow(h) 
        return createRow(tpScroll, h) 
    end

    -- ====== TOUR SNAPSHOT ======
    local tourList = {}  -- { {name=string, pos=Vector3}, ... }

    local function setTour(list)
        tourList = list or {}
    end
    ----------------------------------------------------------------
    -- Teleport to Player (Picker + Distance + Mode/Duration/Easing)
    ----------------------------------------------------------------
    local tpToPlayerTitle = createTpRow(28)
    tpToPlayerTitle.BackgroundTransparency = 1
    local tptpLabel = Instance.new("TextLabel")
    tptpLabel.BackgroundTransparency = 1
    tptpLabel.Size = UDim2.new(1, -20, 1, 0)
    tptpLabel.Position = UDim2.new(0,10,0,0)
    tptpLabel.Text = "Teleport to Player"
    tptpLabel.TextColor3 = Color3.new(1,1,1)
    tptpLabel.TextXAlignment = Enum.TextXAlignment.Left
    tptpLabel.Font = Enum.Font.GothamBold
    tptpLabel.TextSize = 14
    tptpLabel.Parent = tpToPlayerTitle

    local pickerRow = createTpRow(56)
    pickerRow:SetAttribute("label","Teleport to Player")

    local playerNameLbl = Instance.new("TextLabel")
    playerNameLbl.BackgroundTransparency = 1
    playerNameLbl.Size = UDim2.new(1, -140, 0.5, -2)
    playerNameLbl.Position = UDim2.new(0, 10, 0, 4)
    playerNameLbl.Text = "Target: (belum dipilih)"
    playerNameLbl.TextColor3 = Color3.fromRGB(235,235,235)
    playerNameLbl.TextXAlignment = Enum.TextXAlignment.Left
    playerNameLbl.Font = Enum.Font.Gotham
    playerNameLbl.TextSize = 15
    playerNameLbl.Parent = pickerRow

    local distanceLbl = Instance.new("TextLabel")
    distanceLbl.BackgroundTransparency = 1
    distanceLbl.Size = UDim2.new(1, -140, 0.5, -2)
    distanceLbl.Position = UDim2.new(0, 10, 0.5, 0)
    distanceLbl.Text = "Distance: -"
    distanceLbl.TextColor3 = Color3.fromRGB(200,200,200)
    distanceLbl.TextXAlignment = Enum.TextXAlignment.Left
    distanceLbl.Font = Enum.Font.Gotham
    distanceLbl.TextSize = 13
    distanceLbl.Parent = pickerRow

    local pickBtn = Instance.new("TextButton")
    pickBtn.Size = UDim2.new(0, 100, 0, 26)
    pickBtn.Position = UDim2.new(1, -120, 0, 6)
    pickBtn.Text = "Pilih Player"
    pickBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
    pickBtn.TextColor3 = Color3.new(1,1,1)
    pickBtn.BorderSizePixel = 0
    pickBtn.Parent = pickerRow
    Instance.new("UICorner", pickBtn).CornerRadius = UDim.new(0,6)

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0, 100, 0, 26)
    refreshBtn.Position = UDim2.new(1, -120, 0, 30)
    refreshBtn.Text = "Refresh"
    refreshBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
    refreshBtn.TextColor3 = Color3.new(1,1,1)
    refreshBtn.BorderSizePixel = 0
    refreshBtn.Parent = pickerRow
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,6)

    local selectedPlayerName = nil
    local function openPlayerPopup()
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        local pop = Instance.new("ScreenGui")
        pop.Name = "PB_PlayerPicker"
        pop.ResetOnSpawn = false
        pop.Parent = pg

        local f = Instance.new("Frame")
        f.Size = UDim2.fromOffset(300, 320)
        f.Position = UDim2.new(0.5, -150, 0.5, -160)
        f.BackgroundColor3 = Color3.fromRGB(45,45,50)
        f.BorderSizePixel = 0
        f.Parent = pop
        f.ClipsDescendants = true
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -12, 0, 30)
        title.Position = UDim2.new(0,6,0,6)
        title.BackgroundColor3 = Color3.fromRGB(70,70,70)
        title.Text = "Pilih Player"
        title.TextColor3 = Color3.new(1,1,1)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.Parent = f
        Instance.new("UICorner", title).CornerRadius = UDim.new(0,6)

        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(1, -12, 1, -80)
        list.Position = UDim2.new(0,6,0,42)
        list.BackgroundTransparency = 1
        list.ScrollBarThickness = 6
        list.ClipsDescendants = true
        list.Parent = f
        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0,6)
        lay.Parent = list

        local close = Instance.new("TextButton")
        close.Size = UDim2.new(1, -12, 0, 30)
        close.Position = UDim2.new(0,6,1,-36)
        close.Text = "Tutup"
        close.BackgroundColor3 = Color3.fromRGB(90,60,60)
        close.TextColor3 = Color3.new(1,1,1)
        close.Parent = f
        Instance.new("UICorner", close).CornerRadius = UDim.new(0,6)

        local function build()
            for _,ch in ipairs(list:GetChildren()) do
                if ch:IsA("TextButton") then ch:Destroy() end
            end
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(1, -4, 0, 28)
                    b.Text = plr.Name
                    b.BackgroundColor3 = Color3.fromRGB(60,60,70)
                    b.TextColor3 = Color3.new(1,1,1)
                    b.Parent = list
                    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
                    b.MouseButton1Click:Connect(function()
                        selectedPlayerName = plr.Name
                        playerNameLbl.Text = "Target: "..selectedPlayerName
                        pop:Destroy()
                    end)
                end
            end
        end
        build()
        close.MouseButton1Click:Connect(function() pop:Destroy() end)
    end

    pickBtn.MouseButton1Click:Connect(openPlayerPopup)
    refreshBtn.MouseButton1Click:Connect(function()
        if selectedPlayerName then
            playerNameLbl.Text = "Target: "..selectedPlayerName
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not tpScroll.Visible then return end
        if selectedPlayerName and root then
            local target = Players:FindFirstChild(selectedPlayerName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local d = (root.Position - target.Character.HumanoidRootPart.Position).Magnitude
                distanceLbl.Text = string.format("Distance: %.1f studs", d)
            else
                distanceLbl.Text = "Distance: -"
            end
        else
            distanceLbl.Text = "Distance: -"
        end
    end)

    -- Mode Instant / Tween
    local modeRow = createTpRow(40)
    local modeLbl = Instance.new("TextLabel")
    modeLbl.BackgroundTransparency = 1
    modeLbl.Size = UDim2.new(1, -140, 1, 0)
    modeLbl.Position = UDim2.new(0,10,0,0)
    modeLbl.Text = "Mode Teleport"
    modeLbl.TextColor3 = Color3.fromRGB(235,235,235)
    modeLbl.TextXAlignment = Enum.TextXAlignment.Left
    modeLbl.Font = Enum.Font.Gotham
    modeLbl.TextSize = 16
    modeLbl.Parent = modeRow

    local modeInstant = Instance.new("TextButton")
    modeInstant.Size = UDim2.new(0, 86, 0, 26)
    modeInstant.Position = UDim2.new(1, -196, 0.5, -13)
    modeInstant.Text = "Instant"
    modeInstant.BackgroundColor3 = Color3.fromRGB(0,120,0)
    modeInstant.TextColor3 = Color3.new(1,1,1)
    modeInstant.Parent = modeRow
    Instance.new("UICorner", modeInstant).CornerRadius = UDim.new(0,6)

    local modeTween = Instance.new("TextButton")
    modeTween.Size = UDim2.new(0, 86, 0, 26)
    modeTween.Position = UDim2.new(1, -100, 0.5, -13)
    modeTween.Text = "Tween"
    modeTween.BackgroundColor3 = Color3.fromRGB(70,70,70)
    modeTween.TextColor3 = Color3.new(1,1,1)
    modeTween.Parent = modeRow
    Instance.new("UICorner", modeTween).CornerRadius = UDim.new(0,6)

    local function setMode(m)
        tpMode = m
        modeInstant.BackgroundColor3 = (m=="Instant") and Color3.fromRGB(0,120,0) or Color3.fromRGB(70,70,70)
        modeTween.BackgroundColor3   = (m=="Tween")   and Color3.fromRGB(0,120,0) or Color3.fromRGB(70,70,70)
    end
    modeInstant.MouseButton1Click:Connect(function() setMode("Instant") end)
    modeTween.MouseButton1Click:Connect(function() setMode("Tween") end)

    -- Duration + Easing
    local tweenRow = createTpRow(58)
    tweenRow:SetAttribute("label","Tween Settings")
    local durLbl = Instance.new("TextLabel")
    durLbl.BackgroundTransparency = 1
    durLbl.Size = UDim2.new(1, 0, 0, 20)
    durLbl.Position = UDim2.new(0,10,0,6)
    durLbl.Text = "Tween Duration: 1.0s"
    durLbl.TextColor3 = Color3.fromRGB(235,235,235)
    durLbl.TextXAlignment = Enum.TextXAlignment.Left
    durLbl.Font = Enum.Font.Gotham
    durLbl.TextSize = 16
    durLbl.Parent = tweenRow

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.6, -20, 0, 8)
    bar.Position = UDim2.new(0,10,0,34)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    bar.BorderSizePixel = 0
    bar.Parent = tweenRow
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,8)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0.2, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,8)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18,18)
    knob.Position = UDim2.new(0.2, -9, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    knob.BorderSizePixel = 0
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local dragging = false
    local function setDurPct(p)
        p = math.clamp(p, 0, 1)
        tweenDuration = math.floor(((0.2 + 4.8 * p) * 10) + 0.5) / 10
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -9, 0.5, -9)
        durLbl.Text = string.format("Tween Duration: %.1fs", tweenDuration)
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            setDurPct(rel)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
            setDurPct(rel)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local easeBtn = Instance.new("TextButton")
    easeBtn.Size = UDim2.new(0.35, -10, 0, 26)
    easeBtn.Position = UDim2.new(0.65, 0, 0, 30)
    easeBtn.Text = "Easing: QuadOut"
    easeBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
    easeBtn.TextColor3 = Color3.new(1,1,1)
    easeBtn.BorderSizePixel = 0
    easeBtn.Parent = tweenRow
    Instance.new("UICorner", easeBtn).CornerRadius = UDim.new(0,6)

    local function cycleEase()
        easeIdx = easeIdx % #easeStyles + 1
        easeBtn.Text = "Easing: " .. easeStyles[easeIdx][1]
    end
    easeBtn.MouseButton1Click:Connect(cycleEase)

    -- Tombol Teleport Now (target player)
    local goRow = createTpRow(40)
    local goBtn = Instance.new("TextButton")
    goBtn.Size = UDim2.new(1, -20, 1, -10)
    goBtn.Position = UDim2.new(0,10,0,5)
    goBtn.Text = "Teleport to Target Player"
    goBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    goBtn.TextColor3 = Color3.new(1,1,1)
    goBtn.BorderSizePixel = 0
    goBtn.Parent = goRow
    Instance.new("UICorner", goBtn).CornerRadius = UDim.new(0,8)

    local function teleportToTarget()
        if not root then return end
        if not selectedPlayerName then return end
        local plr = Players:FindFirstChild(selectedPlayerName)
        if not plr or not plr.Character then return end
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        teleportToPosition(hrp.Position + Vector3.new(0,3,0))
    end
    goBtn.MouseButton1Click:Connect(teleportToTarget)

    -- Auto update target jika keluar/masuk
    local function onRosterChange()
        if selectedPlayerName then
            local still = Players:FindFirstChild(selectedPlayerName)
            if not still then
                selectedPlayerName = nil
                playerNameLbl.Text = "Target: (belum dipilih)"
            end
        end
    end
    Players.PlayerAdded:Connect(onRosterChange)
    Players.PlayerRemoving:Connect(onRosterChange)

    -----------------------------------------------------
    -- Bar Add/Delete Saved Locations
    -----------------------------------------------------
    local btnBar = createTpRow(40)
    btnBar.BackgroundTransparency = 1
    local addBtn = Instance.new("TextButton")
    addBtn.Size = UDim2.new(0.5, -6, 1, 0)
    addBtn.Text = "Add Current Location"
    addBtn.Font = Enum.Font.GothamBold
    addBtn.TextSize = 14
    addBtn.TextColor3 = Color3.new(1,1,1)
    addBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    addBtn.BorderSizePixel = 0
    addBtn.Parent = btnBar
    Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,8)

    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0.5, -6, 1, 0)
    delBtn.Position = UDim2.new(0.5, 6, 0, 0)
    delBtn.Text = "Delete Selected"
    delBtn.Font = Enum.Font.GothamBold
    delBtn.TextSize = 14
    delBtn.TextColor3 = Color3.new(1,1,1)
    delBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
    delBtn.BorderSizePixel = 0
    delBtn.Parent = btnBar
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,8)

    -----------------------------------------------------
    -- Bar Export/Import
    -----------------------------------------------------
    local eximBar = createTpRow(40)
    eximBar.BackgroundTransparency = 1
    local exportBtn = Instance.new("TextButton")
    exportBtn.Size = UDim2.new(0.5, -6, 1, 0)
    exportBtn.Text = "Export Locations"
    exportBtn.Font = Enum.Font.GothamBold
    exportBtn.TextSize = 14
    exportBtn.TextColor3 = Color3.new(1,1,1)
    exportBtn.BackgroundColor3 = Color3.fromRGB(0,90,140)
    exportBtn.BorderSizePixel = 0
    exportBtn.Parent = eximBar
    Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0,8)

    local importBtn = Instance.new("TextButton")
    importBtn.Size = UDim2.new(0.5, -6, 1, 0)
    importBtn.Position = UDim2.new(0.5, 6, 0, 0)
    importBtn.Text = "Import Locations (Server)"
    importBtn.Font = Enum.Font.GothamBold
    importBtn.TextSize = 14
    importBtn.TextColor3 = Color3.new(1,1,1)
    importBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
    importBtn.BorderSizePixel = 0
    importBtn.Parent = eximBar
    Instance.new("UICorner", importBtn).CornerRadius = UDim.new(0,8)

    -----------------------------------------------------
    -- List Entry Builder (tiap lokasi)
    -----------------------------------------------------
    local function createLocationEntry(locationData)
        local entry = createTpRow(56)

        local checkbox = Instance.new("TextButton")
        checkbox.Size = UDim2.fromOffset(26, 26)
        checkbox.Position = UDim2.new(0, 10, 0.5, -13)
        checkbox.Text = ""
        checkbox.BackgroundColor3 = Color3.fromRGB(80,80,80)
        checkbox.BorderSizePixel = 0
        checkbox.Parent = entry
        Instance.new("UICorner", checkbox).CornerRadius = UDim.new(0, 6)
        locationData.checkbox = checkbox

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(1, -56, 0.5, -4)
        tpBtn.Position = UDim2.new(0, 46, 0, 6)
        tpBtn.Text = locationData.name
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 14
        tpBtn.TextColor3 = Color3.new(1,1,1)
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
        tpBtn.BorderSizePixel = 0
        tpBtn.Parent = entry
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -56, 0.5, -4)
        info.Position = UDim2.new(0, 46, 0.5, 2)
        info.BackgroundTransparency = 1
        info.TextColor3 = Color3.fromRGB(200,200,200)
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.Gotham
        info.TextSize = 13
        info.Parent = entry

        local function setInfoFromPos(pos)
            local v = (typeof(pos)=="Vector3") and pos or unpackVec3(pos)
            if v then
                info.Text = string.format("X: %.1f, Y: %.1f, Z: %.1f", v.X, v.Y, v.Z)
            else
                info.Text = "Invalid position"
            end
        end
        setInfoFromPos(locationData.position)

        checkbox.MouseButton1Click:Connect(function()
            locationData.selected = not locationData.selected
            checkbox.BackgroundColor3 = locationData.selected and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
        end)

        tpBtn.MouseButton1Click:Connect(function()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local v = (typeof(locationData.position)=="Vector3") and locationData.position or unpackVec3(locationData.position)
            if v then
                local dest = Vector3.new(v.X, v.Y, v.Z) + Vector3.new(0,3,0)
                if tpMode == "Instant" then
                    teleportToPosition(dest)
                else
                    teleportToPositionAndWait(dest)
                end
            end
        end)

        entry:SetAttribute("label", string.lower(locationData.name))
        return entry
    end

    -----------------------------------------------------
    -- Prompt nama (reusable)
    -----------------------------------------------------
    local function promptName(defaultText, titleText, onSave)
        local prompt = Instance.new("ScreenGui")
        prompt.Name = "PB_Prompt"
        prompt.Parent = PlayerGui
        local f = Instance.new("Frame")
        f.Size = UDim2.fromOffset(300, 150)
        f.Position = UDim2.new(0.5, -150, 0.5, -75)
        f.BackgroundColor3 = Color3.fromRGB(50,50,50)
        f.BorderSizePixel = 0
        f.Parent = prompt
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, 0, 0, 30)
        titleLbl.BackgroundColor3 = Color3.fromRGB(70,70,70)
        titleLbl.Text = titleText
        titleLbl.TextColor3 = Color3.new(1,1,1)
        titleLbl.Parent = f
        local tb = Instance.new("TextBox")
        tb.Size = UDim2.new(1, -20, 0, 30)
        tb.Position = UDim2.new(0, 10, 0, 40)
        tb.Text = defaultText
        tb.BackgroundColor3 = Color3.fromRGB(30,30,30)
        tb.TextColor3 = Color3.new(1,1,1)
        tb.Parent = f
        local save = Instance.new("TextButton")
        save.Size = UDim2.new(0.5, -15, 0, 30)
        save.Position = UDim2.new(0, 10, 1, -40)
        save.Text = "Save"
        save.BackgroundColor3 = Color3.fromRGB(0,120,0)
        save.TextColor3 = Color3.new(1,1,1)
        save.Parent = f
        local cancel = Instance.new("TextButton")
        cancel.Size = UDim2.new(0.5, -15, 0, 30)
        cancel.Position = UDim2.new(0.5, 5, 1, -40)
        cancel.Text = "Cancel"
        cancel.BackgroundColor3 = Color3.fromRGB(120,0,0)
        cancel.TextColor3 = Color3.new(1,1,1)
        cancel.Parent = f

        save.MouseButton1Click:Connect(function()
            local name = (tb.Text ~= "" and tb.Text) or defaultText
            prompt:Destroy()
            onSave(name)
        end)
        cancel.MouseButton1Click:Connect(function() prompt:Destroy() end)
    end

    -----------------------------------------------------
    -- Add/Delete handlers
    -----------------------------------------------------
    addBtn.MouseButton1Click:Connect(function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local defaultName = "Location "..tostring(#savedLocations + 1)
        promptName(defaultName, "Name this location:", function(name)
            local locationData = {name=name, position=hrp.Position, selected=false}
            table.insert(savedLocations, locationData)
            createLocationEntry(locationData)
            recalcTp()
        end)
    end)

    delBtn.MouseButton1Click:Connect(function()
        for i = #savedLocations, 1, -1 do
            if savedLocations[i].selected then
                local chk = savedLocations[i].checkbox
                if chk and chk.Parent then chk.Parent:Destroy() end
                table.remove(savedLocations, i)
            end
        end
        recalcTp()
    end)

    -----------------------------------------------------
    -- Export ke server (ikut mode data server.py)
    -----------------------------------------------------
    exportBtn.MouseButton1Click:Connect(function()
        if #savedLocations == 0 then return end
        if not serverOnline then dprint("export: server offline"); return end

        local defaultName = "Export "..tostring(os.time())
        promptName(defaultName, "Export as:", function(name)
            local copy = {}
            for _, loc in ipairs(savedLocations) do
                local p = packVec3(loc.position)
                if p then
                    copy[#copy+1] = { name = loc.name, position = p }
                else
                    dprint("skip export; invalid position on", loc.name)
                end
            end
            exportedSets[name] = copy

            local body = {
                autoload = autoloadName,
                configs  = configs,
                exports  = normalizeExportsForSend(exportedSets),
                meta     = { username = USERNAME }
            }
            apiPutUser(HWID, body)
        end)
    end)

    -----------------------------------------------------
    -- Import popup (Load/Delete)
    -----------------------------------------------------
    importBtn.MouseButton1Click:Connect(function()
        if serverOnline then
            local ok,data = apiGetUser(HWID)
            if ok and data then
                exportedSets = data.exports or exportedSets
            end
        end

        local popup = Instance.new("ScreenGui")
        popup.Name = "PB_ImportList"
        popup.ResetOnSpawn = false
        popup.Parent = PlayerGui

        local f = Instance.new("Frame")
        f.Size = UDim2.fromOffset(360, 320)
        f.Position = UDim2.new(0.5, -180, 0.5, -160)
        f.BackgroundColor3 = Color3.fromRGB(45,45,50)
        f.BorderSizePixel = 0
        f.Parent = popup
        f.ClipsDescendants = true
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -12, 0, 30)
        lbl.Position = UDim2.new(0, 6, 0, 6)
        lbl.BackgroundColor3 = Color3.fromRGB(70,70,70)
        lbl.Text = "Choose export to import"
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.Parent = f
        Instance.new("UICorner", lbl).CornerRadius = UDim.new(0,6)

        local list = Instance.new("ScrollingFrame")
        list.Size = UDim2.new(1, -12, 1, -106)
        list.Position = UDim2.new(0, 6, 0, 42)
        list.BackgroundTransparency = 1
        list.ScrollBarThickness = 6
        list.ClipsDescendants = true
        list.Parent = f

        local lay = Instance.new("UIListLayout")
        lay.Parent = list
        lay.Padding = UDim.new(0,6)

        local btnRow = Instance.new("Frame")
        btnRow.Size = UDim2.new(1, -12, 0, 36)
        btnRow.Position = UDim2.new(0, 6, 1, -42)
        btnRow.BackgroundTransparency = 1
        btnRow.Parent = f

        local function styleBtn(b)
            b.AutoButtonColor = true
            b.BorderSizePixel = 0
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
            return b
        end

        local loadBtn = styleBtn(Instance.new("TextButton"))
        loadBtn.Size = UDim2.new(0.4, -4, 1, 0)
        loadBtn.Position = UDim2.new(0, 0, 0, 0)
        loadBtn.Text = "Load"
        loadBtn.TextColor3 = Color3.new(1,1,1)
        loadBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
        loadBtn.Parent = btnRow

        local deleteBtn = styleBtn(Instance.new("TextButton"))
        deleteBtn.Size = UDim2.new(0.4, -4, 1, 0)
        deleteBtn.Position = UDim2.new(0.4, 8, 0, 0)
        deleteBtn.Text = "Delete"
        deleteBtn.TextColor3 = Color3.new(1,1,1)
        deleteBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
        deleteBtn.Parent = btnRow

        local closeB = styleBtn(Instance.new("TextButton"))
        closeB.Size = UDim2.new(0.2, -4, 1, 0)
        closeB.Position = UDim2.new(0.8, 8, 0, 0)
        closeB.Text = "Close"
        closeB.TextColor3 = Color3.new(1,1,1)
        closeB.BackgroundColor3 = Color3.fromRGB(90,60,60)
        closeB.Parent = btnRow

        local function setEnabled(btn, enabled, activeColor, disabledColor)
            btn.Active = enabled
            btn.AutoButtonColor = enabled
            btn.BackgroundColor3 = enabled and activeColor or disabledColor
            btn.TextTransparency = enabled and 0 or 0.35
        end

        setEnabled(loadBtn, false, Color3.fromRGB(0,120,0), Color3.fromRGB(70,70,70))
        setEnabled(deleteBtn, false, Color3.fromRGB(120,0,0), Color3.fromRGB(70,70,70))

        local selectedName, selectedBtn

        local function rebuildList()
            for _,ch in ipairs(list:GetChildren()) do
                if ch:IsA("TextButton") then ch:Destroy() end
            end
            selectedName, selectedBtn = nil, nil
            setEnabled(loadBtn, false, Color3.fromRGB(0,120,0), Color3.fromRGB(70,70,70))
            setEnabled(deleteBtn, false, Color3.fromRGB(120,0,0), Color3.fromRGB(70,70,70))

            for name,_set in pairs(exportedSets) do
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -4, 0, 28)
                b.Text = name
                b.BackgroundColor3 = Color3.fromRGB(60,60,70)
                b.TextColor3 = Color3.new(1,1,1)
                b.Parent = list
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

                b.MouseButton1Click:Connect(function()
                    if selectedBtn and selectedBtn ~= b then
                        selectedBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
                    end
                    selectedBtn = b
                    selectedName = name
                    b.BackgroundColor3 = Color3.fromRGB(0,140,200)
                    setEnabled(loadBtn, true, Color3.fromRGB(0,120,0), Color3.fromRGB(70,70,70))
                    setEnabled(deleteBtn, true, Color3.fromRGB(120,0,0), Color3.fromRGB(70,70,70))
                end)
            end
        end

        rebuildList()

        loadBtn.MouseButton1Click:Connect(function()
            if not selectedName then return end
            local set = exportedSets[selectedName]
            if not set then return end

            for i=#savedLocations,1,-1 do
                local chk = savedLocations[i].checkbox
                if chk and chk.Parent then chk.Parent:Destroy() end
                table.remove(savedLocations,i)
            end

            for _,loc in ipairs(set) do
                local v = unpackVec3(loc.position)
                if v then
                    local nd = { name=loc.name, position=v, selected=false }
                    table.insert(savedLocations, nd)
                    createLocationEntry(nd)
                else
                    dprint("skip import; invalid packed position on", tostring(loc.name))
                end
            end
            recalcTp()
            popup:Destroy()
        end)

        deleteBtn.MouseButton1Click:Connect(function()
            if not selectedName then return end
            if not serverOnline then dprint("delete export: server offline"); return end

            exportedSets[selectedName] = nil

            local body = {
                autoload = autoloadName,
                configs  = configs,
                exports  = normalizeExportsForSend(exportedSets),
                meta     = { username = USERNAME }
            }
            local ok,_ = apiPutUser(HWID, body)
            if not ok then
                dprint("delete export PUT failed")
                return
            end

            rebuildList()
        end)

        closeB.MouseButton1Click:Connect(function() popup:Destroy() end)
    end)

    -----------------------------------------------------
    -- Auto Tour (atas → bawah) dengan interval detik
    -----------------------------------------------------
    local autoRespawnAfterTour = false   -- atau false kalau mau default off
    local respawnDelayAfterLast = 4     -- detik default setelah titik terakhir

    local tourRow = createTpRow(58)
    tourRow:SetAttribute("label","Auto Tour")
    local tourLbl = Instance.new("TextLabel")
    tourLbl.BackgroundTransparency = 1
    tourLbl.Size = UDim2.new(1, 0, 0, 20)
    tourLbl.Position = UDim2.new(0,10,0,6)
    tourLbl.Text = "Auto Tour (atas → bawah)"
    tourLbl.TextColor3 = Color3.fromRGB(235,235,235)
    tourLbl.TextXAlignment = Enum.TextXAlignment.Left
    tourLbl.Font = Enum.Font.Gotham
    tourLbl.TextSize = 16
    tourLbl.Parent = tourRow

    local intervalBox = Instance.new("TextBox")
    intervalBox.Size = UDim2.new(0.4, -20, 0, 26)
    intervalBox.Position = UDim2.new(0,10,0,30)
    intervalBox.Text = "3"
    intervalBox.PlaceholderText = "Interval detik"
    intervalBox.TextColor3 = Color3.new(1,1,1)
    intervalBox.BackgroundColor3 = Color3.fromRGB(55,55,60)
    intervalBox.BorderSizePixel = 0
    intervalBox.Parent = tourRow
    Instance.new("UICorner", intervalBox).CornerRadius = UDim.new(0,6)
    
    -- Row tombol snapshot & counter
    local snapRow = createTpRow(40)
    snapRow:SetAttribute("label","Tour Snapshot")

    -- Toggle Auto Respawn (muncul di bawah input interval)
    local arSw = makeSwitch(tpScroll, "Auto Respawn Last Location", false, function(v)
        autoRespawnAfterTour = v
    end)

    local getAllBtn = Instance.new("TextButton")
    getAllBtn.Size = UDim2.new(0.35, -8, 1, -10)
    getAllBtn.Position = UDim2.new(0,10,0,5)
    getAllBtn.Text = "Get All Positions"
    getAllBtn.BackgroundColor3 = Color3.fromRGB(0,90,140)
    getAllBtn.TextColor3 = Color3.new(1,1,1)
    getAllBtn.BorderSizePixel = 0
    getAllBtn.Parent = snapRow
    Instance.new("UICorner", getAllBtn).CornerRadius = UDim.new(0,8)

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.25, -8, 1, -10)
    clearBtn.Position = UDim2.new(0.37, 0, 0, 5)
    clearBtn.Text = "Clear"
    clearBtn.BackgroundColor3 = Color3.fromRGB(90,60,60)
    clearBtn.TextColor3 = Color3.new(1,1,1)
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = snapRow
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,8)

    local tourCountLbl = Instance.new("TextLabel")
    tourCountLbl.BackgroundTransparency = 1
    tourCountLbl.Size = UDim2.new(0.35, -10, 1, 0)
    tourCountLbl.Position = UDim2.new(0.64, 0, 0, 0)
    tourCountLbl.Text = "Tour count: 0"
    tourCountLbl.TextXAlignment = Enum.TextXAlignment.Right
    tourCountLbl.TextColor3 = Color3.fromRGB(220,220,220)
    tourCountLbl.Font = Enum.Font.Gotham
    tourCountLbl.TextSize = 14
    tourCountLbl.Parent = snapRow

    local function rebuildTourCounter()
        tourCountLbl.Text = ("Tour count: %d"):format(#tourList)
    end

    -- builder snapshot dari savedLocations (urut atas → bawah)
    local function buildTourFromSaved()
        local list = {}
        for _, loc in ipairs(savedLocations) do
            local v = (typeof(loc.position) == "Vector3") and loc.position or unpackVec3(loc.position)
            if v then
                list[#list+1] = { name = loc.name, pos = Vector3.new(v.X, v.Y, v.Z) }
            end
        end
        return list
    end

    getAllBtn.MouseButton1Click:Connect(function()
        setTour(buildTourFromSaved())
        rebuildTourCounter()
        statusLbl.Text = "Status: Snapshot updated"
    end)

    clearBtn.MouseButton1Click:Connect(function()
        setTour({})
        rebuildTourCounter()
        statusLbl.Text = "Status: Snapshot cleared"
    end)

    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0.25, -8, 0, 26)
    startBtn.Position = UDim2.new(0.42, 0, 0, 30)
    startBtn.Text = "Start"
    startBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    startBtn.TextColor3 = Color3.new(1,1,1)
    startBtn.BorderSizePixel = 0
    startBtn.Parent = tourRow
    Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)

    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.25, -8, 0, 26)
    stopBtn.Position = UDim2.new(0.69, 8, 0, 30)
    stopBtn.Text = "Stop"
    stopBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
    stopBtn.TextColor3 = Color3.new(1,1,1)
    stopBtn.BorderSizePixel = 0
    stopBtn.Parent = tourRow
    Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,6)

    local statusLbl = Instance.new("TextLabel")
    statusLbl.BackgroundTransparency = 1
    statusLbl.Size = UDim2.new(1, -20, 0, 18)
    statusLbl.Position = UDim2.new(0,10,0, 30+26+6)
    statusLbl.Text = "Status: Idle"
    statusLbl.TextColor3 = Color3.fromRGB(200,200,200)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextSize = 13
    statusLbl.Parent = tourRow

    local tourRunning = false
    local function parseInterval()
        local raw = (intervalBox and intervalBox.Text) or ""
        local cleaned = raw:gsub("[^%d%.]", "")  -- buang semua kecuali digit & titik
        local n = tonumber(cleaned)
        if not n or n < 0.1 then n = 0.1 end
        return n
    end


    local function safeTeleport(dest)
        -- kalau mati/respawn, tunggu karakter baru
        if (not root) or (not root.Parent) or (not hum) or hum.Health <= 0 then
            getCharacter()
        end
        if tpMode == "Instant" then
            teleportToPosition(dest)
        else
            teleportToPositionAndWait(dest)
        end
    end

    local function doRespawnAndWait()
        -- matikan noFallDamage sementara biar pasti mati
        local prevNoFall = noFallDamage
        noFallDamage = false

        local c = LocalPlayer.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function()
                h.Health = 0 -- paksa mati
            end)
        end

        -- tunggu character baru
        local newChar = LocalPlayer.Character
        if (not newChar) or (newChar == c) then
            newChar = LocalPlayer.CharacterAdded:Wait()
        end

        -- rebind referensi & physics
        char = newChar
        root = newChar:WaitForChild("HumanoidRootPart")
        hum  = newChar:WaitForChild("Humanoid")
        ensurePhysics()

        -- kembalikan noFallDamage ke nilai semula
        noFallDamage = prevNoFall
    end

    startBtn.MouseButton1Click:Connect(function()
        if tourRunning then return end

        if #tourList == 0 then
            statusLbl.Text = "Status: Tour list kosong — tekan Get All dulu"
            return
        end

        tourRunning = true
        statusLbl.Text = "Status: Running"

        task.spawn(function()
            while tourRunning do
                -- jalanin semua titik
                for i = 1, #tourList do
                    if not tourRunning then break end

                    local item = tourList[i]
                    local dest = item.pos + Vector3.new(0, 3, 0)

                    pcall(function()
                        safeTeleport(dest)
                    end)

                    -- interval biasa antar titik (BUKAN untuk respawn)
                    local waitSec = parseInterval()
                    if waitSec < 0.1 then waitSec = 0.1 end
                    local t0 = tick()
                    while tourRunning and (tick() - t0) < waitSec do
                        task.wait(0.05)
                    end
                end

                -- selesai semua titik → (opsional) respawn dengan delay khusus 4s
                if not tourRunning then break end
                if autoRespawnAfterTour then
                    local delaySec = respawnDelayAfterLast or 4

                    -- countdown 4 detik, tidak dihitung sebagai interval teleport
                    local t0 = tick()
                    while tourRunning and (tick() - t0) < delaySec do
                        local sisa = math.max(0, delaySec - (tick() - t0))
                        statusLbl.Text = string.format("Status: Respawning in %.1fs", sisa)
                        task.wait(0.05)
                    end
                    if not tourRunning then break end

                    statusLbl.Text = "Status: Respawning..."
                    doRespawnAndWait()       -- tunggu sampai karakter beneran hidup
                    statusLbl.Text = "Status: Running"
                    -- loop while akan lanjut lagi dari posisi 1
                end
            end
            statusLbl.Text = "Status: Stopped"
        end)
    end)

    
    local function doRespawn()
        statusLbl.Text = "Status: Respawning..."
        -- Cara paling kompatibel: matikan Humanoid (akan trigger respawn default)
        local ch = LocalPlayer.Character
        local h = ch and ch:FindFirstChildOfClass("Humanoid")
        if h then
            h.Health = 0
        else
            -- fallback kalau humanoid nggak ada
            pcall(function() LocalPlayer:LoadCharacter() end)
        end

        -- Tunggu karakter baru siap
        pcall(function() LocalPlayer.CharacterAdded:Wait() end)
        getCharacter() -- refresh char/root/hum
        task.wait(0.2)
        statusLbl.Text = "Status: Running"
    end

    stopBtn.MouseButton1Click:Connect(function()
        tourRunning = false
        statusLbl.Text = "Status: Stopping..."
    end)

    -----------------------------------------------------
    -- Search (filter tab aktif)
    -----------------------------------------------------
    local function applySearchToScroll(scroll, recalc)
        local q = string.lower(searchBox.Text or "")
        for _,row in ipairs(scroll:GetChildren()) do
            if row:IsA("Frame") then
                local label = string.lower(tostring(row:GetAttribute("label") or row.Name or ""))
                row.Visible = (q == "") or (string.find(label, q, 1, true) ~= nil)
            end
        end
        if recalc then recalc() end
    end

    local activeTab = "Main"
    local function applySearch()
        if activeTab == "Main" then
            applySearchToScroll(mainScroll, recalcMain)
        elseif activeTab == "Misc" then
            applySearchToScroll(miscScroll, recalcMisc)
        elseif activeTab == "Teleport" then
            local q = string.lower(searchBox.Text or "")
            for _,row in ipairs(tpScroll:GetChildren()) do
                if row:IsA("Frame") and (row ~= nil) then
                    local label = tostring(row:GetAttribute("label") or "")
                    row.Visible = (q == "") or (string.find(label, q, 1, true) ~= nil)
                end
            end
            recalcTp()
        else
            applySearchToScroll(cfgScroll, recalcCfg)
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

    -----------------------------------------------------
    -- ===== CONFIG (Server) =====
    -----------------------------------------------------
    local function getCurrentSettings()
        return {
            fly=fly, noclip=noclip, infJumpMobile=infJumpMobile, infJumpPC=infJumpPC, noFallDamage=noFallDamage,
            walkSpeed=walkSpeed, jumpPower=jumpPower,
            fullBright=fullBright, removeFog=removeFog, fov=defaultFOV,
        }
    end
    local function applySettings(s)
        if not s then return end
        wsSl.Set(s.walkSpeed or walkSpeed)
        jpSl.Set(s.jumpPower or jumpPower)
        setFOV(s.fov or defaultFOV)
        fbSw.Set(s.fullBright or false)
        rfSw.Set(s.removeFog or false)
        flySw.Set(s.fly or false)
        ncSw.Set(s.noclip or false)
        ijmSw.Set(s.infJumpMobile or false)
        ijpSw.Set(s.infJumpPC or false)
        nfdSw.Set(s.noFallDamage or false)
    end

    local nameRow = createRow(cfgScroll, 58)
    nameRow:SetAttribute("label","Config Name")
    local nameLbl2 = Instance.new("TextLabel")
    nameLbl2.BackgroundTransparency = 1
    nameLbl2.Size = UDim2.new(1, 0, 0, 20)
    nameLbl2.Position = UDim2.new(0,10,0,6)
    nameLbl2.Text = "Config Name"
    nameLbl2.TextColor3 = Color3.fromRGB(235,235,235)
    nameLbl2.Font = Enum.Font.Gotham
    nameLbl2.TextSize = 16
    nameLbl2.Parent = nameRow
    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.new(1, -20, 0, 28)
    nameBox.Position = UDim2.new(0,10,0,28)
    nameBox.PlaceholderText = "my-config"
    nameBox.Text = ""
    nameBox.TextColor3 = Color3.new(1,1,1)
    nameBox.BackgroundColor3 = Color3.fromRGB(55,55,60)
    nameBox.BorderSizePixel = 0
    nameBox.Parent = nameRow
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,6)

    local saveRow = createRow(cfgScroll, 40)
    saveRow:SetAttribute("label","Save Config")
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -20, 1, -10)
    saveBtn.Position = UDim2.new(0,10,0,5)
    saveBtn.Text = "Save Config (Server)"
    saveBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = saveRow
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,8)

    local listTitle = createRow(cfgScroll, 28)
    local lt = Instance.new("TextLabel")
    lt.BackgroundTransparency = 1
    lt.Size = UDim2.new(1, -20, 1, 0)
    lt.Position = UDim2.new(0,10,0,0)
    lt.Text = "Saved Configs (Server)"
    lt.TextColor3 = Color3.new(1,1,1)
    lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.Font = Enum.Font.GothamBold
    lt.TextSize = 14
    lt.Parent = listTitle

    local cfgList = createRow(cfgScroll, 180)
    cfgList.BackgroundTransparency = 1
    local cfgScrollInner = Instance.new("ScrollingFrame")
    cfgScrollInner.Size = UDim2.new(1, -12, 1, 0)
    cfgScrollInner.Position = UDim2.new(0,6,0,0)
    cfgScrollInner.BackgroundTransparency = 1
    cfgScrollInner.ScrollBarThickness = 6
    cfgScrollInner.ClipsDescendants = true
    cfgScrollInner.Parent = cfgList
    local cfgLay = Instance.new("UIListLayout")
    cfgLay.Parent = cfgScrollInner
    cfgLay.Padding = UDim.new(0,6)

    local function rebuildCfgList()
        for _,ch in ipairs(cfgScrollInner:GetChildren()) do
            if ch:IsA("TextButton") or ch:IsA("Frame") then ch:Destroy() end
        end
        for name, s in pairs(configs) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -4, 0, 32)
            row.BackgroundColor3 = Color3.fromRGB(50,50,58)
            row.Parent = cfgScrollInner
            Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)

            local nLbl = Instance.new("TextLabel")
            nLbl.BackgroundTransparency = 1
            nLbl.Size = UDim2.new(0.5, -10, 1, 0)
            nLbl.Position = UDim2.new(0,10,0,0)
            nLbl.Text = name .. (autoloadName==name and "  (Auto)" or "")
            nLbl.TextXAlignment = Enum.TextXAlignment.Left
            nLbl.TextColor3 = Color3.new(1,1,1)
            nLbl.Parent = row

            local loadB = Instance.new("TextButton")
            loadB.Size = UDim2.new(0.2, -6, 0, 26)
            loadB.Position = UDim2.new(0.5, 0, 0.5, -13)
            loadB.Text = "Load"
            loadB.BackgroundColor3 = Color3.fromRGB(0,90,140)
            loadB.TextColor3 = Color3.new(1,1,1)
            loadB.Parent = row
            Instance.new("UICorner", loadB).CornerRadius = UDim.new(0,6)

            local autoB = Instance.new("TextButton")
            autoB.Size = UDim2.new(0.2, -6, 0, 26)
            autoB.Position = UDim2.new(0.7, 0, 0.5, -13)
            autoB.Text = "Auto"
            autoB.BackgroundColor3 = autoloadName==name and Color3.fromRGB(0,150,0) or Color3.fromRGB(70,70,70)
            autoB.TextColor3 = Color3.new(1,1,1)
            autoB.Parent = row
            Instance.new("UICorner", autoB).CornerRadius = UDim.new(0,6)

            local delB = Instance.new("TextButton")
            delB.Size = UDim2.new(0.1, -6, 0, 26)
            delB.Position = UDim2.new(0.9, 0, 0.5, -13)
            delB.Text = "Del"
            delB.BackgroundColor3 = Color3.fromRGB(120,0,0)
            delB.TextColor3 = Color3.new(1,1,1)
            delB.Parent = row
            Instance.new("UICorner", delB).CornerRadius = UDim.new(0,6)

            loadB.MouseButton1Click:Connect(function() applySettings(s) end)
            autoB.MouseButton1Click:Connect(function()
                if not serverOnline then dprint("auto set: server offline"); return end
                autoloadName = (autoloadName==name) and nil or name
                local body = {
                    autoload = autoloadName,
                    configs  = configs,
                    exports  = normalizeExportsForSend(exportedSets),
                    meta     = { username = USERNAME }
                }
                apiPutUser(HWID, body)
                rebuildCfgList()
            end)
            delB.MouseButton1Click:Connect(function()
                if not serverOnline then dprint("delete config: server offline"); return end
                configs[name] = nil
                if autoloadName == name then autoloadName = nil end
                local body = {
                    autoload = autoloadName,
                    configs  = configs,
                    exports  = normalizeExportsForSend(exportedSets),
                    meta     = { username = USERNAME }
                }
                apiPutUser(HWID, body)
                rebuildCfgList()
            end)
        end
    end

    saveBtn.MouseButton1Click:Connect(function()
        if not serverOnline then dprint("save config: server offline"); return end
        local nm = nameBox.Text ~= "" and nameBox.Text or ("config-"..tostring(os.time()))
        configs[nm] = getCurrentSettings()
        local body = {
            autoload = autoloadName,
            configs  = configs,
            exports  = normalizeExportsForSend(exportedSets),
            meta     = { username = USERNAME }
        }
        apiPutUser(HWID, body)
        rebuildCfgList()
    end)

    -- Tab switching
    local function showTab(name)
        activeTab = name
        mainScroll.Visible = (name == "Main")
        miscScroll.Visible = (name == "Misc")
        tpScroll.Visible   = (name == "Teleport")
        cfgScroll.Visible  = (name == "Config")
        applySearch()
    end
    tabMainBtn.MouseButton1Click:Connect(function() showTab("Main") end)
    tabMiscBtn.MouseButton1Click:Connect(function() showTab("Misc") end)
    tabTpBtn.MouseButton1Click:Connect(function() showTab("Teleport") end)
    tabCfgBtn.MouseButton1Click:Connect(function() showTab("Config") end)
    showTab("Main")

    -- Minimize / Close
    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        local vis = not minimized
        tabs.Visible = vis
        mainScroll.Visible = vis and (activeTab == "Main")
        miscScroll.Visible = vis and (activeTab == "Misc")
        tpScroll.Visible   = vis and (activeTab == "Teleport")
        cfgScroll.Visible  = vis and (activeTab == "Config")
        frame.Size = minimized and UDim2.fromOffset(420, 56) or UDim2.fromOffset(420, 360)
    end)
    btnClose.MouseButton1Click:Connect(function()
        MainGUI.Enabled = false
        showPill()
    end)

    -- Dragging window
    local draggingFrame = false
    local dragStart, startPos
    drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingFrame = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if draggingFrame and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    drag.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingFrame = false
        end
    end)

    -- Aktifkan panel setelah 5 detik + autoload
    task.delay(5, function()
        overlay:Destroy()
        MainGUI.Enabled = true

        if autoloadName and configs[autoloadName] then
            task.defer(function() applySettings(configs[autoloadName]) end)
        end

        setFOV(defaultFOV)
        rebuildCfgList()
    end)
end

-- ========== Init ==========
tryLoadFromServer()

getCharacter()
attachFly()
ensurePhysics()
hookFallDamage()

LocalPlayer.CharacterAdded:Connect(function()
    getCharacter()
    attachFly()
    ensurePhysics()
    hookFallDamage()
    fly = false
    noclip = false
end)

-- Keybind toggle Fly (F)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        setFly(not fly)
    end
end)

-- UI
createUI()

-- Safety
game:BindToClose(function()
    setFly(false)
    cleanupFly()
end)
