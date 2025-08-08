--[[ 
    Fly + Utility Controller (UI Bawaan) — by pusingbat request
    Fitur:
      • Loading overlay 5 detik (50% transparansi) "Created by Pusingbat" + panel teks ber-background 50%
      • Panel UI dengan header "Created by pusingbat" + tombol Search / Minimize / Close
      • Search memfilter fitur (nama mengandung teks)
      • Close: sembunyikan panel, munculkan tombol pill "Show Pusing"
      • Minimize: tampilkan header saja (klik lagi untuk restore)
      • ScrollingFrame untuk konten (panel tidak terlalu besar)
      • Fly Toggle (default OFF)
      • NoClip Toggle
      • Walk Speed Slider (studs) — pengaruhi jalan & kecepatan fly
      • Jump Power Slider (studs)
      • Inf Jump (Mobile) Toggle
      • Inf Jump (PC) Toggle
      • No Fall Damage Toggle
    Letakkan sebagai LocalScript di StarterPlayer > StarterPlayerScripts
]]--

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ====== State ======
local MIN_WALK, MAX_WALK = 8, 200     -- WalkSpeed range
local MIN_JUMP, MAX_JUMP = 25, 300    -- JumpPower range
local walkSpeed = 16
local jumpPower = 50

local fly = false
local noclip = false
local infJumpMobile = false
local infJumpPC = false
local noFallDamage = false

local char, root, hum
local lv       -- LinearVelocity (movement saat fly)
local align    -- AlignOrientation (lock rotation)
local lastFreefallHealth
local fellFromY
local lastFreefallT

-- ====== Character helpers ======
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
	-- Sesuaikan JumpHeight agar kira-kira konsisten
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

-- ====== Fly logic ======
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

-- Per-frame fly movement
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

	-- Speed fly mengikuti WalkSpeed
	local vSpeed = walkSpeed * 0.9
	local velocity = Vector3.new(0, vertical * vSpeed, 0)
	if dir.Magnitude > 0 then
		velocity = velocity + dir.Unit * walkSpeed
	end
	lv.VectorVelocity = velocity
	root.AssemblyAngularVelocity = Vector3.zero
end)

-- ====== Noclip ======
local function setNoclip(state)
	noclip = state and true or false
end

RunService.Stepped:Connect(function()
	if not char or not root then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if noclip then part.CanCollide = false end
		end
	end
	if not noclip and root then root.CanCollide = true end
end)

-- ====== Inf Jump ======
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

-- ====== No Fall Damage ======
local function hookFallDamage()
	if not hum then return end
	hum.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Freefall then
			lastFreefallHealth = hum.Health
			fellFromY = root and root.Position.Y or nil
			lastFreefallT = tick()
		elseif new == Enum.HumanoidStateType.Landed then
			if noFallDamage and lastFreefallHealth then
				if hum.Health < lastFreefallHealth then
					hum.Health = math.max(hum.Health, lastFreefallHealth)
				end
			end
		end
	end)
	hum.HealthChanged:Connect(function(h)
		if noFallDamage and lastFreefallT and (tick() - lastFreefallT) < 2.5 then
			if lastFreefallHealth and h < lastFreefallHealth then
				hum.Health = lastFreefallHealth
			end
		else
			lastFreefallHealth = h
		end
	end)
end

-- ====== UI (Bawaan) ======
local MainGUI -- reference panel
local ShowPillGUI -- reference pill button

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
	dim.BackgroundTransparency = 0.5 -- 50% background
	dim.BorderSizePixel = 0
	dim.Parent = overlay

	local textBg = Instance.new("Frame")
	textBg.AnchorPoint = Vector2.new(0.5,0.5)
	textBg.Position = UDim2.fromScale(0.5,0.5)
	textBg.Size = UDim2.fromOffset(520,100)
	textBg.BackgroundColor3 = Color3.fromRGB(0,0,0)
	textBg.BackgroundTransparency = 0.5 -- 50% panel bg
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

	task.delay(5, function()
		overlay:Destroy()
	end)

	-- Panel utama
	if MainGUI then MainGUI:Destroy() end
	MainGUI = Instance.new("ScreenGui")
	MainGUI.Name = "PusingbatController"
	MainGUI.ResetOnSpawn = false
	MainGUI.IgnoreGuiInset = true
	MainGUI.Parent = PlayerGui

	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.fromOffset(360, 360)
	frame.Position = UDim2.new(0, 24, 0, 120)
	frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Parent = MainGUI
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

	-- Header bar
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundTransparency = 1
	header.Parent = frame

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -160, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(255,255,255)
	title.Text = "Created by pusingbat"
	title.Parent = header

	-- Header controls (Search icon / Minimize / Close)
    local searchBtn = Instance.new("ImageButton")
    searchBtn.Size = UDim2.fromOffset(26, 26)
    searchBtn.Position = UDim2.new(1, -96, 0.5, -13)
    searchBtn.BackgroundTransparency = 1
    searchBtn.BorderSizePixel = 0
    searchBtn.ZIndex = 3
    -- Gambar kaca pembesar (ganti ID kalau tidak muncul)
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
    btnMin.ZIndex = 3
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
    btnClose.ZIndex = 3
    btnClose.Parent = header
    Instance.new("UICorner", btnClose).CornerRadius = UDim.new(1,0)

    -- Search panel (muncul saat klik icon)
    local searchPanel = Instance.new("Frame")
    searchPanel.Size = UDim2.fromOffset(180, 36)
    searchPanel.Position = UDim2.new(1, -286, 0, 42)
    searchPanel.BackgroundColor3 = Color3.fromRGB(45,45,50)
    searchPanel.Visible = false
    searchPanel.Parent = frame
    searchPanel.ZIndex = 4
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
    searchBox.ZIndex = 5
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

    searchBtn.MouseButton1Click:Connect(function()
        searchPanel.Visible = not searchPanel.Visible
        if searchPanel.Visible then searchBox:CaptureFocus() end
    end)

    -- Drag area (hanya sisi kiri, supaya tombol bisa diklik)
    local drag = Instance.new("Frame")
    drag.BackgroundTransparency = 1
    drag.Size = UDim2.new(1, -180, 1, 0)
    drag.Position = UDim2.new(0, 0, 0, 0)
    drag.Parent = header

	-- Scrolling content
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Content"
	scroll.Size = UDim2.new(1, -16, 1, -56)
	scroll.Position = UDim2.new(0, 8, 0, 48)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.new(0,0,0,0)
	scroll.ScrollBarThickness = 6
	scroll.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll

	local function recalcCanvas()
		scroll.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(recalcCanvas)

	-- Builder helpers
	local allRows = {}

	local function createRow(height)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, height)
		row.BackgroundColor3 = Color3.fromRGB(38,38,42)
		row.BackgroundTransparency = 0.2
		row.BorderSizePixel = 0
		row.Parent = scroll
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
		allRows[#allRows+1] = row
		return row
	end

	local function createSwitch(labelText, initial, callback)
		local row = createRow(40)
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
			knob:TweenPosition(value and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10),
				Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
		end
		switch.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				value = not value
				redraw()
				if callback then task.spawn(callback, value) end
			end
		end)

		row:SetAttribute("label", labelText)
		row:SetAttribute("type", "switch")

		return {
			Set = function(v)
				value = v and true or false
				redraw()
				if callback then task.spawn(callback, value) end
			end,
			Row = row
		}
	end

	local function createSlider(labelText, minV, maxV, initial, callback)
		local row = createRow(58)
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
		row:SetAttribute("type", "slider")

		return {
			Set = function(v)
				local pct = (math.clamp(v, minV, maxV) - minV) / (maxV - minV)
				setFromPct(pct)
			end,
			Row = row
		}
	end

	-- Build controls
	local flySw = createSwitch("Fly", false, function(v) setFly(v) end)
	local ncSw = createSwitch("NoClip (tembus)", false, function(v) setNoclip(v) end)
	local wsSl = createSlider("Walk Speed (studs)", MIN_WALK, MAX_WALK, walkSpeed, function(v) walkSpeed = v; ensurePhysics() end)
	local jpSl = createSlider("Jump Power (studs)", MIN_JUMP, MAX_JUMP, jumpPower, function(v) jumpPower = v; ensurePhysics() end)
	local ijmSw = createSwitch("Inf Jump (Mobile)", false, function(v) infJumpMobile = v end)
	local ijpSw = createSwitch("Inf Jump (PC)", false, function(v) infJumpPC = v end)
	local nfdSw = createSwitch("No Fall Damage", false, function(v) noFallDamage = v end)

	-- Search filter
    local function applySearch()
        local q = string.lower(searchBox.Text or "")
        for _,row in ipairs(allRows) do
            local label = string.lower(tostring(row:GetAttribute("label") or ""))
            row.Visible = (q == "") or (string.find(label, q, 1, true) ~= nil)
        end
        recalcCanvas()
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)


    -- Minimize / Close
    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        scroll.Visible = not minimized
        frame.Size = minimized and UDim2.fromOffset(360, 56) or UDim2.fromOffset(360, 360)
    end)

    btnClose.MouseButton1Click:Connect(function()
        MainGUI.Enabled = false
        showPill()
    end)

	-- Drag window
	local draggingFrame = false
	local dragStart
	local startPos
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

-- ====== Init ======
getCharacter()
attachFly()
ensurePhysics()
hookFallDamage()

-- Rehook on respawn
LocalPlayer.CharacterAdded:Connect(function()
	getCharacter()
	attachFly()
	ensurePhysics()
	hookFallDamage()
	fly = false
	noclip = false
end)

-- Optional keybind (F) toggle Fly
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
