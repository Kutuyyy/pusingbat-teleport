--[[ 
    Pusingbat Piano Player — UI Only + Player
    - UI panel: Play, Pause, Stop, Load Sample, Clear
    - TextBox multi-line untuk Sheets (format bracket: [pwdj] p ...)
    - Slider: BPM, Tokens/Beat, Hold Ratio, Start Delay, Micro Stagger
    - Status indicator: Idle/Playing/Paused/Stopped
    - Penekan tombol memakai VirtualInputManager (meniru main piano manual)
    NOTE:
    - Fokuskan kursor ke piano (chat TIDAK aktif) sebelum Play.
    - Kamu bisa paste Sheets-mu ke TextBox lalu klik Play.
]]

--= SERVICES =--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

--= PARAM DEFAULT =--
local BPM            = 97
local TOKENS_PER_BEAT= 2
local HOLD_RATIO     = 0.65   -- 0.30 .. 0.90
local START_DELAY    = 3
local MICRO_STAGGER  = 0.004  -- detik, 0..0.03

--= STATE =--
local isPlaying = false
local isPaused  = false
local shouldStop= false
local playThread = nil

--= KEY MAPS =--
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

-- butuh Shift
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

--= INPUT SENDER =--
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

--= PARSER =--
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

--= PLAYER CORE =--
local function playFromSheet(sheet, statusSetter)
    local beatSec = 60 / BPM
    local stepSec = beatSec / math.max(TOKENS_PER_BEAT, 1)
    local holdSec = math.clamp(stepSec * HOLD_RATIO, 0.01, 1.0)
    local gapSec  = math.max(stepSec - holdSec, 0.0001)

    statusSetter(("Mulai dalam %ds ..."):format(START_DELAY))
    task.wait(START_DELAY)

    local tokens = tokenize(sheet)
    local total = #tokens
    local i = 1

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
                if #keyList > 0 then
                    pressChord(keyList, holdSec)
                end
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
end

--= UI BUILDER =--
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Overlay 5s
do
    local overlay = Instance.new("ScreenGui")
    overlay.Name = "PusingbatOverlay"
    overlay.IgnoreGuiInset = true
    overlay.ResetOnSpawn = false
    overlay.Parent = PlayerGui

    local dim = Instance.new("Frame")
    dim.Size = UDim2.fromScale(1,1)
    dim.BackgroundColor3 = Color3.new(0,0,0)
    dim.BackgroundTransparency = 0.5
    dim.BorderSizePixel = 0
    dim.Parent = overlay

    local text = Instance.new("TextLabel")
    text.AnchorPoint = Vector2.new(0.5,0.5)
    text.Position = UDim2.fromScale(0.5,0.5)
    text.Size = UDim2.fromOffset(640,80)
    text.BackgroundTransparency = 1
    text.Text = "Pusingbat Piano Player"
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 42
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.Parent = overlay

    task.delay(5, function() overlay:Destroy() end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "PusingbatPianoUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(420, 510)
frame.Position = UDim2.new(0, 24, 0, 120)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, -16, 0, 28)
header.Position = UDim2.new(0, 8, 0, 8)
header.Font = Enum.Font.GothamBold
header.TextSize = 18
header.TextXAlignment = Enum.TextXAlignment.Left
header.TextColor3 = Color3.fromRGB(255,255,255)
header.Text = "Pusingbat Piano Player"
header.Parent = frame

local drag = Instance.new("TextButton")
drag.BackgroundTransparency = 1
drag.Size = UDim2.new(1, 0, 0, 36)
drag.Position = UDim2.new(0, 0, 0, 0)
drag.Text = ""
drag.Parent = frame

-- draggable
do
    local dragging = false
    local startPos, startInput
    drag.InputBegan:Connect(function(input)
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
    drag.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- helpers
local function button(parent, text, pos, size, callback)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(55, 120, 255)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.AutoButtonColor = true
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

local function slider(parent, labelText, minV, maxV, initial, posY, formatFn, onChange)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 56)
    container.Position = UDim2.new(0, 8, 0, posY)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 16
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(235,235,235)
    local function setLabel(val)
        lbl.Text = string.format("%s: %s", labelText, formatFn and formatFn(val) or tostring(val))
    end
    setLabel(initial)
    lbl.Parent = container

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
    bar.BorderSizePixel = 0
    bar.Parent = container
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)

    local fill = Instance.new("Frame")
    local pct0 = (initial - minV) / (maxV - minV)
    fill.Size = UDim2.new(pct0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 8)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18,18)
    knob.Position = UDim2.new(pct0, -9, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
    knob.BorderSizePixel = 0
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local currentVal = initial
    local dragging = false
    local function setFromPct(pct)
        pct = math.clamp(pct, 0, 1)
        currentVal = minV + (maxV - minV) * pct
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -9, 0.5, -9)
        setLabel(currentVal)
        if onChange then onChange(currentVal) end
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

    return {
        Get = function() return currentVal end,
        Set = function(v)
            local pct = (math.clamp(v, minV, maxV) - minV) / (maxV - minV)
            setFromPct(pct)
        end
    }
end

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 1
statusLabel.Size = UDim2.new(1, -16, 0, 20)
statusLabel.Position = UDim2.new(0, 8, 0, 40)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextColor3 = Color3.fromRGB(180,220,255)
statusLabel.Text = "Status: Idle"
statusLabel.Parent = frame

local function setStatus(txt)
    statusLabel.Text = "Status: " .. txt
end

-- TextBox untuk Sheets
local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -16, 0, 170)
box.Position = UDim2.new(0, 8, 0, 68)
box.BackgroundColor3 = Color3.fromRGB(38,38,38)
box.TextColor3 = Color3.fromRGB(235,235,235)
box.TextSize = 14
box.Font = Enum.Font.Code
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.ClearTextOnFocus = false
box.MultiLine = true
box.PlaceholderText = "Tempel Sheets bracket-mu di sini...\nContoh: [4o] p s g f d ..."
box.Text = ""
box.Parent = frame
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

-- Tombol atas: Load Sample / Clear
button(frame, "Load Sample (blue.)", UDim2.new(0, 8, 0, 246), UDim2.fromOffset(200, 32), function()
    box.Text = table.concat({
        "t r w t r w  t r w t y u",
        "[4o] p s g f d   5 a s d s",
        "[1o] u i o   [6a] s",
        "[4o] p s g f a   5 h g f",
        "[1s] s s d d d   [6f] f f a a a",
        "4 t p o   [5p] o u i   [1o] i u t   [6t]"
    }, "  ")
end)

button(frame, "Clear", UDim2.new(0, 220, 0, 246), UDim2.fromOffset(192, 32), function()
    box.Text = ""
end)

-- Sliders
local y = 286
local bpmSlider = slider(frame, "BPM", 40, 200, BPM, y, function(v) return ("%d"):format(v) end, function(v)
    BPM = math.floor(v + 0.5)
end); y = y + 56

local tpbSlider = slider(frame, "Tokens per Beat", 1, 4, TOKENS_PER_BEAT, y, function(v) return ("%0.1f"):format(v) end, function(v)
    TOKENS_PER_BEAT = math.max(1, math.floor(v + 0.25))  -- bulatkan ke 1..4
    tpbSlider.Set(TOKENS_PER_BEAT)
end); y = y + 56

local hrSlider = slider(frame, "Hold Ratio", 0.30, 0.90, HOLD_RATIO, y, function(v) return ("%d%%"):format(math.floor(v*100+0.5)) end, function(v)
    HOLD_RATIO = math.clamp(v, 0.30, 0.90)
end); y = y + 56

local sdSlider = slider(frame, "Start Delay (s)", 0, 8, START_DELAY, y, function(v) return ("%0.1f s"):format(v) end, function(v)
    START_DELAY = math.max(0, v)
end); y = y + 56

local msSlider = slider(frame, "Micro Stagger", 0.0, 0.03, MICRO_STAGGER, y, function(v) return ("%d ms"):format(math.floor(v*1000+0.5)) end, function(v)
    MICRO_STAGGER = math.clamp(v, 0, 0.03)
end); y = y + 56

-- Tombol Play / Pause / Stop
button(frame, "Play", UDim2.new(0, 8, 0, y), UDim2.fromOffset(120, 36), function()
    if isPlaying then
        setStatus("Sudah Playing...")
        return
    end
    local sheet = box.Text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if sheet == "" then
        setStatus("Sheet kosong!")
        return
    end
    isPlaying = true
    isPaused = false
    shouldStop = false
    setStatus("Starting...")
    playThread = task.spawn(function()
        playFromSheet(sheet, setStatus)
        isPlaying = false
        isPaused = false
        if shouldStop then
            setStatus("Stopped")
        else
            setStatus("Selesai")
        end
    end)
end)

button(frame, "Pause/Resume", UDim2.new(0, 142, 0, y), UDim2.fromOffset(140, 36), function()
    if not isPlaying then
        setStatus("Belum Playing")
        return
    end
    isPaused = not isPaused
    if isPaused then
        setStatus("Paused")
    else
        setStatus("Resumed")
    end
end)

button(frame, "Stop", UDim2.new(0, 298, 0, y), UDim2.fromOffset(114, 36), function()
    if not isPlaying then
        setStatus("Idle")
        return
    end
    shouldStop = true
    isPaused = false
    setStatus("Stopping...")
end)

-- Hint kecil
local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Size = UDim2.new(1, -16, 0, 18)
hint.Position = UDim2.new(0, 8, 0, y + 42)
hint.Font = Enum.Font.Gotham
hint.TextSize = 12
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.TextColor3 = Color3.fromRGB(180,180,180)
hint.Text = "Tips: klik area piano (chat off). Tempo/Timing bisa diatur lewat slider."
hint.Parent = frame
