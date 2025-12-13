-- Auto Crockpot + Scanner Map (WindUI) - Full script
-- Menggunakan WindUI (fallback ke Rayfield jika WindUI gagal)
-- Use at your own risk.

---------------------------------------------------------
-- Services & Refs
---------------------------------------------------------
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
local RequestStartDraggingItem = RemoteEvents and RemoteEvents:FindFirstChild("RequestStartDraggingItem") or nil
local StopDraggingItem         = RemoteEvents and RemoteEvents:FindFirstChild("StopDraggingItem") or nil

---------------------------------------------------------
-- State / Settings
---------------------------------------------------------
local AVAILABLE_ITEMS = {
    "Carrot","Corn","Apple","Cake","Ribs","Mackerel"
}

local SelectedItemsSet = {} -- set of selected item names
local SelectedItemsList = {} -- list for printing

local AutoEnabled   = false
local DelaySeconds  = 10
local ItemsPerCycle = 5
local MoveMode      = "DragPivot"  -- "DragPivot" | "TeleportOnly" | "SortOnly"
local LoopId        = 0
local SORT_RADIUS   = 15

local ScanContainsText = ""
local ScanMode = "All Entire Map" -- or "Near Me"
local ScanRadius = 50

local lastScanResults = { type = nil, data = {} }
local CrockPot = nil

---------------------------------------------------------
-- Helpers
---------------------------------------------------------
local function safeToString(v)
    if typeof(v) == "table" then
        return table.concat(v, ", ")
    else
        return tostring(v)
    end
end

local function setSelectedItem(name, state)
    if state then
        SelectedItemsSet[name] = true
    else
        SelectedItemsSet[name] = nil
    end
    -- rebuild list
    SelectedItemsList = {}
    for k,_ in pairs(SelectedItemsSet) do table.insert(SelectedItemsList, k) end
end

local function tableToSet(list)
    local s = {}
    for _, v in ipairs(list) do s[v] = true end
    return s
end

local function isWithinScan(pos)
    if not pos then return ScanMode == "All Entire Map" end
    if ScanMode == "All Entire Map" then return true end
    local char = LocalPlayer and LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local dist = (pos - char.HumanoidRootPart.Position).Magnitude
    return dist <= (tonumber(ScanRadius) or 0)
end

local function getCrockBase()
    if not CrockPot or not CrockPot.Parent then return nil end
    return CrockPot.PrimaryPart or CrockPot:FindFirstChildOfClass("BasePart")
end

local function ensureCrockPot(showNotify, notifyFn)
    local structures = workspace:FindFirstChild("Structures")
    if not structures then
        CrockPot = nil
        if notifyFn then notifyFn("Structures Tidak Ditemukan","workspace.Structures tidak ada.","warning") end
        return false
    end
    local pot = structures:FindFirstChild("Crock Pot")
    if not pot then
        CrockPot = nil
        if notifyFn then notifyFn("Crock Pot Tidak Terdeteksi","Taruh Crock Pot di map (nama model 'Crock Pot').","warning") end
        return false
    end
    CrockPot = pot
    if notifyFn then notifyFn("Crock Pot Terdeteksi","Crock Pot siap.", "check") end
    return true
end

local function getDropCFrame(crockBase, index)
    local radius = 2
    local height = 3
    local angle = (index - 1) * (math.pi / 4)
    local basePos = crockBase.Position
    local offsetX = math.cos(angle) * radius
    local offsetZ = math.sin(angle) * radius
    return CFrame.new(basePos + Vector3.new(offsetX, height, offsetZ))
end

-- safe notify maker (will be replaced by UI notifier)
local function makeNotifier(uiNotify)
    return function(title, content, kind)
        if uiNotify then
            pcall(function() uiNotify({ Title = title, Content = content, Duration = 4, Icon = (kind == "warning" and "alert-circle" or "check") }) end)
        else
            print(title .. " | " .. content)
        end
    end
end

---------------------------------------------------------
-- Processing (move items)
---------------------------------------------------------
local function collectCandidates(crockBase, targetSet)
    local candidates = {}
    local folder = workspace:FindFirstChild("Items")
    if not folder then return candidates end
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart and targetSet[item.Name] and not string.find(item.Name, "Item Chest") then
            local pos = item.PrimaryPart.Position
            local dist = (pos - crockBase.Position).Magnitude
            if (MoveMode ~= "SortOnly" or dist <= SORT_RADIUS) and isWithinScan(pos) then
                table.insert(candidates, { instance = item, distance = dist })
            end
        end
    end
    table.sort(candidates, function(a,b) return a.distance < b.distance end)
    return candidates
end

local function processOnce(uiNotify)
    if not CrockPot or not CrockPot.Parent then
        uiNotify("Crock Pot","Crock Pot belum di-set. Jalankan Ensure dulu.","warning")
        return
    end
    if next(SelectedItemsSet) == nil then
        uiNotify("Crock Pot","Tidak ada item dipilih.","warning")
        return
    end
    local crockBase = getCrockBase()
    if not crockBase then uiNotify("Crock Pot","Crock Pot tidak punya PrimaryPart/BasePart.","warning"); return end

    local targetSet = SelectedItemsSet
    local candidates = collectCandidates(crockBase, targetSet)
    if #candidates == 0 then uiNotify("Crock Pot","Tidak menemukan candidate.", "warning"); return end

    local maxCount = math.min(ItemsPerCycle, #candidates)
    uiNotify("Crock Pot", string.format("Process %d / %d (%s)", maxCount, #candidates, MoveMode), "check")

    if MoveMode == "DragPivot" then
        for i = 1, maxCount do
            local it = candidates[i].instance
            if it and it.Parent then
                local cf = getDropCFrame(crockBase, i)
                pcall(function() if RequestStartDraggingItem then RequestStartDraggingItem:FireServer(it) end end)
                task.wait(0.03)
                pcall(function() it:PivotTo(cf) end)
                task.wait(0.03)
                pcall(function() if StopDraggingItem then StopDraggingItem:FireServer(it) end end)
                task.wait(0.03)
            end
        end
    else
        for i = 1, maxCount do
            local it = candidates[i].instance
            if it and it.Parent then
                local cf = getDropCFrame(crockBase, i)
                pcall(function() it:PivotTo(cf) end)
                task.wait(0.02)
            end
        end
    end
end

local function startAutoLoop(uiNotify)
    LoopId = LoopId + 1
    local cur = LoopId
    task.spawn(function()
        uiNotify("Auto Crockpot","Auto started.", "check")
        while AutoEnabled and cur == LoopId do
            processOnce(uiNotify)
            task.wait(math.clamp(DelaySeconds, 5, 20))
        end
        uiNotify("Auto Crockpot","Auto stopped.", "check")
    end)
end

---------------------------------------------------------
-- Scans & Export (implements all functions you asked)
-- (These functions are the same behavior as previously provided)
---------------------------------------------------------
local function simpleJSONEncode(obj)
    local function escapeStr(s)
        s = tostring(s)
        s = s:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\n","\\n")
        return s
    end
    local function isArray(t)
        local i = 0
        for _ in pairs(t) do i = i + 1 if t[i] == nil then return false end end
        return true
    end
    local function encode(v)
        local t = typeof(v)
        if t == "string" then return '"'..escapeStr(v)..'"'
        elseif t == "number" or t == "boolean" then return tostring(v)
        elseif t == "table" then
            if isArray(v) then
                local parts = {}
                for i=1,#v do table.insert(parts, encode(v[i])) end
                return "["..table.concat(parts,",").."]"
            else
                local parts = {}
                for k,val in pairs(v) do table.insert(parts, '"'..escapeStr(k)..'":'..encode(val)) end
                return "{"..table.concat(parts,",").."}"
            end
        else
            return '"'..escapeStr(tostring(v))..'"'
        end
    end
    return encode(obj)
end

-- Implement scans (same as your working functions)
local function scanStructures(uiNotify)
    local folder = workspace:FindFirstChild("Structures")
    if not folder then uiNotify("Scan Failed","'Structures' tidak ditemukan.","warning"); return end
    local list = {}; local n = 0
    for _, obj in ipairs(folder:GetChildren()) do
        local pos = (obj.PrimaryPart and obj.PrimaryPart.Position) or nil
        if isWithinScan(pos) then
            n = n + 1
            table.insert(list, { idx = n, Name = obj.Name, Class = obj.ClassName, Path = "workspace.Structures."..obj.Name, Pos = pos and tostring(pos) or "NoPos" })
        end
    end
    lastScanResults.type = "Structures"; lastScanResults.data = list
    local out = {}
    for _, v in ipairs(list) do table.insert(out, string.format("%d) Name: %s | Class: %s | Path: %s | Pos: %s", v.idx, v.Name, v.Class, v.Path, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Structures: " .. n
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Structures Copied","Total: "..n.." | Copied.","check")
end

local function scanItems(uiNotify)
    local folder = workspace:FindFirstChild("Items")
    if not folder then uiNotify("Scan Failed","'Items' tidak ditemukan.","warning"); return end
    local list = {}; local n = 0
    for _, obj in ipairs(folder:GetChildren()) do
        local pos = (obj.PrimaryPart and obj.PrimaryPart.Position) or nil
        if isWithinScan(pos) then
            n = n + 1
            table.insert(list, { idx = n, Name = obj.Name, Class = obj.ClassName, Path = "workspace.Items."..obj.Name, Pos = pos and tostring(pos) or "NoPos" })
        end
    end
    lastScanResults.type = "Items"; lastScanResults.data = list
    local out = {}
    for _, v in ipairs(list) do table.insert(out, string.format("%d) Name: %s | Class: %s | Path: %s | Pos: %s", v.idx, v.Name, v.Class, v.Path, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Items: " .. n
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Items Copied","Total: "..n.." | Copied.","check")
end

local function scanChests(uiNotify)
    local folder = workspace:FindFirstChild("Structures") or workspace
    local list = {}; local n = 0
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("Model") and string.find(obj.Name:lower(), "chest") then
            local pos = (obj.PrimaryPart and obj.PrimaryPart.Position) or nil
            if isWithinScan(pos) then
                n = n + 1
                table.insert(list, { idx = n, Name = obj.Name, Path = "workspace.Structures."..obj.Name, Position = pos and tostring(pos) or "NoPos" })
            end
        end
    end
    lastScanResults.type = "Chests"; lastScanResults.data = list
    local out = {}
    for _, v in ipairs(list) do table.insert(out, string.format("%d) Name: %s | Path: %s | Pos: %s", v.idx, v.Name, v.Path, v.Position)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Chests: " .. n
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Chests Copied","Total: "..n.." | Copied.","check")
end

local function scanNearbyPlayers(radius, uiNotify)
    radius = radius or tonumber(ScanRadius) or 50
    local char = LocalPlayer and LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then uiNotify("Scan Failed","Character tidak ready.","warning"); return end
    local root = char.HumanoidRootPart
    local list = {}; local n = 0
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local pos = pl.Character.HumanoidRootPart.Position
            local dist = (pos - root.Position).Magnitude
            if ScanMode == "All Entire Map" or dist <= radius then
                n = n + 1
                table.insert(list, { idx = n, Name = pl.Name, Dist = string.format("%.1f", dist), Pos = tostring(pos) })
            end
        end
    end
    lastScanResults.type = "NearbyPlayers"; lastScanResults.data = list
    local out = {}
    for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Dist: %s | Pos: %s", v.idx, v.Name, v.Dist, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nNearby Players: " .. n
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Players Copied","Found: "..tostring(n).." | Mode: "..safeToString(ScanMode),"check")
end

local function scanNPCs(uiNotify)
    local candidates = {}
    local searched = { "NPCs", "Enemies", "Monsters" }
    for _, name in ipairs(searched) do
        local folder = workspace:FindFirstChild(name)
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    local pos = (obj.PrimaryPart and obj.PrimaryPart.Position) or nil
                    if isWithinScan(pos) then table.insert(candidates, obj) end
                end
            end
        end
    end
    local list = {}
    for i, npc in ipairs(candidates) do
        local pos = (npc.PrimaryPart and tostring(npc.PrimaryPart.Position)) or "NoPos"
        local hp = (npc:FindFirstChild("Humanoid") and npc.Humanoid.Health) or "N/A"
        table.insert(list, { idx = i, Name = npc.Name, HP = tostring(hp), Pos = pos })
    end
    lastScanResults.type = "NPCs"; lastScanResults.data = list
    local out = {}
    for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | HP: %s | Pos: %s", v.idx, v.Name, v.HP, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nTotal NPCs: " .. #list
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("NPCs Copied","Total: "..#list.." | Mode: "..safeToString(ScanMode),"check")
end

local function scanRareItems(keywords, uiNotify)
    keywords = keywords or {"gem","diamond","legend","ancient","rare"}
    local folder = workspace:FindFirstChild("Items")
    if not folder then uiNotify("Scan Failed","'Items' tidak ditemukan.","warning"); return end
    local list = {}; local n = 0
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") then
            local pos = (item.PrimaryPart and item.PrimaryPart.Position) or nil
            if isWithinScan(pos) then
                local nameLower = item.Name:lower()
                for _, kw in ipairs(keywords) do
                    if string.find(nameLower, kw:lower()) then
                        n = n + 1
                        table.insert(list, { idx = n, Name = item.Name, Pos = pos and tostring(pos) or "NoPos" })
                        break
                    end
                end
            end
        end
    end
    lastScanResults.type = "RareItems"; lastScanResults.data = list
    local out = {}
    for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Pos: %s", v.idx, v.Name, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Rare Items: " .. n
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Rare Items Copied","Total: "..tostring(n).." | Mode: "..safeToString(ScanMode),"check")
end

local function scanCraftingStations(uiNotify)
    local folder = workspace:FindFirstChild("Structures")
    if not folder then uiNotify("Scan Failed","'Structures' tidak ditemukan.","warning"); return end
    local list = {}; local n = 0
    for _, obj in ipairs(folder:GetChildren()) do
        local pos = (obj.PrimaryPart and obj.PrimaryPart.Position) or nil
        local name = obj.Name:lower()
        if isWithinScan(pos) and (string.find(name,"bench") or string.find(name,"station") or string.find(name,"blueprint") or string.find(name,"workshop")) then
            n = n + 1
            table.insert(list, { idx = n, Name = obj.Name, Pos = pos and tostring(pos) or "NoPos" })
        end
    end
    lastScanResults.type = "CraftingStations"; lastScanResults.data = list
    local out = {}; for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Pos: %s", v.idx, v.Name, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Stations: " .. n
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Stations Copied","Total: "..tostring(n).." | Mode: "..safeToString(ScanMode),"check")
end

local function scanResourceNodes(uiNotify)
    local candidates = {}
    local searched = { "Resources", "Nodes", "PickupNodes" }
    for _, name in ipairs(searched) do
        local folder = workspace:FindFirstChild(name)
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("Model") then
                    local pos = (obj.PrimaryPart and obj.PrimaryPart.Position) or nil
                    if isWithinScan(pos) then table.insert(candidates, obj) end
                end
            end
        end
    end
    local list = {}
    for i, node in ipairs(candidates) do table.insert(list, { idx = i, Name = node.Name, Pos = (node.PrimaryPart and tostring(node.PrimaryPart.Position)) or "NoPos" }) end
    lastScanResults.type = "ResourceNodes"; lastScanResults.data = list
    local out = {}; for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Pos: %s", v.idx, v.Name, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Resource Nodes: " .. #list
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Resources Copied","Total: "..tostring(#list).." | Mode: "..safeToString(ScanMode),"check")
end

local function scanItemsNearPosition(pos, radius, uiNotify)
    radius = radius or tonumber(ScanRadius) or 10
    if not pos then uiNotify("Scan Failed","No position specified and no Crock Pot found.","warning"); return end
    local folder = workspace:FindFirstChild("Items")
    if not folder then uiNotify("Scan Failed","'Items' not found.","warning"); return end
    local list = {}; local n = 0
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart then
            local dist = (item.PrimaryPart.Position - pos).Magnitude
            if dist <= radius and isWithinScan(item.PrimaryPart.Position) then
                n = n + 1
                table.insert(list, { idx = n, Name = item.Name, Dist = string.format("%.2f", dist), Pos = tostring(item.PrimaryPart.Position) })
            end
        end
    end
    lastScanResults.type = "ItemsNearPosition"; lastScanResults.data = list
    local out = {}; for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Dist: %s | Pos: %s", v.idx, v.Name, v.Dist, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Nearby Items: " .. n
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Nearby Items Copied","Total: "..tostring(n).." | Mode: "..safeToString(ScanMode),"check")
end

local function scanDuplicateItems(uiNotify)
    local folder = workspace:FindFirstChild("Items")
    if not folder then uiNotify("Scan Failed","'Items' not found.","warning"); return end
    local counts = {}
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") then
            local pos = (item.PrimaryPart and item.PrimaryPart.Position) or nil
            if isWithinScan(pos) then counts[item.Name] = (counts[item.Name] or 0) + 1 end
        end
    end
    local list = {}; local idx = 0
    for name, cnt in pairs(counts) do if cnt > 1 then idx = idx + 1 table.insert(list, { idx = idx, Name = name, Count = cnt }) end end
    lastScanResults.type = "DuplicateItems"; lastScanResults.data = list
    local out = {}; for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Count: %d", v.idx, v.Name, v.Count)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Duplicate Types: " .. #list
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Duplicates Copied","Types: "..tostring(#list).." | Mode: "..safeToString(ScanMode),"check")
end

local function scanItemOwnership(uiNotify)
    local folder = workspace:FindFirstChild("Items")
    if not folder then uiNotify("Scan Failed","'Items' not found.","warning"); return end
    local list = {}; local idx = 0
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") then
            local pos = (item.PrimaryPart and item.PrimaryPart.Position) or nil
            if isWithinScan(pos) then
                idx = idx + 1
                local owner = "N/A"
                local ov = item:FindFirstChild("Owner") or item:FindFirstChildOfClass("ObjectValue") or item:FindFirstChildOfClass("StringValue")
                if ov and ov.Value then owner = tostring(ov.Value) end
                table.insert(list, { idx = idx, Name = item.Name, Owner = owner })
            end
        end
    end
    lastScanResults.type = "ItemOwnership"; lastScanResults.data = list
    local out = {}; for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Owner: %s", v.idx, v.Name, v.Owner)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Items Scanned: " .. #list
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Ownership Copied","Total: "..tostring(#list).." | Mode: "..safeToString(ScanMode),"check")
end

local function scanParts(uiNotify)
    local list = {}; local idx = 0; local MAX_PARTS = 2000
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local pos = obj.Position
            if isWithinScan(pos) then
                idx = idx + 1
                local full = obj:GetFullName()
                local path = "workspace." .. (full:gsub("[Ww]orkspace%.", ""))
                table.insert(list, { idx = idx, Name = obj.Name, Class = obj.ClassName, Path = path, Pos = tostring(pos), Size = tostring(obj.Size) })
                if idx >= MAX_PARTS then table.insert(list, { idx = idx+1, Name = "...truncated..." }); break end
            end
        end
    end
    lastScanResults.type = "Parts"; lastScanResults.data = list
    local out = {}; for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Class: %s | Path: %s | Pos: %s | Size: %s", v.idx, v.Name, v.Class, v.Path, v.Pos, v.Size)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Parts: " .. tostring(idx)
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Parts Copied","Total: "..tostring(idx).." | Mode: "..safeToString(ScanMode),"check")
end

local function exportLastScanAsJSON(uiNotify)
    if not lastScanResults or not lastScanResults.type then uiNotify("Export Failed","No last scan results.","warning"); return end
    local json = simpleJSONEncode(lastScanResults)
    if typeof(setclipboard) == "function" then pcall(setclipboard, json) end
    uiNotify("Exported JSON","Last scan copied as JSON.","check")
end

local function exportLastScanAsCSV(uiNotify)
    if not lastScanResults or not lastScanResults.type then uiNotify("Export Failed","No last scan results.","warning"); return end
    local first = lastScanResults.data[1]
    if not first then uiNotify("Export Failed","Last scan empty.","warning"); return end
    local keys = {}
    for k,_ in pairs(first) do table.insert(keys,k) end table.sort(keys)
    local rows = {}
    table.insert(rows, table.concat(keys,","))
    for _, row in ipairs(lastScanResults.data) do
        local cols = {}
        for _, k in ipairs(keys) do
            local v = row[k] or ""
            v = tostring(v):gsub('"', '""')
            if string.find(v, "[,\"\n]") then v = '"'..v..'"' end
            table.insert(cols, v)
        end
        table.insert(rows, table.concat(cols, ","))
    end
    local csv = table.concat(rows, "\n")
    if typeof(setclipboard) == "function" then pcall(setclipboard, csv) end
    uiNotify("Exported CSV","Last scan copied as CSV.","check")
end

local function scanItemsContains(uiNotify)
    local query = string.lower(ScanContainsText or "")
    if query == "" then uiNotify("No Query","Masukkan teks di Contains Name.","warning"); return end
    local folder = workspace:FindFirstChild("Items")
    if not folder then uiNotify("Folder Tidak Ditemukan","'Items' tidak ada.","warning"); return end
    local list = {}; local idx = 0
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") then
            local nameLower = item.Name:lower()
            local pos = item.PrimaryPart and item.PrimaryPart.Position
            if string.find(nameLower, query) and isWithinScan(pos) then
                idx = idx + 1
                table.insert(list, { idx = idx, Name = item.Name, Pos = tostring(pos) })
            end
        end
    end
    lastScanResults.type = "ItemsContains"; lastScanResults.data = list
    local out = {}; for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Pos: %s", v.idx, v.Name, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Items: " .. tostring(idx)
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Items (Contains) Copied","Total: "..tostring(idx).." | Copied.","check")
end

local function scanPartsContains(uiNotify)
    local query = string.lower(ScanContainsText or "")
    if query == "" then uiNotify("No Query","Masukkan teks di Contains Name.","warning"); return end
    local list = {}; local idx = 0; local MAX_PARTS = 2000
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local pos = obj.Position
            if isWithinScan(pos) and string.find(obj.Name:lower(), query) then
                idx = idx + 1
                local full = obj:GetFullName()
                local path = "workspace." .. (full:gsub("[Ww]orkspace%.", ""))
                table.insert(list, { idx = idx, Name = obj.Name, Path = path, Pos = tostring(pos) })
                if idx >= MAX_PARTS then break end
            end
        end
    end
    lastScanResults.type = "PartsContains"; lastScanResults.data = list
    local out = {}; for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Path: %s | Pos: %s", v.idx, v.Name, v.Path, v.Pos)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Parts: " .. tostring(idx)
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Parts (Contains) Copied","Total: "..tostring(idx).." | Copied.","check")
end

local function scanStructuresContains(uiNotify)
    local query = string.lower(ScanContainsText or "")
    if query == "" then uiNotify("No Query","Masukkan teks di Contains Name.","warning"); return end
    local folder = workspace:FindFirstChild("Structures")
    if not folder then uiNotify("Folder Tidak Ditemukan","'Structures' tidak ada.","warning"); return end
    local list = {}; local idx = 0
    for _, obj in ipairs(folder:GetChildren()) do
        local pos = obj.PrimaryPart and obj.PrimaryPart.Position
        if string.find(obj.Name:lower(), query) and isWithinScan(pos) then
            idx = idx + 1
            table.insert(list, { idx = idx, Name = obj.Name, Pos = tostring(pos), Path = "workspace.Structures." .. obj.Name })
        end
    end
    lastScanResults.type = "StructuresContains"; lastScanResults.data = list
    local out = {}; for _, v in ipairs(list) do table.insert(out, string.format("%d) %s | Pos: %s | Path: %s", v.idx, v.Name, v.Pos, v.Path)) end
    local text = table.concat(out, "\n") .. "\n\nTotal Structures: " .. tostring(idx)
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Structures (Contains) Copied","Total: "..tostring(idx).." | Copied.","check")
end

local function copyMethodsDoc(uiNotify)
    local text = [[
AUTO ITEM METHODS + EXPLANATION
DRAG -> PIVOT -> LEPAS is the golden pattern.
]]
    if typeof(setclipboard) == "function" then pcall(setclipboard, text) end
    uiNotify("Methods Copied","Metode + penjelasan dicopy ke clipboard.","check")
end

---------------------------------------------------------
-- UI (WindUI preferred; fallback Rayfield)
---------------------------------------------------------
local okWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if okWind and WindUI then
    WindUI:SetTheme("Dark"); WindUI.TransparencyValue = 0.15
    local notifyFn = makeNotifier(function(opts) WindUI:Notify(opts) end)

    local Window = WindUI:CreateWindow({
        Title = "Auto Crockpot",
        Icon = "zap",
        Author = "AutoScript",
        Folder = "AutoCrockpot_WindUI",
        Size = UDim2.fromOffset(720, 600),
        Theme = "Dark",
        Transparent = true,
        Acrylic = true,
        SideBarWidth = 180,
        HasOutline = true,
    })

    Window:EditOpenButton({
        Title = "Auto Crockpot",
        Icon = "zap",
        CornerRadius = UDim.new(0, 12),
        StrokeThickness = 1,
        Color = ColorSequence.new(Color3.fromRGB(120,200,150), Color3.fromRGB(60,160,110)),
        OnlyMobile = false,
        Enabled = true,
        Draggable = true,
    })

    -- Tab: Auto Crockpot
    local autoTab = Window:Tab({ Title = "Auto Crockpot", Icon = "coffee" })
    autoTab:Paragraph({ Title = "Auto Crockpot", Desc = "Kontrol auto crockpot.", Color = "Grey" })

    -- Items selection as toggles (ensures visible)
    autoTab:Paragraph({ Title = "Pilih Items (toggle)", Desc = "Centang item yang ingin diproses.", Color = "Grey" })
    for _, name in ipairs(AVAILABLE_ITEMS) do
        autoTab:Toggle({
            Title = name,
            Default = false,
            Callback = function(state) setSelectedItem(name, state) end
        })
    end

    -- Move Mode as radio-like toggles
    autoTab:Paragraph({ Title = "Mode Pemindahan", Desc = "Pilih salah satu mode.", Color = "Grey" })
    local function setMoveMode(m)
        MoveMode = m
        WindUI:Notify({ Title = "Mode", Content = MoveMode, Duration = 1.2, Icon = "info" })
    end
    autoTab:Toggle({ Title = "Drag + Pivot (Safe)", Default = true, Callback = function(s) if s then setMoveMode("DragPivot") end end })
    autoTab:Toggle({ Title = "Teleport Only (Fast)", Default = false, Callback = function(s) if s then setMoveMode("TeleportOnly") end end })
    autoTab:Toggle({ Title = "Sort Around Pot (Arrange)", Default = false, Callback = function(s) if s then setMoveMode("SortOnly") end end })

    autoTab:Slider({ Title = "Jumlah item per siklus", Description = "1 - 50", Step = 1, Value = { Min = 1, Max = 50, Default = ItemsPerCycle }, Callback = function(v) ItemsPerCycle = tonumber(v) or ItemsPerCycle end })
    autoTab:Slider({ Title = "Delay antar siklus (detik)", Description = "5 - 60", Step = 1, Value = { Min = 5, Max = 60, Default = DelaySeconds }, Callback = function(v) DelaySeconds = tonumber(v) or DelaySeconds end })

    autoTab:Toggle({ Title = "Auto (ON/OFF)", Default = false, Callback = function(state)
        if state then
            local ok = ensureCrockPot(true, notifyFn)
            if not ok then WindUI:Notify({ Title = "Auto", Content = "CrockPot tidak ditemukan. Auto dibatalkan.", Duration = 2.5, Icon = "alert-circle" }) return end
            AutoEnabled = true
            startAutoLoop(notifyFn)
        else
            AutoEnabled = false
        end
    end })

    autoTab:Button({ Title = "Test Run 1x", Callback = function() local ok = ensureCrockPot(true, notifyFn); if ok then processOnce(notifyFn) end end })
    autoTab:Button({ Title = "Ensure CrockPot (detect)", Callback = function() ensureCrockPot(true, notifyFn) end })

    -- Tab: Scanner Map
    local scanTab = Window:Tab({ Title = "Scanner Map", Icon = "map" })
    scanTab:Paragraph({ Title = "Scanner Map", Desc = "Semua alat scan & export.", Color = "Grey" })

    -- Scan Mode toggles (radio-like)
    scanTab:Paragraph({ Title = "Scan Setting", Desc = "Pilih Mode scan & radius Near Me.", Color = "Grey" })
    scanTab:Toggle({ Title = "All Entire Map", Default = (ScanMode=="All Entire Map"), Callback = function(s) if s then ScanMode = "All Entire Map"; WindUI:Notify({ Title="Scan Mode", Content=ScanMode, Duration=1.2, Icon="map-pin" }) end end })
    scanTab:Toggle({ Title = "Near Me (Studs)", Default = (ScanMode=="Near Me"), Callback = function(s) if s then ScanMode = "Near Me"; WindUI:Notify({ Title="Scan Mode", Content=ScanMode, Duration=1.2, Icon="map-pin" }) end end })

    -- Studs radius input + slider
    scanTab:Input({ Title = "Studs Near Me (radius)", Placeholder = "Masukkan angka (contoh: 50)", Default = tostring(ScanRadius), Callback = function(text)
        local n = tonumber(tostring(text or ""):match("%-?%d+"))
        if n and n > 0 then ScanRadius = n; WindUI:Notify({ Title = "ScanRadius", Content = tostring(ScanRadius).." studs", Duration = 1.2, Icon = "map-pin" }) else WindUI:Notify({ Title="Invalid", Content="Masukkan angka > 0"}) end
    end })
    scanTab:Slider({ Title = "Quick Radius", Description = "5 - 2000", Step = 1, Value = { Min = 5, Max = 2000, Default = ScanRadius }, Callback = function(v) ScanRadius = tonumber(v) or ScanRadius end })

    -- Contains input
    scanTab:Input({ Title = "Contains Name", Placeholder = "masukkan teks pencarian...", Default = ScanContainsText, Callback = function(text) ScanContainsText = tostring(text or "") end })

    -- Contains buttons
    scanTab:Button({ Title = "Scan Items (Contains) + Copy", Callback = function() scanItemsContains(notifyFn) end })
    scanTab:Button({ Title = "Scan Parts (Contains) + Copy", Callback = function() scanPartsContains(notifyFn) end })
    scanTab:Button({ Title = "Scan Structures (Contains) + Copy", Callback = function() scanStructuresContains(notifyFn) end })

    -- Full scan buttons
    scanTab:Button({ Title = "Scan Structures + Copy", Callback = function() scanStructures(notifyFn) end })
    scanTab:Button({ Title = "Scan Items + Copy", Callback = function() scanItems(notifyFn) end })
    scanTab:Button({ Title = "Scan Chests + Copy", Callback = function() scanChests(notifyFn) end })
    scanTab:Button({ Title = "Scan Nearby Players (uses Studs) + Copy", Callback = function() scanNearbyPlayers(tonumber(ScanRadius) or 50, notifyFn) end })
    scanTab:Button({ Title = "Scan NPCs + Copy", Callback = function() scanNPCs(notifyFn) end })
    scanTab:Button({ Title = "Scan Rare Items + Copy", Callback = function() scanRareItems({"gem","diamond","legend","ancient","rare"}, notifyFn) end })
    scanTab:Button({ Title = "Scan Crafting Stations + Copy", Callback = function() scanCraftingStations(notifyFn) end })
    scanTab:Button({ Title = "Scan Resource Nodes + Copy", Callback = function() scanResourceNodes(notifyFn) end })
    scanTab:Button({ Title = "Scan Items Near Crockpot (uses Studs) + Copy", Callback = function()
        local crock = workspace:FindFirstChild("Structures") and workspace.Structures:FindFirstChild("Crock Pot")
        if crock and (crock.PrimaryPart or crock:FindFirstChildOfClass("BasePart")) then
            local pos = (crock.PrimaryPart or crock:FindFirstChildOfClass("BasePart")).Position
            scanItemsNearPosition(pos, tonumber(ScanRadius) or 10, notifyFn)
        else
            notifyFn("No Crockpot","Crock Pot tidak ditemukan.","warning")
        end
    end })

    scanTab:Button({ Title = "Scan Duplicate Items + Copy", Callback = function() scanDuplicateItems(notifyFn) end })
    scanTab:Button({ Title = "Scan Item Ownership + Copy", Callback = function() scanItemOwnership(notifyFn) end })
    scanTab:Button({ Title = "Scan Parts + Copy", Callback = function() scanParts(notifyFn) end })

    -- Export / other
    scanTab:Button({ Title = "Export Last Scan as JSON (Copy)", Callback = function() exportLastScanAsJSON(notifyFn) end })
    scanTab:Button({ Title = "Export Last Scan as CSV (Copy)", Callback = function() exportLastScanAsCSV(notifyFn) end })
    scanTab:Button({ Title = "Copy All Methods + Penjelasan", Callback = function() copyMethodsDoc(notifyFn) end })
    scanTab:Button({ Title = "Clear Output (console)", Callback = function() for _ = 1,60 do print("") end notifyFn("Console Cleared","Output F9 dibersihkan.","check") end })

    WindUI:Notify({ Title = "Loaded", Content = "Auto Crockpot + Scanner Map siap (WindUI).", Duration = 3, Icon = "check" })

else
    -- Fallback: try Rayfield (uses your original API)
    local okRay, Rayfield = pcall(function() return loadstring(game:HttpGet("https://sirius.menu/rayfield"))() end)
    local uiNotify = function(title, content, kind) if okRay and Rayfield and Rayfield.Notify then Rayfield:Notify({ Title = title, Content = content, Duration = 4, Image = (kind=="warning" and "warning" or "check") }) else print(title.. " - "..content) end end
    if not okRay or not Rayfield then
        print("[AutoCrockpot] WindUI & Rayfield gagal dimuat. UI tidak tersedia, fungsi tetap bisa dipanggil via console.")
        return
    end

    local Window = Rayfield:CreateWindow({ Name = "Auto Crockpot Helper", LoadingTitle = "Auto Crockpot", LoadingSubtitle = "Fallback UI", Theme = "Default" })
    local Tab = Window:CreateTab("Crockpot", 4483362458)
    Tab:CreateParagraph({ Title = "Auto Crockpot", Content = "Fallback UI: Auto Crockpot" })
    -- keep simple fallback UI (not fully replicated here for brevity)
    Rayfield:Notify({ Title = "Fallback Loaded", Content = "WindUI gagal. Fallback Rayfield aktif.", Duration = 5, Image = "warning" })
end
