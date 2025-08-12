-- LocalScript: Hook "Notif" Remote + UI debug (gunakan template UI-mu)
-- Taruh di StarterPlayer > StarterPlayerScripts

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- ==== UI (template kamu) ====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugStatsUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local label = Instance.new("TextLabel")
label.Name = "DebugLabel"
label.Size = UDim2.fromScale(0.45, 0.135)
label.Position = UDim2.fromOffset(10, 10)
label.BackgroundTransparency = 0.2
label.BackgroundColor3 = Color3.new(0, 0, 0)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.TextWrapped = true
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.ZIndex = 999
label.Text = "UI OK – hooking Remote..."
label.Parent = screenGui

-- kalau ada script lain yg destroy GUI, re-attach lagi
screenGui.AncestryChanged:Connect(function(_, parent)
	if not parent then
		task.defer(function()
			if PlayerGui then screenGui.Parent = PlayerGui end
		end)
	end
end)

-- ==== state ====
local events = 0
local lastRemote = "-"
local hungryDeltaLast, thirstyDeltaLast = nil, nil
local hungryDeltaSum, thirstyDeltaSum = 0, 0
local hungryBase, thirstyBase = nil, nil -- kalau nanti bisa dibaca nilai awalnya
local hungryNow, thirstyNow = nil, nil

local function fmt(x) return x and tostring(x) or "?" end

local function refreshNow()
	if hungryBase then hungryNow = hungryBase + hungryDeltaSum end
	if thirstyBase then thirstyNow = thirstyBase + thirstyDeltaSum end
end

local function setText()
	refreshNow()
	label.Text = string.format(
		"Remote: %s | Events: %d\n" ..
		"Hungry: %s  (Δlast: %s, Δsum: %s)\n" ..
		"Thirsty: %s (Δlast: %s, Δsum: %s)",
		lastRemote, events,
		fmt(hungryNow or hungryBase), fmt(hungryDeltaLast), fmt(hungryDeltaSum),
		fmt(thirstyNow or thirstyBase), fmt(thirstyDeltaLast), fmt(thirstyDeltaSum)
	)
end
setText()

-- ==== helper parse notif ====
-- Contoh payload: "Notif", "Hungry bertambah +10"
local function parseNotif(text)
	if type(text) ~= "string" then return end
	local low = text:lower()
	local kind -- "hungry" / "thirsty"
	if low:find("hungry") or low:find("hunger") or low:find("lapar") then
		kind = "hungry"
	elseif low:find("thirst") or low:find("thirsty") or low:find("haus") or low:find("hydration") then
		kind = "thirsty"
	else
		return
	end

	-- cari angka +/- (boleh desimal)
	local sign = 1
	if low:find("berkurang") or low:find("-") then sign = -1 end
	local num = text:match("([%+%-]?%d+%.?%d*)")
	num = tonumber(num)
	if not num then return end

	local delta = sign * math.abs(num)
	return kind, delta
end

-- ==== (opsional) seed nilai awal dari GUI kalau kebaca (00.0/100) ====
task.spawn(function()
	task.wait(1) -- kasih waktu UI asli muncul
	local hungryLbl, thirstyLbl
	for _, obj in ipairs(PlayerGui:GetDescendants()) do
		if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and type(obj.Text)=="string" then
			local t = obj.Text:lower()
			if not hungryLbl and t:find("hungry") then hungryLbl = obj end
			if not thirstyLbl and t:find("thirst") then thirstyLbl = obj end
		end
	end
	local function numFromText(s)
		if type(s) ~= "string" then return nil end
		local n = s:match("(%d+%.?%d*)") -- ambil angka pertama dari "00.0/100"
		return n and tonumber(n) or nil
	end
	if hungryLbl then hungryBase = numFromText(hungryLbl.Text) end
	if thirstyLbl then thirstyBase = numFromText(thirstyLbl.Text) end
	setText()
	-- update jika label GUI berubah
	if hungryLbl then hungryLbl:GetPropertyChangedSignal("Text"):Connect(function()
		hungryBase = numFromText(hungryLbl.Text); setText()
	end) end
	if thirstyLbl then thirstyLbl:GetPropertyChangedSignal("Text"):Connect(function()
		thirstyBase = numFromText(thirstyLbl.Text); setText()
	end) end
end)

-- ==== cari & hook RemoteEvent "Network/RemoteEvent" (leifstout_networker@...) ====
local function findNetworkRemote()
	-- coba path yang kamu share (versi fixed)
	local ok, remote = pcall(function()
		return RS:WaitForChild("Packages", 3)
			:WaitForChild("_Index", 3)
			:WaitForChild("leifstout_networker@0.2.1", 3)
			:WaitForChild("networker", 3)
			:WaitForChild("_remotes", 3)
			:WaitForChild("Network", 3)
			:WaitForChild("RemoteEvent", 3)
	end)
	if ok and remote then return remote end

	-- kalau versi paket beda, cari folder yg namanya mulai "leifstout_networker@"
	local packages = RS:FindFirstChild("Packages")
	if not packages then return nil end
	local index = packages:FindFirstChild("_Index")
	if not index then return nil end
	for _, child in ipairs(index:GetChildren()) do
		if child.Name:match("^leifstout_networker@") then
			local nw = child:FindFirstChild("networker")
			if nw and nw:FindFirstChild("_remotes") then
				local net = nw._remotes:FindFirstChild("Network")
				if net and net:FindFirstChild("RemoteEvent") then
					return net.RemoteEvent
				end
			end
		end
	end
	return nil
end

local function hookRemote(re)
	if not re or not re:IsA("RemoteEvent") then return false end
	lastRemote = re:GetFullName()
	setText()

	re.OnClientEvent:Connect(function(...)
		events += 1
		lastRemote = re:GetFullName()

		local args = {...}
		-- format yang kamu kirim dari Sigma Spy: "Notif", "Hungry bertambah +10"
		if #args >= 2 and args[1] == "Notif" and type(args[2]) == "string" then
			local kind, delta = parseNotif(args[2])
			if kind == "hungry" and delta then
				hungryDeltaLast = delta
				hungryDeltaSum += delta
			elseif kind == "thirsty" and delta then
				thirstyDeltaLast = delta
				thirstyDeltaSum += delta
			end
		else
			-- kalau format beda, coba cek semua argumen string (fallback)
			for _,v in ipairs(args) do
				if type(v) == "string" then
					local kind, delta = parseNotif(v)
					if kind == "hungry" and delta then
						hungryDeltaLast = delta
						hungryDeltaSum += delta
					elseif kind == "thirsty" and delta then
						thirstyDeltaLast = delta
						thirstyDeltaSum += delta
					end
				end
			end
		end
		setText()
	end)
	return true
end

-- pasang hook
local remote = findNetworkRemote()
if not hookRemote(remote) then
	label.Text = label.Text .. "\nRemote belum ketemu, nunggu 5s..."
	task.delay(5, function()
		local again = findNetworkRemote()
		if hookRemote(again) then
			label.Text = "Remote ketemu ulang: " .. again:GetFullName()
		else
			label.Text = label.Text .. "\nGagal hook. Coba makan/minum dulu lalu rejoin, atau kasih aku path Remote terbaru."
		end
	end)
end
