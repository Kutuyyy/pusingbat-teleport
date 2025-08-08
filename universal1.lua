--[[ 
    Fly + Utility Controller (UI Bawaan) — by pusingbat request
    Fitur:
    - Loading overlay 5 detik (50% transparansi) "Created by Pusingbat"
    - Panel UI:
        * Fly Toggle
        * NoClip Toggle
        * Walk Speed Slider (studs) -> pengaruhi jalan & kecepatan Fly
        * Jump Power Slider (studs)
        * Inf Jump (Mobile) Toggle
        * Inf Jump (PC) Toggle
        * No Fall Damage Toggle
    - Fly: default OFF, ON baru melayang, OFF saat di udara jatuh normal
    - Anti muter saat Fly
    - Inf Jump: bisa melompat berkali-kali tanpa menyentuh tanah
    - No Fall Damage: pulihkan HP jika berkurang saat jatuh
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
	-- WalkSpeed & JumpPower apply
	hum.WalkSpeed = walkSpeed
	-- Gunakan JumpPower (kompatibilitas)
	pcall(function() hum.UseJumpPower = true end)
	hum.JumpPower = jumpPower
	-- Jaga agar JumpHeight juga kira-kira sesuai:
	-- v^2 = 2*g*h  =>  h ≈ (JumpPower^2)/(2*gravity)
	do
		local g = workspace.Gravity
		local h = (jumpPower * jumpPower) / math.max(2*g, 1)
		pcall(function() hum.JumpHeight = h end)
	end
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

	-- Arah horizontal mengikuti kamera (diratakan tanpa Y)
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

	-- Vertical manual (Space naik, Ctrl/Shift turun)
	local vertical = 0
	if UIS:IsKeyDown(Enum.KeyCode.Space) then vertical = 1 end
	if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vertical = -1 end

	-- Kecepatan fly mengikuti walkSpeed (permintaan user)
	local vSpeed = walkSpeed * 0.9 -- vertical sedikit lebih halus
	local velocity = Vector3.new(0, vertical * vSpeed, 0)
	if dir.Magnitude > 0 then
		velocity = velocity + dir.Unit * walkSpeed
	end
	lv.VectorVelocity = velocity

	-- Anti muter
	root.AssemblyAngularVelocity = Vector3.zero
end)

-- ====== Noclip ======
-- Simpel: atur CanCollide semua BasePart di karakter saat noclip aktif
local function setNoclip(state)
	noclip = state and true or false
end

RunService.Stepped:Connect(function()
	if not char or not root then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if noclip then
				part.CanCollide = false
			end
		end
	end
	if not noclip and root then
		-- kembalikan root collide (sisanya biarkan default game)
		root.CanCollide = true
	end
end)

-- ====== Inf Jump ======
-- Gunakan JumpRequest agar lintas device, lalu pisahkan Mobile vs PC via UIS.TouchEnabled
UIS.JumpRequest:Connect(function()
	if not hum then return end
	if UIS.TouchEnabled and infJumpMobile then
		-- Mobile inf jump
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	elseif (not UIS.TouchEnabled) and infJumpPC then
		-- PC inf jump
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Tambahan untuk PC: Space langsung juga
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Space and (not UIS.TouchEnabled) and infJumpPC and hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- ====== No Fall Damage ======
-- Simpel strategi: catat health saat mulai Freefall, pulihkan saat Landed jika berkurang
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
	-- Guard ekstra: kalau ada damage selama freefall
	hum.HealthChanged:Connect(function(h)
		if noFallDamage and lastFreefallT and (tick() - lastFreefallT) < 2.5 then
			if lastFreefallHealth and h < lastFreefallHealth then
				hum.Health = lastFreefallHealth
			end
		else
			-- Update baseline
			lastFreefallHealth = h
		end
	end)
end

-- ====== UI (Bawaan) ======
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
	dim.BackgroundTransparency = 0.5 -- 50%
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

	task.delay(5, function()
		overlay:Destroy()
	end)

	-- Panel utama
	local gui = Instance.new("ScreenGui")
	gui.Name = "PusingbatController"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(320, 320)
	frame.Position = UDim2.new(0, 24, 0, 120)
	frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
	frame.BackgroundTransparency = 0.15
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
	header.Text = "Created by pusingbat"
	header.Parent = frame

	local drag = Instance.new("TextButton")
	drag.BackgroundTransparency = 1
	drag.Size = UDim2.new(1, 0, 0, 36)
	drag.Text = ""
	drag.Parent = frame

	-- Toggle helper switch
	local function createSwitch(parent, labelText, initial, posY, callback)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, -16, 0, 28)
		container.Position = UDim2.new(0, 8, 0, posY)
		container.BackgroundTransparency = 1
		container.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -100, 1, 0)
		lbl.Position = UDim2.new(0, 0, 0, 0)
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 16
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = Color3.fromRGB(235,235,235)
		lbl.Text = labelText
		lbl.Parent = container

		local switch = Instance.new("Frame")
		switch.Size = UDim2.fromOffset(58, 24)
		switch.Position = UDim2.new(1, -70, 0, 2)
		switch.BackgroundColor3 = initial and Color3.fromRGB(60,180,75) or Color3.fromRGB(120,120,120)
		switch.BorderSizePixel = 0
		switch.Parent = container
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
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				value = not value
				redraw()
				if callback then
					task.spawn(callback, value)
				end
			end
		end)

		return {
			Set = function(v)
				value = v and true or false
				redraw()
				if callback then task.spawn(callback, value) end
			end
		}
	end

	local function createSlider(parent, labelText, minV, maxV, initial, posY, callback)
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, -16, 0, 46)
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
		lbl.Text = string.format("%s: %d", labelText, initial)
		lbl.Parent = container

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, 0, 0, 8)
		bar.Position = UDim2.new(0, 0, 0, 28)
		bar.BackgroundColor3 = Color3.fromRGB(60,60,60)
		bar.BorderSizePixel = 0
		bar.Parent = container
		Instance.new("UICorner", bar).CornerRadius = UDim.new(0,8)

		local fill = Instance.new("Frame")
		local pct0 = (initial - minV) / (maxV - minV)
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

		return {
			Set = function(v)
				local pct = (math.clamp(v, minV, maxV) - minV) / (maxV - minV)
				setFromPct(pct)
			end
		}
	end

	-- Controls layout
	local y = 44
	local row = 34

	local flySwitch = createSwitch(frame, "Fly", false, y, function(v) setFly(v) end); y = y + row
	local noclipSwitch = createSwitch(frame, "NoClip (tembus)", false, y, function(v) setNoclip(v) end); y = y + row
	local wsSlider = createSlider(frame, "Walk Speed (studs)", MIN_WALK, MAX_WALK, walkSpeed, y, function(v)
		walkSpeed = v
		ensurePhysics() -- jalan + fly speed ikut berubah
	end); y = y + 52
	local jpSlider = createSlider(frame, "Jump Power (studs)", MIN_JUMP, MAX_JUMP, jumpPower, y, function(v)
		jumpPower = v
		ensurePhysics()
	end); y = y + 52
	local infMobSwitch = createSwitch(frame, "Inf Jump (Mobile)", false, y, function(v) infJumpMobile = v end); y = y + row
	local infPCSwitch = createSwitch(frame, "Inf Jump (PC)", false, y, function(v) infJumpPC = v end); y = y + row
	local nfdSwitch = createSwitch(frame, "No Fall Damage", false, y, function(v) noFallDamage = v end); y = y + row

	-- Drag Window
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

-- Fallback keybind toggle Fly kalau kamu mau (optional)
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
