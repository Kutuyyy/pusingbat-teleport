local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LocationSaver"
screenGui.Parent = playerGui

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 350)
mainFrame.Position = UDim2.new(0, 10, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Minimized frame (hidden by default)
local minimizedFrame = Instance.new("Frame")
minimizedFrame.Size = UDim2.new(0, 250, 0, 30)
minimizedFrame.Position = UDim2.new(0, 10, 0.5, -175)
minimizedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minimizedFrame.BorderSizePixel = 0
minimizedFrame.Visible = false
minimizedFrame.Parent = screenGui

-- Make both frames draggable
local function setupDragging(frame, handle)
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Drag handle for main frame
local dragHandle = Instance.new("TextButton")
dragHandle.Size = UDim2.new(1, 0, 0, 30)
dragHandle.Position = UDim2.new(0, 0, 0, 0)
dragHandle.Text = "Location Saver ▲"
dragHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dragHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
dragHandle.BorderSizePixel = 0
dragHandle.Parent = mainFrame

-- Drag handle for minimized frame
local minimizedDragHandle = Instance.new("TextButton")
minimizedDragHandle.Size = UDim2.new(1, 0, 1, 0)
minimizedDragHandle.Text = "Location Saver ▼"
minimizedDragHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minimizedDragHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizedDragHandle.BorderSizePixel = 0
minimizedDragHandle.Parent = minimizedFrame

setupDragging(mainFrame, dragHandle)
setupDragging(minimizedFrame, minimizedDragHandle)

-- Locations list frame
local locationsFrame = Instance.new("ScrollingFrame")
locationsFrame.Size = UDim2.new(1, -10, 1, -100)
locationsFrame.Position = UDim2.new(0, 5, 0, 35)
locationsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
locationsFrame.BorderSizePixel = 0
locationsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
locationsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
locationsFrame.ScrollBarThickness = 5
locationsFrame.Parent = mainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = locationsFrame
UIListLayout.Padding = UDim.new(0, 5)

-- Buttons frame
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Size = UDim2.new(1, -10, 0, 60)
buttonsFrame.Position = UDim2.new(0, 5, 1, -65)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

-- Add location button
local addButton = Instance.new("TextButton")
addButton.Size = UDim2.new(1, 0, 0, 25)
addButton.Position = UDim2.new(0, 0, 0, 0)
addButton.Text = "Add Current Location"
addButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
addButton.Parent = buttonsFrame

-- Delete selected button
local deleteButton = Instance.new("TextButton")
deleteButton.Size = UDim2.new(1, 0, 0, 25)
deleteButton.Position = UDim2.new(0, 0, 0, 30)
deleteButton.Text = "Delete Selected"
deleteButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteButton.Parent = buttonsFrame

-- Minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -30, 0, 0)
minimizeButton.Text = "_"
minimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Parent = mainFrame

-- Table to store saved locations
local savedLocations = {}

-- Function to create a location entry
local function createLocationEntry(locationData)
    local entryFrame = Instance.new("Frame")
    entryFrame.Size = UDim2.new(1, 0, 0, 50)
    entryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    entryFrame.BorderSizePixel = 0
    entryFrame.Parent = locationsFrame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 30, 1, 0)
    checkbox.Position = UDim2.new(0, 0, 0, 0)
    checkbox.Text = ""
    checkbox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    checkbox.Parent = entryFrame
    locationData.checkbox = checkbox
    
    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(1, -35, 0.5, -5)
    teleportButton.Position = UDim2.new(0, 35, 0, 2)
    teleportButton.Text = locationData.name
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Parent = entryFrame
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -35, 0.5, -5)
    infoLabel.Position = UDim2.new(0, 35, 0.5, 2)
    infoLabel.Text = string.format("X: %.1f, Y: %.1f, Z: %.1f", 
        locationData.position.X, locationData.position.Y, locationData.position.Z)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = entryFrame
    
    -- Toggle checkbox
    checkbox.MouseButton1Click:Connect(function()
        locationData.selected = not locationData.selected
        checkbox.BackgroundColor3 = locationData.selected and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
    end)
    
    -- Teleport to location
    teleportButton.MouseButton1Click:Connect(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(locationData.position)
    end)
end

-- Toggle between minimized and expanded views
local function toggleMinimize()
    if mainFrame.Visible then
        mainFrame.Visible = false
        minimizedFrame.Visible = true
        minimizedFrame.Position = mainFrame.Position
        dragHandle.Text = "Location Saver ▼"
    else
        mainFrame.Visible = true
        minimizedFrame.Visible = false
        mainFrame.Position = minimizedFrame.Position
        dragHandle.Text = "Location Saver ▲"
    end
end

minimizeButton.MouseButton1Click:Connect(toggleMinimize)
minimizedDragHandle.MouseButton1Click:Connect(toggleMinimize)

-- Add current location
addButton.MouseButton1Click:Connect(function()
    local character = player.Character
    if not character then
        character = player.CharacterAdded:Wait()
    end
    
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Get location name from user
    local name = "Location " .. (#savedLocations + 1)
    
    -- Create input box for name
    local inputGui = Instance.new("ScreenGui")
    inputGui.Name = "LocationNameInput"
    inputGui.Parent = playerGui
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0, 300, 0, 150)
    inputFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    inputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    inputFrame.Parent = inputGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "Name this location:"
    title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = inputFrame
    
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 0, 30)
    textBox.Position = UDim2.new(0, 10, 0, 40)
    textBox.Text = name
    textBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.Parent = inputFrame
    
    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(0.5, -15, 0, 30)
    saveButton.Position = UDim2.new(0, 10, 1, -40)
    saveButton.Text = "Save"
    saveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.Parent = inputFrame
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0.5, -15, 0, 30)
    cancelButton.Position = UDim2.new(0.5, 5, 1, -40)
    cancelButton.Text = "Cancel"
    cancelButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.Parent = inputFrame
    
    saveButton.MouseButton1Click:Connect(function()
        name = textBox.Text ~= "" and textBox.Text or name
        
        local locationData = {
            name = name,
            position = humanoidRootPart.Position,
            selected = false
        }
        
        table.insert(savedLocations, locationData)
        createLocationEntry(locationData)
        
        inputGui:Destroy()
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        inputGui:Destroy()
    end)
end)

-- Delete selected locations
deleteButton.MouseButton1Click:Connect(function()
    for i = #savedLocations, 1, -1 do
        if savedLocations[i].selected then
            savedLocations[i].checkbox.Parent:Destroy()
            table.remove(savedLocations, i)
        end
    end
end)
