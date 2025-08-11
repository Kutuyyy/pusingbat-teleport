local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Fungsi aman untuk membuat UI (kompatibel dengan Delta iOS)
local function createSafeUI()
    -- Cek apakah PlayerGui sudah ada
    if not player:FindFirstChild("PlayerGui") then
        repeat wait() until player:FindFirstChild("PlayerGui")
    end
    
    -- Hapus UI lama jika ada
    if player.PlayerGui:FindFirstChild("AssetTrackerUI") then
        player.PlayerGui.AssetTrackerUI:Destroy()
    end
    
    -- Buat UI sederhana yang kompatibel dengan iOS
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AssetTrackerUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player.PlayerGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0.8, 0, 0.6, 0) -- Ukuran lebih besar untuk mobile
    MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BackgroundTransparency = 0.3
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Tambahkan komponen UI sederhana (sesuaikan dengan kebutuhan)
    local Title = Instance.new("TextLabel")
    Title.Text = "ASSET TRACKER (iOS)"
    Title.Size = UDim2.new(1, 0, 0.1, 0)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextColor3 = Color3.white
    Title.BackgroundTransparency = 1
    Title.Parent = MainFrame
    
    -- Output textbox
    local Output = Instance.new("TextLabel")
    Output.Name = "Output"
    Output.Size = UDim2.new(0.9, 0, 0.8, 0)
    Output.Position = UDim2.new(0.05, 0, 0.15, 0)
    Output.Text = "Loading data..."
    Output.TextXAlignment = Enum.TextXAlignment.Left
    Output.TextYAlignment = Enum.TextYAlignment.Top
    Output.TextWrapped = true
    Output.Font = Enum.Font.SourceSans
    Output.TextColor3 = Color3.white
    Output.BackgroundTransparency = 1
    Output.Parent = MainFrame
    
    return ScreenGui, Output
end

-- Fungsi untuk update data
local function updateData(outputLabel)
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- Info tool yang dipegang
    local heldTool = character:FindFirstChildOfClass("Tool")
    local heldText = heldTool and ("Held: "..heldTool.Name.." (ID: "..(heldTool.AssetId or "N/A")..")") or "No tool equipped"
    
    -- Info inventory
    local inventoryText = ""
    for _, item in ipairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            inventoryText = inventoryText .. item.Name .. " (ID: "..(item.AssetId or "N/A")..")\n"
        end
    end
    
    -- Info NPC (versi sederhana untuk iOS)
    local npcText = "No NPC detected"
    for _, part in ipairs(workspace:GetChildren()) do
        if part:FindFirstChildWhichIsA("ProximityPrompt") then
            npcText = "Near: "..part.Name
            break
        end
    end
    
    outputLabel.Text = heldText.."\n\nInventory:\n"..(inventoryText ~= "" and inventoryText or "Empty").."\n\n"..npcText
end

-- Main execution
local success, err = pcall(function()
    local ui, output = createSafeUI()
    
    -- Update pertama
    updateData(output)
    
    -- Auto-update setiap 2 detik (lebih stabil untuk iOS)
    while true do
        wait(2)
        updateData(output)
    end
end)

if not success then
    print("Error in script:", err)
end
