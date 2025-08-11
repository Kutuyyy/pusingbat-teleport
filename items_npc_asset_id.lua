local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ====== UI CREATION ======
local function createUI()
    -- Pastikan PlayerGui ada
    if not player:FindFirstChild("PlayerGui") then
        repeat task.wait() until player:FindFirstChild("PlayerGui")
    end
    
    -- Hapus UI lama jika ada
    if player.PlayerGui:FindFirstChild("AssetTrackerUI") then
        player.PlayerGui.AssetTrackerUI:Destroy()
    end
    
    -- Buat ScreenGui utama
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AssetTrackerUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = player.PlayerGui
    
    -- Frame utama
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
    MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Tambahkan UICorner untuk estetika
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Judul
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = "ASSET TRACKER"
    Title.Size = UDim2.new(1, 0, 0.1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Parent = MainFrame
    
    -- Section untuk Tool yang dipegang
    local HeldItemSection = createSection("Held Tool:", MainFrame, 0.15)
    local HeldItemValue = HeldItemSection.Value
    
    -- Section untuk Inventory
    local InventorySection = createSection("Inventory Items:", MainFrame, 0.3)
    local InventoryScrollingFrame = Instance.new("ScrollingFrame")
    InventoryScrollingFrame.Name = "InventoryScrollingFrame"
    InventoryScrollingFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
    InventoryScrollingFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    InventoryScrollingFrame.BackgroundTransparency = 1
    InventoryScrollingFrame.ScrollBarThickness = 5
    InventoryScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    InventoryScrollingFrame.Parent = InventorySection
    
    -- Section untuk NPC
    local NPCSection = createSection("Current NPC:", MainFrame, 0.85)
    local NPCValue = NPCSection.Value
    
    -- Tombol tutup
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    CloseButton.Position = UDim2.new(0.9, 0, 0, 0)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Parent = MainFrame
    
    -- Fungsi untuk update UI
    local function updateUI()
        -- Update tool yang dipegang
        local character = player.Character or player.CharacterAdded:Wait()
        local tool = character:FindFirstChildOfClass("Tool")
        HeldItemValue.Text = tool and (tool.Name .. " (ID: " .. (tool.AssetId or "N/A") .. ")") or "None"
        
        -- Update inventory
        InventoryScrollingFrame:ClearAllChildren()
        local yOffset = 0
        local itemHeight = 20
        for _, item in ipairs(player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                local itemLabel = Instance.new("TextLabel")
                itemLabel.Text = item.Name .. ": " .. (item.AssetId or "N/A")
                itemLabel.Size = UDim2.new(1, 0, 0, itemHeight)
                itemLabel.Position = UDim2.new(0, 0, 0, yOffset)
                itemLabel.Font = Enum.Font.Gotham
                itemLabel.TextSize = 14
                itemLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                itemLabel.BackgroundTransparency = 1
                itemLabel.TextXAlignment = Enum.TextXAlignment.Left
                itemLabel.Parent = InventoryScrollingFrame
                
                yOffset = yOffset + itemHeight
            end
        end
        InventoryScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
        
        -- Update NPC
        local closestNPC = findClosestNPC()
        NPCValue.Text = closestNPC or "None"
    end
    
    -- Fungsi pembantu untuk membuat section
    function createSection(title, parent, yPosition)
        local section = Instance.new("Frame")
        section.Name = title .. "Section"
        section.Size = UDim2.new(0.9, 0, 0.2, 0)
        section.Position = UDim2.new(0.05, 0, yPosition, 0)
        section.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        section.BorderSizePixel = 0
        section.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Name = title .. "Label"
        label.Text = title
        label.Size = UDim2.new(0.4, 0, 0.3, 0)
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = section
        
        local value = Instance.new("TextLabel")
        value.Name = title .. "Value"
        value.Text = "Loading..."
        value.Size = UDim2.new(0.6, 0, 0.3, 0)
        value.Position = UDim2.new(0.4, 0, 0, 0)
        value.Font = Enum.Font.Gotham
        value.TextSize = 16
        value.TextColor3 = Color3.fromRGB(255, 255, 255)
        value.BackgroundTransparency = 1
        value.TextXAlignment = Enum.TextXAlignment.Right
        value.Parent = section
        
        return {
            Frame = section,
            Label = label,
            Value = value
        }
    end
    
    -- Fungsi untuk menemukan NPC terdekat
    local function findClosestNPC()
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
        
        local closestNPC = nil
        local closestDistance = math.huge
        local rootPart = character.HumanoidRootPart
        
        for _, npc in ipairs(workspace:GetChildren()) do
            if npc:FindFirstChildWhichIsA("ProximityPrompt") and npc:FindFirstChild("HumanoidRootPart") then
                local distance = (npc.HumanoidRootPart.Position - rootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestNPC = npc.Name
                end
            end
        end
        
        return closestDistance < 20 and closestNPC or nil
    end
    
    -- Event listeners
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Drag functionality
    local dragging = false
    local dragStart
    local startPos
    
    Title.InputBegan:Connect(function(input)
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
    
    -- Update UI secara berkala
    RunService.Heartbeat:Connect(function()
        pcall(updateUI)
    end)
    
    return ScreenGui
end

-- ====== INITIALIZATION ======
-- Loading screen
local function createLoadingScreen()
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "LoadingScreen"
    loadingGui.ResetOnSpawn = false
    loadingGui.Parent = player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.Parent = loadingGui
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0.1, 0)
    text.Position = UDim2.new(0, 0, 0.45, 0)
    text.Text = "Asset Tracker Loading..."
    text.Font = Enum.Font.GothamBold
    text.TextSize = 24
    text.TextColor3 = Color3.new(1, 1, 1)
    text.BackgroundTransparency = 1
    text.Parent = frame
    
    task.delay(3, function()
        loadingGui:Destroy()
        createUI()
    end)
end

-- Mulai script
if player.PlayerGui then
    createLoadingScreen()
else
    player.CharacterAdded:Connect(function()
        createLoadingScreen()
    end)
end

-- Toggle UI dengan tombol (jika didukung)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F5 and not gameProcessed then
        if player.PlayerGui:FindFirstChild("AssetTrackerUI") then
            player.PlayerGui.AssetTrackerUI:Destroy()
        else
            createUI()
        end
    end
end)
