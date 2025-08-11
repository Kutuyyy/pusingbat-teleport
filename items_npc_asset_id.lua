-- Pusingbat Hub — Minimal UI + Assets Tab (Held/Inventory/NPC)
-- Works in Studio (LocalScript) and executors (Delta). No Rayfield required.

-- ========== Services ==========
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ========== Safe UI Parent (executor-friendly) ==========
local function getUiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local core = game:FindFirstChildOfClass("CoreGui")
    if core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- ========== Helpers (data) ==========
local function getToolAssetId(tool)
    local id = rawget(tool, "AssetId") and tool.AssetId or nil
    return id and tostring(id) or "N/A"
end

local function getHeldInfo()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return "Held Tool: None" end
    return ("Held Tool: %s\nAsset ID: %s"):format(tool.Name, getToolAssetId(tool))
end

local function getInventoryInfo()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 2)
    if not backpack then return "Inventory: (Backpack not found)" end
    local lines, n = {"Inventory Items:"}, 0
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            n += 1
            table.insert(lines, ("%d) %s — ID: %s"):format(n, item.Name, getToolAssetId(item)))
        end
    end
    if n == 0 then table.insert(lines, "(empty)") end
    return table.concat(lines, "\n")
end

local function getNearestNPCInfo()
    local char = LocalPlayer.Character
    if not char then return "Nearest NPC: None" end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return "Nearest NPC: None" end

    local bestName, bestDist = nil, math.huge
    for _, m in ipairs(workspace:GetChildren()) do
        local hrp = m:FindFirstChild("HumanoidRootPart")
        local hasPrompt = m:FindFirstChildWhichIsA("ProximityPrompt")
        if hrp and hasPrompt then
            local d = (hrp.Position - root.Position).Magnitude
            if d < bestDist then
                bestDist, bestName = d, m.Name
            end
        end
    end
    return bestName and ("Nearest NPC: %s (%.1f studs)"):format(bestName, bestDist) or "Nearest NPC: None"
end

-- ========== UI Factory ==========
local function makeCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
    return c
end

local function makeButton(parent, text, sizeUDim2, posUDim2)
    local b = Instance.new("TextButton")
    b.Size = sizeUDim2
    b.Position = posUDim2 or UDim2.new()
    b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    b.TextColor3 = Color3.fromRGB(235, 235, 235)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.AutoButtonColor = true
    b.BorderSizePixel = 0
    b.Parent = parent
    makeCorner(b, 8)
    return b
end

local function makeScroll(parent)
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1, -16, 1, -88)
    s.Position = UDim2.new(0, 8, 0, 78)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.CanvasSize = UDim2.new(0,0,0,0)
    s.ScrollBarThickness = 6
    s.Visible = false
    s.Parent = parent
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = s
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 20)
    end)
    return s
end

local function makeRow(parent, h)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, h)
    row.BackgroundColor3 = Color3.fromRGB(38,38,42)
    row.BackgroundTransparency = 0.2
    row.BorderSizePixel = 0
    row.Parent = parent
    makeCorner(row, 8)
    return row
end

-- ========== Create UI ==========
local ScreenGui, MainFrame
local tabs = {}
local pages = {}
local outputLabel -- used by Assets tab

local function showTab(key)
    for k, page in pairs(pages) do
        page.Visible = (k == key)
    end
end

local function createUI()
    -- Clean old
    local parent = getUiParent()
    local old = parent:FindFirstChild("PusingbatUI")
    if old then old:Destroy() end

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PusingbatUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = parent

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0.6, 0, 0.6, 0)
    MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    makeCorner(MainFrame, 12)

    -- Header
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -40, 0, 36)
    header.Position = UDim2.new(0, 20, 0, 16)
    header.BackgroundTransparency = 1
    header.Text = "Pusingbat Hub"
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Font = Enum.Font.GothamBold
    header.TextSize = 20
    header.Parent = MainFrame

    -- Close
    local closeBtn = makeButton(MainFrame, "X", UDim2.fromOffset(28, 28), UDim2.new(1, -36, 0, 18))
    closeBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Tabs bar container
    local tabsBar = Instance.new("Frame")
    tabsBar.Size = UDim2.new(1, -16, 0, 28)
    tabsBar.Position = UDim2.new(0, 8, 0, 56)
    tabsBar.BackgroundTransparency = 1
    tabsBar.Parent = MainFrame

    -- Create 5 tabs: Main, Misc, Teleport, Config, Assets
    local tabNames = {"Main","Misc","Teleport","Config","Assets"}
    local x = 0
    for i, name in ipairs(tabNames) do
        local b = makeButton(tabsBar, name, UDim2.fromOffset(110, 28), UDim2.new(0, x, 0, 0))
        tabs[name] = b
        x = x + 116
    end

    -- Pages (ScrollingFrames)
    for _, name in ipairs(tabNames) do
        pages[name] = makeScroll(MainFrame)
    end

    -- Placeholder rows for non-assets tabs (optional)
    for _, name in ipairs({"Main","Misc","Teleport","Config"}) do
        local row = makeRow(pages[name], 40)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 1, -10)
        lbl.Position = UDim2.new(0, 10, 0, 5)
        lbl.BackgroundTransparency = 1
        lbl.Text = name .. " tab (placeholder)"
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
    end

    -- ===================== ASSETS TAB =====================
    local assetsPage = pages["Assets"]

    local function makeActionButton(text, callback)
        local r = makeRow(assetsPage, 40)
        local b = makeButton(r, text, UDim2.new(1, -20, 1, -10), UDim2.new(0, 10, 0, 5))
        b.BackgroundColor3 = Color3.fromRGB(0, 90, 140)
        b.MouseButton1Click:Connect(function() task.spawn(callback) end)
    end

    -- Output box
    do
        local r = makeRow(assetsPage, 220)
        local bg = Instance.new("TextLabel")
        bg.Size = UDim2.new(1, -20, 1, -20)
        bg.Position = UDim2.new(0, 10, 0, 10)
        bg.BackgroundColor3 = Color3.fromRGB(28,28,32)
        bg.TextXAlignment = Enum.TextXAlignment.Left
        bg.TextYAlignment = Enum.TextYAlignment.Top
        bg.TextWrapped = false
        bg.Text = "Output will appear here."
        bg.Font = Enum.Font.Code
        bg.TextSize = 14
        bg.TextColor3 = Color3.fromRGB(230,230,230)
        bg.BorderSizePixel = 0
        bg.Parent = r
        makeCorner(bg, 8)
        outputLabel = bg
    end

    local function setOutput(txt)
        outputLabel.Text = txt
    end

    makeActionButton("View Held Item", function()
        setOutput(getHeldInfo())
    end)

    makeActionButton("View Inventory Items", function()
        setOutput(getInventoryInfo())
    end)

    makeActionButton("View Nearest NPC", function()
        setOutput(getNearestNPCInfo())
    end)

    -- Tab switching
    local function bindTab(btn, key)
        btn.MouseButton1Click:Connect(function() showTab(key) end)
    end
    for name, btn in pairs(tabs) do bindTab(btn, name) end
    showTab("Assets") -- default open Assets; ganti "Main" kalau mau

    -- Drag window
    local dragging, dragStart, startPos = false, nil, nil
    local dragArea = header
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ========== Boot ==========
local function boot()
    -- wait PlayerGui only if needed
    if not LocalPlayer:FindFirstChild("PlayerGui") then
        LocalPlayer.CharacterAdded:Wait()
        LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    createUI()
end

-- Toggle with F5
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        local parent = getUiParent()
        local ui = parent:FindFirstChild("PusingbatUI")
        if ui then
            ui:Destroy()
        else
            boot()
        end
    end
end)

-- Auto-start first time
boot()
