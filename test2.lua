-- LocalScript: Network Logger Window (draggable + resizable + tabs)
-- Tempel di StarterPlayer > StarterPlayerScripts

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

----------------------------------------------------------------
-- Data state
----------------------------------------------------------------
local HB = 0
local HookedCount = 0
local EventsCount = 0
local HookedSet = {}          -- [RemoteEvent] = true
local HookedList = {}         -- array of RemoteEvent (for UI)
local EventLog = {}           -- array of {t=timestamp, remote=Instance, summary=string, full=string}
local MAX_EVENTS = 200
local ActiveFilter -- Instance remote yang difilter (nil = semua)
local ActiveTab = "Overview"

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
local function safeFullName(inst)
	local ok, res = pcall(function() return inst:GetFullName() end)
	return ok and res or (inst.ClassName .. " " .. (inst.Name or "?"))
end

local function short(s, n)
	n = n or 120
	s = tostring(s)
	if #s > n then return s:sub(1, n-3) .. "..." end
	return s
end

local function dumpVal(v, depth)
	depth = depth or 0
	if depth > 1 then return "{...}" end
	local t = typeof(v)
	if t == "string" then
		return '"' .. s tostring(v) .. '"' -- dummy to avoid gsub later (we'll just short())
	end
	return nil
end

local function dumpAny(v, depth)
	depth = depth or 0
	local t = typeof(v)
	if t == "string" then
		return '"' .. v .. '"'
	elseif t == "number" or t == "boolean" then
		return tostring(v)
	elseif t == "Instance" then
		return "<" .. safeFullName(v) .. ">"
	elseif t == "table" then
		local parts, count = {}, 0
		for k,val in pairs(v) do
			count += 1
			if count > 6 then table.insert(parts, "..."); break end
			local keyStr = (type(k)=="string") and k or ("["..tostring(k).."]")
			table.insert(parts, keyStr .. "=" .. dumpAny(val, depth+1))
		end
		return "{" .. table.concat(parts, ", ") .. "}"
	else
		return "<"..t..">"
	end
end

local function summarizeArgs(args)
	local parts = {}
	for i,a in ipairs(args) do
		parts[i] = "arg"..i.."="..short(dumpAny(a), 140)
	end
	return table.concat(parts, " | ")
end

local function fullDump(args)
	local parts = {}
	for i,a in ipairs(args) do
		parts[i] = "arg"..i.." = " .. dumpAny(a, 0)
	end
	return table.concat(parts, "\n")
end

local function addEvent(remote, args)
	EventsCount += 1
	local entry = {
		t = os.time(),
		remote = remote,
		summary = summarizeArgs(args),
		full = fullDump(args)
	}
	table.insert(EventLog, 1, entry)
	if #EventLog > MAX_EVENTS then table.remove(EventLog) end
end

----------------------------------------------------------------
-- UI: Window
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "NetworkLoggerUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local window = Instance.new("Frame")
window.Name = "Window"
window.Size = UDim2.fromOffset(520, 340)
window.Position = UDim2.fromOffset(24, 24)
window.BackgroundColor3 = Color3.fromRGB(22,22,22)
window.BackgroundTransparency = 0.1
window.BorderSizePixel = 0
window.Parent = gui

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(70,70,70)
stroke.Parent = window

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,6)
corner.Parent = window

-- Title bar
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -90, 0, 30)
title.Position = UDim2.fromOffset(10, 6)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansSemibold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(235,235,235)
title.Text = "Network Logger"
title.Parent = window

local btnMin = Instance.new("TextButton")
btnMin.Name = "BtnMin"
btnMin.Size = UDim2.fromOffset(30, 24)
btnMin.Position = UDim2.new(1, -76, 0, 6)
btnMin.Text = "-"
btnMin.Font = Enum.Font.SourceSansBold
btnMin.TextSize = 20
btnMin.BackgroundColor3 = Color3.fromRGB(40,40,40)
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.Parent = window

local btnClose = Instance.new("TextButton")
btnClose.Name = "BtnClose"
btnClose.Size = UDim2.fromOffset(30, 24)
btnClose.Position = UDim2.new(1, -40, 0, 6)
btnClose.Text = "×"
btnClose.Font = Enum.Font.SourceSansBold
btnClose.TextSize = 20
btnClose.BackgroundColor3 = Color3.fromRGB(40,40,40)
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.Parent = window

-- Dragging
do
	local dragging = false
	local dragStart, startPos
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = window.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			window.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Resize grip (bottom-right)
local grip = Instance.new("Frame")
grip.Name = "Grip"
grip.Size = UDim2.fromOffset(16, 16)
grip.AnchorPoint = Vector2.new(1,1)
grip.Position = UDim2.new(1, -4, 1, -4)
grip.BackgroundColor3 = Color3.fromRGB(70,70,70)
grip.BorderSizePixel = 0
grip.Parent = window

local gripCorner = Instance.new("UICorner")
gripCorner.CornerRadius = UDim.new(0,3)
gripCorner.Parent = grip

do
	local resizing = false
	local startSize, startPos, startMouse
	grip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			startSize = window.Size
			startPos = window.Position
			startMouse = input.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then resizing = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - startMouse
			local w = math.max(360, startSize.X.Offset + delta.X)
			local h = math.max(220, startSize.Y.Offset + delta.Y)
			window.Size = UDim2.fromOffset(w, h)
		end
	end)
end

-- Content area
local content = Instance.new("Frame")
content.Name = "Content"
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.fromOffset(10, 40)
content.Parent = window

-- Tabs
local tabs = Instance.new("Frame")
tabs.Name = "Tabs"
tabs.Size = UDim2.new(1, 0, 0, 28)
tabs.BackgroundTransparency = 1
tabs.Parent = content

local function makeTabButton(text, xIndex)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 100, 1, 0)
	b.Position = UDim2.fromOffset((xIndex-1)*106, 0)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 16
	b.Parent = tabs
	return b
end

local btnTabOverview = makeTabButton("Overview", 1)
local btnTabRemotes  = makeTabButton("Remotes",  2)
local btnTabEvents   = makeTabButton("Events",   3)

local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1, 0, 1, -34)
body.Position = UDim2.fromOffset(0, 34)
body.BackgroundTransparency = 1
body.Parent = content

-- Panels
local panelOverview = Instance.new("Frame")
panelOverview.BackgroundTransparency = 1
panelOverview.Size = UDim2.fromScale(1,1)
panelOverview.Parent = body

local panelRemotes = Instance.new("Frame")
panelRemotes.BackgroundTransparency = 1
panelRemotes.Size = UDim2.fromScale(1,1)
panelRemotes.Visible = false
panelRemotes.Parent = body

local panelEvents = Instance.new("Frame")
panelEvents.BackgroundTransparency = 1
panelEvents.Size = UDim2.fromScale(1,1)
panelEvents.Visible = false
panelEvents.Parent = body

-- Overview contents
local ovText = Instance.new("TextLabel")
ovText.BackgroundTransparency = 1
ovText.TextXAlignment = Enum.TextXAlignment.Left
ovText.TextYAlignment = Enum.TextYAlignment.Top
ovText.Font = Enum.Font.SourceSans
ovText.TextSize = 18
ovText.TextColor3 = Color3.new(1,1,1)
ovText.Size = UDim2.fromScale(1,1)
ovText.Parent = panelOverview

-- Remotes list
local remScroll = Instance.new("ScrollingFrame")
remScroll.Size = UDim2.new(1, 0, 1, -28)
remScroll.CanvasSize = UDim2.new()
remScroll.ScrollBarThickness = 6
remScroll.BackgroundTransparency = 1
remScroll.Parent = panelRemotes

local remList = Instance.new("UIListLayout")
remList.Padding = UDim.new(0,4)
remList.Parent = remScroll

local remFilter = Instance.new("TextLabel")
remFilter.Size = UDim2.new(1, 0, 0, 24)
remFilter.Position = UDim2.new(0,0,1,-24)
remFilter.BackgroundTransparency = 1
remFilter.Font = Enum.Font.SourceSans
remFilter.TextSize = 16
remFilter.TextXAlignment = Enum.TextXAlignment.Left
remFilter.TextColor3 = Color3.new(1,1,1)
remFilter.Text = "Filter: All"
remFilter.Parent = panelRemotes

-- Events list + details
local evTop = Instance.new("Frame")
evTop.Size = UDim2.new(1, 0, 0.55, -2)
evTop.BackgroundTransparency = 1
evTop.Parent = panelEvents

local evScroll = Instance.new("ScrollingFrame")
evScroll.Size = UDim2.new(1, 0, 1, 0)
evScroll.CanvasSize = UDim2.new()
evScroll.ScrollBarThickness = 6
evScroll.BackgroundTransparency = 1
evScroll.Parent = evTop

local evList = Instance.new("UIListLayout")
evList.Padding = UDim.new(0,4)
evList.Parent = evScroll

local evDetail = Instance.new("ScrollingFrame")
evDetail.Size = UDim2.new(1, 0, 0.45, -6)
evDetail.Position = UDim2.new(0, 0, 0.55, 6)
evDetail.ScrollBarThickness = 6
evDetail.BackgroundTransparency = 0.05
evDetail.Parent = panelEvents

local evDetailText = Instance.new("TextLabel")
evDetailText.Size = UDim2.new(1, -10, 0, 0)
evDetailText.Position = UDim2.fromOffset(5,5)
evDetailText.BackgroundTransparency = 1
evDetailText.Font = Enum.Font.Code
evDetailText.TextSize = 15
evDetailText.TextXAlignment = Enum.TextXAlignment.Left
evDetailText.TextYAlignment = Enum.TextYAlignment.Top
evDetailText.TextWrapped = true
evDetailText.AutomaticSize = Enum.AutomaticSize.Y
evDetailText.TextColor3 = Color3.new(1,1,1)
evDetailText.Text = "-- select an event --"
evDetailText.Parent = evDetail

----------------------------------------------------------------
-- UI rendering
----------------------------------------------------------------
local function switchTab(name)
	ActiveTab = name
	panelOverview.Visible = (name=="Overview")
	panelRemotes.Visible  = (name=="Remotes")
	panelEvents.Visible   = (name=="Events")
end
btnTabOverview.MouseButton1Click:Connect(function() switchTab("Overview") end)
btnTabRemotes.MouseButton1Click:Connect(function() switchTab("Remotes") end)
btnTabEvents.MouseButton1Click:Connect(function() switchTab("Events") end)

btnMin.MouseButton1Click:Connect(function()
	body.Visible = not body.Visible
end)
btnClose.MouseButton1Click:Connect(function()
	gui.Enabled = false
end)

local function renderOverview()
	local lastRemote = (#HookedList > 0) and safeFullName(HookedList[1]) or "-"
	ovText.Text = string.format(
		"Heartbeat: %d\nHooked Remotes: %d\nEvents: %d\nFilter: %s\n\nTips:\n- Tab 'Remotes' untuk pilih filter\n- Tab 'Events' untuk lihat payload & klik baris untuk detail",
		HB, HookedCount, EventsCount, ActiveFilter and safeFullName(ActiveFilter) or "All"
	)
end

local function makeRow(text, click)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -8, 0, 28)
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	b.TextXAlignment = Enum.TextXAlignment.Left
	b.Font = Enum.Font.SourceSans
	b.TextSize = 16
	b.Text = text
	b.AutoButtonColor = true
	b.MouseButton1Click:Connect(click)
	local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0,4)
	return b
end

local function renderRemotes()
	for _,child in ipairs(remScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for i, re in ipairs(HookedList) do
		local row = makeRow(short(safeFullName(re), 90), function()
			ActiveFilter = re
			remFilter.Text = "Filter: "..short(safeFullName(re), 120)
			switchTab("Events")
		end)
		row.Parent = remScroll
	end
	remScroll.CanvasSize = UDim2.new(0,0,0, remList.AbsoluteContentSize.Y + 6)
	remFilter.Text = "Filter: ".. (ActiveFilter and short(safeFullName(ActiveFilter), 120) or "All")
end

local function renderEvents()
	for _,child in ipairs(evScroll:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for i, ev in ipairs(EventLog) do
		if not ActiveFilter or ev.remote == ActiveFilter then
			local rowText = os.date("%H:%M:%S", ev.t) .. " | " .. short(safeFullName(ev.remote), 60) .. " | " .. short(ev.summary, 140)
			local row = makeRow(rowText, function()
				evDetailText.Text = ("Time: %s\nRemote: %s\n\n%s"):format(
					os.date("%c", ev.t), safeFullName(ev.remote), ev.full
				)
				evDetail.CanvasSize = UDim2.new(0,0,0, evDetailText.AbsoluteSize.Y + 10)
			end)
			row.Parent = evScroll
		end
	end
	evScroll.CanvasSize = UDim2.new(0,0,0, evList.AbsoluteContentSize.Y + 6)
end

local function renderAll()
	renderOverview()
	renderRemotes()
	renderEvents()
end

-- periodic UI update (HB)
task.spawn(function()
	while gui.Parent do
		HB += 1
		if ActiveTab=="Overview" then renderOverview() end
		task.wait(1)
	end
end)

----------------------------------------------------------------
-- Hooking remotes (ReplicatedStorage)
----------------------------------------------------------------
local function hookRemote(re)
	if not re:IsA("RemoteEvent") then return end
	if HookedSet[re] then return end
	HookedSet[re] = true
	table.insert(HookedList, 1, re)
	HookedCount += 1
	if ActiveTab=="Remotes" then renderRemotes() end

	re.OnClientEvent:Connect(function(...)
		addEvent(re, {...})
		if ActiveTab=="Events" then renderEvents() end
		if ActiveTab=="Overview" then renderOverview() end
	end)
end

for _, obj in ipairs(RS:GetDescendants()) do
	if obj:IsA("RemoteEvent") then hookRemote(obj) end
end
RS.DescendantAdded:Connect(function(obj)
	if obj:IsA("RemoteEvent") then hookRemote(obj) end
end)

renderAll()
