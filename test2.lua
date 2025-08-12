-- LOCALSCRIPT di StarterPlayerScripts
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- ================= UI (template kamu, tidak diubah) =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugStatsUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local label = Instance.new("TextLabel")
label.Name = "DebugLabel"
label.Size = UDim2.fromScale(0.28, 0.065) -- kalau teks kepotong, gedein aja
label.Position = UDim2.fromOffset(10, 10)
label.BackgroundTransparency = 0.2
label.BackgroundColor3 = Color3.new(0, 0, 0)
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 20
label.ZIndex = 999
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Top
label.TextWrapped = true
label.Text = "UI OK - kelihatan?"
label.Parent = screenGui

-- kalau ada script lain yg destroy GUI, re-attach lagi
screenGui.AncestryChanged:Connect(function(_, parent)
	if not parent then
		task.defer(function()
			if PlayerGui then
				screenGui.Parent = PlayerGui
			end
		end)
	end
end)

-- ================== STATE & HELPER ==================
local events = 0
local lastRemote = "-"
local hungryDeltaLast, thirstyDeltaLast = nil, nil
local hungryDeltaSum,  thirstyDeltaSum  = 0, 0
local hungryBase,      thirstyBase      = nil, nil -- kalau nanti bisa dibaca dari GUI/leaderstats
local hungryNow,       thirstyNow       = nil, nil
local HB = 0 -- heartbeat bukti script jalan

local function fmt(x) return x and tostring(x) or "?" end
local function short(s)
	if not s then return "-" end
	s = tostring(s)
	return (#s > 28) and ("..." .. s:sub(-25)) or s
end

local function refreshTotals()
	if hungryBase  then hungryNow  = hungryBase  + hungryDeltaSum  end
	if thirstyBase then thirstyNow = thirstyBase + thirstyDeltaSum end
end

local function setText(status)
	refreshTotals()
	label.Text =
		(status or "UI OK") .. "\n" ..
		string.format("HB:%d | Ev:%d | Last:%s\nH:%s (Δ:%s Σ:%s) | T:%s (Δ:%s Σ:%s)",
			HB, events, short(lastRemote),
			fmt(hungryNow or hungryBase), fmt(hungryDeltaLast), fmt(hungryDeltaSum),
			fmt(thirstyNow or thirstyBase), fmt(thirstyDeltaLast), fmt(thirstyDeltaSum)
		)
end
setText("Booting...")

-- heartbeat (tiap detik biar kelihatan script hidup)
task.spawn(function()
	while true do
		HB += 1
		setText()
		task.wait(1)
	end
end)

-- ================== PARSER NOTIF ==================
-- Contoh: "Hungry bertambah +10" / "Thirsty berkurang -5"
local function parseNotif(text)
	if type(text) ~= "string" then return end
	local low = text:lower()
	local kind
	if low:find("hungry") or low:find("hunger") or low:find("lapar") then
		kind = "hungry"
	elseif low:find("thirst") or low:find("thirsty") or low:find("haus") or low:find("hydration") then
		kind = "thirsty"
	else
		return
	end
	local sign = 1
	if low:find("berkurang") or low:find("%-") then sign = -1 end
	local num = text:match("([%+%-]?%d+%.?%d*)")
	num = tonumber(num)
	if not num then return end
	return kind, sign * math.abs(num)
end

-- ================== (opsional) seed dari GUI (00.0/100) ==================
task.spawn(function()
	task.wait(1)
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

	if hungryLbl then
		hungryBase = numFromText(hungryLbl.Text)
		hungryLbl:GetPropertyChangedSignal("Text"):Connect(function()
			hungryBase = numFromText(hungryLbl.Text); setText("Seed GUI")
		end)
	end
	if thirstyLbl then
		thirstyBase = numFromText(thirstyLbl.Text)
		thirstyLbl:GetPropertyChangedSignal("Text"):Connect(function()
			thirstyBase = numFromText(thirstyLbl.Text); setText("Seed GUI")
		end)
	end
	setText("Seed GUI done")
end)

-- ================== HOOK REMOTE (Network/RemoteEvent) ==================
local function findNetworkRemote()
	-- path versi yang kamu kasih: leifstout_networker@0.2.1
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

	-- fallback: cari paket leifstout_networker@ versi berapa pun
	local index = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("_Index")
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
	if not (re and re:IsA("RemoteEvent")) then return false end
	lastRemote = re:GetFullName()
	setText("Hooked: "..lastRemote)

	re.OnClientEvent:Connect(function(...)
		events += 1
		lastRemote = re:GetFullName()

		local args = {...}
		-- Format yang ketahuan via Sigma Spy: "Notif", "Hungry bertambah +10"
		if #args >= 2 and args[1] == "Notif" and type(args[2]) == "string" then
			local kind, delta = parseNotif(args[2])
			if kind == "hungry"  and delta then hungryDeltaLast = delta; hungryDeltaSum += delta end
			if kind == "thirsty" and delta then thirstyDeltaLast = delta; thirstyDeltaSum += delta end
		else
			-- fallback: cek semua string
			for _,v in ipairs(args) do
				if type(v) == "string" then
					local kind, delta = parseNotif(v)
					if kind == "hungry"  and delta then hungryDeltaLast = delta; hungryDeltaSum += delta end
					if kind == "thirsty" and delta then thirstyDeltaLast = delta; thirstyDeltaSum += delta end
				end
			end
		end

		setText("Event received")
	end)
	return true
end

-- pasang hook tanpa mem-block UI
task.spawn(function()
	setText("Mencari Remote...")
	local remote = findNetworkRemote()
	if hookRemote(remote) then return end
	setText("Remote belum ketemu, retry...")

	-- retry beberapa kali supaya robust
	for i = 1, 10 do
		task.wait(1)
		if hookRemote(findNetworkRemote()) then
			setText("Hooked after retry")
			return
		end
	end
	setText("Gagal hook Remote. Coba makan/minum dulu, atau kirim path terbaru.")
end)
