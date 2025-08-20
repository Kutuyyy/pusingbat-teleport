--[[
    Pusingbat Piano Player — Rapi + Draggable + Scrollable + Movement Lock
    - Panel draggable via header
    - Konten scrollable (AutomaticCanvasSize.Y) — nyaman di HP
    - Play / Pause / Stop, Load Sample (blue.) / Clear
    - Slider: BPM, Tokens/Beat, Hold Ratio, Start Delay, Micro Stagger
    - Movement Lock saat Playing:
        * Utama: Disable kontrol Roblox (PlayerModule Controls)
        * Fallback: WalkSpeed/JumpPower = 0 (restore setelah selesai)
    - Aman di respawn: tetap terkunci jika masih Playing

    Cara pakai:
    1) Klik area pianonya (chat OFF).
    2) Paste Sheets ke kotak, atur slider → Play.
]]

-- ===== Services =====
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ===== Hapus UI lama jika ada (biar gak dobel) =====
pcall(function()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _, g in ipairs(pg:GetChildren()) do
            if g:IsA("ScreenGui") and (g.Name == "PusingbatPianoUI" or g.Name == "PusingbatOverlay") then
                g:Destroy()
            end
        end
    end
end)

-- ===== Player Params (default) =====
local BPM            = 97
local TOKENS_PER_BEAT= 2
local HOLD_RATIO     = 0.65
local START_DELAY    = 3
local MICRO_STAGGER  = 0.004

-- ===== Runtime State =====
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
    if digitMap[ch] then return digitMap[ch], false end
    if nonShiftPunct[ch] then return nonShiftPunct[ch], false end
    if shiftedPunct[ch] then return shiftedPunct[ch], true end
    local kc = select(1, keycodeFromLetter(ch))
    if kc then return kc, false end
    warn("Karakter tidak dikenali di sheet: '"..ch.."'")
    return nil, false
end

-- ===== Input Sender =====
local function pressKey(kc, holdSec, useShift)
    if useShift then VIM:SendKeyEvent(true, SHIFT, false, game) end
    VIM:SendKeyEvent(true, kc, false, game)
    task.wait(holdSec)
    VIM:SendKeyEvent(false, kc, false, game)
    if useShift then VIM:SendKeyEvent(false, SHIFT, false, game) end
end

local function pressChord(keyList, holdSec)
    local needShift = false
    for _, info in ipairs(keyList) do
        if info.shift then needShift = true break end
    end
    if needShift then VIM:SendKeyEvent(true, SHIFT, false, game) end
    for i, info in ipairs(keyList) do
        VIM:SendKeyEvent(true, info.kc, false, game)
        if i < #keyList then task.wait(MICRO_STAGGER) end
    end
    task.wait(holdSec)
    for _, info in ipairs(keyList) do
        VIM:SendKeyEvent(false, info.kc, false, game)
    end
    if needShift then VIM:SendKeyEvent(false, SHIFT, false, game) end
end

-- ===== Parser =====
local function tokenize(sheet)
    local tokens = {}
    for tk in sheet:gmatch("%S+") do
        table.insert(tokens, tk)
    end
    return tokens
end

local function parseToken(token)
    if token:sub(1,1) == "[" and token:sub(-1,-1) == "]" then
        return true, token:sub(2, -2)
    else
        return false, token
    end
end

-- ===== Movement Lock (anti karakter jalan saat Play) =====
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

local controlsObj -- cache Controls
local function setMovementLock(lock)
    -- Coba disable default controls
    local ok, controls = pcall(function()
        if not controlsObj then
            local PM = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
            controlsObj = PM:GetControls()
        end
        return controlsObj
    end)
    if ok and controls then
        if lock then controls:Disable() else controls:Enable() end
    else
        -- Fallback: matikan movement lewat Walk/Jump
        immobilize(lock)
    end
end

-- Jika respawn saat masih Playing, tetap terkunci
LocalPlayer.CharacterAdded:Connect(function()
    if isPlaying then
        task.defer(function() setMovementLock(true) end)
    end
end)

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
                local keyList = {}
                for j = 1, #body do
                    local ch = body:sub(j,j)
                    local kc, needShift = keycodeFromChar(ch)
                    if kc then table.insert(keyList, {kc = kc, shift = needShift}) end
                end
                if #keyList > 0 then pressChord(keyList, holdSec) end
            else
                local ch = body:sub(1,1)
                local kc, needShift = keycodeFromChar(ch)
                if kc then pressKey(kc, holdSec, needShift) end
            end
            statusSetter(("Playing %d/%d"):format(i, total))
            task.wait(gapSec)
        end
        i += 1
    end

    if shouldStop then
        statusSetter("Stopped")
    else
        statusSetter("Selesai")
    end
end

-- ===== UI =====
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Responsive scale utk HP
local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
local baseScale = math.clamp(viewport.X / 900, 0.90, 1.10)
local isTouch = UIS.TouchEnabled

-- Root GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PusingbatPianoUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

-- Main window (draggable)
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
mini.Parent = header
Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 6)

-- Drag area (header)
do
    local dragging, startPos, startInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input
            startPos = frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput.Position
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Body (ScrollingFrame)
local body = Instance.new("ScrollingFrame")
body.Name = "Body"
body.Size = UDim2.new(1, -16, 1, -math.floor(42*baseScale) - 12)
body.Position = UDim2.new(0, 8, 0, math.floor(42*baseScale) + 4)
body.BackgroundTransparency = 1
body.ScrollBarThickness = isTouch and math.floor(10*baseScale) or math.floor(6*baseScale)
body.ScrollingDirection = Enum.ScrollingDirection.Y
body.AutomaticCanvasSize = Enum.AutomaticSize.Y
body.CanvasSize = UDim2.new()
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
    f.LayoutOrder = #body:GetChildren()+1
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

local function makeButton(parent, label, x, w, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w, 0, math.floor(36*baseScale))
    btn.Position = UDim2.new(0, x, 0, math.floor(36*baseScale))
    btn.BackgroundColor3 = Color3.fromRGB(55,120,255)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = math.floor(16*baseScale)
    btn.Font = Enum.Font.GothamBold
    btn.Text = label
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
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
    Instance.new("UICorner", knob).CornerRadius = UDim.New(1,0) -- fix casing
end
