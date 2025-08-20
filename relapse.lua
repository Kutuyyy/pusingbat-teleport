--[[
    Pusingbat Piano Player — UI rapi + Draggable + Scrollable + Movement Lock (PlayerGui)
    - Panel: Play / Pause / Stop, Load Sample, Clear
    - TextBox multi-line untuk Sheets ([pwdj] p ...)
    - Slider: BPM, Tokens/Beat, Hold Ratio, Start Delay, Micro Stagger
    - Status label, Minimize, Drag via header, Konten scrollable
    - Saat Play: kunci kontrol gerak; Stop/Selesai: lepas lagi
]]

--=== Services ===--
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local VIM          = game:GetService("VirtualInputManager")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer

--=== Param Default ===--
local BPM             = 97
local TOKENS_PER_BEAT = 2
local HOLD_RATIO      = 0.65
local START_DELAY     = 3
local MICRO_STAGGER   = 0.004

--=== State ===--
local isPlaying, isPaused, shouldStop = false, false, false

--=== Key Maps ===--
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

--=== Movement Lock ===--
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

LocalPlayer.CharacterAdded:Connect(function()
    if isPlaying then task.defer(function() setMovementLock(true) end) end
end)

game:BindToClose(function()
    setMovementLock(false)
end)

--=== Input Sender ===--
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

--=== Parser ===--
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

--=== Player Core ===--
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

    if shouldStop then statusSetter("Stopped") else statusSetter("Selesai") end
end

--=== UI (berdasarkan gaya patokanmu) ===--
local function createUI()
    -- Overlay 5 detik (sesuai contoh)
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

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

    local text = Instance.new("TextLabel")
    text.AnchorPoint = Vector2.new(0.5,0.5)
    text.Position = UDim2.fromScale(0.5,0.5)
    text.Size = UDim2.fromOffset(600, 80)
    text.BackgroundTransparency = 1
    text.Text = "Created by Pusingbat"
    text.Font = Enum.Font.GothamBlack
    text.TextSize = 42
    text.TextColor3 = Color3.fromRGB(255,255,255)
    text.Parent = overlay

    task.delay(5, function() overlay:Destroy() end)

    -- Panel utama
    local gui = Instance.new("ScreenGui")
    gui.Name = "PusingbatPiano"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999999
    gui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(360, 540)       -- lebih tinggi biar muat scroll
    frame.Position = UDim2.new(0, 24, 0, 120)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    -- Header + drag area
    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, -50, 0, 30)
    header.Position = UDim2.new(0, 12, 0, 8)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 18
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.TextColor3 = Color3.fromRGB(255,255,255)
    header.Text = "Pusingbat Piano Player"
    header.Parent = frame

    local mini = Instance.new("TextButton")
    mini.Size = UDim2.fromOffset(28, 24)
    mini.Position = UDim2.new(1, -36, 0, 8)
    mini.BackgroundColor3 = Color3.fromRGB(55,120,255)
    mini.TextColor3 = Color3.new(1,1,1)
    mini.TextSize = 16
    mini.Font = Enum.Font.GothamBold
    mini.Text = "-"
    mini.Parent = frame
    Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 6)

    local drag = Instance.new("TextButton")
    drag.BackgroundTransparency = 1
    drag.Size = UDim2.new(1, 0, 0, 40)
    drag.Text = ""
    drag.Parent = frame

    -- Draggable
    do
        local draggingFrame, dragStart, startPos
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
    end

    -- Kontainer scrollable
    local body = Instance.new("ScrollingFrame")
    body.Name = "Body"
    body.Size = UDim2.new(1, -16, 1, -56)  -- sisakan header + padding
    body.Position = UDim2.new(0, 8, 0, 48)
    body.BackgroundTransparency = 1
    body.ScrollBarThickness = UIS.TouchEnabled and 10 or 6
    body.ScrollingDirection = Enum.ScrollingDirection.Y
    body.AutomaticCanvasSize = Enum.AutomaticSize.Y
    body.CanvasSize = UDim2.new()
    body.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0,8)
    padding.PaddingBottom = UDim.new(0,8)
    padding.PaddingLeft = UDim.new(0,6)
    padding.PaddingRight = UDim.new(0,6)
    padding.Parent = body

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list.Parent = body

    -- Helper section
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
    local function label(parent, text, size)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Size = UDim2.new(1, -16, 0, 22)
        l.Position = UDim2.new(0, 12, 0, 6)
        l.Font = Enum.Font.Gotham
        l.TextSize = size or 14
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextColor3 = Color3.fromRGB(220,220,220)
        l.Text = text
        l.Parent = parent
        return l
    end

    -- Status
    local statusSec = section(56)
    local statusLabel = label(statusSec, "Status: Idle", 14)
    statusLabel.Position = UDim2.new(0,12,0,10)
    statusLabel.TextColor3 = Color3.fromRGB(180,220,255)
    local function setStatus(txt) statusLabel.Text = "Status: "..txt end

    -- Sheets
    local sheetSec = section(200)
    label(sheetSec, "Sheets (format bracket)", 14)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -24, 1, -50)
    box.Position = UDim2.new(0, 12, 0, 36)
    box.BackgroundColor3 = Color3.fromRGB(38,38,38)
    box.TextColor3 = Color3.fromRGB(235,235,235)
    box.TextSize = 14
    box.Font = Enum.Font.Code
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.ClearTextOnFocus = false
    box.MultiLine = true
    box.TextWrapped = true
    box.PlaceholderText = "Tempel Sheets di sini...\nContoh: [4o] p s g f d ..."
    box.Parent = sheetSec
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

    -- Preset buttons (horizontal, scale)
    local btnRow = section(80)
    label(btnRow, "Preset", 14)

    local wrap1 = Instance.new("Frame")
    wrap1.Size = UDim2.new(1, -24, 0, 36)
    wrap1.Position = UDim2.new(0, 12, 0, 36)
    wrap1.BackgroundTransparency = 1
    wrap1.Parent = btnRow

    local hlist1 = Instance.new("UIListLayout")
    hlist1.FillDirection = Enum.FillDirection.Horizontal
    hlist1.SortOrder = Enum.SortOrder.LayoutOrder
    hlist1.Padding = UDim.new(0, 8)
    hlist1.VerticalAlignment = Enum.VerticalAlignment.Center
    hlist1.Parent = wrap1

    local function mkBtn(parent, t, col)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.5, -4, 1, 0)
        b.BackgroundColor3 = col
        b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 16
        b.Font = Enum.Font.GothamBold
        b.Text = t
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        return b
    end

    local sampleBtn = mkBtn(wrap1, "Load Sample (blue.)", Color3.fromRGB(55,120,255))
    local clearBtn  = mkBtn(wrap1, "Clear", Color3.fromRGB(80,80,80))

    sampleBtn.MouseButton1Click:Connect(function()
        box.Text = table.concat({
            "t r w t r w  t r w t y u",
            "[4o] p s g f d   5 a s d s",
            "[1o] u i o   [6a] s",
            "[4o] p s g f a   5 h g f",
            "[1s] s s d d d   [6f] f f a a a",
            "4 t p o   [5p] o u i   [1o] i u t   [6t]"
        }, "  ")
    end)
    clearBtn.MouseButton1Click:Connect(function() box.Text = "" end)

    -- Transport (Play/Pause/Stop)
    local ctlSec = section(96)
    label(ctlSec, "Transport", 14)

    local wrap2 = Instance.new("Frame")
    wrap2.Size = UDim2.new(1, -24, 0, 36)
    wrap2.Position = UDim2.new(0, 12, 0, 36)
    wrap2.BackgroundTransparency = 1
    wrap2.Parent = ctlSec

    local hlist2 = Instance.new("UIListLayout")
    hlist2.FillDirection = Enum.FillDirection.Horizontal
    hlist2.SortOrder = Enum.SortOrder.LayoutOrder
    hlist2.Padding = UDim.new(0, 8)
    hlist2.VerticalAlignment = Enum.VerticalAlignment.Center
    hlist2.Parent = wrap2

    local function mkTransport(text)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1/3, -6, 1, 0)
        b.BackgroundColor3 = Color3.fromRGB(55,120,255)
        b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 16
        b.Font = Enum.Font.GothamBold
        b.Text = text
        b.Parent = wrap2
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        return b
    end

    local playBtn  = mkTransport("Play")
    local pauseBtn = mkTransport("Pause/Resume")
    local stopBtn  = mkTransport("Stop")

    -- Sliders
    local function sliderRow(titleText, minV, maxV, initial, onChange, formatter)
        local s = section(74)
        local lbl = label(s, titleText .. ": " .. (formatter and formatter(initial) or tostring(initial)), 14)

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -24, 0, 10)
        bar.Position = UDim2.new(0, 12, 0, 40)
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
        knob.Size = UDim2.fromOffset(18,18)
        knob.Position = UDim2.new(pct0, -9, 0.5, -9)
        knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
        knob.BorderSizePixel = 0
        knob.Parent = bar
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local dragging, val = false, initial
        local function setFromPct(p)
            p = math.clamp(p, 0, 1)
            val = minV + (maxV - minV) * p
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, -9, 0.5, -9)
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

        return {
            Set = function(v)
                local p = (math.clamp(v, minV, maxV) - minV) / (maxV - minV)
                setFromPct(p)
            end
        }
    end

    sliderRow("BPM", 40, 200, BPM, function(v) BPM = math.floor(v + 0.5) end,
        function(v) return ("%d"):format(v) end)

    local tpbRow
    tpbRow = sliderRow("Tokens per Beat", 1, 4, TOKENS_PER_BEAT, function(v)
        TOKENS_PER_BEAT = math.max(1, math.floor(v + 0.25))
        if tpbRow and tpbRow.Set then tpbRow.Set(TOKENS_PER_BEAT) end
    end, function(v) return ("%0.1f"):format(v) end)

    sliderRow("Hold Ratio", 0.30, 0.90, HOLD_RATIO, function(v)
        HOLD_RATIO = math.clamp(v, 0.30, 0.90)
    end, function(v) return ("%d%%"):format(math.floor(v*100+0.5)) end)

    sliderRow("Start Delay (s)", 0, 8, START_DELAY, function(v)
        START_DELAY = math.max(0, v)
    end, function(v) return ("%0.1f s"):format(v) end)

    sliderRow("Micro Stagger", 0.0, 0.03, MICRO_STAGGER, function(v)
        MICRO_STAGGER = math.clamp(v, 0, 0.03)
    end, function(v) return ("%d ms"):format(math.floor(v*1000+0.5)) end)

    -- Transport callbacks
    playBtn.MouseButton1Click:Connect(function()
        if isPlaying then setStatus("Sudah Playing..."); return end
        local sheet = box.Text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        if sheet == "" then setStatus("Sheet kosong!"); return end
        isPlaying, isPaused, shouldStop = true, false, false
        setMovementLock(true)     -- kunci gerak
        setStatus("Starting...")
        task.spawn(function()
            playFromSheet(sheet, setStatus)
            isPlaying, isPaused = false, false
            setMovementLock(false) -- lepas kunci saat selesai
        end)
    end)

    pauseBtn.MouseButton1Click:Connect(function()
        if not isPlaying then setStatus("Belum Playing"); return end
        isPaused = not isPaused
        setStatus(isPaused and "Paused" or "Resumed")
    end)

    stopBtn.MouseButton1Click:Connect(function()
        if not isPlaying then setStatus("Idle"); return end
        shouldStop, isPaused = true, false
        setMovementLock(false)    -- guard
        setStatus("Stopping...")
    end)

    -- Minimize
    local minimized = false
    mini.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            body.Visible = false
            frame.Size = UDim2.fromOffset(frame.Size.X.Offset, 56)
            mini.Text = "+"
        else
            body.Visible = true
            frame.Size = UDim2.fromOffset(360, 540)
            mini.Text = "-"
        end
    end)
end

--=== Init ===--
createUI()
