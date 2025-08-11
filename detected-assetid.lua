local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Cek inventory (Backpack)
player.Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        print("[Backpack] Item ID:", child.AssetId)
    end
end)

-- Cek Tool yang sedang dipegang (Character)
player.CharacterAdded:Connect(function(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            print("[Character] Item ID:", child.AssetId)
        end
    end)
end)
