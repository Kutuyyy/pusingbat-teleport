-- Pusingbat Piano Player — Delta Safe GUI + Watchdog (Mobile+PC)
-- UI: Play/Pause/Stop, Load Sample, Clear, Sliders; Movement lock + SuperLock; Touch Calibrate

-- ===== Services =====
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local VIM     = game:GetService("VirtualInputManager")
local RS      = game:GetService("RunService")

-- ===== Safe init =====
if not game:IsLoaded() then game.Loaded:Wait() end
while not Players.LocalPlayer do task.wait() end
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
while not workspace.CurrentCamera do RS.RenderStepped:Wait() end

-- ===== Safe GUI parent (Delta-friendly) =====
local function getSafeGuiParent()
    local ok, hui = pcall(function()
        return (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or nil
    end)
    if ok and typeof(hui) == "Instance" then return hui end

    local container = Instance.new("ScreenGui")
    container.Name = "PusingbatContainerPre"
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(container) end end)
    container.ResetOnSpawn = false
    container.IgnoreGuiInset = true
    container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    container.DisplayOrder = 999

    if PlayerGui then
        container.Parent = PlayerGui
        return container
    end

    local CoreGui = game:FindService("CoreGui") or game:GetService("CoreGui")
    container.Parent = CoreGui
    return container
end

local rootParent = getSafeGuiParent()
local rootIsScreenGui = rootParent:IsA("ScreenGui")
local gui = rootIsScreenGui and rootParent or Instance.new("ScreenGui")
if not rootIsScreenGui then
    gui.Name = "PusingbatPianoUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999
    gui.Enabled = true
    gui.Parent = rootParent
else
    gui.Name = "PusingbatPianoUI"
    gui.Enabled = true
end

-- Watchdog reparent
task.spawn(function()
    while gui and gui.Parent == nil do task.wait(0.25) end
    while gui do
        if gui.Parent == nil then gui.Parent = getSafeGuiParent() end
        task.wait(0.5)
    end
end)

-- ===== Params Player =====
local BPM                   = 97
local TOKENS_PER_BEAT       = 2
local HOLD_RATIO            = 0.65
local START_DELAY           = 3
local MICRO_STAGGER         = 0.004
local TOUCH_CHORD_ROLL_MS   = 12    -- 0..30 ms; makin kecil makin barengan
local TOUCH_ROLL_MODE       = "center" -- "left" | "right" | "center"

-- ===== Touch Playback (Mobile) =====
local TOUCH_MODE = UIS.TouchEnabled
local touchMap   = {}      -- [char] = Vector2 screen pos
local calibrating = false

local function getMouseXY()
    local p = UIS:GetMouseLocation()
    return Vector2.new(p.X, p.Y)
end

local function tapAt(pos, holdSec)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    if holdSec and holdSec > 0 then task.wait(holdSec) end
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

local function uniqueCharsFromSheet(sheet)
    local set = {}
    for tk in sheet:gmatch("%S+") do
        local body = tk
        if tk:sub(1,1) == "[" and tk:sub(-1) == "]" then body = tk:sub(2,-2) end
        for i = 1, #body do
            local ch = body:sub(i,i)
            if ch ~= " " then set[ch] = true end
        end
    end
    local list = {}
    for ch in pairs(set) do table.insert(list, ch) end
    table.sort(list)
    return list
end

-- ===== Runtime =====
local isPlaying, isPaused, shouldStop = false, false, false

-- ===== Key Maps =====
local digitMap = {
    ["0"]=Enum.KeyCode.Zero, ["1"]=Enum.KeyCode.One, ["2"]=Enum.KeyCode.Two,
    ["3"]=Enum.KeyCode.Three,["4"]=Enum.KeyCode.Four,["5"]=Enum.KeyCode.Five,
    ["6"]=Enum.KeyCode.Six,  ["7"]=Enum.KeyCode.Seven,["8"]=Enum.KeyCode.Eight, ["9"]=Enum.KeyCode.Nine,
}
local nonShiftPunct = {
    ["-"]=Enum.KeyCode.Minus, ["="]=Enum.KeyCode.Equals,
    ["["]=Enum.KeyCode.LeftBracket, ["]"]=Enum.KeyCode.RightBracket,
    [";"]=Enum.KeyCode.Semicolon,  ["'"]=Enum.KeyCode.Quote,
    [","]=Enum.KeyCode.Comma,      ["."]=Enum.KeyCode.Period,
    ["/"]=Enum.KeyCode.Slash,      ["\\"]=Enum.KeyCode.BackSlash,
    ["`"]=Enum.KeyCode.Backquote,
}
local shiftedPunct = {
    ["!"]=Enum.KeyCode.One,   ["@"]=Enum.KeyCode.Two,  ["#"]=Enum.KeyCode.Three,
    ["$"]=Enum.KeyCode.Four,  ["%"]=Enum.KeyCode.Five, ["^"]=Enum.KeyCode.Six,
    ["&"]=Enum.KeyCode.Seven, ["*"]=Enum.KeyCode.Eight,["("]=Enum.KeyCode.Nine,
    [")"]=Enum.KeyCode.Zero,  ["_"]=Enum.KeyCode.Minus,["+"]=Enum.KeyCode.Equals,
    ["{"]=Enum.KeyCode.LeftBracket, ["}"]=Enum.KeyCode.RightBracket,
    [":"]=Enum.KeyCode.Semicolon, ['"']=Enum.KeyCode.Quote,
    ["<"]=Enum.KeyCode.Comma, [">"]=Enum.KeyCode.Period, ["?"]=Enum.KeyCode.Slash,
    ["|"]=Enum.KeyCode.BackSlash, ["~"]=Enum.KeyCode.Backquote,
}
local SHIFT = Enum.KeyCode.LeftShift

local function keycodeFromLetter(letter)
    local up = string.upper(letter)
    if up:match("%a") and Enum.KeyCode[up] then
        return Enum.KeyCode[up], false
    end
    return nil, false
end

local function keycodeFromChar(ch)
    if ch == " " then return nil, false end
    if digitMap[ch]      then return digitMap[ch], false end
    if nonShiftPunct[ch] then return nonShiftPunct[ch], false end
    if shiftedPunct[ch]  then return shiftedPunct[ch], true end
    local kc = select(1, keycodeFromLetter(ch))
    if kc then return kc, false end
    warn("Karakter tidak dikenali di sheet: '"..ch.."'")
    return nil, false
end

-- ===== Movement Lock =====
local function getHumanoid()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChildOfClass("Humanoid")
end

local oldWalk, oldJump
local function immobilize(on)
    local hum = getHumanoid()
    if not hum then return end
    if on then
        oldWalk, oldJump = hum.WalkSpeed, hum.JumpPower
        hum.WalkSpeed = 0
        pcall(function() hum.UseJumpPower = true end)
        hum.JumpPower = 0
    else
        if oldWalk then hum.WalkSpeed = oldWalk end
        if oldJump then hum.JumpPower = oldJump end
    end
end

local function setMovementLock(lock)
    local ok, controls = pcall(function()
        local PM = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
        return PM:GetControls()
    end)
    if ok and controls then
        if lock then controls:Disable() else controls:Enable() end
    else
        immobilize(lock)
    end
end

-- ===== Super Lock (mobile proof) =====
local freezeConn
local prev = {anchored=false, autoRotate=true, ws=nil, jp=nil, ragdoll=true}

local function superLock(on)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and root) then return end

    if on then
        prev.anchored   = root.Anchored
        prev.autoRotate = hum.AutoRotate
        prev.ws         = hum.WalkSpeed
        prev.jp         = pcall(function() return hum.JumpPower end) and hum.JumpPower or nil
        prev.ragdoll    = pcall(function() return hum:GetStateEnabled(Enum.HumanoidStateType.Ragdoll) end) or true

        hum.AutoRotate = false
        hum.WalkSpeed  = 0
        pcall(function() hum.UseJumpPower = true hum.JumpPower = 0 end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end)

        root.Anchored = true

        if not freezeConn then
            freezeConn = RS.Stepped:Connect(function()
                if not (root and hum) then return end
                root.AssemblyLinearVelocity  = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                hum:Move(Vector3.new(), false)
            end)
        end
    else
        if freezeConn then freezeConn:Disconnect(); freezeConn = nil end
        root.Anchored = prev.anchored
        hum.AutoRotate = prev.autoRotate
        if prev.ws then hum.WalkSpeed = prev.ws end
        if prev.jp then pcall(function() hum.JumpPower = prev.jp end) end
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, prev.ragdoll) end)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    if isPlaying then
        task.defer(function()
            setMovementLock(true)
            superLock(true)
        end)
    end
end)

local function cleanup()
    setMovementLock(false)
    superLock(false)
end

-- ===== Input Sender =====
local function pressKey(kc, holdSec, useShift, rawChar)
    if TOUCH_MODE and touchMap[rawChar or ""] then
        tapAt(touchMap[rawChar], holdSec); return
    end
    if useShift then VIM:SendKeyEvent(true, SHIFT, false, game) end
    VIM:SendKeyEvent(true, kc, false, game)
    task.wait(holdSec)
    VIM:SendKeyEvent(false, kc, false, game)
    if useShift then VIM:SendKeyEvent(false, SHIFT, false, game) end
end

local function pressChord(keyList, holdSec, rawChars)
    if TOUCH_MODE then
        local pts = {}
        for _, ch in ipairs(rawChars) do
            local p = touchMap[ch]
            if p then table.insert(pts, {ch = ch, p = p}) end
        end
        if #pts == 0 then return end

        if TOUCH_ROLL_MODE == "left" then
            table.sort(pts, function(a,b) return a.p.X < b.p.X end)
        elseif TOUCH_ROLL_MODE == "right" then
            table.sort(pts, function(a,b) return a.p.X > b.p.X end)
        else
            local cx = workspace.CurrentCamera.ViewportSize.X/2
            table.sort(pts, function(a,b)
                return math.abs(a.p.X - cx) < math.abs(b.p.X - cx)
            end)
        end

        local step = math.max(TOUCH_CHORD_ROLL_MS, 0) / 1000
        for i, it in ipairs(pts) do
            VIM:SendMouseButtonEvent(it.p.X, it.p.Y, 0, true, game, 0)
            VIM:SendMouseButtonEvent(it.p.X, it.p.Y, 0, false, game, 0)
            if i < #pts and step > 0 then task.wait(step) end
        end
        if holdSec > (#pts-1)*step then task.wait(holdSec - (#pts-1)*step) end
        return
    end

    local needShift=false
    for _,info in ipairs(keyList) do if info.shift then needShift=true break end end
    if needShift then VIM:SendKeyEvent(true, SHIFT, false, game) end
    for i, info in ipairs(keyList) do
        VIM:SendKeyEvent(true, info.kc, false, game)
        if i < #keyList then task.wait(MICRO_STAGGER) end
    end
    task.wait(holdSec)
    for _, info in ipairs(keyList) do VIM:SendKeyEvent(false, info.kc, false, game) end
    if needShift then VIM:SendKeyEvent(false, SHIFT, false, game) end
end

-- ===== Parser =====
local function tokenize(sheet)
    local tokens = {}
    for tk in sheet:gmatch("%S+") do table.insert(tokens, tk) end
    return tokens
end

local function parseToken(token)
    if token:sub(1,1) == "[" and token:sub(-1) == "]" then
        return true, token:sub(2, -2)
    else
        return false, token
    end
end

-- ===== Player Core =====
local function playFromSheet(sheet, statusSetter)
    local beatSec = 60 / BPM
    local stepSec = beatSec / math.max(TOKENS_PER_BEAT, 1)
    local holdSec = math.clamp(stepSec * HOLD_RATIO, 0.01, 1.0)
    local gapSec  = math.max(stepSec - holdSec, 0.0001)

    statusSetter(("Mulai dalam %ds ..."):format(START_DELAY))
    task.wait(START_DELAY)

    local tokens = tokenize(sheet)
    local i, total = 1, #tokens

    while i <= total do
        if shouldStop then break end
        while isPaused do
            statusSetter(("Paused (%d/%d)"):format(i, total))
            task.wait(0.05)
        end

        local tk = tokens[i]
        if tk then
            local isChord, body = parseToken(tk)
            if isChord then
                local keyList, rawChars = {}, {}
                for j = 1, #body do
                    local ch = body:sub(j,j)
                    table.insert(rawChars, ch)
                    local kc, needShift = keycodeFromChar(ch)
                    if kc then table.insert(keyList, {kc = kc, shift = needShift}) end
                end
                if #keyList > 0 or TOUCH_MODE then pressChord(keyList, holdSec, rawChars) end
            else
                local ch = body:sub(1,1)
                local kc, needShift = keycodeFromChar(ch)
                pressKey(kc, holdSec, needShift, ch)
            end
            statusSetter(("Playing %d/%d"):format(i, total))
            task.wait(gapSec)
        end
        i = i + 1
    end

    if shouldStop then statusSetter("Stopped") else statusSetter("Selesai") end
end

-- ===== UI =====
local viewport = workspace.CurrentCamera.ViewportSize
local baseScale = math.clamp(viewport.X / 900, 0.90, 1.10)
local isTouch = UIS.TouchEnabled

-- Toast kecil
do
    local toast = Instance.new("TextLabel")
    toast.Size = UDim2.fromOffset(220, 36)
    toast.Position = UDim2.new(0, 16, 0, 60)
    toast.BackgroundColor3 = Color3.fromRGB(30,140,80)
    toast.TextColor3 = Color3.fromRGB(255,255,255)
    toast.Text = "UI Ready (Delta)"
    toast.Font = Enum.Font.GothamBold
    toast.TextSize = 16
    toast.Parent = gui
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0,8)
    task.delay(2, function() if toast then toast:Destroy() end end)

    if gui then
        gui.AncestryChanged:Connect(function(_, parent)
            if parent == nil then cleanup() end
        end)
    end

    Players.LocalPlayer.CharacterRemoving:Connect(cleanup)
end

-- Frame utama
local frame = Instance.new("Frame")
frame.Name = "Window"
frame.Size = UDim2.fromOffset(math.floor(420*baseScale), math.floor(520*baseScale))
frame.Position = UDim2.new(0, 24, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(28,28,28)
frame.BackgroundTransparency = 0.06
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1,0,0, math.floor(42*baseScale))
header.BackgroundColor3 = Color3.fromRGB(22,22,22)
header.BorderSizePixel = 0
header.Parent = frame
header.Active = true
header.ZIndex = 2
Instance.new("UICorner", header).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = math.floor(18*baseScale)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Text = "Pusingbat Piano Player"
title.ZIndex = 3
title.Parent = header

-- Minimize button
local mini = Instance.new("TextButton")
mini.Size = UDim2.fromOffset(math.floor(36*baseScale), math.floor(28*baseScale))
mini.Position = UDim2.new(1, -math.floor(40*baseScale), 0.5, -math.floor(14*baseScale))
mini.BackgroundColor3 = Color3.fromRGB(55,120,255)
mini.TextColor3 = Color3.new(1,1,1)
mini.TextSize = math.floor(14*baseScale)
mini.Font = Enum.Font.GothamBold
mini.Text = "-"
mini.ZIndex = 4
mini.Parent = header
Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 6)

-- Drag ramah mobile
do
  local dragging=false; local startPos; local startXY; local dragInput
  local function update(input)
    local d = input.Position - startXY
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
  end
  header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
      dragging = true; startPos = frame.Position; startXY = input.Position; dragInput = input
    end
  end)
  header.InputEnded:Connect(function(input) if input == dragInput then dragging = false end end)
  UIS.InputChanged:Connect(function(input) if dragging and input == dragInput then update(input) end end)
end

-- Body (1x saja!)
local body = Instance.new("ScrollingFrame")
body.Name = "Body"
body.Size = UDim2.new(1, -16, 1, -math.floor(42*baseScale) - 12)
body.Position = UDim2.new(0, 8, 0, math.floor(42*baseScale) + 4)
body.BackgroundTransparency = 1
body.ScrollBarThickness = isTouch and math.floor(10*baseScale) or math.floor(6*baseScale)
body.ScrollingDirection = Enum.ScrollingDirection.Y
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.CanvasSize = UDim2.new()
body.ZIndex = 1
body.Parent = frame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,8)
padding.PaddingBottom = UDim.new(0,8)
padding.PaddingLeft = UDim.new(0,4)
padding.PaddingRight = UDim.new(0,4)
padding.Parent = body

local list = Instance.new("UIListLayout")
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Padding = UDim.new(0, math.floor(8*baseScale))
list.Parent = body

-- Helpers
local function section(height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, height)
    f.BackgroundColor3 = Color3.fromRGB(35,35,35)
    f.BorderSizePixel = 0
    f.Parent = body
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    return f
end

local function makeLabel(parent, text, size)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, -16, 0, math.floor(22*baseScale))
    l.Position = UDim2.new(0, 12, 0, 6)
    l.Font = Enum.Font.Gotham
    l.TextSize = size or math.floor(14*baseScale)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Text = text
    l.Parent = parent
    return l
end

local function makeHRow(parent, height)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, -24, 0, height)
    wrap.Position = UDim2.new(0, 12, 0, math.floor(36*baseScale))
    wrap.BackgroundTransparency = 1
    wrap.Parent = parent
    local hlist = Instance.new("UIListLayout")
    hlist.FillDirection = Enum.FillDirection.Horizontal
    hlist.SortOrder = Enum.SortOrder.LayoutOrder
    hlist.Padding = UDim.new(0, 8)
    hlist.VerticalAlignment = Enum.VerticalAlignment.Center
    hlist.Parent = wrap
    return wrap
end

local function makeButton(parent, label, sizeUDim2, cb, color)
    local btn = Instance.new("TextButton")
    btn.Size = sizeUDim2
    btn.BackgroundColor3 = color or Color3.fromRGB(55,120,255)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = math.floor(16*baseScale)
    btn.Font = Enum.Font.GothamBold
    btn.Text = label
    btn.AutoButtonColor = true
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.Activated:Connect(function() if cb then cb() end end)
    return btn
end

local function makeSliderRow(titleText, minV, maxV, initial, onChange, formatter)
    local s = section(math.floor(74*baseScale))
    makeLabel(s, titleText .. ": " .. (formatter and formatter(initial) or tostring(initial)))
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, math.floor(10*baseScale))
    bar.Position = UDim2.new(0, 12, 0, math.floor(40*baseScale))
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    bar.BorderSizePixel = 0
    bar.Parent = s
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

    local fill = Instance.new("Frame")
    local pct0 = (initial - minV) / (maxV - minV)
    fill.Size = UDim2.new(pct0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(math.floor(18*baseScale), math.floor(18*baseScale))
    knob.Position = UDim2.new(pct0, -math.floor(9*baseScale), 0.5, -math.floor(9*baseScale))
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    knob.BorderSizePixel = 0
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local lbl = s:FindFirstChildOfClass("TextLabel")
    local dragging, val = false, initial
    local function setFromPct(p)
        p = math.clamp(p, 0, 1)
        val = minV + (maxV - minV) * p
        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, -math.floor(9*baseScale), 0.5, -math.floor(9*baseScale))
        lbl.Text = titleText .. ": " .. (formatter and formatter(val) or tostring(val))
        if onChange then onChange(val) end
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

    return { Set = function(v)
        local p = (math.clamp(v, minV, maxV) - minV) / (maxV - minV)
        setFromPct(p)
    end }
end

-- ===== Status =====
local statusSec = section(math.floor(56*baseScale))
local statusLabel = makeLabel(statusSec, "Status: Idle", math.floor(14*baseScale))
statusLabel.Position = UDim2.new(0, 12, 0, 10)
statusLabel.TextColor3 = Color3.fromRGB(180,220,255)
local function setStatus(txt) statusLabel.Text = "Status: "..txt end

-- ===== Sheets =====
local sheetSec = section(math.floor(200*baseScale))
makeLabel(sheetSec, "Sheets (format bracket)", math.floor(14*baseScale))
local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -24, 1, -math.floor(50*baseScale))
box.Position = UDim2.new(0, 12, 0, math.floor(36*baseScale))
box.BackgroundColor3 = Color3.fromRGB(38,38,38)
box.TextColor3 = Color3.fromRGB(235,235,235)
box.TextSize = math.floor(14*baseScale)
box.Font = Enum.Font.Code
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.ClearTextOnFocus = false
box.MultiLine = true
box.TextWrapped = true
box.PlaceholderText = "Tempel Sheets di sini...\nContoh: [4o] p s g f d ..."
box.Parent = sheetSec
Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

-- ===== Minimize helper (harus setelah 'mini' dibuat) =====
local minimized = false
local function setMinimized(state)
    minimized = state and true or false
    if minimized then
        body.Visible = false
        frame.Size = UDim2.fromOffset(frame.Size.X.Offset, math.floor(42*baseScale)+4)
        mini.Text = "+"
    else
        body.Visible = true
        frame.Size = UDim2.fromOffset(math.floor(420*baseScale), math.floor(520*baseScale))
        mini.Text = "-"
    end
end
mini.Activated:Connect(function() setMinimized(not minimized) end)

-- ===== Calibrate (Touch) =====
local calibSec = section(math.floor(80*baseScale))
makeLabel(calibSec, "Mobile Touch Playback", math.floor(14*baseScale))
local wrapCal = makeHRow(calibSec, math.floor(36*baseScale))

makeButton(wrapCal, "Calibrate (Touch)", UDim2.new(1, 0, 1, 0), function()
    if calibrating then setStatus("Sedang kalibrasi..."); return end
    local sheet = box.Text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if sheet == "" then setStatus("Isi sheet dulu untuk kalibrasi"); return end

    local prevPos = frame.Position
    local prevMin = minimized
    setMinimized(true)
    frame.Position = UDim2.new(0, 12, 0, 12)

    calibrating = true
    setStatus("Kalibrasi mulai…")
    touchMap = {}

    local chars = uniqueCharsFromSheet(sheet)
    if #chars == 0 then
        setStatus("Tidak ada token")
        calibrating = false
        frame.Position = prevPos
        setMinimized(prevMin)
        return
    end

    local overlay = Instance.new("TextButton")
    overlay.BackgroundTransparency = 1
    overlay.AutoButtonColor = false
    overlay.Text = ""
    overlay.Size = UDim2.fromScale(1,1)
    overlay.ZIndex = 9999
    overlay.Modal = true
    overlay.Parent = gui

    local idx = 1
    local prompt = Instance.new("TextLabel")
    prompt.Size = UDim2.fromOffset(360, 36)
    prompt.Position = UDim2.new(0, 16, 0, 60)
    prompt.BackgroundColor3 = Color3.fromRGB(50,50,50)
    prompt.TextColor3 = Color3.fromRGB(255,255,255)
    prompt.Font = Enum.Font.GothamBold
    prompt.TextSize = 16
    prompt.ZIndex = 10000
    prompt.Parent = gui
    Instance.new("UICorner", prompt).CornerRadius = UDim.new(0,8)

    local function setPrompt()
        prompt.Text = ("Tap tuts bertuliskan:  %s   (%d/%d)"):format(chars[idx], idx, #chars)
    end
    setPrompt()

    local function finishCalib()
        if overlay then overlay:Destroy() overlay = nil end
        if prompt  then prompt:Destroy()  prompt  = nil end
        calibrating = false
        setStatus("Kalibrasi selesai ✓")
        frame.Position = prevPos
        setMinimized(prevMin)
    end

    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local p = input.Position
            local pos = Vector2.new(p.X, p.Y)
            local ch = chars[idx]
            touchMap[ch] = pos
            idx += 1
            if idx > #chars then finishCalib() else setPrompt() end
        end
    end)
end, Color3.fromRGB(90,140,255))

-- ===== Preset Buttons =====
local btnRow = section(math.floor(80*baseScale))
makeLabel(btnRow, "Preset", math.floor(14*baseScale))
local wrap1 = (function()
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, -24, 0, math.floor(36*baseScale))
    wrap.Position = UDim2.new(0, 12, 0, math.floor(36*baseScale))
    wrap.BackgroundTransparency = 1
    wrap.Parent = btnRow
    local h = Instance.new("UIListLayout")
    h.FillDirection = Enum.FillDirection.Horizontal
    h.SortOrder = Enum.SortOrder.LayoutOrder
    h.Padding = UDim.new(0, 8)
    h.VerticalAlignment = Enum.VerticalAlignment.Center
    h.Parent = wrap
    return wrap
end)()

makeButton(wrap1, "Load Sample (blue.)", UDim2.new(0.5, -4, 1, 0), function()
    box.Text = table.concat({
        "t r w t r w  t r w t y u",
        "[4o] p s g f d   5 a s d s",
        "[1o] u i o   [6a] s",
        "[4o] p s g f a   5 h g f",
        "[1s] s s d d d   [6f] f f a a a",
        "4 t p o   [5p] o u i   [1o] i u t   [6t]"
    }, "  ")
end)
makeButton(wrap1, "Clear", UDim2.new(0.5, -4, 1, 0), function() box.Text = "" end, Color3.fromRGB(80,80,80))

-- ===== Transport =====
local ctlSec = section(math.floor(96*baseScale))
makeLabel(ctlSec, "Transport", math.floor(14*baseScale))
local wrap2 = (function()
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, -24, 0, math.floor(36*baseScale))
    wrap.Position = UDim2.new(0, 12, 0, math.floor(36*baseScale))
    wrap.BackgroundTransparency = 1
    wrap.Parent = ctlSec
    local h = Instance.new("UIListLayout")
    h.FillDirection = Enum.FillDirection.Horizontal
    h.SortOrder = Enum.SortOrder.LayoutOrder
    h.Padding = UDim.new(0, 8)
    h.VerticalAlignment = Enum.VerticalAlignment.Center
    h.Parent = wrap
    return wrap
end)()

local function makeTransportButton(text, color)
    return makeButton(wrap2, text, UDim2.new(1/3, -6, 1, 0), nil, color)
end

local playBtn  = makeTransportButton("Play")
local pauseBtn = makeTransportButton("Pause/Resume")
local stopBtn  = makeTransportButton("Stop", Color3.fromRGB(200,70,70))

playBtn.Activated:Connect(function()
    if isPlaying then setStatus("Sudah Playing..."); return end
    local sheet = box.Text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if sheet == "" then setStatus("Sheet kosong!"); return end
    isPlaying, isPaused, shouldStop = true, false, false
    setMovementLock(true)
    superLock(true)                       -- ON saat mulai
    setStatus("Starting...")
    task.spawn(function()
        playFromSheet(sheet, setStatus)
        isPlaying, isPaused = false, false
        setMovementLock(false)
        superLock(false)                  -- OFF saat selesai normal
    end)
end)

pauseBtn.Activated:Connect(function()
    if not isPlaying then setStatus("Belum Playing"); return end
    isPaused = not isPaused
    setStatus(isPaused and "Paused" or "Resumed")
end)

stopBtn.Activated:Connect(function()
    if not isPlaying then setStatus("Idle"); return end
    shouldStop, isPaused = true, false
    setMovementLock(false)
    superLock(false)                      -- OFF saat stop
    setStatus("Stopping...")
end)

-- ===== Sliders =====
local bpmRow = makeSliderRow("BPM", 40, 200, BPM, function(v)
    BPM = math.floor(v + 0.5)
end, function(v) return ("%d"):format(v) end)

local tpbRow = nil
tpbRow = makeSliderRow("Tokens per Beat", 1, 4, TOKENS_PER_BEAT, function(v)
    TOKENS_PER_BEAT = math.max(1, math.floor(v + 0.25))
    if tpbRow and tpbRow.Set then tpbRow.Set(TOKENS_PER_BEAT) end
end, function(v) return ("%0.1f"):format(v) end)

local hrRow  = makeSliderRow("Hold Ratio", 0.30, 0.90, HOLD_RATIO, function(v)
    HOLD_RATIO = math.clamp(v, 0.30, 0.90)
end, function(v) return ("%d%%"):format(math.floor(v*100+0.5)) end)

local sdRow  = makeSliderRow("Start Delay (s)", 0, 8, START_DELAY, function(v)
    START_DELAY = math.max(0, v)
end, function(v) return ("%0.1f s"):format(v) end)

local msRow  = makeSliderRow("Micro Stagger", 0.0, 0.03, MICRO_STAGGER, function(v)
    MICRO_STAGGER = math.clamp(v, 0, 0.03)
end, function(v) return ("%d ms"):format(math.floor(v*1000+0.5)) end)

-- ===== Hint =====
local hint = section(math.floor(56*baseScale))
makeLabel(hint, "Tips: klik area piano (chat OFF). Atur BPM/Timing di slider. Saat Play, karakter dikunci.", math.floor(12*baseScale))
