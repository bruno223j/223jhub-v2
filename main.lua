-- 
--             223JHUB  v2.5  free universal script          
--                 SCRIPT POR BRUNO223J E TY                 
--               DISCORD: bruno223j  |  frty2017             
-- 

local _KCoreGui = game:GetService("CoreGui")
local _KTween   = game:GetService("TweenService")
local _KHttp    = game:GetService("HttpService")
local _KLP      = game:GetService("Players").LocalPlayer

local function GetGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local ok2, pg = pcall(function() return _KLP:WaitForChild("PlayerGui", 5) end)
    if ok2 and pg then return pg end
    return _KCoreGui
end
local _GuiParent = GetGuiParent()

-- Key system removido: a GUI inicia diretamente.

-- HUB PRINCIPAL
-- ============================================================
function _223HUB_MAIN()

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UIS             = game:GetService("UserInputService")
local _mouseHeld={}
local _M3,_M4,_M5
pcall(function() _M3=Enum.UserInputType.MouseButton3; _M4=Enum.UserInputType.MouseButton4; _M5=Enum.UserInputType.MouseButton5 end)
local function InputMouseAlias(inp)
    local u=tostring(inp and inp.UserInputType or "")
    local k=tostring(inp and inp.KeyCode or "")
    local raw=u.." "..k
    if raw:find("MouseButton1",1,true) then return "Mouse1" end
    if raw:find("MouseButton2",1,true) then return "Mouse2" end
    if raw:find("MouseButton3",1,true) then return "Mouse3" end
    if raw:find("MouseButton4",1,true) or raw:find("ButtonX",1,true) then return "Mouse4" end
    if raw:find("MouseButton5",1,true) or raw:find("ButtonY",1,true) then return "Mouse5" end
    return nil
end
local function BindFromName(name)
    if name=="Mouse1" or name=="MouseButton1" then return Enum.UserInputType.MouseButton1 end
    if name=="Mouse2" or name=="MouseButton2" then return Enum.UserInputType.MouseButton2 end
    if name=="Mouse3" or name=="MouseButton3" then return _M3 or "Mouse3" end
    if name=="Mouse4" or name=="MouseButton4" then return _M4 or "Mouse4" end
    if name=="Mouse5" or name=="MouseButton5" then return _M5 or "Mouse5" end
    if name=="ScrollUp" or name=="ScrollDown" then return name end
    local ok,k=pcall(function() return Enum.KeyCode[name] end)
    return ok and k or Enum.KeyCode.Unknown
end
local function IsBindHeldNow(bind)
    if type(bind)=="string" then
        if bind=="Mouse1" or bind=="Mouse2" or bind=="Mouse3" or bind=="Mouse4" or bind=="Mouse5" then return _mouseHeld[bind]==true end
        return false
    end
    local isMouse=(bind==Enum.UserInputType.MouseButton1 or bind==Enum.UserInputType.MouseButton2 or bind==_M3 or bind==_M4 or bind==_M5)
    if isMouse then
        if _mouseHeld[bind]~=nil then return _mouseHeld[bind]==true end
        local ok,v=pcall(function() return UIS:IsMouseButtonPressed(bind) end)
        return ok and v==true
    end
    if bind and bind~=Enum.KeyCode.Unknown then
        local ok,v=pcall(function() return UIS:IsKeyDown(bind) end)
        return ok and v==true
    end
    return false
end
local CoreGui         = game:GetService("CoreGui")
local TweenService    = game:GetService("TweenService")
local HttpService     = game:GetService("HttpService")
local Workspace       = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local LP    = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam   = Workspace.CurrentCamera

local function Rejoin()
    local ok,err=pcall(function() TeleportService:Teleport(game.PlaceId,LP) end)
    if not ok then warn("[223JHUB] Rejoin failed: "..tostring(err)) end
end
local function ServerHop()
    local url="https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/Public?sortOrder=Asc&limit=100"
    local ok,raw=pcall(function()
        if game.HttpGet then return game:HttpGet(url) end
        return HttpService:GetAsync(url)
    end)
    local data
    if ok and raw then pcall(function() data=HttpService:JSONDecode(raw) end) end
    if data and type(data.data)=="table" then
        local candidates={}
        for _,srv in ipairs(data.data) do
            if srv.id and srv.id~=game.JobId and tonumber(srv.playing or 0)<tonumber(srv.maxPlayers or 0) then candidates[#candidates+1]=srv.id end
        end
        if #candidates>0 then
            local target=candidates[math.random(1,#candidates)]
            local hopped,hErr=pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,target,LP) end)
            if hopped then return end
            warn("[223JHUB] Server hop instance failed: "..tostring(hErr))
        end
    end
    Rejoin()
end

if _G._223HUB_Kill then pcall(_G._223HUB_Kill) end
local _conns = {}
local _resources = {}
local _hubShutdown=false
local _diag={}
local function AC(c)
    if c then _conns[#_conns+1]=c end
    return c
end
local function AR(resource)
    if resource then _resources[resource]=true end
    return resource
end
local function ReleaseResource(resource)
    if not resource then return end
    _resources[resource]=nil
    pcall(function() resource.Visible=false end)
    pcall(function() resource:Remove() end)
    pcall(function() resource:Destroy() end)
end
local function CleanupResources()
    for resource in pairs(_resources) do ReleaseResource(resource) end
    _resources={}
end
local function DiagModule(name,status,err,elapsed)
    _diag[name]={status=status or "unknown",error=err and tostring(err) or nil,lastUpdate=os.clock(),elapsed=elapsed or 0}
end
local function DiagError(name,err)
    DiagModule(name,"error",err,0)
end
local function DiagSummary()
    local out={}
    for name,v in pairs(_diag) do
        local err=v.error and " err="..tostring(v.error) or ""
        out[#out+1]=name.."="..tostring(v.status).." ("..string.format("%.2fms",(v.elapsed or 0)*1000)..")"..err
    end
    table.sort(out)
    local resourceCount=0; for _ in pairs(_resources) do resourceCount=resourceCount+1 end
    out[#out+1]="connections="..tostring(#_conns).." resources="..tostring(resourceCount)
    return #out>0 and table.concat(out," | ") or "No diagnostics recorded"
end

_G._223HUB_Kill = function()
    if _hubShutdown then return end
    _hubShutdown=true
    for _,c in ipairs(_conns) do pcall(function() c:Disconnect() end) end
    _conns={}
    if _G._223HUB_DrawPool then
        for _,d in pairs(_G._223HUB_DrawPool) do pcall(function() d:Remove() end) end
        _G._223HUB_DrawPool={}
    end
    CleanupResources()
    if _GuiParent:FindFirstChild("223TYHUB") then _GuiParent:FindFirstChild("223TYHUB"):Destroy() end
end
_G._223HUB_DrawPool = _G._223HUB_DrawPool or {}
local DrawPool = _G._223HUB_DrawPool

local _espInterval=1/30
local Cfg = {
    ESP = {
        Enabled=false, Box=false, Fill=false, Names=false,
        HP=false, Tracers=false, Dist=false, WallCheck=false,
        TeamCheck=false, HeldTool=false,
        MaxDist=500, TrackList={},
        BoxColor=Color3.fromRGB(220,40,40), FillColor=Color3.fromRGB(220,40,40),
        NameColor=Color3.fromRGB(255,255,255), TracerColor=Color3.fromRGB(220,40,40),
        DistColor=Color3.fromRGB(200,200,200), HPColor=Color3.fromRGB(0,255,0),
        HPBgColor=Color3.fromRGB(60,0,0), ToolColor=Color3.fromRGB(255,210,50),
        Skeleton=false, SkelColor=Color3.fromRGB(0,220,255), Mode="Default (Universal)",
                UpdateRate=30, RadarEnabled=false, RadarTarget="", RadarHighlight=false, RadarColorName="Yellow", ESPColorName="Red",

    },
    Aim = {
        Aimbot=false, AimbotType="Default (Universal)", WallCheck=false, TeamCheck=false,
        Prediction=false, PredStr=3,
        FOV=150, ShowFOV=false, UseFOV=false, FOVFollow=false, CameraFollow=false,
        MaxDistanceEnabled=false, MaxDistance=500, FOVColorName="Red",
        AimPart="Head", Smoothness=8,
        AimKey=Enum.KeyCode.E, AimKeyName="E",
        AimStrength=70, Blacklist={}, FocusPriorityEnabled=false, FocusPriority="Closest",
    },
    Trigger = { Enabled=false, TeamCheck=false, Delay=80, AutoBot=false,
                ClickControl=false, ClickCount=3,
                OneShot=false, OneShotDelay=3 },
    Misc = {
        Fly=false, FlySpeed=50, FlyBoost=false, Noclip=false,
        Speed=false, WalkSpeed=25, AntiAFK=false,
        HitboxExtender=false, TeamCheck=false, HitboxSize=8, HitboxPart="All",
        JumpMod=false, JumpPower=80, JumpMethod="JumpPower",
        InfJump=false, AntiRag=false, ClickTp=false, SpinBot=false,
        CrashLag=false, AutoJump=false,
        AlwaysSprint=false,
    },
    Settings = {
        ToggleKey=Enum.KeyCode.Semicolon,
        ESPKey=Enum.KeyCode.F2,      ESPKeyName="F2",
        AimbotKey=Enum.KeyCode.F3,   AimbotKeyName="F3",
        FlyKey=Enum.KeyCode.F5,      FlyKeyName="F5",
        NoclipKey=Enum.KeyCode.F6,   NoclipKeyName="F6",
SpeedKey=Enum.KeyCode.F7,    SpeedKeyName="F7",
        ClickTpKey=Enum.KeyCode.F8, ClickTpKeyName="F8",
        ToggleKeyName="Semicolon",
        BlockGameInput=false, VSync=false,
    },
}

-- ============================================================
-- SAVES
-- ============================================================
local SDIR="223TYHUB_Configs/"
local function EnsDir() pcall(function() if not isfolder(SDIR) then makefolder(SDIR) end end) end
local function SafeSer(t)
    local o={}
    for k,v in pairs(t) do
        if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then o[k]=v
        elseif type(v)=="table" then o[k]=SafeSer(v) end
    end
    return o
end
local function SerCfg()
    local t={ESP=SafeSer(Cfg.ESP),Aim=SafeSer(Cfg.Aim),
             Trigger=SafeSer(Cfg.Trigger),Misc=SafeSer(Cfg.Misc),
             Settings=SafeSer(Cfg.Settings)}
    t.Aim.AimKeyName=Cfg.Aim.AimKeyName
    for k,v in pairs(Cfg.Settings) do if type(v)=="string" then t.Settings[k]=v end end
    return HttpService:JSONEncode(t)
end
local function ValidateConfig(t)
    if type(t)~="table" then return false,"Config root must be an object" end
    for _,section in ipairs({"ESP","Aim","Trigger","Misc","Settings"}) do
        if t[section]~=nil and type(t[section])~="table" then return false,"Section "..section.." must be an object" end
    end
    if t.Aim then
        if t.Aim.Blacklist~=nil and type(t.Aim.Blacklist)~="table" then return false,"Aim.Blacklist must be an object" end
        if t.Aim.AimKeyName~=nil and type(t.Aim.AimKeyName)~="string" then return false,"Aim.AimKeyName must be text" end
    end
    if t.Settings then
        for _,key in ipairs({"ToggleKeyName","ESPKeyName","AimbotKeyName","FlyKeyName","NoclipKeyName","SpeedKeyName","ClickTpKeyName"}) do
            if t.Settings[key]~=nil and type(t.Settings[key])~="string" then return false,"Settings."..key.." must be text" end
        end
    end
    if t.ESP and t.ESP.UpdateRate~=nil and (type(t.ESP.UpdateRate)~="number" or t.ESP.UpdateRate<1 or t.ESP.UpdateRate>60) then return false,"ESP.UpdateRate must be between 1 and 60" end
    return true
end
local SyncGuiFromCfg
local function ApplySave(t)
    local valid,err=ValidateConfig(t)
    if not valid then DiagError("Saves",err); return false,err end
    if not t then return false,"Empty config" end
    local function mg(d,s) if not s then return end
        for k,v in pairs(s) do
            if type(v)=="table" then if type(d[k])=="table" then mg(d[k],v) end
            elseif d[k]~=nil then d[k]=v end
        end
    end
    mg(Cfg.ESP,t.ESP); mg(Cfg.Aim,t.Aim)
    mg(Cfg.Trigger,t.Trigger); mg(Cfg.Misc,t.Misc)
    mg(Cfg.Settings,t.Settings)
    local M3,M4,M5
    pcall(function() M3=Enum.UserInputType.MouseButton3; M4=Enum.UserInputType.MouseButton4; M5=Enum.UserInputType.MouseButton5 end)
    local function TK(n,fallback)
        if n=="Mouse1" then return Enum.UserInputType.MouseButton1 end
        if n=="Mouse2" then return Enum.UserInputType.MouseButton2 end
        if n=="Mouse3" then return M3 or fallback end
        if n=="Mouse4" then return M4 or fallback end
        if n=="Mouse5" then return M5 or fallback end
        if n=="ScrollUp" or n=="ScrollDown" then return n end
        local aliases={ [";"]="Semicolon", ["`"]="Backquote", ["["]="LeftBracket", ["]"]="RightBracket", ["\\"]="Backslash", ["'"]="Quote", [","]="Comma", ["."]="Period", ["/"]="Slash", ["-"]="Minus", ["="]="Equals" }
        n=aliases[n] or n
        if not n then return fallback or Enum.KeyCode.Unknown end
        local ok,k=pcall(function() return Enum.KeyCode[n] end)
        if ok and k and k~=Enum.KeyCode.Unknown then return k end
        return fallback or Enum.KeyCode.Unknown
    end
    local function KeepBind(current,default)
        return (current and current~=Enum.KeyCode.Unknown) and current or default
    end
    Cfg.Aim.AimKey=TK(Cfg.Aim.AimKeyName,KeepBind(Cfg.Aim.AimKey,Enum.KeyCode.E))
    Cfg.Settings.ToggleKey=TK(Cfg.Settings.ToggleKeyName,KeepBind(Cfg.Settings.ToggleKey,Enum.KeyCode.Semicolon))
    Cfg.Settings.ESPKey=TK(Cfg.Settings.ESPKeyName,KeepBind(Cfg.Settings.ESPKey,Enum.KeyCode.F2))
    Cfg.Settings.AimbotKey=TK(Cfg.Settings.AimbotKeyName,KeepBind(Cfg.Settings.AimbotKey,Enum.KeyCode.F3))
    Cfg.Settings.FlyKey=TK(Cfg.Settings.FlyKeyName,KeepBind(Cfg.Settings.FlyKey,Enum.KeyCode.F5))
    Cfg.Settings.NoclipKey=TK(Cfg.Settings.NoclipKeyName,KeepBind(Cfg.Settings.NoclipKey,Enum.KeyCode.F6))
    Cfg.Settings.SpeedKey=TK(Cfg.Settings.SpeedKeyName,KeepBind(Cfg.Settings.SpeedKey,Enum.KeyCode.F7))
    Cfg.Settings.ClickTpKey=TK(Cfg.Settings.ClickTpKeyName,KeepBind(Cfg.Settings.ClickTpKey,Enum.KeyCode.F8))
    Cfg.ESP.UpdateRate=math.clamp(tonumber(Cfg.ESP.UpdateRate) or 30,1,60)
    _espInterval=1/Cfg.ESP.UpdateRate
    if SyncGuiFromCfg then pcall(SyncGuiFromCfg) end
    DiagModule("Saves","ok",nil,0)
    return true
end
local function SaveCfg(name)
    if not writefile then return false,"writefile indisponvel" end
    EnsDir()
    local fn=SDIR..name:gsub("[^%w_%-]","_")..".json"
    local ok,e=pcall(writefile,fn,SerCfg())
    return ok, ok and fn or tostring(e)
end
local function LoadCfg(name)
    if not readfile then return false,"readfile indisponvel" end
    local fn=SDIR..name:gsub("[^%w_%-]","_")..".json"
    if isfile and not isfile(fn) then return false,"No encontrado" end
    local ok,data=pcall(readfile,fn); if not ok then return false,"Erro" end
    local ok2,t=pcall(function() return HttpService:JSONDecode(data) end)
    if not ok2 then DiagError("Saves","JSON invalido"); return false,"JSON invalido" end
    local applied,applyErr=ApplySave(t)
    if not applied then return false,applyErr end
    return true,fn
end
local function ListCfgs()
    if not listfiles then return {} end
    EnsDir()
    local ok,lst=pcall(listfiles,SDIR)
    if not ok or type(lst)~="table" then return {} end
    local out={}
    for _,f in ipairs(lst) do
        local n=tostring(f):match("([^/\\]+)%.json$")
        if n then out[#out+1]=n end
    end
    return out
end
local function DelCfg(name)
    if not delfile then return false end
    pcall(delfile,SDIR..name:gsub("[^%w_%-]","_")..".json"); return true
end

-- ============================================================
-- DRAWING HELPER
-- ============================================================
local function ND(kind, props)
    local ok, d = pcall(Drawing.new, kind)
    if not ok or not d then return nil end
    if props then for k,v in pairs(props) do pcall(function() d[k]=v end) end end
    DrawPool[d]=true
    AR(d)
    return d
end
local function SafeSet(d, props)
    if not d then return end
    for k,v in pairs(props) do pcall(function() d[k]=v end) end
end
local function SafeHide(d)
    if d then pcall(function() d.Visible=false end) end
end

-- ============================================================
-- UTILITRIOS
-- ============================================================
local function W2S(worldPos)
    local sp, onScreen = Cam:WorldToViewportPoint(worldPos)
    return Vector2.new(sp.X, sp.Y), (sp.Z > 0) and onScreen
end

local function GetBounds(char)
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local head   = char:FindFirstChild("Head")
    local topPos = head and (head.Position + Vector3.new(0, head.Size.Y/2 + 0.1, 0))
                        or  (hrp.Position + Vector3.new(0, 3.3, 0))
    local botPos = hrp.Position - Vector3.new(0, 3.0, 0)
    local tZ = (Cam:WorldToViewportPoint(topPos)).Z
    local bZ = (Cam:WorldToViewportPoint(botPos)).Z
    if tZ <= 0 and bZ <= 0 then return nil end
    local topSP = W2S(topPos)
    local botSP = W2S(botPos)
    local h = math.abs(botSP.Y - topSP.Y)
    if h < 3 then return nil end
    local w = h * 0.6
    return topSP.X - w/2, topSP.Y, w, h
end

local function GetDist(char)
    local myc = LP.Character
    local a = char and char:FindFirstChild("HumanoidRootPart")
    local b = myc  and myc:FindFirstChild("HumanoidRootPart")
    if not a or not b then return nil end
    return math.floor((a.Position - b.Position).Magnitude)
end

local function GetHP(char)
    local h = char and char:FindFirstChildOfClass("Humanoid")
    if not h then return 0, 100 end
    return math.max(0, h.Health), math.max(1, h.MaxHealth)
end

-- ============================================================
-- WALLCHECK OTIMIZADO
-- ============================================================
local _rpCache = {}   -- [player] = { char, myc, rp, parts }

local function _BuildRP(char, myc)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local ex = {}
    for _,v in ipairs(myc:GetDescendants())  do if v:IsA("BasePart") then ex[#ex+1]=v end end
    for _,v in ipairs(char:GetDescendants()) do if v:IsA("BasePart") then ex[#ex+1]=v end end
    rp.FilterDescendantsInstances = ex
    return rp
end

local function GetRaycastParams(player, char, myc)
    local cached = _rpCache[player]
    if cached and cached.char == char and cached.myc == myc then
        return cached.rp
    end
    local rp = _BuildRP(char, myc)
    _rpCache[player] = { char=char, myc=myc, rp=rp }
    return rp
end

local function IsVisible(player, char)
    local myc  = LP.Character
    local mine = myc and myc:FindFirstChild("HumanoidRootPart")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not mine or not hrp then return false end
    local rp = GetRaycastParams(player, char, myc)
    local res = Workspace:Raycast(mine.Position, hrp.Position - mine.Position, rp)
    return res == nil
end

-- Cache de visibilidade por frame: dois arrays paralelos evitam alocao de tabela
local _visResultCache  = {}   -- [player] = bool
local _visFrameCache   = {}   -- [player] = frameStamp
local _visFrameStamp   = 0

local function IsVisibleCached(player, char)
    local frame = _visFrameStamp
    if _visFrameCache[player] == frame then
        return _visResultCache[player]
    end
    local result = IsVisible(player, char)
    _visResultCache[player] = result
    _visFrameCache[player]  = frame
    return result
end

local function SameTeam(p)
    if not p or p==LP then return false end
    local mt=LP.Team; local pt=p.Team
    return mt~=nil and pt~=nil and mt==pt
end

local function IsValidTarget(p)
    if not p or p==LP then return false end
    if type(Cfg.Aim.Blacklist)~="table" then Cfg.Aim.Blacklist={} end
    if Cfg.Aim.Blacklist[p.Name]==true then return false end
    if Cfg.Aim.TeamCheck and SameTeam(p) then return false end
    local c=p.Character; if not c then return false end
    local h=c:FindFirstChildOfClass("Humanoid")
    return h~=nil and h.Health>0
end

local function GetHeldTool(char)
    if not char then return nil end
    for _,v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then return v.Name end
    end
    return nil
end

-- ============================================================
-- OTIMIZAO 2: ClosestTarget  usa cache de visibilidade
-- ============================================================
local function ClosestTarget()
    local vs=Cam.ViewportSize
    local center=Vector2.new(vs.X/2,vs.Y/2)
    local best,bestScore=nil,nil
    for _,p in ipairs(Players:GetPlayers()) do
        if not IsValidTarget(p) then continue end
        local c=p.Character
        local part=c:FindFirstChild(Cfg.Aim.AimPart) or c:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        if Cfg.Aim.WallCheck and not IsVisibleCached(p,c) then continue end
        local sp,onScreen=W2S(part.Position)
        if not onScreen then continue end
        local screenDist=(sp-center).Magnitude
        if Cfg.Aim.UseFOV and screenDist>Cfg.Aim.FOV then continue end
        local localRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local worldDistance=localRoot and (part.Position-localRoot.Position).Magnitude or math.huge
        if Cfg.Aim.MaxDistanceEnabled and worldDistance>Cfg.Aim.MaxDistance then continue end
        local hum=c:FindFirstChildOfClass("Humanoid")
        local health=hum and hum.Health or 0
        local score=screenDist
        if Cfg.Aim.FocusPriorityEnabled then
            local mode=Cfg.Aim.FocusPriority
            if mode=="Farthest" then score=-screenDist
            elseif mode=="Most Health" then score=-health
            elseif mode=="Least Health" then score=health
            else score=screenDist end
        end
        if bestScore==nil or score<bestScore then bestScore=score; best=p end
    end
    return best
end

-- ============================================================
-- ESP OBJECTS
-- ============================================================
local ESPO = {}
local _espLastUpdate=0

local BONES_R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local BONES_R6 = {
    {"Head","Torso"},
    {"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}
local MAX_BONES = 14

local function MakeESP(p)
    if p==LP or ESPO[p] then return end
    local d={}
    d.Box=ND("Square",{Filled=false,Color=Cfg.ESP.BoxColor,Transparency=0.7,Thickness=1.5,Visible=false})
    d.Fill=ND("Square",{Filled=true,Color=Cfg.ESP.FillColor,Transparency=0.7,Thickness=0,Visible=false})
    d.Name=ND("Text",{Size=14,Color=Cfg.ESP.NameColor,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.Dist=ND("Text",{Size=12,Color=Cfg.ESP.DistColor,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.HPBg=ND("Square",{Filled=true,Color=Cfg.ESP.HPBgColor,Transparency=0.7,Thickness=0,Visible=false})
    d.HPBar=ND("Square",{Filled=true,Color=Color3.fromRGB(0,255,0),Transparency=0,Thickness=0,Visible=false})
    d.Tracer=ND("Line",{Thickness=1.5,Color=Cfg.ESP.TracerColor,Transparency=0.7,Visible=false})
    d.Tool=ND("Text",{Size=12,Color=Cfg.ESP.ToolColor,Outline=true,OutlineColor=Color3.new(0,0,0),Center=true,Visible=false})
    d.Skel={}
    for i=1,MAX_BONES do d.Skel[i]=ND("Line",{Thickness=1.2,Color=Cfg.ESP.SkelColor,Transparency=0.7,Visible=false}) end
    ESPO[p]=d
end

local function KillESP(p)
    local d = ESPO[p]
    if not d then return end
    local singles = {"Box","Fill","Name","Dist","HPBg","HPBar","Tracer","Tool"}
    for _,k in ipairs(singles) do
        if d[k] then
            pcall(function() d[k].Visible=false; d[k]:Remove() end)
            DrawPool[d[k]] = nil
        end
    end
    if d.Skel then
        for _,ln in ipairs(d.Skel) do
            pcall(function() ln.Visible=false; ln:Remove() end)
            DrawPool[ln]=nil
        end
    end
    _visResultCache[p] = nil
    _visFrameCache[p]  = nil
    _rpCache[p] = nil
    ESPO[p] = nil
end

local function HideESP(d)
    local singles = {"Box","Fill","Name","Dist","HPBg","HPBar","Tracer","Tool"}
    for _,k in ipairs(singles) do SafeHide(d[k]) end
    if d.Skel then for _,ln in ipairs(d.Skel) do SafeHide(ln) end end
end

-- ============================================================
-- FOV CIRCLE
-- OTIMIZAO: s recalcula quando FOV, posio ou estado mudam
-- ============================================================
local FOV_SEGS = 48
local _fovLines = {}
for i=1,FOV_SEGS do
    local ln = ND("Line",{Thickness=1.5, Color=Color3.fromRGB(220,50,50), Transparency=0.7, Visible=false})
    _fovLines[i] = ln
end

local _fovLastR   = -1
local _fovLastCX  = -1
local _fovLastCY  = -1
local _fovLastVis = nil
local _fovLastColor = nil
local FOVColors={Red=Color3.fromRGB(220,40,40),Blue=Color3.fromRGB(40,130,240),Purple=Color3.fromRGB(160,50,220),Yellow=Color3.fromRGB(230,190,40),White=Color3.fromRGB(255,255,255)}

-- OTIMIZAO: pre-calcula ngulos do FOV uma nica vez
local _fovCos = {}
local _fovSin = {}
for i=1,FOV_SEGS do
    _fovCos[i] = { math.cos((i-1)/FOV_SEGS * math.pi*2), math.cos(i/FOV_SEGS * math.pi*2) }
    _fovSin[i] = { math.sin((i-1)/FOV_SEGS * math.pi*2), math.sin(i/FOV_SEGS * math.pi*2) }
end

local function UpdateFOVCircle()
    local show = Cfg.Aim.ShowFOV
    local cx, cy
    if Cfg.Aim.FOVFollow then
        local mpos = UIS:GetMouseLocation()
        cx, cy = mpos.X, mpos.Y
    else
        local vs = Cam.ViewportSize
        cx, cy = vs.X/2, vs.Y/2
    end
        local r = Cfg.Aim.FOV
    local colorName=Cfg.Aim.FOVColorName or "Red"
    if show == _fovLastVis and r == _fovLastR and math.abs(cx-_fovLastCX)<0.5 and math.abs(cy-_fovLastCY)<0.5 and colorName==_fovLastColor then
        return
    end
    _fovLastVis=show; _fovLastR=r; _fovLastCX=cx; _fovLastCY=cy; _fovLastColor=colorName

    for i=1, FOV_SEGS do
        local ln = _fovLines[i]
                if not ln then continue end
        local fovColor=FOVColors[Cfg.Aim.FOVColorName] or FOVColors.Red
        pcall(function()
            ln.Color=fovColor
            ln.From    = Vector2.new(cx + _fovCos[i][1]*r, cy + _fovSin[i][1]*r)
            ln.To      = Vector2.new(cx + _fovCos[i][2]*r, cy + _fovSin[i][2]*r)
            ln.Visible = show
        end)
    end
end

-- ============================================================
-- ============================================================
-- TRIGGERBOT
-- ClickControl / One-Shot: modos de disparo do TriggerBot
-- ============================================================
local _tbLast      = 0
local _tbFiring    = false  -- evita disparos sobrepostos
local _osShotReady = true   -- One-Shot: libera o prximo disparo
local _osLastTgt   = nil    -- One-Shot: player do ltimo disparo

local function _DoClicks(n)
    if _tbFiring then return end
    _tbFiring = true
    task.spawn(function()
        local vms = game:GetService("VirtualInputManager")
        for i = 1, math.max(1, n) do
            pcall(function() vms:SendMouseButtonEvent(0,0,0,true,game,0) end)
            task.wait(0.05)
            pcall(function() vms:SendMouseButtonEvent(0,0,0,false,game,0) end)
            if i < n then task.wait(0.04) end
        end
        _tbFiring = false
    end)
end

AC(RunService.Heartbeat:Connect(function()
    if not Cfg.Trigger.Enabled then return end
    if tick()-_tbLast < Cfg.Trigger.Delay/1000 then return end
    local tgt=Mouse.Target; if not tgt then return end
    local model=tgt:FindFirstAncestorOfClass("Model"); if not model then return end
    local p=Players:GetPlayerFromCharacter(model); if not p then return end
    if not IsValidTarget(p) then return end
    if Cfg.Trigger.TeamCheck and SameTeam(p) then return end

    -- One-Shot: 1 disparo por lock, depois aguarda delay configurvel
    if Cfg.Trigger.OneShot then
        -- Troca de alvo  reseta imediatamente para atirar
        if p ~= _osLastTgt then
            _osShotReady = true
            _osLastTgt   = p
        end
        if not _osShotReady then return end
        _osShotReady = false
        _tbLast = tick()
        local clicks = (Cfg.Trigger.ClickControl and Cfg.Trigger.ClickCount) or 1
        _DoClicks(clicks)
        -- Aps o delay, libera prximo tiro no mesmo alvo
        task.delay(Cfg.Trigger.OneShotDelay, function()
            if _osLastTgt == p then _osShotReady = true end
        end)
        return
    end

    _tbLast=tick()
    local clicks = (Cfg.Trigger.ClickControl and Cfg.Trigger.ClickCount) or 1
    _DoClicks(clicks)
end))

-- ============================================================
-- FLY
-- ============================================================
local _flyConn,_bv,_bg=nil,nil,nil
local function EnableFly()
    if _flyConn then return end
    local char=LP.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum.PlatformStand=true
    _bv=Instance.new("BodyVelocity"); _bv.MaxForce=Vector3.new(1e5,1e5,1e5); _bv.Velocity=Vector3.zero; _bv.Parent=hrp
    _bg=Instance.new("BodyGyro");    _bg.MaxTorque=Vector3.new(1e5,1e5,1e5); _bg.P=1e4; _bg.Parent=hrp
    _flyConn=AC(RunService.RenderStepped:Connect(function()
        if not Cfg.Misc.Fly then return end
        if not _bv or not _bv.Parent then return end
        local cf=Cam.CFrame; local vel=Vector3.zero
        local spd=Cfg.Misc.FlySpeed*(Cfg.Misc.FlyBoost and 3 or 1)
        if UIS:IsKeyDown(Enum.KeyCode.W)         then vel=vel+cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.S)         then vel=vel-cf.LookVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.A)         then vel=vel-cf.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.D)         then vel=vel+cf.RightVector*spd end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then vel=vel+Vector3.new(0,spd,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then vel=vel-Vector3.new(0,spd*0.6,0) end
        _bv.Velocity=vel; _bg.CFrame=cf
    end))
end
local function DisableFly()
    if _flyConn then _flyConn:Disconnect(); _flyConn=nil end
    if _bv then pcall(function() _bv:Destroy() end); _bv=nil end
    if _bg then pcall(function() _bg:Destroy() end); _bg=nil end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand=false end
end

-- ============================================================
-- NOCLIP
-- ============================================================
local _ncConn=nil
local function EnableNoclip()
    if _ncConn then return end
    _ncConn=AC(RunService.Stepped:Connect(function()
        if not Cfg.Misc.Noclip then return end
        local char=LP.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end))
end
local function DisableNoclip()
    if _ncConn then _ncConn:Disconnect(); _ncConn=nil end
    local char=LP.Character; if not char then return end
    -- Restaura coliso: BaseParts que deveriam ter coliso de volta
    -- (exclui partes que naturalmente no tm coliso, como HRP em alguns jogos)
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            -- HumanoidRootPart normalmente no tem coliso no Roblox padro
            if p.Name == "HumanoidRootPart" then
                p.CanCollide = false
            else
                p.CanCollide = true
            end
        end
    end
end

-- ============================================================
-- SPEED / JUMP
-- ============================================================
local function ApplySpeed()
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum.WalkSpeed=Cfg.Misc.Speed and Cfg.Misc.WalkSpeed or 16
end
local function ApplyJump()
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if not Cfg.Misc.JumpMod then hum.JumpPower=50; return end
    hum.JumpPower=Cfg.Misc.JumpPower
end
AC(UIS.JumpRequest:Connect(function()
    if not Cfg.Misc.InfJump then return end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end))

AC(RunService.Heartbeat:Connect(function()
    if not Cfg.Misc.AlwaysSprint then return end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if hum.MoveDirection.Magnitude > 0 then
        hum.WalkSpeed=math.max(hum.WalkSpeed, Cfg.Misc.Speed and Cfg.Misc.WalkSpeed or 21)
    end
end))

-- ============================================================
-- ANTI AFK / ANTI RAGDOLL
-- ============================================================
LP.Idled:Connect(function()
    if not Cfg.Misc.AntiAFK then return end
    local vim=game:GetService("VirtualInputManager")
    pcall(function() vim:SendKeyEvent(true,Enum.KeyCode.ButtonL3,false,game) end)
    task.wait(0.5)
    pcall(function() vim:SendKeyEvent(false,Enum.KeyCode.ButtonL3,false,game) end)
end)

AC(RunService.Heartbeat:Connect(function()
    if not Cfg.Misc.AntiRag then return end
    local char=LP.Character; if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local st=hum:GetState()
    if st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end))

-- ============================================================
-- HITBOX EXTENDER
-- OTIMIZAO: reutiliza tabela pset em vez de criar por chamada
-- ============================================================
local _hbConns={}
local _hbOriginals={}
local HBP={
    All  ={"Head","Torso","UpperTorso","LowerTorso","HumanoidRootPart","Left Arm","Right Arm","Left Leg","Right Leg","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"},
    Head ={"Head"}, Torso={"Torso","UpperTorso","LowerTorso"},
    Arms ={"Left Arm","Right Arm","LeftUpperArm","RightUpperArm","LeftLowerArm","RightLowerArm","LeftHand","RightHand"},
    Legs ={"Left Leg","Right Leg","LeftUpperLeg","RightUpperLeg","LeftLowerLeg","RightLowerLeg","LeftFoot","RightFoot"},
    HRP  ={"HumanoidRootPart"},
}
-- Pr-converte HBP para sets, evita rebuild por chamada
local HBP_SETS = {}
for k, names in pairs(HBP) do
    local s = {}
    for _,n in ipairs(names) do s[n]=true end
    HBP_SETS[k] = s
end

local function RestoreHitbox(p)
    local originals=_hbOriginals[p]
    if not originals then return end
    for part,state in pairs(originals) do
        if part and part.Parent and state then
            pcall(function() part.Size=state.Size end)
            pcall(function() part.LocalTransparencyModifier=state.LocalTransparencyModifier end)
        end
    end
    _hbOriginals[p]=nil
end
local function ApplyHBChar(p,char)
    if not p or not char or not Cfg.Misc.HitboxExtender then return end
    if Cfg.Misc.TeamCheck and SameTeam(p) then return end
    local pset=HBP_SETS[Cfg.Misc.HitboxPart] or HBP_SETS.All
    local size=math.clamp(tonumber(Cfg.Misc.HitboxSize) or 8,2,80)
    local originals=_hbOriginals[p] or {}; _hbOriginals[p]=originals
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and pset[part.Name] then
            if not originals[part] then
                originals[part]={Size=part.Size,LocalTransparencyModifier=part.LocalTransparencyModifier}
            end
            part.Size=Vector3.new(size,size,size)
            part.LocalTransparencyModifier=0.8
        end
    end
end
local function SetHitbox(p,on)
    if p==LP then return end
    if _hbConns[p] then _hbConns[p]:Disconnect(); _hbConns[p]=nil end
    if not on then RestoreHitbox(p); return end
    RestoreHitbox(p)
    if p.Character then ApplyHBChar(p,p.Character) end
    _hbConns[p]=p.CharacterAdded:Connect(function(char)
        RestoreHitbox(p)
        task.wait(0.5)
        if Cfg.Misc.HitboxExtender then ApplyHBChar(p,char) end
    end)
end
local function RefreshHitboxes()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then SetHitbox(p,Cfg.Misc.HitboxExtender) end
    end
end

-- ============================================================
-- ============================================================
-- Deadline target resolver: uses the game's characters container instead of Players.Character.
local function GetDeadlineCharacterFolder()
    return Workspace:FindFirstChild("characters") or Workspace:FindFirstChild("Characters")
end

local function DeadlineRoot(model)
    return model and (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart",true))
end

local function DeadlinePlayer(model)
    local p=Players:GetPlayerFromCharacter(model)
    if p then return p end
    for _,candidate in ipairs(Players:GetPlayers()) do
        if candidate.Name==model.Name or candidate.DisplayName==model.Name then return candidate end
    end
    return nil
end

local function DeadlineVisible(model,part)
    if not Cfg.Aim.WallCheck then return true end
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={LP.Character}
    local hit=Workspace:Raycast(Cam.CFrame.Position,part.Position-Cam.CFrame.Position,params)
    return not hit or hit.Instance:IsDescendantOf(model)
end


-- Deadline ESP pool: the Deadline game stores character models in Workspace.characters,
-- so it cannot reuse the universal Player-keyed ESPO table.
local DeadlineDrawings={}
local function MakeDeadlineESP(model)
    if DeadlineDrawings[model] then return DeadlineDrawings[model] end
    local d={
        Box=ND("Square",{Filled=false,Thickness=1,Transparency=1,Color=Color3.fromRGB(0,255,255),Visible=false}),
        Name=ND("Text",{Size=13,Center=true,Outline=true,Color=Color3.fromRGB(255,255,100),Visible=false}),
        Tracer=ND("Line",{Thickness=1,Transparency=0.75,Color=Color3.fromRGB(255,0,0),Visible=false}),
        Tool=ND("Text",{Size=12,Center=true,Outline=true,Color=Cfg.ESP.ToolColor,Visible=false}),
        HPBar=ND("Square",{Filled=true,Color=Color3.fromRGB(0,255,0),Visible=false}),
        HPBg=ND("Square",{Filled=true,Color=Cfg.ESP.HPBgColor,Transparency=0.7,Visible=false})
    }
    DeadlineDrawings[model]=d
    return d
end
local function HideDeadlineESP(d)
    if not d then return end
    for _,v in pairs(d) do SafeHide(v) end
end
local function DestroyDeadlineESP(model)
    local d=DeadlineDrawings[model]
    if not d then return end
    for _,v in pairs(d) do pcall(function() v:Remove() end) end
    DeadlineDrawings[model]=nil
end
local function UpdateDeadlineESP()
    local folder=Workspace:FindFirstChild("characters") or Workspace:FindFirstChild("Characters")
    if not folder then
        for _,d in pairs(DeadlineDrawings) do HideDeadlineESP(d) end
        return
    end
    local localChar=LP.Character
    local localRoot=localChar and (localChar:FindFirstChild("HumanoidRootPart") or localChar:FindFirstChildWhichIsA("BasePart",true))
    local localPos=localRoot and localRoot.Position
    local seen={}
    for _,model in ipairs(folder:GetChildren()) do
        local root=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart",true)
        if root and model~=localChar then
            seen[model]=true
            local d=MakeDeadlineESP(model)
            local rootPos,onScreen=Cam:WorldToViewportPoint(root.Position)
            local player=DeadlinePlayer(model)
            local radarFilter=Cfg.ESP.RadarEnabled and not Cfg.ESP.RadarHighlight
            local radarAllowed=not radarFilter or Cfg.ESP.RadarTarget=="" or (player and player.Name==Cfg.ESP.RadarTarget) or model.Name==Cfg.ESP.RadarTarget
            local allowed=(not Cfg.ESP.TeamCheck or not player or not SameTeam(player)) and radarAllowed
            local dist=localPos and (root.Position-localPos).Magnitude or 0
            local visible=not Cfg.ESP.WallCheck or DeadlineVisible(model,root)
            if not onScreen or rootPos.Z<0 or dist>Cfg.ESP.MaxDist or not allowed or not visible then
                HideDeadlineESP(d)
            else
                -- Exact Deadline geometry from the supplied script.
                local topPos=Cam:WorldToViewportPoint(root.Position+Vector3.new(0,2.5,0))
                local bottomPos=Cam:WorldToViewportPoint(root.Position-Vector3.new(0,3,0))
                local boxHeight=math.abs(topPos.Y-bottomPos.Y)
                local boxWidth=boxHeight*0.6
                local boxPos=Vector2.new(rootPos.X-boxWidth/2,math.min(topPos.Y,bottomPos.Y))
                local radarFocus=Cfg.ESP.RadarHighlight and Cfg.ESP.RadarTarget~="" and player and player.Name==Cfg.ESP.RadarTarget
                local radarColor=FOVColors[Cfg.ESP.RadarColorName] or FOVColors.Yellow
                if Cfg.ESP.Box then SafeSet(d.Box,{Size=Vector2.new(boxWidth,boxHeight),Position=boxPos,Color=radarFocus and radarColor or Color3.fromRGB(0,255,255),Visible=true}) else SafeHide(d.Box) end
                if Cfg.ESP.Names then SafeSet(d.Name,{Text=model.Name.." ["..math.floor(dist).."m]",Position=Vector2.new(rootPos.X,boxPos.Y-20),Color=radarFocus and radarColor or Color3.fromRGB(255,255,100),Visible=true}) else SafeHide(d.Name) end
                if Cfg.ESP.HeldTool then
                    local tn=GetHeldTool(model)
                    if tn then SafeSet(d.Tool,{Text="["..tn.."]",Position=Vector2.new(rootPos.X,boxPos.Y-35),Visible=true}) else SafeHide(d.Tool) end
                else SafeHide(d.Tool) end
                if Cfg.ESP.Tracers then SafeSet(d.Tracer,{From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y),To=Vector2.new(rootPos.X,bottomPos.Y),Color=radarFocus and radarColor or Color3.fromRGB(255,0,0),Visible=true}) else SafeHide(d.Tracer) end
                if Cfg.ESP.HP then
                    local hum=model:FindFirstChildOfClass("Humanoid")
                    local hp=hum and hum.Health or 0
                    local maxHp=hum and hum.MaxHealth or 1
                    local ratio=math.clamp(hp/math.max(maxHp,1),0,1)
                    local barH=boxHeight*ratio
                    SafeSet(d.HPBg,{Position=Vector2.new(boxPos.X-7,boxPos.Y),Size=Vector2.new(5,boxHeight),Visible=true})
                    SafeSet(d.HPBar,{Position=Vector2.new(boxPos.X-7,boxPos.Y+boxHeight-barH),Size=Vector2.new(5,barH),Color=Color3.fromRGB(0,255,0),Visible=true})
                else SafeHide(d.HPBg); SafeHide(d.HPBar) end
            end
        end
    end
    for model,d in pairs(DeadlineDrawings) do
        if not seen[model] or not model.Parent then DestroyDeadlineESP(model) end
    end
end

-- CLEAN ESP / AIM RENDER LOOP
-- Reuses one Drawing pool per player and updates visual data at 30 FPS.
-- ============================================================
local _aimLockedTarget=nil
AC(RunService.RenderStepped:Connect(function(dt)
    local frameStart=os.clock()
    local vs=Cam.ViewportSize
    local cx,cy=vs.X/2,vs.Y/2
    UpdateFOVCircle()
    DiagModule("FOV",Cfg.Aim.ShowFOV and "active" or "idle",nil,os.clock()-frameStart)

    local aimStart=os.clock()
    local aimTargeted=false
    local aimHeld=IsBindHeldNow(Cfg.Aim.AimKey)
    if Cfg.Aim.AimKey=="ScrollUp" or Cfg.Aim.AimKey=="ScrollDown" then
        aimHeld=_G._scrollAimPulse; _G._scrollAimPulse=false
    end
    if Cfg.Aim.Aimbot and aimHeld then
        local target
        -- Quando Camera Follow está ativo, mantém o último alvo válido mesmo após sair do FOV.
        if Cfg.Aim.CameraFollow and _aimLockedTarget and IsValidTarget(_aimLockedTarget) then
            target=_aimLockedTarget
        else
            target=ClosestTarget()
            if Cfg.Aim.CameraFollow then _aimLockedTarget=target end
        end
        local targetChar=target and target.Character
        local part=targetChar and (targetChar:FindFirstChild(Cfg.Aim.AimPart) or targetChar:FindFirstChild("HumanoidRootPart"))
        if target and targetChar and part then
            aimTargeted=true
            if Cfg.Aim.CameraFollow then _aimLockedTarget=target end
            local pos=part.Position
            if Cfg.Aim.Prediction then
                local hrp=targetChar:FindFirstChild("HumanoidRootPart") or part
                if hrp then pos=pos+hrp.AssemblyLinearVelocity*(Cfg.Aim.PredStr*0.02) end
            end
            local alpha=math.clamp(math.clamp(Cfg.Aim.AimStrength/100,0.01,1)*math.clamp((101-Cfg.Aim.Smoothness)/100,0.01,1),0.005,1)
            Cam.CFrame=Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position,pos),alpha)
        end
    else
        _aimLockedTarget=nil
    end
    if not Cfg.Aim.CameraFollow or not aimHeld then _aimLockedTarget=nil end
    DiagModule("Aimbot",not Cfg.Aim.Aimbot and "disabled" or (aimTargeted and "active" or "idle"),nil,os.clock()-aimStart)

    local espStart=os.clock()
    if not Cfg.ESP.Enabled then
        DiagModule("ESP","disabled",nil,os.clock()-espStart)
        for _,d in pairs(ESPO) do HideESP(d) end
        for _,d in pairs(DeadlineDrawings) do HideDeadlineESP(d) end
        return
    end
    local now=os.clock()
    local syncInterval=Cfg.Settings.VSync and math.max(tonumber(dt) or 1/60,1/240) or _espInterval
    if now-_espLastUpdate<syncInterval then
        DiagModule("ESP","waiting",nil,os.clock()-espStart)
        return
    end
    _espLastUpdate=now
    local vsY=vs.Y
    if Cfg.ESP.Mode=="Deadline" then
        for _,d in pairs(ESPO) do HideESP(d) end
        UpdateDeadlineESP()
        DiagModule("ESP","active",nil,os.clock()-espStart)
        return
    else
        for _,d in pairs(DeadlineDrawings) do HideDeadlineESP(d) end
    end

    for player,d in pairs(ESPO) do
        if not player or not player.Parent then KillESP(player); continue end
        local char=player.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hrp then HideESP(d); continue end

        local dist=GetDist(char) or math.huge
        local bx,by,bw,bh
        local deadlineMode=(Cfg.ESP.Mode=="Deadline")
        if deadlineMode then
            local rootPos,onScreen=Cam:WorldToViewportPoint(hrp.Position)
            if not onScreen or rootPos.Z<0 then HideESP(d); continue end
            local topPos=Cam:WorldToViewportPoint(hrp.Position+Vector3.new(0,2.5,0))
            local bottomPos=Cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3,0))
            bh=math.abs(topPos.Y-bottomPos.Y); bw=bh*0.6
            bx=rootPos.X-bw/2; by=math.min(topPos.Y,bottomPos.Y)
        else
            bx,by,bw,bh=GetBounds(char)
        end
        local visible=(not Cfg.ESP.WallCheck) or IsVisibleCached(player,char)
        local radarFilter=Cfg.ESP.RadarEnabled and not Cfg.ESP.RadarHighlight
        local radarAllowed=not radarFilter or Cfg.ESP.RadarTarget=="" or player.Name==Cfg.ESP.RadarTarget
        local allowed=(not Cfg.ESP.TeamCheck or not SameTeam(player))
            and (not next(Cfg.ESP.TrackList) or Cfg.ESP.TrackList[player.Name])
            and radarAllowed
        local show=dist<=Cfg.ESP.MaxDist and visible and allowed and bx~=nil

        if show then
            local x,y,w,h=bx,by,bw,bh
            local radarFocus=Cfg.ESP.RadarHighlight and Cfg.ESP.RadarTarget~="" and player and player.Name==Cfg.ESP.RadarTarget
            local radarColor=FOVColors[Cfg.ESP.RadarColorName] or FOVColors.Yellow
            local boxColor=radarFocus and radarColor or (deadlineMode and Color3.fromRGB(0,255,255) or Cfg.ESP.BoxColor)
            local nameColor=radarFocus and radarColor or (deadlineMode and Color3.fromRGB(255,255,100) or Cfg.ESP.NameColor)
            local tracerColor=radarFocus and radarColor or (deadlineMode and Color3.fromRGB(255,0,0) or Cfg.ESP.TracerColor)
            if Cfg.ESP.Box then SafeSet(d.Box,{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=boxColor,Transparency=0.7,Visible=true}) else SafeHide(d.Box) end
            if Cfg.ESP.Fill then SafeSet(d.Fill,{Position=Vector2.new(x,y),Size=Vector2.new(w,h),Color=radarFocus and radarColor or Cfg.ESP.FillColor,Transparency=0.7,Visible=true}) else SafeHide(d.Fill) end
            if Cfg.ESP.Names then SafeSet(d.Name,{Position=Vector2.new(x+w/2,y-18),Text=player.DisplayName,Color=nameColor,Visible=true}) else SafeHide(d.Name) end
            if Cfg.ESP.Dist then SafeSet(d.Dist,{Position=Vector2.new(x+w/2,y+h+4),Text=math.floor(dist).."m",Color=Cfg.ESP.DistColor,Visible=true}) else SafeHide(d.Dist) end
            if Cfg.ESP.HP then
                local hp,mhp=GetHP(char); local ratio=math.clamp(hp/math.max(mhp,1),0,1); local barH=h*ratio
                SafeSet(d.HPBg,{Position=Vector2.new(x-7,y),Size=Vector2.new(5,h),Color=Cfg.ESP.HPBgColor,Transparency=0.7,Visible=true})
                SafeSet(d.HPBar,{Position=Vector2.new(x-7,y+h-barH),Size=Vector2.new(5,barH),Color=Color3.fromRGB(0,255,0),Transparency=0,Visible=true})
            else SafeHide(d.HPBg); SafeHide(d.HPBar) end
            if Cfg.ESP.Tracers then SafeSet(d.Tracer,{From=Vector2.new(cx,vsY),To=Vector2.new(x+w/2,y+h),Color=tracerColor,Transparency=0.7,Visible=true}) else SafeHide(d.Tracer) end
            if Cfg.ESP.HeldTool then
                local tn=GetHeldTool(char)
                if tn then SafeSet(d.Tool,{Position=Vector2.new(x+w/2,y-32),Text="["..tn.."]",Color=Cfg.ESP.ToolColor,Visible=true}) else SafeHide(d.Tool) end
            else SafeHide(d.Tool) end
            if Cfg.ESP.Skeleton then
                local bones=(char:FindFirstChild("Torso") and BONES_R6) or BONES_R15
                for bi=1,MAX_BONES do
                    local ln=d.Skel[bi]; local pair=bones[bi]
                    if ln and pair then
                        local p1=char:FindFirstChild(pair[1]); local p2=char:FindFirstChild(pair[2])
                        if p1 and p2 then
                            local s1,o1=W2S(p1.Position); local s2,o2=W2S(p2.Position)
                            if o1 and o2 then SafeSet(ln,{From=s1,To=s2,Color=Cfg.ESP.SkelColor,Visible=true}) else SafeHide(ln) end
                        else SafeHide(ln) end
                    elseif ln then SafeHide(ln) end
                end
            else for _,ln in ipairs(d.Skel) do SafeHide(ln) end end
        else
            HideESP(d)
        end
    end
    DiagModule("ESP","active",nil,os.clock()-espStart)
end))

for _,p in ipairs(Players:GetPlayers()) do MakeESP(p) end
AC(Players.PlayerAdded:Connect(function(p)
    MakeESP(p)
    if Cfg.Misc.HitboxExtender then SetHitbox(p,true) end
end))
AC(Players.PlayerRemoving:Connect(function(p)
    KillESP(p); SetHitbox(p,false); _hbConns[p]=nil; _hbOriginals[p]=nil
end))
AC(LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed(); ApplyJump()
    if Cfg.Misc.Fly then EnableFly() end
    if Cfg.Misc.Noclip then EnableNoclip() end
end))

-- ============================================================
-- CLICK TELEPORT
-- Uses the current mouse hit position only while the toggle is enabled.
-- ============================================================
AC(UIS.InputBegan:Connect(function(input,gameProcessed)
    if gameProcessed or not Cfg.Misc.ClickTp then return end
    if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    local char=LP.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ok,hit=pcall(function() return Mouse.Hit end)
    if ok and hit then
        hrp.CFrame=CFrame.new(hit.Position+Vector3.new(0,3,0))
    end
end))

-- ============================================================
-- TOOL HELPERS
-- Scanned only when the user presses Load Tools.
-- ============================================================
local function _TryGrab(tool)
    if not tool or not tool.Parent then return false end
    local bp=LP:FindFirstChild("Backpack")
    local char=LP.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not bp then return false end
    local ok=pcall(function() tool.Parent=bp end)
    if ok and (tool.Parent==bp or (char and tool.Parent==char)) then return true end
    if hum then
        local ok2=pcall(function() hum:EquipTool(tool) end)
        if ok2 and char and tool.Parent==char then return true end
    end
    local cloneOk=pcall(function() tool:Clone().Parent=bp end)
    return cloneOk
end

local function GetMapTools()
    local out={}
    local seen={}
    local containers={Workspace,game:GetService("ReplicatedStorage")}
    for _,container in ipairs(containers) do
        local ok,desc=pcall(function() return container:GetDescendants() end)
        if ok and desc then
            for _,v in ipairs(desc) do
                if v:IsA("Tool") and not v:IsDescendantOf(Players) and not seen[v] then
                    seen[v]=true
                    out[#out+1]={name=v.Name,tool=v,dist=math.huge}
                end
            end
        end
    end
    local char=LP.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _,entry in ipairs(out) do
            local part=entry.tool:FindFirstChildWhichIsA("BasePart",true)
            if part then entry.dist=(part.Position-hrp.Position).Magnitude end
        end
        table.sort(out,function(a,b) return a.dist<b.dist end)
    end
    return out
end

local function GrabNearestTool()
    local list=GetMapTools()
    local first=list[1]
    if first then return _TryGrab(first.tool) and first.name or nil end
    return nil
end

-- ============================================================
-- KEYBINDS
-- ============================================================
local _guiVisible=true
_G._scrollAimPulse=false
local M3,M4,M5
pcall(function() M3=Enum.UserInputType.MouseButton3; M4=Enum.UserInputType.MouseButton4; M5=Enum.UserInputType.MouseButton5 end)
local _CBs={}
local function TR(k) if _CBs[k] then _CBs[k]() end end
AC(UIS.InputBegan:Connect(function(inp)
    local u=inp.UserInputType
    local alias=InputMouseAlias(inp)
    if alias then _mouseHeld[alias]=true end
    if u==Enum.UserInputType.MouseButton1 or u==Enum.UserInputType.MouseButton2 or u==M3 or u==M4 or u==M5 then _mouseHeld[u]=true end
end))
AC(UIS.InputEnded:Connect(function(inp)
    local u=inp.UserInputType
    local alias=InputMouseAlias(inp)
    if alias then _mouseHeld[alias]=false end
    if u==Enum.UserInputType.MouseButton1 or u==Enum.UserInputType.MouseButton2 or u==M3 or u==M4 or u==M5 then _mouseHeld[u]=false end
end))
local function BindMatches(inp,bind)
    if type(bind)=="string" then
        local alias=InputMouseAlias(inp)
        if bind=="Mouse1" or bind=="Mouse2" or bind=="Mouse3" or bind=="Mouse4" or bind=="Mouse5" then return alias==bind end
        if inp.UserInputType~=Enum.UserInputType.MouseWheel then return false end
        return (bind=="ScrollUp" and inp.Position.Z>0) or (bind=="ScrollDown" and inp.Position.Z<0)
    end
    if inp.UserInputType~=Enum.UserInputType.Keyboard then return inp.UserInputType==bind end
    return inp.KeyCode==bind
end
AC(UIS.InputBegan:Connect(function(inp,gp)
    local inputAlias=InputMouseAlias(inp)
    local isMouseInput=(inputAlias~=nil or inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.MouseButton2)
    if gp and not isMouseInput then return end
    if inp.UserInputType==Enum.UserInputType.MouseWheel and (inp.Position.Z>0 and Cfg.Aim.AimKey=="ScrollUp" or inp.Position.Z<0 and Cfg.Aim.AimKey=="ScrollDown") then _G._scrollAimPulse=true end
    if BindMatches(inp,Cfg.Settings.ToggleKey) then if _G._223HUB_ToggleMenu then _G._223HUB_ToggleMenu() end
    elseif BindMatches(inp,Cfg.Settings.ESPKey) then Cfg.ESP.Enabled=not Cfg.ESP.Enabled; TR("ESP")
    elseif BindMatches(inp,Cfg.Settings.AimbotKey) then Cfg.Aim.Aimbot=not Cfg.Aim.Aimbot; TR("Aim")
    elseif BindMatches(inp,Cfg.Settings.FlyKey) then Cfg.Misc.Fly=not Cfg.Misc.Fly; if Cfg.Misc.Fly then EnableFly() else DisableFly() end; TR("Fly")
    elseif BindMatches(inp,Cfg.Settings.NoclipKey) then Cfg.Misc.Noclip=not Cfg.Misc.Noclip; if Cfg.Misc.Noclip then EnableNoclip() else DisableNoclip() end; TR("NC")
    elseif BindMatches(inp,Cfg.Settings.SpeedKey) then Cfg.Misc.Speed=not Cfg.Misc.Speed; ApplySpeed(); TR("Speed")
    elseif BindMatches(inp,Cfg.Settings.ClickTpKey) then Cfg.Misc.ClickTp=not Cfg.Misc.ClickTp; TR("Click TP")
    end
end))

-- ============================================================
-- GUI Fluent
local _fluentSource=game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
-- Mantém o dropdown como popup independente, com altura limitada e reposicionamento automático conforme o espaço disponível.
_fluentSource=_fluentSource:gsub("BackgroundTransparency=1,Size=UDim2.new(1,0,0,300),Position=UDim2.fromOffset(0,42),Parent=m.Frame,Visible=false","BackgroundTransparency=1,Size=UDim2.fromOffset(170,300),Parent=h.Library.GUI,Visible=false")
_fluentSource=_fluentSource:gsub("local w,x=function()v.Position=UDim2.fromOffset(0,42)end,0","local w,x=function()local w=0 if ai.ViewportSize.Y-p.AbsolutePosition.Y<v.AbsoluteSize.Y-5 then w=v.AbsoluteSize.Y-5-(ai.ViewportSize.Y-p.AbsolutePosition.Y)+40 end v.Position=UDim2.fromOffset(p.AbsolutePosition.X-1,p.AbsolutePosition.Y-5-w)end,0")
_fluentSource=_fluentSource:gsub("function l.Open(B)l.Opened=true A.ScrollingEnabled=false pcall(function()m.Frame.Size=UDim2.new(1,0,0,42+u.AbsoluteSize.Y)end)v.Position=UDim2.fromOffset(0,42)v.Visible=true","function l.Open(B)l.Opened=true A.ScrollingEnabled=false v.Visible=true")
_fluentSource=_fluentSource:gsub("function l.Close(B)l.Opened=false A.ScrollingEnabled=true pcall(function()m.Frame.Size=UDim2.new(1,0,0,42)end)u.Size=UDim2.fromScale(1,0.6)v.Visible=false","function l.Close(B)l.Opened=false A.ScrollingEnabled=true u.Size=UDim2.fromScale(1,0.6)v.Visible=false")
_fluentSource=_fluentSource:gsub("local y,z=function()if#l.Values>10 then v.Size=UDim2.fromOffset(x,392)else v.Size=UDim2.fromOffset(x,s.AbsoluteContentSize.Y+10)end end","local y,z=function()local maxH=math.max(120,math.min(392,ai.ViewportSize.Y-32))if#l.Values>10 then v.Size=UDim2.fromOffset(x,maxH)else v.Size=UDim2.fromOffset(x,math.min(s.AbsoluteContentSize.Y+10,maxH))end end")
local Fluent=loadstring(_fluentSource)()
local Window=Fluent:CreateWindow({
    Title="223JHUB",
    SubTitle="223JHUB 2.5 | revolucionari'us",
    TabWidth=160,
    Size=UDim2.fromOffset(760,560),
    Acrylic=false,
    Theme="Dark",
    MinimizeKey=Enum.KeyCode.RightShift
})
-- Mantém dropdowns abertos dentro da área visível e evita que escapem pelas bordas.
local function KeepDropdownsInsideViewport()
    local frames=Fluent.OpenFrames
    if type(frames)~="table" then return end
    for _,frame in ipairs(frames) do
        if frame and frame:IsA("GuiObject") and frame.Visible then
            pcall(function() frame.ZIndex=100 end)
        end
    end
end
AC(RunService.RenderStepped:Connect(KeepDropdownsInsideViewport))
local CAS=game:GetService("ContextActionService")
local _hubMenuOpen=true
local _hubBlockAction="223JHUB_BlockGameInput"
local _hubBlockKeys={Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Space,Enum.KeyCode.LeftShift,Enum.KeyCode.LeftControl,Enum.UserInputType.MouseMovement,Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseWheel}
local function SetHubFocus(open)
    _hubMenuOpen=open
    pcall(function() CAS:UnbindAction(_hubBlockAction) end)
    if open then
        UIS.MouseBehavior=Enum.MouseBehavior.Default
        UIS.MouseIconEnabled=true
        if Cfg.Settings.BlockGameInput then
            pcall(function()
                CAS:BindActionAtPriority(_hubBlockAction,function() return Enum.ContextActionResult.Sink end,false,3000,unpack(_hubBlockKeys))
            end)
        end
    else
        -- Nunca ocultar ou prender o cursor ao minimizar a interface.
        pcall(function() UIS.MouseBehavior=Enum.MouseBehavior.Default end)
        pcall(function() UIS.MouseIconEnabled=true end)
    end
end

local Tabs={
    Home=Window:AddTab({Title="Home",Icon="house"}),
    Combat=Window:AddTab({Title="Combat",Icon="crosshair"}),
    Visuals=Window:AddTab({Title="Visuals",Icon="eye"}),
    Radar=Window:AddTab({Title="Radar",Icon="scan-line"}),
    Misc=Window:AddTab({Title="Misc",Icon="settings-2"}),
    Spawn=Window:AddTab({Title="Spawn",Icon="package"}),
    Binds=Window:AddTab({Title="Binds",Icon="keyboard"}),
    Saves=Window:AddTab({Title="Saves",Icon="save"}),
    Settings=Window:AddTab({Title="Settings",Icon="settings"}),
    Custom=Window:AddTab({Title="Personalização",Icon="palette"}),
    Credits=Window:AddTab({Title="Credits",Icon="heart"})
}
local Options=Fluent.Options
Tabs.Home:AddSection("223JHUB 2.5")
Tabs.Home:AddParagraph({Title="Bem-vindo ao 223JHUB 2.5",Content="Interface Fluent para utilidades visuais, combate e gerenciamento de configuracoes."})
Tabs.Home:AddParagraph({Title="Creditos",Content="Criado por Bruno223j e TY | Revolutionari'us Group"})
Tabs.Home:AddParagraph({Title="Atualizacao",Content="Versao 2.5 com Saves, prioridade de foco, radar de alvo unico, taxa configur?vel do ESP e otimiza??o de ciclos."})
Tabs.Home:AddParagraph({Title="Estado",Content="As listas de jogadores e ferramentas s?o carregadas somente quando voc? solicita."})
Tabs.Home:AddParagraph({Title="Novidades",Content="Camera Follow mantém o alvo acompanhado fora do FOV; Aimbot Distance limita a distância máxima; Radar Highlight destaca um alvo específico no ESP; a aba Personalização controla cores do ESP e do FOV."})
Tabs.Home:AddParagraph({Title="Interface",Content="Dropdowns são tratados como menus expansíveis e as binds carregadas pelos saves são reaplicadas visualmente na GUI."})
_G._223HUB_ToggleMenu=function()
    _hubMenuOpen=not _hubMenuOpen
    pcall(function() Window:Minimize() end)
    SetHubFocus(_hubMenuOpen)
end
local function T(tab,id,title,getV,setV)
    tab:AddToggle(id,{Title=title,Default=getV(),Callback=function(v) setV(v) end})
end
local function S(tab,id,title,min,max,def,cb)
    tab:AddSlider(id,{Title=title,Min=min,Max=max,Default=def,Rounding=0,Callback=cb})
end
local function BindIdentity(bind)
    if bind==nil then return nil end
    return type(bind)=="string" and bind or tostring(bind)
end
local function FindBindConflicts()
    local entries={
        {"Menu",Cfg.Settings.ToggleKey},{"ESP",Cfg.Settings.ESPKey},{"Aimbot Toggle",Cfg.Settings.AimbotKey},
        {"Fly",Cfg.Settings.FlyKey},{"Noclip",Cfg.Settings.NoclipKey},{"Speed",Cfg.Settings.SpeedKey},{"Click Teleport",Cfg.Settings.ClickTpKey},{"Aim Lock",Cfg.Aim.AimKey}
    }
    local seen={}; local conflicts={}
    for _,entry in ipairs(entries) do
        local id=BindIdentity(entry[2])
        if id and id~="Enum.KeyCode.Unknown" then
            if seen[id] then conflicts[#conflicts+1]=seen[id].." + "..entry[1].." ("..id..")" else seen[id]=entry[1] end
        end
    end
    return conflicts
end
local function NotifyBindConflicts()
    local conflicts=FindBindConflicts()
    if #conflicts>0 then Fluent:Notify({Title="Bind conflict",Content=table.concat(conflicts," | "),Duration=4}) end
    return conflicts
end
local waitingBind=false
local _bindButtons={}
local function BindButton(tab,title,getName,setBind)
    local button=tab:AddButton({Title=title..": ["..getName().."]",Callback=function()
        if waitingBind then return end
        waitingBind=true
        Fluent:Notify({Title="Bind",Content="Pressione uma tecla ou Mouse1/Mouse2",Duration=3})
        local cn
        cn=UIS.InputBegan:Connect(function(inp,gp)
            local isMouseInput=(inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.MouseButton2 or inp.UserInputType==M3 or inp.UserInputType==M4 or inp.UserInputType==M5)
            if gp and not isMouseInput then return end
            local code,name
            if inp.UserInputType==Enum.UserInputType.Keyboard then code,name=inp.KeyCode,inp.KeyCode.Name
            elseif inp.UserInputType==Enum.UserInputType.MouseButton1 then code,name=Enum.UserInputType.MouseButton1,"Mouse1"
            elseif inp.UserInputType==Enum.UserInputType.MouseButton2 then code,name=Enum.UserInputType.MouseButton2,"Mouse2"
            elseif M3 and inp.UserInputType==M3 then code,name=M3,"Mouse3"
            elseif M4 and inp.UserInputType==M4 then code,name=M4,"Mouse4"
            elseif M5 and inp.UserInputType==M5 then code,name=M5,"Mouse5"
            elseif inp.UserInputType==Enum.UserInputType.MouseWheel then code,name=(inp.Position.Z>0 and "ScrollUp" or "ScrollDown"), (inp.Position.Z>0 and "ScrollUp" or "ScrollDown") end
            if code then
                cn:Disconnect(); waitingBind=false; setBind(code,name)
                pcall(function() if button and button.SetTitle then button:SetTitle(title..": ["..name.."]") end end)
                NotifyBindConflicts()
                Fluent:Notify({Title="Bind updated",Content=title.." = "..name,Duration=2})
            end
                end)
    end})
    _bindButtons[title]={Button=button,GetName=getName}
    return button
end
-- Seletor interno: não cria popup nem janela flutuante; o clique avança pelos valores no próprio painel.
local function LocalSelect(tab,id,title,values,default,callback)
    local state={Values=values or {},Value=nil,Index=1,Button=nil}
    local function findIndex(value)
        for i,v in ipairs(state.Values) do if v==value then return i end end
        return 1
    end
    state.Index=type(default)=="number" and math.clamp(default,1,math.max(#state.Values,1)) or findIndex(default)
    state.Value=state.Values[state.Index]
    local function refresh()
        local text=title..": ["..tostring(state.Value or "").."]"
        if state.Button and state.Button.SetTitle then pcall(function() state.Button:SetTitle(text) end) end
    end
    local object={Value=state.Value}
    function object:SetValue(value)
        state.Index=findIndex(value); state.Value=state.Values[state.Index]; object.Value=state.Value; refresh(); if callback then callback(state.Value) end
    end
    function object:SetValues(newValues)
        state.Values=newValues or {}; state.Index=math.clamp(state.Index,1,math.max(#state.Values,1)); state.Value=state.Values[state.Index]; object.Value=state.Value; refresh()
    end
    state.Button=tab:AddButton({Title=title..": ["..tostring(state.Value or "").."]",Callback=function()
        if #state.Values==0 then return end
        state.Index=(state.Index%#state.Values)+1; state.Value=state.Values[state.Index]; object.Value=state.Value; refresh(); if callback then callback(state.Value) end
    end})
    object.Button=state.Button
    Options[id]=object
    if callback and state.Value~=nil then callback(state.Value) end
    return object
end
Tabs.Combat:AddSection("Aimbot")
T(Tabs.Combat,"Aimbot","Enable Aimbot",function() return Cfg.Aim.Aimbot end,function(v) Cfg.Aim.Aimbot=v end)
Tabs.Combat:AddDropdown("AimMode",{Title="Aimbot Mode",Values={"Default (Universal)","AR2"},Multi=false,Default=Cfg.Aim.AimbotType,Callback=function(v) Cfg.Aim.AimbotType=v end})
Tabs.Combat:AddDropdown("AimPart",{Title="Target Part",Values={"Head","HumanoidRootPart","Torso","UpperTorso"},Multi=false,Default=Cfg.Aim.AimPart,Callback=function(v) Cfg.Aim.AimPart=v end})
T(Tabs.Combat,"AimPrediction","Prediction",function() return Cfg.Aim.Prediction end,function(v) Cfg.Aim.Prediction=v end)
T(Tabs.Combat,"AimWall","Wall Check",function() return Cfg.Aim.WallCheck end,function(v) Cfg.Aim.WallCheck=v end)
T(Tabs.Combat,"AimTeam","Team Check",function() return Cfg.Aim.TeamCheck end,function(v) Cfg.Aim.TeamCheck=v end)
S(Tabs.Combat,"PredStrength","Prediction Strength",1,20,3,function(v) Cfg.Aim.PredStr=v end)
S(Tabs.Combat,"Smooth","Smoothness",1,100,8,function(v) Cfg.Aim.Smoothness=v end)
S(Tabs.Combat,"AimStrength","Aim Strength",1,100,70,function(v) Cfg.Aim.AimStrength=v end)
T(Tabs.Combat,"FocusPriorityEnabled","Enable Focus Priority",function() return Cfg.Aim.FocusPriorityEnabled end,function(v) Cfg.Aim.FocusPriorityEnabled=v end)
Tabs.Combat:AddDropdown("FocusPriority",{Title="Focus Priority",Values={"Closest","Farthest","Most Health","Least Health"},Multi=false,Default=Cfg.Aim.FocusPriority,Callback=function(v) Cfg.Aim.FocusPriority=v end})
Tabs.Combat:AddSection("Aim Exclusion List")
local aimExcludeNames={"Press Load Players"}; local aimExcludeSelected=nil; local aimExcludeMap={}
local function RefreshAimExcludeList()
    aimExcludeNames={}; aimExcludeMap={}
    if type(Cfg.Aim.Blacklist)~="table" then Cfg.Aim.Blacklist={} end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            local label=(Cfg.Aim.Blacklist[p.Name]==true and "[IGNORADO] " or "[PERMITIDO] ")..p.Name
            aimExcludeNames[#aimExcludeNames+1]=label; aimExcludeMap[label]=p.Name
        end
    end
    if #aimExcludeNames==0 then aimExcludeNames={"No players found"} end
    if Options.AimExcludeList then Options.AimExcludeList:SetValues(aimExcludeNames) end
end
Tabs.Combat:AddDropdown("AimExcludeList",{Title="Players / status",Values=aimExcludeNames,Multi=false,Default=1,Callback=function(v) aimExcludeSelected=aimExcludeMap[v] or v end})
Tabs.Combat:AddButton({Title="Load Players",Callback=RefreshAimExcludeList})
Tabs.Combat:AddButton({Title="Add / Remove Exclusion",Callback=function()
    if not aimExcludeSelected or aimExcludeSelected=="No players found" or aimExcludeSelected=="Press Load Players" then return end
    if type(Cfg.Aim.Blacklist)~="table" then Cfg.Aim.Blacklist={} end
    Cfg.Aim.Blacklist[aimExcludeSelected]=not (Cfg.Aim.Blacklist[aimExcludeSelected]==true)
    local state=Cfg.Aim.Blacklist[aimExcludeSelected] and "ignored" or "allowed"
    RefreshAimExcludeList()
    Fluent:Notify({Title="Aimbot exclusion",Content=aimExcludeSelected.." = "..state,Duration=2})
end})
local AimLockBind
local aimBindWaiting=false
local function AimBindLabel()
    return "Aim Lock Bind: ["..tostring(Cfg.Aim.AimKeyName or "E").."]"
end
local function SetAimBind(bind,name)
    if not bind then return end
    Cfg.Aim.AimKey=bind
    Cfg.Aim.AimKeyName=name
    if AimLockBind and AimLockBind.SetTitle then pcall(function() AimLockBind:SetTitle(AimBindLabel()) end) end
    NotifyBindConflicts()
end
AimLockBind=Tabs.Combat:AddButton({Title=AimBindLabel(),Callback=function()
    if aimBindWaiting then return end
    aimBindWaiting=true
    Fluent:Notify({Title="Aim Lock Bind",Content="Pressione uma tecla ou Mouse1-Mouse5",Duration=3})
    local cn
    cn=UIS.InputBegan:Connect(function(inp,gp)
        local u=inp.UserInputType
        local mouseName=InputMouseAlias(inp)
        local code,name
        if mouseName then
            code=BindFromName(mouseName); name=mouseName
        elseif u==Enum.UserInputType.Keyboard and inp.KeyCode~=Enum.KeyCode.Unknown then
            code=inp.KeyCode; name=inp.KeyCode.Name
        end
        if code then
            cn:Disconnect(); aimBindWaiting=false; SetAimBind(code,name)
            Fluent:Notify({Title="Bind updated",Content="Aim Lock Bind = "..name,Duration=2})
        end
    end)
end})
Tabs.Combat:AddSection("FOV")
T(Tabs.Combat,"ShowFOV","Show FOV",function() return Cfg.Aim.ShowFOV end,function(v) Cfg.Aim.ShowFOV=v end)
T(Tabs.Combat,"UseFOV","Use FOV",function() return Cfg.Aim.UseFOV end,function(v) Cfg.Aim.UseFOV=v end)
T(Tabs.Combat,"CameraFollow","Camera Follow Target",function() return Cfg.Aim.CameraFollow end,function(v) Cfg.Aim.CameraFollow=v; if not v then _aimLockedTarget=nil end end)
T(Tabs.Combat,"AimMaxDistanceEnabled","Max Distance",function() return Cfg.Aim.MaxDistanceEnabled end,function(v) Cfg.Aim.MaxDistanceEnabled=v end)
S(Tabs.Combat,"AimMaxDistance","Aim Distance",50,10000,500,function(v) Cfg.Aim.MaxDistance=v end)
S(Tabs.Combat,"FOVSize","FOV Size",10,800,150,function(v) Cfg.Aim.FOV=v end)
Tabs.Combat:AddSection("TriggerBot")
T(Tabs.Combat,"Trigger","Enable TriggerBot",function() return Cfg.Trigger.Enabled end,function(v) Cfg.Trigger.Enabled=v end)
T(Tabs.Combat,"TriggerTeam","Team Check",function() return Cfg.Trigger.TeamCheck end,function(v) Cfg.Trigger.TeamCheck=v end)
S(Tabs.Combat,"TriggerDelay","Delay (ms)",0,1000,80,function(v) Cfg.Trigger.Delay=v end)
Tabs.Combat:AddSection("Hitbox Extender")
T(Tabs.Combat,"Hitbox","Enable Hitbox",function() return Cfg.Misc.HitboxExtender end,function(v) Cfg.Misc.HitboxExtender=v; RefreshHitboxes() end)
T(Tabs.Combat,"HitboxTeamCheck","Team Check",function() return Cfg.Misc.TeamCheck end,function(v) Cfg.Misc.TeamCheck=v; RefreshHitboxes() end)
Tabs.Combat:AddDropdown("HitboxPart",{Title="Hitbox Part",Values={"All","Head","Torso","Arms","Legs","HRP"},Multi=false,Default=Cfg.Misc.HitboxPart,Callback=function(v)
    if HBP_SETS[v] then Cfg.Misc.HitboxPart=v; if Cfg.Misc.HitboxExtender then RefreshHitboxes() end end
end})
S(Tabs.Combat,"HitboxSize","Hitbox Size",2,80,8,function(v) Cfg.Misc.HitboxSize=math.clamp(tonumber(v) or 8,2,80); if Cfg.Misc.HitboxExtender then RefreshHitboxes() end end)

Tabs.Visuals:AddSection("ESP")
T(Tabs.Visuals,"ESP","Enable ESP",function() return Cfg.ESP.Enabled end,function(v) Cfg.ESP.Enabled=v end)
Tabs.Visuals:AddDropdown("ESPMode",{Title="ESP Mode",Values={"Default (Universal)","Deadline"},Multi=false,Default=Cfg.ESP.Mode,Callback=function(v) Cfg.ESP.Mode=v end})
T(Tabs.Visuals,"Box","Box",function() return Cfg.ESP.Box end,function(v) Cfg.ESP.Box=v end)
T(Tabs.Visuals,"Fill","Fill",function() return Cfg.ESP.Fill end,function(v) Cfg.ESP.Fill=v end)
T(Tabs.Visuals,"Names","Names",function() return Cfg.ESP.Names end,function(v) Cfg.ESP.Names=v end)
T(Tabs.Visuals,"Health","Health Bar",function() return Cfg.ESP.HP end,function(v) Cfg.ESP.HP=v end)
T(Tabs.Visuals,"Tracers","Tracers",function() return Cfg.ESP.Tracers end,function(v) Cfg.ESP.Tracers=v end)
T(Tabs.Visuals,"Distance","Distance",function() return Cfg.ESP.Dist end,function(v) Cfg.ESP.Dist=v end)
T(Tabs.Visuals,"TeamCheck","Team Check",function() return Cfg.ESP.TeamCheck end,function(v) Cfg.ESP.TeamCheck=v end)
T(Tabs.Visuals,"Skeleton","Skeleton",function() return Cfg.ESP.Skeleton end,function(v) Cfg.ESP.Skeleton=v end)
S(Tabs.Visuals,"MaxDistance","Max Distance",50,10000,500,function(v) Cfg.ESP.MaxDist=v end)
S(Tabs.Visuals,"ESPUpdateRate","ESP Update Rate (FPS)",1,60,30,function(v) Cfg.ESP.UpdateRate=v; _espInterval=1/math.max(v,1) end)
T(Tabs.Visuals,"HeldTool","Show Item in Hand",function() return Cfg.ESP.HeldTool end,function(v) Cfg.ESP.HeldTool=v end)

Tabs.Misc:AddSection("Movement")
T(Tabs.Misc,"Fly","Fly",function() return Cfg.Misc.Fly end,function(v) Cfg.Misc.Fly=v; if v then EnableFly() else DisableFly() end end)
S(Tabs.Misc,"FlySpeed","Fly Speed",1,500,50,function(v) Cfg.Misc.FlySpeed=v end)
T(Tabs.Misc,"Noclip","Noclip",function() return Cfg.Misc.Noclip end,function(v) Cfg.Misc.Noclip=v; if v then EnableNoclip() else DisableNoclip() end end)
T(Tabs.Misc,"Speed","Speedhack",function() return Cfg.Misc.Speed end,function(v) Cfg.Misc.Speed=v; ApplySpeed() end)
S(Tabs.Misc,"WalkSpeed","WalkSpeed",1,1000,25,function(v) Cfg.Misc.WalkSpeed=v; if Cfg.Misc.Speed then ApplySpeed() end end)
T(Tabs.Misc,"Jump","Jump Modifier",function() return Cfg.Misc.JumpMod end,function(v) Cfg.Misc.JumpMod=v; ApplyJump() end)
S(Tabs.Misc,"JumpPower","Jump Power",1,500,80,function(v) Cfg.Misc.JumpPower=v; if Cfg.Misc.JumpMod then ApplyJump() end end)
Tabs.Misc:AddSection("Other")
T(Tabs.Misc,"AntiRag","Anti Ragdoll",function() return Cfg.Misc.AntiRag end,function(v) Cfg.Misc.AntiRag=v end)
T(Tabs.Misc,"ClickTP","Click Teleport",function() return Cfg.Misc.ClickTp end,function(v) Cfg.Misc.ClickTp=v end)
T(Tabs.Misc,"AntiAFK","Anti AFK",function() return Cfg.Misc.AntiAFK end,function(v) Cfg.Misc.AntiAFK=v end)
Tabs.Misc:AddButton({Title="Rejoin",Callback=Rejoin})
Tabs.Misc:AddButton({Title="Server Hop",Callback=ServerHop})

Tabs.Spawn:AddSection("Tools")
local toolEntries={}
local toolNames={}
local selectedTool=nil
local function RefreshFluentTools(query)
    query=(query or ""):lower()
    toolEntries={}; toolNames={}; selectedTool=nil
    for _,entry in ipairs(GetMapTools()) do
        if query=="" or entry.name:lower():find(query,1,true) then
            toolEntries[#toolEntries+1]=entry; toolNames[#toolNames+1]=entry.name
        end
    end
    if toolNames[1] then selectedTool=toolEntries[1] end
    if Options.ToolList then Options.ToolList:SetValues(toolNames[1] and toolNames or {"No tools found"}) end
end
Tabs.Spawn:AddInput("ToolSearch",{Title="Search Tool",Placeholder="Type a tool name",Default="",Callback=function(v) end})
Tabs.Spawn:AddDropdown("ToolList",{Title="Select Tool",Values={"Press Load Tools"},Multi=false,Default=1,Callback=function(v)
    for _,entry in ipairs(toolEntries) do if entry.name==v then selectedTool=entry; break end end
end})
Tabs.Spawn:AddButton({Title="Load Tools",Callback=function() RefreshFluentTools(Options.ToolSearch and Options.ToolSearch.Value or "") end})
Tabs.Spawn:AddButton({Title="Spawn Selected Tool",Callback=function()
    if selectedTool then _TryGrab(selectedTool.tool) end
end})
Tabs.Spawn:AddButton({Title="Grab Nearest Tool",Callback=function() GrabNearestTool() end})
local inventoryToolNames={"Press Refresh Inventory"}
local selectedInventoryTool=nil
local function RefreshInventoryTools()
    local names={}; local seen={}
    local character=LP and LP.Character
    local backpack=LP and LP:FindFirstChild("Backpack")
    for _,container in ipairs({character,backpack}) do
        if container then
            for _,item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and not seen[item.Name] then
                    seen[item.Name]=true; names[#names+1]=item.Name
                end
            end
        end
    end
    table.sort(names)
    inventoryToolNames=#names>0 and names or {"No tools in inventory"}
    if Options.InventoryTool then Options.InventoryTool:SetValues(inventoryToolNames) end
    if #names>0 then selectedInventoryTool=names[1] else selectedInventoryTool=nil end
end
Tabs.Spawn:AddDropdown("InventoryTool",{Title="Tool to Remove",Values=inventoryToolNames,Multi=false,Default=1,Callback=function(v)
    if v~="No tools in inventory" and v~="Press Refresh Inventory" then selectedInventoryTool=v end
end})
Tabs.Spawn:AddButton({Title="Refresh Inventory",Callback=RefreshInventoryTools})
Tabs.Spawn:AddButton({Title="Remove Selected Tool",Callback=function()
    local targetName=selectedInventoryTool
    if not targetName or targetName=="No tools in inventory" or targetName=="Press Refresh Inventory" then
        Fluent:Notify({Title="Tools",Content="Selecione uma ferramenta do inventário primeiro.",Duration=2})
        return
    end
    local character=LP and LP.Character
    local backpack=LP and LP:FindFirstChild("Backpack")
    local removed=0
    for _,container in ipairs({character,backpack}) do
        if container then
            for _,item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and item.Name==targetName then
                    pcall(function() item:Destroy() end)
                    removed=removed+1
                end
            end
        end
    end
    Fluent:Notify({Title="Tools",Content=removed>0 and ("Ferramenta removida: "..targetName) or "A ferramenta não foi encontrada.",Duration=2})
    RefreshInventoryTools()
end})
-- Tools are scanned only after the user presses Load Tools.

-- Atualização explícita dos controles Fluent após LoadCfg/importação.
SyncGuiFromCfg=function()
    local function set(id,value)
        local option=Options and Options[id]
        if option and option.SetValue then
            pcall(function() option:SetValue(value) end)
        end
    end
    local toggles={
        AimMaxDistanceEnabled=Cfg.Aim.MaxDistanceEnabled,
        RadarHighlight=Cfg.ESP.RadarHighlight,
        ESP=Cfg.ESP.Enabled, Box=Cfg.ESP.Box, Fill=Cfg.ESP.Fill,
        Names=Cfg.ESP.Names, Health=Cfg.ESP.HP, Tracers=Cfg.ESP.Tracers,
        Distance=Cfg.ESP.Dist, TeamCheck=Cfg.ESP.TeamCheck, Skeleton=Cfg.ESP.Skeleton,
        HeldTool=Cfg.ESP.HeldTool, Aimbot=Cfg.Aim.Aimbot, ShowFOV=Cfg.Aim.ShowFOV,
        UseFOV=Cfg.Aim.UseFOV, CameraFollow=Cfg.Aim.CameraFollow, Trigger=Cfg.Trigger.Enabled, TriggerTeam=Cfg.Trigger.TeamCheck,
        Hitbox=Cfg.Misc.HitboxExtender, HitboxTeamCheck=Cfg.Misc.TeamCheck,
        Fly=Cfg.Misc.Fly, Noclip=Cfg.Misc.Noclip, Speed=Cfg.Misc.Speed,
        Jump=Cfg.Misc.JumpMod, AntiRag=Cfg.Misc.AntiRag, ClickTP=Cfg.Misc.ClickTp,
        AntiAFK=Cfg.Misc.AntiAFK, BlockGameInput=Cfg.Settings.BlockGameInput,
        VSync=Cfg.Settings.VSync,
    }
    for id,value in pairs(toggles) do set(id,value) end
    local sliders={
        FOVSize=Cfg.Aim.FOV, AimMaxDistance=Cfg.Aim.MaxDistance, TriggerDelay=Cfg.Trigger.Delay,
        HitboxSize=Cfg.Misc.HitboxSize, MaxDistance=Cfg.ESP.MaxDist,
        ESPUpdateRate=Cfg.ESP.UpdateRate, FlySpeed=Cfg.Misc.FlySpeed,
        WalkSpeed=Cfg.Misc.WalkSpeed, JumpPower=Cfg.Misc.JumpPower,
    }
    for id,value in pairs(sliders) do set(id,value) end
    set("AimMode",Cfg.Aim.AimbotType); set("AimPart",Cfg.Aim.AimPart)
    set("FocusPriority",Cfg.Aim.FocusPriority); set("HitboxPart",Cfg.Misc.HitboxPart)
    set("ESPMode",Cfg.ESP.Mode); set("ESPColor",Cfg.ESP.ESPColorName or "Red"); set("FOVColor",Cfg.Aim.FOVColorName); set("RadarColor",Cfg.ESP.RadarColorName)
    for title,entry in pairs(_bindButtons) do
        if entry.Button and entry.Button.SetTitle then pcall(function() entry.Button:SetTitle(title..": ["..tostring(entry.GetName()).."]") end) end
    end
end
local function SyncGuiAfterLoad()
    if not SyncGuiFromCfg then return end
    -- Alguns elementos Fluent ainda estão em animação durante o primeiro SetValue.
    task.defer(function()
        for _=1,3 do
            pcall(SyncGuiFromCfg)
            task.wait(0.15)
        end
    end)
end

-- Aba Saves: opera??es locais compat?veis com writefile/readfile/listfiles.
local saveNames={}; local selectedSave=nil
local function RefreshSaveList()
    saveNames=ListCfgs()
    if #saveNames==0 then saveNames={"No saves found"} end
    if Options.SaveList then Options.SaveList:SetValues(saveNames) end
end
Tabs.Saves:AddSection("Configuration Manager")
Tabs.Saves:AddInput("SaveName",{Title="Save name",Placeholder="my_config",Default="",Callback=function(v) end})
Tabs.Saves:AddDropdown("SaveList",{Title="Saved configurations",Values={"Press Refresh"},Multi=false,Default=1,Callback=function(v) selectedSave=v end})
Tabs.Saves:AddButton({Title="Refresh Saves",Callback=RefreshSaveList})
Tabs.Saves:AddButton({Title="Save Current",Callback=function()
    local name=(Options.SaveName and Options.SaveName.Value or ""):gsub("%s+","_")
    if name=="" then Fluent:Notify({Title="Saves",Content="Digite um nome.",Duration=2}); return end
    local ok,msg=SaveCfg(name); Fluent:Notify({Title="Saves",Content=ok and "Configuracao salva." or tostring(msg),Duration=2}); RefreshSaveList()
end})
Tabs.Saves:AddButton({Title="Load Selected",Callback=function()
    if not selectedSave or selectedSave=="No saves found" then return end
    local ok,msg=LoadCfg(selectedSave)
    if ok then SyncGuiAfterLoad() end
    Fluent:Notify({Title="Saves",Content=ok and "Configuracao carregada." or tostring(msg),Duration=2})
end})
Tabs.Saves:AddButton({Title="Delete Selected",Callback=function()
    if not selectedSave or selectedSave=="No saves found" then return end
    DelCfg(selectedSave); selectedSave=nil; RefreshSaveList()
end})
Tabs.Saves:AddSection("Import / Export")
Tabs.Saves:AddInput("ImportJson",{Title="JSON to import",Placeholder="Cole o JSON exportado",Default="",Callback=function(v) end})
Tabs.Saves:AddButton({Title="Import JSON",Callback=function()
    local raw=Options.ImportJson and Options.ImportJson.Value or ""
    local ok,data=pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok then DiagError("Saves","JSON invalido"); Fluent:Notify({Title="Saves",Content="JSON invalido.",Duration=2}); return end
    local applied,err=ApplySave(data)
    if applied then SyncGuiAfterLoad(); Fluent:Notify({Title="Saves",Content="JSON importado.",Duration=2}) else Fluent:Notify({Title="Saves",Content=tostring(err),Duration=3}) end
end})
Tabs.Saves:AddButton({Title="Export JSON",Callback=function()
    local raw=SerCfg()
    if setclipboard then pcall(setclipboard,raw); Fluent:Notify({Title="Saves",Content="JSON copiado para a area de transfer?ncia.",Duration=2}) else Fluent:Notify({Title="Saves",Content="setclipboard indisponivel.",Duration=2}) end
end})

-- Radar: lista carregada manualmente e um alvo por vez.
local radarNames={"Press Load Players"}; local radarSelected=nil; local radarMap={}
local function RefreshRadarList()
    radarNames={}; radarMap={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            local label=(Cfg.ESP.RadarTarget==p.Name and "[RASTREANDO] " or "[DISPONIVEL] ")..p.Name
            radarNames[#radarNames+1]=label; radarMap[label]=p.Name
        end
    end
    if #radarNames==0 then radarNames={"No players found"} end
    if Options.RadarList then Options.RadarList:SetValues(radarNames) end
end
Tabs.Radar:AddSection("Single Target Radar")
T(Tabs.Radar,"RadarEnabled","Enable Radar Filter",function() return Cfg.ESP.RadarEnabled end,function(v) Cfg.ESP.RadarEnabled=v end)
Tabs.Radar:AddDropdown("RadarList",{Title="Target / status",Values=radarNames,Multi=false,Default=1,Callback=function(v) radarSelected=radarMap[v] or v end})
Tabs.Radar:AddButton({Title="Load Players",Callback=RefreshRadarList})
Tabs.Radar:AddButton({Title="Track Selected",Callback=function()
    if radarSelected and radarSelected~="No players found" and radarSelected~="Press Load Players" then Cfg.ESP.RadarTarget=radarSelected; Cfg.ESP.RadarEnabled=true; RefreshRadarList() end
end})
Tabs.Radar:AddButton({Title="Clear Radar Target",Callback=function() Cfg.ESP.RadarTarget=""; Cfg.ESP.RadarEnabled=false; RefreshRadarList() end})
T(Tabs.Radar,"RadarHighlight","Highlight Target in ESP",function() return Cfg.ESP.RadarHighlight end,function(v) Cfg.ESP.RadarHighlight=v end)
Tabs.Radar:AddParagraph({Title="Radar / ESP",Content="When Highlight is enabled, the selected target remains visible with a separate color instead of filtering the ESP to one player."})

Tabs.Binds:AddSection("Menu and Systems")
BindButton(Tabs.Binds,"Toggle Menu",function() return Cfg.Settings.ToggleKeyName end,function(k,n) Cfg.Settings.ToggleKey=k; Cfg.Settings.ToggleKeyName=n end)
BindButton(Tabs.Binds,"ESP Toggle",function() return Cfg.Settings.ESPKeyName end,function(k,n) Cfg.Settings.ESPKey=k; Cfg.Settings.ESPKeyName=n end)
BindButton(Tabs.Binds,"Aimbot Toggle",function() return Cfg.Settings.AimbotKeyName end,function(k,n) Cfg.Settings.AimbotKey=k; Cfg.Settings.AimbotKeyName=n end)
BindButton(Tabs.Binds,"Fly Toggle",function() return Cfg.Settings.FlyKeyName end,function(k,n) Cfg.Settings.FlyKey=k; Cfg.Settings.FlyKeyName=n end)
BindButton(Tabs.Binds,"Noclip Toggle",function() return Cfg.Settings.NoclipKeyName end,function(k,n) Cfg.Settings.NoclipKey=k; Cfg.Settings.NoclipKeyName=n end)
BindButton(Tabs.Binds,"Speed Toggle",function() return Cfg.Settings.SpeedKeyName end,function(k,n) Cfg.Settings.SpeedKey=k; Cfg.Settings.SpeedKeyName=n end)
BindButton(Tabs.Binds,"Click Teleport Toggle",function() return Cfg.Settings.ClickTpKeyName end,function(k,n) Cfg.Settings.ClickTpKey=k; Cfg.Settings.ClickTpKeyName=n end)
Tabs.Binds:AddParagraph({Title="Mouse support",Content="All bind selectors accept keyboard keys, Mouse1-Mouse5 and mouse wheel."})
Tabs.Binds:AddButton({Title="Check Bind Conflicts",Callback=function()
    local conflicts=NotifyBindConflicts()
    if #conflicts==0 then Fluent:Notify({Title="Binds",Content="No conflicts detected.",Duration=2}) end
end})

Tabs.Settings:AddSection("Control")
T(Tabs.Settings,"BlockGameInput","Block game interaction while menu is open",function() return Cfg.Settings.BlockGameInput end,function(v) Cfg.Settings.BlockGameInput=v; SetHubFocus(_hubMenuOpen) end)
local CustomColors={Red=Color3.fromRGB(220,40,40),Blue=Color3.fromRGB(40,130,240),Purple=Color3.fromRGB(160,50,220),Yellow=Color3.fromRGB(230,190,40),White=Color3.fromRGB(255,255,255)}
Tabs.Custom:AddSection("Personalização de cores")
local ESPColors={Red=Color3.fromRGB(220,40,40),Blue=Color3.fromRGB(40,130,240),Purple=Color3.fromRGB(160,50,220),Yellow=Color3.fromRGB(230,190,40),White=Color3.fromRGB(255,255,255)}
Tabs.Custom:AddDropdown("ESPColor",{Title="ESP Color",Values={"Red","Blue","Purple","Yellow","White"},Multi=false,Default=Cfg.ESP.ESPColorName or "Red",Callback=function(v)
    local c=ESPColors[v]
    if c then Cfg.ESP.ESPColorName=v; Cfg.ESP.BoxColor=c; Cfg.ESP.FillColor=c; Cfg.ESP.NameColor=c; Cfg.ESP.TracerColor=c; Cfg.ESP.DistColor=c; Cfg.ESP.SkelColor=c end
end})
Tabs.Custom:AddDropdown("FOVColor",{Title="Aim FOV Color",Values={"Red","Blue","Purple","Yellow","White"},Multi=false,Default=Cfg.Aim.FOVColorName,Callback=function(v) if CustomColors[v] then Cfg.Aim.FOVColorName=v end end})
Tabs.Custom:AddDropdown("RadarColor",{Title="Radar Highlight Color",Values={"Red","Blue","Purple","Yellow","White"},Multi=false,Default=Cfg.ESP.RadarColorName,Callback=function(v) if CustomColors[v] then Cfg.ESP.RadarColorName=v end end})
Tabs.Custom:AddParagraph({Title="Aplicação",Content="As cores do FOV e do destaque individual do Radar/ESP são salvas junto com a configuração."})
Tabs.Settings:AddSection("Diagnostics")
Tabs.Settings:AddParagraph({Title="Runtime diagnostics",Content="Shows module state, recent errors, frame update time and managed resources."})
Tabs.Settings:AddButton({Title="Run Diagnostics",Callback=function()
    local conflicts=FindBindConflicts()
    if #conflicts>0 then DiagError("Binds","Conflicts: "..table.concat(conflicts," | ")) else DiagModule("Binds","ok",nil,0) end
    Fluent:Notify({Title="Diagnostics",Content=DiagSummary(),Duration=7})
end})
Tabs.Settings:AddButton({Title="Reset Diagnostic Errors",Callback=function()
    for name,v in pairs(_diag) do if v.status=="error" then v.status="reset"; v.error=nil end end
    Fluent:Notify({Title="Diagnostics",Content="Errors reset.",Duration=2})
end})
T(Tabs.Settings,"VSync","VSync - sync ESP with game FPS",function() return Cfg.Settings.VSync end,function(v) Cfg.Settings.VSync=v; _espLastUpdate=0 end)
local function ShutdownHub()
    if _hubShutdown then return end
    -- Stop every feature first.
    Cfg.ESP.Enabled=false; Cfg.Aim.Aimbot=false; Cfg.Trigger.Enabled=false
    Cfg.Misc.Fly=false; Cfg.Misc.Noclip=false; Cfg.Misc.Speed=false; Cfg.Misc.JumpMod=false; Cfg.Misc.HitboxExtender=false
    pcall(DisableFly); pcall(DisableNoclip); pcall(ApplySpeed); pcall(ApplyJump)
    pcall(function() for player in pairs(_hbConns) do SetHitbox(player,false) end end)
    pcall(function() for player in pairs(_hbOriginals) do RestoreHitbox(player) end end)
    -- Remove both ESP pools, including Deadline models not represented by Players.
    pcall(function() for player in pairs(ESPO) do KillESP(player) end end)
    pcall(function() for model in pairs(DeadlineDrawings) do DestroyDeadlineESP(model) end end)
    Cfg.Aim.ShowFOV=false
    _fovLastVis=false
    pcall(function()
        for _,ln in ipairs(_fovLines) do
            if ln then ln.Visible=false; ln:Remove(); DrawPool[ln]=nil end
        end
    end)
    -- Disconnect every connection registered through AC.
    pcall(function() for _,conn in ipairs(_conns) do if conn then conn:Disconnect() end end end)
    CleanupResources()
    pcall(function() CAS:UnbindAction(_hubBlockAction) end)
    pcall(function() Fluent:Unload() end)
    pcall(function() if _GuiParent and _GuiParent:FindFirstChild("223TYHUB") then _GuiParent:FindFirstChild("223TYHUB"):Destroy() end end)
    pcall(function() UIS.MouseBehavior=Enum.MouseBehavior.Default; UIS.MouseIconEnabled=true end)
    _hubShutdown=true
    pcall(function() if _G._223HUB_Kill then _G._223HUB_Kill() end end)
    _G._223HUB_ToggleMenu=nil
    _G._223HUB_Kill=nil
    _G._223HUB_Shutdown=nil
end
_G._223HUB_Shutdown=ShutdownHub
Tabs.Settings:AddButton({Title="Unload 223JHUB",Callback=ShutdownHub})
Tabs.Settings:AddParagraph({Title="Shutdown",Content="Stops all systems, disconnects events and removes the interface."})
Tabs.Settings:AddSection("About")
Tabs.Settings:AddParagraph({Title="Credits",Content="223JHUB 2.5 | Script by Bruno223J and TY | Revolutionarius Group"})
Tabs.Settings:AddParagraph({Title="Fluent UI",Content="Interface powered by Fluent UI Library."})
Tabs.Credits:AddSection("223JHUB 2.5")
Tabs.Credits:AddParagraph({Title="Developers",Content="Bruno223j and TY"})
Tabs.Credits:AddParagraph({Title="Discord",Content="bruno223j & frty2017"})
Tabs.Credits:AddParagraph({Title="Final Edition",Content="ESP, controls and cleanup finalized."})
Window:SelectTab(1)
Fluent:Notify({Title="223JHUB 2.5",Content="Fluent interface loaded.",Duration=4})
-- O Fluent pode alterar o foco durante a montagem; aplica o estado final depois disso.
task.defer(function()
    SetHubFocus(_hubMenuOpen)
    pcall(function() UIS.MouseBehavior=Enum.MouseBehavior.Default end)
    pcall(function() UIS.MouseIconEnabled=true end)
end)

print("[223JHUB 2.5 RELEASE]  LOADED | BRUNO223J & TY | DISCORD | bruno223j | frty2017 | Toggle=[;]")

end -- fim de _223JHUB_MAIN()

-- Inicializacao direta sem autenticacao.
_223HUB_MAIN()
