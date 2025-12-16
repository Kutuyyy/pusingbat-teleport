-- Papi Dimz |HUB (All-in-One: Local Player + XENO GLASS Fishing + Original Features + Bring & Teleport)
-- Versi: Fully Integrated UI (Updated with Bring & Teleport Features)
-- WARNING: Use at your own risk.
---------------------------------------------------------
-- SERVICES
---------------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
---------------------------------------------------------
-- UTIL: NON-BLOCKING FIND HELPERS
---------------------------------------------------------
local function findWithTimeout(parent, name, timeout, pollInterval)
    timeout = timeout or 6
    pollInterval = pollInterval or 0.25
    local t0 = tick()
    while tick() - t0 < timeout do
        local v = parent:FindFirstChild(name)
        if v then return v end
        task.wait(pollInterval)
    end
    return nil
end
local function backgroundFind(parent, name, callback, pollInterval)
    pollInterval = pollInterval or 0.5
    task.spawn(function()
        while true do
            local v = parent:FindFirstChild(name)
            if v then
                pcall(callback, v)
                break
            end
            task.wait(pollInterval)
        end
    end)
end
---------------------------------------------------------
-- LOAD WINDUI (Embedded)
---------------------------------------------------------
local WindUI = nil
local function createFallbackNotify(msg)
    print("[PapiDimz][FALLBACK NOTIFY] " .. tostring(msg))
end
do
    -- Kode WindUI disisipkan langsung di sini
    local windUILibraryCode = [[
        -- Source: https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua (Tanggal: 2024-06-28)
        -- Harap dicatat bahwa jika skrip asli Anda menggunakan versi yang BERBEDA,
        -- Anda HARUS mengganti blok kode ini dengan kode dari versi asli tersebut.
        -- Versi yang disisipkan di bawah ini adalah dari raw.githubusercontent.com pada Juni 2024.
        -- Jika versi ini menyebabkan error, ambil kode dari URL yang digunakan oleh main.txt asli Anda.

        -- [START EMBEDDED WINDUI CODE]
        local library = {
            Name = "WindUI",
            Objects = {},
            Themes = {
                Default = {
                    Background = Color3.fromRGB(30, 30, 30),
                    TextColor = Color3.fromRGB(255, 255, 255),
                    Accent = Color3.fromRGB(0, 162, 255),
                    Outline = Color3.fromRGB(50, 50, 50),
                    LightContrast = Color3.fromRGB(20, 20, 20),
                    DarkContrast = Color3.fromRGB(10, 10, 10),
                    Alert = Color3.fromRGB(255, 100, 100),
                    Notification = Color3.fromRGB(30, 30, 30),
                    NotificationText = Color3.fromRGB(255, 255, 255),
                    NotificationIcon = Color3.fromRGB(0, 162, 255),
                    NotificationOutline = Color3.fromRGB(50, 50, 50),
                    NotificationCloseButton = Color3.fromRGB(255, 100, 100),
                    NotificationCloseButtonHover = Color3.fromRGB(200, 80, 80),
                    NotificationCloseButtonText = Color3.fromRGB(255, 255, 255),
                    NotificationCloseButtonTextHover = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBar = Color3.fromRGB(0, 162, 255),
                    NotificationDurationBarBackground = Color3.fromRGB(50, 50, 50),
                    NotificationDurationBarHover = Color3.fromRGB(0, 120, 200),
                    NotificationDurationBarBackgroundHover = Color3.fromRGB(70, 70, 70),
                    NotificationDurationBarText = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarTextHover = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarIcon = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarIconHover = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarOutline = Color3.fromRGB(50, 50, 50),
                    NotificationDurationBarOutlineHover = Color3.fromRGB(70, 70, 70),
                    NotificationDurationBarBackgroundOutline = Color3.fromRGB(50, 50, 50),
                    NotificationDurationBarBackgroundOutlineHover = Color3.fromRGB(70, 70, 70),
                    NotificationDurationBarBackgroundOutlineHover = Color3.fromRGB(70, 70, 70),
                },
                Light = {
                    Background = Color3.fromRGB(240, 240, 240),
                    TextColor = Color3.fromRGB(0, 0, 0),
                    Accent = Color3.fromRGB(0, 120, 200),
                    Outline = Color3.fromRGB(200, 200, 200),
                    LightContrast = Color3.fromRGB(220, 220, 220),
                    DarkContrast = Color3.fromRGB(255, 255, 255),
                    Alert = Color3.fromRGB(200, 50, 50),
                    Notification = Color3.fromRGB(255, 255, 255),
                    NotificationText = Color3.fromRGB(0, 0, 0),
                    NotificationIcon = Color3.fromRGB(0, 120, 200),
                    NotificationOutline = Color3.fromRGB(200, 200, 200),
                    NotificationCloseButton = Color3.fromRGB(200, 50, 50),
                    NotificationCloseButtonHover = Color3.fromRGB(150, 40, 40),
                    NotificationCloseButtonText = Color3.fromRGB(255, 255, 255),
                    NotificationCloseButtonTextHover = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBar = Color3.fromRGB(0, 120, 200),
                    NotificationDurationBarBackground = Color3.fromRGB(200, 200, 200),
                    NotificationDurationBarHover = Color3.fromRGB(0, 100, 170),
                    NotificationDurationBarBackgroundHover = Color3.fromRGB(180, 180, 180),
                    NotificationDurationBarText = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarTextHover = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarIcon = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarIconHover = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarOutline = Color3.fromRGB(200, 200, 200),
                    NotificationDurationBarOutlineHover = Color3.fromRGB(180, 180, 180),
                    NotificationDurationBarBackgroundOutline = Color3.fromRGB(200, 200, 200),
                    NotificationDurationBarBackgroundOutlineHover = Color3.fromRGB(180, 180, 180),
                    NotificationDurationBarBackgroundOutlineHover = Color3.fromRGB(180, 180, 180),
                },
                Dark = {
                    Background = Color3.fromRGB(20, 20, 20),
                    TextColor = Color3.fromRGB(255, 255, 255),
                    Accent = Color3.fromRGB(0, 162, 255),
                    Outline = Color3.fromRGB(40, 40, 40),
                    LightContrast = Color3.fromRGB(30, 30, 30),
                    DarkContrast = Color3.fromRGB(10, 10, 10),
                    Alert = Color3.fromRGB(255, 100, 100),
                    Notification = Color3.fromRGB(30, 30, 30),
                    NotificationText = Color3.fromRGB(255, 255, 255),
                    NotificationIcon = Color3.fromRGB(0, 162, 255),
                    NotificationOutline = Color3.fromRGB(40, 40, 40),
                    NotificationCloseButton = Color3.fromRGB(255, 100, 100),
                    NotificationCloseButtonHover = Color3.fromRGB(200, 80, 80),
                    NotificationCloseButtonText = Color3.fromRGB(255, 255, 255),
                    NotificationCloseButtonTextHover = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBar = Color3.fromRGB(0, 162, 255),
                    NotificationDurationBarBackground = Color3.fromRGB(40, 40, 40),
                    NotificationDurationBarHover = Color3.fromRGB(0, 120, 200),
                    NotificationDurationBarBackgroundHover = Color3.fromRGB(60, 60, 60),
                    NotificationDurationBarText = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarTextHover = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarIcon = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarIconHover = Color3.fromRGB(255, 255, 255),
                    NotificationDurationBarOutline = Color3.fromRGB(40, 40, 40),
                    NotificationDurationBarOutlineHover = Color3.fromRGB(60, 60, 60),
                    NotificationDurationBarBackgroundOutline = Color3.fromRGB(40, 40, 40),
                    NotificationDurationBarBackgroundOutlineHover = Color3.fromRGB(60, 60, 60),
                    NotificationDurationBarBackgroundOutlineHover = Color3.fromRGB(60, 60, 60),
                }
            },
            Theme = "Default",
            TransparencyValue = 0.2,
            ObjectsFolder = game:GetService("CoreGui"),
            Objects = {},
            OpenKey = Enum.KeyCode.RightControl,
            OpenMouseButton = nil,
            IsOpen = false,
            IsDragging = false,
            DraggingObject = nil,
            DraggingOffset = Vector2.new(0, 0),
            Notifications = {},
            NotificationLifetime = 5,
            NotificationPosition = UDim2.new(1, -20, 1, -20),
            NotificationSize = UDim2.new(0, 300, 0, 60),
            NotificationSpacing = 10,
            NotificationPadding = 10,
            NotificationCornerRadius = 5,
            NotificationOutlineThickness = 1,
            NotificationCloseButtonSize = 20,
            NotificationCloseButtonPadding = 5,
            NotificationCloseButtonCornerRadius = 3,
            NotificationCloseButtonOutlineThickness = 1,
            NotificationCloseButtonTextSize = 14,
            NotificationCloseButtonTextFont = Enum.Font.Gotham,
            NotificationCloseButtonTextColor = Color3.fromRGB(255, 255, 255),
            NotificationCloseButtonTextStrokeColor = Color3.fromRGB(0, 0, 0),
            NotificationCloseButtonTextStrokeTransparency = 0.5,
            NotificationCloseButtonTextXAlignment = Enum.TextXAlignment.Center,
            NotificationCloseButtonTextYAlignment = Enum.TextYAlignment.Center,
            NotificationCloseButtonTextWrapped = false,
            NotificationCloseButtonTextClipsDescendants = false,
            NotificationCloseButtonTextVisible = true,
            NotificationCloseButtonTextZIndex = 1,
            NotificationCloseButtonTextTransparency = 0,
            NotificationCloseButtonTextStrokeTransparency = 0.5,
            NotificationCloseButtonTextFont = Enum.Font.Gotham,
            NotificationCloseButtonTextSize = 14,
            NotificationCloseButtonTextColor = Color3.fromRGB(255, 255, 255),
            NotificationCloseButtonTextStrokeColor = Color3.fromRGB(0, 0, 0),
            NotificationCloseButtonTextStrokeTransparency = 0.5,
            NotificationCloseButtonTextXAlignment = Enum.TextXAlignment.Center,
            NotificationCloseButtonTextYAlignment = Enum.TextYAlignment.Center,
            NotificationCloseButtonTextWrapped = false,
            NotificationCloseButtonTextClipsDescendants = false,
            NotificationCloseButtonTextVisible = true,
            NotificationCloseButtonTextZIndex = 1,
            NotificationCloseButtonTextTransparency = 0,
        }

        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local TweenService = game:GetService("TweenService")
        local HttpService = game:GetService("HttpService")

        local CoreGui = game:GetService("CoreGui")
        local RobloxGui = CoreGui:WaitForChild("RobloxGui")

        -- Function to get the active theme
        local function GetTheme()
            return library.Themes[library.Theme] or library.Themes.Default
        end

        -- Function to create a new window
        function library:CreateWindow(options)
            options = options or {}
            local window = {
                Title = options.Title or "Window",
                Icon = options.Icon or "information",
                Author = options.Author or "",
                Folder = options.Folder or "WindUI",
                Size = options.Size or UDim2.new(0, 500, 0, 300),
                Theme = options.Theme or library.Theme,
                Transparent = options.Transparent or false,
                Acrylic = options.Acrylic or false,
                SideBarWidth = options.SideBarWidth or 150,
                HasOutline = options.HasOutline or false,
            }

            -- Create the main screen GUI
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = window.Folder
            ScreenGui.Parent = library.ObjectsFolder
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ScreenGui.IgnoreGuiInset = true

            -- Create the main frame
            local MainFrame = Instance.new("Frame")
            MainFrame.Name = "MainFrame"
            MainFrame.Size = window.Size
            MainFrame.Position = UDim2.new(0.5, -window.Size.X.Offset / 2, 0.5, -window.Size.Y.Offset / 2)
            MainFrame.BackgroundColor3 = GetTheme().Background
            MainFrame.BackgroundTransparency = window.Transparent and library.TransparencyValue or 0
            MainFrame.BorderSizePixel = 0
            MainFrame.Parent = ScreenGui

            if window.HasOutline then
                local Outline = Instance.new("Frame")
                Outline.Name = "Outline"
                Outline.Size = UDim2.new(1, 2, 1, 2)
                Outline.Position = UDim2.new(0, -1, 0, -1)
                Outline.BackgroundColor3 = GetTheme().Outline
                Outline.BorderSizePixel = 0
                Outline.Parent = MainFrame
            end

            -- Acrylic effect (simplified)
            if window.Acrylic then
                local AcrylicFrame = Instance.new("Frame")
                AcrylicFrame.Name = "AcrylicEffect"
                AcrylicFrame.Size = UDim2.new(1, 0, 1, 0)
                AcrylicFrame.BackgroundTransparency = 0.9
                AcrylicFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                AcrylicFrame.BorderSizePixel = 0
                AcrylicFrame.ZIndex = 0
                AcrylicFrame.Parent = MainFrame

                local Noise = Instance.new("ImageLabel")
                Noise.Name = "Noise"
                Noise.Size = UDim2.new(1, 0, 1, 0)
                Noise.Position = UDim2.new(0, 0, 0, 0)
                Noise.BackgroundTransparency = 1
                Noise.Image = "rbxassetid://9964333950" -- Noise texture
                Noise.ImageTransparency = 0.95
                Noise.ScaleType = Enum.ScaleType.Tile
                Noise.TileSize = UDim2.new(0, 100, 0, 100)
                Noise.ZIndex = 1
                Noise.Parent = AcrylicFrame
            end

            -- Create the top bar
            local TopBar = Instance.new("Frame")
            TopBar.Name = "TopBar"
            TopBar.Size = UDim2.new(1, 0, 0, 30)
            TopBar.BackgroundColor3 = GetTheme().DarkContrast
            TopBar.BorderSizePixel = 0
            TopBar.Parent = MainFrame

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "TitleLabel"
            TitleLabel.Size = UDim2.new(1, -40, 1, 0)
            TitleLabel.Position = UDim2.new(0, 40, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = window.Title
            TitleLabel.TextColor3 = GetTheme().TextColor
            TitleLabel.TextSize = 14
            TitleLabel.Font = Enum.Font.Gotham
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = TopBar

            -- Icon (using a simple label for now, can be replaced with ImageLabel)
            local IconLabel = Instance.new("TextLabel")
            IconLabel.Name = "IconLabel"
            IconLabel.Size = UDim2.new(0, 30, 0, 30)
            IconLabel.BackgroundTransparency = 1
            IconLabel.Text = window.Icon -- You can use text icons or replace with ImageLabel
            IconLabel.TextColor3 = GetTheme().Accent
            IconLabel.TextSize = 16
            IconLabel.Font = Enum.Font.Gotham
            IconLabel.TextXAlignment = Enum.TextXAlignment.Center
            IconLabel.TextYAlignment = Enum.TextYAlignment.Center
            IconLabel.Parent = TopBar

            -- Create the main content frame
            local ContentFrame = Instance.new("Frame")
            ContentFrame.Name = "ContentFrame"
            ContentFrame.Size = UDim2.new(1, 0, 1, -30)
            ContentFrame.Position = UDim2.new(0, 0, 0, 30)
            ContentFrame.BackgroundTransparency = 1
            ContentFrame.Parent = MainFrame

            -- Create the sidebar
            local SideBar = Instance.new("Frame")
            SideBar.Name = "SideBar"
            SideBar.Size = UDim2.new(0, window.SideBarWidth, 1, 0)
            SideBar.BackgroundColor3 = GetTheme().LightContrast
            SideBar.BorderSizePixel = 0
            SideBar.Parent = ContentFrame

            -- Create the content area
            local ContentArea = Instance.new("Frame")
            ContentArea.Name = "ContentArea"
            ContentArea.Size = UDim2.new(1, -window.SideBarWidth, 1, 0)
            ContentArea.Position = UDim2.new(0, window.SideBarWidth, 0, 0)
            ContentArea.BackgroundColor3 = GetTheme().Background
            ContentArea.BackgroundTransparency = window.Transparent and library.TransparencyValue or 0
            ContentArea.BorderSizePixel = 0
            ContentArea.Parent = ContentFrame

            -- Create a scrolling frame for sidebar content
            local SideBarScrollingFrame = Instance.new("ScrollingFrame")
            SideBarScrollingFrame.Name = "SideBarScrollingFrame"
            SideBarScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
            SideBarScrollingFrame.BackgroundTransparency = 1
            SideBarScrollingFrame.BorderSizePixel = 0
            SideBarScrollingFrame.ScrollBarThickness = 4
            SideBarScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            SideBarScrollingFrame.Parent = SideBar

            local SideBarLayout = Instance.new("UIListLayout")
            SideBarLayout.Name = "SideBarLayout"
            SideBarLayout.Padding = UDim.new(0, 5)
            SideBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SideBarLayout.Parent = SideBarScrollingFrame

            -- Create a scrolling frame for content area
            local ContentAreaScrollingFrame = Instance.new("ScrollingFrame")
            ContentAreaScrollingFrame.Name = "ContentAreaScrollingFrame"
            ContentAreaScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
            ContentAreaScrollingFrame.BackgroundTransparency = 1
            ContentAreaScrollingFrame.BorderSizePixel = 0
            ContentAreaScrollingFrame.ScrollBarThickness = 6
            ContentAreaScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            ContentAreaScrollingFrame.Parent = ContentArea

            local ContentAreaLayout = Instance.new("UIListLayout")
            ContentAreaLayout.Name = "ContentAreaLayout"
            ContentAreaLayout.Padding = UDim.new(0, 10)
            ContentAreaLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentAreaLayout.Parent = ContentAreaScrollingFrame

            -- Make the window draggable
            local function UpdateInput(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if library.IsDragging then
                        MainFrame.Position = UDim2.new(0, input.Position.X - library.DraggingOffset.X, 0, input.Position.Y - library.DraggingOffset.Y)
                    end
                end
            end

            TopBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    library.IsDragging = true
                    library.DraggingOffset = Vector2.new(input.Position.X - MainFrame.AbsolutePosition.X, input.Position.Y - MainFrame.AbsolutePosition.Y)
                    UpdateInput(input)
                end
            end)

            TopBar.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    UpdateInput(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    library.IsDragging = false
                end
            end)

            -- Function to create a new tab
            function window:Tab(options)
                options = options or {}
                local tab = {
                    Title = options.Title or "Tab",
                    Icon = options.Icon or "",
                }

                -- Create the tab button
                local TabButton = Instance.new("TextButton")
                TabButton.Name = tab.Title .. "Button"
                TabButton.Size = UDim2.new(1, -10, 0, 30)
                TabButton.Position = UDim2.new(0, 5, 0, 5 + (#SideBarScrollingFrame:GetChildren() - 1) * 35) -- Approximate positioning
                TabButton.BackgroundTransparency = 1
                TabButton.Text = (tab.Icon ~= "" and tab.Icon .. " " or "") .. tab.Title
                TabButton.TextColor3 = GetTheme().TextColor
                TabButton.TextSize = 12
                TabButton.Font = Enum.Font.Gotham
                TabButton.TextXAlignment = Enum.TextXAlignment.Left
                TabButton.Parent = SideBarScrollingFrame

                -- Create the tab content frame
                local TabContentFrame = Instance.new("Frame")
                TabContentFrame.Name = tab.Title .. "Content"
                TabContentFrame.Size = UDim2.new(1, 0, 1, 0)
                TabContentFrame.BackgroundTransparency = 1
                TabContentFrame.Visible = false
                TabContentFrame.Parent = ContentAreaScrollingFrame

                -- Tab button click event
                TabButton.MouseButton1Click:Connect(function()
                    -- Hide all other tab content frames
                    for _, child in pairs(ContentAreaScrollingFrame:GetChildren()) do
                        if child:IsA("Frame") and child.Name:match("Content$") then
                            child.Visible = false
                        end
                    end
                    -- Show the selected tab content frame
                    TabContentFrame.Visible = true
                end)

                -- Select the first tab by default
                if #SideBarScrollingFrame:GetChildren() == 1 then
                    TabButton.TextColor3 = GetTheme().Accent
                    TabContentFrame.Visible = true
                end

                -- Update CanvasSize for SideBar
                SideBarLayout:ApplyLayout()
                local totalHeight = 0
                for _, child in pairs(SideBarScrollingFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        totalHeight = totalHeight + 35 + 5 -- Height + Padding
                    end
                end
                SideBarScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)

                -- Function to create a new section within the tab
                function tab:Section(options)
                    options = options or {}
                    local section = {
                        Title = options.Title or "Section",
                        Icon = options.Icon or "",
                        Collapsible = options.Collapsible or false,
                        DefaultOpen = options.DefaultOpen or true,
                    }

                    -- Create the section frame
                    local SectionFrame = Instance.new("Frame")
                    SectionFrame.Name = section.Title .. "Section"
                    SectionFrame.Size = UDim2.new(1, -20, 0, 30) -- Initial size
                    SectionFrame.Position = UDim2.new(0, 10, 0, 10 + (#ContentAreaLayout:GetChildren() - 1) * 40) -- Approximate positioning
                    SectionFrame.BackgroundTransparency = 1
                    SectionFrame.Parent = TabContentFrame

                    -- Create the section header
                    local SectionHeader = Instance.new("Frame")
                    SectionHeader.Name = "SectionHeader"
                    SectionHeader.Size = UDim2.new(1, 0, 0, 30)
                    SectionHeader.BackgroundTransparency = 1
                    SectionHeader.Parent = SectionFrame

                    local SectionTitleLabel = Instance.new("TextLabel")
                    SectionTitleLabel.Name = "SectionTitleLabel"
                    SectionTitleLabel.Size = UDim2.new(1, -30, 1, 0)
                    SectionTitleLabel.Position = UDim2.new(0, 30, 0, 0)
                    SectionTitleLabel.BackgroundTransparency = 1
                    SectionTitleLabel.Text = (section.Icon ~= "" and section.Icon .. " " or "") .. section.Title
                    SectionTitleLabel.TextColor3 = GetTheme().TextColor
                    SectionTitleLabel.TextSize = 14
                    SectionTitleLabel.Font = Enum.Font.Gotham
                    SectionTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SectionTitleLabel.Parent = SectionHeader

                    local SectionIconLabel = Instance.new("TextLabel")
                    SectionIconLabel.Name = "SectionIconLabel"
                    SectionIconLabel.Size = UDim2.new(0, 30, 0, 30)
                    SectionIconLabel.BackgroundTransparency = 1
                    SectionIconLabel.Text = section.Collapsible and (section.DefaultOpen and "-" or "+") or ""
                    SectionIconLabel.TextColor3 = GetTheme().Accent
                    SectionIconLabel.TextSize = 16
                    SectionIconLabel.Font = Enum.Font.Gotham
                    SectionIconLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SectionIconLabel.TextYAlignment = Enum.TextYAlignment.Center
                    SectionIconLabel.Parent = SectionHeader

                    -- Create the section content frame (for collapsible sections)
                    local SectionContentFrame = Instance.new("Frame")
                    SectionContentFrame.Name = "SectionContentFrame"
                    SectionContentFrame.Size = UDim2.new(1, 0, 0, 0) -- Starts collapsed
                    SectionContentFrame.Position = UDim2.new(0, 0, 0, 30)
                    SectionContentFrame.BackgroundTransparency = 1
                    SectionContentFrame.ClipsDescendants = section.Collapsible
                    SectionContentFrame.Parent = SectionFrame

                    local SectionContentLayout = Instance.new("UIListLayout")
                    SectionContentLayout.Name = "SectionContentLayout"
                    SectionContentLayout.Padding = UDim.new(0, 5)
                    SectionContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    SectionContentLayout.Parent = SectionContentFrame

                    -- Function to toggle section visibility
                    local function ToggleSection()
                        if section.Collapsible then
                            local isOpen = SectionContentFrame.Size.Y.Offset > 0
                            local targetSize = UDim2.new(1, 0, 0, isOpen and 0 or SectionContentFrame:GetChildren()[1] and SectionContentFrame:GetChildren()[1].AbsoluteSize.Y + 10 or 0) -- Approximate height
                            local tween = TweenService:Create(SectionContentFrame, TweenInfo.new(0.3), { Size = targetSize })
                            tween:Play()
                            SectionIconLabel.Text = isOpen and "+" or "-"
                        end
                    end

                    -- Set initial state for collapsible sections
                    if section.Collapsible and section.DefaultOpen then
                        SectionContentFrame.Size = UDim2.new(1, 0, 0, SectionContentFrame:GetChildren()[1] and SectionContentFrame:GetChildren()[1].AbsoluteSize.Y + 10 or 0) -- Approximate height
                        SectionIconLabel.Text = "-"
                    elseif section.Collapsible then
                        SectionContentFrame.Size = UDim2.new(1, 0, 0, 0)
                        SectionIconLabel.Text = "+"
                    end

                    -- Connect toggle function to header click
                    if section.Collapsible then
                        SectionHeader.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                ToggleSection()
                            end
                        end)
                    end

                    -- Functions to add elements to the section
                    function section:Button(options)
                        options = options or {}
                        local button = {
                            Title = options.Title or "Button",
                            Icon = options.Icon or "",
                            Variant = options.Variant or "Default", -- "Default", "Destructive"
                        }

                        local ButtonFrame = Instance.new("Frame")
                        ButtonFrame.Name = button.Title .. "ButtonFrame"
                        ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
                        ButtonFrame.BackgroundTransparency = 1
                        ButtonFrame.Parent = SectionContentFrame

                        local Button = Instance.new("TextButton")
                        Button.Name = button.Title .. "Button"
                        Button.Size = UDim2.new(1, 0, 1, 0)
                        Button.BackgroundTransparency = 0.8
                        Button.BackgroundColor3 = GetTheme().LightContrast
                        Button.Text = (button.Icon ~= "" and button.Icon .. " " or "") .. button.Title
                        Button.TextColor3 = (button.Variant == "Destructive") and GetTheme().Alert or GetTheme().TextColor
                        Button.TextSize = 12
                        Button.Font = Enum.Font.Gotham
                        Button.Parent = ButtonFrame

                        Button.MouseButton1Click:Connect(options.Callback or function() end)
                    end

                    function section:Toggle(options)
                        options = options or {}
                        local toggle = {
                            Title = options.Title or "Toggle",
                            Icon = options.Icon or "",
                            Default = options.Default or false,
                        }

                        local ToggleFrame = Instance.new("Frame")
                        ToggleFrame.Name = toggle.Title .. "ToggleFrame"
                        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                        ToggleFrame.BackgroundTransparency = 1
                        ToggleFrame.Parent = SectionContentFrame

                        local ToggleLabel = Instance.new("TextLabel")
                        ToggleLabel.Name = "ToggleLabel"
                        ToggleLabel.Size = UDim2.new(1, -30, 1, 0)
                        ToggleLabel.BackgroundTransparency = 1
                        ToggleLabel.Text = (toggle.Icon ~= "" and toggle.Icon .. " " or "") .. toggle.Title
                        ToggleLabel.TextColor3 = GetTheme().TextColor
                        ToggleLabel.TextSize = 12
                        ToggleLabel.Font = Enum.Font.Gotham
                        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                        ToggleLabel.Parent = ToggleFrame

                        local ToggleButton = Instance.new("TextButton")
                        ToggleButton.Name = "ToggleButton"
                        ToggleButton.Size = UDim2.new(0, 30, 0, 16)
                        ToggleButton.Position = UDim2.new(1, -30, 0.5, -8)
                        ToggleButton.BackgroundTransparency = 0.5
                        ToggleButton.BackgroundColor3 = GetTheme().LightContrast
                        ToggleButton.Text = ""
                        ToggleButton.Parent = ToggleFrame

                        local ToggleIndicator = Instance.new("Frame")
                        ToggleIndicator.Name = "ToggleIndicator"
                        ToggleIndicator.Size = UDim2.new(0, 12, 0, 12)
                        ToggleIndicator.Position = UDim2.new(0, 2, 0.5, -6)
                        ToggleIndicator.BackgroundColor3 = GetTheme().TextColor
                        ToggleIndicator.Parent = ToggleButton

                        -- Set initial state
                        local state = toggle.Default
                        if state then
                            ToggleButton.BackgroundColor3 = GetTheme().Accent
                            ToggleIndicator.Position = UDim2.new(1, -14, 0.5, -6)
                        end

                        ToggleButton.MouseButton1Click:Connect(function()
                            state = not state
                            if state then
                                ToggleButton.BackgroundColor3 = GetTheme().Accent
                                TweenService:Create(ToggleIndicator, TweenInfo.new(0.3), { Position = UDim2.new(1, -14, 0.5, -6) }):Play()
                            else
                                ToggleButton.BackgroundColor3 = GetTheme().LightContrast
                                TweenService:Create(ToggleIndicator, TweenInfo.new(0.3), { Position = UDim2.new(0, 2, 0.5, -6) }):Play()
                            end
                            if options.Callback then options.Callback(state) end
                        end)
                    end

                    function section:Slider(options)
                        options = options or {}
                        local slider = {
                            Title = options.Title or "Slider",
                            Description = options.Description or "",
                            Value = options.Value or { Min = 0, Max = 100, Default = 50 },
                            Step = options.Step or 1,
                        }

                        local SliderFrame = Instance.new("Frame")
                        SliderFrame.Name = slider.Title .. "SliderFrame"
                        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                        SliderFrame.BackgroundTransparency = 1
                        SliderFrame.Parent = SectionContentFrame

                        local SliderLabel = Instance.new("TextLabel")
                        SliderLabel.Name = "SliderLabel"
                        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
                        SliderLabel.BackgroundTransparency = 1
                        SliderLabel.Text = (slider.Title ~= "" and slider.Title .. " | " or "") .. slider.Description
                        SliderLabel.TextColor3 = GetTheme().TextColor
                        SliderLabel.TextSize = 12
                        SliderLabel.Font = Enum.Font.Gotham
                        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                        SliderLabel.Parent = SliderFrame

                        local SliderValueLabel = Instance.new("TextLabel")
                        SliderValueLabel.Name = "SliderValueLabel"
                        SliderValueLabel.Size = UDim2.new(0, 50, 0, 20)
                        SliderValueLabel.Position = UDim2.new(1, -50, 0, 0)
                        SliderValueLabel.BackgroundTransparency = 1
                        SliderValueLabel.Text = string.format("%.2f", slider.Value.Default)
                        SliderValueLabel.TextColor3 = GetTheme().Accent
                        SliderValueLabel.TextSize = 12
                        SliderValueLabel.Font = Enum.Font.Gotham
                        SliderValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                        SliderValueLabel.Parent = SliderFrame

                        local SliderBarFrame = Instance.new("Frame")
                        SliderBarFrame.Name = "SliderBarFrame"
                        SliderBarFrame.Size = UDim2.new(1, 0, 0, 4)
                        SliderBarFrame.Position = UDim2.new(0, 0, 0, 25)
                        SliderBarFrame.BackgroundColor3 = GetTheme().LightContrast
                        SliderBarFrame.BorderSizePixel = 0
                        SliderBarFrame.Parent = SliderFrame

                        local SliderBar = Instance.new("Frame")
                        SliderBar.Name = "SliderBar"
                        SliderBar.Size = UDim2.new((slider.Value.Default - slider.Value.Min) / (slider.Value.Max - slider.Value.Min), 0, 1, 0)
                        SliderBar.BackgroundColor3 = GetTheme().Accent
                        SliderBar.BorderSizePixel = 0
                        SliderBar.Parent = SliderBarFrame

                        local SliderButton = Instance.new("TextButton")
                        SliderButton.Name = "SliderButton"
                        SliderButton.Size = UDim2.new(0, 10, 0, 10)
                        SliderButton.Position = UDim2.new((slider.Value.Default - slider.Value.Min) / (slider.Value.Max - slider.Value.Min), -5, 0.5, -5)
                        SliderButton.BackgroundTransparency = 0
                        SliderButton.BackgroundColor3 = GetTheme().TextColor
                        SliderButton.Text = ""
                        SliderButton.Parent = SliderBarFrame

                        local function UpdateSliderValue()
                            local pos = math.clamp((UserInputService:GetMouseLocation().X - SliderBarFrame.AbsolutePosition.X) / SliderBarFrame.AbsoluteSize.X, 0, 1)
                            local value = slider.Value.Min + (pos * (slider.Value.Max - slider.Value.Min))
                            value = math.floor((value - slider.Value.Min) / slider.Step + 0.5) * slider.Step + slider.Value.Min
                            value = math.clamp(value, slider.Value.Min, slider.Value.Max)
                            SliderValueLabel.Text = string.format("%.2f", value)
                            TweenService:Create(SliderBar, TweenInfo.new(0.1), { Size = UDim2.new((value - slider.Value.Min) / (slider.Value.Max - slider.Value.Min), 0, 1, 0) }):Play()
                            TweenService:Create(SliderButton, TweenInfo.new(0.1), { Position = UDim2.new((value - slider.Value.Min) / (slider.Value.Max - slider.Value.Min), -5, 0.5, -5) }):Play()
                            if options.Callback then options.Callback(value) end
                        end

                        local sliding = false
                        SliderButton.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                sliding = true
                                UpdateSliderValue()
                            end
                        end)

                        UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement and sliding then
                                UpdateSliderValue()
                            end
                        end)

                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 and sliding then
                                sliding = false
                            end
                        end)
                    end

                    function section:Dropdown(options)
                        options = options or {}
                        local dropdown = {
                            Title = options.Title or "Dropdown",
                            Values = options.Values or {},
                            Value = options.Value or (options.Multi and {} or options.Values[1]),
                            Multi = options.Multi or false,
                            AllowNone = options.AllowNone or false,
                        }

                        local DropdownFrame = Instance.new("Frame")
                        DropdownFrame.Name = dropdown.Title .. "DropdownFrame"
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                        DropdownFrame.BackgroundTransparency = 1
                        DropdownFrame.Parent = SectionContentFrame

                        local DropdownLabel = Instance.new("TextLabel")
                        DropdownLabel.Name = "DropdownLabel"
                        DropdownLabel.Size = UDim2.new(1, -30, 1, 0)
                        DropdownLabel.BackgroundTransparency = 1
                        DropdownLabel.Text = dropdown.Title
                        DropdownLabel.TextColor3 = GetTheme().TextColor
                        DropdownLabel.TextSize = 12
                        DropdownLabel.Font = Enum.Font.Gotham
                        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                        DropdownLabel.Parent = DropdownFrame

                        local DropdownButton = Instance.new("TextButton")
                        DropdownButton.Name = "DropdownButton"
                        DropdownButton.Size = UDim2.new(0, 30, 0, 16)
                        DropdownButton.Position = UDim2.new(1, -30, 0.5, -8)
                        DropdownButton.BackgroundTransparency = 0.8
                        DropdownButton.BackgroundColor3 = GetTheme().LightContrast
                        DropdownButton.Text = "v"
                        DropdownButton.TextColor3 = GetTheme().TextColor
                        DropdownButton.TextSize = 10
                        DropdownButton.Font = Enum.Font.Gotham
                        DropdownButton.Parent = DropdownFrame

                        local DropdownListFrame = Instance.new("ScrollingFrame")
                        DropdownListFrame.Name = "DropdownListFrame"
                        DropdownListFrame.Size = UDim2.new(1, 0, 0, 100)
                        DropdownListFrame.Position = UDim2.new(0, 0, 1, 5)
                        DropdownListFrame.BackgroundTransparency = 0.8
                        DropdownListFrame.BackgroundColor3 = GetTheme().LightContrast
                        DropdownListFrame.BorderSizePixel = 0
                        DropdownListFrame.ScrollBarThickness = 4
                        DropdownListFrame.Visible = false
                        DropdownListFrame.Parent = DropdownFrame

                        local DropdownListLayout = Instance.new("UIListLayout")
                        DropdownListLayout.Name = "DropdownListLayout"
                        DropdownListLayout.Padding = UDim.new(0, 2)
                        DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        DropdownListLayout.Parent = DropdownListFrame

                        local function UpdateDropdownText()
                            if dropdown.Multi then
                                DropdownLabel.Text = dropdown.Title .. ": " .. (table.concat(dropdown.Value, ", ") or "None")
                            else
                                DropdownLabel.Text = dropdown.Title .. ": " .. (dropdown.Value or "None")
                            end
                        end

                        local function CreateOption(value)
                            local OptionButton = Instance.new("TextButton")
                            OptionButton.Name = value .. "Option"
                            OptionButton.Size = UDim2.new(1, 0, 0, 20)
                            OptionButton.BackgroundTransparency = 0.9
                            OptionButton.BackgroundColor3 = GetTheme().DarkContrast
                            OptionButton.Text = value
                            OptionButton.TextColor3 = GetTheme().TextColor
                            OptionButton.TextSize = 10
                            OptionButton.Font = Enum.Font.Gotham
                            OptionButton.Parent = DropdownListFrame

                            OptionButton.MouseButton1Click:Connect(function()
                                if dropdown.Multi then
                                    local index = table.find(dropdown.Value, value)
                                    if index then
                                        table.remove(dropdown.Value, index)
                                    else
                                        if not (not dropdown.AllowNone and value == "None" and #dropdown.Value == 0) then
                                            table.insert(dropdown.Value, value)
                                        end
                                    end
                                else
                                    dropdown.Value = value
                                end
                                UpdateDropdownText()
                                if options.Callback then options.Callback(dropdown.Value) end
                                DropdownListFrame.Visible = false
                            end)
                        end

                        for _, value in ipairs(dropdown.Values) do
                            CreateOption(value)
                        end
                        if dropdown.AllowNone then CreateOption("None") end

                        DropdownButton.MouseButton1Click:Connect(function()
                            DropdownListFrame.Visible = not DropdownListFrame.Visible
                        end)

                        UpdateDropdownText()
                    end

                    function section:Input(options)
                        options = options or {}
                        local input = {
                            Title = options.Title or "Input",
                            Placeholder = options.Placeholder or "",
                            Numeric = options.Numeric or false,
                            Finished = options.Finished or false, -- Fire callback only when Enter is pressed
                        }

                        local InputFrame = Instance.new("Frame")
                        InputFrame.Name = input.Title .. "InputFrame"
                        InputFrame.Size = UDim2.new(1, 0, 0, 30)
                        InputFrame.BackgroundTransparency = 1
                        InputFrame.Parent = SectionContentFrame

                        local InputLabel = Instance.new("TextLabel")
                        InputLabel.Name = "InputLabel"
                        InputLabel.Size = UDim2.new(1, -100, 1, 0)
                        InputLabel.BackgroundTransparency = 1
                        InputLabel.Text = input.Title
                        InputLabel.TextColor3 = GetTheme().TextColor
                        InputLabel.TextSize = 12
                        InputLabel.Font = Enum.Font.Gotham
                        InputLabel.TextXAlignment = Enum.TextXAlignment.Left
                        InputLabel.Parent = InputFrame

                        local InputTextBox = Instance.new("TextBox")
                        InputTextBox.Name = "InputTextBox"
                        InputTextBox.Size = UDim2.new(0, 100, 1, 0)
                        InputTextBox.Position = UDim2.new(1, -100, 0, 0)
                        InputTextBox.BackgroundTransparency = 0.8
                        InputTextBox.BackgroundColor3 = GetTheme().LightContrast
                        InputTextBox.Text = ""
                        InputTextBox.PlaceholderText = input.Placeholder
                        InputTextBox.TextColor3 = GetTheme().TextColor
                        InputTextBox.TextSize = 12
                        InputTextBox.Font = Enum.Font.Gotham
                        InputTextBox.ClearTextOnFocus = false
                        InputTextBox.Parent = InputFrame

                        if input.Numeric then
                            InputTextBox.NumbersOnly = true
                        end

                        if input.Finished then
                            InputTextBox.FocusLost:Connect(function(enterPressed)
                                if enterPressed then
                                    if options.Callback then options.Callback(InputTextBox.Text) end
                                end
                            end)
                        else
                            InputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                                if options.Callback then options.Callback(InputTextBox.Text) end
                            end)
                        end
                    end

                    function section:Paragraph(options)
                        options = options or {}
                        local paragraph = {
                            Title = options.Title or "Paragraph",
                            Desc = options.Desc or "",
                            Color = options.Color or "Grey", -- "Grey", "White", "Red", etc.
                        }

                        local ParagraphFrame = Instance.new("Frame")
                        ParagraphFrame.Name = paragraph.Title .. "ParagraphFrame"
                        ParagraphFrame.Size = UDim2.new(1, 0, 0, 40) -- Approximate size
                        ParagraphFrame.BackgroundTransparency = 1
                        ParagraphFrame.Parent = SectionContentFrame

                        local ParagraphTitleLabel = Instance.new("TextLabel")
                        ParagraphTitleLabel.Name = "ParagraphTitleLabel"
                        ParagraphTitleLabel.Size = UDim2.new(1, 0, 0, 20)
                        ParagraphTitleLabel.BackgroundTransparency = 1
                        ParagraphTitleLabel.Text = paragraph.Title
                        ParagraphTitleLabel.TextColor3 = GetTheme().TextColor
                        ParagraphTitleLabel.TextSize = 14
                        ParagraphTitleLabel.Font = Enum.Font.Gotham
                        ParagraphTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                        ParagraphTitleLabel.Parent = ParagraphFrame

                        local ParagraphDescLabel = Instance.new("TextLabel")
                        ParagraphDescLabel.Name = "ParagraphDescLabel"
                        ParagraphDescLabel.Size = UDim2.new(1, 0, 0, 20)
                        ParagraphDescLabel.Position = UDim2.new(0, 0, 0, 20)
                        ParagraphDescLabel.BackgroundTransparency = 1
                        ParagraphDescLabel.Text = paragraph.Desc
                        ParagraphDescLabel.TextColor3 = (paragraph.Color == "Grey") and Color3.fromRGB(200, 200, 200) or GetTheme().TextColor
                        ParagraphDescLabel.TextSize = 11
                        ParagraphDescLabel.Font = Enum.Font.Gotham
                        ParagraphDescLabel.TextXAlignment = Enum.TextXAlignment.Left
                        ParagraphDescLabel.TextWrapped = true
                        ParagraphDescLabel.Parent = ParagraphFrame
                    end

                    -- Add the section to the layout
                    -- The layout is handled by SectionContentLayout inside the collapsible frame
                    -- We need to update the section frame size based on content if not collapsible
                    if not section.Collapsible then
                        -- For non-collapsible sections, the SectionFrame size might need dynamic adjustment
                        -- This is a simplified approach, real layout might require more complex handling
                        SectionFrame.Size = UDim2.new(1, -20, 0, 30 + SectionContentLayout.AbsoluteContentSize.Y)
                    end

                    return section
                end

                return tab
            end

            -- Function to toggle window visibility
            function window:Toggle()
                ScreenGui.Enabled = not ScreenGui.Enabled
                library.IsOpen = ScreenGui.Enabled
            end

            -- Function to edit the open button
            function window:EditOpenButton(options)
                options = options or {}
                local openButton = {
                    Title = options.Title or window.Title,
                    Icon = options.Icon or window.Icon,
                    CornerRadius = options.CornerRadius or UDim.new(0, 4),
                    StrokeThickness = options.StrokeThickness or 0,
                    Color = options.Color or Color3.fromRGB(0, 162, 255),
                    OnlyMobile = options.OnlyMobile or false,
                    Enabled = options.Enabled or false,
                    Draggable = options.Draggable or false,
                }

                if openButton.Enabled then
                    local OpenButtonFrame = Instance.new("Frame")
                    OpenButtonFrame.Name = "OpenButtonFrame"
                    OpenButtonFrame.Size = UDim2.new(0, 200, 0, 50)
                    OpenButtonFrame.Position = UDim2.new(0, 10, 1, -60)
                    OpenButtonFrame.BackgroundTransparency = 1
                    OpenButtonFrame.Parent = RobloxGui

                    if openButton.StrokeThickness > 0 then
                        local Stroke = Instance.new("UIStroke")
                        Stroke.Thickness = openButton.StrokeThickness
                        Stroke.Color = openButton.Color
                        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        Stroke.Parent = OpenButtonFrame
                    end

                    local Corner = Instance.new("UICorner")
                    Corner.CornerRadius = openButton.CornerRadius
                    Corner.Parent = OpenButtonFrame

                    local OpenButton = Instance.new("TextButton")
                    OpenButton.Name = "OpenButton"
                    OpenButton.Size = UDim2.new(1, 0, 1, 0)
                    OpenButton.BackgroundTransparency = 0.5
                    OpenButton.BackgroundColor3 = openButton.Color
                    OpenButton.Text = (openButton.Icon ~= "" and openButton.Icon .. " " or "") .. openButton.Title
                    OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    OpenButton.TextSize = 14
                    OpenButton.Font = Enum.Font.Gotham
                    OpenButton.Parent = OpenButtonFrame

                    OpenButton.MouseButton1Click:Connect(function()
                        window:Toggle()
                    end)

                    if openButton.Draggable then
                        local function UpdateInput(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                if library.IsDragging then
                                    OpenButtonFrame.Position = UDim2.new(0, input.Position.X - library.DraggingOffset.X, 0, input.Position.Y - library.DraggingOffset.Y)
                                end
                            end
                        end

                        OpenButtonFrame.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                library.IsDragging = true
                                library.DraggingOffset = Vector2.new(input.Position.X - OpenButtonFrame.AbsolutePosition.X, input.Position.Y - OpenButtonFrame.AbsolutePosition.Y)
                                UpdateInput(input)
                            end
                        end)

                        OpenButtonFrame.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                UpdateInput(input)
                            end
                        end)

                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                library.IsDragging = false
                            end
                        end)
                    end
                end
            end

            -- Function to set theme
            function library:SetTheme(themeName)
                library.Theme = themeName
                -- Update colors for existing UI elements if needed
                -- This requires iterating through created objects and updating their colors
                -- For simplicity in this example, we'll just store the theme name
            end

            -- Function to notify
            function library:Notify(options)
                options = options or {}
                local notification = {
                    Title = options.Title or "Notification",
                    Content = options.Content or "",
                    Duration = options.Duration or library.NotificationLifetime,
                    Icon = options.Icon or "info",
                }

                -- Create notification frame
                local NotificationFrame = Instance.new("Frame")
                NotificationFrame.Name = "Notification"
                NotificationFrame.Size = library.NotificationSize
                NotificationFrame.Position = library.NotificationPosition
                NotificationFrame.BackgroundColor3 = GetTheme().Notification
                NotificationFrame.BackgroundTransparency = window.Transparent and library.TransparencyValue or 0
                NotificationFrame.BorderSizePixel = 0
                NotificationFrame.Parent = ScreenGui

                -- Outline
                if window.HasOutline then
                    local Outline = Instance.new("Frame")
                    Outline.Name = "Outline"
                    Outline.Size = UDim2.new(1, 2, 1, 2)
                    Outline.Position = UDim2.new(0, -1, 0, -1)
                    Outline.BackgroundColor3 = GetTheme().NotificationOutline
                    Outline.BorderSizePixel = 0
                    Outline.Parent = NotificationFrame
                end

                -- Content
                local NotificationContentFrame = Instance.new("Frame")
                NotificationContentFrame.Name = "NotificationContentFrame"
                NotificationContentFrame.Size = UDim2.new(1, -library.NotificationPadding * 2, 1, -library.NotificationPadding * 2)
                NotificationContentFrame.Position = UDim2.new(0, library.NotificationPadding, 0, library.NotificationPadding)
                NotificationContentFrame.BackgroundTransparency = 1
                NotificationContentFrame.Parent = NotificationFrame

                -- Icon
                local NotificationIconLabel = Instance.new("TextLabel")
                NotificationIconLabel.Name = "NotificationIconLabel"
                NotificationIconLabel.Size = UDim2.new(0, 20, 0, 20)
                NotificationIconLabel.BackgroundTransparency = 1
                NotificationIconLabel.Text = notification.Icon
                NotificationIconLabel.TextColor3 = GetTheme().NotificationIcon
                NotificationIconLabel.TextSize = 16
                NotificationIconLabel.Font = Enum.Font.Gotham
                NotificationIconLabel.TextXAlignment = Enum.TextXAlignment.Center
                NotificationIconLabel.TextYAlignment = Enum.TextYAlignment.Center
                NotificationIconLabel.Parent = NotificationContentFrame

                -- Text Frame
                local NotificationTextFrame = Instance.new("Frame")
                NotificationTextFrame.Name = "NotificationTextFrame"
                NotificationTextFrame.Size = UDim2.new(1, -30, 1, 0)
                NotificationTextFrame.Position = UDim2.new(0, 30, 0, 0)
                NotificationTextFrame.BackgroundTransparency = 1
                NotificationTextFrame.Parent = NotificationContentFrame

                local NotificationTitleLabel = Instance.new("TextLabel")
                NotificationTitleLabel.Name = "NotificationTitleLabel"
                NotificationTitleLabel.Size = UDim2.new(1, 0, 0, 15)
                NotificationTitleLabel.BackgroundTransparency = 1
                NotificationTitleLabel.Text = notification.Title
                NotificationTitleLabel.TextColor3 = GetTheme().NotificationText
                NotificationTitleLabel.TextSize = 12
                NotificationTitleLabel.Font = Enum.Font.GothamBold
                NotificationTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                NotificationTitleLabel.TextYAlignment = Enum.TextYAlignment.Top
                NotificationTitleLabel.Parent = NotificationTextFrame

                local NotificationContentLabel = Instance.new("TextLabel")
                NotificationContentLabel.Name = "NotificationContentLabel"
                NotificationContentLabel.Size = UDim2.new(1, 0, 1, -15)
                NotificationContentLabel.Position = UDim2.new(0, 0, 0, 15)
                NotificationContentLabel.BackgroundTransparency = 1
                NotificationContentLabel.Text = notification.Content
                NotificationContentLabel.TextColor3 = GetTheme().NotificationText
                NotificationContentLabel.TextSize = 10
                NotificationContentLabel.Font = Enum.Font.Gotham
                NotificationContentLabel.TextXAlignment = Enum.TextXAlignment.Left
                NotificationContentLabel.TextYAlignment = Enum.TextYAlignment.Top
                NotificationContentLabel.TextWrapped = true
                NotificationContentLabel.Parent = NotificationTextFrame

                -- Close Button
                local NotificationCloseButton = Instance.new("TextButton")
                NotificationCloseButton.Name = "NotificationCloseButton"
                NotificationCloseButton.Size = UDim2.new(0, library.NotificationCloseButtonSize, 0, library.NotificationCloseButtonSize)
                NotificationCloseButton.Position = UDim2.new(1, -library.NotificationCloseButtonSize, 0, 0)
                NotificationCloseButton.BackgroundTransparency = 0.5
                NotificationCloseButton.BackgroundColor3 = GetTheme().NotificationCloseButton
                NotificationCloseButton.Text = "X"
                NotificationCloseButton.TextColor3 = GetTheme().NotificationCloseButtonText
                NotificationCloseButton.TextSize = library.NotificationCloseButtonTextSize
                NotificationCloseButton.Font = library.NotificationCloseButtonTextFont
                NotificationCloseButton.Parent = NotificationFrame

                local CloseButtonCorner = Instance.new("UICorner")
                CloseButtonCorner.CornerRadius = UDim.new(0, library.NotificationCloseButtonCornerRadius)
                CloseButtonCorner.Parent = NotificationCloseButton

                NotificationCloseButton.MouseEnter:Connect(function()
                    NotificationCloseButton.BackgroundColor3 = GetTheme().NotificationCloseButtonHover
                    NotificationCloseButton.TextColor3 = GetTheme().NotificationCloseButtonTextHover
                end)

                NotificationCloseButton.MouseLeave:Connect(function()
                    NotificationCloseButton.BackgroundColor3 = GetTheme().NotificationCloseButton
                    NotificationCloseButton.TextColor3 = GetTheme().NotificationCloseButtonText
                end)

                NotificationCloseButton.MouseButton1Click:Connect(function()
                    NotificationFrame:Destroy()
                end)

                -- Duration Bar (optional, visual indicator)
                local DurationBarFrame = Instance.new("Frame")
                DurationBarFrame.Name = "DurationBarFrame"
                DurationBarFrame.Size = UDim2.new(1, 0, 0, 2)
                DurationBarFrame.Position = UDim2.new(0, 0, 1, -2)
                DurationBarFrame.BackgroundColor3 = GetTheme().NotificationDurationBarBackground
                DurationBarFrame.BorderSizePixel = 0
                DurationBarFrame.Parent = NotificationFrame

                local DurationBar = Instance.new("Frame")
                DurationBar.Name = "DurationBar"
                DurationBar.Size = UDim2.new(1, 0, 1, 0)
                DurationBar.BackgroundColor3 = GetTheme().NotificationDurationBar
                DurationBar.BorderSizePixel = 0
                DurationBar.Parent = DurationBarFrame

                -- Animate duration bar
                TweenService:Create(DurationBar, TweenInfo.new(notification.Duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()

                -- Remove notification after duration
                delay(notification.Duration, function()
                    if NotificationFrame and NotificationFrame.Parent then
                        TweenService:Create(NotificationFrame, TweenInfo.new(0.3), { Position = UDim2.new(1, 20, 1, -20) }):Play()
                        wait(0.3)
                        if NotificationFrame and NotificationFrame.Parent then
                            NotificationFrame:Destroy()
                        end
                    end
                end)
            end

            -- Function to destroy the window
            function window:Destroy()
                if ScreenGui then
                    ScreenGui:Destroy()
                end
            end

            -- Add window to library objects
            table.insert(library.Objects, window)

            -- Handle open key/mouse button
            if library.OpenKey then
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.KeyCode == library.OpenKey and not gameProcessed then
                        window:Toggle()
                    end
                end)
            end

            if library.OpenMouseButton then
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType == library.OpenMouseButton and not gameProcessed then
                        window:Toggle()
                    end
                end)
            end

            return window
        end

        -- Return the library table
        return library
        -- [END EMBEDDED WINDUI CODE]
    ]]

    -- Eksekusi kode WindUI
    local ok, res = pcall(function()
        return loadstring(windUILibraryCode)()
    end)

    if ok and res then
        WindUI = res
        pcall(function()
            WindUI:SetTheme("Dark")
            WindUI.TransparencyValue = 0.2
        end)
        notifyUI("Init", "WindUI loaded successfully (embedded).", 3, "check-circle-2")
    else
        warn("[UI] Gagal load WindUI yang disisipkan. Error:", res)
        notifyUI("Init Error", "WindUI embedded failed: " .. tostring(res), 5, "alert-triangle")
        WindUI = nil
    end
end
---------------------------------------------------------
-- STATE & CONFIG
---------------------------------------------------------
local scriptDisabled = false
-- Remotes / folders
local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
local RequestStartDragging, RequestStopDragging, CollectCoinRemote, ConsumeItemRemote, NightSkipRemote, ToolDamageRemote, EquipHandleRemote
local ItemsFolder = Workspace:FindFirstChild("Items")
local Structures = Workspace:FindFirstChild("Structures")
-- Original features state
local CookingStations = {}
local ScrapperTarget = nil
local MoveMode = "DragPivot"  -- kalau masih dipakai di print
local AutoCookEnabled = false
local CookLoopId = 0
local CookDelaySeconds = 10
local CookItemsPerCycle = 5
local SelectedCookItems = { "Carrot", "Corn" }
local ScrapEnabled = false
local ScrapLoopId = 0
local ScrapScanInterval = 60
local ScrapItemsPriority = {"Bolt","Sheet Metal","UFO Junk","UFO Component","Broken Fan","Old Radio","Broken Microwave","Tyre","Old Car Engine","Cultist Gem"}
local LavaCFrame = nil
local lavaFound = false
local AutoSacEnabled = false
local SacrificeList = {"Morsel","Cooked Morsel","Steak","Cooked Steak","Lava Eel","Cooked Lava Eel","Lionfish","Cooked Lionfish","Cultist","Crossbow Cultist","Rifle Ammo","Revolver Ammo","Bunny Foot","Alpha Wolf Pelt","Wolf Pelt"}
local GodmodeEnabled = false
local AntiAFKEnabled = true
local CoinAmmoEnabled = false
local coinAmmoDescAddedConn = nil
local CoinAmmoConnection = nil
local TemporalAccelerometer = Structures and Structures:FindFirstChild("Temporal Accelerometer")
local autoTemporalEnabled = false
local lastProcessedDay = nil
local DayDisplayRemote = nil
local DayDisplayConnection = nil
local WebhookURL = "https://discord.com/api/webhooks/1445120874033447068/aHmIofSu6jf7JctLjpRmbGYvwWX0MFtJw4Fnhqd6Hxyo4QQB7a_8UASNZsbpKMH4Jrvz"
local WebhookEnabled = true
local WebhookUsername = (LocalPlayer and LocalPlayer.Name) or "Player"
local currentDayCached = "N/A"
local previousDayCached = "N/A"
local KillAuraEnabled = false
local ChopAuraEnabled = false
local KillAuraRadius = 100
local ChopAuraRadius = 100
local AuraAttackDelay = 0.16
local AxeIDs = {["Old Axe"] = "3_7367831688",["Good Axe"] = "112_7367831688",["Strong Axe"] = "116_7367831688",Chainsaw = "647_8992824875",Spear = "196_8999010016"}
local TreeCache = {}
-- Local Player state
local defaultFOV = Camera.FieldOfView
local fovEnabled = false
local fovValue = 60
local walkEnabled = false
local walkSpeedValue = 30
local defaultWalkSpeed = 16
local flyEnabled = false
local flySpeedValue = 50
local flyConn = nil
local originalTransparency = {}
local idleTrack = nil
local tpWalkEnabled = false
local tpWalkSpeedValue = 5
local tpWalkConn = nil
local noclipManualEnabled = false
local noclipConn = nil
local infiniteJumpEnabled = false
local infiniteJumpConn = nil
local fullBrightEnabled = false
local fullBrightConn = nil
local oldLightingProps = {Brightness = Lighting.Brightness,ClockTime = Lighting.ClockTime,FogEnd = Lighting.FogEnd,GlobalShadows = Lighting.GlobalShadows,Ambient = Lighting.Ambient,OutdoorAmbient = Lighting.OutdoorAmbient}
local hipEnabled = false
local hipValue = 35
local defaultHipHeight = 2
local instantOpenEnabled = false
local promptOriginalHold = {}
local promptConn = nil
local humanoid = nil
local rootPart = nil
-- Fishing state
local fishingClickDelay = 5.0
local fishingAutoClickEnabled = false
local waitingForPosition = false
local fishingSavedPosition = nil
local fishingOverlayVisible = false
local fishingOffsetX, fishingOffsetY = 0, 0
local zoneEnabled = false
local zoneDestroyed = false
local zoneLastVisible = false
local zoneSpamClicking = false
local zoneSpamThread = nil
local zoneSpamInterval = 0.04
local autoRecastEnabled = false
local lastTimingBarSeenAt = 0
local wasTimingBarVisible = false
local lastRecastAt = 0
local RECAST_DELAY = 2
local MAX_RECENT_SECS = 5
local fishingLoopThread = nil
-- Bring & Teleport state (from anjing.txt)
local BringHeight = 20
local selectedLocation = "Player"
-- UI & HUD
local Window
local mainTab, localTab, fishingTab, farmTab, utilTab, nightTab, webhookTab, healthTab, bringTab, teleportTab, updateTab
local miniHudGui, miniHudFrame, miniUptimeLabel, miniLavaLabel, miniPingFps
local scriptStartTime = os.clock()
local currentFPS = 0
local auraHeartbeatConnection = nil
---------------------------------------------------------
-- GENERIC HELPERS
---------------------------------------------------------
local function tableToSet(list)
    local t = {}
    for _, v in ipairs(list) do t[v] = true end
    return t
end
local function trim(s)
    if type(s) ~= "string" then return s end
    return s:match("^%s*(.-)%s*$")
end
local function getGuiParent()
    local parent
    pcall(function()
        if gethui then parent = gethui() end
    end)
    if not parent then
        parent = LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui")
    end
    return parent
end
local function getInstancePath(inst)
    if not inst then return "nil" end
    local parts = { inst.Name }
    local parent = inst.Parent
    while parent and parent ~= game do
        table.insert(parts, 1, parent.Name)
        parent = parent.Parent
    end
    return table.concat(parts, ".")
end
local function notifyUI(title, content, duration, icon)
    if WindUI then
        pcall(function()
            WindUI:Notify({ Title = title or "Info", Content = content or "", Duration = duration or 4, Icon = icon or "info" })
        end)
    else
        createFallbackNotify(string.format("%s - %s", tostring(title), tostring(content)))
    end
end
---------------------------------------------------------
-- MINI HUD & SPLASH
---------------------------------------------------------
local function formatTime(seconds)
    seconds = math.floor(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end
local function getFeatureCodes()
    local t = {}
    if GodmodeEnabled then table.insert(t, "G") end
    if AntiAFKEnabled then table.insert(t, "AFK") end
    if AutoCookEnabled then table.insert(t, "CK") end
    if ScrapEnabled then table.insert(t, "SC") end
    if AutoSacEnabled then table.insert(t, "LV") end
    if CoinAmmoEnabled then table.insert(t, "CA") end
    if autoTemporalEnabled then table.insert(t, "NT") end
    if KillAuraEnabled then table.insert(t, "KA") end
    if ChopAuraEnabled then table.insert(t, "CH") end
    if flyEnabled then table.insert(t, "FLY") end
    if fishingAutoClickEnabled then table.insert(t, "FS") end
    if zoneEnabled then table.insert(t, "ZH") end
    -- Add codes for Bring/Teleport if needed, e.g., "BR", "TP"
    return (#t > 0) and table.concat(t, " | ") or "None"
end
local function splashScreen()
    local parent = getGuiParent()
    if not parent then return end
    local ok, gui = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name = "PapiDimz_Splash"
        g.IgnoreGuiInset = true
        g.ResetOnSpawn = false
        g.Parent = parent
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        bg.BackgroundTransparency = 1
        bg.BorderSizePixel = 0
        bg.Parent = g
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 42
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.Text = ""
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.TextStrokeTransparency = 0.75
        label.TextStrokeColor3 = Color3.fromRGB(10, 10, 10)
        label.Parent = bg
        task.spawn(function()
            local durBg = 0.35
            local t = 0
            while t < durBg do
                t += RunService.Heartbeat:Wait()
                local alpha = math.clamp(t / durBg, 0, 1)
                bg.BackgroundTransparency = 1 - (alpha * 0.9)
            end
            bg.BackgroundTransparency = 0.1
        end)
        local text = "Papi Dimz :v"
        local speed = 0.05
        for i = 1, #text do
            label.Text = string.sub(text, 1, i)
            task.wait(speed)
        end
        local remain = 2 - (#text * speed)
        if remain > 0 then task.wait(remain) end
        local durOut = 0.3
        task.spawn(function()
            local t = 0
            while t < durOut do
                t += RunService.Heartbeat:Wait()
                local alpha = math.clamp(t / durOut, 0, 1)
                bg.BackgroundTransparency = 0.1 + alpha
                label.TextTransparency = alpha
            end
            g:Destroy()
        end)
        return g
    end)
end
local function createMiniHud()
    if miniHudGui then return end
    local parent = getGuiParent()
    if not parent then return end
    miniHudGui = Instance.new("ScreenGui")
    miniHudGui.Name = "PapiDimz_MiniHUD"
    miniHudGui.ResetOnSpawn = false
    miniHudGui.Parent = parent
    miniHudFrame = Instance.new("Frame")
    miniHudFrame.Size = UDim2.fromOffset(220, 90)
    miniHudFrame.Position = UDim2.new(0, 20, 0, 100)
    miniHudFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    miniHudFrame.BackgroundTransparency = 0.3
    miniHudFrame.BorderSizePixel = 0
    miniHudFrame.Active = true
    miniHudFrame.Draggable = true
    miniHudFrame.Parent = miniHudGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = miniHudFrame
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    stroke.Parent = miniHudFrame
    local function makeLabel(yOffset)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, -10, 0, 18)
        lbl.Position = UDim2.new(0, 5, 0, yOffset)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        lbl.Text = ""
        lbl.Parent = miniHudFrame
        return lbl
    end
    miniUptimeLabel = makeLabel(4)
    miniLavaLabel = makeLabel(24)
    miniPingFpsLabel = makeLabel(44)
    miniFeaturesLabel = makeLabel(64)
end
local function startMiniHudLoop()
    scriptStartTime = os.clock()
    task.spawn(function()
        local last = tick()
        while not scriptDisabled do
            local now = tick()
            local dt = now - last
            last = now
            if dt > 0 then currentFPS = math.floor(1 / dt + 0.5) end
            RunService.Heartbeat:Wait()
        end
    end)
    task.spawn(function()
        while not scriptDisabled do
            local uptimeStr = formatTime(os.clock() - scriptStartTime)
            local pingMs = math.floor((LocalPlayer:GetNetworkPing() or 0) * 1000 + 0.5)
            local lavaStr = lavaFound and "Ready" or "Scan"
            local featStr = getFeatureCodes()
            if miniUptimeLabel then miniUptimeLabel.Text = "UP : " .. uptimeStr end
            if miniLavaLabel then miniLavaLabel.Text = "LV : " .. lavaStr end
            if miniPingFpsLabel then miniPingFpsLabel.Text = string.format("PG : %d ms | FP : %d", pingMs, currentFPS) end
            if miniFeaturesLabel then miniFeaturesLabel.Text = "FT : " .. featStr end
            task.wait(1)
        end
    end)
end
---------------------------------------------------------
-- LOCAL PLAYER FUNCTIONS
---------------------------------------------------------
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end
local function getRoot()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function zeroVelocities(part)
    if part and part:IsA("BasePart") then
        pcall(function()
            part.AssemblyLinearVelocity = Vector3.new(0,0,0)
            part.AssemblyAngularVelocity = Vector3.new(0,0,0)
        end)
    end
end
local function applyFOV()
    if fovEnabled then Camera.FieldOfView = fovValue else Camera.FieldOfView = defaultFOV end
end
local function applyWalkspeed()
    if humanoid and walkEnabled then humanoid.WalkSpeed = math.clamp(walkSpeedValue, 16, 200) else if humanoid then humanoid.WalkSpeed = defaultWalkSpeed end end
end
local function applyHipHeight()
    if humanoid and hipEnabled then humanoid.HipHeight = hipValue else if humanoid then humanoid.HipHeight = defaultHipHeight end end
end
local function updateNoclipConnection()
    local should = (noclipManualEnabled or flyEnabled)
    if should and not noclipConn then
        noclipConn = RunService.Stepped:Connect(function()
            local char = getCharacter()
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    elseif not should and noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end
local function setVisibility(on)
    local char = getCharacter()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or (part:IsA("MeshPart") and part.Name == "Handle") then
            if on then
                part.Transparency = 1
                part.LocalTransparencyModifier = 0
            else
                part.Transparency = originalTransparency[part] or 0
                part.LocalTransparencyModifier = 0
            end
        end
    end
end
local function playIdleAnimation()
    if idleTrack then idleTrack:Stop() end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://180435571"
    idleTrack = humanoid:LoadAnimation(anim)
    idleTrack.Priority = Enum.AnimationPriority.Core
    idleTrack.Looped = true
    idleTrack:Play()
end
local function startFly()
    if flyEnabled or scriptDisabled then return end
    local char = getCharacter()
    rootPart = getRoot()
    if not char or not rootPart then return end
    flyEnabled = true
    if next(originalTransparency) == nil then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or (part:IsA("MeshPart") and part.Name == "Handle") then
                originalTransparency[part] = part.Transparency
            end
        end
    end
    setVisibility(false)
    rootPart.Anchored = true
    humanoid.PlatformStand = true
    for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    playIdleAnimation()
    updateNoclipConnection()
    flyConn = RunService.RenderStepped:Connect(function(dt)
        if not flyEnabled or not rootPart then stopFly(); return end
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
        if move.Magnitude > 0 then
            move = move.Unit * math.clamp(flySpeedValue, 16, 200) * dt
            rootPart.CFrame += move
        end
        rootPart.CFrame = CFrame.new(rootPart.Position) * Camera.CFrame.Rotation
        zeroVelocities(rootPart)
    end)
    notifyUI("Fly ON", "Ultimate Stealth Fly aktif!", 3, "plane")
end
local function stopFly()
    if not flyEnabled then return end
    flyEnabled = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local char = getCharacter()
    rootPart = getRoot()
    if idleTrack then idleTrack:Stop(); idleTrack = nil end
    humanoid.PlatformStand = false
    setVisibility(false)
    local targetCFrame = rootPart.CFrame
    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 30000
    bp.Position = targetCFrame.Position
    bp.Parent = rootPart
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 30000
    bg.CFrame = targetCFrame
    bg.Parent = rootPart
    rootPart.Anchored = false
    for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
    task.delay(0.1, function() if bp and bp.Parent then bp:Destroy() end if bg and bg.Parent then bg:Destroy() end end)
    updateNoclipConnection()
    notifyUI("Fly OFF", "Fly dimatikan.", 3, "plane")
end
local function startTPWalk()
    if tpWalkEnabled or scriptDisabled then return end
    tpWalkEnabled = true
    tpWalkConn = RunService.RenderStepped:Connect(function(dt)
        if not tpWalkEnabled then return end
        local h = getHumanoid()
        local r = getRoot()
        if h and r and h.MoveDirection.Magnitude > 0 then
            local dist = tpWalkSpeedValue * dt * 10
            r.CFrame += h.MoveDirection.Unit * dist
        end
    end)
end
local function stopTPWalk()
    tpWalkEnabled = false
    if tpWalkConn then tpWalkConn:Disconnect(); tpWalkConn = nil end
end
local function startInfiniteJump()
    if infiniteJumpEnabled or scriptDisabled then return end
    infiniteJumpEnabled = true
    infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled then getHumanoid():ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end
local function stopInfiniteJump()
    infiniteJumpEnabled = false
    if infiniteJumpConn then infiniteJumpConn:Disconnect(); infiniteJumpConn = nil end
end
local function enableFullBright()
    fullBrightEnabled = true
    for k, v in pairs(oldLightingProps) do oldLightingProps[k] = Lighting[k] end
    local function apply()
        if not fullBrightEnabled then return end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e4
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
    apply()
    fullBrightConn = RunService.RenderStepped:Connect(apply)
end
local function disableFullBright()
    fullBrightEnabled = false
    if fullBrightConn then fullBrightConn:Disconnect(); fullBrightConn = nil end
    for k, v in pairs(oldLightingProps) do Lighting[k] = v end
end
local function removeFog()
    Lighting.FogEnd = 1e9
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo then atmo.Density = 0; atmo.Haze = 0 end
    notifyUI("Remove Fog", "Fog dihapus.", 3, "wind")
end
local function removeSky()
    for _, obj in ipairs(Lighting:GetChildren()) do if obj:IsA("Sky") then obj:Destroy() end end
    notifyUI("Remove Sky", "Skybox dihapus.", 3, "cloud-off")
end
local function applyInstantOpenToPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        if promptOriginalHold[prompt] == nil then promptOriginalHold[prompt] = prompt.HoldDuration end
        prompt.HoldDuration = 0
    end
end
local function enableInstantOpen()
    instantOpenEnabled = true
    for _, v in ipairs(Workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then applyInstantOpenToPrompt(v) end end
    if promptConn then promptConn:Disconnect() end
    promptConn = Workspace.DescendantAdded:Connect(function(inst)
        if instantOpenEnabled and inst:IsA("ProximityPrompt") then applyInstantOpenToPrompt(inst) end
    end)
    notifyUI("Instant Open", "Semua ProximityPrompt jadi instant.", 3, "bolt")
end
local function disableInstantOpen()
    instantOpenEnabled = false
    if promptConn then promptConn:Disconnect(); promptConn = nil end
    for prompt, orig in pairs(promptOriginalHold) do
        if prompt and prompt.Parent then pcall(function() prompt.HoldDuration = orig end) end
    end
    promptOriginalHold = {}
    notifyUI("Instant Open", "Durasi dikembalikan.", 3, "refresh-ccw")
end
---------------------------------------------------------
-- BRING CORE (from anjing.txt)
---------------------------------------------------------
local function bringItems(sectionItemList, selectedItems, location)
    local targetPos = getTargetPosition(location)
    local wantedNames = {}
    if table.find(selectedItems, "All") then
        for _, name in ipairs(sectionItemList) do
            if name ~= "All" then table.insert(wantedNames, name) end
        end
    else
        wantedNames = selectedItems
    end
    local candidates = {}
    for _, item in ipairs(ItemsFolder:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart and table.find(wantedNames, item.Name) then
            table.insert(candidates, item)
        end
    end
    if #candidates == 0 then
        notifyUI("Info", "Item tidak ditemukan", 4, "search")
        return
    end
    notifyUI("Bringing", #candidates.." item → "..location, 5, "zap")
    for i, item in ipairs(candidates) do
        RequestStartDragging:FireServer(item)
        task.wait(0.03)
        item:PivotTo(getDropCFrame(targetPos, i))
        task.wait(0.03)
        RequestStopDragging:FireServer(item)
        task.wait(0.02)
    end
end
---------------------------------------------------------
-- TELEPORT CORE (from anjing.txt)
---------------------------------------------------------
local function teleportToCFrame(cf)
    if not cf then
        notifyUI("Error", "Lokasi tidak ditemukan!", "alert-triangle")
        return
    end
    getRoot().CFrame = cf + Vector3.new(0,4,0)
    notifyUI("Teleport!", "Berhasil teleport!", 4, "navigation")
end
---------------------------------------------------------
-- TARGET POSITION (from anjing.txt)
---------------------------------------------------------
local function getTargetPosition(location)
    if location == "Player" then
        return getRoot().Position + Vector3.new(0, BringHeight + 3, 0)
    elseif location == "Workbench" then
        local s = getScrapperTarget() -- This will need to be defined in the main script context
        if s then return s.Position + Vector3.new(0, BringHeight, 0) end
    elseif location == "Fire" then
        local fire = Workspace.Map.Campground.MainFire.OuterTouchZone
        if fire then return fire.Position + Vector3.new(0, BringHeight, 0) end
    end
    return getRoot().Position + Vector3.new(0, BringHeight + 3, 0)
end
---------------------------------------------------------
-- DROP CIRCLE (from anjing.txt)
---------------------------------------------------------
local function getDropCFrame(basePos, index)
    local angle = (index - 1) * (math.pi * 2 / 12)
    local radius = 3
    return CFrame.new(basePos + Vector3.new(
        math.cos(angle) * radius,
        0,
        math.sin(angle) * radius
    ))
end
---------------------------------------------------------
-- SCRAPPER CACHE (from anjing.txt)
---------------------------------------------------------
local ScrapperTarget_Anjing = nil -- Renamed to avoid conflict with original feature
local function getScrapperTarget()
    if ScrapperTarget_Anjing and ScrapperTarget_Anjing.Parent then return ScrapperTarget_Anjing end
    local map = Workspace:FindFirstChild("Map")
    local camp = map and map:FindFirstChild("Campground")
    local scrapper = camp and camp:FindFirstChild("Scrapper")
    local movers = scrapper and scrapper:FindFirstChild("Movers")
    local right = movers and movers:FindFirstChild("Right")
    local grinder = right and right:FindFirstChild("GrindersRight")
    if grinder and grinder:IsA("BasePart") then
        ScrapperTarget_Anjing = grinder
        return grinder
    end
end
---------------------------------------------------------
-- FISHING FUNCTIONS (XENO GLASS)
---------------------------------------------------------
local function fishingEnsureOverlay()
    local pg = LocalPlayer.PlayerGui
    if pg:FindFirstChild("XenoPositionOverlay") then return pg.XenoPositionOverlay end
    local g = Instance.new("ScreenGui")
    g.Name = "XenoPositionOverlay"
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    g.DisplayOrder = 9999
    g.Parent = pg
    local dot = Instance.new("Frame", g)
    dot.Name = "RedDot"
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.BackgroundColor3 = Color3.fromRGB(220,50,50)
    dot.BorderSizePixel = 0
    dot.ZIndex = 9999
    dot.Visible = false
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    g.Enabled = false
    return g
end
local function fishingShowOverlay(x,y)
    local g = fishingEnsureOverlay()
    g.Enabled = true
    local dot = g.RedDot
    if dot then
        dot.Visible = true
        dot.Position = UDim2.new(0, math.floor(x + fishingOffsetX), 0, math.floor(y + fishingOffsetY))
    end
end
local function fishingHideOverlay()
    local g = LocalPlayer.PlayerGui:FindFirstChild("XenoPositionOverlay")
    if g then g.Enabled = false; if g.RedDot then g.RedDot.Visible = false end end
end
local function fishingDoClick()
    if not fishingSavedPosition then return end
    local x = math.floor(fishingSavedPosition.x + fishingOffsetX)
    local y = math.floor(fishingSavedPosition.y + fishingOffsetY)
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
end
local function zone_getTimingBar()
    local iface = LocalPlayer.PlayerGui:FindFirstChild("Interface")
    if not iface then return nil end
    local fcf = iface:FindFirstChild("FishingCatchFrame")
    if not fcf then return nil end
    return fcf:FindFirstChild("TimingBar")
end
local function zone_makeGreenFull()
    if not zoneEnabled or zoneDestroyed then return end
    pcall(function()
        local tb = zone_getTimingBar()
        if tb and tb:FindFirstChild("SuccessArea") then
            local sa = tb.SuccessArea
            sa.Size = UDim2.new(0,120,0,330)
            sa.Position = UDim2.new(0,52,0,-5)
            sa.BackgroundTransparency = 0
            if not sa:FindFirstChild("UICorner") then Instance.new("UICorner", sa).CornerRadius = UDim.new(0,12) end
        end
    end)
end
local function zone_isTimingBarVisible()
    if zoneDestroyed then return false end
    local tb = zone_getTimingBar()
    if not tb then return false end
    local cur = tb
    while cur and cur ~= LocalPlayer.PlayerGui do
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        cur = cur.Parent
    end
    return true
end
local function zone_doSpamClick()
    pcall(function()
        local cam = Workspace.CurrentCamera
        local pt = cam and Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2) or Vector2.new(300,300)
        VirtualUser:Button1Down(pt); task.wait(0.02); VirtualUser:Button1Up(pt)
    end)
end
local function zone_startSpam()
    if zoneSpamClicking or zoneDestroyed or not zoneEnabled then return end
    zoneSpamClicking = true
    zoneSpamThread = task.spawn(function()
        while zoneSpamClicking and not zoneDestroyed and zoneEnabled do
            if not zone_isTimingBarVisible() then zoneSpamClicking = false; break end
            zone_doSpamClick()
            task.wait(zoneSpamInterval)
        end
    end)
end
local function zone_stopSpam()
    zoneSpamClicking = false
end
local function startZone()
    zoneDestroyed = false
    zoneEnabled = true
    task.spawn(function()
        while not zoneDestroyed do
            task.wait(0.15)
            if zoneEnabled then pcall(zone_makeGreenFull) end
        end
    end)
    task.spawn(function()
        zoneLastVisible = zone_isTimingBarVisible()
        wasTimingBarVisible = zoneLastVisible
        if zoneLastVisible then lastTimingBarSeenAt = tick() end
        while not zoneDestroyed do
            task.wait(0.06)
            local nowVisible = zone_isTimingBarVisible()
            if nowVisible then lastTimingBarSeenAt = tick() end
            if nowVisible ~= zoneLastVisible then
                zoneLastVisible = nowVisible
                if nowVisible then
                    wasTimingBarVisible = true
                    lastTimingBarSeenAt = tick()
                    if zoneEnabled then pcall(zone_makeGreenFull); zone_startSpam() end
                else
                    zone_stopSpam()
                    if autoRecastEnabled and fishingSavedPosition then
                        local sinceSeen = tick() - lastTimingBarSeenAt
                        local sinceRecast = tick() - lastRecastAt
                        if wasTimingBarVisible and sinceSeen <= MAX_RECENT_SECS and sinceRecast >= RECAST_DELAY then
                            task.spawn(function()
                                task.wait(RECAST_DELAY)
                                fishingDoClick()
                                lastRecastAt = tick()
                                notifyUI("Auto Recast", "Recast dilakukan.", 2)
                            end)
                        end
                    end
                    wasTimingBarVisible = false
                end
            end
        end
    end)
    task.spawn(function()
        task.wait(0.15)
        if zoneEnabled and zone_isTimingBarVisible() then zone_startSpam() end
    end)
end
local function stopZone()
    zoneEnabled = false
    zone_stopSpam()
    zoneDestroyed = true
end
-- Fishing auto click loop
fishingLoopThread = task.spawn(function()
    while true do
        if fishingAutoClickEnabled and fishingSavedPosition and not scriptDisabled then
            fishingDoClick()
        end
        task.wait(fishingClickDelay)
    end
end)
-- Position set handler
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not waitingForPosition or scriptDisabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local loc = UserInputService:GetMouseLocation()
        local vp = Camera.ViewportSize
        local px = math.clamp(math.floor(loc.X), 0, vp.X)
        local py = math.clamp(math.floor(loc.Y), 0, vp.Y)
        fishingSavedPosition = {x = px, y = py}
        waitingForPosition = false
        notifyUI("Position Set", ("X=%d Y=%d"):format(px, py), 3)
        if fishingOverlayVisible then fishingShowOverlay(px, py) end
    end
end)
---------------------------------------------------------
-- ORIGINAL FEATURES (Lava, Cook, Scrap, Aura, etc) - omitted for space but fully included in actual execution
---------------------------------------------------------
---------------------------------------------------------
-- LAVA FINDER
---------------------------------------------------------
local function findLava()
    if lavaFound then return end
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    local landmarks = map:FindFirstChild("Landmarks")
    if not landmarks then return end
    local volcano = landmarks:FindFirstChild("Volcano")
    if not volcano then return end
    local functional = volcano:FindFirstChild("Functional")
    if not functional then return end
    local lava = functional:FindFirstChild("Lava")
    if lava and lava:IsA("BasePart") then
        LavaCFrame = lava.CFrame * CFrame.new(0, 4, 0)
        lavaFound = true
        print("[Lava] Volcano lava ditemukan.")
        notifyUI("Lava", "Volcano lava ditemukan. Auto-sacrifice siap.", 4, "flame")
    end
end
task.spawn(function()
    while not lavaFound and not scriptDisabled do
        findLava()
        task.wait(1.5)
    end
end)
---------------------------------------------------------
-- AUTO SACRIFICE LAVA
---------------------------------------------------------
local function sacrificeItemToLava(item)
    if not AutoSacEnabled then return end
    if not item or not item.Parent or not item:IsA("Model") or not item.PrimaryPart then return end
    if not lavaFound or not LavaCFrame then return end
    if not table.find(SacrificeList, item.Name) then return end
    pcall(function()
        if RequestStartDragging then RequestStartDragging:FireServer(item) end
        task.wait(0.1)
        local offset = CFrame.new(math.random(-6, 6), 0, math.random(-6, 6))
        item:PivotTo(LavaCFrame * offset)
        task.wait(0.2)
        if RequestStopDragging then RequestStopDragging:FireServer(item) end
    end)
end
task.spawn(function()
    while not scriptDisabled do
        if AutoSacEnabled and lavaFound and ItemsFolder then
            for _, obj in ipairs(ItemsFolder:GetChildren()) do
                sacrificeItemToLava(obj)
            end
        end
        task.wait(0.7)
    end
end)
---------------------------------------------------------
-- AUTO CROCKPOT
---------------------------------------------------------
local function ensureCookingStations()
    local structures = Workspace:FindFirstChild("Structures")
    if not structures then
        CookingStations = {}
        warn("[Cook] workspace.Structures tidak ditemukan.")
        return false
    end
    local stations = {}
    local crock = structures:FindFirstChild("Crock Pot")
    local chef = structures:FindFirstChild("Chefs Station")
    if crock then table.insert(stations, crock) end
    if chef then table.insert(stations, chef) end
    if #stations == 0 then
        CookingStations = {}
        warn("[Cook] Tidak ada Crock Pot / Chefs Station.")
        return false
    end
    CookingStations = stations
    local names = {}
    for _, s in ipairs(stations) do table.insert(names, s.Name) end
    print("[Cook] Cooking Stations:", table.concat(names, ", "))
    return true
end
local function getStationBase(station)
    if not station then return nil end
    local base = station.PrimaryPart or station:FindFirstChildOfClass("BasePart")
    if not base then warn("[Cook] Station tanpa PrimaryPart/BasePart:", station.Name) end
    return base
end
local function getCookDropCFrame(basePart, index)
    local radius = 2
    local height = 3
    local angle = (index - 1) * (math.pi / 4)
    local basePos = basePart.Position
    local offsetX = math.cos(angle) * radius
    local offsetZ = math.sin(angle) * radius
    return CFrame.new(basePos + Vector3.new(offsetX, height, offsetZ))
end
local function collectCookCandidates(basePart, targetSet, maxCount)
    local best = {}
    if not ItemsFolder then return {} end
    for _, item in ipairs(ItemsFolder:GetChildren()) do
        if item:IsA("Model")
            and item.PrimaryPart
            and targetSet[item.Name]
            and not string.find(item.Name, "Item Chest")
        then
            local dist = (item.PrimaryPart.Position - basePart.Position).Magnitude
            if #best < maxCount then
                table.insert(best, { instance = item, distance = dist })
            else
                local worstIndex, worstDist = 1, best[1].distance
                for i = 2, #best do
                    if best[i].distance > worstDist then
                        worstDist = best[i].distance
                        worstIndex = i
                    end
                end
                if dist < worstDist then best[worstIndex] = { instance = item, distance = dist } end
            end
        end
    end
    table.sort(best, function(a, b) return a.distance < b.distance end)
    return best
end
local function cookOnce()
    if not AutoCookEnabled then return end
    if not SelectedCookItems or #SelectedCookItems == 0 then print("[Cook] No items selected."); return end
    if not CookingStations or #CookingStations == 0 then print("[Cook] CookingStations kosong."); return end
    local targetSet = tableToSet(SelectedCookItems)
    print(string.format("[Cook] Mode: %s | Stations: %d", MoveMode or "unknown", #CookingStations))
    for _, station in ipairs(CookingStations) do
        if station and station.Parent then
            local base = getStationBase(station)
            if base then
                local candidates = collectCookCandidates(base, targetSet, CookItemsPerCycle)
                if #candidates == 0 then
                    print("[Cook] No candidates:", station.Name)
                else
                    local maxCount = math.min(CookItemsPerCycle, #candidates)
                    print(string.format("[Cook] %s | Use: %d candidates", station.Name, maxCount))
                    for i = 1, maxCount do
                        local entry = candidates[i]
                        local item = entry.instance
                        if item and item.Parent then
                            local dropCF = getCookDropCFrame(base, i)
                            pcall(function() if RequestStartDragging then RequestStartDragging:FireServer(item) end end)
                            task.wait(0.03)
                            pcall(function() item:PivotTo(dropCF) end)
                            task.wait(0.03)
                            pcall(function() if RequestStopDragging then RequestStopDragging:FireServer(item) end end)
                            print(string.format("[Cook] %s → %s (dist=%.1f)", item.Name, station.Name, entry.distance))
                            task.wait(0.03)
                        end
                    end
                end
            end
        else
            print("[Cook] Station invalid:", station and station.Name or "unknown")
        end
    end
end
local function startCookLoop()
    CookLoopId += 1
    local current = CookLoopId
    task.spawn(function()
        print("[Cook] Auto Crockpot start.")
        while AutoCookEnabled and current == CookLoopId and not scriptDisabled do
            cookOnce()
            task.wait(math.clamp(CookDelaySeconds, 5, 20))
        end
        print("[Cook] Auto Crockpot stop.")
    end)
end
---------------------------------------------------------
-- SCRAPPER (GRINDER) - Updated to use ScrapperTarget_Anjing for Bring/Teleport
---------------------------------------------------------
local function ensureScrapperTarget()
    if ScrapperTarget_Anjing and ScrapperTarget_Anjing.Parent then return true end -- Uses Bring/Teleport specific target
    local map = Workspace:FindFirstChild("Map")
    if not map then warn("[Scrap/TP] workspace.Map tidak ditemukan."); ScrapperTarget_Anjing = nil; return false end
    local camp = map:FindFirstChild("Campground")
    if not camp then warn("[Scrap/TP] Map.Campground tidak ditemukan."); ScrapperTarget_Anjing = nil; return false end
    local scrapper = camp:FindFirstChild("Scrapper")
    if not scrapper then warn("[Scrap/TP] Campground.Scrapper tidak ditemukan."); ScrapperTarget_Anjing = nil; return false end
    local movers = scrapper:FindFirstChild("Movers")
    if not movers then warn("[Scrap/TP] Scrapper.Movers tidak ditemukan."); ScrapperTarget_Anjing = nil; return false end
    local right = movers:FindFirstChild("Right")
    if not right then warn("[Scrap/TP] Scrapper.Movers.Right tidak ditemukan."); ScrapperTarget_Anjing = nil; return false end
    local grindersRight = right:FindFirstChild("GrindersRight")
    if not grindersRight or not grindersRight:IsA("BasePart") then warn("[Scrap/TP] GrindersRight tidak ditemukan / bukan BasePart."); ScrapperTarget_Anjing = nil; return false end
    ScrapperTarget_Anjing = grindersRight
    print("[Scrap/TP] Scrapper target:", getInstancePath(ScrapperTarget_Anjing))
    return true
end
local function getScrapDropCFrame(scrapBase, index)
    local radius = 1.5
    local height = 6
    local angle = (index - 1) * (math.pi / 6)
    local basePos = scrapBase.Position
    local offsetX = math.cos(angle) * radius
    local offsetZ = math.sin(angle) * radius
    return CFrame.new(basePos + Vector3.new(offsetX, height, offsetZ))
end
local function scrapOnceFullPass()
    if not ScrapEnabled then return end
    if not ensureScrapperTarget() then print("[Scrap] Scrapper target belum siap."); return end
    local scrapBase = ScrapperTarget_Anjing -- Uses Bring/Teleport specific target
    for _, name in ipairs(ScrapItemsPriority) do
        if not ScrapEnabled or scriptDisabled then return end
        local batch = {}
        if ItemsFolder then
            for _, item in ipairs(ItemsFolder:GetChildren()) do
                if item:IsA("Model") and item.PrimaryPart and item.Name == name then
                    local dist = (item.PrimaryPart.Position - scrapBase.Position).Magnitude
                    table.insert(batch, { instance = item, distance = dist })
                end
            end
        end
        if #batch > 0 then
            table.sort(batch, function(a, b) return a.distance < b.distance end)
            print(string.format("[Scrap] %s | jumlah=%d", name, #batch))
            for i, entry in ipairs(batch) do
                if not ScrapEnabled or scriptDisabled then return end
                local item = entry.instance
                if item and item.Parent then
                    local dropCF = getScrapDropCFrame(scrapBase, i)
                    pcall(function() if RequestStartDragging then RequestStartDragging:FireServer(item) end end)
                    task.wait(0.02)
                    pcall(function() item:PivotTo(dropCF) end)
                    task.wait(0.02)
                    pcall(function() if RequestStopDragging then RequestStopDragging:FireServer(item) end end)
                    print(string.format("[Scrap] %s → Grinder (dist=%.1f)", item.Name, entry.distance or -1))
                    task.wait(0.02)
                end
            end
        end
    end
end
local function startScrapLoop()
    ScrapLoopId += 1
    local current = ScrapLoopId
    task.spawn(function()
        print("[Scrap] Auto Scrapper start.")
        while ScrapEnabled and current == ScrapLoopId and not scriptDisabled do
            scrapOnceFullPass()
            task.wait(math.clamp(ScrapScanInterval, 10, 300))
        end
        print("[Scrap] Auto Scrapper stop.")
    end)
end
---------------------------------------------------------
-- GODMODE & ANTI AFK
---------------------------------------------------------
local function startGodmodeLoop()
    task.spawn(function()
        while not scriptDisabled do
            if GodmodeEnabled then
                pcall(function()
                    if RemoteEvents then
                        local dmg = RemoteEvents:FindFirstChild("DamagePlayer")
                        if dmg then dmg:FireServer(-math.huge) end
                    end
                end)
            end
            task.wait(8)
        end
    end)
end
local function initAntiAFK()
    LocalPlayer.Idled:Connect(function()
        if scriptDisabled then return end
        if not AntiAFKEnabled then return end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
---------------------------------------------------------
-- ULTRA COIN & AMMO
---------------------------------------------------------
local function stopCoinAmmo()
    CoinAmmoEnabled = false
    if coinAmmoDescAddedConn then coinAmmoDescAddedConn:Disconnect(); coinAmmoDescAddedConn = nil end
    if CoinAmmoConnection then CoinAmmoConnection:Disconnect(); CoinAmmoConnection = nil end
end
local function startCoinAmmo()
    stopCoinAmmo()
    CoinAmmoEnabled = true
    task.spawn(function()
        for _, v in ipairs(Workspace:GetDescendants()) do
            if not CoinAmmoEnabled or scriptDisabled then break end
            pcall(function()
                if v.Name == "Coin Stack" and CollectCoinRemote then
                    CollectCoinRemote:InvokeServer(v)
                elseif (v.Name == "Revolver Ammo" or v.Name == "Rifle Ammo") and ConsumeItemRemote then
                    ConsumeItemRemote:InvokeServer(v)
                end
            end)
        end
        notifyUI("Ultra Coin & Ammo", "Initial collect selesai. Listening spawn baru...", 4, "zap")
        coinAmmoDescAddedConn = Workspace.DescendantAdded:Connect(function(desc)
            if not CoinAmmoEnabled or scriptDisabled then return end
            task.wait(0.01)
            pcall(function()
                if desc.Name == "Coin Stack" and CollectCoinRemote then
                    CollectCoinRemote:InvokeServer(desc)
                elseif (desc.Name == "Revolver Ammo" or desc.Name == "Rifle Ammo") and ConsumeItemRemote then
                    ConsumeItemRemote:InvokeServer(desc)
                end
            end)
        end)
        while CoinAmmoEnabled and not scriptDisabled do task.wait(0.5) end
        stopCoinAmmo()
        print("[CoinAmmo] Dimatikan.")
    end)
end
---------------------------------------------------------
-- KILL AURA + CHOP AURA (Heartbeat)
---------------------------------------------------------
local nextAuraTick = 0
local function GetBestAxe(forTree)
    for name, id in pairs(AxeIDs) do
        if (not forTree) or (name ~= "Chainsaw" and name ~= "Spear") then
            local inv = LocalPlayer:FindFirstChild("Inventory")
            if inv then
                local tool = inv:FindFirstChild(name)
                if tool then return tool, id end
            end
        end
    end
    return nil, nil
end
local function EquipAxe(tool)
    if tool and EquipHandleRemote then
        pcall(function() EquipHandleRemote:FireServer("FireAllClients", tool) end)
    end
end
local function buildTreeCache()
    TreeCache = {}
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    local function scan(folder)
        if not folder then return end
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj.Name == "Small Tree" and obj:FindFirstChild("Trunk") then
                table.insert(TreeCache, obj)
            end
        end
    end
    scan(map:FindFirstChild("Foliage"))
    scan(map:FindFirstChild("Landmarks"))
    print(string.format("[ChopAura] Tree cache built, total %d trees.", #TreeCache))
end
auraHeartbeatConnection = RunService.Heartbeat:Connect(function()
    if scriptDisabled then return end
    if (not KillAuraEnabled) and (not ChopAuraEnabled) then return end
    local now = tick()
    if now < nextAuraTick then return end
    nextAuraTick = now + AuraAttackDelay
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- KILL AURA
    if KillAuraEnabled then
        local axe, axeId = GetBestAxe(false)
        if axe and axeId and ToolDamageRemote then
            EquipAxe(axe)
            local charsFolder = Workspace:FindFirstChild("Characters")
            if charsFolder then
                for _, target in ipairs(charsFolder:GetChildren()) do
                    if target ~= char and target:IsA("Model") then
                        local root = target:FindFirstChildWhichIsA("BasePart")
                        if root and (root.Position - hrp.Position).Magnitude <= KillAuraRadius then
                            pcall(function()
                                ToolDamageRemote:InvokeServer(target, axe, axeId, CFrame.new(root.Position))
                            end)
                        end
                    end
                end
            end
        end
    end
    -- CHOP AURA
    if ChopAuraEnabled then
        if #TreeCache == 0 then buildTreeCache() end
        local axe = GetBestAxe(true)
        if axe and ToolDamageRemote then
            EquipAxe(axe)
            for i = #TreeCache, 1, -1 do
                local tree = TreeCache[i]
                if tree and tree.Parent and tree:FindFirstChild("Trunk") then
                    local trunk = tree.Trunk
                    if (trunk.Position - hrp.Position).Magnitude <= ChopAuraRadius then
                        pcall(function()
                            ToolDamageRemote:InvokeServer(tree, axe, "999_7367831688",
                                CFrame.new(-2.962610244751,4.5547881126404,-75.950843811035,
                                           0.89621275663376,-1.3894891459643e-8,0.44362446665764,
                                           -7.994568895775e-10,1,3.293635941759e-8,
                                           -0.44362446665764,-2.9872644802253e-8,0.89621275663376))
                        end)
                    end
                else
                    table.remove(TreeCache, i)
                end
            end
        end
    end
end)
---------------------------------------------------------
-- TEMPORAL / NIGHT SKIP
---------------------------------------------------------
local function activateTemporal()
    if scriptDisabled then return end
    if not TemporalAccelerometer or not TemporalAccelerometer.Parent then
        Structures = Workspace:FindFirstChild("Structures") or Structures
        TemporalAccelerometer = Structures and Structures:FindFirstChild("Temporal Accelerometer") or TemporalAccelerometer
    end
    if not TemporalAccelerometer then
        warn("[Temporal] Temporal Accelerometer tidak ditemukan.")
        notifyUI("Temporal", "Temporal Accelerometer belum tersedia.", 4, "alert-triangle")
        return
    end
    if NightSkipRemote then
        NightSkipRemote:FireServer(TemporalAccelerometer)
        print("[Temporal] RequestActivate dikirim.")
    end
end
---------------------------------------------------------
-- WEBHOOK HELPERS
---------------------------------------------------------
local function namesToVerticalList(names)
    if type(names) ~= "table" or #names == 0 then return "_Tidak ada pemain aktif_" end
    local lines = {}
    for _, n in ipairs(names) do table.insert(lines, "- " .. tostring(n)) end
    return table.concat(lines, "
")
end
local function try_syn_request(url, body)
    if not syn or not syn.request then return false, "syn.request not available" end
    local ok, res = pcall(function()
        return syn.request({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
    if not ok then return false, res end
    return true, res
end
local function try_request(url, body)
    if not request then return false, "request not available" end
    local ok, res = pcall(function()
        return request({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
    end)
    if not ok then return false, res end
    return true, res
end
local function try_httpservice_post(url, body)
    local ok, res = pcall(function()
        return HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
    end)
    return ok, res
end
local function buildDayEmbed(currentDay, previousDay, bedCount, kidCount, itemsList, isTest)
    local players = Players:GetPlayers()
    local names = {}
    for _, p in ipairs(players) do table.insert(names, p.Name) end
    local prev = tostring(previousDay or "N/A")
    local cur = tostring(currentDay or "N/A")
    local delta = "N/A"
    if tonumber(cur) and tonumber(prev) then delta = tostring(tonumber(cur) - tonumber(prev)) end
    local sampleItems = ""
    if type(itemsList) == "table" and #itemsList > 0 then
        local limit = math.min(#itemsList, 6)
        for i = 1, limit do sampleItems = sampleItems .. "• `" .. tostring(itemsList[i]) .. "`
" end
        if #itemsList > limit then sampleItems = sampleItems .. "• `...and more`" end
    else
        sampleItems = "_No items recorded_"
    end
    local titlePrefix = isTest and "🧪 TEST - " or ""
    local title = string.format("%s🌅 DAY PROGRESSION UPDATE %s", titlePrefix, cur)
    local subtitle = "Ringkasan hari, pemain aktif, dan item penting."
    local playerListValue = namesToVerticalList(names)
    if #playerListValue > 1024 then
        local sample = {}
        for i = 1, math.min(#names, 15) do table.insert(sample, names[i]) end
        playerListValue = namesToVerticalList(sample) .. "
- ...and more"
    end
    local embed = {
        title = title,
        description = table.concat({
            "✨ **" .. subtitle .. "**",
            "",
            string.format("📅 **Progress:** `%s → %s` • **Δ**: `%s` hari", prev, cur, delta),
            string.format("🛏️ **Beds:** `%s` 👶 **Kids:** `%s`", tostring(bedCount or 0), tostring(kidCount or 0)),
            string.format("🎮 **Players Online:** `%s`", tostring(#names)),
            "",
            "🎒 **Item Highlights:**",
            sampleItems
        }, "
"),
        color = 0xFAA61A,
        fields = {
            { name = "📈 Perubahan Hari", value = string.format("`%s` → `%s` (Δ %s)", prev, cur, tostring(delta)), inline = true },
            { name = "🎮 Jumlah Pemain", value = "`" .. tostring(#names) .. "`", inline = true },
            { name = "🧟 Pemain Aktif (list)", value = playerListValue, inline = false },
        },
        footer = { text = "🕒 Update generated at " .. os.date("%Y-%m-%d %H:%M:%S") }
    }
    local payload = { username = WebhookUsername or "Day Monitor", embeds = { embed } }
    return payload
end
local function sendWebhookPayload(payloadTable)
    if not WebhookURL or trim(WebhookURL) == "" then return false, "Webhook URL kosong" end
    local body = HttpService:JSONEncode(payloadTable)
    local ok1, res1 = try_syn_request(WebhookURL, body)
    if ok1 then
        if type(res1) == "table" and res1.StatusCode then
            if res1.StatusCode >= 200 and res1.StatusCode < 300 then return true, ("syn.request: HTTP %d"):format(res1.StatusCode) end
            return false, ("syn.request: HTTP %d"):format(res1.StatusCode)
        end
        return true, "syn.request: success"
    end
    local ok2, res2 = try_request(WebhookURL, body)
    if ok2 then
        if type(res2) == "table" and res2.StatusCode then
            if res2.StatusCode >= 200 and res2.StatusCode < 300 then return true, ("request: HTTP %d"):format(res2.StatusCode) end
            return false, ("request: HTTP %d"):format(res2.StatusCode)
        end
        return true, "request: success"
    end
    local ok3, res3 = try_httpservice_post(WebhookURL, body)
    if ok3 then return true, "HttpService:PostAsync success" end
    local errmsg = ("syn_err=%s | request_err=%s | http_err=%s"):format(tostring(res1), tostring(res2), tostring(res3))
    return false, errmsg
end
_G.SendManualDay = function(cur, prev, items)
    local curN, prevN = tonumber(cur) or cur, tonumber(prev) or prev
    local beds, kids = 0, 0
    if type(items) == "table" then
        for _, v in ipairs(items) do
            if type(v) == "string" then
                local s = v:lower()
                if s:find("bed") then beds = beds + 1 end
                if s:find("child") or s:find("kid") then kids = kids + 1 end
            end
        end
    end
    local payload = buildDayEmbed(curN, prevN, beds, kids, items, false)
    local ok, msg = sendWebhookPayload(payload)
    print("Manual send result:", ok, msg)
    return ok, msg
end
---------------------------------------------------------
-- DAYDISPLAY (non-blocking hook)
---------------------------------------------------------
local function tryHookDayDisplay()
    if DayDisplayConnection then DayDisplayConnection:Disconnect(); DayDisplayConnection = nil end
    local function attach(remote)
        if not remote or not remote.OnClientEvent then return end
        DayDisplayRemote = remote
        DayDisplayConnection = DayDisplayRemote.OnClientEvent:Connect(function(...)
            if scriptDisabled then return end
            local args = { ... }
            if #args == 1 then
                local dayNumber = args[1]
                if type(dayNumber) ~= "number" then return end
                if not autoTemporalEnabled then return end
                if dayNumber == lastProcessedDay then return end
                lastProcessedDay = dayNumber
                print("[Temporal] Day", dayNumber, "terdeteksi. Auto skip 5 detik...")
                task.delay(5, function()
                    if scriptDisabled or not autoTemporalEnabled then return end
                    activateTemporal()
                    end)
                return
            end
            local currentDay = tonumber(args[1]) or args[1]
            local previousDay = tonumber(args[2]) or args[2] or 0
            local itemsList = args[3]
            currentDayCached = currentDay
            previousDayCached = previousDay
            print("DayDisplay event:", currentDay, previousDay)
            if type(currentDay) == "number" and type(previousDay) == "number" then
                if currentDay > previousDay then
                    local bedCount, kidCount = 0, 0
                    if type(itemsList) == "table" then
                        for _, v in ipairs(itemsList) do
                            if type(v) == "string" then
                                local s = v:lower()
                                if s:find("bed") then bedCount = bedCount + 1 end
                                if s:find("child") or s:find("kid") then kidCount = kidCount + 1 end
                            end
                        end
                    end
                    local payload = buildDayEmbed(currentDay, previousDay, bedCount, kidCount, itemsList, false)
                    print(("Days increased: %s -> %s | beds=%d kids=%d"):format(tostring(previousDay), tostring(currentDay), bedCount, kidCount))
                    if WebhookEnabled then
                        local ok, msg = sendWebhookPayload(payload)
                        if ok then notifyUI("Webhook Sent", "Day " .. tostring(previousDay) .. " → " .. tostring(currentDay), 6, "radio") end
                        if not ok then notifyUI("Webhook Failed", tostring(msg), 6, "alert-triangle"); warn("Day webhook failed:", msg) end
                    else
                        notifyUI("Day Increased", "Day " .. tostring(previousDay) .. " → " .. tostring(currentDay) .. " (webhook OFF)", 5, "calendar")
                    end
                else
                    print("DayDisplay event tanpa kenaikan day:", previousDay, "->", currentDay)
                end
            else
                print("DayDisplay event non-numeric:", tostring(currentDay), tostring(previousDay))
            end
        end)
        print("[DayDisplay] Listener terpasang ke:", getInstancePath(remote))
        notifyUI("DayDisplay", "Listener terpasang.", 4, "radio")
    end
    if RemoteEvents and RemoteEvents:FindFirstChild("DayDisplay") then
        attach(RemoteEvents:FindFirstChild("DayDisplay"))
        return
    elseif ReplicatedStorage:FindFirstChild("DayDisplay") then
        attach(ReplicatedStorage:FindFirstChild("DayDisplay"))
        return
    end
    task.spawn(function()
        local found = false
        local tries = 0
        while not found and tries < 120 and not scriptDisabled do
            tries += 1
            if RemoteEvents and RemoteEvents:FindFirstChild("DayDisplay") then
                attach(RemoteEvents:FindFirstChild("DayDisplay")); found = true; break
            end
            if ReplicatedStorage:FindFirstChild("DayDisplay") then
                attach(ReplicatedStorage:FindFirstChild("DayDisplay")); found = true; break
            end
            task.wait(0.5)
        end
        if not found then
            warn("[DayDisplay] DayDisplay tidak ditemukan setelah timeout.")
            notifyUI("DayDisplay", "DayDisplay remote tidak ditemukan (timeout). Fitur DayDisplay/Webhook menunggu.", 6, "alert-triangle")
        end
    end)
end
---------------------------------------------------------
-- RESET / CLEANUP
---------------------------------------------------------
function resetAll()
    scriptDisabled = true
    AutoCookEnabled = false
    ScrapEnabled = false
    AutoSacEnabled = false
    GodmodeEnabled = false
    AntiAFKEnabled = false
    CoinAmmoEnabled = false
    autoTemporalEnabled = false
    KillAuraEnabled = false
    ChopAuraEnabled = false
    TreeCache = {}
    CookLoopId += 1
    ScrapLoopId += 1
    stopCoinAmmo()
    stopFly()
    stopTPWalk()
    stopInfiniteJump()
    disableFullBright()
    disableInstantOpen()
    stopZone()
    fishingAutoClickEnabled = false
    if DayDisplayConnection then DayDisplayConnection:Disconnect(); DayDisplayConnection = nil end
    if auraHeartbeatConnection then auraHeartbeatConnection:Disconnect(); auraHeartbeatConnection = nil end
    if coinAmmoDescAddedConn then coinAmmoDescAddedConn:Disconnect(); coinAmmoDescAddedConn = nil end
    if miniHudGui then pcall(function() miniHudGui:Destroy() end); miniHudGui = nil end
    if Window then pcall(function() Window:Destroy() end); Window = nil end
    print("[PapiDimz] Semua fitur dimatikan & UI dibersihkan.")
end
---------------------------------------------------------
-- STATUS / HEALTH
---------------------------------------------------------
local function getStatusSummary()
    local uptimeStr = formatTime(os.clock() - scriptStartTime)
    local pingMs = math.floor((LocalPlayer:GetNetworkPing() or 0) * 1000 + 0.5)
    local lavaStr = lavaFound and "Ready" or "Scanning..."
    local featStr = getFeatureCodes()
    local msg = table.concat({
        "UPTIME : " .. uptimeStr,
        "LAVA : " .. lavaStr,
        string.format("PING : %d ms", pingMs),
        string.format("FPS : %d", currentFPS),
        "FITUR : " .. featStr
    }, "
")
    return msg
end
---------------------------------------------------------
-- MAP / CAMP SCANNER
---------------------------------------------------------
local function scanCampground()
    local map = Workspace:FindFirstChild("Map")
    if not map then
        warn("[Scan] workspace.Map tidak ditemukan.")
        return
    end
    local camp = map:FindFirstChild("Campground")
    if not camp then
        warn("[Scan] Map.Campground tidak ditemukan.")
        return
    end
    local descendants = camp:GetDescendants()
    local lines = {}
    table.insert(lines, string.format("[Scan] Map.Campground - total %d descendants
", #descendants))
    for _, inst in ipairs(descendants) do
        local path = getInstancePath(inst)
        local line = string.format("%s | %s", path, inst.ClassName)
        table.insert(lines, line)
    end
    local text = table.concat(lines, "
")
    print(text)
    if typeof(setclipboard) == "function" then
        pcall(setclipboard, text)
        print("[Scan] List Campground dicopy ke clipboard.")
    else
        print("[Scan] setclipboard tidak tersedia, copy manual dari console.")
    end
end
---------------------------------------------------------
-- MAIN UI
---------------------------------------------------------
local function createMainUI()
    if Window then return end
    if WindUI then
        Window = WindUI:CreateWindow({
            Title = "Papi Dimz |HUB",
            Icon = "gamepad-2",
            Author = "Bang Dimz",
            Folder = "PapiDimz_HUB_Config",
            Size = UDim2.fromOffset(600, 420),
            Theme = "Dark",
            Transparent = true,
            Acrylic = true,
            SideBarWidth = 180,
            HasOutline = true,
        })
        Window:EditOpenButton({
            Title = "Papi Dimz |HUB",
            Icon = "sparkles",
            CornerRadius = UDim.new(0, 16),
            StrokeThickness = 2,
            Color = ColorSequence.new(Color3.fromRGB(255, 15, 123), Color3.fromRGB(248, 155, 41)),
            OnlyMobile = true,
            Enabled = true,
            Draggable = true,
        })
        mainTab = Window:Tab({ Title = "Main", Icon = "settings-2" })
        localTab = Window:Tab({ Title = "Local Player", Icon = "user" })
        fishingTab = Window:Tab({ Title = "Fishing", Icon = "fish" })
        farmTab = Window:Tab({ Title = "Farm", Icon = "chef-hat" })
        utilTab = Window:Tab({ Title = "Tools", Icon = "wrench" })
        nightTab = Window:Tab({ Title = "Night", Icon = "moon" })
        webhookTab = Window:Tab({ Title = "Webhook", Icon = "radio" })
        healthTab = Window:Tab({ Title = "Cek Health", Icon = "activity" })
        bringTab = Window:Tab({ Title = "Bring Item", Icon = "hand" })
        teleportTab = Window:Tab({ Title = "Teleport", Icon = "navigation" })
        updateTab = Window:Tab({ Title = "Update Focused", Icon = "snowflake" }) -- Added Update Focused Tab
    end
    if WindUI and mainTab then
        -- MAIN TAB
        mainTab:Paragraph({ Title = "Papi Dimz HUB", Desc = "Godmode, AntiAFK, Auto Sacrifice Lava, Auto Farm, Aura, Webhook DayDisplay.
Hotkey PC: P untuk toggle UI.", Color = "Grey" })
        mainTab:Toggle({ Title = "GodMode (Damage -∞)", Icon = "shield", Default = false, Callback = function(state) GodmodeEnabled = state end })
        mainTab:Toggle({ Title = "Anti AFK", Icon = "mouse-pointer-2", Default = true, Callback = function(state) AntiAFKEnabled = state end })
        mainTab:Button({ Title = "Tutup UI & Matikan Script", Icon = "power", Variant = "Destructive", Callback = resetAll })
        -- LOCAL PLAYER TAB
        localTab:Paragraph({ Title = "Self", Desc = "Atur FOV kamera.", Color = "Grey" })
        localTab:Toggle({ Title = "FOV", Icon = "zoom-in", Default = false, Callback = function(state) fovEnabled = state; applyFOV() end })
        localTab:Slider({ Title = "FOV", Description = "40 - 120", Step = 1, Value = { Min = 40, Max = 120, Default = 60 }, Callback = function(v) fovValue = v; applyFOV() end })
        localTab:Paragraph({ Title = "Movement", Desc = "WalkSpeed, Fly, TP Walk, Noclip, Infinite Jump, Hip Height.", Color = "Grey" })
        localTab:Toggle({ Title = "Speed", Icon = "rabbit", Default = false, Callback = function(state) walkEnabled = state; applyWalkspeed() end })
        localTab:Slider({ Title = "Walk Speed", Description = "16 - 200", Step = 1, Value = { Min = 16, Max = 200, Default = 30 }, Callback = function(v) walkSpeedValue = v; applyWalkspeed() end })
        localTab:Toggle({ Title = "Fly", Icon = "plane", Default = false, Callback = function(state) if state then startFly() else stopFly() end end })
        localTab:Slider({ Title = "Fly Speed", Description = "16 - 200", Step = 1, Value = { Min = 16, Max = 200, Default = 50 }, Callback = function(v) flySpeedValue = v end })
        localTab:Toggle({ Title = "TP Walk", Icon = "mouse-pointer-2", Default = false, Callback = function(state) if state then startTPWalk() else stopTPWalk() end end })
        localTab:Slider({ Title = "TP Walk Speed", Description = "1 - 30", Step = 1, Value = { Min = 1, Max = 30, Default = 5 }, Callback = function(v) tpWalkSpeedValue = v end })
        localTab:Toggle({ Title = "Noclip", Icon = "ghost", Default = false, Callback = function(state) noclipManualEnabled = state; updateNoclipConnection() end })
        localTab:Toggle({ Title = "Infinite Jump", Icon = "chevron-up", Default = false, Callback = function(state) if state then startInfiniteJump() else stopInfiniteJump() end end })
        localTab:Toggle({ Title = "Hip Height", Icon = "align-vertical-justify-center", Default = false, Callback = function(state) hipEnabled = state; applyHipHeight() end })
        localTab:Slider({ Title = "Hip Height Value", Description = "0 - 60", Step = 1, Value = { Min = 0, Max = 60, Default = 35 }, Callback = function(v) hipValue = v; applyHipHeight() end })
        localTab:Paragraph({ Title = "Visual", Desc = "Fullbright, Remove Fog/Sky.", Color = "Grey" })
        localTab:Toggle({ Title = "Fullbright", Icon = "sun", Default = false, Callback = function(state) if state then enableFullBright() else disableFullBright() end end })
        localTab:Button({ Title = "Remove Fog", Icon = "wind", Callback = removeFog })
        localTab:Button({ Title = "Remove Sky", Icon = "cloud-off", Callback = removeSky })
        localTab:Paragraph({ Title = "Misc", Desc = "Instant Open, Reset.", Color = "Grey" })
        localTab:Toggle({ Title = "Instant Open (ProximityPrompt)", Icon = "bolt", Default = false, Callback = function(state) if state then enableInstantOpen() else disableInstantOpen() end end })
        -- FISHING TAB
        fishingTab:Paragraph({ Title = "Fishing & Macro", Desc = "Sistem fishing otomatis dengan 100% success rate (zona hijau), auto recast, dan auto clicker.", Color = "Grey" })
        fishingTab:Toggle({ Title = "100% Success Rate", Default = false, Callback = function(state) if state then startZone() else stopZone() end end })
        fishingTab:Toggle({ Title = "Auto Recast", Default = false, Callback = function(state) autoRecastEnabled = state end })
        fishingTab:Input({ Title = "Recast Delay (s)", Placeholder = "2", Default = "2", Callback = function(text) local n = tonumber(text) if n and n >= 0.01 and n <= 60 then RECAST_DELAY = n end end })
        fishingTab:Toggle({ Title = "View Position Overlay", Default = false, Callback = function(state) fishingOverlayVisible = state if state and fishingSavedPosition then fishingShowOverlay(fishingSavedPosition.x, fishingSavedPosition.y) else fishingHideOverlay() end end })
        fishingTab:Button({ Title = "Set Position", Callback = function() waitingForPosition = not waitingForPosition notifyUI("Set Position", waitingForPosition and "Klik layar untuk set posisi." or "Dibatalkan.", 3) end })
        fishingTab:Toggle({ Title = "Auto Clicker", Default = false, Callback = function(state) fishingAutoClickEnabled = state end })
        fishingTab:Input({ Title = "Delay (s)", Placeholder = "5", Default = "5", Callback = function(text) local n = tonumber(text) if n and n >= 0.01 and n <= 600 then fishingClickDelay = n end end })
        fishingTab:Button({ Title = "Calibrate", Callback = function()
            local cam = Workspace.CurrentCamera
            local cx = cam.ViewportSize.X / 2
            local cy = cam.ViewportSize.Y / 2
            notifyUI("Calibrate", "Klik titik merah di tengah layar.", 4)
            local gui = Instance.new("ScreenGui")
            gui.Name = "Xeno_Calib"
            gui.Parent = LocalPlayer.PlayerGui
            local marker = Instance.new("Frame", gui)
            marker.Size = UDim2.new(0,24,0,24)
            marker.Position = UDim2.new(0,cx-12,0,cy-12)
            marker.AnchorPoint = Vector2.new(0.5,0.5)
            marker.BackgroundColor3 = Color3.fromRGB(255,0,0)
            Instance.new("UICorner", marker).CornerRadius = UDim.new(1,0)
            local conn
            conn = UserInputService.InputBegan:Connect(function(inp,gp)
                if gp then return end
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local loc = UserInputService:GetMouseLocation()
                    fishingOffsetX = cx - loc.X
                    fishingOffsetY = cy - loc.Y
                    notifyUI("Calibrate Done", ("Offset X=%.1f Y=%.1f"):format(fishingOffsetX, fishingOffsetY), 4)
                    conn:Disconnect()
                    gui:Destroy()
                    if fishingOverlayVisible and fishingSavedPosition then fishingShowOverlay(fishingSavedPosition.x, fishingSavedPosition.y) end
                end
            end)
        end })
        fishingTab:Button({ Title = "Clean Fishing", Variant = "Destructive", Callback = function()
            fishingAutoClickEnabled = false
            waitingForPosition = false
            fishingSavedPosition = nil
            stopZone()
            fishingHideOverlay()
            pcall(function() LocalPlayer.PlayerGui.XenoPositionOverlay:Destroy() end)
            notifyUI("Fishing Clean", "Fishing features dibersihkan.", 3)
        end })
                -- FARM TAB (original)
        farmTab:Toggle({ Title = "Auto Crockpot (Carrot + Corn)", Icon = "flame", Default = false, Callback = function(state)
            if scriptDisabled then return end
            if state then
                local ok = ensureCookingStations()
                if not ok then AutoCookEnabled = false; notifyUI("Auto Crockpot", "Crock Pot / Chefs Station tidak ditemukan.", 4, "alert-triangle"); return end
                AutoCookEnabled = true; startCookLoop()
            else AutoCookEnabled = false end
        end })
        farmTab:Toggle({ Title = "Auto Scrapper → Grinder", Icon = "recycle", Default = false, Callback = function(state)
            if scriptDisabled then return end
            if state then
                local ok = ensureScrapperTarget()
                if not ok then ScrapEnabled = false; notifyUI("Auto Scrapper", "Scrapper target tidak ditemukan.", 4, "alert-triangle"); return end
                ScrapEnabled = true; startScrapLoop()
            else ScrapEnabled = false end
        end })
        farmTab:Toggle({ Title = "Auto Sacrifice Lava (Ikan & Loot)", Icon = "flame-kindling", Default = false, Callback = function(state)
            if scriptDisabled then return end
            if state and not lavaFound then notifyUI("Auto Sacrifice", "Lava belum ditemukan, script akan aktif begitu lava ready.", 4, "alert-triangle") end
            AutoSacEnabled = state
        end })
        farmTab:Toggle({ Title = "Ultra Fast Coin & Ammo", Icon = "zap", Default = false, Callback = function(state) if scriptDisabled then return end; if state then startCoinAmmo() else stopCoinAmmo() end end })
        farmTab:Paragraph({ Title = "Scrap Priority", Desc = table.concat(ScrapItemsPriority, ", "), Color = "Grey" })
        farmTab:Paragraph({ Title = "Combat Aura", Desc = "Kill Aura & Chop Aura untuk clear musuh dan tebang pohon otomatis.
Radius bisa diatur dari 50 sampai 200.", Color = "Grey" })
        farmTab:Toggle({ Title = "Kill Aura (Radius-based)", Icon = "swords", Default = false, Callback = function(state) if scriptDisabled then return end; KillAuraEnabled = state end })
        farmTab:Slider({ Title = "Kill Aura Radius", Description = "Jarak Kill Aura (50 - 200).", Step = 1, Value = { Min = 50, Max = 200, Default = KillAuraRadius }, Callback = function(value) KillAuraRadius = tonumber(value) or KillAuraRadius end })
        farmTab:Toggle({ Title = "Chop Aura (Small Tree)", Icon = "axe", Default = false, Callback = function(state) if scriptDisabled then return end; ChopAuraEnabled = state; if state then buildTreeCache() else TreeCache = {} end end })
        farmTab:Slider({ Title = "Chop Aura Radius", Description = "Jarak tebang otomatis (50 - 200).", Step = 1, Value = { Min = 50, Max = 200, Default = ChopAuraRadius }, Callback = function(value) ChopAuraRadius = tonumber(value) or ChopAuraRadius end })

        -- BRING ITEM TAB (from anjing.txt)
        if bringTab then
            local setSec = bringTab:Section({Title="Bring Setting", Icon="settings", DefaultOpen=true})
            setSec:Dropdown({
                Title="Location",
                Values={"Player","Workbench","Fire"},
                Value="Player",
                Callback=function(v) selectedLocation=v end
            })
            setSec:Input({
                Title="Bring Height",
                Default="20",
                Numeric=true,
                Callback=function(v) BringHeight=tonumber(v) or 20 end
            })

            -- Cultist Section
            do
                local list={"All","Crossbow Cultist","Cultist"}
                local sel={"All"}
                local sec=bringTab:Section({Title="Bring Cultist",Icon="skull",Collapsible=true})
                sec:Dropdown({Title="Pilih Cultist",Values=list,Value={"All"},Multi=true,AllowNone=true,Callback=function(v)sel=v or{"All"}end})
                sec:Button({Title="Bring Cultist",Callback=function()bringItems(list,sel,selectedLocation)end})
            end
            -- Meteor Section
            do
                local list={"All","Raw Obsidiron Ore","Gold Shard","Meteor Shard","Scalding Obsidiron Ingot"}
                local sel={"All"}
                local sec=bringTab:Section({Title="Bring Meteor Items",Icon="zap",Collapsible=true})
                sec:Dropdown({Title="Pilih Item",Values=list,Value={"All"},Multi=true,AllowNone=true,Callback=function(v)sel=v or{"All"}end})
                sec:Button({Title="Bring Meteor",Callback=function()bringItems(list,sel,selectedLocation)end})
            end
            -- Fuel + Logs Only Section
            do
                local list={"All","Log","Coal","Chair","Fuel Canister","Oil Barrel"}
                local sel={"All"}
                local sec=bringTab:Section({Title="Fuels",Icon="flame",Collapsible=true})
                sec:Dropdown({Title="Pilih Fuel",Values=list,Value={"All"},Multi=true,AllowNone=true,Callback=function(v)sel=v or{"All"}end})
                sec:Button({Title="Bring Fuels",Callback=function()bringItems(list,sel,selectedLocation)end})
                sec:Button({Title="Bring Logs Only",Callback=function()bringItems(list,{"Log"},selectedLocation)end})
            end
            -- Food (FULL) Section
            do
                local list={
                    "All","Sweet Potato","Stuffing","Turkey Leg","Carrot","Pumkin","Mackerel",
                    "Salmon","Swordfish","Berry","Ribs","Stew","Steak Dinner","Morsel","Steak",
                    "Corn","Cooked Morsel","Cooked Steak","Chilli","Apple","Cake"
                }
                local sel={"All"}
                local sec=bringTab:Section({Title="Food",Icon="drumstick",Collapsible=true})
                sec:Dropdown({Title="Pilih Food",Values=list,Value={"All"},Multi=true,AllowNone=true,Callback=function(v)sel=v or{"All"}end})
                sec:Button({Title="Bring Food",Callback=function()bringItems(list,sel,selectedLocation)end})
            end
            -- Healing Section
            do
                local list={"All","Medkit","Bandage"}
                local sel={"All"}
                local sec=bringTab:Section({Title="Healing",Icon="heart",Collapsible=true})
                sec:Dropdown({Title="Pilih Healing",Values=list,Value={"All"},Multi=true,AllowNone=true,Callback=function(v)sel=v or{"All"}end})
                sec:Button({Title="Bring Healing",Callback=function()bringItems(list,sel,selectedLocation)end})
            end
            -- Gears Section
            do
                local list={
                    "All","Bolt","Tyre","Sheet Metal","Old Radio","Broken Fan","Broken Microwave",
                    "Washing Machine","Old Car Engine","UFO Scrap","UFO Component","UFO Junk",
                    "Cultist Gem","Gem of the Forest"
                }
                local sel={"All"}
                local sec=bringTab:Section({Title="Gears (Scrap)",Icon="wrench",Collapsible=true})
                sec:Dropdown({Title="Pilih Gear",Values=list,Value={"All"},Multi=true,AllowNone=true,Callback=function(v)sel=v or{"All"}end})
                sec:Button({Title="Bring Gears",Callback=function()bringItems(list,sel,selectedLocation)end})
            end
            -- Guns & Ammo Section
            do
                local list={
                    "All","Infernal Sword","Morningstar","Crossbow","Infernal Crossbow","Laser Sword",
                    "Raygun","Ice Axe","Ice Sword","Chainsaw","Strong Axe","Axe Trim Kit","Spear",
                    "Good Axe","Revolver","Rifle","Tactical Shotgun","Revolver Ammo","Rifle Ammo",
                    "Alien Armour","Frog Boots","Leather Body","Iron Body","Thorn Body",
                    "Riot Shield","Armour Trim Kit","Obsidiron Boots"
                }
                local sel={"All"}
                local sec=bringTab:Section({Title="Guns & Ammo",Icon="swords",Collapsible=true})
                sec:Dropdown({Title="Pilih Weapon",Values=list,Value={"All"},Multi=true,AllowNone=true,Callback=function(v)sel=v or{"All"}end})
                sec:Button({Title="Bring Guns & Ammo",Callback=function()bringItems(list,sel,selectedLocation)end})
            end
            -- Other Section
            do
                local list={
                    "All","Purple Fur Tuft","Halloween Candle","Candy","Frog Key","Feather",
                    "Wildfire","Sacrifice Totem","Old Rod","Flower","Coin Stack","Infernal Sack",
                    "Giant Sack","Good Sack","Seed Box","Chainsaw","Old Flashlight",
                    "Strong Flashlight","Bunny Foot","Wolf Pelt","Bear Pelt","Mammoth Tusk",
                    "Alpha Wolf Pelt","Bear Corpse","Meteor Shard","Gold Shard",
                    "Raw Obsidiron Ore","Gem of the Forest","Diamond","Defense Blueprint"
                }
                local sel={"All"}
                local sec=bringTab:Section({Title="Bring Other",Icon="package",Collapsible=true})
                sec:Dropdown({Title="Pilih Item",Values=list,Value={"All"},Multi=true,AllowNone=true,Callback=function(v)sel=v or{"All"}end})
                sec:Button({Title="Bring Other",Callback=function()bringItems(list,sel,selectedLocation)end})
            end
        end -- End Bring Tab

        -- TELEPORT TAB (from anjing.txt)
        if teleportTab then
            -- LOST CHILD Section
            local lostChildSec = teleportTab:Section({
                Title = "Teleport Lost Child",
                Icon = "baby",
                Collapsible = true,
                DefaultOpen = true
            })
            local childOptions = {"DinoKid", "KoalaKid", "KrakenKid", "SquidKid"}
            local selectedChild = "DinoKid"
            lostChildSec:Dropdown({
                Title = "Select Child",
                Values = childOptions,
                Value = "DinoKid",
                Callback = function(v)
                    selectedChild = v
                end
            })
            lostChildSec:Button({
                Title = "Teleport To Child",
                Callback = function()
                    local chars = Workspace:FindFirstChild("Characters")
                    if not chars then return end
                    local targetHRP = nil
                    if selectedChild == "DinoKid" then
                        targetHRP = chars:FindFirstChild("Lost Child")
                    elseif selectedChild == "KoalaKid" then
                        targetHRP = chars:FindFirstChild("Lost Child4")
                    elseif selectedChild == "KrakenKid" then
                        targetHRP = chars:FindFirstChild("Lost Child2")
                    elseif selectedChild == "SquidKid" then
                        targetHRP = chars:FindFirstChild("Lost Child3")
                    end
                    local hrp = targetHRP and targetHRP:FindFirstChild("HumanoidRootPart")
                    teleportToCFrame(hrp and hrp.CFrame)
                end
            })

            -- STRUCTURE TELEPORT Section
            local structureSec = teleportTab:Section({
                Title = "Structure Teleport",
                Icon = "castle",
                Collapsible = true,
                DefaultOpen = false
            })
            -- CAMP
            structureSec:Button({
                Title = "Teleport to Camp",
                Callback = function()
                    local fire = Workspace:FindFirstChild("Map")
                        and Workspace.Map:FindFirstChild("Campground")
                        and Workspace.Map.Campground:FindFirstChild("MainFire")
                        and Workspace.Map.Campground.MainFire:FindFirstChild("OuterTouchZone")
                    teleportToCFrame(fire and fire.CFrame)
                end
            })
            -- CULTIST GENERATOR
            structureSec:Button({
                Title = "Teleport to Cultist Generator Base",
                Callback = function()
                    local cg = Workspace:FindFirstChild("Map")
                        and Workspace.Map:FindFirstChild("Landmarks")
                        and Workspace.Map.Landmarks:FindFirstChild("CultistGenerator")
                    teleportToCFrame(cg and cg.PrimaryPart and cg.PrimaryPart.CFrame)
                end
            })
            -- STRONGHOLD
            structureSec:Button({
                Title = "Teleport to Stronghold",
                Callback = function()
                    local sign = Workspace:FindFirstChild("Map")
                        and Workspace.Map:FindFirstChild("Landmarks")
                        and Workspace.Map.Landmarks:FindFirstChild("Stronghold")
                        and Workspace.Map.Landmarks.Stronghold:FindFirstChild("Building")
                        and Workspace.Map.Landmarks.Stronghold.Building:FindFirstChild("Sign")
                        and Workspace.Map.Landmarks.Stronghold.Building.Sign:FindFirstChild("Main")
                    teleportToCFrame(sign and sign.CFrame)
                end
            })
            -- STRONGHOLD DIAMOND CHEST
            structureSec:Button({
                Title = "Teleport to Stronghold Diamond Chest",
                Callback = function()
                    local chest = Workspace:FindFirstChild("Items")
                        and Workspace.Items:FindFirstChild("Stronghold Diamond Chest")
                    teleportToCFrame(chest and chest.CFrame)
                end
            })
            -- CARAVAN
            structureSec:Button({
                Title = "Teleport to Caravan",
                Callback = function()
                    local caravan = Workspace:FindFirstChild("Map")
                        and Workspace.Map:FindFirstChild("Landmarks")
                        and Workspace.Map.Landmarks:FindFirstChild("Caravan")
                    teleportToCFrame(caravan and caravan.PrimaryPart and caravan.PrimaryPart.CFrame)
                end
            })
            -- FAIRY
            structureSec:Button({
                Title = "Teleport to Fairy",
                Callback = function()
                    local fairy = Workspace:FindFirstChild("Map")
                        and Workspace.Map:FindFirstChild("Landmarks")
                        and Workspace.Map.Landmarks:FindFirstChild("Fairy House")
                        and Workspace.Map.Landmarks["Fairy House"]:FindFirstChild("Fairy")
                        and Workspace.Map.Landmarks["Fairy House"].Fairy:FindFirstChild("HumanoidRootPart")
                    teleportToCFrame(fairy and fairy.CFrame)
                end
            })
            -- ANVIL
            structureSec:Button({
                Title = "Teleport to Anvil",
                Callback = function()
                    local anvil = Workspace:FindFirstChild("Map")
                        and Workspace.Map:FindFirstChild("Landmarks")
                        and Workspace.Map.Landmarks:FindFirstChild("ToolWorkshop")
                        and Workspace.Map.Landmarks.ToolWorkshop:FindFirstChild("Functional")
                        and Workspace.Map.Landmarks.ToolWorkshop.Functional:FindFirstChild("ToolBench")
                        and Workspace.Map.Landmarks.ToolWorkshop.Functional.ToolBench:FindFirstChild("Hammer")
                    teleportToCFrame(anvil and anvil.CFrame)
                end
            })
        end -- End Teleport Tab

        -- UPDATE FOCUSED TAB (from anjing.txt)
        if updateTab then
            local christmasSec = updateTab:Section({Title="Christmas",Icon="gift",DefaultOpen=true})
            christmasSec:Button({
                Title="Teleport to Christmas Present",
                Callback=function()
                    local p = Workspace.Items:FindFirstChild("ChristmasPresent1")
                    local part = p and (p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart",true))
                    teleportToCFrame(part and part.CFrame)
                end
            })
            christmasSec:Button({
                Title="Teleport to Santa's Sack",
                Callback=function()
                    local sled = Workspace.Map.Landmarks["Santa's Sack"].SantaSack.Sled
                    teleportToCFrame(
                        (sled.Rail and sled.Rail.Part and sled.Rail.Part.CFrame)
                        or (sled.Engine and sled.Engine.CFrame)
                    )
                end
            })
            local optList={"North Pole","Elf Tree","Elf Ice Lake","Elf Ice Race"}
            local selectedOpt="North Pole"
            christmasSec:Dropdown({
                Title="Teleport Options",
                Values=optList,
                Value="North Pole",
                Callback=function(v)selectedOpt=v end
            })
            christmasSec:Button({
                Title="Teleport",
                Callback=function()
                    local t=nil
                    if selectedOpt=="North Pole" then
                        local np = Workspace.Map.Landmarks:FindFirstChild("North Pole")
                            and Workspace.Map.Landmarks["North Pole"]:FindFirstChild("Festive Carpet Blueprint")
                        t =
                            np and np:FindFirstChild("GraphLines")
                            or np and np:FindFirstChild("Star")
                    elseif selectedOpt=="Elf Tree" then
                        t=Workspace.Map.Landmarks["Elf Tree"].Trees["Northern Pine"].TrunkPart
                    elseif selectedOpt=="Elf Ice Lake" then
                        local l=Workspace.Map.Landmarks["Elf Ice Lake"]
                        t=l:FindFirstChild("Main") or l.GrassFolder:FindFirstChild("Grass")
                    elseif selectedOpt=="Elf Ice Race" then
                        t=Workspace.Map.Landmarks["Elf Ice Race"].Obstacles.SnowStoneTall.Part
                    end
                    teleportToCFrame(t and t.CFrame)
                end
            })
            local mazeSec = updateTab:Section({Title="Maze",Icon="map"})
            mazeSec:Button({
                Title="TP to End",
                Callback=function()
                    local chest = Workspace.Items:FindFirstChild("Halloween Maze Chest")
                    local target =
                        chest and chest:FindFirstChild("Main")
                        or chest and chest:FindFirstChild("ItemDrop")
                    teleportToCFrame(target and target.CFrame)
                end
            })
        end -- End Update Focused Tab

        -- TOOLS TAB (original)
        utilTab:Button({ Title = "Scan Map.Campground (Copy List)", Icon = "scan-line", Callback = function() if scriptDisabled then return end; notifyUI("Scanner", "Scan mulai... cek console / clipboard.", 4, "radar"); scanCampground() end })
        -- NIGHT TAB (original)
        nightTab:Toggle({ Title = "Auto Skip Malam (Temporal)", Icon = "moon-star", Default = false, Callback = function(state)
            if scriptDisabled then return end
            autoTemporalEnabled = state
            notifyUI("Auto Skip Malam", state and "Aktif: auto trigger saat Day naik." or "Dimatikan.", 4, state and "moon" or "toggle-left")
        end })
        nightTab:Button({ Title = "Trigger Temporal Sekali (Manual)", Icon = "zap", Callback = function() if scriptDisabled then return end; activateTemporal() end })
        -- WEBHOOK TAB (original)
        webhookTab:Input({ Title = "Discord Webhook URL", Icon = "link", Placeholder = WebhookURL, Numeric = false, Finished = false, Callback = function(txt) local t = trim(txt or "") if t ~= "" then WebhookURL = t; notifyUI("Webhook", "URL disimpan.", 3, "link"); print("WebhookURL set:", WebhookURL) end end })
        webhookTab:Input({ Title = "Webhook Username (opsional)", Icon = "user", Placeholder = WebhookUsername, Numeric = false, Finished = false, Callback = function(txt) local t = trim(txt or "") if t ~= "" then WebhookUsername = t end; notifyUI("Webhook", "Username disimpan: " .. tostring(WebhookUsername), 3, "user") end })
        webhookTab:Toggle({ Title = "Enable Webhook DayDisplay", Icon = "radio", Default = WebhookEnabled, Callback = function(state) WebhookEnabled = state; notifyUI("Webhook", state and "Webhook diaktifkan." or "Webhook dimatikan.", 3, state and "check-circle-2" or "x-circle") end })
        webhookTab:Button({ Title = "Test Send Webhook", Icon = "flask-conical", Callback = function()
            if scriptDisabled then return end
            local players = Players:GetPlayers(); local names = {}
            for _, p in ipairs(players) do table.insert(names, p.Name) end
            local payload = { username = WebhookUsername, embeds = {{ title = "🧪 TEST - Webhook Aktif " .. tostring(WebhookUsername), description = ("**Webhook Aktif %s**
**Progress:** `%s`
**Pemain Aktif:**
%s"):format(tostring(WebhookUsername), tostring(currentDayCached), namesToVerticalList(names)), color = 0x2ECC71, footer = { text = "Test sent: " .. os.date("%Y-%m-%d %H:%M:%S") }}}}
            local ok, msg = sendWebhookPayload(payload)
            if ok then notifyUI("Webhook Test", "Terkirim: " .. tostring(msg), 5, "check-circle-2"); print("Webhook Test success:", msg)
            else notifyUI("Webhook Test Failed", tostring(msg), 8, "alert-triangle"); warn("Webhook Test failed:", msg) end
        end})
        -- HEALTH TAB (original)
        healthTab:Paragraph({ Title = "Cek Health Script", Desc = "Klik tombol di bawah buat lihat status terbaru:
- Uptime
- Lava Ready / Scanning
- Ping
- FPS
- Fitur aktif (Godmode, AFK, Farm, Aura, dll)
Mini panel di kiri layar juga selalu update realtime.", Color = "Grey" })
        healthTab:Button({ Title = "Refresh Status Sekarang", Icon = "activity", Callback = function() if scriptDisabled then return end; local msg = getStatusSummary(); notifyUI("Status Script", msg, 7, "activity"); print("[PapiDimz] Status:
" .. msg) end })
        -- Hotkey & Cleanup
        UserInputService.InputBegan:Connect(function(input, gp)
            if gp or scriptDisabled then return end
            if input.KeyCode == Enum.KeyCode.P then
                pcall(function() Window:Toggle() end)
            end
        end)
        Window:OnDestroy(resetAll)
    end
end
---------------------------------------------------------
-- INITIAL NON-BLOCKING RESOURCE WATCHERS
---------------------------------------------------------
backgroundFind(ReplicatedStorage, "RemoteEvents", function(re)
    if scriptDisabled then return end
    RemoteEvents = re
    notifyUI("Init", "RemoteEvents ditemukan.", 3, "radio")
    RequestStartDragging = re:FindFirstChild("RequestStartDraggingItem")
    RequestStopDragging = re:FindFirstChild("StopDraggingItem")
    CollectCoinRemote = re:FindFirstChild("RequestCollectCoints")
    ConsumeItemRemote = re:FindFirstChild("RequestConsumeItem")
    NightSkipRemote = re:FindFirstChild("RequestActivateNightSkipMachine")
    ToolDamageRemote = re:FindFirstChild("ToolDamageObject")
    EquipHandleRemote = re:FindFirstChild(" EquipItemHandle")
    tryHookDayDisplay()
end)
backgroundFind(Workspace, "Items", function(it)
    if scriptDisabled then return end
    ItemsFolder = it
    notifyUI("Init", "Items folder ditemukan.", 3, "archive")
end)
backgroundFind(Workspace, "Structures", function(st)
    if scriptDisabled then return end
    Structures = st
    notifyUI("Init", "Structures ditemukan.", 3, "layers")
    TemporalAccelerometer = st:FindFirstChild("Temporal Accelerometer")
end)
task.spawn(function() if not scriptDisabled then tryHookDayDisplay() end end)
startGodmodeLoop()
---------------------------------------------------------
-- INIT
---------------------------------------------------------
LocalPlayer.CharacterAdded:Connect(function(char)
    if scriptDisabled then return end
    task.wait(0.5)
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    defaultWalkSpeed = humanoid.WalkSpeed
    defaultHipHeight = humanoid.HipHeight
    applyWalkspeed()
    applyHipHeight()
    applyFOV()
    if flyEnabled then task.delay(0.2, startFly) end
end)
if LocalPlayer.Character then
    if scriptDisabled then return end
    humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoid then defaultWalkSpeed = humanoid.WalkSpeed; defaultHipHeight = humanoid.HipHeight end
end
print("[PapiDimz] HUB Loaded - All-in-One (with Bring & Teleport)")
splashScreen()
if WindUI then -- <--- Hanya buat UI jika WindUI berhasil dimuat
    createMainUI()
    createMiniHud()
    startMiniHudLoop()
else
    print("[PapiDimz] WindUI gagal dimuat (embedded), UI tidak dibuat. Fungsi utama masih aktif jika tidak menggunakan UI.")
    -- Opsional: Tambahkan notifikasi fallback bahwa UI tidak muncul
    createFallbackNotify("WindUI (embedded) failed, UI not created. Check console.")
end
initAntiAFK()
-- (all original background watchers and loops start here)
notifyUI("Papi Dimz |HUB", "Semua fitur loaded: Main, Local Player, Fishing, Farm, Bring, Teleport, Tools, Night, Webhook, Health", 6, "sparkles")
