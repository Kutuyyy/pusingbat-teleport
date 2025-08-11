--[[
    Pusingbat — Asset / Inventory / NPC Inspector + Shop Remote Sniffer
    - Toggle UI: F5
    - Tombol:
        • View Held Item
        • View Inventory Items
        • View Nearest NPC
        • Capture Next Buy Remote (5s)

    Catatan:
    - Sniffer hook __namecall untuk FireServer/InvokeServer (perlu executor yang mendukung).
    - Saat Capture aktif, interaksikan NPC/tombol beli → payload pertama akan ditangkap (remote, args, id).
]]

-- ========= SERVICES =========
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========= SAFE UI PARENT =========
local function getUiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return game:FindFirstChildOfClass("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
end

-- ========= UI HELPERS =========
local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function makeBtn(parent, text, size, pos)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos or UDim2.new()
    b.BackgroundColor3 = Color3.fromRGB(0, 90, 140)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 8)
    return b
end

local function makeRow(parent, h)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, h)
    f.BackgroundColor3 = Color3.fromRGB(38,38,42)
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 8)
    return f
end

-- ========= ID EXTRACTORS =========
local function extractIds(s)
    local ids = {}
    if type(s) ~= "string" then return ids end
    for num in s:gmatch("rbxassetid://(%d+)") do table.insert(ids, num) end
    for num in s:gmatch("[?&]id=(%d+)") do table.insert(ids, num) end
    for num in s:gmatch("(%d%d%d%d%d%d+)") do table.insert(ids, num) end -- fallback 6+ digit
    return ids
end

local CONTENT_PROPS = {
    "MeshId","TextureID","TextureId","AnimationId","SoundId","Graphic","Texture",
    "ShirtTemplate","PantsTemplate",
}

local function scanInstanceForAssetIds(inst)
    local found = {}
    local function tryValue(val)
        local ok, v = pcall(function() return tostring(val) end)
        if ok and v and #v > 0 then
            for _, id in ipairs(extractIds(v)) do
                found[id] = true
            end
        end
    end
    for _, prop in ipairs(CONTENT_PROPS) do
        if inst[prop] ~= nil then tryValue(inst[prop]) end
    end
    if inst:IsA("Decal") and inst.Texture then tryValue(inst.Texture) end
    if inst:IsA("Texture") and inst.Texture then tryValue(inst.Texture) end
    if inst:IsA("SpecialMesh") and inst.MeshId then tryValue(inst.MeshId) end
    if inst:IsA("MeshPart") then
        tryValue(inst.MeshId); tryValue(inst.TextureID)
    end
    for _, name in ipairs(inst:GetAttributes()) do
        tryValue(inst:GetAttribute(name))
    end
    return found
end

local function collectAssetIds(root)
    local bag = {}
    for id in pairs(scanInstanceForAssetIds(root)) do bag[id] = true end
    for _, d in ipairs(root:GetDescendants()) do
        for id in pairs(scanInstanceForAssetIds(d)) do bag[id] = true end
    end
    local list = {}
    for id in pairs(bag) do table.insert(list, id) end
    table.sort(list, function(a,b) return tonumber(a) < tonumber(b) end)
    return list
end

-- ========= DATA GATHERERS =========
local function getToolAssetId(tool)
    local id = rawget(tool, "AssetId") and tool.AssetId or nil
    return id and tostring(id) or "N/A"
end

local function getHeldInfo()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return "Held Tool: None" end
    local ids = collectAssetIds(tool)
    local lines = { ("Held Tool: %s (%s)"):format(tool.Name, tool.ClassName) }
    local fallbackId = getToolAssetId(tool)
    if fallbackId ~= "N/A" then table.insert(lines, "Tool.AssetId: "..fallbackId) end
    if #ids > 0 then
        table.insert(lines, "Detected Asset IDs (Mesh/Texture/etc):")
        for i=1, math.min(#ids, 30) do table.insert(lines, "  - "..ids[i]) end
        if #ids > 30 then table.insert(lines, ("  (+%d more)"):format(#ids-30)) end
    else
        table.insert(lines, "No content-based asset IDs found on this tool.")
    end
    return table.concat(lines, "\n")
end

local function getInventoryInfo()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 2)
    if not backpack then return "Inventory: (Backpack not found)" end
    local lines = {"Inventory Items:"}
    local count = 0
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            count += 1
            local ids = collectAssetIds(item)
            local fallbackId = getToolAssetId(item)
            table.insert(lines, ("%d) %s — %d ids%s"):format(
                count, item.Name, #ids, (fallbackId~="N/A" and (" | Tool.AssetId: "..fallbackId) or "")
            ))
            for j=1, math.min(#ids, 10) do table.insert(lines, "     • "..ids[j]) end
            if #ids > 10 then table.insert(lines, "     • ...") end
        end
    end
    if count == 0 then table.insert(lines, "(empty)") end
    return table.concat(lines, "\n")
end

local function getNearestNPCInfo()
    local char = LocalPlayer.Character
    if not char then return "Nearest NPC: None" end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return "Nearest NPC: None" end

    local bestModel, bestDist = nil, math.huge
    for _, mdl in ipairs(workspace:GetDescendants()) do
        if mdl:IsA("Model") then
            local hasHumanoid = mdl:FindFirstChildOfClass("Humanoid")
            local hasPrompt = mdl:FindFirstChildWhichIsA("ProximityPrompt", true)
            local isPlayerChar = hasHumanoid and hasHumanoid.Parent and Players:GetPlayerFromCharacter(hasHumanoid.Parent) ~= nil
            if (hasHumanoid or hasPrompt) and not isPlayerChar then
                local hrp = mdl:FindFirstChild("HumanoidRootPart") or mdl.PrimaryPart
                if hrp and hrp:IsA("BasePart") then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d < bestDist then bestDist, bestModel = d, mdl end
                end
            end
        end
    end
    if not bestModel then return "Nearest NPC: None" end
    local ids = collectAssetIds(bestModel)
    local lines = {
        ("Nearest NPC: %s (%.1f studs)"):format(bestModel.Name, bestDist),
        ("Parts: %d • Asset IDs found: %d"):format(#bestModel:GetDescendants(), #ids),
    }
    for i=1, math.min(#ids, 20) do table.insert(lines, "  - "..ids[i]) end
    if #ids > 20 then table.insert(lines, ("  (+%d more)"):format(#ids-20)) end
    return table.concat(lines, "\n")
end

-- ========= REMOTE SNIFFER =========
local hookEnabled = false
local oldNamecall
local outputBox -- forward ref

local function stringify(v, depth)
    depth = depth or 0
    if depth > 2 then return "<…>" end
    local t = typeof(v)
    if t == "string" then
        if #v > 200 then return v:sub(1,200).."…("..#v..")" end
        return v
    elseif t == "number" or t == "boolean" then
        return tostring(v)
    elseif t == "Instance" then
        return v:GetFullName()
    elseif t == "table" then
        local parts, n = {}, 0
        for k,val in pairs(v) do
            n += 1; if n>10 then table.insert(parts,"…"); break end
            table.insert(parts, "["..stringify(k,depth+1).."]="..stringify(val,depth+1))
        end
        return "{"..table.concat(parts,", ").."}"
    else
        local ok,s = pcall(tostring,v); return ok and s or ("<"..t..">")
    end
end

local function extractIdsFromAny(x, bag)
    bag = bag or {}
    local function pushFromString(s)
        if not s or type(s)~="string" then return end
        for id in s:gmatch("rbxassetid://(%d+)") do bag[id]=true end
        for id in s:gmatch("[?&]id=(%d+)") do bag[id]=true end
        for id in s:gmatch("(%d%d%d%d%d%d+)") do bag[id]=true end
    end
    local t = typeof(x)
    if t=="string" then
        pushFromString(x)
    elseif t=="table" then
        for k,v in pairs(x) do extractIdsFromAny(k,bag); extractIdsFromAny(v,bag) end
    elseif t=="Instance" then
        for _,id in ipairs(collectAssetIds(x)) do bag[id]=true end
    else
        local ok,s = pcall(tostring,x); if ok then pushFromString(s) end
    end
    return bag
end

local function startCapture(windowSec)
    windowSec = windowSec or 5
    if hookEnabled then
        return "Capture already running."
    end

    -- safety: executor API needed
    if not getrawmetatable or not newcclosure or not getnamecallmethod then
        return "Executor tidak mendukung hook __namecall."
    end

    local mt = getrawmetatable(game)
    local setro = setreadonly or make_writeable
    setro(mt,false)
    local __namecall = mt.__namecall
    oldNamecall = oldNamecall or __namecall
    hookEnabled = true

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if hookEnabled and typeof(self)=="Instance" and (method=="FireServer" or method=="InvokeServer") then
            -- Ambil hanya event pertama selama window aktif
            hookEnabled = false
            local args = {...}

            local bag = extractIdsFromAny(args,{})
            local ids = {}
            for id in pairs(bag) do table.insert(ids,id) end
            table.sort(ids,function(a,b) return tonumber(a)<tonumber(b) end)

            local path
            pcall(function() path = self:GetFullName() end)

            local lines = {
                ">> CAPTURED REMOTE <<",
                "Method : "..method,
                "Remote : "..self.Name,
                "Path   : "..(path or "<unknown>"),
                "Args   : "..stringify(args),
                "IDs    : "..(#ids>0 and table.concat(ids,", ") or "(none)")
            }
            if outputBox then outputBox.Text = table.concat(lines,"\n") end
            pcall(function() setclipboard(table.concat(lines,"\n")) end)

            -- restore hook
            mt.__namecall = oldNamecall
            setro(mt,true)
            -- continue original call
            return oldNamecall(self, ...)
        end
        return oldNamecall(self, ...)
    end)
    setro(mt,true)

    -- auto time-out (restore) jika tak ada event
    task.spawn(function()
        task.wait(windowSec)
        if hookEnabled then
            local mt2 = getrawmetatable(game); (setreadonly or make_writeable)(mt2,false)
            mt2.__namecall = oldNamecall
            (setreadonly or make_writeable)(mt2,true)
            hookEnabled = false
            if outputBox then
                outputBox.Text = (outputBox.Text.."\n\n[Capture timed out]"):sub(-6000)
            end
        end
    end)

    return "Capturing next remote for "..windowSec.."s… Interact with the NPC/shop now."
end

-- ========= UI BUILD =========
local ScreenGui, Main

local function buildUI()
    local parent = getUiParent()
    local old = parent:FindFirstChild("PB_ItemsNPC_UI")
    if old then old:Destroy() end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PB_ItemsNPC_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent

    Main = Instance.new("Frame")
    Main.Size = UDim2.new(0.6, 0, 0.6, 0)
    Main.Position = UDim2.new(0.2, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    corner(Main, 12)

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -40, 0, 36)
    header.Position = UDim2.new(0, 20, 0, 16)
    header.BackgroundTransparency = 1
    header.Text = "Asset / Inventory / NPC Inspector + Shop Remote Sniffer"
    header.TextColor3 = Color3.fromRGB(255,255,255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Font = Enum.Font.GothamBold
    header.TextSize = 18
    header.Parent = Main

    local closeBtn = makeBtn(Main, "X", UDim2.fromOffset(28,28), UDim2.new(1,-36,0,18))
    closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Buttons bar
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 44)
    bar.Position = UDim2.new(0, 10, 0, 60)
    bar.BackgroundTransparency = 1
    bar.Parent = Main

    local btnHeld = makeBtn(bar, "View Held Item", UDim2.fromOffset(160, 36), UDim2.new(0,0,0,0))
    local btnInv  = makeBtn(bar, "View Inventory Items", UDim2.fromOffset(200, 36), UDim2.new(0,170,0,0))
    local btnNPC  = makeBtn(bar, "View Nearest NPC", UDim2.fromOffset(180, 36), UDim2.new(0,380,0,0))
    local btnCap  = makeBtn(bar, "Capture Next Buy Remote (5s)", UDim2.fromOffset(240, 36), UDim2.new(0,570,0,0))

    -- Output area
    local outRow = makeRow(Main, Main.Size.Y.Offset - 120)
    outRow.Size = UDim2.new(1, -20, 1, -120)
    outRow.Position = UDim2.new(0, 10, 0, 106)

    outputBox = Instance.new("TextLabel")
    outputBox.Size = UDim2.new(1, -20, 1, -20)
    outputBox.Position = UDim2.new(0, 10, 0, 10)
    outputBox.BackgroundColor3 = Color3.fromRGB(28,28,32)
    outputBox.BorderSizePixel = 0
    outputBox.TextXAlignment = Enum.TextXAlignment.Left
    outputBox.TextYAlignment = Enum.TextYAlignment.Top
    outputBox.Font = Enum.Font.Code
    outputBox.TextSize = 14
    outputBox.TextColor3 = Color3.fromRGB(230,230,230)
    outputBox.Text = "Klik salah satu tombol di atas."
    outputBox.Parent = outRow
    corner(outputBox, 8)

    -- Drag window
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Button callbacks
    btnHeld.MouseButton1Click:Connect(function()
        local ok, res = pcall(getHeldInfo)
        outputBox.Text = ok and res or ("[Error Held]\n"..tostring(res))
    end)
    btnInv.MouseButton1Click:Connect(function()
        local ok, res = pcall(getInventoryInfo)
        outputBox.Text = ok and res or ("[Error Inventory]\n"..tostring(res))
    end)
    btnNPC.MouseButton1Click:Connect(function()
        local ok, res = pcall(getNearestNPCInfo)
        outputBox.Text = ok and res or ("[Error NPC]\n"..tostring(res))
    end)
    btnCap.MouseButton1Click:Connect(function()
        local msg = startCapture(5)
        outputBox.Text = msg
    end)
end

-- ========= BOOT & TOGGLE =========
local function boot()
    if not Players.LocalPlayer:FindFirstChild("PlayerGui") then
        Players.LocalPlayer.CharacterAdded:Wait()
        Players.LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    buildUI()
end

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F5 then
        local parent = getUiParent()
        local ui = parent:FindFirstChild("PB_ItemsNPC_UI")
        if ui then ui:Destroy() else boot() end
    end
end)

boot()
