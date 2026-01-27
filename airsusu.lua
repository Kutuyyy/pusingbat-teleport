-- campuran.lua - FRENESIS x HexaCore Ultimate Fusion
-- Script lengkap dengan semua fitur dari full.lua dan fun.lua

---------------------------------------------------------
-- SERVICES & INITIALIZATION
---------------------------------------------------------
local Services = {
    Players = game:GetService("Players"),
    Workspace = game:GetService("Workspace"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Lighting = game:GetService("Lighting"),
    VirtualUser = game:GetService("VirtualUser"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    Debris = game:GetService("Debris")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

---------------------------------------------------------
-- STATE TABLE - Semua variabel gabungan
---------------------------------------------------------
local State = {
    -- CORE
    scriptDisabled = false,
    scriptActive = true,
    WindUI = nil,
    WindowCreated = false,
    
    -- WINDUI Reference
    WindUIWindow = nil,
    
    -- BRING ITEM SYSTEM
    BringHeight = 20,
    selectedLocation = "Player",
    ScrapperTarget_Bring = nil,
    ItemsFolder = nil,
    RequestStartDragging = nil,
    RequestStopDragging = nil,
    
    -- HexaCore SYSTEM (Local player / general)
    GodmodeEnabled = false,
    AntiAFKEnabled = true,
    humanoid = nil,
    rootPart = nil,
    defaultFOV = Camera and Camera.FieldOfView or 70,
    fovEnabled = false,
    fovValue = 60,
    walkEnabled = false,
    walkSpeedValue = 30,
    defaultWalkSpeed = 16,
    flyEnabled = false,
    flySpeedValue = 50,
    flyConn = nil,
    noclipConn = nil,
    originalTransparency = {},
    idleTrack = nil,
    
    -- FISHING SYSTEM
    fishingClickDelay = 5.0,
    fishingAutoClickEnabled = false,
    waitingForPosition = false,
    fishingSavedPosition = nil,
    fishingOverlayVisible = false,
    fishingOffsetX = 0,
    fishingOffsetY = 0,
    zoneEnabled = false,
    zoneDestroyed = false,
    zoneLastVisible = false,
    zoneSpamClicking = false,
    zoneSpamThread = nil,
    zoneSpamInterval = 0.04,
    autoRecastEnabled = false,
    lastTimingBarSeenAt = 0,
    wasTimingBarVisible = false,
    lastRecastAt = 0,
    RECAST_DELAY = 2,
    MAX_RECENT_SECS = 5,
    fishingLoopThread = nil,
    
    -- UPDATE FOCUSED
    cursedRiftIndex = 0,

    -- FARM SYSTEM
    Structures = Services.Workspace:FindFirstChild("Structures"),
    CookingStations = {},
    MoveMode = "DragPivot",
    AutoCookEnabled = false,
    CookLoopId = 0,
    CookDelaySeconds = 10,
    CookItemsPerCycle = 5,
    SelectedCookItems = { "Carrot", "Corn" },
    ScrapEnabled = false,
    ScrapLoopId = 0,
    ScrapScanInterval = 60,
    ScrapItemsPriority = {"Bolt","Sheet Metal","UFO Junk","UFO Component","Broken Fan","Old Radio","Broken Microwave","Tyre","Old Car Engine","Cultist Gem","Gem of the Forest"},
    LavaCFrame = nil,
    lavaFound = false,
    AutoSacEnabled = false,
    SacrificeList = {"Juggernaut Cultist","Brutal Cultist","Darkstring Cultist","Morsel","Cooked Morsel","Steak","Cooked Steak","Lava Eel","Cooked Lava Eel","Lionfish","Cooked Lionfish","Cultist","Crossbow Cultist","Rifle Ammo","Revolver Ammo","Bunny Foot","Alpha Wolf Pelt","Wolf Pelt"},
    CoinAmmoEnabled = false,
    coinAmmoDescAddedConn = nil,
    CoinAmmoConnection = nil,
    TemporalAccelerometer = nil,
    autoTemporalEnabled = false,
    lastProcessedDay = nil,
    DayDisplayRemote = nil,
    DayDisplayConnection = nil,
    
    -- COMBAT / AURA
    KillAuraEnabled = false,
    ChopAuraEnabled = false,
    KillAuraRadius = 100,
    ChopAuraRadius = 100,
    AuraAttackDelay = 0.16,
    AxeIDs = {
        ["Old Axe"] = "3_7367831688",
        ["Good Axe"] = "112_7367831688",
        ["Strong Axe"] = "116_7367831688",
        ["Infernal Sword"] = "1_8838463626",
        ["Ice Sword"] = "11_8838463626",
        ["Chainsaw"] = "647_8992824875",
        ["Spear"] = "196_8999010016"
    },
    TreeCache = {},
    SelectedTreeCategories = {"Small Tree"},
    auraHeartbeatConnection = nil,
    nextAuraTick = 0,
    lastDayDetected = nil,
    treeScanRadius = 900,
    treeCacheRefreshThread = nil,
    treeCacheRefreshInterval = 5,

    -- LOCAL PLAYER EXTRAS
    tpWalkEnabled = false,
    tpWalkSpeedValue = 5,
    tpWalkConn = nil,
    noclipManualEnabled = false,
    infiniteJumpEnabled = false,
    infiniteJumpConn = nil,
    fullBrightEnabled = false,
    fullBrightConn = nil,
    oldLightingProps = {
        Brightness = Services.Lighting.Brightness,
        ClockTime = Services.Lighting.ClockTime,
        FogEnd = Services.Lighting.FogEnd,
        GlobalShadows = Services.Lighting.GlobalShadows,
        Ambient = Services.Lighting.Ambient,
        OutdoorAmbient = Services.Lighting.OutdoorAmbient
    },
    hipEnabled = false,
    hipValue = 35,
    defaultHipHeight = 2,
    instantOpenEnabled = false,
    promptOriginalHold = {},
    promptConn = nil,
    
    -- GODMODE
    GodmodeLoopActive = false,
    DamagePlayerRemote = nil,
    
    -- FUN SYSTEM VARIABLES (dari fun.lua)
    -- Position
    groundPosition = Vector3.new(0, 6, 0),
    autoStrongholdEnabled = false,
    autoStrongholdRunning = false,
    cachedTriggerZoneCFrame = nil,
    triggerZoneReady = false,
    savedPositionBeforeStronghold = nil,

    -- Spiral
    spiralActive = false,
    spiralThread = nil,
    spiralCenter = Vector3.new(0, 50, 0),
    flySpeed = 300,
    
    -- Overlay
    overlayVisible = false,
    overlayParts = {},
    overlayRadius = 100,
    overlayHeight = 3,
    overlayCenter = Vector3.new(1, 3, 1),
    overlayPoints = 50,
    
    -- Overlay Shape System
    overlayShape = "circle",
    overlayShapes = {"circle", "square", "triangle", "star", "hexagon", "spiral", "diamond"},
    
    -- Sapling
    plantingActive = false,
    plantingThread = nil,
    plantingMode = "character",
    plantInterval = 0.5,
    infiniteSaplingEnabled = false,
    plantSequenceIndex = 1,
    totalPlanted = 0,
    maxPlantPoints = 0,
    plantingCompleted = false,
    
    -- Log Wall
    logWallActive = false,
    logWallThread = nil,
    placeStructureRemote = nil,
    allBlueprints = {},
    blueprintIndex = 1,
    autoRotateLogWall = true,
    
    -- Layer / Shape Settings
    angleIncrement = 2,
    radiusIncrement = 10,
    
    -- Infinite Sapling Settings
    INFINITE_SHOW_MARKER = true,
    INFINITE_MARKER_LIFETIME = 3,
    characterPlantHistory = {},
    
    -- Auto Chest Opener
    isOpeningChests = false,
    chestOpeningThread = nil,
    chestOpeningSpeed = 0.3,
    chestQueue = {},
    chestTypes = {
        "Item Chest",
        "Item Chest2",
        "Item Chest3",
        "Item Chest4",
        "Item Chest5",
        "Item Chest6",
        "Halloween Chest1",
        "Halloween Maze Chest",
        "ChristmasPresent1",
        "Hardmode Crate",
        "Stronghold Diamond Chest"
    },
    openedChests = {},
    
    -- FUN REMOTES
    PlantRemote = nil,
    RequestOpenItemChest = nil,
    
    -- WEBHOOK
    WebhookURL = "https://discord.com/api/webhooks/1445120874033447068/aHmIofSu6jf7JctLjpRmbGYvwWX0MFtJw4Fnhqd6Hxyo4QQB7a_8UASNZsbpKMH4Jrvz",
    WebhookEnabled = true,
    WebhookUsername = (LocalPlayer and LocalPlayer.Name) or "Player",
    currentDayCached = "N/A",
    previousDayCached = "N/A",

    LocationCache = {
    Camp = nil,
    Stronghold = nil,
    StrongholdTriggerZone = nil,
    StrongholdChest = nil,
    Anvil = nil,
    CultistGenerator = nil
    },
}
State.isSettingKeybind = false
State.lastKeybindSet = nil
local currentKeybind = Enum.KeyCode.P

---------------------------------------------------------
-- UTILITY FUNCTIONS (GABUNGAN)
---------------------------------------------------------
local function createFallbackNotify(msg)
    print("[PapiDimz][FALLBACK NOTIFY] " .. tostring(msg))
end

local function notifyUI(title, content, duration, icon)
    if State.WindUI then
        pcall(function()
            State.WindUI:Notify({ Title = title or "Info", Content = content or "", Duration = duration or 4, Icon = icon or "info" })
        end)
    else
        createFallbackNotify(string.format("%s - %s", tostring(title), tostring(content)))
    end
end

local function showWindUINotification(title, message, notificationType, duration)
    local W = State.WindUI
    if not W then return end

    title = title or "FRENESIS"
    message = message or ""
    notificationType = notificationType or "Info"
    duration = duration or 3

    W:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Type = notificationType
    })
end

local function tableToSet(list)
    local t = {}
    for _, v in ipairs(list) do t[v] = true end
    return t
end

local function trim(s)
    if type(s) ~= "string" then return s end
    return s:match("^%s*(.-)%s*$")
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

---------------------------------------------------------
-- FUN SYSTEM FUNCTIONS (dari fun.lua)
---------------------------------------------------------
-- REMOTES FUN SYSTEM
local function findPlantRemote()
    if Services.ReplicatedStorage:FindFirstChild("RemoteEvents") then
        local r = Services.ReplicatedStorage.RemoteEvents:FindFirstChild("RequestPlantItem")
        if r then return r end
    end
    for _, v in ipairs(Services.ReplicatedStorage:GetDescendants()) do
        if v.Name:lower() == "requestplantitem" then
            return v
        end
    end
    return nil
end

State.PlantRemote = findPlantRemote()

local function findPlaceStructureRemote()
    if Services.ReplicatedStorage:FindFirstChild("RemoteEvents") then
        local r = Services.ReplicatedStorage.RemoteEvents:FindFirstChild("RequestPlaceStructure")
        if r then return r end
    end
    for _, v in ipairs(Services.ReplicatedStorage:GetDescendants()) do
        if v.Name:lower() == "requestplacestructure" then
            return v
        end
    end
    return nil
end

State.placeStructureRemote = findPlaceStructureRemote()

-- RequestOpenItemChest remote
do
    if Services.ReplicatedStorage:FindFirstChild("RemoteEvents") then
        State.RequestOpenItemChest = Services.ReplicatedStorage.RemoteEvents:FindFirstChild("RequestOpenItemChest")
    else
        for _, v in ipairs(Services.ReplicatedStorage:GetDescendants()) do
            if v.Name:lower() == "requestopenitemchest" then
                State.RequestOpenItemChest = v
                break
            end
        end
    end
end

-- FUN HELPER FUNCTIONS
local function getRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function teleportKeepXZ(targetY)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local pos = root.Position
    root.CFrame = CFrame.new(pos.X, targetY, pos.Z)
end

local function savePlayerPosition()
    local hrp = getRoot()
    if hrp then
        State.savedPositionBeforeStronghold = hrp.CFrame
    end
end

local function restorePlayerPosition()
    local hrp = getRoot()
    if hrp and State.savedPositionBeforeStronghold then
        hrp.CFrame = State.savedPositionBeforeStronghold
        State.savedPositionBeforeStronghold = nil
    end
end

local function setAnchored(v)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.Anchored = v
    end
end

local function jumpOnce()
    local humanoid = State.humanoid
    if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function teleportToStronghold()
    local sign =
        Services.Workspace:FindFirstChild("Map")
        and Services.Workspace.Map:FindFirstChild("Landmarks")
        and Services.Workspace.Map.Landmarks:FindFirstChild("Stronghold")
        and Services.Workspace.Map.Landmarks.Stronghold:FindFirstChild("Building")
        and Services.Workspace.Map.Landmarks.Stronghold.Building:FindFirstChild("Sign")
        and Services.Workspace.Map.Landmarks.Stronghold.Building.Sign:FindFirstChild("Main")

    if sign and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = sign.CFrame * CFrame.new(0, 3, 0)
        return true
    end
    return false
end

local function isCultistNearby(radius)
    radius = radius or 200

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local chars = Services.Workspace:FindFirstChild("Characters")
    if not chars then return false end

    for _, mob in ipairs(chars:GetChildren()) do
        if mob:IsA("Model")
           and mob:FindFirstChild("HumanoidRootPart")
           and mob:FindFirstChildOfClass("Humanoid") then

            if string.find(mob.Name, "Cultist") then
                local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist <= radius then
                    return true
                end
            end
        end
    end

    return false
end

local function findNearestCultist(maxDist)
    maxDist = maxDist or 200

    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local chars = Services.Workspace:FindFirstChild("Characters")
    if not chars then return nil end

    local nearest, nearestDist = nil, math.huge

    for _, mob in ipairs(chars:GetChildren()) do
        if mob:IsA("Model")
           and mob:FindFirstChild("HumanoidRootPart")
           and mob:FindFirstChild("Humanoid") then

            local name = mob.Name
            if name == "Cultist"
                or name == "Crossbow Cultist"
                or name == "Juggernaut Cultist" then

                local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                if dist <= maxDist and dist < nearestDist and mob.Humanoid.Health > 0 then
                    nearest = mob
                    nearestDist = dist
                end
            end
        end
    end

    return nearest, nearestDist
end

local TweenService = game:GetService("TweenService")

local function tweenAroundCultist(cultist)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = cultist and cultist:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetRoot then return end

    local direction = (targetRoot.Position - hrp.Position).Unit
    local forwardPos = targetRoot.Position - direction * 3
    local backwardPos = hrp.Position - direction * 5

    local info = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

    local tweenForward = TweenService:Create(
        hrp,
        info,
        { CFrame = CFrame.new(forwardPos) }
    )

    local tweenBackward = TweenService:Create(
        hrp,
        info,
        { CFrame = CFrame.new(backwardPos) }
    )

    tweenForward:Play()
    tweenForward.Completed:Wait()

    tweenBackward:Play()
    tweenBackward.Completed:Wait()
end

local RunService = game:GetService("RunService")
local noclipConn

local function enableNoClip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
end

local function disableNoClip()
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

local function sendStrongholdChat()
    pcall(function()
        game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel:SendAsync(
            "HexaCore.. Go to Stronghold"
        )
    end)
end

local function pingStronghold()
    local rs = game:GetService("ReplicatedStorage")
    local players = game:GetService("Players")
    local lp = players.LocalPlayer

    local stronghold =
        game:GetService("Workspace")
        :FindFirstChild("Map")
        and game.Workspace.Map:FindFirstChild("Landmarks")
        and game.Workspace.Map.Landmarks:FindFirstChild("Stronghold")

    if not stronghold then return end

    -- ambil posisi stronghold (dinamis)
    local pos
    local part = stronghold:FindFirstChildWhichIsA("BasePart", true)
    if part then
        pos = part.Position
    else
        pos = stronghold:GetPivot().Position
    end

    local remote = rs:FindFirstChild("RemoteEvents")
        and rs.RemoteEvents:FindFirstChild("RequestBroadcastPing")

    if not remote then return end

    -- kirim 2x (seperti client asli)
    for i = 1, 2 do
        pcall(function()
            remote:FireServer({
                Model = stronghold,
                Player = lp,
                Position = pos
            })
        end)
        task.wait(0.1)
    end
end

local function collectAllDiamonds()
    local rs = game:GetService("ReplicatedStorage")
    local remote = rs:FindFirstChild("RemoteEvents")
        and rs.RemoteEvents:FindFirstChild("RequestTakeDiamonds")

    if not remote then return end

    local items = Services.Workspace:FindFirstChild("Items")
    if not items then return end

    for _, v in ipairs(items:GetChildren()) do
        if v.Name == "Diamond" then
            pcall(function()
                remote:FireServer(v)
            end)
            task.wait(0.15)
        end
    end
end

-- === STRONGHOLD REFERENCE POSITION ===
local function getStrongholdReferencePosition()
    local sign =
        Services.Workspace:FindFirstChild("Map")
        and Services.Workspace.Map:FindFirstChild("Landmarks")
        and Services.Workspace.Map.Landmarks:FindFirstChild("Stronghold")
        and Services.Workspace.Map.Landmarks.Stronghold:FindFirstChild("Building")
        and Services.Workspace.Map.Landmarks.Stronghold.Building:FindFirstChild("Sign")
        and Services.Workspace.Map.Landmarks.Stronghold.Building.Sign:FindFirstChild("Main")

    return sign and sign.Position or nil
end

local function getStronghold()
    if State.LocationCache.Stronghold then
        return State.LocationCache.Stronghold
    end

    local sign =
        Services.Workspace:FindFirstChild("Map")
        and Services.Workspace.Map:FindFirstChild("Landmarks")
        and Services.Workspace.Map.Landmarks:FindFirstChild("Stronghold")
        and Services.Workspace.Map.Landmarks.Stronghold
            :FindFirstChild("Building")
            :FindFirstChild("Sign")
            :FindFirstChild("Main")

    if sign then
        State.LocationCache.Stronghold = sign
    end

    return sign
end

local function getStrongholdTriggerZone()
    if State.LocationCache.StrongholdTriggerZone then
        return State.LocationCache.StrongholdTriggerZone
    end

    local tz = ensureStrongholdTriggerZone()
    if tz then
        State.LocationCache.StrongholdTriggerZone = tz
    end

    return tz
end

local function getStrongholdDiamondChest()
    if State.LocationCache.StrongholdChest then
        return State.LocationCache.StrongholdChest
    end

    local items = Services.Workspace:FindFirstChild("Items")
    local chest = items and items:FindFirstChild("Stronghold Diamond Chest")

    if chest then
        State.LocationCache.StrongholdChest = chest
    end

    return chest
end

local function getSacrificeLavaPosition()
    local map = Services.Workspace:FindFirstChild("Map")
    local lava =
        map and map:FindFirstChild("Landmarks")
        and map.Landmarks:FindFirstChild("Sacrifice Lava")

    local part = lava and (lava.PrimaryPart or lava:FindFirstChildWhichIsA("BasePart", true))
    return part and part.Position or nil
end

local function findCultistGeneratorBase()
    local lavaPos = getSacrificeLavaPosition()
    if not lavaPos then return nil end

    local closest, closestDist = nil, math.huge

    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v:IsA("MeshPart") and v.Name == "banner" then
            local dist = (v.Position - lavaPos).Magnitude
            if dist < closestDist then
                closest = v
                closestDist = dist
            end
        end
    end

    return closest, closestDist
end

local function getCultistGeneratorBase()
    if State.LocationCache.CultistGenerator
       and State.LocationCache.CultistGenerator.Parent then
        return State.LocationCache.CultistGenerator
    end

    local part =
        Services.Workspace:FindFirstChild("Map")
        and Services.Workspace.Map:FindFirstChild("Landmarks")
        and Services.Workspace.Map.Landmarks:FindFirstChild("Volcano")
        and Services.Workspace.Map.Landmarks.Volcano:FindFirstChild("Models")
        and Services.Workspace.Map.Landmarks.Volcano.Models:FindFirstChild("Basalt Pile1")
        and Services.Workspace.Map.Landmarks.Volcano.Models["Basalt Pile1"]:FindFirstChild("Part")

    if part then
        State.LocationCache.CultistGenerator = part
        return part
    end

    return nil
end

local function getAnvil()
    if State.LocationCache.Anvil and State.LocationCache.Anvil.Parent then
        return State.LocationCache.Anvil
    end

    local anvil =
        Services.Workspace:FindFirstChild("Map")
        and Services.Workspace.Map:FindFirstChild("Landmarks")
        and Services.Workspace.Map.Landmarks:FindFirstChild("ToolWorkshop")
        and Services.Workspace.Map.Landmarks.ToolWorkshop
            :FindFirstChild("Functional")
            :FindFirstChild("ToolBench")
            :FindFirstChild("Hammer")

    if anvil then
        State.LocationCache.Anvil = anvil
        return anvil
    end

    return nil
end

local function getCamp()
    if State.LocationCache.Camp and State.LocationCache.Camp.Parent then
        return State.LocationCache.Camp
    end

    local fire =
        Services.Workspace:FindFirstChild("Map")
        and Services.Workspace.Map:FindFirstChild("Campground")
        and Services.Workspace.Map.Campground:FindFirstChild("MainFire")
        and Services.Workspace.Map.Campground.MainFire:FindFirstChild("OuterTouchZone")

    if fire then
        State.LocationCache.Camp = fire
        return fire
    end

    return nil
end



local function findStrongholdTriggerZoneByHeuristic()
    local strongholdPos = getStrongholdReferencePosition()
    if not strongholdPos then return nil end

    local best
    local bestDist = math.huge

    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v.Name == "TriggerZone" and v:IsA("BasePart") then
            local pos = v.Position
            local size = v.Size
            local dist = (pos - strongholdPos).Magnitude

            -- ciri TriggerZone Stronghold
            if dist < 800
                and pos.Y > 0
                and size.Y > 10 and size.Y < 13
                and size.Z > 3 and size.Z < 4 then

                if dist < bestDist then
                    bestDist = dist
                    best = v
                end
            end
        end
    end

    return best, bestDist
end

local function ensureStrongholdTriggerZone()
    -- sudah pernah ketemu → pakai cache
    if State.cachedTriggerZoneCFrame then
        return true
    end

    local hrp = getRoot()
    if not hrp then return false end

    -- 1️⃣ simpan posisi awal
    savePlayerPosition()

    -- 2️⃣ teleport ke stronghold
    local stronghold =
        Services.Workspace:FindFirstChild("Map")
        and Services.Workspace.Map:FindFirstChild("Landmarks")
        and Services.Workspace.Map.Landmarks:FindFirstChild("Stronghold")

    if not stronghold then
        restorePlayerPosition()
        return false
    end

    local part = stronghold:FindFirstChildWhichIsA("BasePart", true)
    if part then
        hrp.CFrame = part.CFrame * CFrame.new(0, 5, 0)
    end

    -- 3️⃣ tunggu map settle
    task.wait(1.5)

    -- 4️⃣ scan TriggerZone (sekali sampai ketemu)
    local tz
    for _, v in ipairs(stronghold:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "TriggerZone" then
            tz = v
            break
        end
    end

    if tz then
        State.cachedTriggerZoneCFrame = tz.CFrame
        restorePlayerPosition()
        return true
    end

    -- gagal → balikin posisi juga
    restorePlayerPosition()
    return false
end


local function getFootPosition()
    local root = getRoot()
    if not root then return nil end

    local origin = Vector3.new(root.Position.X, root.Position.Y + 2, root.Position.Z)
    local rayDir = Vector3.new(0, -20, 0)
    local rp = Services.RunService.RaycastParams.new()
    rp.FilterDescendantsInstances = { LocalPlayer.Character or LocalPlayer }
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    local res = Services.Workspace:Raycast(origin, rayDir, rp)

    if res and res.Position then
        return res.Position + Vector3.new(0, 1, 0)
    end

    return root.Position - Vector3.new(0, 3, 0)
end

local function findSaplingInstance()
    local items = Services.Workspace:FindFirstChild("Items")
    if items then
        for _, v in ipairs(items:GetChildren()) do
            if v.Name:lower():find("sapling") then
                return v
            end
        end
    end

    for _, c in ipairs(Services.ReplicatedStorage:GetDescendants()) do
        if (c:IsA("Model") or c:IsA("Tool")) and c.Name:lower():find("sapling") then
            return c
        end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local inv = LocalPlayer:FindFirstChild("Inventory")
    local containers = { backpack, inv }

    for _, cont in ipairs(containers) do
        if cont then
            for _, c in ipairs(cont:GetChildren()) do
                if c.Name:lower():find("sapling") then
                    return c
                end
            end
        end
    end
    return "Sapling"
end

local function tryCallRemote(remote, argTable)
    if not remote then return false end

    if remote.ClassName == "RemoteFunction" or remote.InvokeServer then
        local ok = pcall(function()
            remote:InvokeServer(unpack(argTable))
        end)
        return ok
    end

    if remote.ClassName == "RemoteEvent" or remote.FireServer then
        local ok = pcall(function()
            remote:FireServer(unpack(argTable))
        end)
        return ok
    end
    return false
end

local function robustPlantCall(remote, saplingArg, position)
    if not remote then return false end

    local attempts = {
        { saplingArg, position },
        { position, saplingArg },
        { tostring(saplingArg), position },
        { position, tostring(saplingArg) },
    }

    for _, args in ipairs(attempts) do
        if tryCallRemote(remote, args) then
            return true
        end
        task.wait(0.03)
    end
    return false
end

-- MARKER SYSTEM
local function createMarker(pos)
    if not State.INFINITE_SHOW_MARKER then return end

    local p = Instance.new("Part")
    p.Size = Vector3.new(1, 1, 1)
    p.Anchored = true
    p.CanCollide = false
    p.Transparency = 0.3
    p.Color = Color3.fromRGB(50, 255, 50)
    p.Material = Enum.Material.Neon
    p.Name = "SaplingMarker"
    p.CFrame = CFrame.new(pos + Vector3.new(0, 0.5, 0))
    p.Parent = Services.Workspace
    Services.Debris:AddItem(p, State.INFINITE_MARKER_LIFETIME)

    table.insert(State.characterPlantHistory, {
        position = pos,
        time = tick(),
        marker = p
    })

    if #State.characterPlantHistory > 50 then
        local oldest = table.remove(State.characterPlantHistory, 1)
        if oldest.marker and oldest.marker.Parent then
            oldest.marker:Destroy()
        end
    end
end

local function clearOldMarkers()
    local currentTime = tick()
    for i = #State.characterPlantHistory, 1, -1 do
        local record = State.characterPlantHistory[i]
        if currentTime - record.time > State.INFINITE_MARKER_LIFETIME then
            if record.marker and record.marker.Parent then
                record.marker:Destroy()
            end
            table.remove(State.characterPlantHistory, i)
        end
    end
end

-- INFINITE SAPLING LOGIC
local function plantInfiniteCycle()
    if not State.infiniteSaplingEnabled then return end

    local sapInst = findSaplingInstance()
    local firstArg = sapInst or "Sapling"

    if State.plantingMode == "character" then
        for i = 1, State.overlayPoints do
            if not State.plantingActive then break end

            local footPos = getFootPosition()
            if footPos then
                createMarker(footPos)
                robustPlantCall(State.PlantRemote, firstArg, footPos)
                State.totalPlanted = State.totalPlanted + 1

                task.wait(0.05)

                if i < State.overlayPoints then
                    footPos = getFootPosition()
                end
            end
        end
    else
        if #State.overlayParts > 0 then
            for _, overlayPart in ipairs(State.overlayParts) do
                if not State.plantingActive then break end

                createMarker(overlayPart.Position)
                robustPlantCall(State.PlantRemote, firstArg, overlayPart.Position)
                State.totalPlanted = State.totalPlanted + 1
                task.wait(0.05)
            end

            State.plantingCompleted = true
            stopPlanting()

            showWindUINotification(
                "Infinite Planting",
                "✅ Cycle selesai!\n" ..
                "Total ditanam: " .. State.totalPlanted .. " pohon\n" ..
                "Mode: Infinite (satu cycle)",
                "Success",
                5
            )
        end
    end

    clearOldMarkers()
end

-- NORMAL PLANTING (single)
local function plantSingle()
    if State.plantingMode == "overlay" and #State.overlayParts > 0 then
        if State.plantSequenceIndex > #State.overlayParts then
            State.plantingCompleted = true
            stopPlanting()

            showWindUINotification(
                "Planting System",
                "✅ Penanaman selesai!\n" ..
                "Total ditanam: " .. State.totalPlanted .. " pohon\n" ..
                "Titik overlay: " .. #State.overlayParts,
                "Success",
                5
            )
            return
        end
    end

    local pos

    if State.plantingMode == "overlay" then
        if #State.overlayParts > 0 then
            pos = State.overlayParts[State.plantSequenceIndex].Position
            State.plantSequenceIndex = State.plantSequenceIndex + 1
        else
            local footPos = getFootPosition()
            if not footPos then return end
            pos = footPos
        end
    else
        pos = getFootPosition()
        if not pos then return end
    end

    local sapInst = findSaplingInstance()
    local firstArg = sapInst or "Sapling"

    local success = robustPlantCall(State.PlantRemote, firstArg, pos)
    if success then
        State.totalPlanted = State.totalPlanted + 1
        createMarker(pos)
    end

    if State.plantingMode == "overlay" and #State.overlayParts > 0 then
        local progress = math.floor((State.plantSequenceIndex - 1) / #State.overlayParts * 100)
        if progress <= 100 then
            if progress % 25 == 0 and progress > 0 then
                showWindUINotification(
                    "Planting Progress",
                    "Progress: " .. progress .. "%\n" ..
                    "(" .. (State.plantSequenceIndex - 1) .. "/" .. #State.overlayParts .. " titik)",
                    "Info",
                    2
                )
            end
        end
    end
end

-- PLANTING LOGIC TERPADU
function startPlanting()
    if State.plantingActive then
        showWindUINotification(
            "Planting System",
            "Penanaman sudah aktif!",
            "Warning",
            2
        )
        return
    end

    State.plantingActive = true
    State.plantingCompleted = false
    State.totalPlanted = 0
    State.plantSequenceIndex = 1

    if State.plantingMode == "overlay" then
        State.maxPlantPoints = #State.overlayParts
        if State.maxPlantPoints == 0 then
            showWindUINotification(
                "Planting System",
                "⚠ Overlay tidak aktif/tidak ada titik!\nBeralih ke mode karakter...",
                "Warning",
                3
            )
            State.plantingMode = "character"
        else
            showWindUINotification(
                "Planting System",
                "▶ Memulai penanaman...\n" ..
                "Mode: " .. State.plantingMode .. "\n" ..
                "Titik: " .. State.maxPlantPoints .. "\n" ..
                "Shape: " .. State.overlayShape .. "\n" ..
                "Layer: " .. State.angleIncrement,
                "Info",
                4
            )
        end
    else
        State.maxPlantPoints = State.overlayPoints
        showWindUINotification(
            "Planting System",
            "▶ Memulai penanaman...\n" ..
            "Mode: Character\n" ..
            "Target: " .. State.maxPlantPoints .. " pohon",
            "Info",
            4
        )
    end

    State.plantingThread = task.spawn(function()
        while State.plantingActive and not State.plantingCompleted do
            if State.infiniteSaplingEnabled then
                plantInfiniteCycle()
                task.wait(State.plantInterval)
            else
                plantSingle()
                task.wait(State.plantInterval)
            end
        end
    end)
end

function stopPlanting()
    State.plantingActive = false
    if State.plantingThread then
        task.cancel(State.plantingThread)
        State.plantingThread = nil
    end

    if not State.plantingCompleted then
        showWindUINotification(
            "Planting System",
            "⏹ Penanaman dihentikan\n" ..
            "Total ditanam: " .. State.totalPlanted .. " pohon\n" ..
            "Progress: " .. (State.plantSequenceIndex - 1) .. "/" .. State.maxPlantPoints,
            "Info",
            4
        )
    end

    for _, record in ipairs(State.characterPlantHistory) do
        if record.marker and record.marker.Parent then
            record.marker:Destroy()
        end
    end
    State.characterPlantHistory = {}
end

local function resetPlantingProgress()
    State.plantSequenceIndex = 1
    State.totalPlanted = 0
    State.plantingCompleted = false

    showWindUINotification(
        "Planting System",
        "🔄 Progress penanaman direset\nSequence kembali ke titik awal",
        "Info",
        3
    )
end

-- SPIRAL FLIGHT
local function startSpiralFlight()
    if State.spiralActive then return end
    State.spiralActive = true

    local root = getRoot()
    if not root then return end

    State.spiralThread = task.spawn(function()
        local startTime = tick()
        local duration = 60
        local radius = 1000
        local loops = 10

        while State.spiralActive and tick() - startTime < duration do
            local t = (tick() - startTime) / duration
            local angle = t * math.pi * 2 * loops
            local r = t * radius

            local target = Vector3.new(
                State.spiralCenter.X + math.cos(angle) * r,
                State.spiralCenter.Y,
                State.spiralCenter.Z + math.sin(angle) * r
            )

            local dir = (target - root.Position)
            if dir.Magnitude > State.flySpeed then
                dir = dir.Unit * State.flySpeed
            end

            root.CFrame = CFrame.new(root.Position + dir)
            task.wait()
        end

        State.spiralActive = false
        if root then
            root.CFrame = CFrame.new(State.groundPosition)
        end
    end)
end

local function stopSpiralFlight()
    State.spiralActive = false
    if State.spiralThread then
        task.cancel(State.spiralThread)
        State.spiralThread = nil
    end
    local root = getRoot()
    if root then
        root.CFrame = CFrame.new(State.groundPosition)
    end
end

-- OVERLAY SYSTEM
local function clearOverlay()
    for _, p in ipairs(State.overlayParts) do
        if p.Parent then p:Destroy() end
    end
    State.overlayParts = {}
end

local function createOverlay()
    clearOverlay()

    local layers = State.angleIncrement
    local basePoints = math.floor(State.overlayPoints / layers)
    local remainder = State.overlayPoints % layers

    for layer = 1, layers do
        local layerRadius = State.overlayRadius + ((layer - 1) * State.radiusIncrement)
        local layerPoints = basePoints
        if layer == layers then
            layerPoints = layerPoints + remainder
        end

        local hue = (layer / layers) * 0.7
        local layerColor = Color3.fromHSV(hue, 0.8, 1)

        if State.overlayShape == "circle" then
            for i = 1, layerPoints do
                local a = (i / layerPoints) * math.pi * 2
                local p = Instance.new("Part")
                p.Size = Vector3.new(1, 1, 1)
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.Color = layerColor
                p.Transparency = 0.3
                p.Position = Vector3.new(
                    State.overlayCenter.X + math.cos(a) * layerRadius,
                    State.overlayCenter.Y,
                    State.overlayCenter.Z + math.sin(a) * layerRadius
                )
                p.Parent = Services.Workspace
                table.insert(State.overlayParts, p)
            end

        elseif State.overlayShape == "square" then
            local pointsPerSide = math.max(1, math.floor(layerPoints / 4))
            local halfSize = layerRadius

            for side = 1, 4 do
                for i = 1, pointsPerSide do
                    local t = (i - 1) / math.max(1, pointsPerSide - 1)
                    local x, z = 0, 0

                    if side == 1 then
                        x = -halfSize + (t * 2 * halfSize)
                        z = halfSize
                    elseif side == 2 then
                        x = halfSize
                        z = halfSize - (t * 2 * halfSize)
                    elseif side == 3 then
                        x = halfSize - (t * 2 * halfSize)
                        z = -halfSize
                    elseif side == 4 then
                        x = -halfSize
                        z = -halfSize + (t * 2 * halfSize)
                    end

                    local p = Instance.new("Part")
                    p.Size = Vector3.new(1, 1, 1)
                    p.Anchored = true
                    p.CanCollide = false
                    p.Material = Enum.Material.Neon
                    p.Color = layerColor
                    p.Transparency = 0.3
                    p.Position = Vector3.new(
                        State.overlayCenter.X + x,
                        State.overlayCenter.Y,
                        State.overlayCenter.Z + z
                    )
                    p.Parent = Services.Workspace
                    table.insert(State.overlayParts, p)
                end
            end

        elseif State.overlayShape == "triangle" then
            local trianglePoints = 3
            local pointsPerSide = math.max(1, math.floor(layerPoints / trianglePoints))
            local vertices = {
                Vector3.new(0, 0, layerRadius),
                Vector3.new(layerRadius * 0.866, 0, -layerRadius * 0.5),
                Vector3.new(-layerRadius * 0.866, 0, -layerRadius * 0.5)
            }

            for side = 1, trianglePoints do
                for i = 1, pointsPerSide do
                    local t = (i - 1) / math.max(1, pointsPerSide - 1)
                    local startPoint = vertices[side]
                    local endPoint = vertices[(side % trianglePoints) + 1]

                    local x = startPoint.X + (endPoint.X - startPoint.X) * t
                    local z = startPoint.Z + (endPoint.Z - startPoint.Z) * t

                    local p = Instance.new("Part")
                    p.Size = Vector3.new(1, 1, 1)
                    p.Anchored = true
                    p.CanCollide = false
                    p.Material = Enum.Material.Neon
                    p.Color = layerColor
                    p.Transparency = 0.3
                    p.Position = Vector3.new(
                        State.overlayCenter.X + x,
                        State.overlayCenter.Y,
                        State.overlayCenter.Z + z
                    )
                    p.Parent = Services.Workspace
                    table.insert(State.overlayParts, p)
                end
            end

        elseif State.overlayShape == "star" then
            for i = 1, layerPoints do
                local angle = (i / layerPoints) * math.pi * 2
                local innerRadius = layerRadius * 0.4
                local outerRadius = layerRadius

                local r = i % 2 == 0 and innerRadius or outerRadius
                local starAngle = angle * 5 / 2

                local x = math.cos(starAngle) * r
                local z = math.sin(starAngle) * r

                local p = Instance.new("Part")
                p.Size = Vector3.new(1, 1, 1)
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.Color = layerColor
                p.Transparency = 0.3
                p.Position = Vector3.new(
                    State.overlayCenter.X + x,
                    State.overlayCenter.Y,
                    State.overlayCenter.Z + z
                )
                p.Parent = Services.Workspace
                table.insert(State.overlayParts, p)
            end

        elseif State.overlayShape == "hexagon" then
            local sides = 6
            local pointsPerSide = math.max(1, math.floor(layerPoints / sides))

            for side = 0, sides - 1 do
                for i = 1, pointsPerSide do
                    local t = (i - 1) / math.max(1, pointsPerSide - 1)
                    local angle1 = (side / sides) * math.pi * 2
                    local angle2 = ((side + 1) / sides) * math.pi * 2

                    local x1 = math.cos(angle1) * layerRadius
                    local z1 = math.sin(angle1) * layerRadius
                    local x2 = math.cos(angle2) * layerRadius
                    local z2 = math.sin(angle2) * layerRadius

                    local x = x1 + (x2 - x1) * t
                    local z = z1 + (z2 - z1) * t

                    local p = Instance.new("Part")
                    p.Size = Vector3.new(1, 1, 1)
                    p.Anchored = true
                    p.CanCollide = false
                    p.Material = Enum.Material.Neon
                    p.Color = layerColor
                    p.Transparency = 0.3
                    p.Position = Vector3.new(
                        State.overlayCenter.X + x,
                        State.overlayCenter.Y,
                        State.overlayCenter.Z + z
                    )
                    p.Parent = Services.Workspace
                    table.insert(State.overlayParts, p)
                end
            end

        elseif State.overlayShape == "spiral" then
            for i = 1, layerPoints do
                local t = i / layerPoints
                local angle = t * math.pi * 8
                local r = t * layerRadius

                local x = math.cos(angle) * r
                local z = math.sin(angle) * r

                local p = Instance.new("Part")
                p.Size = Vector3.new(1, 1, 1)
                p.Anchored = true
                p.CanCollide = false
                p.Material = Enum.Material.Neon
                p.Color = layerColor
                p.Transparency = 0.3
                p.Position = Vector3.new(
                    State.overlayCenter.X + x,
                    State.overlayCenter.Y,
                    State.overlayCenter.Z + z
                )
                p.Parent = Services.Workspace
                table.insert(State.overlayParts, p)
            end

        elseif State.overlayShape == "diamond" then
            local vertices = {
                Vector3.new(0, 0, layerRadius),
                Vector3.new(layerRadius, 0, 0),
                Vector3.new(0, 0, -layerRadius),
                Vector3.new(-layerRadius, 0, 0)
            }
            local pointsPerSide = math.max(1, math.floor(layerPoints / 4))

            for side = 1, 4 do
                for i = 1, pointsPerSide do
                    local t = (i - 1) / math.max(1, pointsPerSide - 1)
                    local startPoint = vertices[side]
                    local endPoint = vertices[(side % 4) + 1]

                    local x = startPoint.X + (endPoint.X - startPoint.X) * t
                    local z = startPoint.Z + (endPoint.Z - startPoint.Z) * t

                    local p = Instance.new("Part")
                    p.Size = Vector3.new(1, 1, 1)
                    p.Anchored = true
                    p.CanCollide = false
                    p.Material = Enum.Material.Neon
                    p.Color = layerColor
                    p.Transparency = 0.3
                    p.Position = Vector3.new(
                        State.overlayCenter.X + x,
                        State.overlayCenter.Y,
                        State.overlayCenter.Z + z
                    )
                    p.Parent = Services.Workspace
                    table.insert(State.overlayParts, p)
                end
            end
        end
    end
end

function updateOverlay()
    if State.overlayVisible then
        createOverlay()
    else
        clearOverlay()
    end
end

-- LOG WALL FUNCTIONS
local function findLogWallBlueprint()
    local player = LocalPlayer
    local inventory = player:FindFirstChild("Inventory")

    if not inventory then
        warn("[FRENESIS] Inventory Not Found!")
        return nil
    end

    local found = {}

    for _, item in ipairs(inventory:GetChildren()) do
        if item.Name == "Log Wall Blueprint" then
            table.insert(found, item)
        end
    end

    if #found == 0 then
        for _, item in ipairs(inventory:GetChildren()) do
            if string.find(item.Name:lower(), "log") and string.find(item.Name:lower(), "wall") then
                table.insert(found, item)
            end
        end
    end

    if #found > 0 then
        return found[1]
    end

    return nil
end

local function countLogWallBlueprints()
    local player = LocalPlayer
    local inventory = player:FindFirstChild("Inventory")
    local count = 0

    if inventory then
        for _, item in ipairs(inventory:GetChildren()) do
            if item.Name == "Log Wall Blueprint" then
                count = count + 1
            end
        end
        if count == 0 then
            for _, item in ipairs(inventory:GetChildren()) do
                if string.find(item.Name:lower(), "log") and string.find(item.Name:lower(), "wall") then
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function getRotationForShape(position, index, totalPoints, shape)
    local overlayCenter = State.overlayCenter
    if shape == "circle" then
        local direction = (position - overlayCenter)
        direction = Vector3.new(direction.X, 0, direction.Z)
        if direction.Magnitude > 0 then
            return math.atan2(-direction.Z, direction.X)
        end

    elseif shape == "square" then
        local localPos = position - overlayCenter
        if math.abs(localPos.X) > math.abs(localPos.Z) then
            return (localPos.X > 0) and math.rad(90) or math.rad(270)
        else
            return (localPos.Z > 0) and math.rad(0) or math.rad(180)
        end

    elseif shape == "triangle" then
        return (index % 3) * math.rad(120)

    elseif shape == "hexagon" then
        return (index % 6) * math.rad(60)

    elseif shape == "star" then
        return (index * math.rad(72)) % math.rad(360)

    elseif shape == "diamond" then
        local angle = (index % 8) * math.rad(45)
        return angle + math.rad(22.5)
    end

    return 0
end

local function placeLogWallAtPosition(position, index, totalPoints)
    if not State.placeStructureRemote then
        warn("[FRENESIS] RequestPlaceStructure remote Not Found!")
        return false
    end

    local blueprint = findLogWallBlueprint()
    if not blueprint then
        warn("[FRENESIS] Log Wall Blueprint Not Found di inventory!")
        return false
    end

    local rotationY = 0
    local shape = State.overlayShape
    local overlayCenter = State.overlayCenter

    if shape == "circle" then
        local angle = (index / totalPoints) * math.pi * 2
        rotationY = angle

    elseif shape == "square" then
        local localPos = position - overlayCenter
        if math.abs(localPos.X) > math.abs(localPos.Z) then
            local side = localPos.X > 0 and "right" or "left"
            rotationY = (side == "right") and math.rad(90) or math.rad(270)
        else
            local side = localPos.Z > 0 and "top" or "bottom"
            rotationY = (side == "top") and math.rad(0) or math.rad(180)
        end

    elseif shape == "triangle" then
        rotationY = (index % 3) * math.rad(120)

    elseif shape == "star" then
        rotationY = (index * math.rad(72)) % math.rad(360)

    else
        local direction = (position - overlayCenter)
        direction = Vector3.new(direction.X, 0, direction.Z)
        if direction.Magnitude > 0 then
            rotationY = math.atan2(-direction.Z, direction.X)
        end
    end

    local cframe = CFrame.new(position) * CFrame.Angles(0, rotationY, 0)
    local argsTable = {
        CFrame = cframe,
        Position = position,
        Valid = true
    }

    local rotOnly = CFrame.new(0, 0, 0, cframe.RightVector, cframe.UpVector, cframe.LookVector)

    local success, result = pcall(function()
        return State.placeStructureRemote:InvokeServer(blueprint, argsTable, rotOnly)
    end)

    if success then
        return true
    else
        warn("[FRENESIS] Gagal menempatkan Log Wall:", result)
        return false
    end
end

local function startAutoLogWall()
    if State.logWallActive then return end

    if #State.overlayParts == 0 then
        showWindUINotification(
            "Log Wall System",
            "⚠ Overlay tidak aktif/tidak ada titik!\nAktifkan overlay terlebih dahulu.",
            "Warning",
            3
        )
        return
    end

    local blueprintCount = countLogWallBlueprints()
    if blueprintCount == 0 then
        showWindUINotification(
            "Log Wall System",
            "✗ Tidak ada Log Wall Blueprint di inventory!",
            "Error",
            5
        )
        return
    end

    local totalPoints = #State.overlayParts
    local maxPlaceable = math.min(blueprintCount, totalPoints)

    State.logWallActive = true
    local placedCount = 0
    local failedCount = 0

    showWindUINotification(
        "Log Wall System",
        "▶ Memulai penempatan Log Wall...\n" ..
        "Titik overlay: " .. totalPoints .. "\n" ..
        "Blueprint tersedia: " .. blueprintCount .. "\n" ..
        "Bentuk: " .. State.overlayShape,
        "Info",
        4
    )

    State.logWallThread = task.spawn(function()
        for i, overlayPart in ipairs(State.overlayParts) do
            if not State.logWallActive then break end

            if countLogWallBlueprints() == 0 then
                showWindUINotification(
                    "Log Wall System",
                    "⚠ Blueprint habis, menghentikan...",
                    "Warning",
                    3
                )
                break
            end

            local success = placeLogWallAtPosition(overlayPart.Position, i, totalPoints)

            if success then
                placedCount = placedCount + 1
                if overlayPart and overlayPart.Parent then
                    overlayPart.Color = Color3.fromRGB(255, 100, 100)
                    overlayPart.Transparency = 0.1
                end

                if placedCount % 5 == 0 then
                    local remaining = countLogWallBlueprints()
                    local progress = math.floor((i / totalPoints) * 100)
                    showWindUINotification(
                        "Log Wall Progress",
                        "Progress: " .. progress .. "%\n" ..
                        "Berhasil: " .. placedCount .. " / " .. maxPlaceable .. "\n" ..
                        "Blueprint tersisa: " .. remaining,
                        "Success",
                        2
                    )
                end
            else
                failedCount = failedCount + 1
            end

            task.wait(0.3)
        end

        State.logWallActive = false

        local summary = "✅ Penempatan Log Wall selesai!\n" ..
                       "Berhasil: " .. placedCount .. "\n" ..
                       "Gagal: " .. failedCount .. "\n" ..
                       "Blueprint tersisa: " .. countLogWallBlueprints()

        showWindUINotification(
            "Log Wall System - Selesai",
            summary,
            "Success",
            6
        )

        task.wait(2)
        if State.overlayVisible then
            updateOverlay()
        end
    end)
end

local function stopAutoLogWall()
    State.logWallActive = false
    if State.logWallThread then
        task.cancel(State.logWallThread)
        State.logWallThread = nil
    end
    showWindUINotification(
        "Log Wall System",
        "⏹ Penempatan Log Wall dihentikan",
        "Info",
        3
    )
end

-- AUTO CHEST OPENER FUNCTIONS
local function findAllChests()
    local foundChests = {}
    local itemsFolder = Services.Workspace:FindFirstChild("Items")
    if itemsFolder then
        local chests = itemsFolder:GetChildren()
        for _, chest in ipairs(chests) do
            for _, chestType in ipairs(State.chestTypes) do
                if chest:IsA("Model") and chest.Name == chestType then
                    local hasLid = false
                    for _, child in ipairs(chest:GetChildren()) do
                        if child:IsA("Model") and child.Name == "ChestLid" then
                            hasLid = true
                            break
                        end
                    end
                    if hasLid then
                        table.insert(foundChests, {
                            instance = chest,
                            name = chest.Name,
                            parent = "Items",
                            position = chest:GetPivot().Position
                        })
                    end
                end
            end
        end
    end

    -- Cari di seluruh workspace
    local allChests = Services.Workspace:GetDescendants()
    for _, obj in ipairs(allChests) do
        for _, chestType in ipairs(State.chestTypes) do
            if obj:IsA("Model") and obj.Name == chestType then
                local alreadyFound = false
                for _, found in ipairs(foundChests) do
                    if found.instance == obj then
                        alreadyFound = true
                        break
                    end
                end
                if not alreadyFound then
                    local hasLid = false
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("Model") and (child.Name == "ChestLid" or string.find(child.Name:lower(), "lid")) then
                            hasLid = true
                            break
                        end
                    end
                    if hasLid or obj.Name == "ChristmasPresent1" then
                        table.insert(foundChests, {
                            instance = obj,
                            name = obj.Name,
                            parent = obj.Parent and obj.Parent.Name or "Workspace",
                            position = obj:GetPivot().Position
                        })
                    end
                end
            end
        end
    end

    -- Cari objek lain yang mengandung "chest" atau "present"
    local allObjects = Services.Workspace:GetDescendants()
    for _, obj in ipairs(allObjects) do
        if obj:IsA("Model") and (string.find(obj.Name:lower(), "chest") or string.find(obj.Name:lower(), "present")) then
            local alreadyFound = false
            for _, found in ipairs(foundChests) do
                if found.instance == obj then
                    alreadyFound = true
                    break
                end
            end
            if not alreadyFound then
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("Model") and (child.Name == "ChestLid" or string.find(child.Name:lower(), "lid")) then
                        table.insert(foundChests, {
                            instance = obj,
                            name = obj.Name,
                            parent = obj.Parent and obj.Parent.Name or "Workspace",
                            position = obj:GetPivot().Position
                        })
                        break
                    end
                end
            end
        end
    end

    local charPos = LocalPlayer.Character and LocalPlayer.Character:GetPivot().Position or Vector3.new(0, 0, 0)
    table.sort(foundChests, function(a, b)
        return (a.position - charPos).Magnitude < (b.position - charPos).Magnitude
    end)

    return foundChests
end

local function openSingleChest(chestInstance)
    if chestInstance and chestInstance.Parent then
        local args = {chestInstance}
        local success, errorMsg = pcall(function()
            if State.RequestOpenItemChest then
                State.RequestOpenItemChest:FireServer(unpack(args))
                return true
            end
            return false
        end)
        if success then
            State.openedChests[chestInstance] = true
            return true, "Berhasil membuka: " .. chestInstance.Name
        else
            return false, "Gagal membuka " .. chestInstance.Name .. ": " .. tostring(errorMsg)
        end
    else
        return false, "Chest tidak valid atau sudah deleted"
    end
end

local function rescanChests()
    State.chestQueue = findAllChests()
    State.openedChests = {}
    return #State.chestQueue
end

local function startAutoOpenChests()
    if State.isOpeningChests then return end

    if #State.chestQueue == 0 then
        rescanChests()
    end

    if #State.chestQueue == 0 then
        showWindUINotification(
            "Chest Opener",
            "Tidak ada chest yang ditemukan!",
            "Warning",
            3
        )
        return
    end

    State.isOpeningChests = true
    local totalChests = #State.chestQueue
    local openedCount = 0
    local failedCount = 0

    showWindUINotification(
        "Chest Opener",
        "Memulai membuka " .. totalChests .. " chest...",
        "Info",
        2
    )

    State.chestOpeningThread = task.spawn(function()
        for i, chestInfo in ipairs(State.chestQueue) do
            if not State.isOpeningChests then break end

            if State.openedChests[chestInfo.instance] then
                -- continue
            else
                local success, message = openSingleChest(chestInfo.instance)
                if success then
                    openedCount = openedCount + 1
                    showWindUINotification(
                        "Chest Opener",
                        "✓ " .. chestInfo.name .. " (" .. i .. "/" .. totalChests .. ")",
                        "Success",
                        1
                    )
                else
                    failedCount = failedCount + 1
                    showWindUINotification(
                        "Chest Opener",
                        "✗ " .. chestInfo.name .. " - Gagal",
                        "Error",
                        1
                    )
                end
            end

            task.wait(State.chestOpeningSpeed)
        end

        local summary = "Selesai!\nChest terbuka: " .. openedCount .. "/" .. totalChests .. "\nGagal: " .. failedCount

        if openedCount > 0 then
            showWindUINotification(
                "Chest Opener - Selesai",
                summary,
                "Success",
                5
            )
        else
            showWindUINotification(
                "Chest Opener - Selesai",
                summary,
                "Warning",
                5
            )
        end

        State.isOpeningChests = false
        State.chestOpeningThread = nil
    end)
end

local function stopAutoOpenChests()
    State.isOpeningChests = false
    if State.chestOpeningThread then
        task.cancel(State.chestOpeningThread)
        State.chestOpeningThread = nil
    end
    showWindUINotification(
        "Chest Opener",
        "Membuka chest dihentikan",
        "Info",
        2
    )
end

local function scanStrongholdChests()
    local results = {}

    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v:IsA("Model")
           and (v.Name == "Stronghold Diamond Chest" or v.Name == "Item Chest6") then
            table.insert(results, v)
        end
    end

    return results
end

local function openScannedStrongholdChests(chests)
    if not State.RequestOpenItemChest then return end

    for _, chest in ipairs(chests) do
        if chest and chest.Parent then
            pcall(function()
                State.RequestOpenItemChest:FireServer(chest)
            end)
            task.wait(0.25)
        end
    end
end

---------------------------------------------------------
-- ORIGINAL FULL.LUA FUNCTIONS
---------------------------------------------------------
-- BRING ITEM: scrapper target for bring
local function getScrapperTarget_Bring()
    if State.ScrapperTarget_Bring and State.ScrapperTarget_Bring.Parent then return State.ScrapperTarget_Bring end
    local map = Services.Workspace:FindFirstChild("Map")
    local camp = map and map:FindFirstChild("Campground")
    local scrapper = camp and camp:FindFirstChild("Scrapper")
    local movers = scrapper and scrapper:FindFirstChild("Movers")
    local right = movers and movers:FindFirstChild("Right")
    local grinder = right and right:FindFirstChild("GrindersRight")
    if grinder and grinder:IsA("BasePart") then
        State.ScrapperTarget_Bring = grinder
        return grinder
    end
    return nil
end

-- WAIT FOR RESOURCES untuk Bring Item system
local function waitForEssentialResources()
    -- ensure Character
    repeat
        State.Character = LocalPlayer.Character
        task.wait()
    until State.Character

    State.HumanoidRootPart = State.Character:WaitForChild("HumanoidRootPart")
    print("[Resource] Karakter siap.")

    while not State.scriptDisabled do
        State.ItemsFolder = Services.Workspace:FindFirstChild("Items")
        State.RemoteEvents = Services.ReplicatedStorage:FindFirstChild("RemoteEvents")
        if State.ItemsFolder and State.RemoteEvents then
            State.RequestStartDragging = State.RemoteEvents:FindFirstChild("RequestStartDraggingItem")
            State.RequestStopDragging = State.RemoteEvents:FindFirstChild("StopDraggingItem")
            if State.RequestStartDragging and State.RequestStopDragging then
                print("[Resource] Semua remote 'Bring Item' ditemukan.")
                initFarmRemotes()
                break
            end
        end
        task.wait(1)
    end
end

-- spawn background
task.spawn(waitForEssentialResources)

-- FISHING overlay helpers
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
        dot.Position = UDim2.new(0, math.floor(x + State.fishingOffsetX), 0, math.floor(y + State.fishingOffsetY))
    end
end

local function fishingHideOverlay()
    local g = LocalPlayer.PlayerGui:FindFirstChild("XenoPositionOverlay")
    if g then g.Enabled = false; if g.RedDot then g.RedDot.Visible = false end end
end

local function fishingDoClick()
    if not State.fishingSavedPosition then return end
    local x = math.floor(State.fishingSavedPosition.x + State.fishingOffsetX)
    local y = math.floor(State.fishingSavedPosition.y + State.fishingOffsetY)
    pcall(function()
        Services.VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.01)
        Services.VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
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
    if not State.zoneEnabled or State.zoneDestroyed then return end
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
    if State.zoneDestroyed then return false end
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
        local cam = Services.Workspace.CurrentCamera
        local pt = cam and Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2) or Vector2.new(300,300)
        Services.VirtualUser:Button1Down(pt); task.wait(0.02); Services.VirtualUser:Button1Up(pt)
    end)
end

local function zone_startSpam()
    if State.zoneSpamClicking or State.zoneDestroyed or not State.zoneEnabled then return end
    State.zoneSpamClicking = true
    State.zoneSpamThread = task.spawn(function()
        while State.zoneSpamClicking and not State.zoneDestroyed and State.zoneEnabled do
            if not zone_isTimingBarVisible() then State.zoneSpamClicking = false; break end
            zone_doSpamClick()
            task.wait(State.zoneSpamInterval)
        end
    end)
end

local function zone_stopSpam()
    State.zoneSpamClicking = false
end

local function startZone()
    State.zoneDestroyed = false
    State.zoneEnabled = true
    task.spawn(function()
        while not State.zoneDestroyed do
            task.wait(0.15)
            if State.zoneEnabled then pcall(zone_makeGreenFull) end
        end
    end)
    task.spawn(function()
        State.zoneLastVisible = zone_isTimingBarVisible()
        State.wasTimingBarVisible = State.zoneLastVisible
        if State.zoneLastVisible then State.lastTimingBarSeenAt = tick() end
        while not State.zoneDestroyed do
            task.wait(0.06)
            local nowVisible = zone_isTimingBarVisible()
            if nowVisible then State.lastTimingBarSeenAt = tick() end
            if nowVisible ~= State.zoneLastVisible then
                State.zoneLastVisible = nowVisible
                if nowVisible then
                    State.wasTimingBarVisible = true
                    State.lastTimingBarSeenAt = tick()
                    if State.zoneEnabled then pcall(zone_makeGreenFull); zone_startSpam() end
                else
                    zone_stopSpam()
                    if State.autoRecastEnabled and State.fishingSavedPosition then
                        local sinceSeen = tick() - State.lastTimingBarSeenAt
                        local sinceRecast = tick() - State.lastRecastAt
                        if State.wasTimingBarVisible and sinceSeen <= State.MAX_RECENT_SECS and sinceRecast >= State.RECAST_DELAY then
                            task.spawn(function()
                                task.wait(State.RECAST_DELAY)
                                fishingDoClick()
                                State.lastRecastAt = tick()
                                if State.WindUI then State.WindUI:Notify({Title="Auto Recast", Content="Recast dilakukan.", Duration=2}) end
                            end)
                        end
                    end
                    State.wasTimingBarVisible = false
                end
            end
        end
    end)
    task.spawn(function()
        task.wait(0.15)
        if State.zoneEnabled and zone_isTimingBarVisible() then zone_startSpam() end
    end)
end

local function stopZone()
    State.zoneEnabled = false
    zone_stopSpam()
    State.zoneDestroyed = true
end

-- FARM: Lava finder
local function findLava()
    if State.lavaFound then return end
    local map = Services.Workspace:FindFirstChild("Map")
    if not map then return end
    local landmarks = map:FindFirstChild("Landmarks")
    if not landmarks then return end
    local volcano = landmarks:FindFirstChild("Volcano")
    if not volcano then return end
    local functional = volcano:FindFirstChild("Functional")
    if not functional then return end
    local lava = functional:FindFirstChild("Lava")
    if lava and lava:IsA("BasePart") then
        State.LavaCFrame = lava.CFrame * CFrame.new(0, 4, 0)
        State.lavaFound = true
        print("[Lava] Volcano lava ditemukan.")
        notifyUI("Lava", "Volcano lava found. Auto-sacrifice ready.", 4, "flame")
    end
end

task.spawn(function()
    while not State.lavaFound and not State.scriptDisabled do
        findLava()
        task.wait(1.5)
    end
end)

-- AUTO SACRIFICE
local function sacrificeItemToLava(item)
    if not State.AutoSacEnabled then return end
    if not item or not item.Parent or not item:IsA("Model") or not item.PrimaryPart then return end
    if not State.lavaFound or not State.LavaCFrame then return end
    if not table.find(State.SacrificeList, item.Name) then return end
    pcall(function()
        if State.RequestStartDragging then State.RequestStartDragging:FireServer(item) end
        task.wait(0.1)
        local offset = CFrame.new(math.random(-6, 6), 0, math.random(-6, 6))
        item:PivotTo(State.LavaCFrame * offset)
        task.wait(0.2)
        if State.RequestStopDragging then State.RequestStopDragging:FireServer(item) end
    end)
end

task.spawn(function()
    while not State.scriptDisabled do
        if State.AutoSacEnabled and State.lavaFound and State.ItemsFolder then
            for _, obj in ipairs(State.ItemsFolder:GetChildren()) do
                sacrificeItemToLava(obj)
            end
        end
        task.wait(0.7)
    end
end)

-- AUTO CROCKPOT (farm)
local function ensureCookingStations()
    local structures = Services.Workspace:FindFirstChild("Structures")
    if not structures then
        State.CookingStations = {}
        warn("[Cook] workspace.Structures Not Found.")
        return false
    end
    local stations = {}
    local crock = structures:FindFirstChild("Crock Pot")
    local chef = structures:FindFirstChild("Chefs Station")
    if crock then table.insert(stations, crock) end
    if chef then table.insert(stations, chef) end
    if #stations == 0 then
        State.CookingStations = {}
        warn("[Cook] Tidak ada Crock Pot / Chefs Station.")
        return false
    end
    State.CookingStations = stations
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
    if not State.ItemsFolder then return {} end
    for _, item in ipairs(State.ItemsFolder:GetChildren()) do
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
    if not State.AutoCookEnabled then return end
    if not State.SelectedCookItems or #State.SelectedCookItems == 0 then print("[Cook] No items selected."); return end
    if not State.CookingStations or #State.CookingStations == 0 then print("[Cook] CookingStations kosong."); return end
    local targetSet = tableToSet(State.SelectedCookItems)
    print(string.format("[Cook] Mode: %s | Stations: %d", State.MoveMode or "unknown", #State.CookingStations))
    for _, station in ipairs(State.CookingStations) do
        if station and station.Parent then
            local base = getStationBase(station)
            if base then
                local candidates = collectCookCandidates(base, targetSet, State.CookItemsPerCycle)
                if #candidates == 0 then
                    print("[Cook] No candidates:", station.Name)
                else
                    local maxCount = math.min(State.CookItemsPerCycle, #candidates)
                    print(string.format("[Cook] %s | Use: %d candidates", station.Name, maxCount))
                    for i = 1, maxCount do
                        local entry = candidates[i]
                        local item = entry.instance
                        if item and item.Parent then
                            local dropCF = getCookDropCFrame(base, i)
                            pcall(function() if State.RequestStartDragging then State.RequestStartDragging:FireServer(item) end end)
                            task.wait(0.03)
                            pcall(function() item:PivotTo(dropCF) end)
                            task.wait(0.03)
                            pcall(function() if State.RequestStopDragging then State.RequestStopDragging:FireServer(item) end end)
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
    State.CookLoopId = State.CookLoopId + 1
    local current = State.CookLoopId
    task.spawn(function()
        print("[Cook] Auto Crockpot start.")
        while State.AutoCookEnabled and current == State.CookLoopId and not State.scriptDisabled do
            cookOnce()
            task.wait(math.clamp(State.CookDelaySeconds, 5, 20))
        end
        print("[Cook] Auto Crockpot stop.")
    end)
end

-- SCRAPPER for farm
State.ScrapperTargetFarm = nil

local function ensureScrapperTargetFarm()
    if State.ScrapperTargetFarm and State.ScrapperTargetFarm.Parent then return true end
    local map = Services.Workspace:FindFirstChild("Map")
    if not map then warn("[Scrap] workspace.Map Not Found."); State.ScrapperTargetFarm = nil; return false end
    local camp = map:FindFirstChild("Campground")
    if not camp then warn("[Scrap] Map.Campground Not Found."); State.ScrapperTargetFarm = nil; return false end
    local scrapper = camp:FindFirstChild("Scrapper")
    if not scrapper then warn("[Scrap] Campground.Scrapper Not Found."); State.ScrapperTargetFarm = nil; return false end
    local movers = scrapper:FindFirstChild("Movers")
    if not movers then warn("[Scrap] Scrapper.Movers Not Found."); State.ScrapperTargetFarm = nil; return false end
    local right = movers:FindFirstChild("Right")
    if not right then warn("[Scrap] Scrapper.Movers.Right Not Found."); State.ScrapperTargetFarm = nil; return false end
    local grindersRight = right:FindFirstChild("GrindersRight")
    if not grindersRight or not grindersRight:IsA("BasePart") then warn("[Scrap] GrindersRight Not Found / bukan BasePart."); State.ScrapperTargetFarm = nil; return false end
    State.ScrapperTargetFarm = grindersRight
    print("[Scrap] Scrapper target:", getInstancePath(State.ScrapperTargetFarm))
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
    if not State.ScrapEnabled then return end
    if not ensureScrapperTargetFarm() then 
        print("[Scrap] Scrapper target belum siap.")
        return 
    end
    local scrapBase = State.ScrapperTargetFarm
    for _, name in ipairs(State.ScrapItemsPriority) do
        if not State.ScrapEnabled or State.scriptDisabled then return end
        local batch = {}
        if State.ItemsFolder then
            for _, item in ipairs(State.ItemsFolder:GetChildren()) do
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
                if not State.ScrapEnabled or State.scriptDisabled then return end
                local item = entry.instance
                if item and item.Parent then
                    local dropCF = getScrapDropCFrame(scrapBase, i)
                    pcall(function() if State.RequestStartDragging then State.RequestStartDragging:FireServer(item) end end)
                    task.wait(0.02)
                    pcall(function() item:PivotTo(dropCF) end)
                    task.wait(0.02)
                    pcall(function() if State.RequestStopDragging then State.RequestStopDragging:FireServer(item) end end)
                    print(string.format("[Scrap] %s → Grinder (dist=%.1f)", item.Name, entry.distance or -1))
                    task.wait(0.02)
                end
            end
        end
    end
end

local function startScrapLoop()
    State.ScrapLoopId = State.ScrapLoopId + 1
    local current = State.ScrapLoopId
    task.spawn(function()
        print("[Scrap] Auto Scrapper start.")
        while State.ScrapEnabled and current == State.ScrapLoopId and not State.scriptDisabled do
            scrapOnceFullPass()
            task.wait(math.clamp(State.ScrapScanInterval, 10, 300))
        end
        print("[Scrap] Auto Scrapper stop.")
    end)
end

-- GODMODE & ANTI AFK
local function startGodmodeLoop()
    if State.GodmodeLoopActive then return end
    State.GodmodeLoopActive = true
    task.spawn(function()
        while State.GodmodeLoopActive and not State.scriptDisabled do
            if State.GodmodeEnabled then
                pcall(function()
                    if not State.DamagePlayerRemote then
                        State.DamagePlayerRemote = State.RemoteEvents and State.RemoteEvents:FindFirstChild("DamagePlayer")
                    end
                    if State.DamagePlayerRemote then
                        State.DamagePlayerRemote:FireServer(-math.huge)
                    else
                        State.DamagePlayerRemote = Services.ReplicatedStorage:FindFirstChild("RemoteEvents") and Services.ReplicatedStorage.RemoteEvents:FindFirstChild("DamagePlayer")
                        if not State.DamagePlayerRemote then
                            warn("[GodMode] Remote 'DamagePlayer' Not Found!")
                        end
                    end
                end)
            end
            task.wait(8)
        end
        State.GodmodeLoopActive = false
    end)
end

local function stopCoinAmmo()
    State.CoinAmmoEnabled = false
    if State.coinAmmoDescAddedConn then State.coinAmmoDescAddedConn:Disconnect(); State.coinAmmoDescAddedConn = nil end
    if State.CoinAmmoConnection then State.CoinAmmoConnection:Disconnect(); State.CoinAmmoConnection = nil end
end

local function startCoinAmmo()
    stopCoinAmmo()
    State.CoinAmmoEnabled = true
    task.spawn(function()
        for _, v in ipairs(Services.Workspace:GetDescendants()) do
            if not State.CoinAmmoEnabled or State.scriptDisabled then break end
            pcall(function()
                if v.Name == "Coin Stack" and State.CollectCoinRemote then
                    State.CollectCoinRemote:InvokeServer(v)
                elseif (v.Name == "Revolver Ammo" or v.Name == "Rifle Ammo") and State.ConsumeItemRemote then
                    State.ConsumeItemRemote:InvokeServer(v)
                end
            end)
        end
        notifyUI("Ultra Coin & Ammo", "Initial collection done. Waiting for new spawns...", 4, "zap")
        State.coinAmmoDescAddedConn = Services.Workspace.DescendantAdded:Connect(function(desc)
            if not State.CoinAmmoEnabled or State.scriptDisabled then return end
            task.wait(0.01)
            pcall(function()
                if desc.Name == "Coin Stack" and State.CollectCoinRemote then
                    State.CollectCoinRemote:InvokeServer(desc)
                elseif (desc.Name == "Revolver Ammo" or desc.Name == "Rifle Ammo") and State.ConsumeItemRemote then
                    State.ConsumeItemRemote:InvokeServer(desc)
                end
            end)
        end)
        while State.CoinAmmoEnabled and not State.scriptDisabled do task.wait(0.5) end
        stopCoinAmmo()
        print("[CoinAmmo] deactivated.")
    end)
end

-- AURA logic (heartbeat)
local function GetBestAxe(forTree)
    for name, id in pairs(State.AxeIDs) do
        if (not forTree) or (name ~= "Infernal Sword" and name ~= "Spear" and name ~= "Chainsaw" and name ~= "Ice Sword") then
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
    if tool and State.EquipHandleRemote then
        pcall(function() State.EquipHandleRemote:FireServer("FireAllClients", tool) end)
    end
end

local function buildTreeCache()
    State.TreeCache = {}
    local map = Services.Workspace:FindFirstChild("Map")
    if not map then return end
    
    -- Rebuild TreeCategories mapping
    if not State.TreeCategories then
        State.TreeCategories = {
            ["Small Tree"] = {"Small Tree"},
            ["Snowy Small Tree"] = {"Snowy Small Tree","Northern Pine","Corrupted Small Tree","Fairy Small Tree"},
            ["Big Tree"] = {"TreeBig1", "TreeBig2", "TreeBig3","Corrupted TreeBig1","Corrupted TreeBig2","Corrupted TreeBig3","FairyTreeBig1","FairyTreeBig2","FairyTreeBig3"}
        }
    end
    
    local allTargetNames = {}
    for _, category in ipairs(State.SelectedTreeCategories) do
        local names = State.TreeCategories[category]
        if names then
            for _, treeName in ipairs(names) do allTargetNames[treeName] = true end
        else
            warn("[ChopAura] Kategori pohon Not Found:", category)
        end
    end
    
    local function scanFolder(folder)
        if not folder then return end
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("Model") and allTargetNames[obj.Name] then
                if obj:FindFirstChild("Trunk") then
                    table.insert(State.TreeCache, obj)
                end
            end
        end
    end
    
    scanFolder(Services.Workspace:FindFirstChild("Map") and Services.Workspace.Map:FindFirstChild("Foliage"))
    scanFolder(Services.Workspace:FindFirstChild("Map") and Services.Workspace.Map:FindFirstChild("Landmarks"))
    
    local categoryStr = table.concat(State.SelectedTreeCategories, ", ")
    local totalTargets = 0
    for _ in pairs(allTargetNames) do totalTargets = totalTargets + 1 end
    print(string.format("[ChopAura] Cache dibangun untuk %d kategori: %s. Total jenis pohon: %d. Pohon ditemukan: %d",
        #State.SelectedTreeCategories, categoryStr, totalTargets, #State.TreeCache))
    if #State.TreeCache > 0 and State.ChopAuraEnabled then
        notifyUI("Chop Aura Cache", string.format("Found %d trees in categories: %s", #State.TreeCache, categoryStr), 4, "trees")
    end
end

-- Connect heartbeat once
State.auraHeartbeatConnection = Services.RunService.Heartbeat:Connect(function()
    if State.scriptDisabled then return end
    if (not State.KillAuraEnabled) and (not State.ChopAuraEnabled) then return end
    local now = tick()
    if now < State.nextAuraTick then return end
    State.nextAuraTick = now + State.AuraAttackDelay
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- KILL AURA
    if State.KillAuraEnabled then
        local axe, axeId = GetBestAxe(false)
        if axe and axeId and State.ToolDamageRemote then
            EquipAxe(axe)
            local charsFolder = Services.Workspace:FindFirstChild("Characters")
            if charsFolder then
                for _, target in ipairs(charsFolder:GetChildren()) do
                    if target ~= char and target:IsA("Model") then
                        local root = target:FindFirstChildWhichIsA("BasePart")
                        if root and (root.Position - hrp.Position).Magnitude <= State.KillAuraRadius then
                            pcall(function()
                                State.ToolDamageRemote:InvokeServer(target, axe, axeId, CFrame.new(root.Position))
                            end)
                        end
                    end
                end
            end
        end
    end
    
    -- CHOP AURA
    if State.ChopAuraEnabled then
        if #State.TreeCache == 0 then buildTreeCache() end
        local axe = GetBestAxe(true)
        if axe and State.ToolDamageRemote then
            EquipAxe(axe)
            for i = #State.TreeCache, 1, -1 do
                local tree = State.TreeCache[i]
                if tree and tree.Parent and tree:FindFirstChild("Trunk") then
                    local trunk = tree.Trunk
                    if (trunk.Position - hrp.Position).Magnitude <= State.ChopAuraRadius then
                        pcall(function()
                            State.ToolDamageRemote:InvokeServer(tree, axe, "999_7367831688",
                                CFrame.new(-2.962610244751,4.5547881126404,-75.950843811035,
                                        0.89621275663376,-1.3894891459643e-8,0.44362446665764,
                                        -7.994568895775e-10,1,3.293635941759e-8,
                                        -0.44362446665764,-2.9872644802253e-8,0.89621275663376))
                        end)
                    end
                else
                    table.remove(State.TreeCache, i)
                end
            end
        end
    end
end)

-- Fungsi refreshTreeCache yang ringan
local function refreshTreeCache()
    if not State.ChopAuraEnabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local map = Services.Workspace:FindFirstChild("Map")
    if not map then return end
    
    -- Rebuild target names
    local allTargetNames = {}
    for _, category in ipairs(State.SelectedTreeCategories) do
        local names = State.TreeCategories[category]
        if names then
            for _, treeName in ipairs(names) do
                allTargetNames[treeName] = true
            end
        end
    end
    
    -- Scan folder yang umum berisi pohon
    local foldersToScan = {
        map:FindFirstChild("Foliage"),
        map:FindFirstChild("Landmarks")
    }
    
    -- Buat lookup table untuk cache yang ada (untuk cek duplikat)
    local existingTrees = {}
    for _, tree in ipairs(State.TreeCache) do
        if tree and tree.Parent then
            existingTrees[tree] = true
        end
    end
    
    -- Scan untuk pohon baru (optimized dengan batas radius)
    local newTreesFound = 0
    local maxTreesToAdd = 50 -- Batasi jumlah pohon baru per scan
    
    for _, folder in ipairs(foldersToScan) do
        if folder and newTreesFound < maxTreesToAdd then
            -- Gunakan GetChildren() daripada GetDescendants() untuk lebih cepat
            local objects = folder:GetChildren()
            for _, obj in ipairs(objects) do
                if obj:IsA("Model") and allTargetNames[obj.Name] and obj:FindFirstChild("Trunk") then
                    local trunk = obj.Trunk
                    local distance = (trunk.Position - hrp.Position).Magnitude
                    
                    -- Hanya scan pohon dalam radius dan belum ada di cache
                    if distance <= State.treeScanRadius and not existingTrees[obj] then
                        table.insert(State.TreeCache, obj)
                        existingTrees[obj] = true
                        newTreesFound = newTreesFound + 1
                        
                        if newTreesFound >= maxTreesToAdd then
                            break
                        end
                    end
                end
            end
        end
        if newTreesFound >= maxTreesToAdd then
            break
        end
    end
    
    -- Bersihkan pohon yang sudah tidak ada (lebih efisien)
    local validTrees = {}
    for _, tree in ipairs(State.TreeCache) do
        if tree and tree.Parent and tree:FindFirstChild("Trunk") then
            local trunk = tree.Trunk
            local distance = (trunk.Position - hrp.Position).Magnitude
            -- Hanya simpan pohon dalam radius yang diperbesar sedikit
            if distance <= (State.treeScanRadius * 1.5) then -- Beri buffer
                table.insert(validTrees, tree)
            end
        end
    end
    State.TreeCache = validTrees
    
    if newTreesFound > 0 then
        print(string.format("[ChopAura] %d pohon baru ditambahkan ke cache (Day: %s)", 
            newTreesFound, State.currentDayCached or "N/A"))
    end
end

-- Fungsi untuk memulai auto-refresh cache
local function startTreeCacheRefresh()
    if State.treeCacheRefreshThread then return end
    
    State.treeCacheRefreshThread = task.spawn(function()
        while State.ChopAuraEnabled and not State.scriptDisabled do
            task.wait(State.treeCacheRefreshInterval)
            if State.ChopAuraEnabled then
                refreshTreeCache()
            end
        end
        State.treeCacheRefreshThread = nil
    end)
end

-- Fungsi untuk menghentikan auto-refresh
local function stopTreeCacheRefresh()
    if State.treeCacheRefreshThread then
        task.cancel(State.treeCacheRefreshThread)
        State.treeCacheRefreshThread = nil
    end
end

-- TEMPORAL / NIGHT SKIP
local function ensureTemporal()
    if State.TemporalAccelerometer and State.TemporalAccelerometer.Parent then return State.TemporalAccelerometer end
    State.Structures = Services.Workspace:FindFirstChild("Structures") or State.Structures
    State.TemporalAccelerometer = State.Structures and State.Structures:FindFirstChild("Temporal Accelerometer") or nil
    return State.TemporalAccelerometer
end

local function activateTemporal()
    if State.scriptDisabled or not State.autoTemporalEnabled then return end
    local temporal = ensureTemporal()
    if not temporal then
        warn("[Temporal] Temporal Accelerometer Not Found.")
        notifyUI("Temporal", "Temporal Accelerometer Not Found.", 4, "alert-triangle")
        return
    end
    if not State.NightSkipRemote then
        State.NightSkipRemote = State.RemoteEvents and State.RemoteEvents:FindFirstChild("RequestActivateNightSkipMachine")
    end
    if not State.NightSkipRemote then
        warn("[Temporal] NightSkipRemote Not Found.")
        return
    end
    State.NightSkipRemote:FireServer(temporal)
    print("[Temporal] NightSkip fired.")
end

-- WEBHOOK helpers
local function namesToVerticalList(names)
    if type(names) ~= "table" or #names == 0 then return "_Tidak ada pemain aktif_" end
    local lines = {}
    for _, n in ipairs(names) do table.insert(lines, "- " .. tostring(n)) end
    return table.concat(lines, "\n")
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
        return Services.HttpService:PostAsync(url, body, Enum.HttpContentType.ApplicationJson)
    end)
    return ok, res
end

local function buildDayEmbed(currentDay, previousDay, bedCount, kidCount, itemsList, isTest)
    local players = Services.Players:GetPlayers()
    local names = {}
    for _, p in ipairs(players) do table.insert(names, p.Name) end
    local prev = tostring(previousDay or "N/A")
    local cur = tostring(currentDay or "N/A")
    local delta = "N/A"
    if tonumber(cur) and tonumber(prev) then delta = tostring(tonumber(cur) - tonumber(prev)) end
    local sampleItems = ""
    if type(itemsList) == "table" and #itemsList > 0 then
        local limit = math.min(#itemsList, 6)
        for i = 1, limit do sampleItems = sampleItems .. "• `" .. tostring(itemsList[i]) .. "`\n" end
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
        playerListValue = namesToVerticalList(sample) .. "\n- ...and more"
    end
    local embed = {
        title = title,
        description = table.concat({
            "✨ **" .. subtitle .. "**",
            "",
            string.format("📆 **Progress:** `%s → %s` • **Δ**: `%s` hari", prev, cur, delta),
            string.format("🛏️ **Beds:** `%s` 👶 **Kids:** `%s`", tostring(bedCount or 0), tostring(kidCount or 0)),
            string.format("🎮 **Players Online:** `%s`", tostring(#names)),
            "",
            "🎒 **Item Highlights:",
            sampleItems
        }, "\n"),
        color = 0xFAA61A,
        fields = {
            { name = "📈 Perubahan Hari", value = string.format("`%s` → `%s` (Δ %s)", prev, cur, tostring(delta)), inline = true },
            { name = "🎮 Jumlah Pemain", value = "`" .. tostring(#names) .. "`", inline = true },
            { name = "🧍 Pemain Aktif (list)", value = playerListValue, inline = false },
        },
        footer = { text = "🕒 Update generated at " .. os.date("%Y-%m-%d %H:%M:%S") }
    }
    local payload = { username = State.WebhookUsername or "Day Monitor", embeds = { embed } }
    return payload
end

local function sendWebhookPayload(payloadTable)
    if not State.WebhookURL or trim(State.WebhookURL) == "" then return false, "Webhook URL kosong" end
    local body = Services.HttpService:JSONEncode(payloadTable)
    local ok1, res1 = try_syn_request(State.WebhookURL, body)
    if ok1 then
        if type(res1) == "table" and res1.StatusCode then
            if res1.StatusCode >= 200 and res1.StatusCode < 300 then return true, ("syn.request: HTTP %d"):format(res1.StatusCode) end
            return false, ("syn.request: HTTP %d"):format(res1.StatusCode)
        end
        return true, "syn.request: success"
    end
    local ok2, res2 = try_request(State.WebhookURL, body)
    if ok2 then
        if type(res2) == "table" and res2.StatusCode then
            if res2.StatusCode >= 200 and res2.StatusCode < 300 then return true, ("request: HTTP %d"):format(res2.StatusCode) end
            return false, ("request: HTTP %d"):format(res2.StatusCode)
        end
        return true, "request: success"
    end
    local ok3, res3 = try_httpservice_post(State.WebhookURL, body)
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

-- DAYDISPLAY hook - FIXED VERSION
local function tryHookDayDisplay()
    if State.DayDisplayConnection then 
        State.DayDisplayConnection:Disconnect() 
        State.DayDisplayConnection = nil 
    end
    
    local function attach(remote)
        if not remote or not remote.OnClientEvent then 
            return 
        end
        
        State.DayDisplayRemote = remote
        
        State.DayDisplayConnection = State.DayDisplayRemote.OnClientEvent:Connect(function(...)
            if State.scriptDisabled then return end
            local args = { ... }

            -- CASE 1: single-arg dayNumber
            if #args == 1 then
                local dayNumber = args[1]
                if type(dayNumber) == "number" then
                    if State.autoTemporalEnabled and dayNumber ~= State.lastProcessedDay then
                        State.lastProcessedDay = dayNumber
                        print("[Temporal] Day", dayNumber, "terdeteksi (single-arg), delay 5 detik")
                        task.delay(5, function()
                            if State.scriptDisabled or not State.autoTemporalEnabled then return end
                            activateTemporal()
                        end)
                    end
                    
                    -- AUTO REFRESH TREE CACHE KETIKA DAY NAIK
                    if State.ChopAuraEnabled then
                        local previousDay = State.lastDayDetected
                        State.lastDayDetected = dayNumber
                        
                        if previousDay and dayNumber > previousDay then
                            print(string.format("[ChopAura] Day naik: %d → %d, auto refresh tree cache...", 
                                previousDay, dayNumber))
                            
                            -- Delay 2 detik untuk pastikan pohon sudah spawn
                            task.delay(2, function()
                                if State.ChopAuraEnabled and not State.scriptDisabled then
                                    refreshTreeCache()
                                end
                            end)
                        elseif not previousDay then
                            -- Day pertama kali terdeteksi saat Chop Aura aktif
                            State.lastDayDetected = dayNumber
                        end
                    end
                end
                return
            end

            -- CASE 2: multi-arg (currentDay, previousDay, items)
            local currentDay = tonumber(args[1]) or args[1]
            local previousDay = tonumber(args[2]) or args[2] or 0
            local itemsList = args[3]

            -- Auto-temporal
            if State.autoTemporalEnabled and type(currentDay) == "number" and type(previousDay) == "number" and currentDay > previousDay and currentDay ~= State.lastProcessedDay then
                State.lastProcessedDay = currentDay
                print("[Temporal] Day", currentDay, "terdeteksi (multi-arg), delay 5 detik")
                task.delay(5, function()
                    if State.scriptDisabled or not State.autoTemporalEnabled then return end
                    activateTemporal()
                end)
            end

            -- AUTO REFRESH TREE CACHE KETIKA DAY NAIK
            if State.ChopAuraEnabled and type(currentDay) == "number" and type(previousDay) == "number" then
                if currentDay > previousDay then
                    print(string.format("[ChopAura] Day naik: %d → %d, auto refresh tree cache...", 
                        previousDay, currentDay))
                    
                    -- Delay 2 detik untuk pastikan pohon sudah spawn
                    task.delay(2, function()
                        if State.ChopAuraEnabled and not State.scriptDisabled then
                            refreshTreeCache()
                        end
                    end)
                end
                -- Update lastDayDetected
                State.lastDayDetected = currentDay
            end

            -- Existing webhook / day handling (TIDAK DIUBAH)
            State.currentDayCached = currentDay
            State.previousDayCached = previousDay
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
                    if State.WebhookEnabled then
                        local ok, msg = sendWebhookPayload(payload)
                        if ok then 
                            notifyUI("Webhook Sent", "Day " .. tostring(previousDay) .. " → " .. tostring(currentDay), 6, "radio") 
                        end
                        if not ok then 
                            notifyUI("Webhook Failed", tostring(msg), 6, "alert-triangle")
                            warn("Day webhook failed:", msg) 
                        end
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
        
        print("[DayDisplay] Listener attached ke:", getInstancePath(remote))
        notifyUI("DayDisplay", "Listener attached.", 4, "radio")
    end  -- <-- INI PENUTUP FUNGSI attach()

    -- immediate attach if available
    if State.RemoteEvents and State.RemoteEvents:FindFirstChild("DayDisplay") then
        attach(State.RemoteEvents:FindFirstChild("DayDisplay"))
        return
    elseif Services.ReplicatedStorage:FindFirstChild("DayDisplay") then
        attach(Services.ReplicatedStorage:FindFirstChild("DayDisplay"))
        return
    end

    -- otherwise wait async
    task.spawn(function()
        local found = false
        local tries = 0
        while not found and tries < 120 and not State.scriptDisabled do
            tries = tries + 1
            if State.RemoteEvents and State.RemoteEvents:FindFirstChild("DayDisplay") then
                attach(State.RemoteEvents:FindFirstChild("DayDisplay"))
                found = true
                break
            end
            if Services.ReplicatedStorage:FindFirstChild("DayDisplay") then
                attach(Services.ReplicatedStorage:FindFirstChild("DayDisplay"))
                found = true
                break
            end
            task.wait(0.5)
        end
        if not found then
            warn("[DayDisplay] DayDisplay Not Found After timeout.")
            notifyUI("DayDisplay", "DayDisplay remote Not Found (timeout). Fitur DayDisplay/Webhook Waiting.", 6, "alert-triangle")
        end
    end)
end  


-- INIT Remote Events (general)
local function initRemoteEvents()
    local function safeWaitForChild(parent, name, timeout)
        timeout = timeout or 10
        local start = tick()
        while tick() - start < timeout do
            local child = parent:FindFirstChild(name)
            if child then return child end
            task.wait(0.5)
        end
        return nil
    end
    
    -- wait for RemoteEvents
    local re = safeWaitForChild(Services.ReplicatedStorage, "RemoteEvents")
    if not re then
        warn("[RemoteEvents] Not Found After timeout!")
        return false
    end
    State.RemoteEvents = re
    print("[RemoteEvents] Ditemukan:", re.Name)
    State.RequestStartDragging = re:FindFirstChild("RequestStartDraggingItem")
    State.RequestStopDragging = re:FindFirstChild("StopDraggingItem")
    State.DamagePlayerRemote = re:FindFirstChild("DamagePlayer")
    State.CollectCoinRemote = re:FindFirstChild("RequestCollectCoints")
    State.ConsumeItemRemote = re:FindFirstChild("RequestConsumeItem")
    State.NightSkipRemote = re:FindFirstChild("RequestActivateNightSkipMachine")
    State.ToolDamageRemote = re:FindFirstChild("ToolDamageObject")
    State.EquipHandleRemote = re:FindFirstChild("EquipItemHandle")
    
    print(string.format(
        "[Remotes] Bring: %s/%s | GodMode: %s | Farm: %s/%s/%s/%s/%s",
        tostring(State.RequestStartDragging ~= nil),
        tostring(State.RequestStopDragging ~= nil),
        tostring(State.DamagePlayerRemote ~= nil),
        tostring(State.CollectCoinRemote ~= nil),
        tostring(State.ConsumeItemRemote ~= nil),
        tostring(State.NightSkipRemote ~= nil),
        tostring(State.ToolDamageRemote ~= nil),
        tostring(State.EquipHandleRemote ~= nil)
    ))
    
    if State.WindUI then
        State.WindUI:Notify({ Title = "Remote Events", Content = "All remotes found!", Duration = 3, Icon = "radio" })
    end
    return true
end

-- BRING ITEM helpers
local function getTargetPosition(location)
    if not State.HumanoidRootPart then
        return Vector3.new(0, State.BringHeight + 3, 0)
    end
    if location == "Player" then
        return State.HumanoidRootPart.Position + Vector3.new(0, State.BringHeight + 3, 0)
    elseif location == "Workbench" then
        local s = getScrapperTarget_Bring()
        if s then return s.Position + Vector3.new(0, State.BringHeight, 0) end
    elseif location == "Fire" then
        local fire = Services.Workspace.Map.Campground.MainFire.OuterTouchZone
        if fire then return fire.Position + Vector3.new(0, State.BringHeight, 0) end
    end
    return State.HumanoidRootPart.Position + Vector3.new(0, State.BringHeight + 3, 0)
end

local function getDropCFrame(basePos, index)
    local angle = (index - 1) * (math.pi * 2 / 12)
    local radius = 3
    return CFrame.new(basePos + Vector3.new(
        math.cos(angle) * radius,
        0,
        math.sin(angle) * radius
    ))
end

local function bringItems(sectionItemList, selectedItems, location)
    if not State.ItemsFolder or not State.RequestStartDragging or not State.RequestStopDragging then
        notifyUI("System Not Ready", "Please wait until the game is fully loaded.", 4, "alert-triangle")
        return
    end
    if not State.HumanoidRootPart then
        notifyUI("No Character", "Character not found.", 4, "user-x")
        return
    end
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
    for _, item in ipairs(State.ItemsFolder:GetChildren()) do
        if item:IsA("Model") and item.PrimaryPart and table.find(wantedNames, item.Name) then
            table.insert(candidates, item)
        end
    end
    if #candidates == 0 then
        notifyUI("Info", "Item Not Found", 4, "search")
        return
    end
    notifyUI("Bringing", #candidates .. " item → " .. location, 5, "zap")
    for i, item in ipairs(candidates) do
        State.RequestStartDragging:FireServer(item)
        task.wait(0.03)
        item:PivotTo(getDropCFrame(targetPos, i))
        task.wait(0.03)
        State.RequestStopDragging:FireServer(item)
        task.wait(0.02)
    end
end

local function teleportToCFrame(cf)
    if not cf then
        notifyUI("Error", "Lokasi Not Found!", 4, "alert-triangle")
        return
    end
    if State.HumanoidRootPart then
        State.HumanoidRootPart.CFrame = cf + Vector3.new(0,4,0)
        notifyUI("Teleport!", "Successfully teleported!", 4, "navigation")
    end
end

-- LOCAL PLAYER helpers
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function zeroVelocities(part)
    if part and part:IsA("BasePart") then
        part.AssemblyLinearVelocity = Vector3.new(0,0,0)
        part.AssemblyAngularVelocity = Vector3.new(0,0,0)
    end
end

-- Apply settings
local function applyFOV()
    Camera.FieldOfView = State.fovEnabled and State.fovValue or State.defaultFOV
end

local function applyWalkspeed()
    if State.walkspeedConn then return end

    State.walkspeedConn = Services.RunService.Heartbeat:Connect(function()
        if State.scriptDisabled then return end
        if not State.walkspeedEnabled then return end

        local hum = State.humanoid
        if not hum or not hum.Parent then return end

        if hum.WalkSpeed ~= State.walkspeedValue then
            hum.WalkSpeed = State.walkspeedValue
        end
    end)
end

local function applyHipHeight()
    if State.humanoid then
        State.humanoid.HipHeight = State.hipEnabled and State.hipValue or State.defaultHipHeight
    end
end

-- TP Walk
local function startTPWalk()
    if State.tpWalkEnabled or State.scriptDisabled then return end
    State.tpWalkEnabled = true
    State.tpWalkConn = Services.RunService.RenderStepped:Connect(function(dt)
        if not State.tpWalkEnabled then return end
        local h = getHumanoid()
        local r = getRoot()
        if h and r and h.MoveDirection.Magnitude > 0 then
            local dist = State.tpWalkSpeedValue * dt * 10
            r.CFrame += h.MoveDirection.Unit * dist
        end
    end)
end

local function stopTPWalk()
    State.tpWalkEnabled = false
    if State.tpWalkConn then State.tpWalkConn:Disconnect(); State.tpWalkConn = nil end
end

-- Infinite jump
local function startInfiniteJump()
    if State.infiniteJumpEnabled or State.scriptDisabled then return end
    State.infiniteJumpEnabled = true
    State.infiniteJumpConn = Services.UserInputService.JumpRequest:Connect(function()
        if State.infiniteJumpEnabled then getHumanoid():ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function stopInfiniteJump()
    State.infiniteJumpEnabled = false
    if State.infiniteJumpConn then State.infiniteJumpConn:Disconnect(); State.infiniteJumpConn = nil end
end

-- Fullbright
local function enableFullBright()
    State.fullBrightEnabled = true
    for k, v in pairs(State.oldLightingProps) do State.oldLightingProps[k] = Services.Lighting[k] end
    local function apply()
        if not State.fullBrightEnabled then return end
        Services.Lighting.Brightness = 2
        Services.Lighting.ClockTime = 14
        Services.Lighting.FogEnd = 1e4
        Services.Lighting.GlobalShadows = false
        Services.Lighting.Ambient = Color3.new(1,1,1)
        Services.Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
    apply()
    State.fullBrightConn = Services.RunService.RenderStepped:Connect(apply)
end

local function disableFullBright()
    State.fullBrightEnabled = false
    if State.fullBrightConn then State.fullBrightConn:Disconnect(); State.fullBrightConn = nil end
    for k, v in pairs(State.oldLightingProps) do Services.Lighting[k] = v end
end

-- Instant open handling
local function applyInstantOpenToPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        if State.promptOriginalHold[prompt] == nil then State.promptOriginalHold[prompt] = prompt.HoldDuration end
        prompt.HoldDuration = 0
    end
end

local function enableInstantOpen()
    State.instantOpenEnabled = true
    for _, v in ipairs(Services.Workspace:GetDescendants()) do if v:IsA("ProximityPrompt") then applyInstantOpenToPrompt(v) end end
    if State.promptConn then State.promptConn:Disconnect() end
    State.promptConn = Services.Workspace.DescendantAdded:Connect(function(inst)
        if State.instantOpenEnabled and inst:IsA("ProximityPrompt") then applyInstantOpenToPrompt(inst) end
    end)
    notifyUI("Instant Open", "Semua ProximityPrompt jadi instant.", 3, "bolt")
end

local function disableInstantOpen()
    State.instantOpenEnabled = false
    if State.promptConn then State.promptConn:Disconnect(); State.promptConn = nil end
    for prompt, orig in pairs(State.promptOriginalHold) do
        if prompt and prompt.Parent then pcall(function() prompt.HoldDuration = orig end) end
    end
    State.promptOriginalHold = {}
    notifyUI("Instant Open", "Durasi dikembalikan.", 3, "refresh-ccw")
end

-- Visibility helpers
local function setVisibility(on)
    local char = getCharacter()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or (part:IsA("MeshPart") and part.Name == "Handle") then
            if on then
                part.Transparency = 1
                part.LocalTransparencyModifier = 0
            else
                part.Transparency = State.originalTransparency[part] or 0
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

-- Idle animation
local function playIdleAnimation()
    if State.idleTrack then State.idleTrack:Stop() end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://180435571"
    State.idleTrack = State.humanoid:LoadAnimation(anim)
    State.idleTrack.Priority = Enum.AnimationPriority.Core
    State.idleTrack.Looped = true
    State.idleTrack:Play()
end

-- NOCLIP update
local function updateNoclipConnection()
    if State.flyEnabled and not State.noclipConn then
        State.noclipConn = Services.RunService.Stepped:Connect(function()
            local char = getCharacter()
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    elseif not State.flyEnabled and State.noclipConn then
        State.noclipConn:Disconnect()
        State.noclipConn = nil
    end
end

-- FLY start/stop
local function startFly()
    if State.flyEnabled or State.scriptDisabled then return end
    local char = getCharacter()
    State.humanoid = getHumanoid()
    State.rootPart = getRoot()
    if not char or not State.humanoid or not State.rootPart then return end
    State.flyEnabled = true
    if next(State.originalTransparency) == nil then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or (part:IsA("MeshPart") and part.Name == "Handle") then
                State.originalTransparency[part] = part.Transparency
            end
        end
    end
    setVisibility(false)
    State.rootPart.Anchored = true
    State.humanoid.PlatformStand = true
    for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    playIdleAnimation()
    updateNoclipConnection()
    State.flyConn = Services.RunService.RenderStepped:Connect(function(dt)
        if not State.flyEnabled or not State.rootPart then return end
        local move = Vector3.new(0,0,0)
        local UIS = Services.UserInputService
        if UIS:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
        if move.Magnitude > 0 then
            move = move.Unit * math.clamp(State.flySpeedValue, 16, 200) * dt
            State.rootPart.CFrame += move
        end
        -- FOLLOW CAMERA X & Y
        State.rootPart.CFrame = CFrame.new(State.rootPart.Position) * Camera.CFrame.Rotation
        zeroVelocities(State.rootPart)
    end)
end

local function stopFly()
    if not State.flyEnabled then return end
    State.flyEnabled = false
    if State.flyConn then State.flyConn:Disconnect(); State.flyConn = nil end
    local char = getCharacter()
    State.humanoid = getHumanoid()
    State.rootPart = getRoot()
    if State.idleTrack then State.idleTrack:Stop(); State.idleTrack = nil end
    if State.humanoid then State.humanoid.PlatformStand = false end
    setVisibility(false)
    local targetCFrame = State.rootPart and State.rootPart.CFrame
    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = 30000
    bp.Position = targetCFrame.Position
    bp.Parent = State.rootPart
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 30000
    bg.CFrame = targetCFrame
    bg.Parent = State.rootPart
    State.rootPart.Anchored = false
    for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
    task.delay(0.1, function()
        if bp then bp:Destroy() end
        if bg then bg:Destroy() end
    end)
    updateNoclipConnection()
end

-- ANTI AFK
LocalPlayer.Idled:Connect(function()
    if State.AntiAFKEnabled then
        Services.VirtualUser:CaptureController()
        Services.VirtualUser:ClickButton2(Vector2.zero)
    end
end)

-- INPUT LISTENERS for fishing position set
Services.UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not State.waitingForPosition or State.scriptDisabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local loc = Services.UserInputService:GetMouseLocation()
        local vp = Camera.ViewportSize
        local px = math.clamp(math.floor(loc.X), 0, vp.X)
        local py = math.clamp(math.floor(loc.Y), 0, vp.Y)
        State.fishingSavedPosition = {x = px, y = py}
        State.waitingForPosition = false
        notifyUI("Position Set", ("X=%d Y=%d"):format(px, py), 3)
        if State.fishingOverlayVisible then fishingShowOverlay(px, py) end
    end
end)

-- Fishing auto click loop
State.fishingLoopThread = task.spawn(function()
    while true do
        if State.fishingAutoClickEnabled and State.fishingSavedPosition and not State.scriptDisabled then
            fishingDoClick()
        end
        task.wait(State.fishingClickDelay)
    end
end)

---------------------------------------------------------
-- LOAD WINDUI
---------------------------------------------------------
do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if ok and res then
        State.WindUI = res
        pcall(function()
            State.WindUI:SetTheme("Dark")
            State.WindUI.TransparencyValue = 0.2
        end)
    else
        warn("[UI] Gagal load WindUI. Menggunakan fallback minimal.")
        State.WindUI = nil
    end
end

---------------------------------------------------------
-- CREATE UI WINDOW DENGAN SEMUA TAB
---------------------------------------------------------
local function createUI()
    if not State.WindUI then
        warn("[FRENESIS] WindUI tidak tersedia, UI tidak dibuat")
        --return
    end

    if State.WindowCreated then return end
    State.WindowCreated = true

    local Window = State.WindUI:CreateWindow({
        Title = "HexaCore |HUB",
        Icon = "gamepad-2",
        Author = "HexaCore by Dimz",
        Folder = "PapiDimz_HUB_Config",
        Size = UDim2.fromOffset(600, 520),
        Theme = "Dark",
        Transparent = true,
        Acrylic = true,
        SideBarWidth = 180,
        HasOutline = true,
    })
    State.WindUIWindow = Window

    State.WindUIWindow:EditOpenButton({
        Title = "HexaCore Hub",
        Icon = "monitor",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 2,
        Color = ColorSequence.new(
            Color3.fromHex("FF0F7B"),
            Color3.fromHex("F89B29")
        ),
        OnlyMobile = true,
        Enabled = true,
        Draggable = true,
    })
    ---------------------------------------------------------
    --// TAB 1 : INFORMATION
    ---------------------------------------------------------
    local infoTab = Window:Tab({
        Title = "Information",
        Icon = "info"
    })

    infoTab:Paragraph({
        Title = "Welcome To HexaCore Hub Official",
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
            if setclipboard then
                setclipboard("https://discord.gg/c247yzPpEm")
            end
            State.WindUI:Notify({
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
        Title = "HexaCore Keybind",
        Desc  = "Keybind to open/close UI",
        Value = "p", -- bisa diganti
        Callback = function(v)
            -- otomatis bikin UI show/hide pakai key yang dipilih
            Window:SetToggleKey(Enum.KeyCode[v])
        end
    })

    local FunTab      = Window:Tab({ Title = "Fun", Icon = "gamepad-2" })
    local MainTab     = Window:Tab({ Title = "Main", Icon = "settings-2" })
    local LocalTab    = Window:Tab({ Title = "Local Player", Icon = "user" })
    local FishingTab  = Window:Tab({ Title = "Fishing", Icon = "fish" })
    local BringTab    = Window:Tab({ Title = "Bring Item", Icon = "hand" })
    local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "navigation" })
    local UpdateTab   = Window:Tab({ Title = "Update Focused", Icon = "snowflake" })
    local FarmTab     = Window:Tab({ Title = "Farm", Icon = "chef-hat" })
    local NightTab    = Window:Tab({ Title = "Night", Icon = "moon" })
    local WebhookTab  = Window:Tab({ Title = "Webhook", Icon = "radio" })

    
    ---------------------------------------------------------
    -- TAB 1: FUN
    ---------------------------------------------------------
    do
        -------------------------------------------------
        -- SECTION UI
        -------------------------------------------------
        local autoStrongholdSec = FunTab:Section({
            Title = "Auto Stronghold",
            Icon = "castle",
            DefaultOpen = true
        })

        local strongholdRow = autoStrongholdSec:Paragraph({
            Title = "Stronghold Time",
            Desc = "Time : --:--\nStatus : ON"
        })

        -------------------------------------------------
        -- TIMER STATE
        -------------------------------------------------
        local strongholdSeconds = nil
        local lastSync = 0
        local SYNC_INTERVAL = 300 -- 5 menit

        -------------------------------------------------
        -- TIME PARSER
        -------------------------------------------------
        local function parseStrongholdSeconds(text)
            if type(text) ~= "string" then return nil end
            local h = tonumber(text:match("(%d+)%s*[hH]")) or 0
            local m = tonumber(text:match("(%d+)%s*[mM]")) or 0
            local s = tonumber(text:match("(%d+)%s*[sS]")) or 0
            local total = h * 3600 + m * 60 + s
            return total > 0 and total or nil
        end

        local function formatTime(sec)
            if not sec or sec < 0 then return "--:--" end
            local m = math.floor(sec / 60)
            local s = sec % 60
            return string.format("%02dm %02ds", m, s)
        end

        -------------------------------------------------
        -- STRONGHOLD TIMER LOOP
        -------------------------------------------------
        task.spawn(function()
            local finalSyncDone = false

            while not State.scriptDisabled do
                local now = os.clock()
                local syncInterval = SYNC_INTERVAL

                if strongholdSeconds then
                    if strongholdSeconds <= 10 and not finalSyncDone then
                        syncInterval = 0
                    elseif strongholdSeconds <= 30 then
                        syncInterval = 5
                    else
                        finalSyncDone = false
                    end
                end

                if (not strongholdSeconds) or (now - lastSync >= syncInterval) then
                    local ok, rawText = pcall(function()
                        return game.Workspace
                            .Map.Landmarks.Stronghold
                            .Functional.Sign.SurfaceGui
                            .Frame.Body.Text
                    end)

                    if ok and rawText then
                        local sec = parseStrongholdSeconds(rawText)
                        if sec then
                            strongholdSeconds = sec
                            lastSync = now
                            if sec <= 10 then finalSyncDone = true end
                        end
                    end
                end

                if strongholdSeconds and strongholdSeconds > 0 then
                    strongholdSeconds -= 1
                end

                strongholdRow:SetDesc(
                    "Time : " .. formatTime(strongholdSeconds) .. "\nStatus : ON"
                )

                task.wait(1)
            end
        end)

        -------------------------------------------------
        -- AUTO STRONGHOLD MAIN LOOP
        -------------------------------------------------
        task.spawn(function()
            while not State.scriptDisabled do
                task.wait(1)

                -- GLOBAL GUARD
                if not State.autoStrongholdEnabled then
                    State.autoStrongholdRunning = false
                    continue
                end

                if State.autoStrongholdRunning then
                    continue
                end

                if not (strongholdSeconds and strongholdSeconds <= 0) then
                    continue
                end

                -- LOCK CYCLE
                State.autoStrongholdRunning = true

                local function finish()
                    disableNoClip()

                    local hrp = getRoot()
                    if hrp then
                        hrp.Anchored = false
                    end

                    State.autoStrongholdRunning = false
                end

                -- DELAY AFTER TIMER 0
                task.wait(10)
                if not State.autoStrongholdEnabled then
                    finish()
                    continue
                end

                local hrp = getRoot()
                if not hrp or not State.cachedTriggerZoneCFrame then
                    finish()
                    continue
                end

                -------------------------------------------------
                -- FLOOR 1 : TRIGGERZONE
                -------------------------------------------------
                sendStrongholdChat()
                pingStronghold()
                task.wait(0.5)
                hrp.Anchored = false
                hrp.CFrame = State.cachedTriggerZoneCFrame * CFrame.new(0, 5, 0)
                task.wait(0.6)

                jumpOnce()
                task.wait(2)

                if not State.autoStrongholdEnabled then
                    finish()
                    continue
                end

                -------------------------------------------------
                -- CULTIST WATCH MODE (FIXED)
                -------------------------------------------------
                local cleanTimer = 0
                local MAX_CLEAN = 10
                local lastTween = 0

                disableNoClip()

                while State.autoStrongholdEnabled do
                    local cultist = findNearestCultist(200)

                    if cultist then
                        cleanTimer = 0

                        if os.clock() - lastTween >= 1.2 then
                            enableNoClip()
                            tweenAroundCultist(cultist)
                            lastTween = os.clock()
                        end

                        task.wait(0.1)
                    else
                        disableNoClip()
                        cleanTimer += 1

                        if cleanTimer >= MAX_CLEAN then
                            break
                        end

                        task.wait(1)
                    end
                end

                disableNoClip()

                if not State.autoStrongholdEnabled then
                    finish()
                    continue
                end

                -------------------------------------------------
                -- FLOOR 3 : STRONGHOLD DIAMOND CHEST
                -------------------------------------------------
                do
                    local items = Services.Workspace:FindFirstChild("Items")
                    local chest = items and items:FindFirstChild("Stronghold Diamond Chest")
                    if chest then
                        local part = chest.PrimaryPart
                            or chest:FindFirstChildWhichIsA("BasePart", true)
                        if part then
                            hrp.CFrame = part.CFrame * CFrame.new(0, 2, 0)
                        end
                    end
                end

                task.wait(1)

                -------------------------------------------------
                -- LOOTING
                -------------------------------------------------
                local chests = scanStrongholdChests()
                task.wait(1)
                openScannedStrongholdChests(chests)
                task.wait(1)

                collectAllDiamonds()
                task.wait(1)

                -- END CYCLE
                finish()

                repeat task.wait(2)
                until not strongholdSeconds or strongholdSeconds > 0
            end
        end)

        -------------------------------------------------
        -- TOGGLE
        -------------------------------------------------
        autoStrongholdSec:Toggle({
        Title = "Auto Stronghold",
        Callback = function(v)
            State.autoStrongholdEnabled = v

            if v then
                task.spawn(function()
                    if ensureStrongholdTriggerZone() then
                        notifyUI(
                            "Auto Stronghold",
                            "✅ TriggerZone Stronghold ditemukan",
                            3,
                            "check"
                        )
                    else
                        notifyUI(
                            "Auto Stronghold",
                            "❌ Gagal menemukan TriggerZone Stronghold",
                            4,
                            "alert-triangle"
                        )
                    end
                end)
            end
        end})

        -- =========================================
        -- 🔍 REVEAL MAP (RAPIH & COLLAPSIBLE)
        -- =========================================

        local RevealMapSection = FunTab:Section({
            Title = "Reveal Map",
            Icon = "map-pin",
            Description = "Terbang spiral untuk membuka seluruh map"
        })

        RevealMapSection:Button({
            Title = "Start / Stop Reveal Map",
            Description = "Reveal Map",
            Callback = function()
                if State.spiralActive then
                    stopSpiralFlight()
                else
                    startSpiralFlight()
                end
            end
        })

        RevealMapSection:Button({
            Title = "📍 Teleport to Ground",
            Description = "Teleport ke posisi ground",
            Callback = function()
                local r = getRoot()
                if r then
                    r.CFrame = CFrame.new(State.groundPosition)
                end
            end
        })


        -- =========================================
        -- 🌱 SAPLING SYSTEM (COLLAPSIBLE & CLEAN)
        -- =========================================

        local SaplingSection = FunTab:Section({
            Title = "Sapling System",
            Icon = "leaf",
            Description = "Sistem penanaman pohon otomatis"
        })

        SaplingSection:Dropdown({
            Title = "Plant Mode",
            Values = { "character", "overlay" },
            Default = 2, -- overlay
            Callback = function(v)
                State.plantingMode = v
                State.plantSequenceIndex = 1
            end
        })

        SaplingSection:Dropdown({
            Title = "Select Shape",
            Values = State.overlayShapes,
            Default = 1, -- circle
            Callback = function(v)
                State.overlayShape = v
                if State.overlayVisible then updateOverlay() end
            end
        })

        SaplingSection:Toggle({
            Title = "Show Overlay",
            Description = "Tampilkan overlay di workspace",
            Default = true,
            Callback = function(v)
                State.overlayVisible = v
                updateOverlay()
            end
        })

        SaplingSection:Toggle({
            Title = "Infinite Sapling Mode",
            Description = "ON: Tanam banyak pohon sekaligus | OFF: Tanam satu per satu",
            Default = false,
            Callback = function(v)
                State.infiniteSaplingEnabled = v
            end
        })

        SaplingSection:Slider({
            Title = "Plant Count",
            Description = "Total titik tanam untuk semua layer",
            Step = 1,
            Value = { Min = 50, Max = 1000, Default = 250 },
            Callback = function(v)
                State.overlayPoints = math.floor(v)
                if State.overlayVisible then updateOverlay() end
            end
        })

        SaplingSection:Slider({
            Title = "Angle Increment",
            Description = "Jumlah layer konsentris",
            Step = 1,
            Value = { Min = 1, Max = 10, Default = 2 },
            Callback = function(v)
                State.angleIncrement = math.floor(v)
                if State.overlayVisible then updateOverlay() end
            end
        })

        SaplingSection:Slider({
            Title = "Overlay Radius",
            Description = "Radius layer pertama",
            Step = 1,
            Value = { Min = 10, Max = 200, Default = 40 },
            Callback = function(v)
                State.overlayRadius = math.floor(v)
                if State.overlayVisible then updateOverlay() end
            end
        })

        SaplingSection:Slider({
            Title = "Overlay Height",
            Description = "Ketinggian overlay dari ground",
            Step = 0.5,
            Value = { Min = 0, Max = 50, Default = 3 },
            Callback = function(v)
                State.overlayHeight = v
                State.overlayCenter = Vector3.new(1, v, 1)
                if State.overlayVisible then updateOverlay() end
            end
        })

        SaplingSection:Slider({
            Title = "Plant Interval",
            Description = "Detik antar tanam",
            Step = 0.05,
            Value = { Min = 0.05, Max = 2, Default = 0.1 },
            Callback = function(v)
                State.plantInterval = math.floor(v * 100) / 100
            end
        })

        SaplingSection:Button({
            Title = "▶ Start Planting",
            Description = "Mulai penanaman otomatis",
            Callback = function()
                if State.plantingActive then
                    stopPlanting()
                else
                    startPlanting()
                end
            end
        })

        SaplingSection:Button({
            Title = "⏹ Stop Planting",
            Description = "Hentikan penanaman",
            Callback = function()
                stopPlanting()
            end
        })

        SaplingSection:Button({
            Title = "🔄 Reset Progress",
            Description = "Reset urutan penanaman ke titik awal",
            Callback = function()
                resetPlantingProgress()
            end
        })


        local LogwallSection = FunTab:Section({ 
            Title = "Log Wall System",
            Icon = "brick-wall",
            Description = "Sistem penempatan Log Wall otomatis"
        })

        LogwallSection:Toggle({
            Title = "Auto Rotate Log Wall",
            Description = "Rotasi otomatis mengikuti bentuk overlay",
            Default = true,
            Callback = function(v)
                State.autoRotateLogWall = v
            end
        })

        LogwallSection:Button({
            Title = "🔍 Scan Log Wall Blueprint",
            Description = "Cari Log Wall Blueprint di inventory",
            Callback = function()
                local count = countLogWallBlueprints()
                if count > 0 then
                    showWindUINotification(
                        "Log Wall System",
                        "✅ Ditemukan " .. count .. " Log Wall Blueprint!",
                        "Success",
                        4
                    )
                else
                    showWindUINotification(
                        "Log Wall System",
                        "✗ Tidak ada Log Wall Blueprint di inventory!",
                        "Error",
                        4
                    )
                end
            end
        })

        LogwallSection:Button({
            Title = "▶ Start Auto Place Log Wall",
            Description = "Mulai menempatkan Log Wall di semua titik overlay",
            Callback = function()
                if State.logWallActive then
                    stopAutoLogWall()
                else
                    startAutoLogWall()
                end
            end
        })

        LogwallSection:Button({
            Title = "⏹ Stop Auto Place Log Wall",
            Description = "Hentikan penempatan Log Wall",
            Callback = function()
                stopAutoLogWall()
            end
        })

        local OpenChest = FunTab:Section({ 
            Title = "Open Chest System",
            Icon = "treasure-chest",
            Description = "Sistem pembukaan chest otomatis"
        })

        OpenChest:Toggle({
            Title = "Auto Open All Chest",
            Description = "ON: Scan dan buka semua chest otomatis",
            Default = false,
            Callback = function(v)
                if v then
                    startAutoOpenChests()
                else
                    stopAutoOpenChests()
                end
            end
        })

        OpenChest:Slider({
            Title = "Delay Chest",
            Description = "Delay antara membuka chest (detik)",
            Step = 0.1,
            Value = { Min = 0.3, Max = 1, Default = State.chestOpeningSpeed },
            Callback = function(v)
                State.chestOpeningSpeed = math.floor(v * 10) / 10
            end
        })

        OpenChest:Button({
            Title = "🔍 Scan Chest Sekarang",
            Description = "Scan semua chest di map",
            Callback = function()
                local count = rescanChests()
                if count > 0 then
                    showWindUINotification(
                        "Chest Scanner",
                        "Ditemukan " .. count .. " chest!",
                        "Success",
                        3
                    )
                else
                    showWindUINotification(
                        "Chest Scanner",
                        "Tidak ada chest ditemukan",
                        "Warning",
                        3
                    )
                end
            end
        })

        OpenChest:Button({
            Title = "▶ Mulai Buka Chest",
            Description = "Mulai membuka semua chest yang ditemukan",
            Callback = function()
                if not State.isOpeningChests then
                    startAutoOpenChests()
                else
                    showWindUINotification(
                        "Chest Opener",
                        "Sedang membuka chest...",
                        "Info",
                        2
                    )
                end
            end
        })

        OpenChest:Button({
            Title = "⏹ Berhenti",
            Description = "Hentikan proses membuka chest",
            Callback = function()
                stopAutoOpenChests()
            end
        })
    end
    ---------------------------------------------------------
    -- TAB 2: MAIN
    ---------------------------------------------------------
    do
        MainTab:Paragraph({
            Title = "HexaCore HUB",
            Desc = "Godmode, AntiAFK, Auto Sacrifice Lava, Auto Farm, Aura, Webhook DayDisplay.\nHotkey PC: P untuk toggle UI.",
            Color = "Grey"
        })

        MainTab:Toggle({
            Title = "GodMode",
            Default = false,
            Callback = function(v)
                State.GodmodeEnabled = v
                if v then
                    if not State.DamagePlayerRemote then
                        State.DamagePlayerRemote = State.RemoteEvents and State.RemoteEvents:FindFirstChild("DamagePlayer")
                        if not State.DamagePlayerRemote then
                            State.DamagePlayerRemote = Services.ReplicatedStorage:FindFirstChild("RemoteEvents") and Services.ReplicatedStorage.RemoteEvents:FindFirstChild("DamagePlayer")
                        end
                    end
                    if State.DamagePlayerRemote then
                        startGodmodeLoop()
                        notifyUI("GodMode", "ACTIVE - Refresh Damage Every 8 Seconds", 5, "shield")
                        print("[GodMode] GodMode activated, remote ditemukan:", State.DamagePlayerRemote.Name)
                    else
                        State.GodmodeEnabled = false
                        notifyUI("GodMode FAILED", "'DamagePlayer' not found!", 6, "alert-triangle")
                        warn("[GodMode] Remote 'DamagePlayer' not found!")
                    end
                else
                    notifyUI("GodMode", "DISABLED", 3, "shield-off")
                    print("[GodMode] GodMode disabled")
                end
            end
        })

        MainTab:Toggle({
            Title = "Anti AFK",
            Default = true,
            Callback = function(v)
                State.AntiAFKEnabled = v
            end
        })

        MainTab:Button({
            Title = "Shutdown Script",
            Variant = "Destructive",
            Callback = function()
                State.scriptDisabled = true
                State.scriptActive = false
                stopFly()
                stopZone()
                State.fishingAutoClickEnabled = false
                State.AutoCookEnabled = false
                State.ScrapEnabled = false
                State.AutoSacEnabled = false
                State.KillAuraEnabled = false
                State.ChopAuraEnabled = false
                stopCoinAmmo()
                State.autoTemporalEnabled = false
                State.CookLoopId = State.CookLoopId + 1
                State.ScrapLoopId = State.ScrapLoopId + 1
                stopAutoOpenChests()
                stopAutoLogWall()
                stopPlanting()
                stopSpiralFlight()
                if State.DayDisplayConnection then State.DayDisplayConnection:Disconnect(); State.DayDisplayConnection = nil end
                State.WebhookEnabled = false
                fishingHideOverlay()
                clearOverlay()
                pcall(function() if LocalPlayer.PlayerGui:FindFirstChild("XenoPositionOverlay") then LocalPlayer.PlayerGui.XenoPositionOverlay:Destroy() end end)
                if Window then
                    pcall(function() Window:Destroy() end)
                end
                warn("[PapiDimz x FRENESIS] Script deactivated")
            end
        })
    end
    ---------------------------------------------------------
    -- TAB 3: LOCAL PLAYER
    ---------------------------------------------------------
    do
        LocalTab:Paragraph({ Title = "Self", Desc = "Atur FOV kamera.", Color = "Grey" })
        LocalTab:Toggle({ Title = "FOV", Icon = "zoom-in", Default = false, Callback = function(state) State.fovEnabled = state; applyFOV() end })
        LocalTab:Slider({ Title = "FOV", Description = "40 - 120", Step = 1, Value = { Min = 40, Max = 120, Default = 60 }, Callback = function(v) State.fovValue = v; applyFOV() end })
        LocalTab:Paragraph({ Title = "Movement", Desc = "WalkSpeed, Fly, TP Walk, Noclip, Infinite Jump, Hip Height.", Color = "Grey" })
        LocalTab:Toggle({
            Title = "Speed",
            Icon = "rabbit",
            Default = false,
            Callback = function(state)
                State.walkspeedEnabled = state
                if state then applyWalkspeed() end
            end
        })
        LocalTab:Slider({
            Title = "Walk Speed",
            Description = "16 - 200",
            Step = 1,
            Value = { Min = 16, Max = 200, Default = 30 },
            Callback = function(v)
                State.walkspeedValue = v
                if v > 16 then
                    State.walkspeedEnabled = true
                    applyWalkspeed()
                end
            end
        })
        LocalTab:Toggle({ Title = "Fly", Icon = "plane", Default = false, Callback = function(state) if state then startFly() else stopFly() end end })
        LocalTab:Slider({ Title = "Fly Speed", Description = "16 - 200", Step = 1, Value = { Min = 16, Max = 200, Default = 50 }, Callback = function(v) State.flySpeedValue = v end })
        LocalTab:Toggle({ Title = "TP Walk", Icon = "mouse-pointer-2", Default = false, Callback = function(state) if state then startTPWalk() else stopTPWalk() end end })
        LocalTab:Slider({ Title = "TP Walk Speed", Description = "1 - 30", Step = 1, Value = { Min = 1, Max = 30, Default = 5 }, Callback = function(v) State.tpWalkSpeedValue = v end })
        LocalTab:Toggle({ Title = "Noclip", Icon = "ghost", Default = false, Callback = function(state) State.noclipManualEnabled = state; updateNoclipConnection() end })
        LocalTab:Toggle({ Title = "Infinite Jump", Icon = "chevron-up", Default = false, Callback = function(state) if state then startInfiniteJump() else stopInfiniteJump() end end })
        LocalTab:Toggle({ Title = "Hip Height", Icon = "align-vertical-justify-center", Default = false, Callback = function(state) State.hipEnabled = state; applyHipHeight() end })
        LocalTab:Slider({ Title = "Hip Height Value", Description = "0 - 60", Step = 1, Value = { Min = 0, Max = 60, Default = 35 }, Callback = function(v) State.hipValue = v; applyHipHeight() end })
        LocalTab:Paragraph({ Title = "Visual", Desc = "Fullbright, Remove Fog/Sky.", Color = "Grey" })
        LocalTab:Toggle({ Title = "Fullbright", Icon = "sun", Default = false, Callback = function(state) if state then enableFullBright() else disableFullBright() end end })
        LocalTab:Button({ Title = "Remove Fog", Icon = "wind", Callback = function() Services.Lighting.FogEnd = 1e9; local atmo = Services.Lighting:FindFirstChildOfClass("Atmosphere"); if atmo then atmo.Density = 0; atmo.Haze = 0 end; notifyUI("Remove Fog", "Fog deleted.", 3, "wind") end })
        LocalTab:Button({ Title = "Remove Sky", Icon = "cloud-off", Callback = function() for _, obj in ipairs(Services.Lighting:GetChildren()) do if obj:IsA("Sky") then obj:Destroy() end end; notifyUI("Remove Sky", "Skybox deleted.", 3, "cloud-off") end })
        LocalTab:Paragraph({ Title = "Misc", Desc = "Instant Open, Reset.", Color = "Grey" })
        LocalTab:Toggle({ Title = "Instant Open", Icon = "bolt", Default = false, Callback = function(state) if state then enableInstantOpen() else disableInstantOpen() end end })
    end
    ---------------------------------------------------------
    -- TAB 4: FISHING
    ---------------------------------------------------------
    do
        FishingTab:Paragraph({
            Title = "Fishing & Macro",
            Desc = "Automated Fishing. Just Watch video if u dont know how to use it.",
            Color = "Grey"
        })
        FishingTab:Toggle({ Title = "100% Success Rate", Default = false, Callback = function(state) if state then startZone() else stopZone() end end })
        FishingTab:Toggle({ Title = "Auto Recast", Default = false, Callback = function(state) State.autoRecastEnabled = state end })
        FishingTab:Input({ Title = "Recast Delay (s)", Placeholder = "2", Default = "2", Callback = function(text) local n = tonumber(text) if n and n >= 0.01 and n <= 60 then State.RECAST_DELAY = n end end })
        FishingTab:Toggle({ Title = "View Position Overlay", Default = false, Callback = function(state) State.fishingOverlayVisible = state if state and State.fishingSavedPosition then fishingShowOverlay(State.fishingSavedPosition.x, State.fishingSavedPosition.y) else fishingHideOverlay() end end })
        FishingTab:Button({ Title = "Set Position", Callback = function() State.waitingForPosition = not State.waitingForPosition; notifyUI("Set Position", State.waitingForPosition and "Click on screen to set position." or "Cancelled.", 3) end })
        FishingTab:Toggle({ Title = "Auto Clicker", Default = false, Callback = function(state) State.fishingAutoClickEnabled = state end })
        FishingTab:Input({ Title = "Delay (s)", Placeholder = "5", Default = "5", Callback = function(text) local n = tonumber(text) if n and n >= 0.01 and n <= 600 then State.fishingClickDelay = n end end })
        FishingTab:Button({ Title = "Calibrate", Callback = function()
            local cam = Services.Workspace.CurrentCamera
            local cx = cam.ViewportSize.X / 2
            local cy = cam.ViewportSize.Y / 2
            notifyUI("Calibrate", "Click the red dot in the center of the screen.", 4)
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
            conn = Services.UserInputService.InputBegan:Connect(function(inp,gp)
                if gp then return end
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local loc = Services.UserInputService:GetMouseLocation()
                    State.fishingOffsetX = cx - loc.X
                    State.fishingOffsetY = cy - loc.Y
                    notifyUI("Calibrate Done", ("Offset X=%.1f Y=%.1f"):format(State.fishingOffsetX, State.fishingOffsetY), 4)
                    conn:Disconnect()
                    gui:Destroy()
                    if State.fishingOverlayVisible and State.fishingSavedPosition then
                        fishingShowOverlay(State.fishingSavedPosition.x, State.fishingSavedPosition.y)
                    end
                end
            end)
        end })
        FishingTab:Button({ Title = "Clean Fishing", Variant = "Destructive", Callback = function()
            State.fishingAutoClickEnabled = false
            State.waitingForPosition = false
            State.fishingSavedPosition = nil
            stopZone()
            fishingHideOverlay()
            pcall(function() LocalPlayer.PlayerGui.XenoPositionOverlay:Destroy() end)
            notifyUI("Fishing Clean", "Fishing features cleaned up.", 3)
        end })
    end
    ---------------------------------------------------------
    -- TAB 5: BRING ITEM
    ---------------------------------------------------------
    do
        local setSec = BringTab:Section({Title="Bring Setting", Icon="settings", DefaultOpen=true})
        setSec:Dropdown({ Title="Location", Values={"Player","Workbench","Fire"}, Value="Player", Callback=function(v) State.selectedLocation=v end })
        setSec:Input({ Title="Bring Height", Default="20", Numeric=true, Callback=function(v) State.BringHeight=tonumber(v) or 20 end })

        -- Helper function untuk membuat section bring
        local function createBringSection(title, icon, list, defaultValue)
            defaultValue = defaultValue or {"All"}
            local sel = defaultValue
            local sec = BringTab:Section({Title=title,Icon=icon,Collapsible=true})
            sec:Dropdown({Title="Pilih Item",Values=list,Value=defaultValue,Multi=true,AllowNone=true,Callback=function(v) sel=v or {"All"} end})
            sec:Button({Title="Bring "..title,Callback=function() bringItems(list,sel,State.selectedLocation) end})
            return sec
        end

        -- Cultist
        createBringSection("Bring Cultist","skull",{"All","Crossbow Cultist","Cultist","juggernaut Cultist","Brutal Cultist","Darkstring Cultist"},{"Crossbow Cultist","Cultist"})
        -- Meteor
        createBringSection("Bring Meteor Items","zap",{"All","Raw Obsidiron Ore","Gold Shard","Meteor Shard","Scalding Obsidiron Ingot"},{"All"})
        -- Fuels + Logs
        local fuelsList = {"All","Cultist","Crossbow Cultist","Log","Coal","Chair","Fuel Canister","Oil Barrel","juggernaut Cultist","Brutal Cultist","Darkstring Cultist"}
        local selectedFuels = {"Coal","Fuel Canister","Oil Barrel","Cultist","Crossbow Cultist","juggernaut Cultist","Brutal Cultist","Darkstring Cultist"}
        local fuelsSec = BringTab:Section({Title="Fuels",Icon="flame",Collapsible=true})
        fuelsSec:Dropdown({
            Title="Pilih Item",
            Values=fuelsList,
            Value=selectedFuels,
            Multi=true,
            AllowNone=true,
            Callback=function(v) 
                selectedFuels = v or {"All"}
            end
        })
        fuelsSec:Button({
            Title="Bring Fuels",
            Callback=function() 
                bringItems(fuelsList, selectedFuels, State.selectedLocation) 
            end
        })
        fuelsSec:Button({
            Title="Bring Logs Only",
            Callback=function() 
                bringItems(fuelsList, {"Log"}, State.selectedLocation) 
            end
        })
        -- Food
        createBringSection("Food","drumstick",{
            "All","Sweet Potato","Stuffing","Turkey Leg","Carrot","Pumkin","Mackerel",
            "Salmon","Swordfish","Berry","Ribs","Stew","Steak Dinner","Morsel","Steak",
            "Corn","Cooked Morsel","Cooked Steak","Chilli","Apple","Cake","MRE"
        }, {"All"})
        -- Healing
        createBringSection("Healing","heart",{"All","MedKit","Bandage"},{"All"})
        -- Gears
        createBringSection("Gears (Scrap)","wrench",{
            "All","Bolt","Tyre","Sheet Metal","Old Radio","Broken Fan","Broken Microwave",
            "Washing Machine","Old Car Engine","UFO Scrap","UFO Component","UFO Junk",
            "Cultist Gem","Gem of the Forest","Gem of the Forest Fragment"
        }, {"All"})
        -- Guns & Ammo
        createBringSection("Guns & Ammo","swords",{
            "All","Infernal Sword","Morningstar","Crossbow","Infernal Crossbow","Laser Sword",
            "Raygun","Ice Axe","Ice Sword","Chainsaw","Strong Axe","Axe Trim Kit","Spear",
            "Good Axe","Revolver","Rifle","Tactical Shotgun","Revolver Ammo","Rifle Ammo",
            "Alien Armour","Frog Boots","Leather Body","Iron Body","Thorn Body",
            "Riot Shield","Armour Trim Kit","Obsidiron Boots"
        }, {"All"})
        -- Other Items
        createBringSection("Bring Other","package",{
            "All","Purple Fur Tuft","Halloween Candle","Candy","Frog Key","Feather",
            "Wildfire","Sacrifice Totem","Old Rod","Flower","Coin Stack","Infernal Sack",
            "Giant Sack","Good Sack","Seed Box","Chainsaw","Old Flashlight",
            "Strong Flashlight","Bunny Foot","Wolf Pelt","Bear Pelt","Mammoth Tusk",
            "Alpha Wolf Pelt","Bear Corpse","Meteor Shard","Gold Shard",
            "Raw Obsidiron Ore","Gem of the Forest","Diamond","Defense Blueprint"
        }, {"All"})
    end

    ---------------------------------------------------------
    -- TAB 6: TELEPORT
    ---------------------------------------------------------
    do
        local lostChildSec = TeleportTab:Section({ Title = "Teleport Lost Child", Icon = "baby", Collapsible = true, DefaultOpen = true })
        local childOptions = {"DinoKid", "KoalaKid", "KrakenKid", "SquidKid"}
        local selectedChild = "DinoKid"
        lostChildSec:Dropdown({ Title = "Select Child", Values = childOptions, Value = "DinoKid", Callback = function(v) selectedChild = v end })
        lostChildSec:Button({ Title = "Teleport To Child", Callback = function()
            local chars = Services.Workspace:FindFirstChild("Characters")
            if not chars then return end
            local targetHRP = nil
            if selectedChild == "DinoKid" then targetHRP = chars:FindFirstChild("Lost Child")
            elseif selectedChild == "KoalaKid" then targetHRP = chars:FindFirstChild("Lost Child4")
            elseif selectedChild == "KrakenKid" then targetHRP = chars:FindFirstChild("Lost Child2")
            elseif selectedChild == "SquidKid" then targetHRP = chars:FindFirstChild("Lost Child3") end
            local hrp = targetHRP and targetHRP:FindFirstChild("HumanoidRootPart")
            teleportToCFrame(hrp and hrp.CFrame)
        end })

       local structureSec = TeleportTab:Section({
            Title = "Structure Teleport",
            Icon = "castle",
            Collapsible = true,
            DefaultOpen = false
        })

        -- CAMP
        structureSec:Button({
            Title = "Teleport to Camp",
            Callback = function()
                local camp = getCamp()
                if camp then
                    teleportToCFrame(camp.CFrame)
                else
                    notifyUI("Teleport", "Camp tidak ditemukan", 3, "alert-triangle")
                end
            end
        })

        -- CULTIST GENERATOR BASE (cached)
        structureSec:Button({
            Title = "Teleport to Cultist Generator Base",
            Callback = function()
                local part = getCultistGeneratorBase()
                if not part then
                    notifyUI("Teleport", "Cultist Generator Base tidak ditemukan", 3, "alert-triangle")
                    return
                end

                teleportToCFrame(part.CFrame * CFrame.new(0, 2, 0))
            end
        })

        -- STRONGHOLD
        structureSec:Button({
            Title = "Teleport to Stronghold",
            Callback = function()
                local sign = getStronghold()
                if sign then
                    teleportToCFrame(sign.CFrame)
                end
            end
        })

        -- STRONGHOLD DIAMOND CHEST
        structureSec:Button({
            Title = "Teleport to Stronghold Diamond Chest",
            Callback = function()
                local chest = getStrongholdDiamondChest()
                if not chest then return end

                local part =
                    chest.PrimaryPart
                    or chest:FindFirstChildWhichIsA("BasePart", true)

                if part then
                    teleportToCFrame(part.CFrame * CFrame.new(0, 4, 0))
                end
            end
        })

        -- CARAVAN
        structureSec:Button({
            Title = "Teleport to Caravan",
            Callback = function()
                local map = Services.Workspace:FindFirstChild("Map")
                local caravan = map and map:FindFirstChild("Landmarks")
                    and map.Landmarks:FindFirstChild("Caravan")

                if caravan and caravan.PrimaryPart then
                    teleportToCFrame(caravan.PrimaryPart.CFrame)
                end
            end
        })

        -- FAIRY
        structureSec:Button({
            Title = "Teleport to Fairy",
            Callback = function()
                local fairy =
                    Services.Workspace:FindFirstChild("Map")
                    and Services.Workspace.Map:FindFirstChild("Landmarks")
                    and Services.Workspace.Map.Landmarks:FindFirstChild("Fairy House")
                    and Services.Workspace.Map.Landmarks["Fairy House"]
                        :FindFirstChild("Fairy")
                        :FindFirstChild("HumanoidRootPart")

                if fairy then
                    teleportToCFrame(fairy.CFrame)
                end
            end
        })

        -- ANVIL (cached)
        structureSec:Button({
            Title = "Teleport to Anvil",
            Callback = function()
                local anvil = getAnvil()
                if not anvil then
                    notifyUI("Teleport", "Anvil tidak ditemukan", 3, "alert-triangle")
                    return
                end

                teleportToCFrame(anvil.CFrame)
            end
        })

    end
    ---------------------------------------------------------
    -- TAB 7: UPDATE FOCUSED
    ---------------------------------------------------------
    do
        local christmasSec = UpdateTab:Section({Title="Christmas",Icon="gift",DefaultOpen=true})
        christmasSec:Button({ Title = "Teleport to Christmas Present", Callback = function() local p = Services.Workspace.Items:FindFirstChild("ChristmasPresent1") local part = p and (p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart",true)) teleportToCFrame(part and part.CFrame) end })
        christmasSec:Button({ Title = "Teleport to Santa's Sack", Callback = function() local sled = Services.Workspace.Map.Landmarks["Santa's Sack"].SantaSack.Sled teleportToCFrame((sled.Rail and sled.Rail.Part and sled.Rail.Part.CFrame) or (sled.Engine and sled.Engine.CFrame)) end })
        local optList={"North Pole","Elf Tree","Elf Ice Lake","Elf Ice Race"}
        local selectedOpt="North Pole"
        christmasSec:Dropdown({ Title = "Teleport Options", Values = optList, Value = "North Pole", Callback = function(v) selectedOpt = v end })
        christmasSec:Button({ Title = "Teleport", Callback = function()
            local t=nil
            if selectedOpt=="North Pole" then
                local np = Services.Workspace.Map.Landmarks:FindFirstChild("North Pole") and Services.Workspace.Map.Landmarks["North Pole"]:FindFirstChild("Festive Carpet Blueprint")
                t = np and np:FindFirstChild("GraphLines") or np and np:FindFirstChild("Star")
            elseif selectedOpt=="Elf Tree" then
                t = Services.Workspace.Map.Landmarks["Elf Tree"].Trees["Northern Pine"].TrunkPart
            elseif selectedOpt=="Elf Ice Lake" then
                local l = Services.Workspace.Map.Landmarks["Elf Ice Lake"]
                t = l:FindFirstChild("Main") or l.GrassFolder:FindFirstChild("Grass")
            elseif selectedOpt=="Elf Ice Race" then
                t = Services.Workspace.Map.Landmarks["Elf Ice Race"].Obstacles.SnowStoneTall.Part
            end
            teleportToCFrame(t and t.CFrame)
        end })
        local mazeSec = UpdateTab:Section({Title="Maze",Icon="map"})
        mazeSec:Button({ Title = "TP to End", Callback = function() local chest = Services.Workspace.Items:FindFirstChild("Halloween Maze Chest") local target = chest and chest:FindFirstChild("Main") or chest and chest:FindFirstChild("ItemDrop") teleportToCFrame(target and target.CFrame) end })
        
        local hardModeSec = UpdateTab:Section({
            Title = "Hard Mode",
            Icon = "skull"
        })

        -- Research Building
        hardModeSec:Button({
            Title = "Research Building",
            Callback = function()
                local part =
                    Services.Workspace:FindFirstChild("Map")
                    and Services.Workspace.Map:FindFirstChild("Landmarks")
                    and Services.Workspace.Map.Landmarks:FindFirstChild("Research Outpost")
                    and (
                        Services.Workspace.Map.Landmarks["Research Outpost"].PrimaryPart
                        or Services.Workspace.Map.Landmarks["Research Outpost"]:FindFirstChildWhichIsA("BasePart", true)
                    )

                teleportToCFrame(part and part.CFrame)
            end
        })

        -- Cursed Sign
        hardModeSec:Button({
            Title = "Teleport to Cursed Sign",
            Callback = function()
                local landmarks =
                    Services.Workspace:FindFirstChild("Map")
                    and Services.Workspace.Map:FindFirstChild("Landmarks")

                if not landmarks then return end

                local rifts = {}
                for _, v in ipairs(landmarks:GetDescendants()) do
                    if v:IsA("Model") and v.Name == "Corrupted Tree Rift" then
                        table.insert(rifts, v)
                    end
                end

                if #rifts == 0 then return end

                State.cursedRiftIndex = State.cursedRiftIndex + 1
                if State.cursedRiftIndex > #rifts then
                    State.cursedRiftIndex = 1
                end

                local target = rifts[State.cursedRiftIndex]
                local part =
                    target.PrimaryPart
                    or target:FindFirstChildWhichIsA("BasePart", true)

                teleportToCFrame(part and part.CFrame)
            end
        })
    end
    ---------------------------------------------------------
    -- TAB 8: FARM
    ---------------------------------------------------------
    do
        FarmTab:Paragraph({ Title = "Combat Aura", Desc = "Auto Kill and Auto Cut Tree \nThe radius is adjustable from 50 to 200.", Color = "Grey" })
        FarmTab:Toggle({ Title = "Kill Aura (Radius-based)", Icon = "swords", Default = false, Callback = function(state) if State.scriptDisabled then return end State.KillAuraEnabled = state; notifyUI("Kill Aura", state and "Kill Aura activated!" or "Kill Aura deactivated.", 3) end })
        FarmTab:Slider({ Title = "Kill Aura Radius", Description = "Jarak Kill Aura (50 - 200).", Step = 1, Value = { Min = 50, Max = 200, Default = State.KillAuraRadius }, Callback = function(value) State.KillAuraRadius = tonumber(value) or State.KillAuraRadius end })
        FarmTab:Toggle({
            Title = "Chop Aura",
            Icon = "axe",
            Default = false,
            Callback = function(state)
                if State.scriptDisabled then return end
                State.ChopAuraEnabled = state
                if state then
                    -- Build cache awal
                    buildTreeCache()
                    
                    -- Simpan day saat ini
                    State.lastDayDetected = State.currentDayCached
                    
                    notifyUI("Chop Aura", 
                        string.format("AKTIF untuk %s (%d pohon dalam cache)", 
                        table.concat(State.SelectedTreeCategories, ", "), 
                        #State.TreeCache), 
                        4, "zap")
                else
                    State.TreeCache = {}
                    State.lastDayDetected = nil
                    notifyUI("Chop Aura", "deactivated", 3, "toggle-left")
                end
            end
        })

        -- MODIFIKASI pada dropdown kategori pohon untuk restart refresh jika berubah kategori:
        FarmTab:Dropdown({
            Title = "Tree Categories",
            Description = "Pilih kategori pohon untuk Chop Aura",
            Values = {"Small Tree","Snowy Small Tree","Big Tree"},
            Value = {"Small Tree"},
            Multi = true,
            Callback = function(selectedValues)
                if not selectedValues or #selectedValues == 0 then
                    selectedValues = {"Small Tree"}
                end
                State.SelectedTreeCategories = selectedValues
                
                -- Jika Chop Aura aktif, restart refresh dengan kategori baru
                if State.ChopAuraEnabled then
                    -- Stop refresh lama
                    stopTreeCacheRefresh()
                    
                    -- Rebuild cache dengan kategori baru
                    buildTreeCache()
                    
                    -- Start refresh baru
                    startTreeCacheRefresh()
                    
                    notifyUI("Tree Categories Updated", 
                        string.format("Kategori diperbarui: %s\n(%d pohon dalam cache)", 
                        table.concat(State.SelectedTreeCategories, ", "), 
                        #State.TreeCache), 
                        3, "trees")
                else
                    notifyUI("Tree Categories Updated", 
                        string.format("Kategori disimpan: %s", 
                        table.concat(State.SelectedTreeCategories, ", ")), 
                        3, "trees")
                end
            end
        })
        FarmTab:Slider({ Title = "Chop Aura Radius", Description = "Jarak tebang otomatis (50 - 200).", Step = 1, Value = { Min = 50, Max = 200, Default = State.ChopAuraRadius }, Callback = function(value) State.ChopAuraRadius = tonumber(value) or State.ChopAuraRadius end })
        FarmTab:Paragraph({ Title = "Automation Section", Color = "Grey" })
        FarmTab:Toggle({ Title = "Auto Crockpot", Icon = "flame", Default = false, Callback = function(state) if State.scriptDisabled then return end if state then local ok = ensureCookingStations() if not ok then State.AutoCookEnabled = false; notifyUI("Auto Crockpot", "Crock Pot / Chefs Station Not Found.", 4, "alert-triangle"); return end State.AutoCookEnabled = true; startCookLoop(); notifyUI("Auto Crockpot", "Auto Crockpot activated!", 4) else State.AutoCookEnabled = false; notifyUI("Auto Crockpot", "Auto Crockpot deactivated.", 3) end end })
        FarmTab:Toggle({ Title = "Auto Scrapper", Icon = "recycle", Default = false, Callback = function(state) if State.scriptDisabled then return end if state then local ok = ensureScrapperTargetFarm() if not ok then State.ScrapEnabled = false; notifyUI("Auto Scrapper", "Scrapper target Not Found.", 4, "alert-triangle"); return end State.ScrapEnabled = true; startScrapLoop(); notifyUI("Auto Scrapper", "Auto Scrapper activated!", 4) else State.ScrapEnabled = false; notifyUI("Auto Scrapper", "Auto Scrapper deactivated.", 3) end end })
        FarmTab:Toggle({ Title = "Auto Sacrifice Lava", Icon = "flame-kindling", Default = false, Callback = function(state) if State.scriptDisabled then return end State.AutoSacEnabled = state if state then notifyUI("Auto Sacrifice Lava", State.lavaFound and "Auto sacrifice activated!" or "Lava not found yet, script will activate once lava is ready.", 4, State.lavaFound and "check-circle" or "alert-triangle") else notifyUI("Auto Sacrifice Lava", "Auto sacrifice deactivated.", 3) end end })
        FarmTab:Toggle({ Title = "Ultra Fast Coin & Ammo", Icon = "zap", Default = false, Callback = function(state) if State.scriptDisabled then return end if state then startCoinAmmo(); notifyUI("Coin & Ammo", "Auto collect activated!", 4) else stopCoinAmmo(); notifyUI("Coin & Ammo", "Auto collect deactivated.", 3) end end })
    end
    ---------------------------------------------------------
    -- TAB 9: NIGHT
    ---------------------------------------------------------
    do
        NightTab:Toggle({ Title = "Auto Skip Night", Icon = "moon-star", Default = false, Callback = function(state) if State.scriptDisabled then return end State.autoTemporalEnabled = state; notifyUI("Auto Skip Night", state and "Active: auto trigger when Day increases." or "deactivated.", 4, state and "moon" or "toggle-left") end })
        NightTab:Button({ Title = "Manual Skip Night", Icon = "zap", Callback = function() if State.scriptDisabled then return end activateTemporal(); notifyUI("Temporal", "Temporal Accelerometer activated!", 4) end })
    end
    ---------------------------------------------------------
    -- TAB 10: WEBHOOK
    ---------------------------------------------------------
    do

        WebhookTab:Input({ Title = "Discord Webhook URL", Icon = "link", Placeholder = State.WebhookURL, Numeric = false, Finished = false, Callback = function(txt) local t = trim(txt or "") if t ~= "" then State.WebhookURL = t; notifyUI("Webhook", "URL disimpan.", 3, "link"); print("WebhookURL set:", State.WebhookURL) end end })
        WebhookTab:Input({ Title = "Webhook Username (opsional)", Icon = "user", Placeholder = State.WebhookUsername, Numeric = false, Finished = false, Callback = function(txt) local t = trim(txt or "") if t ~= "" then State.WebhookUsername = t end; notifyUI("Webhook", "Username disimpan: " .. tostring(State.WebhookUsername), 3, "user") end })
        WebhookTab:Toggle({ Title = "Enable Webhook DayDisplay", Icon = "radio", Default = State.WebhookEnabled, Callback = function(state) State.WebhookEnabled = state; notifyUI("Webhook", state and "Webhook activated." or "Webhook deactivated.", 3, state and "check-circle-2" or "x-circle") end })
        WebhookTab:Button({ Title = "Test Send Webhook", Icon = "flask-conical", Callback = function()
            if State.scriptDisabled then return end
            local players = Services.Players:GetPlayers(); local names = {}
            for _, p in ipairs(players) do table.insert(names, p.Name) end
            local payload = { username = State.WebhookUsername, embeds = {{ title = "🧪 TEST - Webhook Aktif " .. tostring(State.WebhookUsername), description = ("**Webhook Aktif %s**\n\n**Progress:** `%s`\n\n**Pemain Aktif:**\n%s"):format(tostring(State.WebhookUsername), tostring(State.currentDayCached), namesToVerticalList(names)), color = 0x2ECC71, footer = { text = "Test sent: " .. os.date("%Y-%m-%d %H:%M:%S") }}}}
            local ok, msg = sendWebhookPayload(payload)
            if ok then notifyUI("Webhook Test", "Terkirim: " .. tostring(msg), 5, "check-circle-2"); print("Webhook Test success:", msg) else notifyUI("Webhook Test Failed", tostring(msg), 8, "alert-triangle"); warn("Webhook Test failed:", msg) end
        end })
    end
    task.wait(1)
    notifyUI("✅ HexaCore Ready!", "All systems loaded.", 8, "check-circle")
    print([[
[PapiDimz x FRENESIS] MERGE COMPLETE
===========================
- Fun System: READY
- Bring Item System: READY
- Teleport System: READY
- Local Player Mods: READY
- Fishing Macro: READY
- Farm System: READY
- Combat Aura: READY
- Night Skip: READY
- Webhook: READY
===========================
]])
end

---------------------------------------------------------
-- INITIALIZATION & STARTUP
---------------------------------------------------------
if State.uiKeybindConn then
    State.uiKeybindConn:Disconnect()
end

State.uiKeybindConn = Services.UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if State.isSettingKeybind then return end
    if not State.WindUIWindow then return end

    if input.KeyCode == currentKeybind then
        State.WindUIWindow:Toggle()
    end
end)


task.spawn(function()
    initRemoteEvents()
    pcall(tryHookDayDisplay)
    
    if State.WindUI then
        createUI()
        task.wait(3)
    end
end)

-- Update overlay berkala
task.spawn(function()
    while State.scriptActive do
        task.wait(1)
        if State.overlayVisible then
            updateOverlay()
        end
    end
end)

-- Auto-sacrifice loop safety
task.spawn(function()
    while not State.scriptDisabled do
        if State.AutoSacEnabled and State.lavaFound and State.ItemsFolder then
            for _, obj in ipairs(State.ItemsFolder:GetChildren()) do
                sacrificeItemToLava(obj)
            end
        end
        task.wait(0.7)
    end
end)

-- Character initialization
LocalPlayer.CharacterAdded:Connect(function(char)
    -- tunggu character stabil
    task.wait(0.4)

    -- =========================
    -- EXISTING CORE STATE
    -- =========================
    State.humanoid = char:WaitForChild("Humanoid")
    State.rootPart = char:WaitForChild("HumanoidRootPart")
    State.defaultWalkSpeed = State.humanoid.WalkSpeed
    State.Character = char
    State.HumanoidRootPart = State.rootPart

    print("[Character] Loaded.")

    -- =========================
    -- SAFETY (WAJIB)
    -- =========================
    -- pastikan tidak ke-anchor (fail-safe)
    State.rootPart.Anchored = false

    -- reset Auto Stronghold state
    State.autoStrongholdRunning = false
end)


if LocalPlayer.Character then
    State.humanoid = getHumanoid()
    State.rootPart = getRoot()
    if State.humanoid then State.defaultWalkSpeed = State.humanoid.WalkSpeed end
end

-- Start GodMode loop if default
task.spawn(function()
    task.wait(2)
    initRemoteEvents()
    pcall(tryHookDayDisplay)
    if State.GodmodeEnabled and State.DamagePlayerRemote then startGodmodeLoop() end
    LocalPlayer.Idled:Connect(function()
        if State.scriptDisabled then return end
        if not State.AntiAFKEnabled then return end
        Services.VirtualUser:CaptureController()
        Services.VirtualUser:ClickButton2(Vector2.new())
        print("[Anti-AFK] Triggered anti-AFK")
    end)
end)

-- Final loaded notifications
task.wait(1)
notifyUI("✅ HexaCore Ready!", "All systems loaded.", 8, "check-circle")
print([[
[PapiDimz x FRENESIS] MERGE COMPLETE
===========================
- Fun System: READY
- Bring Item System: READY
- Teleport System: READY
- Local Player Mods: READY
- Fishing Macro: READY
- Farm System: READY
- Combat Aura: READY
- Night Skip: READY
- Webhook: READY
===========================
]])

notifyUI("HexaCore Loaded!", "All Features: Fun + Main + Local Player + Fishing + Bring Item + Teleport + Update Focused + Farm + Night Skip + Webhook", 10, "sparkles")

-- END OF SCRIPT
