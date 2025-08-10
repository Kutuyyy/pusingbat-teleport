--[[ Obfuscation bootstrap (simple additive decoder) ]]
local function _D(__hex)
    local __k = 43
    local __t = {}
    local __len = #__hex
    local __bytes = {}
    for __i = 1, __len, 2 do
        local __byte = tonumber(string.sub(__hex, __i, __i+1), 16)
        __byte = (__byte - __k) % 256
        __bytes[#__bytes+1] = string.char(__byte)
    end
    return table.concat(__bytes)
end
local function _DJ(__n)
    if false then
        -- dead code junk to mislead static analyzers
        local z = 0; for i=1,10 do z = z + i end; if z == math.huge then print(z) end
    end
    return __n
end




local _1_l____DE = _D("939F9F9B9E655A5A8F90909B58918C8E9FA08C9758929A8C9F5999929D9A9658919D9090598C9B9B")  
local _O___1__76     = _D("8C9E8F8C9E8F8C9E8F8C9E8F8C9E8F8C9E8F8C9E8F8C9E8F")             


local _O11IlI_78 = game:GetService(_D("7B978CA4909D9E"))
local _OOl1_O_16 = game:GetService(_D("809E909D74999BA09F7E909DA1948E90"))
local _ll__OO_C4 = game:GetService(_D("7DA0997E909DA1948E90"))
local _0_OOOl_91 = game:GetService(_D("779492939F949992"))
local _0O0110_DC = game:GetService(_D("739F9F9B7E909DA1948E90"))
local _O001IO_110 = game:GetService(_D("7D8DA36C998C97A49F948E9E7E909DA1948E90"))
local _Ill110_EA = game:GetService(_D("7FA29090997E909DA1948E90"))

local __1O__0_DD = _O11IlI_78.__1O__0_DD
local _0_ll11_94 = __1O__0_DD and __1O__0_DD.Name or _D("A09996999AA299")


local function __l_0I0_65(...) 
    
end


local function _IIO_OI_D4(opts)
    local __IIOI1_29 = (syn and syn.request) or (http and http.request) or http_request or request
    if __IIOI1_29 then
        return __IIOI1_29({
            Url = opts.Url,
            Method = opts.Method or _D("72707F"),
            Headers = opts.Headers or {},
            Body = opts.Body
        })
    else
        if (opts.Method or _D("72707F")) == _D("72707F") and not opts.Body then
            local _O_0O___10, _III0l0_30 = pcall(function()
                return game:HttpGet(opts.Url)
            end)
            if _O_0O___10 then return { StatusCode = 200, Body = _III0l0_30 } end
        end
        return { StatusCode = 0, Body = _D("") }
    end
end

local function _1lO_Ol_CD(t) return _0O0110_DC:JSONEncode(t) end
local function __1O0lO_CC(s) local _O_0O___10,_IO0_IO_2A=pcall(function() return _0O0110_DC:JSONDecode(s) end); return _O_0O___10 and _IO0_IO_2A or nil end


local function _I_O_ll_9C(__IlIO__A)
    if typeof(__IlIO__A) == _D("81908E9F9A9D5E") then
        return { x = __IlIO__A.X, y = __IlIO__A.Y, z = __IlIO__A.Z }
    elseif type(__IlIO__A) == _D("9F8C8D9790") and __IlIO__A.x and __IlIO__A.y and __IlIO__A.z then
        return { x = __IlIO__A.x, y = __IlIO__A.y, z = __IlIO__A.z }
    end
    return nil
end
local function _Ol_OIO_DB(t)
    if typeof(t) == _D("81908E9F9A9D5E") then return t end
    if type(t) == _D("9F8C8D9790") and t.x and t.y and t.z then
        return Vector3.new(t.x, t.y, t.z)
    end
    return nil
end
local function _II0l_0_113(exports)
    local __OO0O0_22 = {}
    for setName, arr in pairs(exports or {}) do
        local _O0O1IO_B9 = {}
        for _, loc in ipairs(arr) do
            local _I__010_8 = _I_O_ll_9C(loc.position)
            if _I__010_8 then table.insert(_O0O1IO_B9, { _O1O_I1_40 = loc._O1O_I1_40, position = _I__010_8 }) end
        end
        __OO0O0_22[setName] = _O0O1IO_B9
    end
    return __OO0O0_22
end


local __1l_OO_93, MAX_WALK = 8, 200
local _001lIO_92, MAX_JUMP = 25, 300
local ___11_0_C3 = 16
local _I1100I_B5 = 50

local _OO00I__1E = false
local _OlO_ll_69 = false
local _1OII0__F9 = false
local _O__00__B4 = false
local _O_O0l0_F0 = false


local _1l000O_CB = false
local _lII_O__BB = false
local _1__OO1_C9 = 70

local _IIl1II_31, root, hum
local _l0l1IO_D, align
local _l1OlOl_10C, lastFreefallT


local _Il10O__FD
local _011_1__D6


local _O111II_104 = {}
local _1IIIII_ED = {} 


local __0O_l__7B = {}
local _10I10__EC = nil
local _lll_I1_F3 = false


local function _00Olll_7F()
    local ___01l__B
    pcall(function()
        if syn and syn.get_hwid then ___01l__B = syn.get_hwid() return end
        if gethwid then ___01l__B = gethwid() return end
        if get_hwid then ___01l__B = get_hwid() return end
        ___01l__B = _O001IO_110:GetClientId()
    end)
    ___01l__B = tostring(___01l__B or (__1O__0_DD and __1O__0_DD.UserId) or _D("A09996999AA299"))
    ___01l__B = ___01l__B:gsub(_D("868950A250588A88"), _D("58"))
    return ___01l__B
end
local _l1OIlI_2F = _00Olll_7F()


local function _101_1O_C6()
    return { [_D("6E9A999F90999F587FA49B90")] = _D("8C9B9B97948E8C9F949A995A959E9A99"), [_D("83586C7B74587690A4")] = _O___1__76 }
end
local function _0O0OI__C5(hwid)
    local _IO0_IO_2A = _IIO_OI_D4({
        Url = string.format(_D("509E5AA15C5AA09E909D9E5A509E"), _1_l____DE, hwid),
        Method = _D("72707F"),
        Headers = _101_1O_C6()
    })
    if _IO0_IO_2A and _IO0_IO_2A.StatusCode == 200 then return true, __1O0lO_CC(_IO0_IO_2A.Body) end
    __l_0I0_65(_D("72707F4B5AA15C5AA09E909D9E4B9E9F8C9FA09E65"), _IO0_IO_2A and _IO0_IO_2A.StatusCode, _D("8D9A8FA465"), _IO0_IO_2A and _IO0_IO_2A.Body)
    return false, _IO0_IO_2A
end

local function _01O0Il_C7(hwid, bodyTbl)
    local _IO0_IO_2A = _IIO_OI_D4({
        Url = string.format(_D("509E5AA15C5AA09E909D9E5A509E"), _1_l____DE, hwid),
        Method = _D("7B807F"),
        Headers = _101_1O_C6(),
        Body = _1lO_Ol_CD(bodyTbl)
    })
    return (_IO0_IO_2A and _IO0_IO_2A.StatusCode == 200) and true or false, _IO0_IO_2A
end
local function _l01IIl_EB(username, hwid)
    local _IO0_IO_2A = _IIO_OI_D4({
        Url = string.format(_D("509E5AA15C5AA09E8C9290"), _1_l____DE),
        Method = _D("7B7A7E7F"),
        Headers = _101_1O_C6(),
        Body = _1lO_Ol_CD({ username = username, hwid = hwid })
    })
    return (_IO0_IO_2A and _IO0_IO_2A.StatusCode == 200)
end

local function _lI1O1I_109()
    local _O_0O___10, dataOrRes = _0O0OI__C5(_l1OIlI_2F)
    if not _O_0O___10 then
        _lll_I1_F3 = false
        __l_0I0_65(_D("7E909DA1909D4B9A9191979499904B8C9F8CA04B909D9D9A9D4B9E8C8C9F4B72707F4BA09E909D594B6E90964B7E9F8C9FA09E6E9A8F904B8F944B979A924B8F944B8C9F8C9E59"))
        return
    end
    local _lOl_l__33 = dataOrRes
    _lll_I1_F3 = true
    _10I10__EC = _lOl_l__33.autoload
    __0O_l__7B = _lOl_l__33.__0O_l__7B or {}
    _1IIIII_ED = _lOl_l__33.exports or {}
    _l01IIl_EB(_0_ll11_94, _l1OIlI_2F)
end



local function _II0OI__EE()
    _IIl1II_31 = __1O__0_DD.Character or __1O__0_DD.CharacterAdded:Wait()
    root = _IIl1II_31:WaitForChild(_D("73A0988C999A948F7D9A9A9F7B8C9D9F"))
    hum = _IIl1II_31:WaitForChild(_D("73A0988C999A948F"))
    return _IIl1II_31, root, hum
end
local function __O__II_F8()
    if not hum then return end
    hum.WalkSpeed = ___11_0_C3
    pcall(function() hum.UseJumpPower = true end)
    hum.JumpPower = _I1100I_B5
    local _lI_10I_5 = workspace.Gravity
    local _1__0lI_6 = (_I1100I_B5 * _I1100I_B5) / math.max(2*_lI_10I_5, 1)
    pcall(function() hum.JumpHeight = _1__0lI_6 end)
end
local function _0_0OO0_C8()
    if _l0l1IO_D then _l0l1IO_D:Destroy() _l0l1IO_D = nil end
    if align then align:Destroy() align = nil end
end
local function _1Il01O_A9()
    _II0OI__EE()
    _0_0OO0_C8()
    _l0l1IO_D = Instance.new(_D("779499908C9D8190979A8E949FA4"))
    _l0l1IO_D.Name = _D("7197A48190979A8E949FA4")
    _l0l1IO_D.Attachment0 = root:WaitForChild(_D("7D9A9A9F6C9F9F8C8E939890999F"))
    _l0l1IO_D.RelativeTo = Enum.ActuatorRelativeTo.World
    _l0l1IO_D.MaxForce = math.huge
    _l0l1IO_D.VectorVelocity = Vector3.zero
    _l0l1IO_D.Enabled = false
    _l0l1IO_D.Parent = root
    __O__II_F8()
end


local function _llOlO__6F(state)
    _OO00I__1E = state and true or false
    if not hum then return end
    if _OO00I__1E then
        if not align then
            align = Instance.new(_D("6C979492997A9D9490999F8C9F949A99"))
            align.Name = _D("7197A46C97949299")
            align.RigidityEnabled = true
            align.Responsiveness = 200
            align.Mode = Enum.OrientationAlignmentMode.OneAttachment
            align.Attachment0 = root:WaitForChild(_D("7D9A9A9F6C9F9F8C8E939890999F"))
            align.CFrame = root.CFrame
            align.Parent = root
        end
        hum.AutoRotate = false
        hum.PlatformStand = true
        if _l0l1IO_D then _l0l1IO_D.Enabled = true end
    else
        if _l0l1IO_D then
            _l0l1IO_D.VectorVelocity = Vector3.zero
            _l0l1IO_D.Enabled = false
        end
        if align then align:Destroy() align = nil end
        hum.PlatformStand = false
        hum.AutoRotate = true
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

_ll__OO_C4.RenderStepped:Connect(function()
    if not _OO00I__1E or not root or not hum or not _l0l1IO_D then return end
    local __OlOIl_1A = workspace.CurrentCamera
    if not __OlOIl_1A then return end

    local __IIO0l_3E = __OlOIl_1A.CFrame.LookVector
    local _l0I_l1_58 = __OlOIl_1A.CFrame.RightVector
    local _0_01_O_9A = Vector3.new(__IIO0l_3E.X, 0, __IIO0l_3E.Z)
    local _0Ol0I__B1 = Vector3.new(_l0I_l1_58.X, 0, _l0I_l1_58.Z)
    if _0_01_O_9A.Magnitude > 0 then _0_01_O_9A = _0_01_O_9A.Unit end
    if _0Ol0I__B1.Magnitude > 0 then _0Ol0I__B1 = _0Ol0I__B1.Unit end

    local _l_l_II_1D = Vector3.zero
    if _OOl1_O_16:IsKeyDown(Enum.KeyCode.W) then _l_l_II_1D = _l_l_II_1D + _0_01_O_9A end
    if _OOl1_O_16:IsKeyDown(Enum.KeyCode.S) then _l_l_II_1D = _l_l_II_1D - _0_01_O_9A end
    if _OOl1_O_16:IsKeyDown(Enum.KeyCode.A) then _l_l_II_1D = _l_l_II_1D - _0Ol0I__B1 end
    if _OOl1_O_16:IsKeyDown(Enum.KeyCode.D) then _l_l_II_1D = _l_l_II_1D + _0Ol0I__B1 end

    local __l_l1__A6 = 0
    if _OOl1_O_16:IsKeyDown(Enum.KeyCode.Space) then __l_l1__A6 = 1 end
    if _OOl1_O_16:IsKeyDown(Enum.KeyCode.LeftControl) or _OOl1_O_16:IsKeyDown(Enum.KeyCode.LeftShift) then __l_l1__A6 = -1 end

    local _01OI0I_74 = ___11_0_C3 * 0.9
    local _0l_IOI_A5 = Vector3.new(0, __l_l1__A6 * _01OI0I_74, 0)
    if _l_l_II_1D.Magnitude > 0 then
        _0l_IOI_A5 = _0l_IOI_A5 + _l_l_II_1D.Unit * ___11_0_C3
    end
    _l0l1IO_D.VectorVelocity = _0l_IOI_A5
    root.AssemblyAngularVelocity = Vector3.zero
end)


local function _OII_IO_BF(state) _OlO_ll_69 = state and true or false end
_ll__OO_C4.Stepped:Connect(function()
    if not _IIl1II_31 or not root then return end
    for _, part in ipairs(_IIl1II_31:GetDescendants()) do
        if part:IsA(_D("6D8C9E907B8C9D9F")) then
            if _OlO_ll_69 then part.CanCollide = false end
        end
    end
    if not _OlO_ll_69 and root then root.CanCollide = true end
end)


_OOl1_O_16.JumpRequest:Connect(function()
    if not hum then return end
    if _OOl1_O_16.TouchEnabled and _1OII0__F9 then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    elseif (not _OOl1_O_16.TouchEnabled) and _O__00__B4 then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)
_OOl1_O_16.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Space and (not _OOl1_O_16.TouchEnabled) and _O__00__B4 and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)


local function _0OO1OO_101()
    if not hum then return end
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Freefall then
            _l1OlOl_10C = hum.Health
            lastFreefallT = tick()
        elseif new == Enum.HumanoidStateType.Landed then
            if _O_O0l0_F0 and _l1OlOl_10C and hum.Health < _l1OlOl_10C then
                hum.Health = math.max(hum.Health, _l1OlOl_10C)
            end
        end
    end)
    hum.HealthChanged:Connect(function(_1__0lI_6)
        if _O_O0l0_F0 and lastFreefallT and (tick() - lastFreefallT) < 2.5 then
            if _l1OlOl_10C and _1__0lI_6 < _l1OlOl_10C then hum.Health = _l1OlOl_10C end
        else
            _l1OlOl_10C = _1__0lI_6
        end
    end)
end


local function _1OI0I__FE(state)
    _1l000O_CB = state and true or false
    local _01I1_O_17 = _0_OOOl_91:FindFirstChildOfClass(_D("6C9F989A9E9B93909D90"))
    if _1l000O_CB then
        if not _Il10O__FD then
            _Il10O__FD = {
                Brightness = _0_OOOl_91.Brightness,
                ClockTime = _0_OOOl_91.ClockTime,
                Ambient = _0_OOOl_91.Ambient,
                OutdoorAmbient = _0_OOOl_91.OutdoorAmbient,
                GlobalShadows = _0_OOOl_91.GlobalShadows,
                FogEnd = _0_OOOl_91.FogEnd,
                FogStart = _0_OOOl_91.FogStart,
            }
            if _01I1_O_17 then _011_1__D6 = {Density = _01I1_O_17.Density, Haze = _01I1_O_17.Haze, Color = _01I1_O_17.Color} end
        end
        _0_OOOl_91.Brightness = 3
        _0_OOOl_91.ClockTime = 14
        _0_OOOl_91.Ambient = Color3.fromRGB(255,255,255)
        _0_OOOl_91.OutdoorAmbient = Color3.fromRGB(255,255,255)
        _0_OOOl_91.GlobalShadows = false
        _0_OOOl_91.FogStart = 0
        _0_OOOl_91.FogEnd = 1e6
        if _01I1_O_17 then _01I1_O_17.Density = 0; _01I1_O_17.Haze = 0 end
    else
        if _Il10O__FD then
            _0_OOOl_91.Brightness = _Il10O__FD.Brightness
            _0_OOOl_91.ClockTime = _Il10O__FD.ClockTime
            _0_OOOl_91.Ambient = _Il10O__FD.Ambient
            _0_OOOl_91.OutdoorAmbient = _Il10O__FD.OutdoorAmbient
            _0_OOOl_91.GlobalShadows = _Il10O__FD.GlobalShadows
            _0_OOOl_91.FogStart = _Il10O__FD.FogStart
            _0_OOOl_91.FogEnd = _Il10O__FD.FogEnd
        end
        if _011_1__D6 then
            local _l_0Ill_1 = _0_OOOl_91:FindFirstChildOfClass(_D("6C9F989A9E9B93909D90"))
            if _l_0Ill_1 then _l_0Ill_1.Density = _011_1__D6.Density; _l_0Ill_1.Haze = _011_1__D6.Haze; _l_0Ill_1.Color = _011_1__D6.Color end
        end
    end
end

local function _l11I1l_F4(state)
    _lII_O__BB = state and true or false
    local _01I1_O_17 = _0_OOOl_91:FindFirstChildOfClass(_D("6C9F989A9E9B93909D90"))
    if _lII_O__BB then
        _0_OOOl_91.FogStart = 0
        _0_OOOl_91.FogEnd = 1e6
        if _01I1_O_17 then _01I1_O_17.Density = 0; _01I1_O_17.Haze = 0 end
    else
        if not _1l000O_CB and _Il10O__FD then
            _0_OOOl_91.FogStart = _Il10O__FD.FogStart
            _0_OOOl_91.FogEnd = _Il10O__FD.FogEnd
            if _011_1__D6 then
                local _l_0Ill_1 = _0_OOOl_91:FindFirstChildOfClass(_D("6C9F989A9E9B93909D90"))
                if _l_0Ill_1 then _l_0Ill_1.Density = _011_1__D6.Density; _l_0Ill_1.Haze = _011_1__D6.Haze end
            end
        end
    end
end

local function _1I_0_1_6E(_lIOOl1_5C)
    _1__OO1_C9 = _lIOOl1_5C
    local __OlOIl_1A = workspace.CurrentCamera
    if __OlOIl_1A then __OlOIl_1A.FieldOfView = _1__OO1_C9 end
end


local __OO0Ol_77
local _OOl10O_DF



local _Il10I0_73 = _D("74999E9F8C999F")
local _111I1O_FF = 1.0
local _lO0l0l_CA = {
    {_D("7CA08C8F7AA09F"),  Enum.EasingStyle.Quad,    Enum.EasingDirection.Out},
    {_D("7CA08C8F7499"),   Enum.EasingStyle.Quad,    Enum.EasingDirection.In},
    {_D("7E9499907AA09F"),  Enum.EasingStyle.Sine,    Enum.EasingDirection.Out},
    {_D("779499908C9D"),   Enum.EasingStyle.Linear,  Enum.EasingDirection.InOut},
    {_D("6D8C8E967AA09F"),  Enum.EasingStyle.Back,    Enum.EasingDirection.Out},
    {_D("6EA08D948E7AA09F"), Enum.EasingStyle.Cubic,   Enum.EasingDirection.Out},
}
local _1lIl0l_7D = 1
local _I0_1OI_E8 = false
local function _1lOO0l_10F(_I0llIO_35)
    if not root then return end
    if _Il10I0_73 == _D("74999E9F8C999F") then
        root.CFrame = CFrame.new(_I0llIO_35)
        return
    end
    if _I0_1OI_E8 then return end
    _I0_1OI_E8 = true
    local _1IIl10_75 = _OO00I__1E
    if _1IIl10_75 then _llOlO__6F(false) end
    local _1_1I0l_39 = TweenInfo.new(
        math.max(0.05, _111I1O_FF),
        _lO0l0l_CA[_1lIl0l_7D][2],
        _lO0l0l_CA[_1lIl0l_7D][3],
        0,false,0
    )
    local _l0O_1O_15 = _Ill110_EA:Create(root, _1_1I0l_39, {CFrame = CFrame.new(_I0llIO_35)})
    _l0O_1O_15:Play()
    _l0O_1O_15.Completed:Connect(function()
        _I0_1OI_E8 = false
        if _1IIl10_75 then _llOlO__6F(true) end
    end)
end

local function _OllI0O_114(_I0llIO_35)
    if not root then return end
    if _Il10I0_73 == _D("74999E9F8C999F") then
        root.CFrame = CFrame.new(_I0llIO_35)
        return
    end

    local _1IIl10_75 = _OO00I__1E
    if _1IIl10_75 then _llOlO__6F(false) end
    local _1_1I0l_39 = TweenInfo.new(
        math.max(0.05, _111I1O_FF),
        _lO0l0l_CA[_1lIl0l_7D][2],
        _lO0l0l_CA[_1lIl0l_7D][3],
        0,false,0
    )
    local _l0O_1O_15 = _Ill110_EA:Create(root, _1_1I0l_39, {CFrame = CFrame.new(_I0llIO_35)})
    _l0O_1O_15:Play()
    
    pcall(function() _l0O_1O_15.Completed:Wait() end)
    if _1IIl10_75 then _llOlO__6F(true) end
end

local function _O1_1ll_9D()
    if _OOl10O_DF then _OOl10O_DF:Destroy() end
    local __IOO11_A7 = __1O__0_DD:WaitForChild(_D("7B978CA4909D72A094"))
    local _l0000O_12 = Instance.new(_D("7E8E9D90909972A094"))
    _l0000O_12.Name = _D("7BA09E9499927B949797")
    _l0000O_12.ResetOnSpawn = false
    _l0000O_12.IgnoreGuiInset = true
    _l0000O_12.Parent = __IOO11_A7

    local _0lIO0l_19 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _0lIO0l_19.Size = UDim2.fromOffset(160, 46)
    _0lIO0l_19.Position = UDim2.new(0, 20, 0, 80)
    _0lIO0l_19.BackgroundColor3 = Color3.fromRGB(40,40,48)
    _0lIO0l_19.TextColor3 = Color3.fromRGB(230,230,240)
    _0lIO0l_19.Text = _D("7E939AA24B7BA09E949992")
    _0lIO0l_19.Font = Enum.Font.GothamBold
    _0lIO0l_19.TextSize = 20
    _0lIO0l_19.BorderSizePixel = 0
    _0lIO0l_19.Parent = _l0000O_12
    Instance.new(_D("80746E9A9D99909D"), _0lIO0l_19).CornerRadius = UDim.new(1,0)

    _0lIO0l_19.MouseButton1Click:Connect(function()
        if __OO0Ol_77 then __OO0Ol_77.Enabled = true end
        if _OOl10O_DF then _OOl10O_DF:Destroy() _OOl10O_DF=nil end
    end)

    _OOl10O_DF = _l0000O_12
end

local function _1__01l_98()
    local __IOO11_A7 = __1O__0_DD:WaitForChild(_D("7B978CA4909D72A094"))

    
    local _I_l00O_85 = Instance.new(_D("7E8E9D90909972A094"))
    _I_l00O_85.Name = _D("7BA09E9499928D8C9F779A8C8F949992")
    _I_l00O_85.ResetOnSpawn = false
    _I_l00O_85.IgnoreGuiInset = true
    _I_l00O_85.Parent = __IOO11_A7

    local __llll1_1C = Instance.new(_D("719D8C9890"))
    __llll1_1C.Size = UDim2.fromScale(1,1)
    __llll1_1C.BackgroundColor3 = Color3.new(0,0,0)
    __llll1_1C.BackgroundTransparency = 0.5
    __llll1_1C.BorderSizePixel = 0
    __llll1_1C.Parent = _I_l00O_85

    local _OI1l0l_72 = Instance.new(_D("719D8C9890"))
    _OI1l0l_72.AnchorPoint = Vector2.new(0.5,0.5)
    _OI1l0l_72.Position = UDim2.fromScale(0.5,0.5)
    _OI1l0l_72.Size = UDim2.fromOffset(520,100)
    _OI1l0l_72.BackgroundColor3 = Color3.fromRGB(0,0,0)
    _OI1l0l_72.BackgroundTransparency = 0.5
    _OI1l0l_72.BorderSizePixel = 0
    _OI1l0l_72.Parent = _I_l00O_85
    Instance.new(_D("80746E9A9D99909D"), _OI1l0l_72).CornerRadius = UDim.new(0,18)

    local _I_0__O_46 = Instance.new(_D("7F90A39F778C8D9097"))
    _I_0__O_46.Size = UDim2.fromScale(1,1)
    _I_0__O_46.BackgroundTransparency = 1
    _I_0__O_46.Text = _D("6E9D908C9F908F4B8DA44B7BA09E9499928D8C9F")
    _I_0__O_46.Font = Enum.Font.GothamBlack
    _I_0__O_46.TextSize = 42
    _I_0__O_46.TextColor3 = Color3.fromRGB(255,255,255)
    _I_0__O_46.Parent = _OI1l0l_72

    
    if __OO0Ol_77 then __OO0Ol_77:Destroy() end
    __OO0Ol_77 = Instance.new(_D("7E8E9D90909972A094"))
    __OO0Ol_77.Name = _D("7BA09E9499928D8C9F6E9A999F9D9A9797909D")
    __OO0Ol_77.ResetOnSpawn = false
    __OO0Ol_77.IgnoreGuiInset = true
    __OO0Ol_77.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    __OO0Ol_77.Parent = __IOO11_A7
    __OO0Ol_77.Enabled = false

    local _IlII_0_4F = Instance.new(_D("719D8C9890"))
    _IlII_0_4F.Name = _D("788C9499719D8C9890")
    _IlII_0_4F.Size = UDim2.fromOffset(420, 360)
    _IlII_0_4F.Position = UDim2.new(0, 24, 0, 120)
    _IlII_0_4F.BackgroundColor3 = Color3.fromRGB(30,30,30)
    _IlII_0_4F.BackgroundTransparency = 0.15
    _IlII_0_4F.BorderSizePixel = 0
    _IlII_0_4F.Active = true
    _IlII_0_4F.ClipsDescendants = true
    _IlII_0_4F.Parent = __OO0Ol_77
    Instance.new(_D("80746E9A9D99909D"), _IlII_0_4F).CornerRadius = UDim.new(0, 12)

    
    local ___IOOI_67 = Instance.new(_D("719D8C9890"))
    ___IOOI_67.Size = UDim2.new(1, 0, 0, 40)
    ___IOOI_67.BackgroundTransparency = 1
    ___IOOI_67.Parent = _IlII_0_4F

    local _O10I0__5A = Instance.new(_D("7F90A39F778C8D9097"))
    _O10I0__5A.BackgroundTransparency = 1
    _O10I0__5A.Size = UDim2.new(1, -220, 1, 0)
    _O10I0__5A.Position = UDim2.new(0, 10, 0, 0)
    _O10I0__5A.Font = Enum.Font.GothamBold
    _O10I0__5A.TextSize = 18
    _O10I0__5A.TextXAlignment = Enum.TextXAlignment.Left
    _O10I0__5A.TextColor3 = Color3.fromRGB(255,255,255)
    _O10I0__5A.Text = _D("6E9D908C9F908F4B8DA44B9BA09E9499928D8C9F")
    _O10I0__5A.Parent = ___IOOI_67

    local __l1O_1_BD = Instance.new(_D("74988C92906DA09F9F9A99"))
    __l1O_1_BD.Size = UDim2.fromOffset(26, 26)
    __l1O_1_BD.Position = UDim2.new(1, -96, 0.5, -13)
    __l1O_1_BD.BackgroundTransparency = 1
    __l1O_1_BD.Image = _D("9D8DA38C9E9E909F948F655A5A615B5E5C5B6260645E63")
    __l1O_1_BD.ImageColor3 = Color3.fromRGB(220,220,220)
    __l1O_1_BD.Parent = ___IOOI_67

    local _1Ol_IO_5F = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _1Ol_IO_5F.Size = UDim2.fromOffset(26, 26)
    _1Ol_IO_5F.Position = UDim2.new(1, -64, 0.5, -13)
    _1Ol_IO_5F.Text = _D("0DABBE")
    _1Ol_IO_5F.Font = Enum.Font.GothamBlack
    _1Ol_IO_5F.TextSize = 18
    _1Ol_IO_5F.TextColor3 = Color3.fromRGB(255,255,255)
    _1Ol_IO_5F.BackgroundColor3 = Color3.fromRGB(70,70,80)
    _1Ol_IO_5F.BorderSizePixel = 0
    _1Ol_IO_5F.Parent = ___IOOI_67
    Instance.new(_D("80746E9A9D99909D"), _1Ol_IO_5F).CornerRadius = UDim.new(1,0)

    local __ll_I1_95 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    __ll_I1_95.Size = UDim2.fromOffset(26, 26)
    __ll_I1_95.Position = UDim2.new(1, -32, 0.5, -13)
    __ll_I1_95.Text = _D("A3")
    __ll_I1_95.Font = Enum.Font.GothamBlack
    __ll_I1_95.TextSize = 16
    __ll_I1_95.TextColor3 = Color3.fromRGB(255,255,255)
    __ll_I1_95.BackgroundColor3 = Color3.fromRGB(90,50,50)
    __ll_I1_95.BorderSizePixel = 0
    __ll_I1_95.Parent = ___IOOI_67
    Instance.new(_D("80746E9A9D99909D"), __ll_I1_95).CornerRadius = UDim.new(1,0)

    
    local _l1O_O__E7 = Instance.new(_D("719D8C9890"))
    _l1O_O__E7.Size = UDim2.fromOffset(220, 36)
    _l1O_O__E7.Position = UDim2.new(1, -346, 0, 42)
    _l1O_O__E7.BackgroundColor3 = Color3.fromRGB(45,45,50)
    _l1O_O__E7.Visible = false
    _l1O_O__E7.Parent = _IlII_0_4F
    Instance.new(_D("80746E9A9D99909D"), _l1O_O__E7).CornerRadius = UDim.new(0, 8)

    local _1_0OOI_BC = Instance.new(_D("7F90A39F6D9AA3"))
    _1_0OOI_BC.Size = UDim2.new(1, -12, 1, -12)
    _1_0OOI_BC.Position = UDim2.new(0, 6, 0, 6)
    _1_0OOI_BC.BackgroundColor3 = Color3.fromRGB(55,55,60)
    _1_0OOI_BC.PlaceholderText = _D("7E908C9D8E934B91908C9FA09D90")
    _1_0OOI_BC.Text = _D("")
    _1_0OOI_BC.Font = Enum.Font.Gotham
    _1_0OOI_BC.TextSize = 14
    _1_0OOI_BC.TextColor3 = Color3.fromRGB(230,230,230)
    _1_0OOI_BC.ClearTextOnFocus = false
    _1_0OOI_BC.Parent = _l1O_O__E7
    Instance.new(_D("80746E9A9D99909D"), _1_0OOI_BC).CornerRadius = UDim.new(0, 6)

    __l1O_1_BD.MouseButton1Click:Connect(function()
        _l1O_O__E7.Visible = not _l1O_O__E7.Visible
        if _l1O_O__E7.Visible then _1_0OOI_BC:CaptureFocus() end
    end)

    
    local _0I__10_36 = Instance.new(_D("719D8C9890"))
    _0I__10_36.BackgroundTransparency = 1
    _0I__10_36.Size = UDim2.new(1, -240, 1, 0)
    _0I__10_36.Position = UDim2.new(0, 0, 0, 0)
    _0I__10_36.Parent = ___IOOI_67

    
    local _10llOI_45 = Instance.new(_D("719D8C9890"))
    _10llOI_45.Size = UDim2.new(1, -16, 0, 30)
    _10llOI_45.Position = UDim2.new(0, 8, 0, 44)
    _10llOI_45.BackgroundTransparency = 1
    _10llOI_45.Parent = _IlII_0_4F

    local function _l_lO_1_FA(_I_0__O_46, xOffset)
        local __1O_lO_2 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
        __1O_lO_2.Size = UDim2.fromOffset(100, 28)
        __1O_lO_2.Position = UDim2.new(0, xOffset, 0, 0)
        __1O_lO_2.BackgroundColor3 = Color3.fromRGB(45,45,50)
        __1O_lO_2.TextColor3 = Color3.fromRGB(230,230,230)
        __1O_lO_2.Text = _I_0__O_46
        __1O_lO_2.Font = Enum.Font.GothamBold
        __1O_lO_2.TextSize = 14
        __1O_lO_2.BorderSizePixel = 0
        __1O_lO_2.Parent = _10llOI_45
        Instance.new(_D("80746E9A9D99909D"), __1O_lO_2).CornerRadius = UDim.new(1,0)
        return __1O_lO_2
    end

    local _001_IO_D9 = _l_lO_1_FA(_D("788C9499"), 0)
    local _IOOIlO_DA = _l_lO_1_FA(_D("78949E8E"), 108)
    local _10O100_A0   = _l_lO_1_FA(_D("7F9097909B9A9D9F"), 216)
    local __10O10_C1  = _l_lO_1_FA(_D("6E9A99919492"), 324)

    
    local function __IIlIO_CF()
        local _1_IOl1_6D = Instance.new(_D("7E8E9D9A9797949992719D8C9890"))
        _1_IOl1_6D.Size = UDim2.new(1, -16, 1, -88)
        _1_IOl1_6D.Position = UDim2.new(0, 8, 0, 78)
        _1_IOl1_6D.BackgroundTransparency = 1
        _1_IOl1_6D.BorderSizePixel = 0
        _1_IOl1_6D.CanvasSize = UDim2.new(0,0,0,0)
        _1_IOl1_6D.ScrollBarThickness = 6
        _1_IOl1_6D.Visible = false
        _1_IOl1_6D.ClipsDescendants = true
        _1_IOl1_6D.AutomaticCanvasSize = Enum.AutomaticSize.None
        _1_IOl1_6D.Parent = _IlII_0_4F

        local _0lO0O__68 = Instance.new(_D("807477949E9F778CA49AA09F"))
        _0lO0O__68.FillDirection = Enum.FillDirection.Vertical
        _0lO0O__68.Padding = UDim.new(0, 8)
        _0lO0O__68.SortOrder = Enum.SortOrder.LayoutOrder
        _0lO0O__68.Parent = _1_IOl1_6D

        local __0ll10_23 = Instance.new(_D("80747B8C8F8F949992"))
        __0ll10_23.PaddingTop = UDim.new(0, 6)
        __0ll10_23.PaddingBottom = UDim.new(0, 12)
        __0ll10_23.PaddingLeft = UDim.new(0, 4)
        __0ll10_23.PaddingRight = UDim.new(0, 4)
        __0ll10_23.Parent = _1_IOl1_6D

        local function _I1OI01_6B()
            _1_IOl1_6D.CanvasSize = UDim2.new(0,0,0, _0lO0O__68.AbsoluteContentSize.Y + __0ll10_23.PaddingBottom.Offset)
        end
        _0lO0O__68:GetPropertyChangedSignal(_D("6C8D9E9A97A09F906E9A999F90999F7E94A590")):Connect(_I1OI01_6B)
        return _1_IOl1_6D, _0lO0O__68, _I1OI01_6B
    end

    local _lIOOll_CE, _, recalcMain = __IIlIO_CF()
    local _Ol_0lO_D2, _, recalcMisc = __IIlIO_CF()
    local _01IlOl_A3, _, recalcTp = __IIlIO_CF()
    local _Il__lO_AA, _, recalcCfg = __IIlIO_CF()

    local function _l_1____AC(parent, height)
        local _II0Il__2B = Instance.new(_D("719D8C9890"))
        _II0Il__2B.Size = UDim2.new(1, 0, 0, height)
        _II0Il__2B.BackgroundColor3 = Color3.fromRGB(38,38,42)
        _II0Il__2B.BackgroundTransparency = 0.2
        _II0Il__2B.BorderSizePixel = 0
        _II0Il__2B.Parent = parent
        Instance.new(_D("80746E9A9D99909D"), _II0Il__2B).CornerRadius = UDim.new(0, 8)
        return _II0Il__2B
    end

    local function _10OI0__D1(parent, labelText, initial, callback)
        local _II0Il__2B = _l_1____AC(parent, 40)
        local _OI01O0_21 = Instance.new(_D("7F90A39F778C8D9097"))
        _OI01O0_21.BackgroundTransparency = 1
        _OI01O0_21.Size = UDim2.new(1, -120, 1, 0)
        _OI01O0_21.Position = UDim2.new(0, 10, 0, 0)
        _OI01O0_21.Font = Enum.Font.Gotham
        _OI01O0_21.TextSize = 16
        _OI01O0_21.TextXAlignment = Enum.TextXAlignment.Left
        _OI01O0_21.TextColor3 = Color3.fromRGB(235,235,235)
        _OI01O0_21.Text = labelText
        _OI01O0_21.Parent = _II0Il__2B

        local _011_l0_70 = Instance.new(_D("719D8C9890"))
        _011_l0_70.Size = UDim2.fromOffset(58, 24)
        _011_l0_70.Position = UDim2.new(1, -70, 0.5, -12)
        _011_l0_70.BackgroundColor3 = initial and Color3.fromRGB(60,180,75) or Color3.fromRGB(120,120,120)
        _011_l0_70.BorderSizePixel = 0
        _011_l0_70.Parent = _II0Il__2B
        Instance.new(_D("80746E9A9D99909D"), _011_l0_70).CornerRadius = UDim.new(1,0)

        local _lI0I_I_3C = Instance.new(_D("719D8C9890"))
        _lI0I_I_3C.Size = UDim2.fromOffset(20,20)
        _lI0I_I_3C.Position = initial and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10)
        _lI0I_I_3C.BackgroundColor3 = Color3.fromRGB(255,255,255)
        _lI0I_I_3C.BorderSizePixel = 0
        _lI0I_I_3C.Parent = _011_l0_70
        Instance.new(_D("80746E9A9D99909D"), _lI0I_I_3C).CornerRadius = UDim.new(1,0)

        local _lIOOl1_5C = initial
        local function _10ll10_6C()
            _011_l0_70.BackgroundColor3 = _lIOOl1_5C and Color3.fromRGB(60,180,75) or Color3.fromRGB(120,120,120)
            _lI0I_I_3C:TweenPosition(_lIOOl1_5C and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
        end
        _011_l0_70.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                _lIOOl1_5C = not _lIOOl1_5C
                _10ll10_6C()
                if callback then task.spawn(callback, _lIOOl1_5C) end
            end
        end)

        _II0Il__2B:SetAttribute(_D("978C8D9097"), labelText)
        return {Row=_II0Il__2B, Set=function(__IlIO__A) _lIOOl1_5C=__IlIO__A and true or false; _10ll10_6C(); if callback then task.spawn(callback, _lIOOl1_5C) end end}
    end

    local function _01111I_D0(parent, labelText, minV, maxV, initial, callback)
        local _II0Il__2B = _l_1____AC(parent, 58)
        local _OI01O0_21 = Instance.new(_D("7F90A39F778C8D9097"))
        _OI01O0_21.BackgroundTransparency = 1
        _OI01O0_21.Size = UDim2.new(1, 0, 0, 20)
        _OI01O0_21.Position = UDim2.new(0, 10, 0, 6)
        _OI01O0_21.Font = Enum.Font.Gotham
        _OI01O0_21.TextSize = 16
        _OI01O0_21.TextXAlignment = Enum.TextXAlignment.Left
        _OI01O0_21.TextColor3 = Color3.fromRGB(235,235,235)
        _OI01O0_21.Text = string.format(_D("509E654B508F"), labelText, initial)
        _OI01O0_21.Parent = _II0Il__2B

        local _O_0l0O_18 = Instance.new(_D("719D8C9890"))
        _O_0l0O_18.Size = UDim2.new(1, -20, 0, 8)
        _O_0l0O_18.Position = UDim2.new(0, 10, 0, 34)
        _O_0l0O_18.BackgroundColor3 = Color3.fromRGB(60,60,60)
        _O_0l0O_18.BorderSizePixel = 0
        _O_0l0O_18.Parent = _II0Il__2B
        Instance.new(_D("80746E9A9D99909D"), _O_0l0O_18).CornerRadius = UDim.new(0,8)

        local __O_01l_42 = (initial - minV) / (maxV - minV)
        local _OOO_l0_38 = Instance.new(_D("719D8C9890"))
        _OOO_l0_38.Size = UDim2.new(__O_01l_42, 0, 1, 0)
        _OOO_l0_38.BackgroundColor3 = Color3.fromRGB(0,170,255)
        _OOO_l0_38.BorderSizePixel = 0
        _OOO_l0_38.Parent = _O_0l0O_18
        Instance.new(_D("80746E9A9D99909D"), _OOO_l0_38).CornerRadius = UDim.new(0,8)

        local _lI0I_I_3C = Instance.new(_D("719D8C9890"))
        _lI0I_I_3C.Size = UDim2.fromOffset(18,18)
        _lI0I_I_3C.Position = UDim2.new(__O_01l_42, -9, 0.5, -9)
        _lI0I_I_3C.BackgroundColor3 = Color3.fromRGB(240,240,240)
        _lI0I_I_3C.BorderSizePixel = 0
        _lI0I_I_3C.Parent = _O_0l0O_18
        Instance.new(_D("80746E9A9D99909D"), _lI0I_I_3C).CornerRadius = UDim.new(1,0)

        local _l100___99 = false
        local function _1_l0II_D8(_1IlOO0_24)
            _1IlOO0_24 = math.clamp(_1IlOO0_24, 0, 1)
            local ___O1lO_2D = math.floor(minV + (maxV - minV) * _1IlOO0_24 + 0.5)
            _OOO_l0_38.Size = UDim2.new(_1IlOO0_24, 0, 1, 0)
            _lI0I_I_3C.Position = UDim2.new(_1IlOO0_24, -9, 0.5, -9)
            _OI01O0_21.Text = string.format(_D("509E654B508F"), labelText, ___O1lO_2D)
            if callback then callback(___O1lO_2D) end
        end

        _O_0l0O_18.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                _l100___99 = true
                local _II1OOl_28 = (input.Position.X - _O_0l0O_18.AbsolutePosition.X) / _O_0l0O_18.AbsoluteSize.X
                _1_l0II_D8(_II1OOl_28)
            end
        end)
        _OOl1_O_16.InputChanged:Connect(function(input)
            if _l100___99 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local _II1OOl_28 = (input.Position.X - _O_0l0O_18.AbsolutePosition.X) / _O_0l0O_18.AbsoluteSize.X
                _1_l0II_D8(_II1OOl_28)
            end
        end)
        _O_0l0O_18.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                _l100___99 = false
            end
        end)

        _II0Il__2B:SetAttribute(_D("978C8D9097"), labelText)
        return {Row=_II0Il__2B, Set=function(__IlIO__A) local _1IlOO0_24=(math.clamp(__IlIO__A,minV,maxV)-minV)/(maxV-minV); _1_l0II_D8(_1IlOO0_24) end}
    end


    local _1_Ol11_4D = _10OI0__D1(_lIOOll_CE, _D("7197A4"), false, function(__IlIO__A) _llOlO__6F(__IlIO__A) end)
    local _O0l0___41  = _10OI0__D1(_lIOOll_CE, _D("799A6E97949B4B539F90988DA09E54"), false, function(__IlIO__A) _OII_IO_BF(__IlIO__A) end)
    local _O_I0lI_47  = _01111I_D0(_lIOOll_CE, _D("828C97964B7E9B90908F4B539E9FA08F9E54"), __1l_OO_93, MAX_WALK, ___11_0_C3, function(__IlIO__A) ___11_0_C3 = __IlIO__A; __O__II_F8() end)
    local _O__O0I_3B  = _01111I_D0(_lIOOll_CE, _D("75A0989B4B7B9AA2909D4B539E9FA08F9E54"), _001lIO_92, MAX_JUMP, _I1100I_B5, function(__IlIO__A) _I1100I_B5 = __IlIO__A; __O__II_F8() end)
    local _lIlO_I_52 = _10OI0__D1(_lIOOll_CE, _D("7499914B75A0989B4B53789A8D94979054"), false, function(__IlIO__A) _1OII0__F9 = __IlIO__A end)
    local _lll0Il_53 = _10OI0__D1(_lIOOll_CE, _D("7499914B75A0989B4B537B6E54"), false, function(__IlIO__A) _O__00__B4 = __IlIO__A end)
    local _OlI0I__56 = _10OI0__D1(_lIOOll_CE, _D("799A4B718C97974B6F8C988C9290"), false, function(__IlIO__A) _O_O0l0_F0 = __IlIO__A end)

    
    local _1O10II_37  = _10OI0__D1(_Ol_0lO_D2, _D("71A097978D9D9492939F4B537F909D8C99924B7F909DA09E54"), false, function(__IlIO__A) _1OI0I__FE(__IlIO__A) end)
    local _001l0l_4E = _01111I_D0(_Ol_0lO_D2, _D("719490978F4B9A914B819490A2"), 60, 120, _1__OO1_C9, function(__IlIO__A) _1I_0_1_6E(__IlIO__A) end)
    local _l__0IO_43  = _10OI0__D1(_Ol_0lO_D2, _D("7D90989AA1904B719A92"), false, function(__IlIO__A) _l11I1l_F4(__IlIO__A) end)

    
    local function _0llOOI_E1(_1__0lI_6) 
        return _l_1____AC(_01IlOl_A3, _1__0lI_6) 
    end

    
    local _1IO_01_A2 = {}  

    local function _0ll1lI_8A(_OO10O1_3D)
        _1IO_01_A2 = _OO10O1_3D or {}
    end
    
    
    
    local _0I_I0__107 = _0llOOI_E1(28)
    _0I_I0__107.BackgroundTransparency = 1
    local _l1OI0I_C2 = Instance.new(_D("7F90A39F778C8D9097"))
    _l1OI0I_C2.BackgroundTransparency = 1
    _l1OI0I_C2.Size = UDim2.new(1, -20, 1, 0)
    _l1OI0I_C2.Position = UDim2.new(0,10,0,0)
    _l1OI0I_C2.Text = _D("7F9097909B9A9D9F4B9F9A4B7B978CA4909D")
    _l1OI0I_C2.TextColor3 = Color3.new(1,1,1)
    _l1OI0I_C2.TextXAlignment = Enum.TextXAlignment.Left
    _l1OI0I_C2.Font = Enum.Font.GothamBold
    _l1OI0I_C2.TextSize = 14
    _l1OI0I_C2.Parent = _0I_I0__107

    local _IO0I_I_BA = _0llOOI_E1(56)
    _IO0I_I_BA:SetAttribute(_D("978C8D9097"),_D("7F9097909B9A9D9F4B9F9A4B7B978CA4909D"))

    local _I0_O0I_FC = Instance.new(_D("7F90A39F778C8D9097"))
    _I0_O0I_FC.BackgroundTransparency = 1
    _I0_O0I_FC.Size = UDim2.new(1, -140, 0.5, -2)
    _I0_O0I_FC.Position = UDim2.new(0, 10, 0, 4)
    _I0_O0I_FC.Text = _D("7F8C9D92909F654B538D9097A0984B8F949B9497949354")
    _I0_O0I_FC.TextColor3 = Color3.fromRGB(235,235,235)
    _I0_O0I_FC.TextXAlignment = Enum.TextXAlignment.Left
    _I0_O0I_FC.Font = Enum.Font.Gotham
    _I0_O0I_FC.TextSize = 15
    _I0_O0I_FC.Parent = _IO0I_I_BA

    local _01Il1O_E3 = Instance.new(_D("7F90A39F778C8D9097"))
    _01Il1O_E3.BackgroundTransparency = 1
    _01Il1O_E3.Size = UDim2.new(1, -140, 0.5, -2)
    _01Il1O_E3.Position = UDim2.new(0, 10, 0.5, 0)
    _01Il1O_E3.Text = _D("6F949E9F8C998E90654B58")
    _01Il1O_E3.TextColor3 = Color3.fromRGB(200,200,200)
    _01Il1O_E3.TextXAlignment = Enum.TextXAlignment.Left
    _01Il1O_E3.Font = Enum.Font.Gotham
    _01Il1O_E3.TextSize = 13
    _01Il1O_E3.Parent = _IO0I_I_BA

    local _1l_1_O_86 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _1l_1_O_86.Size = UDim2.new(0, 100, 0, 26)
    _1l_1_O_86.Position = UDim2.new(1, -120, 0, 6)
    _1l_1_O_86.Text = _D("7B949794934B7B978CA4909D")
    _1l_1_O_86.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
    _1l_1_O_86.TextColor3 = Color3.new(1,1,1)
    _1l_1_O_86.BorderSizePixel = 0
    _1l_1_O_86.Parent = _IO0I_I_BA
    Instance.new(_D("80746E9A9D99909D"), _1l_1_O_86).CornerRadius = UDim.new(0,6)

    local _O_I0___D5 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _O_I0___D5.Size = UDim2.new(0, 100, 0, 26)
    _O_I0___D5.Position = UDim2.new(1, -120, 0, 30)
    _O_I0___D5.Text = _D("7D90919D909E93")
    _O_I0___D5.BackgroundColor3 = Color3.fromRGB(60,60,70)
    _O_I0___D5.TextColor3 = Color3.new(1,1,1)
    _O_I0___D5.BorderSizePixel = 0
    _O_I0___D5.Parent = _IO0I_I_BA
    Instance.new(_D("80746E9A9D99909D"), _O_I0___D5).CornerRadius = UDim.new(0,6)

    local _IIl10O_10E = nil
    local function _IIlO0l_106()
        local _0I0O0l_11 = __1O__0_DD:WaitForChild(_D("7B978CA4909D72A094"))
        local _1ll0I0_26 = Instance.new(_D("7E8E9D90909972A094"))
        _1ll0I0_26.Name = _D("7B6D8A7B978CA4909D7B948E96909D")
        _1ll0I0_26.ResetOnSpawn = false
        _1ll0I0_26.Parent = _0I0O0l_11

        local _OOOll0_4 = Instance.new(_D("719D8C9890"))
        _OOOll0_4.Size = UDim2.fromOffset(300, 320)
        _OOOll0_4.Position = UDim2.new(0.5, -150, 0.5, -160)
        _OOOll0_4.BackgroundColor3 = Color3.fromRGB(45,45,50)
        _OOOll0_4.BorderSizePixel = 0
        _OOOll0_4.Parent = _1ll0I0_26
        _OOOll0_4.ClipsDescendants = true
        Instance.new(_D("80746E9A9D99909D"), _OOOll0_4).CornerRadius = UDim.new(0, 10)

        local _O10I0__5A = Instance.new(_D("7F90A39F778C8D9097"))
        _O10I0__5A.Size = UDim2.new(1, -12, 0, 30)
        _O10I0__5A.Position = UDim2.new(0,6,0,6)
        _O10I0__5A.BackgroundColor3 = Color3.fromRGB(70,70,70)
        _O10I0__5A.Text = _D("7B949794934B7B978CA4909D")
        _O10I0__5A.TextColor3 = Color3.new(1,1,1)
        _O10I0__5A.Font = Enum.Font.GothamBold
        _O10I0__5A.TextSize = 14
        _O10I0__5A.Parent = _OOOll0_4
        Instance.new(_D("80746E9A9D99909D"), _O10I0__5A).CornerRadius = UDim.new(0,6)

        local _OO10O1_3D = Instance.new(_D("7E8E9D9A9797949992719D8C9890"))
        _OO10O1_3D.Size = UDim2.new(1, -12, 1, -80)
        _OO10O1_3D.Position = UDim2.new(0,6,0,42)
        _OO10O1_3D.BackgroundTransparency = 1
        _OO10O1_3D.ScrollBarThickness = 6
        _OO10O1_3D.ClipsDescendants = true
        _OO10O1_3D.Parent = _OOOll0_4
        local _1OlOOI_20 = Instance.new(_D("807477949E9F778CA49AA09F"))
        _1OlOOI_20.Padding = UDim.new(0,6)
        _1OlOOI_20.Parent = _OO10O1_3D

        local _O_l011_4A = Instance.new(_D("7F90A39F6DA09F9F9A99"))
        _O_l011_4A.Size = UDim2.new(1, -12, 0, 30)
        _O_l011_4A.Position = UDim2.new(0,6,1,-36)
        _O_l011_4A.Text = _D("7FA09FA09B")
        _O_l011_4A.BackgroundColor3 = Color3.fromRGB(90,60,60)
        _O_l011_4A.TextColor3 = Color3.new(1,1,1)
        _O_l011_4A.Parent = _OOOll0_4
        Instance.new(_D("80746E9A9D99909D"), _O_l011_4A).CornerRadius = UDim.new(0,6)

        local function __OI1OI_49()
            for _,ch in ipairs(_OO10O1_3D:GetChildren()) do
                if ch:IsA(_D("7F90A39F6DA09F9F9A99")) then ch:Destroy() end
            end
            for _,_0I01l__25 in ipairs(_O11IlI_78:GetPlayers()) do
                if _0I01l__25 ~= __1O__0_DD then
                    local __1O_lO_2 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
                    __1O_lO_2.Size = UDim2.new(1, -4, 0, 28)
                    __1O_lO_2.Text = _0I01l__25.Name
                    __1O_lO_2.BackgroundColor3 = Color3.fromRGB(60,60,70)
                    __1O_lO_2.TextColor3 = Color3.new(1,1,1)
                    __1O_lO_2.Parent = _OO10O1_3D
                    Instance.new(_D("80746E9A9D99909D"), __1O_lO_2).CornerRadius = UDim.new(0,6)
                    __1O_lO_2.MouseButton1Click:Connect(function()
                        _IIl10O_10E = _0I01l__25.Name
                        _I0_O0I_FC.Text = _D("7F8C9D92909F654B").._IIl10O_10E
                        _1ll0I0_26:Destroy()
                    end)
                end
            end
        end
        __OI1OI_49()
        _O_l011_4A.MouseButton1Click:Connect(function() _1ll0I0_26:Destroy() end)
    end

    _1l_1_O_86.MouseButton1Click:Connect(_IIlO0l_106)
    _O_I0___D5.MouseButton1Click:Connect(function()
        if _IIl10O_10E then
            _I0_O0I_FC.Text = _D("7F8C9D92909F654B").._IIl10O_10E
        end
    end)

    _ll__OO_C4.RenderStepped:Connect(function()
        if not _01IlOl_A3.Visible then return end
        if _IIl10O_10E and root then
            local _0OI0I1_71 = _O11IlI_78:FindFirstChild(_IIl10O_10E)
            if _0OI0I1_71 and _0OI0I1_71.Character and _0OI0I1_71.Character:FindFirstChild(_D("73A0988C999A948F7D9A9A9F7B8C9D9F")) then
                local _0Ol00I_3 = (root.Position - _0OI0I1_71.Character.HumanoidRootPart.Position).Magnitude
                _01Il1O_E3.Text = string.format(_D("6F949E9F8C998E90654B50595C914B9E9FA08F9E"), _0Ol00I_3)
            else
                _01Il1O_E3.Text = _D("6F949E9F8C998E90654B58")
            end
        else
            _01Il1O_E3.Text = _D("6F949E9F8C998E90654B58")
        end
    end)

    
    local _00llI0_82 = _0llOOI_E1(40)
    local _IllIO0_81 = Instance.new(_D("7F90A39F778C8D9097"))
    _IllIO0_81.BackgroundTransparency = 1
    _IllIO0_81.Size = UDim2.new(1, -140, 1, 0)
    _IllIO0_81.Position = UDim2.new(0,10,0,0)
    _IllIO0_81.Text = _D("789A8F904B7F9097909B9A9D9F")
    _IllIO0_81.TextColor3 = Color3.fromRGB(235,235,235)
    _IllIO0_81.TextXAlignment = Enum.TextXAlignment.Left
    _IllIO0_81.Font = Enum.Font.Gotham
    _IllIO0_81.TextSize = 16
    _IllIO0_81.Parent = _00llI0_82

    local _OI1O0I_E5 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _OI1O0I_E5.Size = UDim2.new(0, 86, 0, 26)
    _OI1O0I_E5.Position = UDim2.new(1, -196, 0.5, -13)
    _OI1O0I_E5.Text = _D("74999E9F8C999F")
    _OI1O0I_E5.BackgroundColor3 = Color3.fromRGB(0,120,0)
    _OI1O0I_E5.TextColor3 = Color3.new(1,1,1)
    _OI1O0I_E5.Parent = _00llI0_82
    Instance.new(_D("80746E9A9D99909D"), _OI1O0I_E5).CornerRadius = UDim.new(0,6)

    local __ll1lI_B8 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    __ll1lI_B8.Size = UDim2.new(0, 86, 0, 26)
    __ll1lI_B8.Position = UDim2.new(1, -100, 0.5, -13)
    __ll1lI_B8.Text = _D("7FA2909099")
    __ll1lI_B8.BackgroundColor3 = Color3.fromRGB(70,70,70)
    __ll1lI_B8.TextColor3 = Color3.new(1,1,1)
    __ll1lI_B8.Parent = _00llI0_82
    Instance.new(_D("80746E9A9D99909D"), __ll1lI_B8).CornerRadius = UDim.new(0,6)

    local function _101l_1_89(m)
        _Il10I0_73 = m
        _OI1O0I_E5.BackgroundColor3 = (m==_D("74999E9F8C999F")) and Color3.fromRGB(0,120,0) or Color3.fromRGB(70,70,70)
        __ll1lI_B8.BackgroundColor3   = (m==_D("7FA2909099"))   and Color3.fromRGB(0,120,0) or Color3.fromRGB(70,70,70)
    end
    _OI1O0I_E5.MouseButton1Click:Connect(function() _101l_1_89(_D("74999E9F8C999F")) end)
    __ll1lI_B8.MouseButton1Click:Connect(function() _101l_1_89(_D("7FA2909099")) end)

    
    local _OIO10O_A4 = _0llOOI_E1(58)
    _OIO10O_A4:SetAttribute(_D("978C8D9097"),_D("7FA29090994B7E909F9F9499929E"))
    local _0_10_l_66 = Instance.new(_D("7F90A39F778C8D9097"))
    _0_10_l_66.BackgroundTransparency = 1
    _0_10_l_66.Size = UDim2.new(1, 0, 0, 20)
    _0_10_l_66.Position = UDim2.new(0,10,0,6)
    _0_10_l_66.Text = _D("7FA29090994B6FA09D8C9F949A99654B5C595B9E")
    _0_10_l_66.TextColor3 = Color3.fromRGB(235,235,235)
    _0_10_l_66.TextXAlignment = Enum.TextXAlignment.Left
    _0_10_l_66.Font = Enum.Font.Gotham
    _0_10_l_66.TextSize = 16
    _0_10_l_66.Parent = _OIO10O_A4

    local _O_0l0O_18 = Instance.new(_D("719D8C9890"))
    _O_0l0O_18.Size = UDim2.new(0.6, -20, 0, 8)
    _O_0l0O_18.Position = UDim2.new(0,10,0,34)
    _O_0l0O_18.BackgroundColor3 = Color3.fromRGB(60,60,60)
    _O_0l0O_18.BorderSizePixel = 0
    _O_0l0O_18.Parent = _OIO10O_A4
    Instance.new(_D("80746E9A9D99909D"), _O_0l0O_18).CornerRadius = UDim.new(0,8)

    local _OOO_l0_38 = Instance.new(_D("719D8C9890"))
    _OOO_l0_38.Size = UDim2.new(0.2, 0, 1, 0)
    _OOO_l0_38.BackgroundColor3 = Color3.fromRGB(0,170,255)
    _OOO_l0_38.BorderSizePixel = 0
    _OOO_l0_38.Parent = _O_0l0O_18
    Instance.new(_D("80746E9A9D99909D"), _OOO_l0_38).CornerRadius = UDim.new(0,8)

    local _lI0I_I_3C = Instance.new(_D("719D8C9890"))
    _lI0I_I_3C.Size = UDim2.fromOffset(18,18)
    _lI0I_I_3C.Position = UDim2.new(0.2, -9, 0.5, -9)
    _lI0I_I_3C.BackgroundColor3 = Color3.fromRGB(240,240,240)
    _lI0I_I_3C.BorderSizePixel = 0
    _lI0I_I_3C.Parent = _O_0l0O_18
    Instance.new(_D("80746E9A9D99909D"), _lI0I_I_3C).CornerRadius = UDim.new(1,0)

    local _l100___99 = false
    local function _1OI0lO_BE(_I__010_8)
        _I__010_8 = math.clamp(_I__010_8, 0, 1)
        _111I1O_FF = math.floor(((0.2 + 4.8 * _I__010_8) * 10) + 0.5) / 10
        _OOO_l0_38.Size = UDim2.new(_I__010_8, 0, 1, 0)
        _lI0I_I_3C.Position = UDim2.new(_I__010_8, -9, 0.5, -9)
        _0_10_l_66.Text = string.format(_D("7FA29090994B6FA09D8C9F949A99654B50595C919E"), _111I1O_FF)
    end
    _O_0l0O_18.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _l100___99 = true
            local _II1OOl_28 = (input.Position.X - _O_0l0O_18.AbsolutePosition.X) / _O_0l0O_18.AbsoluteSize.X
            _1OI0lO_BE(_II1OOl_28)
        end
    end)
    _OOl1_O_16.InputChanged:Connect(function(input)
        if _l100___99 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local _II1OOl_28 = (input.Position.X - _O_0l0O_18.AbsolutePosition.X) / _O_0l0O_18.AbsoluteSize.X
            _1OI0lO_BE(_II1OOl_28)
        end
    end)
    _O_0l0O_18.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _l100___99 = false
        end
    end)

    local __0l_l0_7C = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    __0l_l0_7C.Size = UDim2.new(0.35, -10, 0, 26)
    __0l_l0_7C.Position = UDim2.new(0.65, 0, 0, 30)
    __0l_l0_7C.Text = _D("708C9E949992654B7CA08C8F7AA09F")
    __0l_l0_7C.BackgroundColor3 = Color3.fromRGB(60,60,70)
    __0l_l0_7C.TextColor3 = Color3.new(1,1,1)
    __0l_l0_7C.BorderSizePixel = 0
    __0l_l0_7C.Parent = _OIO10O_A4
    Instance.new(_D("80746E9A9D99909D"), __0l_l0_7C).CornerRadius = UDim.new(0,6)

    local function _O1I_O1_AD()
        _1lIl0l_7D = _1lIl0l_7D % #_lO0l0l_CA + 1
        __0l_l0_7C.Text = _D("708C9E949992654B").._lO0l0l_CA[_1lIl0l_7D][1]
    end
    __0l_l0_7C.MouseButton1Click:Connect(_O1I_O1_AD)

    
    local _lOI1Ol_51 = _0llOOI_E1(40)
    local _1_l1_0_50 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _1_l1_0_50.Size = UDim2.new(1, -20, 1, -10)
    _1_l1_0_50.Position = UDim2.new(0,10,0,5)
    _1_l1_0_50.Text = _D("7F9097909B9A9D9F4B9F9A4B7F8C9D92909F4B7B978CA4909D")
    _1_l1_0_50.BackgroundColor3 = Color3.fromRGB(0,120,0)
    _1_l1_0_50.TextColor3 = Color3.new(1,1,1)
    _1_l1_0_50.BorderSizePixel = 0
    _1_l1_0_50.Parent = _lOI1Ol_51
    Instance.new(_D("80746E9A9D99909D"), _1_l1_0_50).CornerRadius = UDim.new(0,8)

    local function __0_IO__108()
        if not root then return end
        if not _IIl10O_10E then return end
        local _0I01l__25 = _O11IlI_78:FindFirstChild(_IIl10O_10E)
        if not _0I01l__25 or not _0I01l__25.Character then return end
        local _OlO_0__1F = _0I01l__25.Character:FindFirstChild(_D("73A0988C999A948F7D9A9A9F7B8C9D9F"))
        if not _OlO_0__1F then return end
        _1lOO0l_10F(_OlO_0__1F.Position + Vector3.new(0,3,0))
    end
    _1_l1_0_50.MouseButton1Click:Connect(__0_IO__108)

    
    local function _OI0l01_102()
        if _IIl10O_10E then
            local _OIl00l_59 = _O11IlI_78:FindFirstChild(_IIl10O_10E)
            if not _OIl00l_59 then
                _IIl10O_10E = nil
                _I0_O0I_FC.Text = _D("7F8C9D92909F654B538D9097A0984B8F949B9497949354")
            end
        end
    end
    _O11IlI_78.PlayerAdded:Connect(_OI0l01_102)
    _O11IlI_78.PlayerRemoving:Connect(_OI0l01_102)

    
    
    
    local _1I_101_5E = _0llOOI_E1(40)
    _1I_101_5E.BackgroundTransparency = 1
    local _0ll_1I_5D = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _0ll_1I_5D.Size = UDim2.new(0.5, -6, 1, 0)
    _0ll_1I_5D.Text = _D("6C8F8F4B6EA09D9D90999F4B779A8E8C9F949A99")
    _0ll_1I_5D.Font = Enum.Font.GothamBold
    _0ll_1I_5D.TextSize = 14
    _0ll_1I_5D.TextColor3 = Color3.new(1,1,1)
    _0ll_1I_5D.BackgroundColor3 = Color3.fromRGB(0,120,0)
    _0ll_1I_5D.BorderSizePixel = 0
    _0ll_1I_5D.Parent = _1I_101_5E
    Instance.new(_D("80746E9A9D99909D"), _0ll_1I_5D).CornerRadius = UDim.new(0,8)

    local _l00001_64 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _l00001_64.Size = UDim2.new(0.5, -6, 1, 0)
    _l00001_64.Position = UDim2.new(0.5, 6, 0, 0)
    _l00001_64.Text = _D("6F9097909F904B7E9097908E9F908F")
    _l00001_64.Font = Enum.Font.GothamBold
    _l00001_64.TextSize = 14
    _l00001_64.TextColor3 = Color3.new(1,1,1)
    _l00001_64.BackgroundColor3 = Color3.fromRGB(120,0,0)
    _l00001_64.BorderSizePixel = 0
    _l00001_64.Parent = _1I_101_5E
    Instance.new(_D("80746E9A9D99909D"), _l00001_64).CornerRadius = UDim.new(0,8)

    
    
    
    local _0__1l1_7E = _0llOOI_E1(40)
    _0__1l1_7E.BackgroundTransparency = 1
    local ___I0O0_B0 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    ___I0O0_B0.Size = UDim2.new(0.5, -6, 1, 0)
    ___I0O0_B0.Text = _D("70A39B9A9D9F4B779A8E8C9F949A999E")
    ___I0O0_B0.Font = Enum.Font.GothamBold
    ___I0O0_B0.TextSize = 14
    ___I0O0_B0.TextColor3 = Color3.new(1,1,1)
    ___I0O0_B0.BackgroundColor3 = Color3.fromRGB(0,90,140)
    ___I0O0_B0.BorderSizePixel = 0
    ___I0O0_B0.Parent = _0__1l1_7E
    Instance.new(_D("80746E9A9D99909D"), ___I0O0_B0).CornerRadius = UDim.new(0,8)

    local _1l_O01_B3 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _1l_O01_B3.Size = UDim2.new(0.5, -6, 1, 0)
    _1l_O01_B3.Position = UDim2.new(0.5, 6, 0, 0)
    _1l_O01_B3.Text = _D("74989B9A9D9F4B779A8E8C9F949A999E4B537E909DA1909D54")
    _1l_O01_B3.Font = Enum.Font.GothamBold
    _1l_O01_B3.TextSize = 14
    _1l_O01_B3.TextColor3 = Color3.new(1,1,1)
    _1l_O01_B3.BackgroundColor3 = Color3.fromRGB(90,90,90)
    _1l_O01_B3.BorderSizePixel = 0
    _1l_O01_B3.Parent = _0__1l1_7E
    Instance.new(_D("80746E9A9D99909D"), _1l_O01_B3).CornerRadius = UDim.new(0,8)

    
    
    
    local function _1Ol11I_112(_Il_1_l_EF)
        local _0lOl0I_4C = _0llOOI_E1(56)

        local _l_I111_96 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
        _l_I111_96.Size = UDim2.fromOffset(26, 26)
        _l_I111_96.Position = UDim2.new(0, 10, 0.5, -13)
        _l_I111_96.Text = _D("")
        _l_I111_96.BackgroundColor3 = Color3.fromRGB(80,80,80)
        _l_I111_96.BorderSizePixel = 0
        _l_I111_96.Parent = _0lOl0I_4C
        Instance.new(_D("80746E9A9D99909D"), _l_I111_96).CornerRadius = UDim.new(0, 6)
        _Il_1_l_EF._l_I111_96 = _l_I111_96

        local _OO00II_5B = Instance.new(_D("7F90A39F6DA09F9F9A99"))
        _OO00II_5B.Size = UDim2.new(1, -56, 0.5, -4)
        _OO00II_5B.Position = UDim2.new(0, 46, 0, 6)
        _OO00II_5B.Text = _Il_1_l_EF._O1O_I1_40
        _OO00II_5B.Font = Enum.Font.GothamBold
        _OO00II_5B.TextSize = 14
        _OO00II_5B.TextColor3 = Color3.new(1,1,1)
        _OO00II_5B.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
        _OO00II_5B.BorderSizePixel = 0
        _OO00II_5B.Parent = _0lOl0I_4C
        Instance.new(_D("80746E9A9D99909D"), _OO00II_5B).CornerRadius = UDim.new(0, 6)

        local _1_1I0l_39 = Instance.new(_D("7F90A39F778C8D9097"))
        _1_1I0l_39.Size = UDim2.new(1, -56, 0.5, -4)
        _1_1I0l_39.Position = UDim2.new(0, 46, 0.5, 2)
        _1_1I0l_39.BackgroundTransparency = 1
        _1_1I0l_39.TextColor3 = Color3.fromRGB(200,200,200)
        _1_1I0l_39.TextXAlignment = Enum.TextXAlignment.Left
        _1_1I0l_39.Font = Enum.Font.Gotham
        _1_1I0l_39.TextSize = 13
        _1_1I0l_39.Parent = _0lOl0I_4C

        local function _0100ll_105(pos)
            local __IlIO__A = (typeof(pos)==_D("81908E9F9A9D5E")) and pos or _Ol_OIO_DB(pos)
            if __IlIO__A then
                _1_1I0l_39.Text = string.format(_D("83654B50595C91574B84654B50595C91574B85654B50595C91"), __IlIO__A.X, __IlIO__A.Y, __IlIO__A.Z)
            else
                _1_1I0l_39.Text = _D("7499A18C97948F4B9B9A9E949F949A99")
            end
        end
        _0100ll_105(_Il_1_l_EF.position)

        _l_I111_96.MouseButton1Click:Connect(function()
            _Il_1_l_EF.selected = not _Il_1_l_EF.selected
            _l_I111_96.BackgroundColor3 = _Il_1_l_EF.selected and Color3.fromRGB(0,150,0) or Color3.fromRGB(80,80,80)
        end)

        _OO00II_5B.MouseButton1Click:Connect(function()
            local _110OOO_AB = __1O__0_DD.Character or __1O__0_DD.CharacterAdded:Wait()
            local _OlO_0__1F = _110OOO_AB:WaitForChild(_D("73A0988C999A948F7D9A9A9F7B8C9D9F"))
            local __IlIO__A = (typeof(_Il_1_l_EF.position)==_D("81908E9F9A9D5E")) and _Il_1_l_EF.position or _Ol_OIO_DB(_Il_1_l_EF.position)
            if __IlIO__A then
                local _I0llIO_35 = Vector3.new(__IlIO__A.X, __IlIO__A.Y, __IlIO__A.Z) + Vector3.new(0,3,0)
                if _Il10I0_73 == _D("74999E9F8C999F") then
                    _1lOO0l_10F(_I0llIO_35)
                else
                    _OllI0O_114(_I0llIO_35)
                end
            end
        end)

        _0lOl0I_4C:SetAttribute(_D("978C8D9097"), string.lower(_Il_1_l_EF._O1O_I1_40))
        return _0lOl0I_4C
    end

    
    
    
    local function __l00lI_D3(defaultText, titleText, onSave)
        local _O___O1_6A = Instance.new(_D("7E8E9D90909972A094"))
        _O___O1_6A.Name = _D("7B6D8A7B9D9A989B9F")
        _O___O1_6A.Parent = __IOO11_A7
        local _OOOll0_4 = Instance.new(_D("719D8C9890"))
        _OOOll0_4.Size = UDim2.fromOffset(300, 150)
        _OOOll0_4.Position = UDim2.new(0.5, -150, 0.5, -75)
        _OOOll0_4.BackgroundColor3 = Color3.fromRGB(50,50,50)
        _OOOll0_4.BorderSizePixel = 0
        _OOOll0_4.Parent = _O___O1_6A
        Instance.new(_D("80746E9A9D99909D"), _OOOll0_4).CornerRadius = UDim.new(0, 10)
        local __0Il0l_A1 = Instance.new(_D("7F90A39F778C8D9097"))
        __0Il0l_A1.Size = UDim2.new(1, 0, 0, 30)
        __0Il0l_A1.BackgroundColor3 = Color3.fromRGB(70,70,70)
        __0Il0l_A1.Text = titleText
        __0Il0l_A1.TextColor3 = Color3.new(1,1,1)
        __0Il0l_A1.Parent = _OOOll0_4
        local _1ll1_1_14 = Instance.new(_D("7F90A39F6D9AA3"))
        _1ll1_1_14.Size = UDim2.new(1, -20, 0, 30)
        _1ll1_1_14.Position = UDim2.new(0, 10, 0, 40)
        _1ll1_1_14.Text = defaultText
        _1ll1_1_14.BackgroundColor3 = Color3.fromRGB(30,30,30)
        _1ll1_1_14.TextColor3 = Color3.new(1,1,1)
        _1ll1_1_14.Parent = _OOOll0_4
        local _IO0l1__44 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
        _IO0l1__44.Size = UDim2.new(0.5, -15, 0, 30)
        _IO0l1__44.Position = UDim2.new(0, 10, 1, -40)
        _IO0l1__44.Text = _D("7E8CA190")
        _IO0l1__44.BackgroundColor3 = Color3.fromRGB(0,120,0)
        _IO0l1__44.TextColor3 = Color3.new(1,1,1)
        _IO0l1__44.Parent = _OOOll0_4
        local __l0l_0_61 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
        __l0l_0_61.Size = UDim2.new(0.5, -15, 0, 30)
        __l0l_0_61.Position = UDim2.new(0.5, 5, 1, -40)
        __l0l_0_61.Text = _D("6E8C998E9097")
        __l0l_0_61.BackgroundColor3 = Color3.fromRGB(120,0,0)
        __l0l_0_61.TextColor3 = Color3.new(1,1,1)
        __l0l_0_61.Parent = _OOOll0_4

        _IO0l1__44.MouseButton1Click:Connect(function()
            local _O1O_I1_40 = (_1ll1_1_14.Text ~= _D("") and _1ll1_1_14.Text) or defaultText
            _O___O1_6A:Destroy()
            onSave(_O1O_I1_40)
        end)
        __l0l_0_61.MouseButton1Click:Connect(function() _O___O1_6A:Destroy() end)
    end

    
    
    
    _0ll_1I_5D.MouseButton1Click:Connect(function()
        local _110OOO_AB = __1O__0_DD.Character or __1O__0_DD.CharacterAdded:Wait()
        local _OlO_0__1F = _110OOO_AB:WaitForChild(_D("73A0988C999A948F7D9A9A9F7B8C9D9F"))
        local __Il0O0_E2 = _D("779A8E8C9F949A994B")..tostring(#_O111II_104 + 1)
        __l00lI_D3(__Il0O0_E2, _D("798C98904B9F93949E4B979A8E8C9F949A9965"), function(_O1O_I1_40)
            local _Il_1_l_EF = {_O1O_I1_40=_O1O_I1_40, position=_OlO_0__1F.Position, selected=false}
            table.insert(_O111II_104, _Il_1_l_EF)
            _1Ol11I_112(_Il_1_l_EF)
            recalcTp()
        end)
    end)

    _l00001_64.MouseButton1Click:Connect(function()
        for i = #_O111II_104, 1, -1 do
            if _O111II_104[i].selected then
                local _lOOOO0_1B = _O111II_104[i]._l_I111_96
                if _lOOOO0_1B and _lOOOO0_1B.Parent then _lOOOO0_1B.Parent:Destroy() end
                table.remove(_O111II_104, i)
            end
        end
        recalcTp()
    end)

    
    
    
    ___I0O0_B0.MouseButton1Click:Connect(function()
        if #_O111II_104 == 0 then return end
        if not _lll_I1_F3 then __l_0I0_65(_D("90A39B9A9D9F654B9E909DA1909D4B9A919197949990")); return end

        local __Il0O0_E2 = _D("70A39B9A9D9F4B")..tostring(os.time())
        __l00lI_D3(__Il0O0_E2, _D("70A39B9A9D9F4B8C9E65"), function(_O1O_I1_40)
            local _l_IO1l_32 = {}
            for _, loc in ipairs(_O111II_104) do
                local _I__010_8 = _I_O_ll_9C(loc.position)
                if _I__010_8 then
                    _l_IO1l_32[#_l_IO1l_32+1] = { _O1O_I1_40 = loc._O1O_I1_40, position = _I__010_8 }
                else
                    __l_0I0_65(_D("9E96949B4B90A39B9A9D9F664B9499A18C97948F4B9B9A9E949F949A994B9A99"), loc._O1O_I1_40)
                end
            end
            _1IIIII_ED[_O1O_I1_40] = _l_IO1l_32

            local _III0l0_30 = {
                autoload = _10I10__EC,
                __0O_l__7B  = __0O_l__7B,
                exports  = _II0l_0_113(_1IIIII_ED),
                meta     = { username = _0_ll11_94 }
            }
            _01O0Il_C7(_l1OIlI_2F, _III0l0_30)
        end)
    end)

    
    
    
    _1l_O01_B3.MouseButton1Click:Connect(function()
        if _lll_I1_F3 then
            local _O_0O___10,_lOl_l__33 = _0O0OI__C5(_l1OIlI_2F)
            if _O_0O___10 and _lOl_l__33 then
                _1IIIII_ED = _lOl_l__33.exports or _1IIIII_ED
            end
        end

        local _I__I0I_57 = Instance.new(_D("7E8E9D90909972A094"))
        _I__I0I_57.Name = _D("7B6D8A74989B9A9D9F77949E9F")
        _I__I0I_57.ResetOnSpawn = false
        _I__I0I_57.Parent = __IOO11_A7

        local _OOOll0_4 = Instance.new(_D("719D8C9890"))
        _OOOll0_4.Size = UDim2.fromOffset(360, 320)
        _OOOll0_4.Position = UDim2.new(0.5, -180, 0.5, -160)
        _OOOll0_4.BackgroundColor3 = Color3.fromRGB(45,45,50)
        _OOOll0_4.BorderSizePixel = 0
        _OOOll0_4.Parent = _I__I0I_57
        _OOOll0_4.ClipsDescendants = true
        Instance.new(_D("80746E9A9D99909D"), _OOOll0_4).CornerRadius = UDim.new(0, 10)

        local _OI01O0_21 = Instance.new(_D("7F90A39F778C8D9097"))
        _OI01O0_21.Size = UDim2.new(1, -12, 0, 30)
        _OI01O0_21.Position = UDim2.new(0, 6, 0, 6)
        _OI01O0_21.BackgroundColor3 = Color3.fromRGB(70,70,70)
        _OI01O0_21.Text = _D("6E939A9A9E904B90A39B9A9D9F4B9F9A4B94989B9A9D9F")
        _OI01O0_21.TextColor3 = Color3.new(1,1,1)
        _OI01O0_21.Font = Enum.Font.GothamBold
        _OI01O0_21.TextSize = 14
        _OI01O0_21.Parent = _OOOll0_4
        Instance.new(_D("80746E9A9D99909D"), _OI01O0_21).CornerRadius = UDim.new(0,6)

        local _OO10O1_3D = Instance.new(_D("7E8E9D9A9797949992719D8C9890"))
        _OO10O1_3D.Size = UDim2.new(1, -12, 1, -106)
        _OO10O1_3D.Position = UDim2.new(0, 6, 0, 42)
        _OO10O1_3D.BackgroundTransparency = 1
        _OO10O1_3D.ScrollBarThickness = 6
        _OO10O1_3D.ClipsDescendants = true
        _OO10O1_3D.Parent = _OOOll0_4

        local _1OlOOI_20 = Instance.new(_D("807477949E9F778CA49AA09F"))
        _1OlOOI_20.Parent = _OO10O1_3D
        _1OlOOI_20.Padding = UDim.new(0,6)

        local _lOl_Ol_60 = Instance.new(_D("719D8C9890"))
        _lOl_Ol_60.Size = UDim2.new(1, -12, 0, 36)
        _lOl_Ol_60.Position = UDim2.new(0, 6, 1, -42)
        _lOl_Ol_60.BackgroundTransparency = 1
        _lOl_Ol_60.Parent = _OOOll0_4

        local function _l1I011_9F(__1O_lO_2)
            __1O_lO_2.AutoButtonColor = true
            __1O_lO_2.BorderSizePixel = 0
            Instance.new(_D("80746E9A9D99909D"), __1O_lO_2).CornerRadius = UDim.new(0,6)
            return __1O_lO_2
        end

        local _1IlOlI_80 = _l1I011_9F(Instance.new(_D("7F90A39F6DA09F9F9A99")))
        _1IlOlI_80.Size = UDim2.new(0.4, -4, 1, 0)
        _1IlOlI_80.Position = UDim2.new(0, 0, 0, 0)
        _1IlOlI_80.Text = _D("779A8C8F")
        _1IlOlI_80.TextColor3 = Color3.new(1,1,1)
        _1IlOlI_80.BackgroundColor3 = Color3.fromRGB(0,120,0)
        _1IlOlI_80.Parent = _lOl_Ol_60

        local __00lO0_AE = _l1I011_9F(Instance.new(_D("7F90A39F6DA09F9F9A99")))
        __00lO0_AE.Size = UDim2.new(0.4, -4, 1, 0)
        __00lO0_AE.Position = UDim2.new(0.4, 8, 0, 0)
        __00lO0_AE.Text = _D("6F9097909F90")
        __00lO0_AE.TextColor3 = Color3.new(1,1,1)
        __00lO0_AE.BackgroundColor3 = Color3.fromRGB(120,0,0)
        __00lO0_AE.Parent = _lOl_Ol_60

        local __0111l_63 = _l1I011_9F(Instance.new(_D("7F90A39F6DA09F9F9A99")))
        __0111l_63.Size = UDim2.new(0.2, -4, 1, 0)
        __0111l_63.Position = UDim2.new(0.8, 8, 0, 0)
        __0111l_63.Text = _D("6E979A9E90")
        __0111l_63.TextColor3 = Color3.new(1,1,1)
        __0111l_63.BackgroundColor3 = Color3.fromRGB(90,60,60)
        __0111l_63.Parent = _lOl_Ol_60

        local function _O0O1_l_D7(_0lIO0l_19, enabled, activeColor, disabledColor)
            _0lIO0l_19.Active = enabled
            _0lIO0l_19.AutoButtonColor = enabled
            _0lIO0l_19.BackgroundColor3 = enabled and activeColor or disabledColor
            _0lIO0l_19.TextTransparency = enabled and 0 or 0.35
        end

        _O0O1_l_D7(_1IlOlI_80, false, Color3.fromRGB(0,120,0), Color3.fromRGB(70,70,70))
        _O0O1_l_D7(__00lO0_AE, false, Color3.fromRGB(120,0,0), Color3.fromRGB(70,70,70))

        local _11O1I__F2, selectedBtn

        local function _1lIO1O_E6()
            for _,ch in ipairs(_OO10O1_3D:GetChildren()) do
                if ch:IsA(_D("7F90A39F6DA09F9F9A99")) then ch:Destroy() end
            end
            _11O1I__F2, selectedBtn = nil, nil
            _O0O1_l_D7(_1IlOlI_80, false, Color3.fromRGB(0,120,0), Color3.fromRGB(70,70,70))
            _O0O1_l_D7(__00lO0_AE, false, Color3.fromRGB(120,0,0), Color3.fromRGB(70,70,70))

            for _O1O_I1_40,_set in pairs(_1IIIII_ED) do
                local __1O_lO_2 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
                __1O_lO_2.Size = UDim2.new(1, -4, 0, 28)
                __1O_lO_2.Text = _O1O_I1_40
                __1O_lO_2.BackgroundColor3 = Color3.fromRGB(60,60,70)
                __1O_lO_2.TextColor3 = Color3.new(1,1,1)
                __1O_lO_2.Parent = _OO10O1_3D
                Instance.new(_D("80746E9A9D99909D"), __1O_lO_2).CornerRadius = UDim.new(0,6)

                __1O_lO_2.MouseButton1Click:Connect(function()
                    if selectedBtn and selectedBtn ~= __1O_lO_2 then
                        selectedBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
                    end
                    selectedBtn = __1O_lO_2
                    _11O1I__F2 = _O1O_I1_40
                    __1O_lO_2.BackgroundColor3 = Color3.fromRGB(0,140,200)
                    _O0O1_l_D7(_1IlOlI_80, true, Color3.fromRGB(0,120,0), Color3.fromRGB(70,70,70))
                    _O0O1_l_D7(__00lO0_AE, true, Color3.fromRGB(120,0,0), Color3.fromRGB(70,70,70))
                end)
            end
        end

        _1lIO1O_E6()

        _1IlOlI_80.MouseButton1Click:Connect(function()
            if not _11O1I__F2 then return end
            local _I__0Ol_2C = _1IIIII_ED[_11O1I__F2]
            if not _I__0Ol_2C then return end

            for i=#_O111II_104,1,-1 do
                local _lOOOO0_1B = _O111II_104[i]._l_I111_96
                if _lOOOO0_1B and _lOOOO0_1B.Parent then _lOOOO0_1B.Parent:Destroy() end
                table.remove(_O111II_104,i)
            end

            for _,loc in ipairs(_I__0Ol_2C) do
                local __IlIO__A = _Ol_OIO_DB(loc.position)
                if __IlIO__A then
                    local _l1_IO__E = { _O1O_I1_40=loc._O1O_I1_40, position=__IlIO__A, selected=false }
                    table.insert(_O111II_104, _l1_IO__E)
                    _1Ol11I_112(_l1_IO__E)
                else
                    __l_0I0_65(_D("9E96949B4B94989B9A9D9F664B9499A18C97948F4B9B8C8E96908F4B9B9A9E949F949A994B9A99"), tostring(loc._O1O_I1_40))
                end
            end
            recalcTp()
            _I__I0I_57:Destroy()
        end)

        __00lO0_AE.MouseButton1Click:Connect(function()
            if not _11O1I__F2 then return end
            if not _lll_I1_F3 then __l_0I0_65(_D("8F9097909F904B90A39B9A9D9F654B9E909DA1909D4B9A919197949990")); return end

            _1IIIII_ED[_11O1I__F2] = nil

            local _III0l0_30 = {
                autoload = _10I10__EC,
                __0O_l__7B  = __0O_l__7B,
                exports  = _II0l_0_113(_1IIIII_ED),
                meta     = { username = _0_ll11_94 }
            }
            local _O_0O___10,_ = _01O0Il_C7(_l1OIlI_2F, _III0l0_30)
            if not _O_0O___10 then
                __l_0I0_65(_D("8F9097909F904B90A39B9A9D9F4B7B807F4B918C9497908F"))
                return
            end

            _1lIO1O_E6()
        end)

        __0111l_63.MouseButton1Click:Connect(function() _I__I0I_57:Destroy() end)
    end)

    
    
    
    local _O000_I_8F = _0llOOI_E1(58)
    _O000_I_8F:SetAttribute(_D("978C8D9097"),_D("6CA09F9A4B7F9AA09D"))
    local _IIOl11_8E = Instance.new(_D("7F90A39F778C8D9097"))
    _IIOl11_8E.BackgroundTransparency = 1
    _IIOl11_8E.Size = UDim2.new(1, 0, 0, 20)
    _IIOl11_8E.Position = UDim2.new(0,10,0,6)
    _IIOl11_8E.Text = _D("6CA09F9A4B7F9AA09D4B538C9F8C9E4B0DB1BD4B8D8CA28C9354")
    _IIOl11_8E.TextColor3 = Color3.fromRGB(235,235,235)
    _IIOl11_8E.TextXAlignment = Enum.TextXAlignment.Left
    _IIOl11_8E.Font = Enum.Font.Gotham
    _IIOl11_8E.TextSize = 16
    _IIOl11_8E.Parent = _O000_I_8F

    local ___IOll_E4 = Instance.new(_D("7F90A39F6D9AA3"))
    ___IOll_E4.Size = UDim2.new(0.4, -20, 0, 26)
    ___IOll_E4.Position = UDim2.new(0,10,0,30)
    ___IOll_E4.Text = _D("5E")
    ___IOll_E4.PlaceholderText = _D("74999F909DA18C974B8F909F9496")
    ___IOll_E4.TextColor3 = Color3.new(1,1,1)
    ___IOll_E4.BackgroundColor3 = Color3.fromRGB(55,55,60)
    ___IOll_E4.BorderSizePixel = 0
    ___IOll_E4.Parent = _O000_I_8F
    Instance.new(_D("80746E9A9D99909D"), ___IOll_E4).CornerRadius = UDim.new(0,6)
    
    
    local _0_1O1__8C = _0llOOI_E1(40)
    _0_1O1__8C:SetAttribute(_D("978C8D9097"),_D("7F9AA09D4B7E998C9B9E939A9F"))

    local _1l01Il_B2 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _1l01Il_B2.Size = UDim2.new(0.35, -8, 1, -10)
    _1l01Il_B2.Position = UDim2.new(0,10,0,5)
    _1l01Il_B2.Text = _D("72909F4B6C97974B7B9A9E949F949A999E")
    _1l01Il_B2.BackgroundColor3 = Color3.fromRGB(0,90,140)
    _1l01Il_B2.TextColor3 = Color3.new(1,1,1)
    _1l01Il_B2.BorderSizePixel = 0
    _1l01Il_B2.Parent = _0_1O1__8C
    Instance.new(_D("80746E9A9D99909D"), _1l01Il_B2).CornerRadius = UDim.new(0,8)

    local _OOO_00_97 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _OOO_00_97.Size = UDim2.new(0.25, -8, 1, -10)
    _OOO_00_97.Position = UDim2.new(0.37, 0, 0, 5)
    _OOO_00_97.Text = _D("6E97908C9D")
    _OOO_00_97.BackgroundColor3 = Color3.fromRGB(90,60,60)
    _OOO_00_97.TextColor3 = Color3.new(1,1,1)
    _OOO_00_97.BorderSizePixel = 0
    _OOO_00_97.Parent = _0_1O1__8C
    Instance.new(_D("80746E9A9D99909D"), _OOO_00_97).CornerRadius = UDim.new(0,8)

    local __O_O___F5 = Instance.new(_D("7F90A39F778C8D9097"))
    __O_O___F5.BackgroundTransparency = 1
    __O_O___F5.Size = UDim2.new(0.35, -10, 1, 0)
    __O_O___F5.Position = UDim2.new(0.64, 0, 0, 0)
    __O_O___F5.Text = _D("7F9AA09D4B8E9AA0999F654B5B")
    __O_O___F5.TextXAlignment = Enum.TextXAlignment.Right
    __O_O___F5.TextColor3 = Color3.fromRGB(220,220,220)
    __O_O___F5.Font = Enum.Font.Gotham
    __O_O___F5.TextSize = 14
    __O_O___F5.Parent = _0_1O1__8C

    local function __IO1OI_10D()
        __O_O___F5.Text = (_D("7F9AA09D4B8E9AA0999F654B508F")):format(#_1IO_01_A2)
    end

    
    local function _OI00Ol_10A()
        local _OO10O1_3D = {}
        for _, loc in ipairs(_O111II_104) do
            local __IlIO__A = (typeof(loc.position) == _D("81908E9F9A9D5E")) and loc.position or _Ol_OIO_DB(loc.position)
            if __IlIO__A then
                _OO10O1_3D[#_OO10O1_3D+1] = { _O1O_I1_40 = loc._O1O_I1_40, pos = Vector3.new(__IlIO__A.X, __IlIO__A.Y, __IlIO__A.Z) }
            end
        end
        return _OO10O1_3D
    end

    _1l01Il_B2.MouseButton1Click:Connect(function()
        _0ll1lI_8A(_OI00Ol_10A())
        __IO1OI_10D()
        _1IO_11_C0.Text = _D("7E9F8C9FA09E654B7E998C9B9E939A9F4BA09B8F8C9F908F")
    end)

    _OOO_00_97.MouseButton1Click:Connect(function()
        _0ll1lI_8A({})
        __IO1OI_10D()
        _1IO_11_C0.Text = _D("7E9F8C9FA09E654B7E998C9B9E939A9F4B8E97908C9D908F")
    end)

    local _11l1Ol_9E = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _11l1Ol_9E.Size = UDim2.new(0.25, -8, 0, 26)
    _11l1Ol_9E.Position = UDim2.new(0.42, 0, 0, 30)
    _11l1Ol_9E.Text = _D("7E9F8C9D9F")
    _11l1Ol_9E.BackgroundColor3 = Color3.fromRGB(0,120,0)
    _11l1Ol_9E.TextColor3 = Color3.new(1,1,1)
    _11l1Ol_9E.BorderSizePixel = 0
    _11l1Ol_9E.Parent = _O000_I_8F
    Instance.new(_D("80746E9A9D99909D"), _11l1Ol_9E).CornerRadius = UDim.new(0,6)

    local _I1O_ll_8D = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _I1O_ll_8D.Size = UDim2.new(0.25, -8, 0, 26)
    _I1O_ll_8D.Position = UDim2.new(0.69, 8, 0, 30)
    _I1O_ll_8D.Text = _D("7E9F9A9B")
    _I1O_ll_8D.BackgroundColor3 = Color3.fromRGB(120,0,0)
    _I1O_ll_8D.TextColor3 = Color3.new(1,1,1)
    _I1O_ll_8D.BorderSizePixel = 0
    _I1O_ll_8D.Parent = _O000_I_8F
    Instance.new(_D("80746E9A9D99909D"), _I1O_ll_8D).CornerRadius = UDim.new(0,6)

    local _1IO_11_C0 = Instance.new(_D("7F90A39F778C8D9097"))
    _1IO_11_C0.BackgroundTransparency = 1
    _1IO_11_C0.Size = UDim2.new(1, -20, 0, 18)
    _1IO_11_C0.Position = UDim2.new(0,10,0, 30+26+6)
    _1IO_11_C0.Text = _D("7E9F8C9FA09E654B748F9790")
    _1IO_11_C0.TextColor3 = Color3.fromRGB(200,200,200)
    _1IO_11_C0.TextXAlignment = Enum.TextXAlignment.Left
    _1IO_11_C0.Font = Enum.Font.Gotham
    _1IO_11_C0.TextSize = 13
    _1IO_11_C0.Parent = _O000_I_8F

    local _Il0IlI_E9 = false
    local function _IO10l1_FB()
        local _I11IOO_27 = (___IOll_E4 and ___IOll_E4.Text) or _D("")
        local _OO0_lI_7A = _I11IOO_27:gsub(_D("8689508F505988"), _D(""))  
        local _1I1O11_7 = tonumber(_OO0_lI_7A)
        if not _1I1O11_7 or _1I1O11_7 < 0.1 then _1I1O11_7 = 0.1 end
        return _1I1O11_7
    end


    local function _I1IIIO_F1(_I0llIO_35)
        
        if (not root) or (not root.Parent) or (not hum) or hum.Health <= 0 then
            _II0OI__EE()
        end
        if _Il10I0_73 == _D("74999E9F8C999F") then
            _1lOO0l_10F(_I0llIO_35)
        else
            _OllI0O_114(_I0llIO_35)
        end
    end

    _11l1Ol_9E.MouseButton1Click:Connect(function()
        if _Il0IlI_E9 then return end

        if #_1IO_01_A2 == 0 then
            _1IO_11_C0.Text = _D("7E9F8C9FA09E654B7F9AA09D4B97949E9F4B969A9E9A99924B0DABBF4B9F90968C994B72909F4B6C97974B8FA097A0")
            return
        end

        _Il0IlI_E9 = true
        _1IO_11_C0.Text = _D("7E9F8C9FA09E654B7DA09999949992")

        task.spawn(function()
            while _Il0IlI_E9 do
                for i = 1, #_1IO_01_A2 do
                    if not _Il0IlI_E9 then break end

                    local _OI0I_O_3A = _1IO_01_A2[i]
                    local _I0llIO_35 = _OI0I_O_3A.pos + Vector3.new(0, 3, 0)

                    
                    pcall(function()
                        _I1IIIO_F1(_I0llIO_35)
                    end)

                    
                    local _OOI01__90 = _IO10l1_FB()
                    if _OOI01__90 < 0.1 then _OOI01__90 = 0.1 end
                    local _ll0_1I_13 = tick()
                    while _Il0IlI_E9 and (tick() - _ll0_1I_13) < _OOI01__90 do
                        task.wait(0.05)
                    end
                end
            end
            _1IO_11_C0.Text = _D("7E9F8C9FA09E654B7E9F9A9B9B908F")
        end)
    end)

    _I1O_ll_8D.MouseButton1Click:Connect(function()
        _Il0IlI_E9 = false
        _1IO_11_C0.Text = _D("7E9F8C9FA09E654B7E9F9A9B9B949992595959")
    end)

    
    
    
    local function _Ol1l_l_111(_1_IOl1_6D, _I1OI01_6B)
        local _0O1lO__9 = string.lower(_1_0OOI_BC.Text or _D(""))
        for _,_II0Il__2B in ipairs(_1_IOl1_6D:GetChildren()) do
            if _II0Il__2B:IsA(_D("719D8C9890")) then
                local __lOlI0_54 = string.lower(tostring(_II0Il__2B:GetAttribute(_D("978C8D9097")) or _II0Il__2B.Name or _D("")))
                _II0Il__2B.Visible = (_0O1lO__9 == _D("")) or (string.find(__lOlI0_54, _0O1lO__9, 1, true) ~= nil)
            end
        end
        if _I1OI01_6B then _I1OI01_6B() end
    end

    local __l00O0_A8 = _D("788C9499")
    local function _l_I1I0_E0()
        if __l00O0_A8 == _D("788C9499") then
            _Ol1l_l_111(_lIOOll_CE, recalcMain)
        elseif __l00O0_A8 == _D("78949E8E") then
            _Ol1l_l_111(_Ol_0lO_D2, recalcMisc)
        elseif __l00O0_A8 == _D("7F9097909B9A9D9F") then
            local _0O1lO__9 = string.lower(_1_0OOI_BC.Text or _D(""))
            for _,_II0Il__2B in ipairs(_01IlOl_A3:GetChildren()) do
                if _II0Il__2B:IsA(_D("719D8C9890")) and (_II0Il__2B ~= nil) then
                    local __lOlI0_54 = tostring(_II0Il__2B:GetAttribute(_D("978C8D9097")) or _D(""))
                    _II0Il__2B.Visible = (_0O1lO__9 == _D("")) or (string.find(__lOlI0_54, _0O1lO__9, 1, true) ~= nil)
                end
            end
            recalcTp()
        else
            _Ol1l_l_111(_Il__lO_AA, recalcCfg)
        end
    end
    _1_0OOI_BC:GetPropertyChangedSignal(_D("7F90A39F")):Connect(_l_I1I0_E0)

    
    
    
    local function _0__1_0_10B()
        return {
            _OO00I__1E=_OO00I__1E, _OlO_ll_69=_OlO_ll_69, _1OII0__F9=_1OII0__F9, _O__00__B4=_O__00__B4, _O_O0l0_F0=_O_O0l0_F0,
            ___11_0_C3=___11_0_C3, _I1100I_B5=_I1100I_B5,
            _1l000O_CB=_1l000O_CB, _lII_O__BB=_lII_O__BB, fov=_1__OO1_C9,
        }
    end
    local function __l_I_I_F6(s)
        if not s then return end
        _O_I0lI_47.Set(s.___11_0_C3 or ___11_0_C3)
        _O__O0I_3B.Set(s._I1100I_B5 or _I1100I_B5)
        _1I_0_1_6E(s.fov or _1__OO1_C9)
        _1O10II_37.Set(s._1l000O_CB or false)
        _l__0IO_43.Set(s._lII_O__BB or false)
        _1_Ol11_4D.Set(s._OO00I__1E or false)
        _O0l0___41.Set(s._OlO_ll_69 or false)
        _lIlO_I_52.Set(s._1OII0__F9 or false)
        _lll0Il_53.Set(s._O__00__B4 or false)
        _OlI0I__56.Set(s._O_O0l0_F0 or false)
    end

    local __1I__l_84 = _l_1____AC(_Il__lO_AA, 58)
    __1I__l_84:SetAttribute(_D("978C8D9097"),_D("6E9A999194924B798C9890"))
    local _OI_00l_9B = Instance.new(_D("7F90A39F778C8D9097"))
    _OI_00l_9B.BackgroundTransparency = 1
    _OI_00l_9B.Size = UDim2.new(1, 0, 0, 20)
    _OI_00l_9B.Position = UDim2.new(0,10,0,6)
    _OI_00l_9B.Text = _D("6E9A999194924B798C9890")
    _OI_00l_9B.TextColor3 = Color3.fromRGB(235,235,235)
    _OI_00l_9B.Font = Enum.Font.Gotham
    _OI_00l_9B.TextSize = 16
    _OI_00l_9B.Parent = __1I__l_84
    local _00l01I_83 = Instance.new(_D("7F90A39F6D9AA3"))
    _00l01I_83.Size = UDim2.new(1, -20, 0, 28)
    _00l01I_83.Position = UDim2.new(0,10,0,28)
    _00l01I_83.PlaceholderText = _D("98A4588E9A99919492")
    _00l01I_83.Text = _D("")
    _00l01I_83.TextColor3 = Color3.new(1,1,1)
    _00l01I_83.BackgroundColor3 = Color3.fromRGB(55,55,60)
    _00l01I_83.BorderSizePixel = 0
    _00l01I_83.Parent = __1I__l_84
    Instance.new(_D("80746E9A9D99909D"), _00l01I_83).CornerRadius = UDim.new(0,6)

    local _01O00l_88 = _l_1____AC(_Il__lO_AA, 40)
    _01O00l_88:SetAttribute(_D("978C8D9097"),_D("7E8CA1904B6E9A99919492"))
    local _lI_Il__87 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
    _lI_Il__87.Size = UDim2.new(1, -20, 1, -10)
    _lI_Il__87.Position = UDim2.new(0,10,0,5)
    _lI_Il__87.Text = _D("7E8CA1904B6E9A999194924B537E909DA1909D54")
    _lI_Il__87.BackgroundColor3 = Color3.fromRGB(0,120,0)
    _lI_Il__87.TextColor3 = Color3.new(1,1,1)
    _lI_Il__87.BorderSizePixel = 0
    _lI_Il__87.Parent = _01O00l_88
    Instance.new(_D("80746E9A9D99909D"), _lI_Il__87).CornerRadius = UDim.new(0,8)

    local _I0I01I_B6 = _l_1____AC(_Il__lO_AA, 28)
    local _OI1I0I_C = Instance.new(_D("7F90A39F778C8D9097"))
    _OI1I0I_C.BackgroundTransparency = 1
    _OI1I0I_C.Size = UDim2.new(1, -20, 1, 0)
    _OI1I0I_C.Position = UDim2.new(0,10,0,0)
    _OI1I0I_C.Text = _D("7E8CA1908F4B6E9A999194929E4B537E909DA1909D54")
    _OI1I0I_C.TextColor3 = Color3.new(1,1,1)
    _OI1I0I_C.TextXAlignment = Enum.TextXAlignment.Left
    _OI1I0I_C.Font = Enum.Font.GothamBold
    _OI1I0I_C.TextSize = 14
    _OI1I0I_C.Parent = _I0I01I_B6

    local _0l111l_79 = _l_1____AC(_Il__lO_AA, 180)
    _0l111l_79.BackgroundTransparency = 1
    local _IllOOO_100 = Instance.new(_D("7E8E9D9A9797949992719D8C9890"))
    _IllOOO_100.Size = UDim2.new(1, -12, 1, 0)
    _IllOOO_100.Position = UDim2.new(0,6,0,0)
    _IllOOO_100.BackgroundTransparency = 1
    _IllOOO_100.ScrollBarThickness = 6
    _IllOOO_100.ClipsDescendants = true
    _IllOOO_100.Parent = _0l111l_79
    local _OllOII_62 = Instance.new(_D("807477949E9F778CA49AA09F"))
    _OllOII_62.Parent = _IllOOO_100
    _OllOII_62.Padding = UDim.new(0,6)

    local function _1_lOlI_103()
        for _,ch in ipairs(_IllOOO_100:GetChildren()) do
            if ch:IsA(_D("7F90A39F6DA09F9F9A99")) or ch:IsA(_D("719D8C9890")) then ch:Destroy() end
        end
        for _O1O_I1_40, s in pairs(__0O_l__7B) do
            local _II0Il__2B = Instance.new(_D("719D8C9890"))
            _II0Il__2B.Size = UDim2.new(1, -4, 0, 32)
            _II0Il__2B.BackgroundColor3 = Color3.fromRGB(50,50,58)
            _II0Il__2B.Parent = _IllOOO_100
            Instance.new(_D("80746E9A9D99909D"), _II0Il__2B).CornerRadius = UDim.new(0,6)

            local _lO01l1_3F = Instance.new(_D("7F90A39F778C8D9097"))
            _lO01l1_3F.BackgroundTransparency = 1
            _lO01l1_3F.Size = UDim2.new(0.5, -10, 1, 0)
            _lO01l1_3F.Position = UDim2.new(0,10,0,0)
            _lO01l1_3F.Text = _O1O_I1_40 .. (_10I10__EC==_O1O_I1_40 and _D("4B4B536CA09F9A54") or _D(""))
            _lO01l1_3F.TextXAlignment = Enum.TextXAlignment.Left
            _lO01l1_3F.TextColor3 = Color3.new(1,1,1)
            _lO01l1_3F.Parent = _II0Il__2B

            local _O1I1_1_55 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
            _O1I1_1_55.Size = UDim2.new(0.2, -6, 0, 26)
            _O1I1_1_55.Position = UDim2.new(0.5, 0, 0.5, -13)
            _O1I1_1_55.Text = _D("779A8C8F")
            _O1I1_1_55.BackgroundColor3 = Color3.fromRGB(0,90,140)
            _O1I1_1_55.TextColor3 = Color3.new(1,1,1)
            _O1I1_1_55.Parent = _II0Il__2B
            Instance.new(_D("80746E9A9D99909D"), _O1I1_1_55).CornerRadius = UDim.new(0,6)

            local _l_1_I0_48 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
            _l_1_I0_48.Size = UDim2.new(0.2, -6, 0, 26)
            _l_1_I0_48.Position = UDim2.new(0.7, 0, 0.5, -13)
            _l_1_I0_48.Text = _D("6CA09F9A")
            _l_1_I0_48.BackgroundColor3 = _10I10__EC==_O1O_I1_40 and Color3.fromRGB(0,150,0) or Color3.fromRGB(70,70,70)
            _l_1_I0_48.TextColor3 = Color3.new(1,1,1)
            _l_1_I0_48.Parent = _II0Il__2B
            Instance.new(_D("80746E9A9D99909D"), _l_1_I0_48).CornerRadius = UDim.new(0,6)

            local _IlIll0_34 = Instance.new(_D("7F90A39F6DA09F9F9A99"))
            _IlIll0_34.Size = UDim2.new(0.1, -6, 0, 26)
            _IlIll0_34.Position = UDim2.new(0.9, 0, 0.5, -13)
            _IlIll0_34.Text = _D("6F9097")
            _IlIll0_34.BackgroundColor3 = Color3.fromRGB(120,0,0)
            _IlIll0_34.TextColor3 = Color3.new(1,1,1)
            _IlIll0_34.Parent = _II0Il__2B
            Instance.new(_D("80746E9A9D99909D"), _IlIll0_34).CornerRadius = UDim.new(0,6)

            _O1I1_1_55.MouseButton1Click:Connect(function() __l_I_I_F6(s) end)
            _l_1_I0_48.MouseButton1Click:Connect(function()
                if not _lll_I1_F3 then __l_0I0_65(_D("8CA09F9A4B9E909F654B9E909DA1909D4B9A919197949990")); return end
                _10I10__EC = (_10I10__EC==_O1O_I1_40) and nil or _O1O_I1_40
                local _III0l0_30 = {
                    autoload = _10I10__EC,
                    __0O_l__7B  = __0O_l__7B,
                    exports  = _II0l_0_113(_1IIIII_ED),
                    meta     = { username = _0_ll11_94 }
                }
                _01O0Il_C7(_l1OIlI_2F, _III0l0_30)
                _1_lOlI_103()
            end)
            _IlIll0_34.MouseButton1Click:Connect(function()
                if not _lll_I1_F3 then __l_0I0_65(_D("8F9097909F904B8E9A99919492654B9E909DA1909D4B9A919197949990")); return end
                __0O_l__7B[_O1O_I1_40] = nil
                if _10I10__EC == _O1O_I1_40 then _10I10__EC = nil end
                local _III0l0_30 = {
                    autoload = _10I10__EC,
                    __0O_l__7B  = __0O_l__7B,
                    exports  = _II0l_0_113(_1IIIII_ED),
                    meta     = { username = _0_ll11_94 }
                }
                _01O0Il_C7(_l1OIlI_2F, _III0l0_30)
                _1_lOlI_103()
            end)
        end
    end

    _lI_Il__87.MouseButton1Click:Connect(function()
        if not _lll_I1_F3 then __l_0I0_65(_D("9E8CA1904B8E9A99919492654B9E909DA1909D4B9A919197949990")); return end
        local _I1O0l__F = _00l01I_83.Text ~= _D("") and _00l01I_83.Text or (_D("8E9A9991949258")..tostring(os.time()))
        __0O_l__7B[_I1O0l__F] = _0__1_0_10B()
        local _III0l0_30 = {
            autoload = _10I10__EC,
            __0O_l__7B  = __0O_l__7B,
            exports  = _II0l_0_113(_1IIIII_ED),
            meta     = { username = _0_ll11_94 }
        }
        _01O0Il_C7(_l1OIlI_2F, _III0l0_30)
        _1_lOlI_103()
    end)

    
    local function _1l1Ol1_8B(_O1O_I1_40)
        __l00O0_A8 = _O1O_I1_40
        _lIOOll_CE.Visible = (_O1O_I1_40 == _D("788C9499"))
        _Ol_0lO_D2.Visible = (_O1O_I1_40 == _D("78949E8E"))
        _01IlOl_A3.Visible   = (_O1O_I1_40 == _D("7F9097909B9A9D9F"))
        _Il__lO_AA.Visible  = (_O1O_I1_40 == _D("6E9A99919492"))
        _l_I1I0_E0()
    end
    _001_IO_D9.MouseButton1Click:Connect(function() _1l1Ol1_8B(_D("788C9499")) end)
    _IOOIlO_DA.MouseButton1Click:Connect(function() _1l1Ol1_8B(_D("78949E8E")) end)
    _10O100_A0.MouseButton1Click:Connect(function() _1l1Ol1_8B(_D("7F9097909B9A9D9F")) end)
    __10O10_C1.MouseButton1Click:Connect(function() _1l1Ol1_8B(_D("6E9A99919492")) end)
    _1l1Ol1_8B(_D("788C9499"))

    
    local _II1_1l_B7 = false
    _1Ol_IO_5F.MouseButton1Click:Connect(function()
        _II1_1l_B7 = not _II1_1l_B7
        local _O1OOI__2E = not _II1_1l_B7
        _10llOI_45.Visible = _O1OOI__2E
        _lIOOll_CE.Visible = _O1OOI__2E and (__l00O0_A8 == _D("788C9499"))
        _Ol_0lO_D2.Visible = _O1OOI__2E and (__l00O0_A8 == _D("78949E8E"))
        _01IlOl_A3.Visible   = _O1OOI__2E and (__l00O0_A8 == _D("7F9097909B9A9D9F"))
        _Il__lO_AA.Visible  = _O1OOI__2E and (__l00O0_A8 == _D("6E9A99919492"))
        _IlII_0_4F.Size = _II1_1l_B7 and UDim2.fromOffset(420, 56) or UDim2.fromOffset(420, 360)
    end)
    __ll_I1_95.MouseButton1Click:Connect(function()
        __OO0Ol_77.Enabled = false
        _O1_1ll_9D()
    end)

    
    local __IIl10_F7 = false
    local _100OOl_AF, startPos
    _0I__10_36.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            __IIl10_F7 = true
            _100OOl_AF = input.Position
            startPos = _IlII_0_4F.Position
        end
    end)
    _OOl1_O_16.InputChanged:Connect(function(input)
        if __IIl10_F7 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local _O_O1II_4B = input.Position - _100OOl_AF
            _IlII_0_4F.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + _O_O1II_4B.X, startPos.Y.Scale, startPos.Y.Offset + _O_O1II_4B.Y)
        end
    end)
    _0I__10_36.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            __IIl10_F7 = false
        end
    end)

    
    task.delay(5, function()
        _I_l00O_85:Destroy()
        __OO0Ol_77.Enabled = true

        if _10I10__EC and __0O_l__7B[_10I10__EC] then
            task.defer(function() __l_I_I_F6(__0O_l__7B[_10I10__EC]) end)
        end

        _1I_0_1_6E(_1__OO1_C9)
        _1_lOlI_103()
    end)
end


_lI1O1I_109()

_II0OI__EE()
_1Il01O_A9()
__O__II_F8()
_0OO1OO_101()

__1O__0_DD.CharacterAdded:Connect(function()
    _II0OI__EE()
    _1Il01O_A9()
    __O__II_F8()
    _0OO1OO_101()
    _OO00I__1E = false
    _OlO_ll_69 = false
end)


_OOl1_O_16.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        _llOlO__6F(not _OO00I__1E)
    end
end)


_1__01l_98()


game:BindToClose(function()
    _llOlO__6F(false)
    _0_0OO0_C8()
end)
do
    local __x2511 = 2511; local __y8577 = 8577
    if (__x2511 * 0 == 1) then
        print(_DJ("debug:2511:8577"))
    end
    local __t2511 = {}
    for i=1,3 do __t2511[i] = (__x2511 + __y8577) % 11088 end
    if __t2511[1] == 3951 then return _DJ(nil) end
end
do
    local __x4141 = 4141; local __y2342 = 2342
    if (__x4141 * 0 == 1) then
        print(_DJ("debug:4141:2342"))
    end
    local __t4141 = {}
    for i=1,3 do __t4141[i] = (__x4141 + __y2342) % 6483 end
    if __t4141[1] == 6137 then return _DJ(nil) end
end
