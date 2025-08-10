--[[ Obfuscation bootstrap (simple additive decoder) ]]
local function _D(__hex)
    local __k = 57
    local __t = {}
    local __len = #__hex
    local __bytes = {}
    for __i = 1, __len, 2 do
        local __byte = tonumber(string.sub(__hex, __i, __i+1), 16)
        __byte = (__byte - __k) % 256
        __bytes[#__bytes+1] = string.char(__byte)
    end
    return table.concat(__bytes)
end
local function _DJ(__n)
    if false then
        -- dead code junk to mislead static analyzers
        local z = 0; for i=1,10 do z = z + i end; if z == math.huge then print(z) end
    end
    return __n
end




local SERVER_BASE = _D("A1ADADA9AC7368689D9E9EA9669F9A9CADAE9AA566A0A89AAD67A7A0ABA8A4669FAB9E9E679AA9A9")  
local API_KEY     = _D("9AAC9D9AAC9D9AAC9D9AAC9D9AAC9D9AAC9D9AAC9D9AAC9D")             


local Players = game:GetService(_D("89A59AB29EABAC"))
local UIS = game:GetService(_D("8EAC9EAB82A7A9AEAD8C9EABAFA29C9E"))
local RunService = game:GetService(_D("8BAEA78C9EABAFA29C9E"))
local Lighting = game:GetService(_D("85A2A0A1ADA2A7A0"))
local HttpService = game:GetService(_D("81ADADA98C9EABAFA29C9E"))
local RbxAnalyticsService = game:GetService(_D("8B9BB17AA79AA5B2ADA29CAC8C9EABAFA29C9E"))
local TweenService = game:GetService(_D("8DB09E9EA78C9EABAFA29C9E"))

local LocalPlayer = Players.LocalPlayer
local USERNAME = LocalPlayer and LocalPlayer.Name or _D("AEA7A4A7A8B0A7")


local function dprint(...) 
    
end


local function rawRequest(opts)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        return req({
            Url = opts.Url,
            Method = opts.Method or _D("807E8D"),
            Headers = opts.Headers or {},
            Body = opts.Body
        })
    else
        if (opts.Method or _D("807E8D")) == _D("807E8D") and not opts.Body then
            local ok, body = pcall(function()
                return game:HttpGet(opts.Url)
            end)
            if ok then return { StatusCode = 200, Body = body } end
        end
        return { StatusCode = 0, Body = _D("") }
    end
end

local function jsonEncode(t) return HttpService:JSONEncode(t) end
local function jsonDecode(s) local ok,res=pcall(function() return HttpService:JSONDecode(s) end); return ok and res or nil end


local function packVec3(v)
    if typeof(v) == _D("8F9E9CADA8AB6C") then
        return { x = v.X, y = v.Y, z = v.Z }
    elseif type(v) == _D("AD9A9BA59E") and v.x and v.y and v.z then
        return { x = v.x, y = v.y, z = v.z }
    end
    return nil
end
local function unpackVec3(t)
    if typeof(t) == _D("8F9E9CADA8AB6C") then return t end
    if type(t) == _D("AD9A9BA59E") and t.x and t.y and t.z then
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


local MIN_WALK, MAX_WALK = 8, 200
local MIN_JUMP, MAX_JUMP = 25, 300
local walkSpeed = 16
local jumpPower = 50

local fly = false
local noclip = false
local infJumpMobile = false
local infJumpPC = false
local noFallDamage = false


local fullBright = false
local removeFog = false
local defaultFOV = 70

local char, root, hum
local lv, align
local lastFreefallHealth, lastFreefallT


local savedLighting
local savedAtmos


local savedLocations = {}
local exportedSets = {} 


local configs = {}
local autoloadName = nil
local serverOnline = false


local function getHWID()
    local id
    pcall(function()
        if syn and syn.get_hwid then id = syn.get_hwid() return end
        if gethwid then id = gethwid() return end
        if get_hwid then id = get_hwid() return end
        id = RbxAnalyticsService:GetClientId()
    end)
    id = tostring(id or (LocalPlayer and LocalPlayer.UserId) or _D("AEA7A4A7A8B0A7"))
    id = id:gsub(_D("94975EB05E669896"), _D("66"))
    return id
end
local HWID = getHWID()


local function apiHeaders()
    return { [_D("7CA8A7AD9EA7AD668DB2A99E")] = _D("9AA9A9A5A29C9AADA2A8A768A3ACA8A7"), [_D("91667A898266849EB2")] = API_KEY }
end
local function apiGetUser(hwid)
    local res = rawRequest({
        Url = string.format(_D("5EAC68AF6A68AEAC9EABAC685EAC"), SERVER_BASE, hwid),
        Method = _D("807E8D"),
        Headers = apiHeaders()
    })
    if res and res.StatusCode == 200 then return true, jsonDecode(res.Body) end
    dprint(_D("807E8D5968AF6A68AEAC9EABAC59ACAD9AADAEAC73"), res and res.StatusCode, _D("9BA89DB273"), res and res.Body)
    return false, res
end

local function apiPutUser(hwid, bodyTbl)
    local res = rawRequest({
        Url = string.format(_D("5EAC68AF6A68AEAC9EABAC685EAC"), SERVER_BASE, hwid),
        Method = _D("898E8D"),
        Headers = apiHeaders(),
        Body = jsonEncode(bodyTbl)
    })
    return (res and res.StatusCode == 200) and true or false, res
end
local function apiPostUsage(username, hwid)
    local res = rawRequest({
        Url = string.format(_D("5EAC68AF6A68AEAC9AA09E"), SERVER_BASE),
        Method = _D("89888C8D"),
        Headers = apiHeaders(),
        Body = jsonEncode({ username = username, hwid = hwid })
    })
    return (res and res.StatusCode == 200)
end

local function tryLoadFromServer()
    local ok, dataOrRes = apiGetUser(HWID)
    if not ok then
        serverOnline = false
        dprint(_D("8C9EABAF9EAB59A89F9FA5A2A79E599AAD9AAE599EABABA8AB59AC9A9AAD59807E8D59AEAC9EAB67597C9EA4598CAD9AADAEAC7CA89D9E599DA259A5A8A0599DA2599AAD9AAC67"))
        return
    end
    local data = dataOrRes
    serverOnline = true
    autoloadName = data.autoload
    configs = data.configs or {}
    exportedSets = data.exports or {}
    apiPostUsage(USERNAME, HWID)
end



local function getCharacter()
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    root = char:WaitForChild(_D("81AEA69AA7A8A29D8BA8A8AD899AABAD"))
    hum = char:WaitForChild(_D("81AEA69AA7A8A29D"))
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
    lv = Instance.new(_D("85A2A79E9AAB8F9EA5A89CA2ADB2"))
    lv.Name = _D("7FA5B28F9EA5A89CA2ADB2")
    lv.Attachment0 = root:WaitForChild(_D("8BA8A8AD7AADAD9A9CA1A69EA7AD"))
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.MaxForce = math.huge
    lv.VectorVelocity = Vector3.zero
    lv.Enabled = false
    lv.Parent = root
    ensurePhysics()
end


local function setFly(state)
    fly = state and true or false
    if not hum then return end
    if fly then
        if not align then
            align = Instance.new(_D("7AA5A2A0A788ABA29EA7AD9AADA2A8A7"))
            align.Name = _D("7FA5B27AA5A2A0A7")
            align.RigidityEnabled = true
            align.Responsiveness = 200
            align.Mode = Enum.OrientationAlignmentMode.OneAttachment
            align.Attachment0 = root:WaitForChild(_D("8BA8A8AD7AADAD9A9CA1A69EA7AD"))
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


local function setNoclip(state) noclip = state and true or false end
RunService.Stepped:Connect(function()
    if not char or not root then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA(_D("7B9AAC9E899AABAD")) then
            if noclip then part.CanCollide = false end
        end
    end
    if not noclip and root then root.CanCollide = true end
end)


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


local function setFullBright(state)
    fullBright = state and true or false
    local atm = Lighting:FindFirstChildOfClass(_D("7AADA6A8ACA9A19EAB9E"))
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
            local a = Lighting:FindFirstChildOfClass(_D("7AADA6A8ACA9A19EAB9E"))
            if a then a.Density = savedAtmos.Density; a.Haze = savedAtmos.Haze; a.Color = savedAtmos.Color end
        end
    end
end

local function setRemoveFog(state)
    removeFog = state and true or false
    local atm = Lighting:FindFirstChildOfClass(_D("7AADA6A8ACA9A19EAB9E"))
    if removeFog then
        Lighting.FogStart = 0
        Lighting.FogEnd = 1e6
        if atm then atm.Density = 0; atm.Haze = 0 end
    else
        if not fullBright and savedLighting then
            Lighting.FogStart = savedLighting.FogStart
            Lighting.FogEnd = savedLighting.FogEnd
            if savedAtmos then
                local a = Lighting:FindFirstChildOfClass(_D("7AADA6A8ACA9A19EAB9E"))
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


local MainGUI
local ShowPillGUI



local tpMode = _D("82A7ACAD9AA7AD")
local tweenDuration = 1.0
local easeStyles = {
    {_D("8AAE9A9D88AEAD"),  Enum.EasingStyle.Quad,    Enum.EasingDirection.Out},
    {_D("8AAE9A9D82A7"),   Enum.EasingStyle.Quad,    Enum.EasingDirection.In},
    {_D("8CA2A79E88AEAD"),  Enum.EasingStyle.Sine,    Enum.EasingDirection.Out},
    {_D("85A2A79E9AAB"),   Enum.EasingStyle.Linear,  Enum.EasingDirection.InOut},
    {_D("7B9A9CA488AEAD"),  Enum.EasingStyle.Back,    Enum.EasingDirection.Out},
    {_D("7CAE9BA29C88AEAD"), Enum.EasingStyle.Cubic,   Enum.EasingDirection.Out},
}
local easeIdx = 1
local teleporting = false
local function teleportToPosition(dest)
    if not root then return end
    if tpMode == _D("82A7ACAD9AA7AD") then
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
    if tpMode == _D("82A7ACAD9AA7AD") then
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
    
    pcall(function() tw.Completed:Wait() end)
    if wasFly then setFly(true) end
end

local function showPill()
    if ShowPillGUI then ShowPillGUI:Destroy() end
    local PlayerGui = LocalPlayer:WaitForChild(_D("89A59AB29EAB80AEA2"))
    local sg = Instance.new(_D("8C9CAB9E9EA780AEA2"))
    sg.Name = _D("89AEACA2A7A089A2A5A5")
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.Parent = PlayerGui

    local btn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    btn.Size = UDim2.fromOffset(160, 46)
    btn.Position = UDim2.new(0, 20, 0, 80)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,48)
    btn.TextColor3 = Color3.fromRGB(230,230,240)
    btn.Text = _D("8CA1A8B05989AEACA2A7A0")
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.BorderSizePixel = 0
    btn.Parent = sg
    Instance.new(_D("8E827CA8ABA79EAB"), btn).CornerRadius = UDim.new(1,0)

    btn.MouseButton1Click:Connect(function()
        if MainGUI then MainGUI.Enabled = true end
        if ShowPillGUI then ShowPillGUI:Destroy() ShowPillGUI=nil end
    end)

    ShowPillGUI = sg
end

local function createUI()
    local PlayerGui = LocalPlayer:WaitForChild(_D("89A59AB29EAB80AEA2"))

    
    local overlay = Instance.new(_D("8C9CAB9E9EA780AEA2"))
    overlay.Name = _D("89AEACA2A7A09B9AAD85A89A9DA2A7A0")
    overlay.ResetOnSpawn = false
    overlay.IgnoreGuiInset = true
    overlay.Parent = PlayerGui

    local dim = Instance.new(_D("7FAB9AA69E"))
    dim.Size = UDim2.fromScale(1,1)
    dim.BackgroundColor3 = Color3.new(0,0,0)
    dim.BackgroundTransparency = 0.5
    dim.BorderSizePixel = 0
    dim.Parent = overlay

    local textBg = Instance.new(_D("7FAB9AA69E"))
    textBg.AnchorPoint = Vector2.new(0.5,0.5)
    textBg.Position = UDim2.fromScale(0.5,0.5)
    textBg.Size = UDim2.fromOffset(520,100)
    textBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    textBg.BackgroundTransparency = 0.5
    textBg.BorderSizePixel = 0
    textBg.Parent = overlay
    Instance.new(_D("8E827CA8ABA79EAB"), textBg).CornerRadius = UDim.new(0,18)

    local text = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.Text = _D("7CAB9E9AAD9E9D599BB25989AEACA2A7A09B9AAD")
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 42
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.Parent = textBg

    
    if MainGUI then MainGUI:Destroy() end
    MainGUI = Instance.new(_D("8C9CAB9E9EA780AEA2"))
    MainGUI.Name = _D("89AEACA2A7A09B9AAD7CA8A7ADABA8A5A59EAB")
    MainGUI.ResetOnSpawn = false
    MainGUI.IgnoreGuiInset = true
    MainGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGUI.Parent = PlayerGui
    MainGUI.Enabled = false

    local frame = Instance.new(_D("7FAB9AA69E"))
    frame.Name = _D("869AA2A77FAB9AA69E")
    frame.Size = UDim2.fromOffset(420, 360)
    frame.Position = UDim2.new(0, 24, 0, 120)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = true
    frame.Parent = MainGUI
    Instance.new(_D("8E827CA8ABA79EAB"), frame).CornerRadius = UDim.new(0, 12)

    
    local header = Instance.new(_D("7FAB9AA69E"))
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.Parent = frame

    local title = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -220, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Text = _D("7CAB9E9AAD9E9D599BB259A9AEACA2A7A09B9AAD")
    title.Parent = header

    local searchBtn = Instance.new(_D("82A69AA09E7BAEADADA8A7"))
    searchBtn.Size = UDim2.fromOffset(26, 26)
    searchBtn.Position = UDim2.new(1, -96, 0.5, -13)
    searchBtn.BackgroundTransparency = 1
    searchBtn.Image = _D("AB9BB19AACAC9EADA29D7368686F696C6A69706E726C71")
    searchBtn.ImageColor3 = Color3.fromRGB(220,220,220)
    searchBtn.Parent = header

    local btnMin = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    btnMin.Size = UDim2.fromOffset(26, 26)
    btnMin.Position = UDim2.new(1, -64, 0.5, -13)
    btnMin.Text = _D("1BB9CC")
    btnMin.Font = Enum.Font.GothamBlack
    btnMin.TextSize = 18
    btnMin.TextColor3 = Color3.fromRGB(255,255,255)
    btnMin.BackgroundColor3 = Color3.fromRGB(70,70,80)
    btnMin.BorderSizePixel = 0
    btnMin.Parent = header
    Instance.new(_D("8E827CA8ABA79EAB"), btnMin).CornerRadius = UDim.new(1,0)

    local btnClose = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    btnClose.Size = UDim2.fromOffset(26, 26)
    btnClose.Position = UDim2.new(1, -32, 0.5, -13)
    btnClose.Text = _D("B1")
    btnClose.Font = Enum.Font.GothamBlack
    btnClose.TextSize = 16
    btnClose.TextColor3 = Color3.fromRGB(255,255,255)
    btnClose.BackgroundColor3 = Color3.fromRGB(90,50,50)
    btnClose.BorderSizePixel = 0
    btnClose.Parent = header
    Instance.new(_D("8E827CA8ABA79EAB"), btnClose).CornerRadius = UDim.new(1,0)

    
    local searchPanel = Instance.new(_D("7FAB9AA69E"))
    searchPanel.Size = UDim2.fromOffset(220, 36)
    searchPanel.Position = UDim2.new(1, -346, 0, 42)
    searchPanel.BackgroundColor3 = Color3.fromRGB(45,45,50)
    searchPanel.Visible = false
    searchPanel.Parent = frame
    Instance.new(_D("8E827CA8ABA79EAB"), searchPanel).CornerRadius = UDim.new(0, 8)

    local searchBox = Instance.new(_D("8D9EB1AD7BA8B1"))
    searchBox.Size = UDim2.new(1, -12, 1, -12)
    searchBox.Position = UDim2.new(0, 6, 0, 6)
    searchBox.BackgroundColor3 = Color3.fromRGB(55,55,60)
    searchBox.PlaceholderText = _D("8C9E9AAB9CA1599F9E9AADAEAB9E")
    searchBox.Text = _D("")
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 14
    searchBox.TextColor3 = Color3.fromRGB(230,230,230)
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchPanel
    Instance.new(_D("8E827CA8ABA79EAB"), searchBox).CornerRadius = UDim.new(0, 6)

    searchBtn.MouseButton1Click:Connect(function()
        searchPanel.Visible = not searchPanel.Visible
        if searchPanel.Visible then searchBox:CaptureFocus() end
    end)

    
    local drag = Instance.new(_D("7FAB9AA69E"))
    drag.BackgroundTransparency = 1
    drag.Size = UDim2.new(1, -240, 1, 0)
    drag.Position = UDim2.new(0, 0, 0, 0)
    drag.Parent = header

    
    local tabs = Instance.new(_D("7FAB9AA69E"))
    tabs.Size = UDim2.new(1, -16, 0, 30)
    tabs.Position = UDim2.new(0, 8, 0, 44)
    tabs.BackgroundTransparency = 1
    tabs.Parent = frame

    local function makeTabButton(text, xOffset)
        local b = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
        b.Size = UDim2.fromOffset(100, 28)
        b.Position = UDim2.new(0, xOffset, 0, 0)
        b.BackgroundColor3 = Color3.fromRGB(45,45,50)
        b.TextColor3 = Color3.fromRGB(230,230,230)
        b.Text = text
        b.Font = Enum.Font.GothamBold
        b.TextSize = 14
        b.BorderSizePixel = 0
        b.Parent = tabs
        Instance.new(_D("8E827CA8ABA79EAB"), b).CornerRadius = UDim.new(1,0)
        return b
    end

    local tabMainBtn = makeTabButton(_D("869AA2A7"), 0)
    local tabMiscBtn = makeTabButton(_D("86A2AC9C"), 108)
    local tabTpBtn   = makeTabButton(_D("8D9EA59EA9A8ABAD"), 216)
    local tabCfgBtn  = makeTabButton(_D("7CA8A79FA2A0"), 324)

    
    local function makeScroll()
        local scroll = Instance.new(_D("8C9CABA8A5A5A2A7A07FAB9AA69E"))
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

        local layout = Instance.new(_D("8E8285A2ACAD859AB2A8AEAD"))
        layout.FillDirection = Enum.FillDirection.Vertical
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll

        local pad = Instance.new(_D("8E82899A9D9DA2A7A0"))
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingBottom = UDim.new(0, 12)
        pad.PaddingLeft = UDim.new(0, 4)
        pad.PaddingRight = UDim.new(0, 4)
        pad.Parent = scroll

        local function recalc()
            scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + pad.PaddingBottom.Offset)
        end
        layout:GetPropertyChangedSignal(_D("7A9BACA8A5AEAD9E7CA8A7AD9EA7AD8CA2B39E")):Connect(recalc)
        return scroll, layout, recalc
    end

    local mainScroll, _, recalcMain = makeScroll()
    local miscScroll, _, recalcMisc = makeScroll()
    local tpScroll, _, recalcTp = makeScroll()
    local cfgScroll, _, recalcCfg = makeScroll()

    local function createRow(parent, height)
        local row = Instance.new(_D("7FAB9AA69E"))
        row.Size = UDim2.new(1, 0, 0, height)
        row.BackgroundColor3 = Color3.fromRGB(38,38,42)
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new(_D("8E827CA8ABA79EAB"), row).CornerRadius = UDim.new(0, 8)
        return row
    end

    local function makeSwitch(parent, labelText, initial, callback)
        local row = createRow(parent, 40)
        local lbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -120, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(235,235,235)
        lbl.Text = labelText
        lbl.Parent = row

        local switch = Instance.new(_D("7FAB9AA69E"))
        switch.Size = UDim2.fromOffset(58, 24)
        switch.Position = UDim2.new(1, -70, 0.5, -12)
        switch.BackgroundColor3 = initial and Color3.fromRGB(60,180,75) or Color3.fromRGB(120,120,120)
        switch.BorderSizePixel = 0
        switch.Parent = row
        Instance.new(_D("8E827CA8ABA79EAB"), switch).CornerRadius = UDim.new(1,0)

        local knob = Instance.new(_D("7FAB9AA69E"))
        knob.Size = UDim2.fromOffset(20,20)
        knob.Position = initial and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob.BorderSizePixel = 0
        knob.Parent = switch
        Instance.new(_D("8E827CA8ABA79EAB"), knob).CornerRadius = UDim.new(1,0)

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

        row:SetAttribute(_D("A59A9B9EA5"), labelText)
        return {Row=row, Set=function(v) value=v and true or false; redraw(); if callback then task.spawn(callback, value) end end}
    end

    local function makeSlider(parent, labelText, minV, maxV, initial, callback)
        local row = createRow(parent, 58)
        local lbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.Position = UDim2.new(0, 10, 0, 6)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 16
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(235,235,235)
        lbl.Text = string.format(_D("5EAC73595E9D"), labelText, initial)
        lbl.Parent = row

        local bar = Instance.new(_D("7FAB9AA69E"))
        bar.Size = UDim2.new(1, -20, 0, 8)
        bar.Position = UDim2.new(0, 10, 0, 34)
        bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
        bar.BorderSizePixel = 0
        bar.Parent = row
        Instance.new(_D("8E827CA8ABA79EAB"), bar).CornerRadius = UDim.new(0,8)

        local pct0 = (initial - minV) / (maxV - minV)
        local fill = Instance.new(_D("7FAB9AA69E"))
        fill.Size = UDim2.new(pct0, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        Instance.new(_D("8E827CA8ABA79EAB"), fill).CornerRadius = UDim.new(0,8)

        local knob = Instance.new(_D("7FAB9AA69E"))
        knob.Size = UDim2.fromOffset(18,18)
        knob.Position = UDim2.new(pct0, -9, 0.5, -9)
        knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
        knob.BorderSizePixel = 0
        knob.Parent = bar
        Instance.new(_D("8E827CA8ABA79EAB"), knob).CornerRadius = UDim.new(1,0)

        local dragging = false
        local function setFromPct(pct)
            pct = math.clamp(pct, 0, 1)
            local val = math.floor(minV + (maxV - minV) * pct + 0.5)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, -9, 0.5, -9)
            lbl.Text = string.format(_D("5EAC73595E9D"), labelText, val)
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

        row:SetAttribute(_D("A59A9B9EA5"), labelText)
        return {Row=row, Set=function(v) local pct=(math.clamp(v,minV,maxV)-minV)/(maxV-minV); setFromPct(pct) end}
    end


    local flySw = makeSwitch(mainScroll, _D("7FA5B2"), false, function(v) setFly(v) end)
    local ncSw  = makeSwitch(mainScroll, _D("87A87CA5A2A95961AD9EA69BAEAC62"), false, function(v) setNoclip(v) end)
    local wsSl  = makeSlider(mainScroll, _D("909AA5A4598CA99E9E9D5961ACADAE9DAC62"), MIN_WALK, MAX_WALK, walkSpeed, function(v) walkSpeed = v; ensurePhysics() end)
    local jpSl  = makeSlider(mainScroll, _D("83AEA6A95989A8B09EAB5961ACADAE9DAC62"), MIN_JUMP, MAX_JUMP, jumpPower, function(v) jumpPower = v; ensurePhysics() end)
    local ijmSw = makeSwitch(mainScroll, _D("82A79F5983AEA6A9596186A89BA2A59E62"), false, function(v) infJumpMobile = v end)
    local ijpSw = makeSwitch(mainScroll, _D("82A79F5983AEA6A95961897C62"), false, function(v) infJumpPC = v end)
    local nfdSw = makeSwitch(mainScroll, _D("87A8597F9AA5A5597D9AA69AA09E"), false, function(v) noFallDamage = v end)

    
    local fbSw  = makeSwitch(miscScroll, _D("7FAEA5A59BABA2A0A1AD59618D9EAB9AA7A0598D9EABAEAC62"), false, function(v) setFullBright(v) end)
    local fovSl = makeSlider(miscScroll, _D("7FA29EA59D59A89F598FA29EB0"), 60, 120, defaultFOV, function(v) setFOV(v) end)
    local rfSw  = makeSwitch(miscScroll, _D("8B9EA6A8AF9E597FA8A0"), false, function(v) setRemoveFog(v) end)

    
    local function createTpRow(h) 
        return createRow(tpScroll, h) 
    end

    
    local tourList = {}  

    local function setTour(list)
        tourList = list or {}
    end
    
    
    
    local tpToPlayerTitle = createTpRow(28)
    tpToPlayerTitle.BackgroundTransparency = 1
    local tptpLabel = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    tptpLabel.BackgroundTransparency = 1
    tptpLabel.Size = UDim2.new(1, -20, 1, 0)
    tptpLabel.Position = UDim2.new(0,10,0,0)
    tptpLabel.Text = _D("8D9EA59EA9A8ABAD59ADA85989A59AB29EAB")
    tptpLabel.TextColor3 = Color3.new(1,1,1)
    tptpLabel.TextXAlignment = Enum.TextXAlignment.Left
    tptpLabel.Font = Enum.Font.GothamBold
    tptpLabel.TextSize = 14
    tptpLabel.Parent = tpToPlayerTitle

    local pickerRow = createTpRow(56)
    pickerRow:SetAttribute(_D("A59A9B9EA5"),_D("8D9EA59EA9A8ABAD59ADA85989A59AB29EAB"))

    local playerNameLbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    playerNameLbl.BackgroundTransparency = 1
    playerNameLbl.Size = UDim2.new(1, -140, 0.5, -2)
    playerNameLbl.Position = UDim2.new(0, 10, 0, 4)
    playerNameLbl.Text = _D("8D9AABA09EAD7359619B9EA5AEA6599DA2A9A2A5A2A162")
    playerNameLbl.TextColor3 = Color3.fromRGB(235,235,235)
    playerNameLbl.TextXAlignment = Enum.TextXAlignment.Left
    playerNameLbl.Font = Enum.Font.Gotham
    playerNameLbl.TextSize = 15
    playerNameLbl.Parent = pickerRow

    local distanceLbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    distanceLbl.BackgroundTransparency = 1
    distanceLbl.Size = UDim2.new(1, -140, 0.5, -2)
    distanceLbl.Position = UDim2.new(0, 10, 0.5, 0)
    distanceLbl.Text = _D("7DA2ACAD9AA79C9E735966")
    distanceLbl.TextColor3 = Color3.fromRGB(200,200,200)
    distanceLbl.TextXAlignment = Enum.TextXAlignment.Left
    distanceLbl.Font = Enum.Font.Gotham
    distanceLbl.TextSize = 13
    distanceLbl.Parent = pickerRow

    local pickBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    pickBtn.Size = UDim2.new(0, 100, 0, 26)
    pickBtn.Position = UDim2.new(1, -120, 0, 6)
    pickBtn.Text = _D("89A2A5A2A15989A59AB29EAB")
    pickBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
    pickBtn.TextColor3 = Color3.new(1,1,1)
    pickBtn.BorderSizePixel = 0
    pickBtn.Parent = pickerRow
    Instance.new(_D("8E827CA8ABA79EAB"), pickBtn).CornerRadius = UDim.new(0,6)

    local refreshBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    refreshBtn.Size = UDim2.new(0, 100, 0, 26)
    refreshBtn.Position = UDim2.new(1, -120, 0, 30)
    refreshBtn.Text = _D("8B9E9FAB9EACA1")
    refreshBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
    refreshBtn.TextColor3 = Color3.new(1,1,1)
    refreshBtn.BorderSizePixel = 0
    refreshBtn.Parent = pickerRow
    Instance.new(_D("8E827CA8ABA79EAB"), refreshBtn).CornerRadius = UDim.new(0,6)

    local selectedPlayerName = nil
    local function openPlayerPopup()
        local pg = LocalPlayer:WaitForChild(_D("89A59AB29EAB80AEA2"))
        local pop = Instance.new(_D("8C9CAB9E9EA780AEA2"))
        pop.Name = _D("897B9889A59AB29EAB89A29CA49EAB")
        pop.ResetOnSpawn = false
        pop.Parent = pg

        local f = Instance.new(_D("7FAB9AA69E"))
        f.Size = UDim2.fromOffset(300, 320)
        f.Position = UDim2.new(0.5, -150, 0.5, -160)
        f.BackgroundColor3 = Color3.fromRGB(45,45,50)
        f.BorderSizePixel = 0
        f.Parent = pop
        f.ClipsDescendants = true
        Instance.new(_D("8E827CA8ABA79EAB"), f).CornerRadius = UDim.new(0, 10)

        local title = Instance.new(_D("8D9EB1AD859A9B9EA5"))
        title.Size = UDim2.new(1, -12, 0, 30)
        title.Position = UDim2.new(0,6,0,6)
        title.BackgroundColor3 = Color3.fromRGB(70,70,70)
        title.Text = _D("89A2A5A2A15989A59AB29EAB")
        title.TextColor3 = Color3.new(1,1,1)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14
        title.Parent = f
        Instance.new(_D("8E827CA8ABA79EAB"), title).CornerRadius = UDim.new(0,6)

        local list = Instance.new(_D("8C9CABA8A5A5A2A7A07FAB9AA69E"))
        list.Size = UDim2.new(1, -12, 1, -80)
        list.Position = UDim2.new(0,6,0,42)
        list.BackgroundTransparency = 1
        list.ScrollBarThickness = 6
        list.ClipsDescendants = true
        list.Parent = f
        local lay = Instance.new(_D("8E8285A2ACAD859AB2A8AEAD"))
        lay.Padding = UDim.new(0,6)
        lay.Parent = list

        local close = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
        close.Size = UDim2.new(1, -12, 0, 30)
        close.Position = UDim2.new(0,6,1,-36)
        close.Text = _D("8DAEADAEA9")
        close.BackgroundColor3 = Color3.fromRGB(90,60,60)
        close.TextColor3 = Color3.new(1,1,1)
        close.Parent = f
        Instance.new(_D("8E827CA8ABA79EAB"), close).CornerRadius = UDim.new(0,6)

        local function build()
            for _,ch in ipairs(list:GetChildren()) do
                if ch:IsA(_D("8D9EB1AD7BAEADADA8A7")) then ch:Destroy() end
            end
            for _,plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local b = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
                    b.Size = UDim2.new(1, -4, 0, 28)
                    b.Text = plr.Name
                    b.BackgroundColor3 = Color3.fromRGB(60,60,70)
                    b.TextColor3 = Color3.new(1,1,1)
                    b.Parent = list
                    Instance.new(_D("8E827CA8ABA79EAB"), b).CornerRadius = UDim.new(0,6)
                    b.MouseButton1Click:Connect(function()
                        selectedPlayerName = plr.Name
                        playerNameLbl.Text = _D("8D9AABA09EAD7359")..selectedPlayerName
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
            playerNameLbl.Text = _D("8D9AABA09EAD7359")..selectedPlayerName
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not tpScroll.Visible then return end
        if selectedPlayerName and root then
            local target = Players:FindFirstChild(selectedPlayerName)
            if target and target.Character and target.Character:FindFirstChild(_D("81AEA69AA7A8A29D8BA8A8AD899AABAD")) then
                local d = (root.Position - target.Character.HumanoidRootPart.Position).Magnitude
                distanceLbl.Text = string.format(_D("7DA2ACAD9AA79C9E73595E676A9F59ACADAE9DAC"), d)
            else
                distanceLbl.Text = _D("7DA2ACAD9AA79C9E735966")
            end
        else
            distanceLbl.Text = _D("7DA2ACAD9AA79C9E735966")
        end
    end)

    
    local modeRow = createTpRow(40)
    local modeLbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    modeLbl.BackgroundTransparency = 1
    modeLbl.Size = UDim2.new(1, -140, 1, 0)
    modeLbl.Position = UDim2.new(0,10,0,0)
    modeLbl.Text = _D("86A89D9E598D9EA59EA9A8ABAD")
    modeLbl.TextColor3 = Color3.fromRGB(235,235,235)
    modeLbl.TextXAlignment = Enum.TextXAlignment.Left
    modeLbl.Font = Enum.Font.Gotham
    modeLbl.TextSize = 16
    modeLbl.Parent = modeRow

    local modeInstant = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    modeInstant.Size = UDim2.new(0, 86, 0, 26)
    modeInstant.Position = UDim2.new(1, -196, 0.5, -13)
    modeInstant.Text = _D("82A7ACAD9AA7AD")
    modeInstant.BackgroundColor3 = Color3.fromRGB(0,120,0)
    modeInstant.TextColor3 = Color3.new(1,1,1)
    modeInstant.Parent = modeRow
    Instance.new(_D("8E827CA8ABA79EAB"), modeInstant).CornerRadius = UDim.new(0,6)

    local modeTween = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    modeTween.Size = UDim2.new(0, 86, 0, 26)
    modeTween.Position = UDim2.new(1, -100, 0.5, -13)
    modeTween.Text = _D("8DB09E9EA7")
    modeTween.BackgroundColor3 = Color3.fromRGB(70,70,70)
    modeTween.TextColor3 = Color3.new(1,1,1)
    modeTween.Parent = modeRow
    Instance.new(_D("8E827CA8ABA79EAB"), modeTween).CornerRadius = UDim.new(0,6)

    local function setMode(m)
        tpMode = m
        modeInstant.BackgroundColor3 = (m==_D("82A7ACAD9AA7AD")) and Color3.fromRGB(0,120,0) or Color3.fromRGB(70,70,70)
        modeTween.BackgroundColor3   = (m==_D("8DB09E9EA7"))   and Color3.fromRGB(0,120,0) or Color3.fromRGB(70,70,70)
    end
    modeInstant.MouseButton1Click:Connect(function() setMode(_D("82A7ACAD9AA7AD")) end)
    modeTween.MouseButton1Click:Connect(function() setMode(_D("8DB09E9EA7")) end)

    
    local tweenRow = createTpRow(58)
    tweenRow:SetAttribute(_D("A59A9B9EA5"),_D("8DB09E9EA7598C9EADADA2A7A0AC"))
    local durLbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    durLbl.BackgroundTransparency = 1
    durLbl.Size = UDim2.new(1, 0, 0, 20)
    durLbl.Position = UDim2.new(0,10,0,6)
    durLbl.Text = _D("8DB09E9EA7597DAEAB9AADA2A8A773596A6769AC")
    durLbl.TextColor3 = Color3.fromRGB(235,235,235)
    durLbl.TextXAlignment = Enum.TextXAlignment.Left
    durLbl.Font = Enum.Font.Gotham
    durLbl.TextSize = 16
    durLbl.Parent = tweenRow

    local bar = Instance.new(_D("7FAB9AA69E"))
    bar.Size = UDim2.new(0.6, -20, 0, 8)
    bar.Position = UDim2.new(0,10,0,34)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    bar.BorderSizePixel = 0
    bar.Parent = tweenRow
    Instance.new(_D("8E827CA8ABA79EAB"), bar).CornerRadius = UDim.new(0,8)

    local fill = Instance.new(_D("7FAB9AA69E"))
    fill.Size = UDim2.new(0.2, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new(_D("8E827CA8ABA79EAB"), fill).CornerRadius = UDim.new(0,8)

    local knob = Instance.new(_D("7FAB9AA69E"))
    knob.Size = UDim2.fromOffset(18,18)
    knob.Position = UDim2.new(0.2, -9, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    knob.BorderSizePixel = 0
    knob.Parent = bar
    Instance.new(_D("8E827CA8ABA79EAB"), knob).CornerRadius = UDim.new(1,0)

    local dragging = false
    local function setDurPct(p)
        p = math.clamp(p, 0, 1)
        tweenDuration = math.floor(((0.2 + 4.8 * p) * 10) + 0.5) / 10
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -9, 0.5, -9)
        durLbl.Text = string.format(_D("8DB09E9EA7597DAEAB9AADA2A8A773595E676A9FAC"), tweenDuration)
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

    local easeBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    easeBtn.Size = UDim2.new(0.35, -10, 0, 26)
    easeBtn.Position = UDim2.new(0.65, 0, 0, 30)
    easeBtn.Text = _D("7E9AACA2A7A073598AAE9A9D88AEAD")
    easeBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
    easeBtn.TextColor3 = Color3.new(1,1,1)
    easeBtn.BorderSizePixel = 0
    easeBtn.Parent = tweenRow
    Instance.new(_D("8E827CA8ABA79EAB"), easeBtn).CornerRadius = UDim.new(0,6)

    local function cycleEase()
        easeIdx = easeIdx % #easeStyles + 1
        easeBtn.Text = _D("7E9AACA2A7A07359")..easeStyles[easeIdx][1]
    end
    easeBtn.MouseButton1Click:Connect(cycleEase)

    
    local goRow = createTpRow(40)
    local goBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    goBtn.Size = UDim2.new(1, -20, 1, -10)
    goBtn.Position = UDim2.new(0,10,0,5)
    goBtn.Text = _D("8D9EA59EA9A8ABAD59ADA8598D9AABA09EAD5989A59AB29EAB")
    goBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    goBtn.TextColor3 = Color3.new(1,1,1)
    goBtn.BorderSizePixel = 0
    goBtn.Parent = goRow
    Instance.new(_D("8E827CA8ABA79EAB"), goBtn).CornerRadius = UDim.new(0,8)

    local function teleportToTarget()
        if not root then return end
        if not selectedPlayerName then return end
        local plr = Players:FindFirstChild(selectedPlayerName)
        if not plr or not plr.Character then return end
        local hrp = plr.Character:FindFirstChild(_D("81AEA69AA7A8A29D8BA8A8AD899AABAD"))
        if not hrp then return end
        teleportToPosition(hrp.Position + Vector3.new(0,3,0))
    end
    goBtn.MouseButton1Click:Connect(teleportToTarget)

    
    local function onRosterChange()
        if selectedPlayerName then
            local still = Players:FindFirstChild(selectedPlayerName)
            if not still then
                selectedPlayerName = nil
                playerNameLbl.Text = _D("8D9AABA09EAD7359619B9EA5AEA6599DA2A9A2A5A2A162")
            end
        end
    end
    Players.PlayerAdded:Connect(onRosterChange)
    Players.PlayerRemoving:Connect(onRosterChange)

    
    
    
    local btnBar = createTpRow(40)
    btnBar.BackgroundTransparency = 1
    local addBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    addBtn.Size = UDim2.new(0.5, -6, 1, 0)
    addBtn.Text = _D("7A9D9D597CAEABAB9EA7AD5985A89C9AADA2A8A7")
    addBtn.Font = Enum.Font.GothamBold
    addBtn.TextSize = 14
    addBtn.TextColor3 = Color3.new(1,1,1)
    addBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    addBtn.BorderSizePixel = 0
    addBtn.Parent = btnBar
    Instance.new(_D("8E827CA8ABA79EAB"), addBtn).CornerRadius = UDim.new(0,8)

    local delBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    delBtn.Size = UDim2.new(0.5, -6, 1, 0)
    delBtn.Position = UDim2.new(0.5, 6, 0, 0)
    delBtn.Text = _D("7D9EA59EAD9E598C9EA59E9CAD9E9D")
    delBtn.Font = Enum.Font.GothamBold
    delBtn.TextSize = 14
    delBtn.TextColor3 = Color3.new(1,1,1)
    delBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
    delBtn.BorderSizePixel = 0
    delBtn.Parent = btnBar
    Instance.new(_D("8E827CA8ABA79EAB"), delBtn).CornerRadius = UDim.new(0,8)

    
    
    
    local eximBar = createTpRow(40)
    eximBar.BackgroundTransparency = 1
    local exportBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    exportBtn.Size = UDim2.new(0.5, -6, 1, 0)
    exportBtn.Text = _D("7EB1A9A8ABAD5985A89C9AADA2A8A7AC")
    exportBtn.Font = Enum.Font.GothamBold
    exportBtn.TextSize = 14
    exportBtn.TextColor3 = Color3.new(1,1,1)
    exportBtn.BackgroundColor3 = Color3.fromRGB(0,90,140)
    exportBtn.BorderSizePixel = 0
    exportBtn.Parent = eximBar
    Instance.new(_D("8E827CA8ABA79EAB"), exportBtn).CornerRadius = UDim.new(0,8)

    local importBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    importBtn.Size = UDim2.new(0.5, -6, 1, 0)
    importBtn.Position = UDim2.new(0.5, 6, 0, 0)
    importBtn.Text = _D("82A6A9A8ABAD5985A89C9AADA2A8A7AC59618C9EABAF9EAB62")
    importBtn.Font = Enum.Font.GothamBold
    importBtn.TextSize = 14
    importBtn.TextColor3 = Color3.new(1,1,1)
    importBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
    importBtn.BorderSizePixel = 0
    importBtn.Parent = eximBar
    Instance.new(_D("8E827CA8ABA79EAB"), importBtn).CornerRadius = UDim.new(0,8)

    
    
    
    local function createLocationEntry(locationData)
        local entry = createTpRow(56)

        local checkbox = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
        checkbox.Size = UDim2.fromOffset(26, 26)
        checkbox.Position = UDim2.new(0, 10, 0.5, -13)
        checkbox.Text = _D("")
        checkbox.BackgroundColor3 = Color3.fromRGB(80,80,80)
        checkbox.BorderSizePixel = 0
        checkbox.Parent = entry
        Instance.new(_D("8E827CA8ABA79EAB"), checkbox).CornerRadius = UDim.new(0, 6)
        locationData.checkbox = checkbox

        local tpBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
        tpBtn.Size = UDim2.new(1, -56, 0.5, -4)
        tpBtn.Position = UDim2.new(0, 46, 0, 6)
        tpBtn.Text = locationData.name
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 14
        tpBtn.TextColor3 = Color3.new(1,1,1)
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
        tpBtn.BorderSizePixel = 0
        tpBtn.Parent = entry
        Instance.new(_D("8E827CA8ABA79EAB"), tpBtn).CornerRadius = UDim.new(0, 6)

        local info = Instance.new(_D("8D9EB1AD859A9B9EA5"))
        info.Size = UDim2.new(1, -56, 0.5, -4)
        info.Position = UDim2.new(0, 46, 0.5, 2)
        info.BackgroundTransparency = 1
        info.TextColor3 = Color3.fromRGB(200,200,200)
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.Gotham
        info.TextSize = 13
        info.Parent = entry

        local function setInfoFromPos(pos)
            local v = (typeof(pos)==_D("8F9E9CADA8AB6C")) and pos or unpackVec3(pos)
            if v then
                info.Text = string.format(_D("9173595E676A9F65599273595E676A9F65599373595E676A9F"), v.X, v.Y, v.Z)
            else
                info.Text = _D("82A7AF9AA5A29D59A9A8ACA2ADA2A8A7")
            end
        end
        setInfoFromPos(locationData.position)

        checkbox.MouseButton1Click:Connect(function()
            locationData.selected = not locationData.selected
            checkbox.BackgroundColor3 = locationData.selected and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
        end)

        tpBtn.MouseButton1Click:Connect(function()
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hrp = character:WaitForChild(_D("81AEA69AA7A8A29D8BA8A8AD899AABAD"))
            local v = (typeof(locationData.position)==_D("8F9E9CADA8AB6C")) and locationData.position or unpackVec3(locationData.position)
            if v then
                local dest = Vector3.new(v.X, v.Y, v.Z) + Vector3.new(0,3,0)
                if tpMode == _D("82A7ACAD9AA7AD") then
                    teleportToPosition(dest)
                else
                    teleportToPositionAndWait(dest)
                end
            end
        end)

        entry:SetAttribute(_D("A59A9B9EA5"), string.lower(locationData.name))
        return entry
    end

    
    
    
    local function promptName(defaultText, titleText, onSave)
        local prompt = Instance.new(_D("8C9CAB9E9EA780AEA2"))
        prompt.Name = _D("897B9889ABA8A6A9AD")
        prompt.Parent = PlayerGui
        local f = Instance.new(_D("7FAB9AA69E"))
        f.Size = UDim2.fromOffset(300, 150)
        f.Position = UDim2.new(0.5, -150, 0.5, -75)
        f.BackgroundColor3 = Color3.fromRGB(50,50,50)
        f.BorderSizePixel = 0
        f.Parent = prompt
        Instance.new(_D("8E827CA8ABA79EAB"), f).CornerRadius = UDim.new(0, 10)
        local titleLbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
        titleLbl.Size = UDim2.new(1, 0, 0, 30)
        titleLbl.BackgroundColor3 = Color3.fromRGB(70,70,70)
        titleLbl.Text = titleText
        titleLbl.TextColor3 = Color3.new(1,1,1)
        titleLbl.Parent = f
        local tb = Instance.new(_D("8D9EB1AD7BA8B1"))
        tb.Size = UDim2.new(1, -20, 0, 30)
        tb.Position = UDim2.new(0, 10, 0, 40)
        tb.Text = defaultText
        tb.BackgroundColor3 = Color3.fromRGB(30,30,30)
        tb.TextColor3 = Color3.new(1,1,1)
        tb.Parent = f
        local save = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
        save.Size = UDim2.new(0.5, -15, 0, 30)
        save.Position = UDim2.new(0, 10, 1, -40)
        save.Text = _D("8C9AAF9E")
        save.BackgroundColor3 = Color3.fromRGB(0,120,0)
        save.TextColor3 = Color3.new(1,1,1)
        save.Parent = f
        local cancel = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
        cancel.Size = UDim2.new(0.5, -15, 0, 30)
        cancel.Position = UDim2.new(0.5, 5, 1, -40)
        cancel.Text = _D("7C9AA79C9EA5")
        cancel.BackgroundColor3 = Color3.fromRGB(120,0,0)
        cancel.TextColor3 = Color3.new(1,1,1)
        cancel.Parent = f

        save.MouseButton1Click:Connect(function()
            local name = (tb.Text ~= _D("") and tb.Text) or defaultText
            prompt:Destroy()
            onSave(name)
        end)
        cancel.MouseButton1Click:Connect(function() prompt:Destroy() end)
    end

    
    
    
    addBtn.MouseButton1Click:Connect(function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = character:WaitForChild(_D("81AEA69AA7A8A29D8BA8A8AD899AABAD"))
        local defaultName = _D("85A89C9AADA2A8A759")..tostring(#savedLocations + 1)
        promptName(defaultName, _D("879AA69E59ADA1A2AC59A5A89C9AADA2A8A773"), function(name)
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

    
    
    
    exportBtn.MouseButton1Click:Connect(function()
        if #savedLocations == 0 then return end
        if not serverOnline then dprint(_D("9EB1A9A8ABAD7359AC9EABAF9EAB59A89F9FA5A2A79E")); return end

        local defaultName = _D("7EB1A9A8ABAD59")..tostring(os.time())
        promptName(defaultName, _D("7EB1A9A8ABAD599AAC73"), function(name)
            local copy = {}
            for _, loc in ipairs(savedLocations) do
                local p = packVec3(loc.position)
                if p then
                    copy[#copy+1] = { name = loc.name, position = p }
                else
                    dprint(_D("ACA4A2A9599EB1A9A8ABAD7459A2A7AF9AA5A29D59A9A8ACA2ADA2A8A759A8A7"), loc.name)
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

    
    
    
    importBtn.MouseButton1Click:Connect(function()
        if serverOnline then
            local ok,data = apiGetUser(HWID)
            if ok and data then
                exportedSets = data.exports or exportedSets
            end
        end

        local popup = Instance.new(_D("8C9CAB9E9EA780AEA2"))
        popup.Name = _D("897B9882A6A9A8ABAD85A2ACAD")
        popup.ResetOnSpawn = false
        popup.Parent = PlayerGui

        local f = Instance.new(_D("7FAB9AA69E"))
        f.Size = UDim2.fromOffset(360, 320)
        f.Position = UDim2.new(0.5, -180, 0.5, -160)
        f.BackgroundColor3 = Color3.fromRGB(45,45,50)
        f.BorderSizePixel = 0
        f.Parent = popup
        f.ClipsDescendants = true
        Instance.new(_D("8E827CA8ABA79EAB"), f).CornerRadius = UDim.new(0, 10)

        local lbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
        lbl.Size = UDim2.new(1, -12, 0, 30)
        lbl.Position = UDim2.new(0, 6, 0, 6)
        lbl.BackgroundColor3 = Color3.fromRGB(70,70,70)
        lbl.Text = _D("7CA1A8A8AC9E599EB1A9A8ABAD59ADA859A2A6A9A8ABAD")
        lbl.TextColor3 = Color3.new(1,1,1)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.Parent = f
        Instance.new(_D("8E827CA8ABA79EAB"), lbl).CornerRadius = UDim.new(0,6)

        local list = Instance.new(_D("8C9CABA8A5A5A2A7A07FAB9AA69E"))
        list.Size = UDim2.new(1, -12, 1, -106)
        list.Position = UDim2.new(0, 6, 0, 42)
        list.BackgroundTransparency = 1
        list.ScrollBarThickness = 6
        list.ClipsDescendants = true
        list.Parent = f

        local lay = Instance.new(_D("8E8285A2ACAD859AB2A8AEAD"))
        lay.Parent = list
        lay.Padding = UDim.new(0,6)

        local btnRow = Instance.new(_D("7FAB9AA69E"))
        btnRow.Size = UDim2.new(1, -12, 0, 36)
        btnRow.Position = UDim2.new(0, 6, 1, -42)
        btnRow.BackgroundTransparency = 1
        btnRow.Parent = f

        local function styleBtn(b)
            b.AutoButtonColor = true
            b.BorderSizePixel = 0
            Instance.new(_D("8E827CA8ABA79EAB"), b).CornerRadius = UDim.new(0,6)
            return b
        end

        local loadBtn = styleBtn(Instance.new(_D("8D9EB1AD7BAEADADA8A7")))
        loadBtn.Size = UDim2.new(0.4, -4, 1, 0)
        loadBtn.Position = UDim2.new(0, 0, 0, 0)
        loadBtn.Text = _D("85A89A9D")
        loadBtn.TextColor3 = Color3.new(1,1,1)
        loadBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
        loadBtn.Parent = btnRow

        local deleteBtn = styleBtn(Instance.new(_D("8D9EB1AD7BAEADADA8A7")))
        deleteBtn.Size = UDim2.new(0.4, -4, 1, 0)
        deleteBtn.Position = UDim2.new(0.4, 8, 0, 0)
        deleteBtn.Text = _D("7D9EA59EAD9E")
        deleteBtn.TextColor3 = Color3.new(1,1,1)
        deleteBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
        deleteBtn.Parent = btnRow

        local closeB = styleBtn(Instance.new(_D("8D9EB1AD7BAEADADA8A7")))
        closeB.Size = UDim2.new(0.2, -4, 1, 0)
        closeB.Position = UDim2.new(0.8, 8, 0, 0)
        closeB.Text = _D("7CA5A8AC9E")
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
                if ch:IsA(_D("8D9EB1AD7BAEADADA8A7")) then ch:Destroy() end
            end
            selectedName, selectedBtn = nil, nil
            setEnabled(loadBtn, false, Color3.fromRGB(0,120,0), Color3.fromRGB(70,70,70))
            setEnabled(deleteBtn, false, Color3.fromRGB(120,0,0), Color3.fromRGB(70,70,70))

            for name,_set in pairs(exportedSets) do
                local b = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
                b.Size = UDim2.new(1, -4, 0, 28)
                b.Text = name
                b.BackgroundColor3 = Color3.fromRGB(60,60,70)
                b.TextColor3 = Color3.new(1,1,1)
                b.Parent = list
                Instance.new(_D("8E827CA8ABA79EAB"), b).CornerRadius = UDim.new(0,6)

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
                    dprint(_D("ACA4A2A959A2A6A9A8ABAD7459A2A7AF9AA5A29D59A99A9CA49E9D59A9A8ACA2ADA2A8A759A8A7"), tostring(loc.name))
                end
            end
            recalcTp()
            popup:Destroy()
        end)

        deleteBtn.MouseButton1Click:Connect(function()
            if not selectedName then return end
            if not serverOnline then dprint(_D("9D9EA59EAD9E599EB1A9A8ABAD7359AC9EABAF9EAB59A89F9FA5A2A79E")); return end

            exportedSets[selectedName] = nil

            local body = {
                autoload = autoloadName,
                configs  = configs,
                exports  = normalizeExportsForSend(exportedSets),
                meta     = { username = USERNAME }
            }
            local ok,_ = apiPutUser(HWID, body)
            if not ok then
                dprint(_D("9D9EA59EAD9E599EB1A9A8ABAD59898E8D599F9AA2A59E9D"))
                return
            end

            rebuildList()
        end)

        closeB.MouseButton1Click:Connect(function() popup:Destroy() end)
    end)

    
    
    
    local tourRow = createTpRow(58)
    tourRow:SetAttribute(_D("A59A9B9EA5"),_D("7AAEADA8598DA8AEAB"))
    local tourLbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    tourLbl.BackgroundTransparency = 1
    tourLbl.Size = UDim2.new(1, 0, 0, 20)
    tourLbl.Position = UDim2.new(0,10,0,6)
    tourLbl.Text = _D("7AAEADA8598DA8AEAB59619AAD9AAC591BBFCB599B9AB09AA162")
    tourLbl.TextColor3 = Color3.fromRGB(235,235,235)
    tourLbl.TextXAlignment = Enum.TextXAlignment.Left
    tourLbl.Font = Enum.Font.Gotham
    tourLbl.TextSize = 16
    tourLbl.Parent = tourRow

    local intervalBox = Instance.new(_D("8D9EB1AD7BA8B1"))
    intervalBox.Size = UDim2.new(0.4, -20, 0, 26)
    intervalBox.Position = UDim2.new(0,10,0,30)
    intervalBox.Text = _D("6C")
    intervalBox.PlaceholderText = _D("82A7AD9EABAF9AA5599D9EADA2A4")
    intervalBox.TextColor3 = Color3.new(1,1,1)
    intervalBox.BackgroundColor3 = Color3.fromRGB(55,55,60)
    intervalBox.BorderSizePixel = 0
    intervalBox.Parent = tourRow
    Instance.new(_D("8E827CA8ABA79EAB"), intervalBox).CornerRadius = UDim.new(0,6)
    
    
    local snapRow = createTpRow(40)
    snapRow:SetAttribute(_D("A59A9B9EA5"),_D("8DA8AEAB598CA79AA9ACA1A8AD"))

    local getAllBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    getAllBtn.Size = UDim2.new(0.35, -8, 1, -10)
    getAllBtn.Position = UDim2.new(0,10,0,5)
    getAllBtn.Text = _D("809EAD597AA5A55989A8ACA2ADA2A8A7AC")
    getAllBtn.BackgroundColor3 = Color3.fromRGB(0,90,140)
    getAllBtn.TextColor3 = Color3.new(1,1,1)
    getAllBtn.BorderSizePixel = 0
    getAllBtn.Parent = snapRow
    Instance.new(_D("8E827CA8ABA79EAB"), getAllBtn).CornerRadius = UDim.new(0,8)

    local clearBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    clearBtn.Size = UDim2.new(0.25, -8, 1, -10)
    clearBtn.Position = UDim2.new(0.37, 0, 0, 5)
    clearBtn.Text = _D("7CA59E9AAB")
    clearBtn.BackgroundColor3 = Color3.fromRGB(90,60,60)
    clearBtn.TextColor3 = Color3.new(1,1,1)
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = snapRow
    Instance.new(_D("8E827CA8ABA79EAB"), clearBtn).CornerRadius = UDim.new(0,8)

    local tourCountLbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    tourCountLbl.BackgroundTransparency = 1
    tourCountLbl.Size = UDim2.new(0.35, -10, 1, 0)
    tourCountLbl.Position = UDim2.new(0.64, 0, 0, 0)
    tourCountLbl.Text = _D("8DA8AEAB599CA8AEA7AD735969")
    tourCountLbl.TextXAlignment = Enum.TextXAlignment.Right
    tourCountLbl.TextColor3 = Color3.fromRGB(220,220,220)
    tourCountLbl.Font = Enum.Font.Gotham
    tourCountLbl.TextSize = 14
    tourCountLbl.Parent = snapRow

    local function rebuildTourCounter()
        tourCountLbl.Text = (_D("8DA8AEAB599CA8AEA7AD73595E9D")):format(#tourList)
    end

    
    local function buildTourFromSaved()
        local list = {}
        for _, loc in ipairs(savedLocations) do
            local v = (typeof(loc.position) == _D("8F9E9CADA8AB6C")) and loc.position or unpackVec3(loc.position)
            if v then
                list[#list+1] = { name = loc.name, pos = Vector3.new(v.X, v.Y, v.Z) }
            end
        end
        return list
    end

    getAllBtn.MouseButton1Click:Connect(function()
        setTour(buildTourFromSaved())
        rebuildTourCounter()
        statusLbl.Text = _D("8CAD9AADAEAC73598CA79AA9ACA1A8AD59AEA99D9AAD9E9D")
    end)

    clearBtn.MouseButton1Click:Connect(function()
        setTour({})
        rebuildTourCounter()
        statusLbl.Text = _D("8CAD9AADAEAC73598CA79AA9ACA1A8AD599CA59E9AAB9E9D")
    end)

    local startBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    startBtn.Size = UDim2.new(0.25, -8, 0, 26)
    startBtn.Position = UDim2.new(0.42, 0, 0, 30)
    startBtn.Text = _D("8CAD9AABAD")
    startBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    startBtn.TextColor3 = Color3.new(1,1,1)
    startBtn.BorderSizePixel = 0
    startBtn.Parent = tourRow
    Instance.new(_D("8E827CA8ABA79EAB"), startBtn).CornerRadius = UDim.new(0,6)

    local stopBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    stopBtn.Size = UDim2.new(0.25, -8, 0, 26)
    stopBtn.Position = UDim2.new(0.69, 8, 0, 30)
    stopBtn.Text = _D("8CADA8A9")
    stopBtn.BackgroundColor3 = Color3.fromRGB(120,0,0)
    stopBtn.TextColor3 = Color3.new(1,1,1)
    stopBtn.BorderSizePixel = 0
    stopBtn.Parent = tourRow
    Instance.new(_D("8E827CA8ABA79EAB"), stopBtn).CornerRadius = UDim.new(0,6)

    local statusLbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    statusLbl.BackgroundTransparency = 1
    statusLbl.Size = UDim2.new(1, -20, 0, 18)
    statusLbl.Position = UDim2.new(0,10,0, 30+26+6)
    statusLbl.Text = _D("8CAD9AADAEAC7359829DA59E")
    statusLbl.TextColor3 = Color3.fromRGB(200,200,200)
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextSize = 13
    statusLbl.Parent = tourRow

    local tourRunning = false
    local function parseInterval()
        local raw = (intervalBox and intervalBox.Text) or _D("")
        local cleaned = raw:gsub(_D("94975E9D5E6796"), _D(""))  
        local n = tonumber(cleaned)
        if not n or n < 0.1 then n = 0.1 end
        return n
    end


    local function safeTeleport(dest)
        
        if (not root) or (not root.Parent) or (not hum) or hum.Health <= 0 then
            getCharacter()
        end
        if tpMode == _D("82A7ACAD9AA7AD") then
            teleportToPosition(dest)
        else
            teleportToPositionAndWait(dest)
        end
    end

    startBtn.MouseButton1Click:Connect(function()
        if tourRunning then return end

        if #tourList == 0 then
            statusLbl.Text = _D("8CAD9AADAEAC73598DA8AEAB59A5A2ACAD59A4A8ACA8A7A0591BB9CD59AD9EA49AA759809EAD597AA5A5599DAEA5AE")
            return
        end

        tourRunning = true
        statusLbl.Text = _D("8CAD9AADAEAC73598BAEA7A7A2A7A0")

        task.spawn(function()
            while tourRunning do
                for i = 1, #tourList do
                    if not tourRunning then break end

                    local item = tourList[i]
                    local dest = item.pos + Vector3.new(0, 3, 0)

                    
                    pcall(function()
                        safeTeleport(dest)
                    end)

                    
                    local waitSec = parseInterval()
                    if waitSec < 0.1 then waitSec = 0.1 end
                    local t0 = tick()
                    while tourRunning and (tick() - t0) < waitSec do
                        task.wait(0.05)
                    end
                end
            end
            statusLbl.Text = _D("8CAD9AADAEAC73598CADA8A9A99E9D")
        end)
    end)

    stopBtn.MouseButton1Click:Connect(function()
        tourRunning = false
        statusLbl.Text = _D("8CAD9AADAEAC73598CADA8A9A9A2A7A0676767")
    end)

    
    
    
    local function applySearchToScroll(scroll, recalc)
        local q = string.lower(searchBox.Text or _D(""))
        for _,row in ipairs(scroll:GetChildren()) do
            if row:IsA(_D("7FAB9AA69E")) then
                local label = string.lower(tostring(row:GetAttribute(_D("A59A9B9EA5")) or row.Name or _D("")))
                row.Visible = (q == _D("")) or (string.find(label, q, 1, true) ~= nil)
            end
        end
        if recalc then recalc() end
    end

    local activeTab = _D("869AA2A7")
    local function applySearch()
        if activeTab == _D("869AA2A7") then
            applySearchToScroll(mainScroll, recalcMain)
        elseif activeTab == _D("86A2AC9C") then
            applySearchToScroll(miscScroll, recalcMisc)
        elseif activeTab == _D("8D9EA59EA9A8ABAD") then
            local q = string.lower(searchBox.Text or _D(""))
            for _,row in ipairs(tpScroll:GetChildren()) do
                if row:IsA(_D("7FAB9AA69E")) and (row ~= nil) then
                    local label = tostring(row:GetAttribute(_D("A59A9B9EA5")) or _D(""))
                    row.Visible = (q == _D("")) or (string.find(label, q, 1, true) ~= nil)
                end
            end
            recalcTp()
        else
            applySearchToScroll(cfgScroll, recalcCfg)
        end
    end
    searchBox:GetPropertyChangedSignal(_D("8D9EB1AD")):Connect(applySearch)

    
    
    
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
    nameRow:SetAttribute(_D("A59A9B9EA5"),_D("7CA8A79FA2A059879AA69E"))
    local nameLbl2 = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    nameLbl2.BackgroundTransparency = 1
    nameLbl2.Size = UDim2.new(1, 0, 0, 20)
    nameLbl2.Position = UDim2.new(0,10,0,6)
    nameLbl2.Text = _D("7CA8A79FA2A059879AA69E")
    nameLbl2.TextColor3 = Color3.fromRGB(235,235,235)
    nameLbl2.Font = Enum.Font.Gotham
    nameLbl2.TextSize = 16
    nameLbl2.Parent = nameRow
    local nameBox = Instance.new(_D("8D9EB1AD7BA8B1"))
    nameBox.Size = UDim2.new(1, -20, 0, 28)
    nameBox.Position = UDim2.new(0,10,0,28)
    nameBox.PlaceholderText = _D("A6B2669CA8A79FA2A0")
    nameBox.Text = _D("")
    nameBox.TextColor3 = Color3.new(1,1,1)
    nameBox.BackgroundColor3 = Color3.fromRGB(55,55,60)
    nameBox.BorderSizePixel = 0
    nameBox.Parent = nameRow
    Instance.new(_D("8E827CA8ABA79EAB"), nameBox).CornerRadius = UDim.new(0,6)

    local saveRow = createRow(cfgScroll, 40)
    saveRow:SetAttribute(_D("A59A9B9EA5"),_D("8C9AAF9E597CA8A79FA2A0"))
    local saveBtn = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
    saveBtn.Size = UDim2.new(1, -20, 1, -10)
    saveBtn.Position = UDim2.new(0,10,0,5)
    saveBtn.Text = _D("8C9AAF9E597CA8A79FA2A059618C9EABAF9EAB62")
    saveBtn.BackgroundColor3 = Color3.fromRGB(0,120,0)
    saveBtn.TextColor3 = Color3.new(1,1,1)
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = saveRow
    Instance.new(_D("8E827CA8ABA79EAB"), saveBtn).CornerRadius = UDim.new(0,8)

    local listTitle = createRow(cfgScroll, 28)
    local lt = Instance.new(_D("8D9EB1AD859A9B9EA5"))
    lt.BackgroundTransparency = 1
    lt.Size = UDim2.new(1, -20, 1, 0)
    lt.Position = UDim2.new(0,10,0,0)
    lt.Text = _D("8C9AAF9E9D597CA8A79FA2A0AC59618C9EABAF9EAB62")
    lt.TextColor3 = Color3.new(1,1,1)
    lt.TextXAlignment = Enum.TextXAlignment.Left
    lt.Font = Enum.Font.GothamBold
    lt.TextSize = 14
    lt.Parent = listTitle

    local cfgList = createRow(cfgScroll, 180)
    cfgList.BackgroundTransparency = 1
    local cfgScrollInner = Instance.new(_D("8C9CABA8A5A5A2A7A07FAB9AA69E"))
    cfgScrollInner.Size = UDim2.new(1, -12, 1, 0)
    cfgScrollInner.Position = UDim2.new(0,6,0,0)
    cfgScrollInner.BackgroundTransparency = 1
    cfgScrollInner.ScrollBarThickness = 6
    cfgScrollInner.ClipsDescendants = true
    cfgScrollInner.Parent = cfgList
    local cfgLay = Instance.new(_D("8E8285A2ACAD859AB2A8AEAD"))
    cfgLay.Parent = cfgScrollInner
    cfgLay.Padding = UDim.new(0,6)

    local function rebuildCfgList()
        for _,ch in ipairs(cfgScrollInner:GetChildren()) do
            if ch:IsA(_D("8D9EB1AD7BAEADADA8A7")) or ch:IsA(_D("7FAB9AA69E")) then ch:Destroy() end
        end
        for name, s in pairs(configs) do
            local row = Instance.new(_D("7FAB9AA69E"))
            row.Size = UDim2.new(1, -4, 0, 32)
            row.BackgroundColor3 = Color3.fromRGB(50,50,58)
            row.Parent = cfgScrollInner
            Instance.new(_D("8E827CA8ABA79EAB"), row).CornerRadius = UDim.new(0,6)

            local nLbl = Instance.new(_D("8D9EB1AD859A9B9EA5"))
            nLbl.BackgroundTransparency = 1
            nLbl.Size = UDim2.new(0.5, -10, 1, 0)
            nLbl.Position = UDim2.new(0,10,0,0)
            nLbl.Text = name .. (autoloadName==name and _D("5959617AAEADA862") or _D(""))
            nLbl.TextXAlignment = Enum.TextXAlignment.Left
            nLbl.TextColor3 = Color3.new(1,1,1)
            nLbl.Parent = row

            local loadB = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
            loadB.Size = UDim2.new(0.2, -6, 0, 26)
            loadB.Position = UDim2.new(0.5, 0, 0.5, -13)
            loadB.Text = _D("85A89A9D")
            loadB.BackgroundColor3 = Color3.fromRGB(0,90,140)
            loadB.TextColor3 = Color3.new(1,1,1)
            loadB.Parent = row
            Instance.new(_D("8E827CA8ABA79EAB"), loadB).CornerRadius = UDim.new(0,6)

            local autoB = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
            autoB.Size = UDim2.new(0.2, -6, 0, 26)
            autoB.Position = UDim2.new(0.7, 0, 0.5, -13)
            autoB.Text = _D("7AAEADA8")
            autoB.BackgroundColor3 = autoloadName==name and Color3.fromRGB(0,150,0) or Color3.fromRGB(70,70,70)
            autoB.TextColor3 = Color3.new(1,1,1)
            autoB.Parent = row
            Instance.new(_D("8E827CA8ABA79EAB"), autoB).CornerRadius = UDim.new(0,6)

            local delB = Instance.new(_D("8D9EB1AD7BAEADADA8A7"))
            delB.Size = UDim2.new(0.1, -6, 0, 26)
            delB.Position = UDim2.new(0.9, 0, 0.5, -13)
            delB.Text = _D("7D9EA5")
            delB.BackgroundColor3 = Color3.fromRGB(120,0,0)
            delB.TextColor3 = Color3.new(1,1,1)
            delB.Parent = row
            Instance.new(_D("8E827CA8ABA79EAB"), delB).CornerRadius = UDim.new(0,6)

            loadB.MouseButton1Click:Connect(function() applySettings(s) end)
            autoB.MouseButton1Click:Connect(function()
                if not serverOnline then dprint(_D("9AAEADA859AC9EAD7359AC9EABAF9EAB59A89F9FA5A2A79E")); return end
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
                if not serverOnline then dprint(_D("9D9EA59EAD9E599CA8A79FA2A07359AC9EABAF9EAB59A89F9FA5A2A79E")); return end
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
        if not serverOnline then dprint(_D("AC9AAF9E599CA8A79FA2A07359AC9EABAF9EAB59A89F9FA5A2A79E")); return end
        local nm = nameBox.Text ~= _D("") and nameBox.Text or (_D("9CA8A79FA2A066")..tostring(os.time()))
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

    
    local function showTab(name)
        activeTab = name
        mainScroll.Visible = (name == _D("869AA2A7"))
        miscScroll.Visible = (name == _D("86A2AC9C"))
        tpScroll.Visible   = (name == _D("8D9EA59EA9A8ABAD"))
        cfgScroll.Visible  = (name == _D("7CA8A79FA2A0"))
        applySearch()
    end
    tabMainBtn.MouseButton1Click:Connect(function() showTab(_D("869AA2A7")) end)
    tabMiscBtn.MouseButton1Click:Connect(function() showTab(_D("86A2AC9C")) end)
    tabTpBtn.MouseButton1Click:Connect(function() showTab(_D("8D9EA59EA9A8ABAD")) end)
    tabCfgBtn.MouseButton1Click:Connect(function() showTab(_D("7CA8A79FA2A0")) end)
    showTab(_D("869AA2A7"))

    
    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        local vis = not minimized
        tabs.Visible = vis
        mainScroll.Visible = vis and (activeTab == _D("869AA2A7"))
        miscScroll.Visible = vis and (activeTab == _D("86A2AC9C"))
        tpScroll.Visible   = vis and (activeTab == _D("8D9EA59EA9A8ABAD"))
        cfgScroll.Visible  = vis and (activeTab == _D("7CA8A79FA2A0"))
        frame.Size = minimized and UDim2.fromOffset(420, 56) or UDim2.fromOffset(420, 360)
    end)
    btnClose.MouseButton1Click:Connect(function()
        MainGUI.Enabled = false
        showPill()
    end)

    
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


UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        setFly(not fly)
    end
end)


createUI()


game:BindToClose(function()
    setFly(false)
    cleanupFly()
end)
