-- LocalScript: Auto-buang item 0/x ke tempat sampah (pakai UI-mu)
if not game:IsLoaded() then game.Loaded:Wait() end

-- ===== Services =====
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local PPS = game:GetService("ProximityPromptService")

-- ===== Config =====
local USE_REMOTE_FALLBACK = true           -- true = kalau prompt gagal, coba remote
local TRASH_OPCODE = "Buang Sampah"        -- ganti kalau sniffing-mu beda
local SCAN_INTERVAL = 0.5                  -- detik

-- ===== UI (template kamu) =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugStatsUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local label = Instance.new("TextLabel")
label.Name = "DebugLabel"
label.Size = UDim2.fromScale(0.42, 0.12)
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
label.Text = "AutoTrash siap…"
label.Parent = screenGui

screenGui.AncestryChanged:Connect(function(_, parent)
	if not parent then
		task.defer(function()
			if PlayerGui then screenGui.Parent = PlayerGui end
		end)
	end
end)

local function log(...)
	label.Text = table.concat({...}, "\n")
end

-- ===== Utils =====
local function parseUses(name)
	if type(name) ~= "string" then return nil,nil end
	local cur, max = name:match("(%d+)%s*/%s*(%d+)")
	return cur and tonumber(cur) or nil, max and tonumber(max) or nil
end

local function baseName(name)
	if type(name) ~= "string" then return name end
	local s = name
	s = s:gsub("%s*%(%s*%d+%s*/%s*%d+%s*%)", "") -- hapus "(x/y)"
	s = s:gsub("%s*%d+%s*/%s*%d+%s*$", "")       -- hapus " x/y" di akhir
	return s
end

local function gatherTools()
	local list = {}
	local bp = LP:FindFirstChild("Backpack")
	if bp then
		for _,t in ipairs(bp:GetChildren()) do
			if t:IsA("Tool") then table.insert(list, t) end
		end
	end
	local char = LP.Character or LP.CharacterAdded:Wait()
	for _,t in ipairs(char:GetChildren()) do
		if t:IsA("Tool") then table.insert(list, t) end
	end
	return list
end

-- ===== Cari ProximityPrompt “Buang Sampah” =====
local function findTrashPrompt()
	local container = workspace:FindFirstChild("TempatSampah") or workspace:FindFirstChild("TempatSampah", true)
	if not container then return nil end
	local best, bestDist
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	for _, obj in ipairs(container:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			local a = (obj.ActionText or ""):lower()
			local o = (obj.ObjectText or ""):lower()
			if a:find("buang") or a:find("sampah") or o:find("buang") or o:find("sampah") then
				if root and obj.Parent and obj.Parent:IsA("BasePart") then
					local d = (root.Position - obj.Parent.Position).Magnitude
					if not best or d < bestDist then best, bestDist = obj, d end
				else
					best = best or obj
				end
			end
		end
	end
	return best
end

local function triggerPrompt(prompt)
	-- gunakan fireproximityprompt jika tersedia (umum di executor); aman di pcall
	local ok = false
	if typeof(fireproximityprompt) == "function" then
		ok = pcall(function() fireproximityprompt(prompt) end)
	end
	-- fallback: coba “hold” lewat ProximityPromptService jika ada (beberapa executor expose)
	if not ok and PPS and prompt.InputHoldBegin then
		-- bukan API resmi untuk client, tapi banyak environment support
		pcall(function()
			prompt:InputHoldBegin()
			task.wait(prompt.HoldDuration or 0)
			prompt:InputHoldEnd()
		end)
		ok = true
	end
	return ok
end

-- ===== Remote fallback (kalau ada) =====
local function findNetworkRemote()
	local ok, remote = pcall(function()
		return RS:WaitForChild("Packages", 2)
			:WaitForChild("_Index", 2)
			:FindFirstChildWhichIsA("Folder", true) -- cari paket leifstout_networker@*
	end)
	if ok and remote then
		-- coba spesifik jalur networker
		local idx = RS.Packages:FindFirstChild("_Index")
		if idx then
			for _,child in ipairs(idx:GetChildren()) do
				if child.Name:match("^leifstout_networker@") then
					local nw = child:FindFirstChild("networker")
					if nw and nw:FindFirstChild("_remotes") and nw._remotes:FindFirstChild("Network") then
						return nw._remotes.Network:FindFirstChild("RemoteEvent")
					end
				end
			end
		end
	end
	return nil
end
local NetworkRemote = findNetworkRemote()

local function sendRemoteTrash(itemBaseName)
	if not USE_REMOTE_FALLBACK then return false end
	NetworkRemote = NetworkRemote or findNetworkRemote()
	if not NetworkRemote then
		log("AutoTrash: Remote tidak ditemukan.", "Pastikan networker ada di ReplicatedStorage.")
		return false
	end
	local ok, err = pcall(function()
		-- Jika game butuh bentuk lain, ubah sesuai sniff-mu:
		-- contoh lain: NetworkRemote:FireServer("Inventory","Buang Sampah", itemBaseName)
		NetworkRemote:FireServer(TRASH_OPCODE, itemBaseName)
	end)
	if ok then
		log(("Remote '%s' terkirim untuk: %s"):format(TRASH_OPCODE, itemBaseName))
	else
		log("Gagal kirim remote:", tostring(err))
	end
	return ok
end

-- ===== Main: cek & buang =====
local alreadyTrashed = {}

local function tryTrash(tool)
	local cur, max = parseUses(tool.Name)
	if not (cur and max) then return end
	if cur > 0 then return end

	local itemName = baseName(tool.Name)
	local key = itemName .. "|" .. tostring(max)
	if alreadyTrashed[key] then return end
	alreadyTrashed[key] = true

	-- 1) coba prompt “Buang Sampah”
	local prompt = findTrashPrompt()
	if prompt then
		local ok = triggerPrompt(prompt)
		if ok then
			log(("Buang via Prompt: %s"):format(itemName), "(TempatSampah)")
			return
		end
	end

	-- 2) fallback: remote
	if sendRemoteTrash(itemName) then
		log(("Buang via Remote: %s"):format(itemName))
	else
		log(("Gagal buang %s: prompt/remote tidak jalan."):format(itemName))
	end
end

local function watchTool(tool)
	if not tool:IsA("Tool") then return end
	tool:GetPropertyChangedSignal("Name"):Connect(function()
		tryTrash(tool)
	end)
	-- cek awal
	tryTrash(tool)
end

-- hook existing
for _,t in ipairs(gatherTools()) do watchTool(t) end

-- hook baru
local bp = LP:WaitForChild("Backpack")
bp.ChildAdded:Connect(watchTool)
local char = LP.Character or LP.CharacterAdded:Wait()
char.ChildAdded:Connect(watchTool)

-- backup loop
task.spawn(function()
	while true do
		for _,t in ipairs(gatherTools()) do tryTrash(t) end
		task.wait(SCAN_INTERVAL)
	end
end)

log("AutoTrash aktif. Item yang jadi 0/x akan dibuang ke tempat sampah.")
