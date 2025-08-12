-- LocalScript: RemoteEvent Logger + Parser Hungry/Thirsty (UI tampil argumen)
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- ========= UI (template kamu) =========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugStatsUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local label = Instance.new("TextLabel")
label.Name = "DebugLabel"
label.Size = UDim2.fromScale(0.56, 0.28)
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
label.Text = "UI OK – logger siap"
label.Parent = screenGui

screenGui.AncestryChanged:Connect(function(_, parent)
	if not parent then
		task.defer(function()
			if PlayerGui then screenGui.Parent = PlayerGui end
		end)
	end
end)

-- ========= util output =========
local HB, Hooked, Events = 0, 0, 0
local LastRemote = "-"
local logs = {}     -- ring buffer last 6 baris
local MAX_LOG = 6

local HungryBase, ThirstBase = nil, nil   -- kalau nanti bisa baca angka awal
local HungrySum,  ThirstSum  = 0, 0
local HungryLast, ThirstLast = nil, nil

local function pushLog(line)
	table.insert(logs, 1, line)
	if #logs > MAX_LOG then table.remove(logs) end
end

local function short(s, max)
	max = max or 120
	if not s then return "" end
	s = tostring(s)
	if #s > max then
		return s:sub(1, max-3) .. "..."
	end
	return s
end

local function safeFullName(inst)
	local ok, res = pcall(function()
		return inst:GetFullName()
	end)
	return ok and res or (inst.ClassName .. " " .. (inst.Name or "?"))
end

local function dumpVal(v, depth)
	depth = depth or 0
	if depth > 1 then return "{...}" end
	local t = typeof(v)
	if t == "string" then
		return '"' .. short(v, 80) .. '"'
	elseif t == "number" or t == "boolean" then
		return tostring(v)
	elseif t == "Instance" then
		return "<" .. safeFullName(v) .. ">"
	elseif t == "table" then
		local parts, count = {}, 0
		for k,val in pairs(v) do
			count += 1
			if count > 5 then table.insert(parts, "..."); break end
			local keyStr = (type(k)=="string") and k or ("["..tostring(k).."]")
			table.insert(parts, keyStr .. "=" .. dumpVal(val, depth+1))
		end
		return "{" .. table.concat(parts, ", ") .. "}"
	else
		return "<"..t..">"
	end
end

local function getNumberFromText(text)
	if type(text) ~= "string" then return nil end
	local n = text:match("([%+%-]?%d+%.?%d*)")
	return n and tonumber(n) or nil
end

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
	local num = getNumberFromText(text)
	if not num then return end
	-- kalau kalimatnya mengandung "berkurang" atau ada tanda minus, paksa negatif
	if low:find("berkurang") and num > 0 then num = -num end
	return kind, num
end

local function nowValue(base, sum)
	return base and (base + sum) or nil
end

local function refreshLabel()
	local lines = {}
	table.insert(lines, ("HB:%d | Hooked:%d | Events:%d"):format(HB, Hooked, Events))
	table.insert(lines, "LastRemote: " .. LastRemote)
	local hNow = nowValue(HungryBase, HungrySum)
	local tNow = nowValue(ThirstBase, ThirstSum)
	table.insert(lines, ("Hungry: %s (Δlast:%s, Σ:%s)"):format(hNow and tostring(hNow) or "?", HungryLast and tostring(HungryLast) or "?", tostring(HungrySum)))
	table.insert(lines, ("Thirsty: %s (Δlast:%s, Σ:%s)"):format(tNow and tostring(tNow) or "?", ThirstLast and tostring(ThirstLast) or "?", tostring(ThirstSum)))
	table.insert(lines, "---- last payloads ----")
	for i = 1, math.min(#logs, MAX_LOG) do
		table.insert(lines, logs[i])
	end
	label.Text = table.concat(lines, "\n")
end

-- heartbeat (bukti script jalan)
task.spawn(function()
	while true do
		HB += 1
		refreshLabel()
		task.wait(1)
	end
end)

-- (opsional) seed nilai awal dari GUI (format "00.0/100")
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
	local function baseFromLabel(o)
		if not o then return nil end
		local n = o.Text:match("(%d+%.?%d*)")
		return n and tonumber(n) or nil
	end
	HungryBase = baseFromLabel(hungryLbl)
	ThirstBase = baseFromLabel(thirstyLbl)
	if hungryLbl then
		hungryLbl:GetPropertyChangedSignal("Text"):Connect(function()
			HungryBase = baseFromLabel(hungryLbl); refreshLabel()
		end)
	end
	if thirstyLbl then
		thirstyLbl:GetPropertyChangedSignal("Text"):Connect(function()
			ThirstBase = baseFromLabel(thirstyLbl); refreshLabel()
		end)
	end
	refreshLabel()
end)

-- ========= hook RemoteEvent =========
local function hookRemote(re)
	if not re or not re:IsA("RemoteEvent") then return end
	Hooked += 1
	refreshLabel()
	re.OnClientEvent:Connect(function(...)
		Events += 1
		LastRemote = safeFullName(re)

		-- bangun summary argumen
		local parts = {}
		local args = {...}
		for i, a in ipairs(args) do
			parts[i] = "arg"..i.."="..short(dumpVal(a), 140)
		end
		pushLog(short(table.concat(parts, " | "), 220))

		-- parsing notif (cari string di args & juga di table nested level 1)
		for _, a in ipairs(args) do
			if type(a) == "string" then
				local kind, delta = parseNotif(a)
				if kind == "hungry" then HungryLast = delta; HungrySum += delta end
				if kind == "thirsty" then ThirstLast = delta; ThirstSum += delta end
			elseif typeof(a) == "table" then
				for k,v in pairs(a) do
					if type(v) == "string" then
						local kind, delta = parseNotif(v)
						if kind == "hungry" then HungryLast = delta; HungrySum += delta end
						if kind == "thirsty" then ThirstLast = delta; ThirstSum += delta end
					end
					-- kalau key-nya informatif (mis. {Hungry=10})
					if type(k) == "string" and (k:lower():find("hung") or k:lower():find("thirst")) and tonumber(v) then
						if k:lower():find("hung") then HungryLast = tonumber(v); HungrySum += tonumber(v) end
						if k:lower():find("thirst") then ThirstLast = tonumber(v); ThirstSum += tonumber(v) end
					end
				end
			end
		end

		refreshLabel()
	end)
end

-- 1) coba hook path networker yg kamu sebut (versi spesifik & wildcard)
local function findAndHookNetworker()
	local ok, fixed = pcall(function()
		return RS:WaitForChild("Packages", 1)
			:WaitForChild("_Index", 1)
			:WaitForChild("leifstout_networker@0.2.1", 1)
			:WaitForChild("networker", 1)
			:WaitForChild("_remotes", 1)
			:WaitForChild("Network", 1)
			:WaitForChild("RemoteEvent", 1)
	end)
	if ok and fixed then hookRemote(fixed) end

	local packages = RS:FindFirstChild("Packages")
	if not packages then return end
	local index = packages:FindFirstChild("_Index")
	if not index then return end
	for _, child in ipairs(index:GetChildren()) do
		if child.Name:match("^leifstout_networker@") then
			local nw = child:FindFirstChild("networker")
			if nw and nw:FindFirstChild("_remotes") then
				for _, sub in ipairs(nw._remotes:GetDescendants()) do
					if sub:IsA("RemoteEvent") then hookRemote(sub) end
				end
			end
		end
	end
end

-- 2) hook semua RemoteEvent lain di ReplicatedStorage (cadangan)
for _, obj in ipairs(RS:GetDescendants()) do
	if obj:IsA("RemoteEvent") then hookRemote(obj) end
end
RS.DescendantAdded:Connect(function(obj)
	if obj:IsA("RemoteEvent") then hookRemote(obj) end
end)

findAndHookNetworker()
refreshLabel()

-- heartbeat naik → bukti script jalan.
-- lihat bagian "---- last payloads ----" buat isi argumen event terakhir.
