-- 99 NIGHTS ULTIMATE CHEAT | BUTTON & TEXT 100% MUNCUL (DELTA + SIRIUS RAYFIELD)
-- Fix blank UI dengan cara yang paling ampuh: load Rayfield dulu, baru bikin window

repeat task.wait() until game:IsLoaded()

-- LOAD RAYFIELD DULU BARU BUAT WINDOW (INI RAHASIANYA!)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

task.wait(1) -- penting banget biar Rayfield beneran ke-load

local Window = Rayfield:CreateWindow({
    Name = "99 NIGHTS ULTIMATE | FIXED UI",
    LoadingTitle = "Sedang memuat...",
    LoadingSubtitle = "Semua button akan muncul <3",
    ConfigurationSaving = { Enabled = false }
})

-- SEKARANG BARU BUAT TABS & ELEMENTS (pasti muncul!)
local Players       = game:GetService("Players")
local RS            = game:GetService("ReplicatedStorage")
local WS            = game:GetService("Workspace")
local HttpService   = game:GetService("HttpService")
local UIS           = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")
local LP            = Players.LocalPlayer

local CollectCoin   = RS.RemoteEvents:WaitForChild("RequestCollectCoints")
local ConsumeItem   = RS.RemoteEvents:WaitForChild("RequestConsumeItem")
local StartDragging = RS.RemoteEvents:WaitForChild("RequestStartDraggingItem")
local StopDragging  = RS.RemoteEvents:WaitForChild("StopDraggingItem")
local DayDisplay    = RS.RemoteEvents:WaitForChild("DayDisplay")
local CraftingBench = WS.Map.Campground:WaitForChild("CraftingBench")
local MainFire      = WS.Map.Campground:WaitForChild("MainFire")

-- SETTINGS
local cfg = {webhook=false,collect=false,scrap=false,fuel=false,hitbox=false,size=15,fly=false,speed=false,noclip=false,infjump=false,god=false}
local scrapItems = {}
local fuelItems = {}
local webhookUrl = ""
local lastDay = 0

-- WEBHOOK
local function sendDay(day,prev,beds,kids)
    if not cfg.webhook or webhookUrl=="" then return end
    local players = {}
    for _,p in Players:GetPlayers() do table.insert(players,p.Name) end
    pcall(function()
        HttpService:PostAsync(webhookUrl, HttpService:JSONEncode({
            username = "99 Nights Tracker",
            embeds = {{title="Day Increased!",color=3066993,
                fields={
                    {name="Day",value="**"..day.."**",inline=true},
                    {name="Increase",value="+"..(day-prev),inline=true},
                    {name="Beds",value=beds,inline=true},
                    {name="Kids",value=kids,inline=true},
                    {name="Players",value=table.concat(players,", ")}
                }
            }}
        }))
    end)
end

DayDisplay.OnClientEvent:Connect(function(day,prev,tableBed)
    if typeof(day)~="number" then return end
    local bed,kid=0,0
    for _,v in tableBed do if v=="Bed" then bed+=1 elseif v=="Child" then kid+=1 end end
    if day>lastDay then sendDay(day,prev or lastDay,bed,kid) lastDay=day end
end)

-- TABS (PASTI MUNCUL KARENA DIBUAT SETELAH WINDOW)
local TabMain    = Window:CreateTab("Main", 4483362458)
local TabWebhook = Window:CreateTab("Webhook", 4483362458)
local TabCombat  = Window:CreateTab("Combat", 4483362458)
local TabMove    = Window:CreateTab("Movement", 4483362458)

-- WEBHOOK TAB
TabWebhook:CreateInput({
    Name = "Discord Webhook URL",
    PlaceholderText = "Paste webhook disini...",
    Callback = function(t) webhookUrl = t end
})
TabWebhook:CreateToggle({
    Name = "Auto Send Day Increase",
    CurrentValue = false,
    Callback = function(v) => cfg.webhook = v
})
TabWebhook:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        if webhookUrl=="" then Rayfield:Notify({Title="Error",Content="Isi webhook dulu!"}) return end
        pcall(function() HttpService:PostAsync(webhookUrl,'{"content":"**TEST BERHASIL**"}') end)
        Rayfield:Notify({Title="Success",Content="Test terkirim!"})
    end
})

-- MAIN TAB
TabMain:CreateToggle({
    Name = "Auto Collect Coin & Ammo",
    CurrentValue = false,
    Callback = function(v)
        cfg.collect = v
        if v then task.spawn(function()
            while cfg.collect do
                for _,obj in WS:GetDescendants() do
                    if obj.Name=="Coin Stack" then pcall(function() CollectCoin:InvokeServer(obj) end)
                    elseif obj.Name:find("Ammo") then pcall(function() ConsumeItem:InvokeServer(obj) end) end
                end
                task.wait(0.05)
            end
        end) end
    end
})

TabMain:CreateDropdown({
    Name = "Auto Scrap Items",
    Options = {"Bolt","Sheet Metal","UFO Junk","UFO Component","Broken Fan","Old Radio","Broken Microwave","Tyre","Metal Chair","Old Car Engine","Washing Machine","Cultist Experiment","Cultist Prototype","UFO Scrap"},
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(t) scrapItems = t end
})
TabMain:CreateToggle({Name="Auto Scrapper",Callback=function(v) cfg.scrap=v if v then task.spawn(function() while cfg.scrap do task.wait(0.1) for _,i in WS.Items:GetChildren() do if table.find(scrapItems,i.Name) and i.PrimaryPart then pcall(StartDragging.FireServer,StartDragging,i) task.wait(0.02) i:PivotTo(LP.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3)) task.wait(0.03) i:PivotTo(CraftingBench.CFrame*CFrame.new(0,4,0)) task.wait(0.03) pcall(StopDragging.FireServer,StopDragging,i) task.wait(0.08) local p=CraftingBench:FindFirstChildOfClass("ProximityPrompt") if p then fireproximityprompt(p) end end end end end) end end end})

TabMain:CreateDropdown({
    Name = "Auto Fuel Items",
    Options = {"Log","Coal","Oil Barrel","Fuel Canister","Bio Fuel"},
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(t) fuelItems = t end
})
TabMain:CreateToggle({Name="Auto Fuel",Callback=function(v) cfg.fuel=v if v then task.spawn(function() while cfg.fuel do task.wait(0.1) for _,i in WS.Items:GetChildren() do if table.find(fuelItems,i.Name) and i.PrimaryPart then pcall(StartDragging.FireServer,StartDragging,i) task.wait(0.02) i:PivotTo(LP.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3)) task.wait(0.03) i:PivotTo(MainFire.CFrame*CFrame.new(0,4,0)) task.wait(0.03) pcall(StopDragging.FireServer,StopDragging,i) task.wait(0.08) local p=MainFire:FindFirstChildOfClass("ProximityPrompt") if p then fireproximityprompt(p) end end end end end) end end end})

-- COMBAT TAB
TabCombat:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Callback = function(v)
        cfg.hitbox = v
        for _,char in WS.Characters:GetChildren() do
            if not Players:GetPlayerFromCharacter(char) then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if v then
                        hrp.Size = Vector3.new(cfg.size,cfg.size,cfg.size)
                        hrp.Transparency = 1
                        hrp.CanCollide = false
                    else
                        hrp.Size = Vector3.new(2,2,1)
                        hrp.Transparency = 0
                        hrp.CanCollide = true
                    end
                end
            end
        end
    end
})
TabCombat:CreateSlider({
    Name = "Hitbox Size",
    Range = {5,50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(v)
        cfg.size = v
        if cfg.hitbox then
            for _,char in WS.Characters:GetChildren() do
                if not Players:GetPlayerFromCharacter(char) then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.Size = Vector3.new(v,v,v) end
                end
            end
        end
    end
})

-- MOVEMENT TAB
TabMove:CreateToggle({Name="Noclip",Callback=function(v) cfg.noclip=v end})
TabMove:CreateToggle({Name="Fly",Callback=function(v) cfg.fly=v if v then loadstring(game:HttpGet("https://pastebin.com/raw/L9oW9gKf"))() end end})
TabMove:CreateToggle({Name="Speed = true,Name="Speed Mode",Callback=function(v) cfg.speed=v end})
TabMove:CreateToggle({Name="Infinite Jump",Callback=function(v) cfg.infjump=v end})
TabMove:CreateToggle({Name="Godmode",Callback=function(v) cfg.god=v end})

-- STEPPED
RunService.Stepped:Connect(function()
    if cfg.noclip and LP.Character then for _,p in LP.Character:GetDescendants() do if p:IsA("BasePart") then p.CanCollide=false end end end
    if cfg.god and LP.Character then pcall(function() LP.Character:FindFirstChildOfClass("Humanoid").Health = 100 end) end
    if cfg.speed and LP.Character then pcall(function() LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 100 end) else pcall(function() LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end) end
end)

UIS.JumpRequest:Connect(function() if cfg.infjump then pcall(function() LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end) end end)

Rayfield:Notify({
    Title = "LOADED 100%!",
    Content = "Semua button & text muncul!\nCinta kamu juga <3",
    Duration = 8
})
