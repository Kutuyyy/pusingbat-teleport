local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Buat ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AssetTrackerUI"
ScreenGui.Parent = player.PlayerGui

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.3, 0, 0.4, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Judul
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "ASSET TRACKER"
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

-- Section untuk Tool yang dipegang
local HeldItemSection = Instance.new("Frame")
HeldItemSection.Name = "HeldItemSection"
HeldItemSection.Size = UDim2.new(0.9, 0, 0.2, 0)
HeldItemSection.Position = UDim2.new(0.05, 0, 0.15, 0)
HeldItemSection.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
HeldItemSection.BorderSizePixel = 0
HeldItemSection.Parent = MainFrame

local HeldItemLabel = Instance.new("TextLabel")
HeldItemLabel.Name = "HeldItemLabel"
HeldItemLabel.Text = "Held Tool:"
HeldItemLabel.Size = UDim2.new(0.4, 0, 1, 0)
HeldItemLabel.Font = Enum.Font.Gotham
HeldItemLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
HeldItemLabel.BackgroundTransparency = 1
HeldItemLabel.TextXAlignment = Enum.TextXAlignment.Left
HeldItemLabel.Parent = HeldItemSection

local HeldItemValue = Instance.new("TextLabel")
HeldItemValue.Name = "HeldItemValue"
HeldItemValue.Text = "None"
HeldItemValue.Size = UDim2.new(0.6, 0, 1, 0)
HeldItemValue.Position = UDim2.new(0.4, 0, 0, 0)
HeldItemValue.Font = Enum.Font.GothamBold
HeldItemValue.TextColor3 = Color3.fromRGB(255, 255, 255)
HeldItemValue.BackgroundTransparency = 1
HeldItemValue.TextXAlignment = Enum.TextXAlignment.Right
HeldItemValue.Parent = HeldItemSection

-- Section untuk Inventory Items
local InventorySection = Instance.new("Frame")
InventorySection.Name = "InventorySection"
InventorySection.Size = UDim2.new(0.9, 0, 0.4, 0)
InventorySection.Position = UDim2.new(0.05, 0, 0.4, 0)
InventorySection.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
InventorySection.BorderSizePixel = 0
InventorySection.Parent = MainFrame

local InventoryLabel = Instance.new("TextLabel")
InventoryLabel.Name = "InventoryLabel"
InventoryLabel.Text = "Inventory Items:"
InventoryLabel.Size = UDim2.new(1, 0, 0.15, 0)
InventoryLabel.Font = Enum.Font.Gotham
InventoryLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InventoryLabel.BackgroundTransparency = 1
InventoryLabel.TextXAlignment = Enum.TextXAlignment.Left
InventoryLabel.Parent = InventorySection

local InventoryScrollingFrame = Instance.new("ScrollingFrame")
InventoryScrollingFrame.Name = "InventoryScrollingFrame"
InventoryScrollingFrame.Size = UDim2.new(1, 0, 0.85, 0)
InventoryScrollingFrame.Position = UDim2.new(0, 0, 0.15, 0)
InventoryScrollingFrame.BackgroundTransparency = 1
InventoryScrollingFrame.ScrollBarThickness = 5
InventoryScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
InventoryScrollingFrame.Parent = InventorySection

-- Section untuk NPC yang diajak bicara
local NPCSection = Instance.new("Frame")
NPCSection.Name = "NPCSection"
NPCSection.Size = UDim2.new(0.9, 0, 0.2, 0)
NPCSection.Position = UDim2.new(0.05, 0, 0.85, 0)
NPCSection.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
NPCSection.BorderSizePixel = 0
NPCSection.Parent = MainFrame

local NPCLabel = Instance.new("TextLabel")
NPCLabel.Name = "NPCLabel"
NPCLabel.Text = "Current NPC:"
NPCLabel.Size = UDim2.new(0.4, 0, 1, 0)
NPCLabel.Font = Enum.Font.Gotham
NPCLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
NPCLabel.BackgroundTransparency = 1
NPCLabel.TextXAlignment = Enum.TextXAlignment.Left
NPCLabel.Parent = NPCSection

local NPCValue = Instance.new("TextLabel")
NPCValue.Name = "NPCValue"
NPCValue.Text = "None"
NPCValue.Size = UDim2.new(0.6, 0, 1, 0)
NPCValue.Position = UDim2.new(0.4, 0, 0, 0)
NPCValue.Font = Enum.Font.GothamBold
NPCValue.TextColor3 = Color3.fromRGB(255, 255, 255)
NPCValue.BackgroundTransparency = 1
NPCValue.TextXAlignment = Enum.TextXAlignment.Right
NPCValue.Parent = NPCSection

-- Fungsi untuk update UI
local function updateHeldItem()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        HeldItemValue.Text = tostring(tool.AssetId) or "No Asset ID"
    else
        HeldItemValue.Text = "None"
    end
end

local function updateInventory()
    -- Clear existing items
    for _, child in ipairs(InventoryScrollingFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    -- Add new items
    local yOffset = 0
    local itemHeight = 20
    for _, item in ipairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local itemLabel = Instance.new("TextLabel")
            itemLabel.Text = item.Name .. ": " .. tostring(item.AssetId or "No ID")
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
end

local function updateNPC()
    -- Deteksi ProximityPrompt yang sedang aktif
    local closestPrompt = nil
    local closestDistance = math.huge
    
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local distance = (prompt.Parent.Position - character.HumanoidRootPart.Position).Magnitude
            if distance < prompt.MaxActivationDistance and distance < closestDistance then
                closestPrompt = prompt
                closestDistance = distance
            end
        end
    end
    
    if closestPrompt then
        NPCValue.Text = closestPrompt.Parent.Name
    else
        NPCValue.Text = "None"
    end
end

-- Event listeners
character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        updateHeldItem()
    end
end)

character.ChildRemoved:Connect(function(child)
    if child:IsA("Tool") then
        updateHeldItem()
    end
end)

player.Backpack.ChildAdded:Connect(updateInventory)
player.Backpack.ChildRemoved:Connect(updateInventory)

-- Update secara berkala untuk NPC
game:GetService("RunService").Heartbeat:Connect(updateNPC)

-- Inisialisasi pertama
updateHeldItem()
updateInventory()
updateNPC()

-- Toggle UI dengan tombol (contoh: F5)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F5 and not gameProcessed then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
