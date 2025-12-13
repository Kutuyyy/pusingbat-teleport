---------------------------------------------------------
-- PAPI DIMZ HUB - MAIN CORE (PART 1)
-- Window + Information Tab + Main Tab + Keybind System
-- WindUI Load ONCE ONLY (IMPORTANT)
---------------------------------------------------------

--// SERVICES
local Players              = game:GetService("Players")
local UserInputService     = game:GetService("UserInputService")
local RunService           = game:GetService("RunService")
local HttpService          = game:GetService("HttpService")
local LocalPlayer          = Players.LocalPlayer
local PlayerGui            = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------------
--// LOAD WINDUI (ONLY ONE INSTANCE)
---------------------------------------------------------
local WINDUI_URL = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"

local WindUI = nil
local ok, uiResult = pcall(function()
    return loadstring(game:HttpGet(WINDUI_URL))()
end)

if ok and uiResult then
    WindUI = uiResult
else
    warn("FAILED LOAD WINDUI")
    return
end

WindUI:SetTheme("Dark")
WindUI.TransparencyValue = 0.15

---------------------------------------------------------
--// WINDOW: PAPI DIMZ HUB
---------------------------------------------------------
local Window = WindUI:CreateWindow({
    Title = "Papi Dimz Hub",
    Icon = "gamepad-2",
    Author = "Bang Dimz",
    Folder = "PapiDimzHub_Config",
    Size = UDim2.fromOffset(600, 540),
    Theme = "Dark",
    Acrylic = true,
    HasOutline = true,
    SideBarWidth = 170
})

Window:EditOpenButton({
    Title = "Papi Dimz Hub",
    Icon = "sparkles",
    CornerRadius = UDim.new(0, 14),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromRGB(255,170,90), Color3.fromRGB(255,114,80)),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

_G.__WindUIWindows = _G.__WindUIWindows or {}
table.insert(_G.__WindUIWindows, Window)

---------------------------------------------------------
--// GLOBAL STATE (for keybind + disable)
---------------------------------------------------------
local scriptEnabled = true
local currentKeybind = Enum.KeyCode.P  -- default keybind
local listeningKey = false

---------------------------------------------------------
--// RESET ALL (EMPTY FOR NOW - FULL IN PART 4)
---------------------------------------------------------
function resetAll()
    -- full cleanup will be written on PART 4
    WindUI:Notify({
        Title = "Force Close",
        Content = "All features disabled. UI closed.",
        Duration = 3,
        Icon = "power"
    })
end

---------------------------------------------------------
--// TAB 1 : INFORMATION
---------------------------------------------------------
local infoTab = Window:Tab({
    Title = "Information",
    Icon = "info"
})

infoTab:Paragraph({
    Title = "Welcome To Papi Dimz Hub Official",
    Desc  = "Powerful all-in-one script created for smooth automation, utilities, and gameplay enhancement. Enjoy your experience!",
    Color = "Grey"
})

---------------------------------------------------------
-- COPY DISCORD LINK
---------------------------------------------------------
infoTab:Button({
    Title = "Copy Discord Link",
    Icon = "clipboard",
    Callback = function()
        setclipboard("discord.gg/PapiDimz")
        WindUI:Notify({
            Title = "Copied!",
            Content = "Discord link copied to clipboard.",
            Duration = 3,
            Icon = "check"
        })
    end
})

---------------------------------------------------------
-- KEYBIND SETTINGS
---------------------------------------------------------
infoTab:Keybind({
    Title = "Papi Dimz Keybind",
    Default = Enum.KeyCode.P,
    Callback = function(key)
        currentKeybind = key
        WindUI:Notify({
            Title = "Keybind Changed",
            Content = "New keybind: " .. tostring(key),
            Duration = 3,
            Icon = "keyboard"
        })
    end
})

-- LISTEN FOR KEY TO TOGGLE UI
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == currentKeybind then
        pcall(function()
            Window:Toggle()
        end)
    end
end)

---------------------------------------------------------
-- FORCE CLOSE
---------------------------------------------------------
infoTab:Button({
    Title = "Force Close Hub",
    Icon = "power",
    Variant = "Destructive",
    Callback = function()
        scriptEnabled = false

        -- run full cleanup (completed in PART 4)
        resetAll()

        -- unload UI fully
        pcall(function()
            Window:Unload()
        end)
    end
})

---------------------------------------------------------
--// TAB 2 : MAIN
---------------------------------------------------------
mainTab = Window:Tab({ 
    Title = "Main", 
    Icon = "settings-2" 
})



mainTab:Paragraph({
    Title = "Papi Dimz Hub Loaded",
    Desc  = "All main modules are active. Navigate tabs on the left to access features.",
    Color = "Grey"
})

mainTab:Toggle({ 
    Title = "GodMode (Damage -∞)", 
    Icon = "shield", 
    Default = false, 
    Callback = function(state) GodmodeEnabled = state end 
})

mainTab:Toggle({ 
    Title = "Anti AFK", 
    Icon = "mouse-pointer-2", 
    Default = true, 
    Callback = function(state) AntiAFKEnabled = state end 
})

local GodmodeEnabled = false

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
-- PART 1 END
---------------------------------------------------------

print("[PapiDimzHub] PART 1 Loaded (Information + Main Tabs Ready)")
---------------------------------------------------------
-- TAB 3 : LOCAL PLAYER
---------------------------------------------------------

local localTab = Window:Tab({
    Title = "Local Player",
    Icon = "user"
})

---------------------------------------------------------
-- LOCAL PLAYER CORE STATE
---------------------------------------------------------
local lp_Players          = game:GetService("Players")
local lp_RunService       = game:GetService("RunService")
local lp_UIS              = game:GetService("UserInputService")
local lp_Lighting         = game:GetService("Lighting")

local lp_LocalPlayer      = lp_Players.LocalPlayer
repeat task.wait() until lp_LocalPlayer.Character

local lp_Camera           = workspace.CurrentCamera

local function lp_getCharacter()
    return lp_LocalPlayer.Character or lp_LocalPlayer.CharacterAdded:Wait()
end

local function lp_getHumanoid()
    return lp_getCharacter():WaitForChild("Humanoid")
end

local function lp_getRoot()
    return lp_getCharacter():WaitForChild("HumanoidRootPart")
end

local lp_humanoid         = lp_getHumanoid()
local lp_rootPart         = lp_getRoot()

---------------------------------------------------------
-- STATE VARIABLES
---------------------------------------------------------
local lp_scriptDisabled        = false

-- FOV
local lp_defaultFOV            = lp_Camera.FieldOfView
local lp_fovEnabled            = false
local lp_fovValue              = 60

-- Walk
local lp_walkEnabled           = false
local lp_walkSpeedValue        = 30
local lp_defaultWalkSpeed      = lp_humanoid.WalkSpeed

-- Fly (STEALTH FLY ORIGINAL KAMU)
local lp_flyEnabled            = false
local lp_flySpeedValue         = 50
local lp_flyConn               = nil
local lp_originalTransparency  = {}
local lp_idleTrack             = nil

-- TP Walk
local lp_tpWalkEnabled         = false
local lp_tpWalkSpeedValue      = 5
local lp_tpWalkConn            = nil

-- Noclip
local lp_noclipManualEnabled   = false
local lp_noclipConn            = nil

-- Infinite Jump
local lp_infiniteJumpEnabled   = false
local lp_infiniteJumpConn      = nil

-- Fullbright
local lp_fullBrightEnabled     = false
local lp_fullBrightConn        = nil

local lp_oldLightingProps = {
    Brightness      = lp_Lighting.Brightness,
    ClockTime       = lp_Lighting.ClockTime,
    FogEnd          = lp_Lighting.FogEnd,
    GlobalShadows   = lp_Lighting.GlobalShadows,
    Ambient         = lp_Lighting.Ambient,
    OutdoorAmbient  = lp_Lighting.OutdoorAmbient
}

-- Hip Height
local lp_hipEnabled            = false
local lp_hipValue              = 35
local lp_defaultHipHeight      = lp_humanoid.HipHeight

-- Instant Open
local lp_instantOpenEnabled    = false
local lp_promptOriginalHold    = {}
local lp_promptConn            = nil


---------------------------------------------------------
-- LOCAL PLAYER UTILS
---------------------------------------------------------
local function lp_zeroVel(part)
    if part and part:IsA("BasePart") then
        part.AssemblyLinearVelocity = Vector3.new(0,0,0)
        part.AssemblyAngularVelocity = Vector3.new(0,0,0)
    end
end


---------------------------------------------------------
-- FOV APPLY
---------------------------------------------------------
local function lp_applyFOV()
    if lp_fovEnabled then
        lp_Camera.FieldOfView = lp_fovValue
    else
        lp_Camera.FieldOfView = lp_defaultFOV
    end
end


---------------------------------------------------------
-- WALK SPEED APPLY
---------------------------------------------------------
local function lp_applyWalk()
    if not lp_humanoid then return end
    if lp_walkEnabled then
        lp_humanoid.WalkSpeed = lp_walkSpeedValue
    else
        lp_humanoid.WalkSpeed = lp_defaultWalkSpeed
    end
end


---------------------------------------------------------
-- HIP HEIGHT APPLY
---------------------------------------------------------
local function lp_applyHip()
    local h = lp_getHumanoid()
    if not h then return end
    if lp_hipEnabled then
        h.HipHeight = lp_hipValue
    else
        h.HipHeight = lp_defaultHipHeight
    end
end


---------------------------------------------------------
-- NOCLIP (USED BY FLY TOO)
---------------------------------------------------------
local function lp_updateNoclip()
    local shouldEnable = (lp_noclipManualEnabled or lp_flyEnabled)

    if shouldEnable and not lp_noclipConn then
        lp_noclipConn = lp_RunService.Stepped:Connect(function()
            local char = lp_getCharacter()
            for _,v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end)

    elseif not shouldEnable and lp_noclipConn then
        lp_noclipConn:Disconnect()
        lp_noclipConn = nil
    end
end


---------------------------------------------------------
-- STEALTH FLY 100% VERSI KAMU (TIDAK DIUBAH)
---------------------------------------------------------

local function lp_setVisibility(flyOn)
    local char = lp_getCharacter()
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if flyOn then
                part.Transparency = 1
                part.LocalTransparencyModifier = 0
            else
                part.Transparency = lp_originalTransparency[part] or 0
                part.LocalTransparencyModifier = 0
            end
        end
    end
end


local function lp_playIdle()
    if lp_idleTrack then lp_idleTrack:Stop() end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://180435571"
    lp_idleTrack = lp_humanoid:LoadAnimation(anim)
    lp_idleTrack.Priority = Enum.AnimationPriority.Core
    lp_idleTrack.Looped = true
    lp_idleTrack:Play()
end


local function lp_startFly()
    if lp_flyEnabled then return end

    lp_flyEnabled = true

    -- SAVE ORIGINAL TRANSPARENCY
    if next(lp_originalTransparency) == nil then
        for _, part in ipairs(lp_getCharacter():GetDescendants()) do
            if part:IsA("BasePart") then
                lp_originalTransparency[part] = part.Transparency
            end
        end
    end

    lp_setVisibility(false) -- Fly ON (versi kamu)
    lp_rootPart.Anchored = true
    lp_humanoid.PlatformStand = true

    lp_updateNoclip()
    lp_playIdle()

    lp_flyConn = lp_RunService.RenderStepped:Connect(function(dt)
        if not lp_flyEnabled then
            return
        end

        local move = Vector3.new(0,0,0)

        if lp_UIS:IsKeyDown(Enum.KeyCode.W) then move += lp_Camera.CFrame.LookVector end
        if lp_UIS:IsKeyDown(Enum.KeyCode.S) then move -= lp_Camera.CFrame.LookVector end
        if lp_UIS:IsKeyDown(Enum.KeyCode.A) then move -= lp_Camera.CFrame.RightVector end
        if lp_UIS:IsKeyDown(Enum.KeyCode.D) then move += lp_Camera.CFrame.RightVector end
        if lp_UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if lp_UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

        if move.Magnitude > 0 then
            move = move.Unit * lp_flySpeedValue * dt
            lp_rootPart.CFrame += move
        end

        lp_rootPart.CFrame = CFrame.new(lp_rootPart.Position) * lp_Camera.CFrame.Rotation
        lp_zeroVel(lp_rootPart)
    end)

    WindUI:Notify({
        Title = "Fly ON",
        Content = "Ultimate Stealth Fly Activated!",
        Duration = 3,
        Icon = "plane"
    })
end


local function lp_stopFly()
    if not lp_flyEnabled then return end

    lp_flyEnabled = false

    if lp_flyConn then
        lp_flyConn:Disconnect()
        lp_flyConn = nil
    end

    if lp_idleTrack then
        lp_idleTrack:Stop()
        lp_idleTrack = nil
    end

    local pos = lp_rootPart.CFrame

    lp_humanoid.PlatformStand = false
    lp_rootPart.Anchored = false

    lp_setVisibility(false)

    lp_updateNoclip()

    WindUI:Notify({
        Title = "Fly OFF",
        Content = "Returned to normal movement.",
        Duration = 3,
        Icon = "plane"
    })
end


---------------------------------------------------------
-- TP WALK
---------------------------------------------------------
local function lp_startTPWalk()
    if lp_tpWalkEnabled then return end
    lp_tpWalkEnabled = true

    lp_tpWalkConn = lp_RunService.RenderStepped:Connect(function(dt)
        if not lp_tpWalkEnabled then return end

        local h = lp_getHumanoid()
        local r = lp_getRoot()
        if not h or not r then return end

        local mv = h.MoveDirection
        if mv.Magnitude > 0 then
            r.CFrame += mv.Unit * (lp_tpWalkSpeedValue * dt * 10)
        end
    end)
end

local function lp_stopTPWalk()
    lp_tpWalkEnabled = false
    if lp_tpWalkConn then lp_tpWalkConn:Disconnect(); lp_tpWalkConn = nil end
end


---------------------------------------------------------
-- INFINITE JUMP
---------------------------------------------------------
local function lp_startInfinite()
    if lp_infiniteJumpEnabled then return end
    lp_infiniteJumpEnabled = true

    lp_infiniteJumpConn = lp_UIS.JumpRequest:Connect(function()
        lp_humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end

local function lp_stopInfinite()
    lp_infiniteJumpEnabled = false
    if lp_infiniteJumpConn then lp_infiniteJumpConn:Disconnect(); lp_infiniteJumpConn = nil end
end


---------------------------------------------------------
-- FULLBRIGHT
---------------------------------------------------------
local function lp_enableFullbright()
    lp_fullBrightEnabled = true

    local function apply()
        if not lp_fullBrightEnabled then return end
        lp_Lighting.Brightness = 2
        lp_Lighting.ClockTime = 14
        lp_Lighting.FogEnd = 1e9
        lp_Lighting.GlobalShadows = false
        lp_Lighting.Ambient = Color3.new(1,1,1)
        lp_Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end

    apply()
    lp_fullBrightConn = lp_RunService.RenderStepped:Connect(apply)
end

local function lp_disableFullbright()
    lp_fullBrightEnabled = false
    if lp_fullBrightConn then lp_fullBrightConn:Disconnect(); lp_fullBrightConn=nil end

    for k,v in pairs(lp_oldLightingProps) do
        lp_Lighting[k] = v
    end
end


---------------------------------------------------------
-- INSTANT OPEN
---------------------------------------------------------
local function lp_applyPrompt(prompt)
    if lp_promptOriginalHold[prompt] == nil then
        lp_promptOriginalHold[prompt] = prompt.HoldDuration
    end
    prompt.HoldDuration = 0
end

local function lp_enableInstant()
    lp_instantOpenEnabled = true

    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then lp_applyPrompt(v) end
    end

    lp_promptConn = workspace.DescendantAdded:Connect(function(obj)
        if lp_instantOpenEnabled and obj:IsA("ProximityPrompt") then
            lp_applyPrompt(obj)
        end
    end)
end


local function lp_disableInstant()
    lp_instantOpenEnabled = false
    if lp_promptConn then lp_promptConn:Disconnect(); lp_promptConn=nil end

    for prompt,orig in pairs(lp_promptOriginalHold) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = orig
        end
    end
    lp_promptOriginalHold = {}
end


---------------------------------------------------------
-- LOCAL PLAYER UI (WindUI)
---------------------------------------------------------

--------------
-- SELF
--------------
localTab:Paragraph({Title="Self",Desc="Adjust your self-properties.",Color="Grey"})

localTab:Toggle({
    Title = "FOV",
    Default = false,
    Callback = function(state) lp_fovEnabled = state lp_applyFOV() end
})

localTab:Slider({
    Title="FOV Value",
    Description="40-120",
    Step=1,
    Value={Min=40,Max=120,Default=lp_fovValue},
    Callback = function(v) lp_fovValue=v lp_applyFOV() end
})

--------------
-- MOVEMENT
--------------
localTab:Paragraph({Title="Movement",Desc="Walkspeed, Fly, TP Walk, Noclip, Infinite Jump.",Color="Grey"})

localTab:Slider({
    Title="Walk Speed",
    Description="16-200",
    Step=1,
    Value={Min=16,Max=200,Default=lp_walkSpeedValue},
    Callback=function(v) lp_walkSpeedValue=v lp_applyWalk() end
})

localTab:Toggle({
    Title="Speed",
    Callback=function(state) lp_walkEnabled=state lp_applyWalk() end
})

localTab:Toggle({
    Title="Fly (Stealth)",
    Icon="plane",
    Callback=function(state)
        if state then lp_startFly() else lp_stopFly() end
    end
})

localTab:Slider({
    Title="Fly Speed",
    Step=1,
    Value={Min=16,Max=200,Default=lp_flySpeedValue},
    Callback=function(v) lp_flySpeedValue=v end
})

localTab:Slider({
    Title="TP Walk Speed",
    Step=1,
    Value={Min=1,Max=30,Default=lp_tpWalkSpeedValue},
    Callback=function(v) lp_tpWalkSpeedValue=v end
})

localTab:Toggle({
    Title="TP Walk",
    Icon="mouse-pointer-2",
    Callback=function(state)
        if state then lp_startTPWalk() else lp_stopTPWalk() end
    end
})

localTab:Toggle({
    Title="Noclip",
    Icon="ghost",
    Callback=function(state)
        lp_noclipManualEnabled=state
        lp_updateNoclip()
    end
})

localTab:Toggle({
    Title="Infinite Jump",
    Icon="chevron-up",
    Callback=function(state)
        if state then lp_startInfinite() else lp_stopInfinite() end
    end
})

localTab:Toggle({
    Title="Hip Height",
    Icon="align-vertical-justify-center",
    Callback=function(state)
        lp_hipEnabled=state
        lp_applyHip()
    end
})

localTab:Slider({
    Title="Hip Height Value",
    Step=1,
    Value={Min=0,Max=60,Default=lp_hipValue},
    Callback=function(v) lp_hipValue=v lp_applyHip() end
})

--------------
-- VISUAL
--------------
localTab:Paragraph({Title="Visual",Desc="Fullbright, Fog removal.",Color="Grey"})

localTab:Toggle({
    Title="Fullbright",
    Icon="sun",
    Callback=function(state)
        if state then lp_enableFullbright() else lp_disableFullbright() end
    end
})

--------------
-- MISC
--------------
localTab:Paragraph({Title="Misc",Desc="InstantOpen & Reset Tools.",Color="Grey"})

localTab:Toggle({
    Title="Instant Open (ProximityPrompt)",
    Icon="bolt",
    Callback=function(state)
        if state then lp_enableInstant() else lp_disableInstant() end
    end
})

localTab:Button({
    Title="Reset All",
    Icon="power",
    Variant="Destructive",
    Callback=function()
        resetAll()
    end
})

print("[PapiDimzHub] PART 2A Loaded: Local Player Ready.")
---------------------------------------------------------
-- TAB 4 : FISHING
---------------------------------------------------------

local fishingTab = Window:Tab({
    Title = "Fishing",
    Icon = "fish"
})

---------------------------------------------------------
-- FISHING STATE
---------------------------------------------------------

local fs_clickDelay            = 5
local fs_autoClickEnabled     = false

local fs_waitingPosition      = false
local fs_savedPos             = nil  -- {x=?, y=?}

local fs_overlayVisible       = false
local fs_offsetX, fs_offsetY  = 0, 0

local fs_zoneEnabled          = false
local fs_zoneDestroyed        = false
local fs_zoneVisibleLast      = false
local fs_zoneSpam             = false
local fs_zoneSpamThread       = nil
local fs_zoneSpamInterval     = 0.04

local fs_autoRecast           = false
local fs_lastTimingVisible    = false
local fs_lastSeenTime         = 0
local fs_lastRecast           = 0
local fs_RECAST_DELAY         = 2
local fs_MAX_RECENT           = 5

local fs_clickThread          = nil

---------------------------------------------------------
-- GUI OVERLAY POINTER
---------------------------------------------------------

local function fs_getOverlay()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end

    if pg:FindFirstChild("PapiDimz_FishOverlay") then
        return pg:FindFirstChild("PapiDimz_FishOverlay")
    end

    local g = Instance.new("ScreenGui")
    g.Name = "PapiDimz_FishOverlay"
    g.ResetOnSpawn = false
    g.IgnoreGuiInset = true
    g.DisplayOrder = 9999
    g.Enabled = false
    g.Parent = pg

    local dot = Instance.new("Frame", g)
    dot.Name = "Dot"
    dot.Size = UDim2.fromOffset(14,14)
    dot.AnchorPoint = Vector2.new(0.5,0.5)
    dot.BackgroundColor3 = Color3.fromRGB(255,60,60)
    dot.BorderSizePixel = 0
    dot.Visible = false
    dot.ZIndex = 9999

    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    return g
end

local function fs_showOverlay(x,y)
    local g = fs_getOverlay()
    if not g then return end

    g.Enabled = true
    local dot = g:FindFirstChild("Dot")
    if dot then
        dot.Visible = true
        dot.Position = UDim2.new(0, math.floor(x + fs_offsetX), 0, math.floor(y + fs_offsetY))
    end
end

local function fs_hideOverlay()
    local g = LocalPlayer.PlayerGui:FindFirstChild("PapiDimz_FishOverlay")
    if g then
        g.Enabled = false
        local dot = g:FindFirstChild("Dot")
        if dot then dot.Visible = false end
    end
end

---------------------------------------------------------
-- SEND CLICK
---------------------------------------------------------

local function fs_click()
    if not fs_savedPos then return end

    local x = math.floor(fs_savedPos.x + fs_offsetX)
    local y = math.floor(fs_savedPos.y + fs_offsetY)

    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(x,y,0,true,game,0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(x,y,0,false,game,0)
    end)
end

---------------------------------------------------------
-- FIND TIMING BAR
---------------------------------------------------------

local function fs_getTiming()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local iface = pg:FindFirstChild("Interface")
    if not iface then return nil end

    local fcf = iface:FindFirstChild("FishingCatchFrame")
    if not fcf then return nil end

    return fcf:FindFirstChild("TimingBar")
end

---------------------------------------------------------
-- ZONE GREEN FULL
---------------------------------------------------------

local function fs_makeGreenFull()
    if not fs_zoneEnabled or fs_zoneDestroyed then return end

    local tb = fs_getTiming()
    if not tb then return end

    local sa = tb:FindFirstChild("SuccessArea")
    if not sa then return end

    pcall(function()
        sa.Size = UDim2.new(0,120,0,330)
        sa.Position = UDim2.new(0,52,0,-5)
        sa.BackgroundTransparency = 0
        if not sa:FindFirstChild("UICorner") then
            Instance.new("UICorner", sa).CornerRadius = UDim.new(0,12)
        end
    end)
end

---------------------------------------------------------
-- ZONE VISIBILITY CHECK
---------------------------------------------------------

local function fs_isTimingVisible()
    if fs_zoneDestroyed then return false end

    local tb = fs_getTiming()
    if not tb then return false end

    local cur = tb
    while cur and cur ~= LocalPlayer.PlayerGui do
        if cur:IsA("ScreenGui") and not cur.Enabled then return false end
        if cur:IsA("GuiObject") and not cur.Visible then return false end
        cur = cur.Parent
    end

    return true
end

---------------------------------------------------------
-- SPAM CLICK UNTIL GONE
---------------------------------------------------------

local function fs_doSpam()
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local v = cam.ViewportSize
    local pt = Vector2.new(v.X/2, v.Y/2)

    pcall(function()
        VirtualUser:Button1Down(pt)
        task.wait(0.02)
        VirtualUser:Button1Up(pt)
    end)
end

local function fs_startSpam()
    if fs_zoneSpam or fs_zoneDestroyed then return end
    fs_zoneSpam = true

    fs_zoneSpamThread = task.spawn(function()
        while fs_zoneSpam and fs_zoneEnabled and not fs_zoneDestroyed do
            if not fs_isTimingVisible() then
                fs_zoneSpam = false
                break
            end
            fs_doSpam()
            task.wait(fs_zoneSpamInterval)
        end
    end)
end

local function fs_stopSpam()
    fs_zoneSpam = false
end

---------------------------------------------------------
-- START ZONE SYSTEM
---------------------------------------------------------

local function fs_startZone()
    fs_zoneEnabled = true
    fs_zoneDestroyed = false

    -- TERUS UPDATE GREEN FULL
    task.spawn(function()
        while fs_zoneEnabled and not fs_zoneDestroyed do
            fs_makeGreenFull()
            task.wait(0.15)
        end
    end)

    -- CHECK TIMINGBAR APPEAR/DISAPPEAR
    task.spawn(function()
        fs_zoneVisibleLast = fs_isTimingVisible()
        fs_lastTimingVisible = fs_zoneVisibleLast

        if fs_zoneVisibleLast then fs_lastSeenTime = tick() end

        while fs_zoneEnabled and not fs_zoneDestroyed do
            task.wait(0.06)

            local nowVisible = fs_isTimingVisible()

            if nowVisible then fs_lastSeenTime = tick() end

            -- Change visibility
            if nowVisible ~= fs_zoneVisibleLast then
                fs_zoneVisibleLast = nowVisible

                -- TIMINGBAR MUNCUL
                if nowVisible then
                    fs_lastTimingVisible = true
                    fs_lastSeenTime = tick()

                    fs_makeGreenFull()
                    fs_startSpam()

                -- TIMINGBAR HILANG
                else
                    fs_stopSpam()

                    -- AUTO RECAST
                    local sinceSeen = tick() - fs_lastSeenTime
                    local sinceRe   = tick() - fs_lastRecast

                    if fs_autoRecast
                    and fs_savedPos
                    and fs_lastTimingVisible
                    and sinceSeen <= fs_MAX_RECENT
                    and sinceRe >= fs_RECAST_DELAY
                    then
                        task.spawn(function()
                            task.wait(fs_RECAST_DELAY)
                            fs_click()
                            fs_lastRecast = tick()
                            notifyUI("Auto Recast", "Recast dilakukan!", 2)
                        end)
                    end

                    fs_lastTimingVisible = false
                end
            end
        end
    end)

    -- Start spam immediately if timing already visible
    task.spawn(function()
        task.wait(0.15)
        if fs_zoneEnabled and fs_isTimingVisible() then fs_startSpam() end
    end)
end


local function fs_stopZone()
    fs_zoneDestroyed = true
    fs_zoneEnabled = false
    fs_stopSpam()
end

---------------------------------------------------------
-- AUTO CLICK SYSTEM
---------------------------------------------------------

fs_clickThread = task.spawn(function()
    while true do
        if fs_autoClickEnabled and fs_savedPos then
            fs_click()
        end
        task.wait(fs_clickDelay)
    end
end)

---------------------------------------------------------
-- INPUT HANDLER FOR SET POSITION
---------------------------------------------------------

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if not fs_waitingPosition then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local loc = UserInputService:GetMouseLocation()
        local vp = Workspace.CurrentCamera.ViewportSize

        fs_savedPos = {
            x = math.clamp(loc.X, 0, vp.X),
            y = math.clamp(loc.Y, 0, vp.Y),
        }

        fs_waitingPosition = false

        notifyUI("Position Set",
            "X="..fs_savedPos.x.." Y="..fs_savedPos.y, 3
        )

        if fs_overlayVisible then
            fs_showOverlay(fs_savedPos.x, fs_savedPos.y)
        end
    end
end)

---------------------------------------------------------
-- FISHING TAB UI
---------------------------------------------------------

fishingTab:Paragraph({
    Title = "Fishing & Macro",
    Desc = "Auto click, 100% success rate, auto recast, pointer overlay.",
    Color = "Grey"
})

-- ===============================
-- GREEN ZONE (100% SUCCESS)
-- ===============================
fishingTab:Toggle({
    Title = "100% Success Rate",
    Default = false,
    Callback = function(state)
        if state then fs_startZone() else fs_stopZone() end
    end
})

-- ===============================
-- AUTO RECAST
-- ===============================
fishingTab:Toggle({
    Title = "Auto Recast",
    Default = false,
    Callback = function(state)
        fs_autoRecast = state
    end
})

fishingTab:Input({
    Title = "Recast Delay (s)",
    Placeholder = "2",
    Default = "2",
    Callback = function(txt)
        local n = tonumber(txt)
        if n and n >= 0.01 and n <= 60 then
            fs_RECAST_DELAY = n
        end
    end
})

-- ===============================
-- POSITION OVERLAY
-- ===============================

fishingTab:Toggle({
    Title = "View Position Overlay",
    Default = false,
    Callback = function(state)
        fs_overlayVisible = state

        if state and fs_savedPos then
            fs_showOverlay(fs_savedPos.x, fs_savedPos.y)
        else
            fs_hideOverlay()
        end
    end
})

-- SET POSITION
fishingTab:Button({
    Title = "Set Position",
    Callback = function()
        fs_waitingPosition = not fs_waitingPosition

        notifyUI(
            "Set Position",
            fs_waitingPosition and "Klik titik posisi di layar." or "Dibatalkan.",
            3
        )
    end
})

-- ===============================
-- AUTO CLICKER
-- ===============================

fishingTab:Toggle({
    Title = "Auto Clicker",
    Default = false,
    Callback = function(state)
        fs_autoClickEnabled = state
    end
})

fishingTab:Input({
    Title = "Delay (s)",
    Placeholder = "5",
    Default = "5",
    Callback = function(txt)
        local n = tonumber(txt)
        if n and n >= 0.01 and n <= 600 then
            fs_clickDelay = n
        end
    end
})

-- ===============================
-- CALIBRATION
-- ===============================
fishingTab:Button({
    Title = "Calibrate",
    Callback = function()

        local cam = Workspace.CurrentCamera
        local cx, cy = cam.ViewportSize.X/2, cam.ViewportSize.Y/2

        notifyUI("Calibrate", "Klik titik merah di tengah layar.", 4)

        local gui = Instance.new("ScreenGui")
        gui.Name = "PapiDimz_Calib"
        gui.Parent = LocalPlayer.PlayerGui

        local marker = Instance.new("Frame")
        marker.Parent = gui
        marker.Size = UDim2.fromOffset(24,24)
        marker.Position = UDim2.new(0,cx-12,0,cy-12)
        marker.BackgroundColor3 = Color3.fromRGB(255,0,0)
        marker.AnchorPoint = Vector2.new(0.5,0.5)
        Instance.new("UICorner", marker).CornerRadius = UDim.new(1,0)

        local conn
        conn = UserInputService.InputBegan:Connect(function(inp,gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then

                local loc = UserInputService:GetMouseLocation()

                fs_offsetX = cx - loc.X
                fs_offsetY = cy - loc.Y

                notifyUI("Calibrate Done",
                    ("Offset X=%.1f Y=%.1f"):format(fs_offsetX, fs_offsetY),
                    4
                )

                conn:Disconnect()
                gui:Destroy()

                if fs_overlayVisible and fs_savedPos then
                    fs_showOverlay(fs_savedPos.x, fs_savedPos.y)
                end
            end
        end)
    end
})

-- ===============================
-- CLEAN FISHING
-- ===============================
fishingTab:Button({
    Title = "Clean Fishing",
    Variant = "Destructive",
    Callback = function()

        fs_autoClickEnabled = false
        fs_waitingPosition = false
        fs_savedPos = nil

        fs_stopZone()
        fs_hideOverlay()

        pcall(function()
            local g = LocalPlayer.PlayerGui:FindFirstChild("PapiDimz_FishOverlay")
            if g then g:Destroy() end
        end)

        notifyUI("Fishing Clean", "All fishing systems reset.", 3)
    end
})

print("[PapiDimzHub] PART 2B Loaded: Fishing Ready.")
---------------------------------------------------------
-- TAB 5 : BRING ITEM
---------------------------------------------------------

local bringTab = Window:Tab({
    Title = "Bring Item",
    Icon = "hand"
})

---------------------------------------------------------
-- BRING ITEM STATE
---------------------------------------------------------

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemsFolder = Workspace:WaitForChild("Items")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local bi_RequestStart = RemoteEvents:WaitForChild("RequestStartDraggingItem")
local bi_RequestStop  = RemoteEvents:WaitForChild("StopDraggingItem")

local bi_BringHeight = 20
local bi_SelectedLocation = "Player"

local bi_ScrapperTarget = nil

local function bi_getScrapper()
    if bi_ScrapperTarget and bi_ScrapperTarget.Parent then
        return bi_ScrapperTarget
    end

    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end

    local camp = map:FindFirstChild("Campground")
    if not camp then return nil end

    local scrapper = camp:FindFirstChild("Scrapper")
    if not scrapper then return nil end

    local movers = scrapper:FindFirstChild("Movers")
    if not movers then return nil end

    local right = movers:FindFirstChild("Right")
    if not right then return nil end

    local part = right:FindFirstChild("GrindersRight")
    if part then
        bi_ScrapperTarget = part
    end
    return bi_ScrapperTarget
end

---------------------------------------------------------
-- GET TARGET POSITION (Player / Workbench / Fire)
---------------------------------------------------------

local function bi_getTargetPos(location)
    local char = LocalPlayer.Character
    if not char then return Vector3.new(0,30,0) end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.new(0,30,0) end

    -- PLAYER
    if location == "Player" then
        return hrp.Position + Vector3.new(0, bi_BringHeight + 3, 0)
    end

    -- WORKBENCH / SCRAPPER
    if location == "Workbench" then
        local s = bi_getScrapper()
        if s then
            return s.Position + VectorBox.new(0, bi_BringHeight, 0)
        end
        WindUI:Notify({Title="Scrapper Not Found",Content="Default to Player",Icon="alert-circle"})
        return hrp.Position + Vector3.new(0, bi_BringHeight, 0)
    end

    -- FIRE
    if location == "Fire" then
        local fire = Workspace:FindFirstChild("Map")
            and Workspace.Map:FindFirstChild("Campground")
            and Workspace.Map.Campground:FindFirstChild("MainFire")
            and Workspace.Map.Campground.MainFire:FindFirstChild("OuterTouchZone")

        if fire then
            return fire.Position + Vector3.new(0, bi_BringHeight, 0)
        end
        WindUI:Notify({Title="Fire Not Found",Content="Default to Player",Icon="alert-circle"})
        return hrp.Position + Vector3.new(0, bi_BringHeight, 0)
    end

    return hrp.Position + Vector3.new(0, bi_BringHeight, 0)
end

---------------------------------------------------------
-- CIRCULAR DROP FORMATION
---------------------------------------------------------

local function bi_dropCF(base, i)
    local angle = (i - 1) * (2 * math.pi / 12)
    local r     = 3
    local offset = Vector3.new(math.cos(angle)*r, 0, math.sin(angle)*r)
    return CFrame.new(base + offset)
end

---------------------------------------------------------
-- CORE BRING SYSTEM
---------------------------------------------------------

local function bi_bring(sectionList, selected, location)
    local targetPos = bi_getTargetPos(location)
    local list = {}

    if table.find(selected, "All") then
        for _, itemName in ipairs(sectionList) do
            if itemName ~= "All" then
                table.insert(list, itemName)
            end
        end
    else
        list = selected
    end

    local candidates = {}

    for _, item in ipairs(ItemsFolder:GetChildren()) do
        if item:IsA("Model")
        and item.PrimaryPart
        and table.find(list, item.Name) then
            table.insert(candidates, item)
        end
    end

    if #candidates == 0 then
        WindUI:Notify({
            Title = "Not Found",
            Content = "No items found.",
            Duration = 4,
            Icon = "search"
        })
        return
    end

    WindUI:Notify({
        Title = "Bringing..",
        Content = #candidates .. " items",
        Duration = 5,
        Icon = "zap"
    })

    for i, mdl in ipairs(candidates) do
        local cf = bi_dropCF(targetPos, i)

        pcall(function() bi_RequestStart:FireServer(mdl) end)
        task.wait(0.03)

        pcall(function() mdl:PivotTo(cf) end)
        task.wait(0.03)

        pcall(function() bi_RequestStop:FireServer(mdl) end)
        task.wait(0.03)
    end

    WindUI:Notify({
        Title = "Done",
        Content = #candidates .. " items delivered.",
        Duration = 3,
        Icon = "check-circle"
    })
end

---------------------------------------------------------
-- ========== UI: BRING ITEM ==========
---------------------------------------------------------

local setSec = bringTab:Section({
    Title = "Bring Settings",
    Icon = "settings",
    Collapsible = true
})

-- Location
setSec:Dropdown({
    Title = "Location",
    Values = {"Player", "Workbench", "Fire"},
    Value  = "Player",
    Callback = function(v)
        bi_SelectedLocation = v
    end
})

setSec:Input({
    Title = "Bring Height",
    Placeholder = "20",
    Default = "20",
    Numeric = true,
    Callback = function(v)
        bi_BringHeight = tonumber(v) or 20
    end
})

---------------------------------------------------------
-- ITEM SECTIONS (same as your list)
---------------------------------------------------------

local function createBringSection(tab, title, icon, itemList)
    local section = tab:Section({Title = title, Icon = icon, Collapsible = true})
    local selected = {"All"}

    section:Dropdown({
        Title = "Select Item",
        Values = itemList,
        Value = {"All"},
        Multi = true,
        AllowNone = true,
        Callback = function(v)
            selected = v or {"All"}
        end
    })

    section:Button({
        Title = "Bring " .. title,
        Callback = function()
            bi_bring(itemList, selected, bi_SelectedLocation)
        end
    })
end

-- CULTISTS
createBringSection(
    bringTab,
    "Cultists",
    "skull",
    {"All","Crossbow Cultist","Cultist"}
)

-- METEOR ITEMS
createBringSection(
    bringTab,
    "Meteor Items",
    "zap",
    {"All","Raw Obsidiron Ore","Gold Shard","Meteor Shard","Scalding Obsidiron Ingot"}
)

-- FUELS
createBringSection(
    bringTab,
    "Fuels",
    "flame",
    {"All","Log","Coal","Chair","Fuel Canister","Oil Barrel"}
)

-- FOODS
createBringSection(
    bringTab,
    "Food",
    "drumstick",
    {"All","Sweet Potato","Stuffing","Turkey Leg","Carrot","Pumkin","Mackerel","Salmon","Swordfish",
     "Berry","Ribs","Stew","Steak Dinner","Morsel","Steak","Corn","Cooked Morsel","Cooked Steak",
     "Chilli","Apple","Cake"}
)

-- HEALING
createBringSection(
    bringTab,
    "Healing",
    "heart",
    {"All","Medkit","Bandage"}
)

-- GEARS
createBringSection(
    bringTab,
    "Gears (Scrap)",
    "wrench",
    {"All","Bolt","Tyre","Sheet Metal","Old Radio","Broken Fan","Broken Microwave","Washing Machine",
     "Old Car Engine","UFO Scrap","UFO Component","UFO Junk","Cultist Gem","Gem of the Forest"}
)

-- WEAPONS
createBringSection(
    bringTab,
    "Weapons & Ammo",
    "swords",
    {"All","Infernal Sword","Morningstar","Crossbow","Infernal Crossbow","Laser Sword","Raygun",
     "Ice Axe","Ice Sword","Chainsaw","Strong Axe","Axe Trim Kit","Spear","Good Axe","Revolver",
     "Rifle","Tactical Shotgun","Revolver Ammo","Rifle Ammo","Alien Armour","Frog Boots",
     "Leather Body","Iron Body","Thorn Body","Riot Shield","Armour Trim Kit","Obsidiron Boots"}
)

-- OTHER ITEMS
createBringSection(
    bringTab,
    "Other Items",
    "package",
    {"All","Purple Fur Tuft","Halloween Candle","Candy","Frog Key","Feather","Wildfire",
     "Sacrifice Totem","Old Rod","Flower","Coin Stack","Infernal Sack","Giant Sack","Good Sack",
     "Seed Box","Chainsaw","Old Flashlight","Strong Flashlight","Bunny Foot","Wolf Pelt",
     "Bear Pelt","Mammoth Tusk","Alpha Wolf Pelt","Bear Corpse","Meteor Shard","Gold Shard",
     "Raw Obsidiron Ore","Gem of the Forest","Diamond","Defense Blueprint"}
)


print("[PapiDimzHub] Bring Item Loaded!")
---------------------------------------------------------
-- END BRING
---------------------------------------------------------

---------------------------------------------------------
-- TAB 6 : TELEPORT
---------------------------------------------------------

local teleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "navigation"
})

---------------------------------------------------------
-- TELEPORT FUNCTION
---------------------------------------------------------

local function tp_teleTo(cf)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf + Vector3.new(0,4,0)
        WindUI:Notify({
            Title="Teleport",
            Content="Teleport success!",
            Duration=2,
            Icon="navigation"
        })
    end
end

---------------------------------------------------------
-- LOST CHILD TELEPORT
---------------------------------------------------------

local lostSec = teleportTab:Section({
    Title = "Lost Child",
    Icon = "baby",
    Collapsible = true,
    DefaultOpen = true
})

local lostNames = {
    ["DinoKid"]   = "Lost Child",
    ["KrakenKid"] = "Lost Child2",
    ["SquidKid"]  = "Lost Child3",
    ["KoalaKid"]  = "Lost Child4"
}

local tp_selectedChild = "DinoKid"

lostSec:Dropdown({
    Title = "Select Child",
    Values = {"DinoKid","KrakenKid","SquidKid","KoalaKid"},
    Value  = "DinoKid",
    Callback = function(v)
        tp_selectedChild = v
    end
})

lostSec:Button({
    Title = "Teleport to Child",
    Callback = function()
        local folder = Workspace:FindFirstChild("Characters")
        if not folder then
            WindUI:Notify({Title="Error",Content="Characters folder not found!",Icon="alert-triangle"})
            return
        end

        local modelName = lostNames[tp_selectedChild]
        local mdl = folder:FindFirstChild(modelName)
        if mdl and mdl:FindFirstChild("HumanoidRootPart") then
            tp_teleTo(mdl.HumanoidRootPart.CFrame)
        else
            WindUI:Notify({Title="Error",Content="Child not found!",Icon="alert-triangle"})
        end
    end
})

---------------------------------------------------------
-- STRUCTURE TELEPORT
---------------------------------------------------------

local stSec = teleportTab:Section({
    Title = "Structure Teleport",
    Icon = "castle",
    Collapsible = true
})

-- CAMP
stSec:Button({
    Title = "Teleport to Camp",
    Callback = function()
        local fire = Workspace:FindFirstChild("Map")
            and Workspace.Map.Campground:FindFirstChild("MainFire")
            and Workspace.Map.Campground.MainFire:FindFirstChild("OuterTouchZone")

        if fire then
            tp_teleTo(fire.CFrame)
        else
            WindUI:Notify({Title="Error",Content="Camp not found!",Icon="alert-triangle"})
        end
    end
})

-- CULTIST GENERATOR
stSec:Button({
    Title = "Teleport to Cultist Generator Base",
    Callback = function()
        local cult = Workspace:FindFirstChild("Map")
            and Workspace.Map.Landmarks:FindFirstChild("CultistGenerator")

        if cult and cult.PrimaryPart then
            tp_teleTo(cult.PrimaryPart.CFrame)
        else
            WindUI:Notify({Title="Error",Content="Cultist Generator not found!",Icon="alert-triangle"})
        end
    end
})

-- STRONGHOLD
stSec:Button({
    Title = "Teleport to Stronghold",
    Callback = function()
        local sign = Workspace.Map.Landmarks
            and Workspace.Map.Landmarks.Stronghold
            and Workspace.Map.Landmarks.Stronghold.Building
            and Workspace.Map.Landmarks.Stronghold.Building.Sign:FindFirstChild("Main")

        if sign then
            tp_teleTo(sign.CFrame)
            return end

        WindUI:Notify({
            Title="Error",
            Content="Stronghold not found!",
            Icon="alert-triangle"
        })
    end
})

-- STRONGHOLD DIAMOND CHEST
stSec:Button({
    Title = "Teleport to Stronghold Diamond Chest",
    Callback = function()
        local item = Workspace.Items:FindFirstChild("Stronghold Diamond Chest")
        if item and item:FindFirstChild("ChestLid") then
            local mesh = item.ChestLid:FindFirstChild("Meshes/diamondchest_Cube.005")
            if mesh then
                tp_teleTo(mesh.CFrame)
                return
            end
        end

        WindUI:Notify({
            Title="Error",
            Content="Diamond Chest not found!",
            Icon="alert-triangle"
        })
    end
})

-- CARAVAN
stSec:Button({
    Title = "Teleport to Caravan",
    Callback = function()
        local car = Workspace.Map.Landmarks:FindFirstChild("Caravan")
        if car and car.PrimaryPart then
            tp_teleTo(car.PrimaryPart.CFrame)
        else
            WindUI:Notify({Title="Error",Content="Caravan not found!",Icon="alert-triangle"})
        end
    end
})

-- FAIRY
stSec:Button({
    Title = "Teleport to Fairy",
    Callback = function()
        local fairy = Workspace.Map.Landmarks:FindFirstChild("Fairy House")
        if fairy and fairy.Fairy and fairy.Fairy:FindFirstChild("HumanoidRootPart") then
            tp_teleTo(fairy.Fairy.HumanoidRootPart.CFrame)
        else
            WindUI:Notify({Title="Error",Content="Fairy not found!",Icon="alert-triangle"})
        end
    end
})

-- ANVIL
stSec:Button({
    Title = "Teleport to Anvil",
    Callback = function()
        local anvil =
            Workspace.Map.Landmarks.ToolWorkshop.Functional.ToolBench:FindFirstChild("Hammer")

        if anvil then
            tp_teleTo(anvil.CFrame)
        else
            WindUI:Notify({Title="Error",Content="Anvil not found!",Icon="alert-triangle"})
        end
    end
})

print("[PapiDimzHub] PART 3 Loaded : Bring + Teleport Ready.")
---------------------------------------------------------
-- PART 4 — FARM, TOOLS, NIGHT, WEBHOOK, CEK HEALTH
-- + COMPLETE resetAll() CLEANUP
---------------------------------------------------------

---------------------------------------------------------
-- TAB 7 : FARM
---------------------------------------------------------

local farmTab = Window:Tab({
    Title = "Farm",
    Icon = "tractor"
})

farmTab:Paragraph({
    Title = "Auto Farm Module",
    Desc = "Tools & helpers for farming and grinding safely.",
    Color = "Grey"
})

---------------------------------------------------------
-- AUTO CROCKPOT (simple)
---------------------------------------------------------

local farm_autoCook = false
local farm_cookConn = nil

local function farm_startCook()
    if farm_autoCook then return end
    farm_autoCook = true

    farm_cookConn = RunService.Heartbeat:Connect(function()
        local pot = Workspace:FindFirstChild("Crockpot")
        if pot and pot:FindFirstChild("Button") then
            pcall(function()
                fireclickdetector(pot.Button.ClickDetector)
            end)
        end
    end)

    WindUI:Notify({Title="Crockpot", Content="Auto Cook ON", Duration=2, Icon="flame"})
end

local function farm_stopCook()
    farm_autoCook = false
    if farm_cookConn then
        farm_cookConn:Disconnect()
        farm_cookConn = nil
    end
    WindUI:Notify({Title="Crockpot", Content="Auto Cook OFF", Duration=2, Icon="flame"})
end

farmTab:Toggle({
    Title = "Auto Crockpot",
    Default = false,
    Callback = function(state)
        if state then farm_startCook() else farm_stopCook() end
    end
})

---------------------------------------------------------
-- AUTO SCRAPPER (simple)
---------------------------------------------------------

local farm_scrap = false
local farm_scrapConn = nil

local function farm_startScrap()
    if farm_scrap then return end
    farm_scrap = true

    farm_scrapConn = RunService.Heartbeat:Connect(function()
        local part = Workspace:FindFirstChild("ScrapperButton")
        if part and part:IsA("BasePart") then
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 0)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, part, 1)
        end
    end)

    WindUI:Notify({Title="Scrapper", Content="Auto Scrap ON", Duration=2, Icon="wrench"})
end

local function farm_stopScrap()
    farm_scrap = false
    if farm_scrapConn then farm_scrapConn:Disconnect(); farm_scrapConn = nil end
    WindUI:Notify({Title="Scrapper", Content="Auto Scrap OFF", Duration=2, Icon="wrench"})
end

farmTab:Toggle({
    Title = "Auto Scrapper",
    Default = false,
    Callback = function(state)
        if state then farm_startScrap() else farm_stopScrap() end
    end
})

---------------------------------------------------------
-- ULTRA COIN / AMMO FARM (Area Touch Spam)
---------------------------------------------------------

local farm_coin = false
local farm_coinConn = nil

local function farm_startCoin()
    if farm_coin then return end
    farm_coin = true

    farm_coinConn = RunService.Heartbeat:Connect(function()
        local zone = Workspace:FindFirstChild("CoinZone")
        if zone then
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, zone, 0)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, zone, 1)
        end
    end)

    WindUI:Notify({Title="Coin/Ammo", Content="Auto Coin/Ammo ON", Duration=2, Icon="coins"})
end

local function farm_stopCoin()
    farm_coin = false
    if farm_coinConn then farm_coinConn:Disconnect(); farm_coinConn = nil end
    WindUI:Notify({Title="Coin/Ammo", Content="Auto Coin/Ammo OFF", Duration=2, Icon="coins"})
end

farmTab:Toggle({
    Title = "Auto Coin/Ammo",
    Default = false,
    Callback = function(state)
        if state then farm_startCoin() else farm_stopCoin() end
    end
})

---------------------------------------------------------
-- TAB 8 : TOOLS
---------------------------------------------------------

local toolsTab = Window:Tab({
    Title = "Tools",
    Icon = "tool"
})

toolsTab:Paragraph({
    Title = "Utility Tools",
    Desc = "Useful shortcuts and debugging helpers.",
    Color = "Grey"
})

toolsTab:Button({
    Title = "Rejoin Server",
    Icon = "refresh-ccw",
    Callback = function()
        local tp = game:GetService("TeleportService")
        tp:Teleport(game.PlaceId, LocalPlayer)
    end
})

toolsTab:Button({
    Title = "Server Hop",
    Icon = "shuffle",
    Callback = function()
        local tp = game:GetService("TeleportService")

        local servers = {}
        local function getServers(cursor)
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
            if cursor then url = url .. "&cursor=" .. cursor end
            local body = game:HttpGet(url)
            return HttpService:JSONDecode(body)
        end

        local data = getServers()
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers then
                tp:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                return
            end
        end

        WindUI:Notify({Title="Server Hop",Content="No empty server found.",Duration=3,Icon="alert-circle"})
    end
})

---------------------------------------------------------
-- TAB 9 : NIGHT SKIP
---------------------------------------------------------

local nightTab = Window:Tab({
    Title = "Night",
    Icon = "moon"
})

nightTab:Paragraph({
    Title = "Night Control",
    Desc = "Auto skip / auto sleep utility.",
    Color = "Grey"
})

local night_skip = false
local night_conn = nil

local function night_start()
    if night_skip then return end
    night_skip = true

    night_conn = RunService.Heartbeat:Connect(function()
        local skip = Workspace:FindFirstChild("NightSkipButton")
        if skip then
            fireclickdetector(skip.ClickDetector)
        end
    end)

    WindUI:Notify({Title="Night",Content="Auto Skip Night ON",Duration=3,Icon="moon"})
end

local function night_stop()
    night_skip = false
    if night_conn then night_conn:Disconnect(); night_conn = nil end
    WindUI:Notify({Title="Night",Content="Auto Skip Night OFF",Duration=3,Icon="moon"})
end

nightTab:Toggle({
    Title = "Auto Skip Night",
    Default = false,
    Callback = function(v)
        if v then night_start() else night_stop() end
    end
})

---------------------------------------------------------
-- TAB 10 : WEBHOOK
---------------------------------------------------------

local webhookTab = Window:Tab({
    Title = "Webhook",
    Icon = "link"
})

local webhookURL = ""

webhookTab:Paragraph({
    Title = "Webhook Sender",
    Desc = "Send any message to a Discord Webhook.",
    Color = "Grey"
})

webhookTab:Input({
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Callback = function(text)
        webhookURL = text
    end
})

webhookTab:Input({
    Title = "Message",
    Placeholder = "Type message...",
    Default = "",
    Callback = function(msg)
        webhookTab._tmpMsg = msg
    end
})

webhookTab:Button({
    Title = "Send Webhook",
    Icon = "send",
    Callback = function()
        if webhookURL == "" then
            WindUI:Notify({Title="Error",Content="Webhook URL empty.",Icon="alert-circle"})
            return
        end

        pcall(function()
            local req = syn and syn.request or request
            req({
                Url = webhookURL,
                Method = "POST",
                Headers = {["Content-Type"]="application/json"},
                Body = HttpService:JSONEncode({
                    content = webhookTab._tmpMsg or ""
                })
            })
        end)

        WindUI:Notify({Title="Webhook",Content="Message Sent!",Icon="check-circle"})
    end
})

---------------------------------------------------------
-- TAB 11 : CEK HEALTH
---------------------------------------------------------

local healthTab = Window:Tab({
    Title = "Cek Health",
    Icon = "heart-pulse"
})

healthTab:Paragraph({
    Title = "Health Checker",
    Desc = "Display live humanoid health.",
    Color = "Grey"
})

local health_label = nil
local health_conn  = nil

health_label = healthTab:Label({
    Title = "Health: Loading..."
})

local function health_start()
    if health_conn then return end

    health_conn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")

        if hum then
            health_label:SetText("Health: " .. math.floor(hum.Health))
        end
    end)
end

health_start()

---------------------------------------------------------
-- GLOBAL RESET ALL (FORCE CLOSE)
---------------------------------------------------------

function resetAll()
    -------------------------------------------------
    -- LOCAL PLAYER CLEANUP (FROM PART 2)
    -------------------------------------------------
    pcall(stopFly)
    pcall(stopTPWalk)
    pcall(stopInfiniteJump)
    pcall(disableFullBright)
    noclipManualEnabled = false
    updateNoclipConnection()

    humanoid.WalkSpeed = defaultWalkSpeed
    humanoid.HipHeight = defaultHipHeight
    Camera.FieldOfView = defaultFOV

    -------------------------------------------------
    -- FISHING CLEANUP
    -------------------------------------------------
    fishing_enabled = false
    pcall(fishing_stopZone)

    if fishing_loop and fishing_loop.Disconnect then
        pcall(function() fishing_loop:Disconnect() end)
    end

    if fishing_inputConn then
        pcall(function() fishing_inputConn:Disconnect() end)
        fishing_inputConn = nil
    end

    if fishing_overGui then
        pcall(function() fishing_overGui:Destroy() end)
    end

    if fishing_posPanel then
        pcall(function() fishing_posPanel:Destroy() end)
    end

    -------------------------------------------------
    -- FARM CLEANUP
    -------------------------------------------------
    farm_stopCook()
    farm_stopScrap()
    farm_stopCoin()

    -------------------------------------------------
    -- NIGHT CLEANUP
    -------------------------------------------------
    night_stop()

    -------------------------------------------------
    -- HEALTH CLEANUP
    -------------------------------------------------
    if health_conn then
        health_conn:Disconnect()
        health_conn = nil
    end

    -------------------------------------------------
    -- UI UNLOAD
    -------------------------------------------------
    pcall(function()
        Window:Unload()
    end)

    WindUI:Notify({
        Title = "Hub Closed",
        Content = "All features OFF. UI unloaded.",
        Duration = 3,
        Icon = "power"
    })
end

---------------------------------------------------------
-- END OF PART 4
---------------------------------------------------------

print("[PapiDimzHub] ALL PARTS LOADED — HUB READY!")
