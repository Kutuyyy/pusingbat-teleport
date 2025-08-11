-- items_npc_asset_id.lua — Pusingbat Minimal UI + Asset/NPC Inspector (robust)
-- Toggle UI: F5

-- ========= SERVICES =========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ========= SAFE UI PARENT =========
local function getUiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return game:FindFirstChildOfClass("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
end

-- ========= UTILS =========
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

-- Ambil angka dari content-id (rbxassetid://, http, dll)
local function extractIds(s)
    local ids = {}
    if type(s) ~= "string" then return ids end
    -- rbxassetid://123456789
    for num in s:gmatch("rbxassetid://(%d+)") do table.insert(ids, num) end
    -- http(s)://.../?id=123456789
    for num in s:gmatch("[?&]id=(%d+)") do table.insert(ids, num) end
    -- fallback: angka panjang berdiri sendiri (hindari angka kecil)
    for num in s:gmatch("(%d%d%d%d%d%d+)") do table.insert(ids, num) end
    return ids
end

-- Scan instance & descendants untuk content-id umum
local CONTENT_PROPS = {
    "MeshId","TextureID","TextureId","AnimationId","SoundId","Graphic","Texture",
    "Face","ShirtTemplate","PantsTemplate","HeadMesh","OverlayTextureId","NormalMap",
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
        if inst[prop] ~= nil then
            tryValue(inst[prop])
        end
    end
    -- Special cases
    if inst:IsA("Decal") and inst.Texture then tryValue(inst.Texture) end
    if inst:IsA("Texture") and inst.Texture then tryValue(inst.Texture) end
    if inst:IsA("SpecialMesh") and inst.MeshId then tryValue(inst.MeshId) end
    if inst:IsA("MeshPart") then
        tryValue(inst.MeshId)
        tryValue(inst.TextureID)
    end
    if inst:IsA("FaceInstance") and inst.Texture then tryValue(inst.Texture) end
    -- Attributes sometimes store ids
    for _, name in ipairs(inst:GetAttributes()) do
        tryValue(inst:GetAttribute(name))
    end
    return found
end

local function collectAssetIds(root)
    local bag = {}
    -- scan root
    for id in pairs(scanInstanceForAssetIds(root)) do bag[id] = true end
    -- scan descendants
    for _, d in ipairs(root:GetDescendants()) do
        for id in pairs(scanInstanceForAssetIds(d)) do
            bag[id] = true
        end
    end
    local list = {}
    for id in pairs(bag) do table.insert(list, id) end
    table.sort(list, function(a,b) return tonumber(a) < tonumber(b) end)
    return list
end

-- ========= DATA GATHERERS =========
local function getHeldInfo()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return "Held Tool: None" end
    local ids = collectAssetIds(tool)
    local lines = {
        ("Held Tool: %s (%s)"):format(tool.Name, tool.ClassName),
    }
    if #ids > 0 then
        table.insert(lines, "Detected Asset IDs (from Mesh/Texture/etc):")
        for i=1, math.min(#ids, 30) do
            table.insert(lines, ("  - %s"):format(ids[i]))
        end
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
            table.insert(lines, ("%d) %s — %s ids"):format(count, item.Name, tostring(#ids)))
            for j=1, math.min(#ids, 10) do
                table.insert(lines, "     • " .. ids[j])
            end
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
            -- pastikan bukan character player
            local isPlayerChar = hasHumanoid and hasHumanoid.Parent and Players:GetPlayerFromCharacter(hasHumanoid.Parent) ~= nil
            if (hasHumanoid or hasPrompt) and not isPlayerChar then
                local hrp = mdl:FindFirstChild("HumanoidRootPart") or mdl.PrimaryPart
                if hrp and hrp:IsA("BasePart") then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d < bestDist then
                        bestDist, bestModel = d, mdl
                    end
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

-- ========= UI =========
local ScreenGui, Main
local outputBox

local function buildUI()
    local parent = getUiParent()
    if parent:FindFirstChild("PB_ItemsNPC_UI") then
        parent.PB_ItemsNPC_UI:Destroy()
    end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PB_ItemsNPC_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent

    Main = Instance.new("Frame")
    Main.Size = UDim2.new(0.55, 0, 0.6, 0)
    Main.Position = UDim2.new(0.225, 0, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    corner(Main, 12)

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -40, 0, 36)
    header.Position = UDim2.new(0, 20, 0, 16)
    header.BackgroundTransparency = 1
    header.Text = "Asset / Inventory / NPC Inspector"
    header.TextColor3 = Color3.fromRGB(255,255,255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Font = Enum.Font.GothamBold
    header.TextSize = 20
    header.Parent = Main

    local closeBtn = makeBtn(Main, "X", UDim2.fromOffset(28,28), UDim2.new(1,-36,0,18))
    closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Buttons row
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 44)
    bar.Position = UDim2.new(0, 10, 0, 60)
    bar.BackgroundTransparency = 1
    bar.Parent = Main

    local btnHeld = makeBtn(bar, "View Held Item", UDim2.fromOffset(160, 36), UDim2.new(0,0,0,0))
    local btnInv  = makeBtn(bar, "View Inventory Items", UDim2.fromOffset(200, 36), UDim2.new(0,170,0,0))
    local btnNPC  = makeBtn(bar, "View Nearest NPC", UDim2.fromOffset(180, 36), UDim2.new(0,380,0,0))

    -- Output
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

    -- Drag
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Button callbacks (pcall biar aman)
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
end

-- ========= BOOT & TOGGLE =========
local function boot()
    if not Players.LocalPlayer:FindFirstChild("PlayerGui") then
        Players.LocalPlayer.CharacterAdded:Wait()
        Players.LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    buildUI()
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.F5 then
        local parent = getUiParent()
        local ui = parent:FindFirstChild("PB_ItemsNPC_UI")
        if ui then ui:Destroy() else boot() end
    end
end)

boot()
