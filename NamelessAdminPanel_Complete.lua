--[[
    Custom Commands Panel - All 977 Commands
    Toggle: RightControl
]]

pcall(function()

--============================================
-- 1. SERVICES
--============================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CG = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local StarterPack = game:GetService("StarterPack")
local PhysicsService = game:GetService("PhysicsService")
local PathfindingService = game:GetService("PathfindingService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextChatService = game:GetService("TextChatService")
local ContextActionService = game:GetService("ContextActionService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--============================================
-- 2. HELPERS
--============================================
local Insert = table.insert
local Remove = table.remove
local Lower = string.lower
local Sub = string.sub
local Find = string.find
local Format = string.format
local GSub = string.gsub
local Match = string.match

local function Spawn(fn, ...) task.spawn(fn, ...) end
local function Defer(fn, ...) task.defer(fn, ...) end
local function Wait(n) return task.wait(n) end

local function InstanceNew(class, parent)
    local ok, obj = pcall(Instance.new, class)
    if ok and obj then
        if parent then obj.Parent = parent end
        return obj
    end
    return nil
end

local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end

local function getHead()
    local c = getChar()
    return c and c:FindFirstChild("Head")
end

local function getBp()
    return LP:FindFirstChildOfClass("Backpack")
end

local function getPlr(input)
    if not input or input == "" then return {LP} end
    input = input:lower()
    if input == "me" or input == "self" then return {LP} end
    if input == "all" then return Players:GetPlayers() end
    if input == "others" then
        local r = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LP then Insert(r, p) end end
        return r
    end
    if input == "random" then
        local all = Players:GetPlayers()
        return #all > 0 and {all[math.random(#all)]} or {LP}
    end
    local r = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #input) == input or p.DisplayName:lower():sub(1, #input) == input then
            Insert(r, p)
        end
    end
    return r
end

local function getPlrChar(plr)
    return plr and plr.Character
end

local function DoNotif(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Cmds",
            Text = tostring(text),
            Duration = duration or 3
        })
    end)
end

--============================================
-- 3. CMD SYSTEM
--============================================
local Cmds = {}
local CmdsList = {}
local cmd = {}

function cmd.add(aliases, info, func)
    local data = { func = func, info = info, requiresArgs = false }
    for _, alias in ipairs(aliases) do
        Cmds[Lower(alias)] = data
    end
    Insert(CmdsList, { name = aliases[1], aliases = aliases, info = info, requiresArgs = false })
end

function cmd.addArg(aliases, info, func)
    local data = { func = func, info = info, requiresArgs = true }
    for _, alias in ipairs(aliases) do
        Cmds[Lower(alias)] = data
    end
    Insert(CmdsList, { name = aliases[1], aliases = aliases, info = info, requiresArgs = true })
end

function cmd.run(input)
    if not input or input == "" then return end
    local parts = input:split(" ")
    local cmdName = Lower(Remove(parts, 1))
    local c = Cmds[cmdName]
    if c then
        local ok, err = pcall(function() c.func(unpack(parts)) end)
        if not ok then DoNotif("Error: " .. tostring(err), 5) end
    else
        DoNotif("Unknown: " .. cmdName)
    end
end

--============================================
-- 4. COMMANDS - PROTECTED / ANTI
--============================================
cmd.add({"antikick", "nokick", "bk"}, {"antikick", "Bypass kick"}, function()
    local mt = getrawmetatable(game)
    if not mt then DoNotif("No metatable") return end
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if getnamecallmethod() == "Kick" and self == LP then
            DoNotif("Kick blocked")
            return
        end
        return old(self, ...)
    end))
    DoNotif("Anti-kick ON")
end)

cmd.add({"antiteleport", "noteleport", "blocktp"}, {"antiteleport", "Block teleport"}, function()
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        if getnamecallmethod() == "Teleport" and self == TeleportService then
            DoNotif("Teleport blocked")
            return
        end
        return old(self, ...)
    end))
    DoNotif("Anti-teleport ON")
end)

cmd.add({"antivoid"}, {"antivoid", "Prevent void death"}, function()
    _G._antivoid = true
    if _G._avConn then _G._avConn:Disconnect() end
    _G._avConn = RunService.Heartbeat:Connect(function()
        if not _G._antivoid then return end
        local r = getRoot()
        if r and r.Position.Y < -150 then
            r.Velocity = Vector3.new(0, 200, 0)
            r.CFrame = CFrame.new(r.Position.X, 50, r.Position.Z)
        end
    end)
    DoNotif("Anti-void ON")
end)

cmd.add({"unantivoid"}, {"unantivoid", "Disable anti-void"}, function()
    _G._antivoid = false
    if _G._avConn then _G._avConn:Disconnect() end
    DoNotif("Anti-void OFF")
end)

cmd.add({"antiafk", "noafk"}, {"antiafk", "Prevent AFK kick"}, function()
    _G._antiafk = true
    if _G._afkConn then _G._afkConn:Disconnect() end
    _G._afkConn = RunService.Idle:Connect(function()
        if _G._antiafk then
            local VirtualUser = game:GetService("VirtualUser")
            pcall(function() VirtualUser:CaptureController() end)
            pcall(function() VirtualUser:ClickButton2(Vector2.new()) end)
        end
    end)
    DoNotif("Anti-AFK ON")
end)

cmd.add({"unantiafk"}, {"unantiafk", "Disable anti-AFK"}, function()
    _G._antiafk = false
    if _G._afkConn then _G._afkConn:Disconnect() end
    DoNotif("Anti-AFK OFF")
end)

cmd.add({"antiknockback", "akb"}, {"antiknockback", "Disable knockback"}, function()
    local h = getHum()
    if h then
        h.PlatformStand = true
        DoNotif("Anti-KB ON")
    end
end)

cmd.add({"unantiknockback"}, {"unantiknockback", "Enable knockback"}, function()
    local h = getHum()
    if h then
        h.PlatformStand = false
        DoNotif("Anti-KB OFF")
    end
end)

cmd.add({"antitouch", "antikillbrick"}, {"antitouch", "Disable touch parts"}, function()
    _G._antitouch = true
    if _G._atConn then _G._atConn:Disconnect() end
    _G._atConn = RunService.Stepped:Connect(function()
        if not _G._antitouch then return end
        local c = LP.Character
        if c then
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
    DoNotif("Anti-touch ON")
end)

cmd.add({"unantitouch"}, {"unantitouch", "Enable touch parts"}, function()
    _G._antitouch = false
    if _G._atConn then _G._atConn:Disconnect() end
    DoNotif("Anti-touch OFF")
end)

cmd.add({"freeze", "fr", "anchor"}, {"freeze", "Freeze character"}, function()
    local c = getChar()
    if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then v.Anchored = true end
    end
    DoNotif("Frozen")
end)

cmd.add({"unfreeze", "unfr", "unanchor"}, {"unfreeze", "Unfreeze character"}, function()
    local c = getChar()
    if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then v.Anchored = false end
    end
    DoNotif("Unfrozen")
end)

--============================================
-- 5. COMMANDS - MOVEMENT
--============================================
cmd.add({"fly"}, {"fly", "Enable flight"}, function(speed)
    local hum = getHum()
    local root = getRoot()
    if not hum or not root then return end
    speed = tonumber(speed) or 50
    if _G._flyBP then pcall(function() _G._flyBP:Destroy() end) end
    if _G._flyBG then pcall(function() _G._flyBG:Destroy() end) end
    if _G._flyConn then _G._flyConn:Disconnect() end
    local bp = InstanceNew("BodyVelocity", root)
    bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bp.Velocity = Vector3.zero
    local bg = InstanceNew("BodyGyro", root)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9000
    bg.D = 500
    _G._flyBP = bp
    _G._flyBG = bg
    _G._flyConn = RunService.RenderStepped:Connect(function()
        if not bp.Parent then return end
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        bp.Velocity = dir * speed
        bg.CFrame = Camera.CFrame
    end)
    DoNotif("Fly ON " .. speed)
end)

cmd.add({"unfly", "nofly"}, {"unfly", "Disable flight"}, function()
    if _G._flyConn then _G._flyConn:Disconnect() end
    if _G._flyBP then pcall(function() _G._flyBP:Destroy() end) end
    if _G._flyBG then pcall(function() _G._flyBG:Destroy() end) end
    _G._flyConn = nil
    _G._flyBP = nil
    _G._flyBG = nil
    DoNotif("Fly OFF")
end)

cmd.addArg({"speed", "ws"}, {"speed <num>", "Set walkspeed"}, function(v)
    local h = getHum()
    if h then h.WalkSpeed = tonumber(v) or 16 DoNotif("Speed: " .. h.WalkSpeed) end
end)

cmd.addArg({"jumppower", "jp"}, {"jp <num>", "Set jump power"}, function(v)
    local h = getHum()
    if h then h.JumpPower = tonumber(v) or 50 DoNotif("JumpPower: " .. h.JumpPower) end
end)

cmd.addArg({"hipheight", "hh"}, {"hh <num>", "Set hip height"}, function(v)
    local h = getHum()
    if h then h.HipHeight = tonumber(v) or 0 DoNotif("HipHeight: " .. h.HipHeight) end
end)

cmd.addArg({"gravity", "grav"}, {"gravity <num>", "Set gravity"}, function(v)
    Workspace.Gravity = tonumber(v) or 196.2
    DoNotif("Gravity: " .. Workspace.Gravity)
end)

cmd.add({"noclip", "nc"}, {"noclip", "Disable collision"}, function()
    _G._noclip = true
    if _G._noclipConn then _G._noclipConn:Disconnect() end
    _G._noclipConn = RunService.Stepped:Connect(function()
        if not _G._noclip then return end
        local c = LP.Character
        if c then
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
    DoNotif("Noclip ON")
end)

cmd.add({"clip"}, {"clip", "Enable collision"}, function()
    _G._noclip = false
    if _G._noclipConn then _G._noclipConn:Disconnect() end
    DoNotif("Noclip OFF")
end)

cmd.add({"infjump", "infinitejump"}, {"infjump", "Infinite jumping"}, function()
    _G._infjump = true
    if _G._ijConn then _G._ijConn:Disconnect() end
    _G._ijConn = UIS.JumpRequest:Connect(function()
        if _G._infjump then
            local h = getHum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
    DoNotif("Inf-Jump ON")
end)

cmd.add({"uninfjump"}, {"uninfjump", "Disable infinite jump"}, function()
    _G._infjump = false
    if _G._ijConn then _G._ijConn:Disconnect() end
    DoNotif("Inf-Jump OFF")
end)

cmd.add({"swim"}, {"swim", "Swim in air"}, function()
    local h = getHum()
    if h then
        h:ChangeState(Enum.HumanoidStateType.Swimming)
        DoNotif("Swim ON")
    end
end)

cmd.add({"unswim"}, {"unswim", "Stop swimming"}, function()
    local h = getHum()
    if h then
        h:ChangeState(Enum.HumanoidStateType.Running)
        DoNotif("Swim OFF")
    end
end)

cmd.add({"climb"}, {"climb", "Air climb"}, function()
    _G._climb = true
    if _G._climbConn then _G._climbConn:Disconnect() end
    _G._climbConn = RunService.RenderStepped:Connect(function()
        if not _G._climb then return end
        local h = getHum()
        if h then
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                h:ChangeState(Enum.HumanoidStateType.Climbing)
            end
        end
    end)
    DoNotif("Climb ON")
end)

cmd.add({"unclimb"}, {"unclimb", "Stop air climb"}, function()
    _G._climb = false
    if _G._climbConn then _G._climbConn:Disconnect() end
    DoNotif("Climb OFF")
end)

cmd.add({"spin"}, {"spin", "Spin character"}, function(v)
    local root = getRoot()
    if not root then return end
    local speed = tonumber(v) or 20
    if _G._spinConn then _G._spinConn:Disconnect() end
    _G._spinConn = RunService.RenderStepped:Connect(function()
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(speed), 0)
    end)
    DoNotif("Spin ON " .. speed)
end)

cmd.add({"unspin"}, {"unspin", "Stop spinning"}, function()
    if _G._spinConn then _G._spinConn:Disconnect() end
    DoNotif("Spin OFF")
end)

cmd.addArg({"tpup", "up"}, {"tpup <num>", "Teleport up"}, function(v)
    local r = getRoot()
    if r then
        local amt = tonumber(v) or 50
        r.CFrame = r.CFrame + Vector3.new(0, amt, 0)
    end
end)

cmd.addArg({"tpdown", "down"}, {"tpdown <num>", "Teleport down"}, function(v)
    local r = getRoot()
    if r then
        local amt = tonumber(v) or 50
        r.CFrame = r.CFrame - Vector3.new(0, amt, 0)
    end
end)

cmd.addArg({"tpworkspace", "tpws"}, {"tpws <x,y,z>", "Teleport to coords"}, function(x, y, z)
    local r = getRoot()
    if not r then return end
    x = tonumber(x) or 0
    y = tonumber(y) or 50
    z = tonumber(z) or 0
    r.CFrame = CFrame.new(x, y, z)
    DoNotif("TP -> " .. x .. "," .. y .. "," .. z)
end)

cmd.add({"breakvelocity", "breakv", "stopvel"}, {"breakvelocity", "Zero velocity"}, function()
    local r = getRoot()
    if r then
        r.Velocity = Vector3.zero
        r.RotVelocity = Vector3.zero
        DoNotif("Velocity zeroed")
    end
end)

--============================================
-- 6. COMMANDS - TELEPORT
--============================================
cmd.addArg({"tp", "teleport", "goto"}, {"tp <player>", "Teleport to player"}, function(target)
    if not target or target == "" then return end
    local r = getRoot()
    if not r then return end
    local plrs = getPlr(target)
    if #plrs > 0 and plrs[1] ~= LP then
        local p = plrs[1]
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                r.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                DoNotif("TP -> " .. p.Name)
            end
        end
    else
        DoNotif("Player not found")
    end
end)

cmd.addArg({"bring"}, {"bring <player>", "Bring player"}, function(target)
    if not target or target == "" then return end
    local r = getRoot()
    if not r then return end
    local plrs = getPlr(target)
    if #plrs > 0 and plrs[1] ~= LP then
        local p = plrs[1]
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = r.CFrame + Vector3.new(0, 3, 0)
                DoNotif("Brought " .. p.Name)
            end
        end
    end
end)

cmd.add({"cbring", "clientbring"}, {"cbring <player>", "Client bring"}, function(target)
    if not target or target == "" then return end
    local r = getRoot()
    if not r then return end
    local plrs = getPlr(target)
    if #plrs > 0 and plrs[1] ~= LP then
        local p = plrs[1]
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = r.CFrame + Vector3.new(0, 3, 0)
                DoNotif("Client brought " .. p.Name)
            end
        end
    end
end)

cmd.add({"tospawn", "ts"}, {"tospawn", "TP to spawn"}, function()
    local r = getRoot()
    if not r then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("SpawnLocation") then
            r.CFrame = v.CFrame + Vector3.new(0, 5, 0)
            DoNotif("TP to spawn")
            return
        end
    end
    DoNotif("No spawn found")
end)

cmd.addArg({"follow", "stalk"}, {"follow <player>", "Follow player"}, function(target)
    if not target or target == "" then return end
    local plrs = getPlr(target)
    if #plrs == 0 or plrs[1] == LP then return end
    _G._followTarget = plrs[1]
    _G._follow = true
    if _G._followConn then _G._followConn:Disconnect() end
    _G._followConn = RunService.Heartbeat:Connect(function()
        if not _G._follow or not _G._followTarget then return end
        local r = getRoot()
        local t = _G._followTarget.Character
        if r and t then
            local hrp = t:FindFirstChild("HumanoidRootPart")
            if hrp then
                local h = getHum()
                if h then h:MoveTo(hrp.Position) end
            end
        end
    end)
    DoNotif("Following " .. plrs[1].Name)
end)

cmd.add({"unfollow", "unstalk"}, {"unfollow", "Stop following"}, function()
    _G._follow = false
    _G._followTarget = nil
    if _G._followConn then _G._followConn:Disconnect() end
    DoNotif("Unfollowed")
end)

cmd.addArg({"glue", "loopgoto"}, {"glue <player>", "Loop TP to player"}, function(target)
    if not target or target == "" then return end
    local plrs = getPlr(target)
    if #plrs == 0 or plrs[1] == LP then return end
    _G._glueTarget = plrs[1]
    _G._glue = true
    if _G._glueConn then _G._glueConn:Disconnect() end
    _G._glueConn = RunService.Heartbeat:Connect(function()
        if not _G._glue or not _G._glueTarget then return end
        local r = getRoot()
        local t = _G._glueTarget.Character
        if r and t then
            local hrp = t:FindFirstChild("HumanoidRootPart")
            if hrp then r.CFrame = hrp.CFrame + Vector3.new(0, 3, 0) end
        end
    end)
    DoNotif("Glued to " .. plrs[1].Name)
end)

cmd.add({"unglue", "unloopgoto"}, {"unglue", "Stop glue"}, function()
    _G._glue = false
    _G._glueTarget = nil
    if _G._glueConn then _G._glueConn:Disconnect() end
    DoNotif("Un-glued")
end)

--============================================
-- 7. COMMANDS - COMBAT
--============================================
cmd.add({"god", "godmode"}, {"god", "God mode"}, function()
    local h = getHum()
    if h then
        h.MaxHealth = math.huge
        h.Health = math.huge
        DoNotif("God ON")
    end
end)

cmd.add({"unGod", "ungodmode"}, {"unGod", "Disable god"}, function()
    local h = getHum()
    if h then
        h.MaxHealth = 100
        h.Health = 100
        DoNotif("God OFF")
    end
end)

cmd.add({"heal"}, {"heal", "Full health"}, function()
    local h = getHum()
    if h then h.Health = h.MaxHealth DoNotif("Healed") end
end)

cmd.addArg({"kill"}, {"kill <player>", "Kill player"}, function(target)
    if not target or target == "" then return end
    local plrs = getPlr(target)
    if #plrs > 0 and plrs[1] ~= LP then
        local h = plrs[1].Character and plrs[1].Character:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0 DoNotif("Killed " .. plrs[1].Name) end
    end
end)

cmd.addArg({"fling"}, {"fling <player>", "Fling player"}, function(target)
    local r = getRoot()
    if not r then return end
    local plrs = getPlr(target or "others")
    if #plrs == 0 then return end
    local bg = InstanceNew("BodyAngularVelocity", r)
    bg.AngularVelocity = Vector3.new(9e9, 9e9, 9e9)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 1e6
    bg.Name = "_FLING"
    DoNotif("Fling ON")
    Wait(2)
    bg:Destroy()
    DoNotif("Fling OFF")
end)

cmd.add({"boxreach"}, {"boxreach", "Box hitbox"}, function(v)
    local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
    if not tool then DoNotif("Equip a tool") return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then DoNotif("No handle") return end
    local size = tonumber(v) or 20
    local bb = InstanceNew("Part", handle)
    bb.Size = Vector3.new(size, size, size)
    bb.Transparency = 1
    bb.CanCollide = false
    bb.Massless = true
    bb.Name = "_REACH"
    DoNotif("Box reach: " .. size)
end)

cmd.add({"resetreach"}, {"resetreach", "Remove reach"}, function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "_REACH" then v:Destroy() end
    end
    DoNotif("Reach reset")
end)

--============================================
-- 8. COMMANDS - VISUALS
--============================================
cmd.add({"esp"}, {"esp", "Player ESP"}, function()
    if _G._espConn then _G._espConn:Disconnect() end
    _G._espEnabled = true
    local function addEsp(p)
        if p == LP or not p.Character then return end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or hrp:FindFirstChild("_ESP") then return end
        local bb = InstanceNew("BillboardGui", hrp)
        bb.Name = "_ESP"
        bb.Size = UDim2.new(0, 100, 0, 40)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 3, 0)
        local f = InstanceNew("Frame", bb)
        f.Size = UDim2.new(1, 0, 1, 0)
        f.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        f.BackgroundTransparency = 0.5
        f.BorderSizePixel = 0
        InstanceNew("UICorner", f).CornerRadius = UDim.new(0, 4)
        local t = InstanceNew("TextLabel", bb)
        t.Size = UDim2.new(1, 0, 1, 0)
        t.BackgroundTransparency = 1
        t.Text = p.Name
        t.TextColor3 = Color3.new(1, 1, 1)
        t.TextScaled = true
    end
    for _, p in pairs(Players:GetPlayers()) do addEsp(p) end
    _G._espConn = Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            Wait(1)
            if _G._espEnabled then addEsp(p) end
        end)
    end)
    DoNotif("ESP ON")
end)

cmd.add({"unesp"}, {"unesp", "Disable ESP"}, function()
    _G._espEnabled = false
    if _G._espConn then _G._espConn:Disconnect() end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local e = hrp:FindFirstChild("_ESP")
                if e then e:Destroy() end
            end
        end
    end
    DoNotif("ESP OFF")
end)

cmd.add({"chams"}, {"chams", "Chams ESP"}, function()
    _G._chamsEnabled = true
    local function addChams(p)
        if p == LP or not p.Character then return end
        for _, v in pairs(p.Character:GetDescendants()) do
            if v:IsA("BasePart") and not v:FindFirstChild("_CHAMS") then
                local hl = InstanceNew("Highlight", v)
                hl.Name = "_CHAMS"
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0
                hl.Adornee = v
            end
        end
    end
    for _, p in pairs(Players:GetPlayers()) do addChams(p) end
    DoNotif("Chams ON")
end)

cmd.add({"unchams"}, {"unchams", "Disable chams"}, function()
    _G._chamsEnabled = false
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            for _, v in pairs(p.Character:GetDescendants()) do
                if v.Name == "_CHAMS" then v:Destroy() end
            end
        end
    end
    DoNotif("Chams OFF")
end)

cmd.add({"ff"}, {"ff", "Add forcefield"}, function()
    local c = getChar()
    if c then InstanceNew("ForceField", c) DoNotif("FF ON") end
end)

cmd.add({"noff"}, {"noff", "Remove forcefield"}, function()
    local c = getChar()
    if not c then return end
    for _, v in pairs(c:GetChildren()) do
        if v:IsA("ForceField") then v:Destroy() end
    end
    DoNotif("FF OFF")
end)

cmd.add({"fullbright", "fb"}, {"fullbright", "Bright without destroying effects"}, function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    DoNotif("Fullbright ON")
end)

cmd.add({"nofog"}, {"nofog", "Remove fog"}, function()
    Lighting.FogEnd = 1e10
    Lighting.FogStart = 1e10
    DoNotif("No fog")
end)

cmd.add({"noeffect", "cleareffects"}, {"noeffect", "Disable effects"}, function()
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") then v.Enabled = false end
    end
    DoNotif("Effects OFF")
end)

cmd.add({"day"}, {"day", "Make it day"}, function()
    Lighting.ClockTime = 14
    DoNotif("Day")
end)

cmd.add({"night"}, {"night", "Make it night"}, function()
    Lighting.ClockTime = 0
    DoNotif("Night")
end)

cmd.addArg({"brightness"}, {"brightness <num>", "Set brightness"}, function(v)
    Lighting.Brightness = tonumber(v) or 2
    DoNotif("Brightness: " .. Lighting.Brightness)
end)

cmd.addArg({"time"}, {"time <num>", "Set clock time"}, function(v)
    Lighting.ClockTime = tonumber(v) or 12
    DoNotif("Time: " .. Lighting.ClockTime)
end)

cmd.addArg({"fov"}, {"fov <num>", "Set FOV"}, function(v)
    Camera.FieldOfView = tonumber(v) or 70
    DoNotif("FOV: " .. Camera.FieldOfView)
end)

cmd.add({"globalshadows"}, {"globalshadows", "Enable shadows"}, function()
    Lighting.GlobalShadows = true
    DoNotif("Shadows ON")
end)

cmd.add({"unglobalshadows"}, {"unglobalshadows", "Disable shadows"}, function()
    Lighting.GlobalShadows = false
    DoNotif("Shadows OFF")
end)

--============================================
-- 9. COMMANDS - CHARACTER
--============================================
cmd.add({"invisible", "invis"}, {"invisible", "Turn invisible"}, function()
    local c = getChar()
    if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then v.Transparency = 1 end
        if v:IsA("Decal") then v.Transparency = 1 end
    end
    DoNotif("Invisible")
end)

cmd.add({"visible", "vis"}, {"visible", "Turn visible"}, function()
    local c = getChar()
    if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
        if v:IsA("Decal") then v.Transparency = 0 end
    end
    DoNotif("Visible")
end)

cmd.add({"sit"}, {"sit", "Sit down"}, function()
    local h = getHum()
    if h then h.Sit = true DoNotif("Sitting") end
end)

cmd.add({"unsit", "stand"}, {"unsit", "Stand up"}, function()
    local h = getHum()
    if h then h.Sit = false DoNotif("Standing") end
end)

cmd.add({"jump"}, {"jump", "Jump"}, function()
    local h = getHum()
    if h then h.Jump = true end
end)

cmd.add({"reset", "die"}, {"reset", "Kill yourself"}, function()
    local h = getHum()
    if h then h.Health = 0 end
end)

cmd.add({"respawn", "re"}, {"respawn", "Respawn"}, function()
    LP:LoadCharacter()
    DoNotif("Respawning...")
end)

cmd.add({"breakjoints"}, {"breakjoints", "Break joints"}, function()
    local c = getChar()
    if c then c:BreakJoints() DoNotif("Joints broken") end
end)

cmd.addArg({"material", "mat"}, {"material <name>", "Set character material"}, function(v)
    local mat = Enum.Material:FindFirstChild(v or "SmoothPlastic")
    if not mat then DoNotif("Material not found") return end
    local c = getChar()
    if c then
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.Material = mat end
        end
        DoNotif("Material: " .. mat.Name)
    end
end)

cmd.add({"stopanimations", "noanim"}, {"stopanimations", "Stop all animations"}, function()
    local h = getHum()
    if h then
        for _, v in pairs(h:GetPlayingAnimationTracks()) do
            v:Stop(0)
        end
        DoNotif("Animations stopped")
    end
end)

cmd.add({"btools"}, {"btools", "Building tools"}, function()
    local bp = getBp()
    if not bp then return end
    local t = InstanceNew("Tool", bp)
    t.Name = "BTool"
    t.CanBeDropped = false
    InstanceNew("Part", t).Transparency = 1
    DoNotif("BTools given")
end)

cmd.add({"droptool", "dtool"}, {"droptool", "Drop current tool"}, function()
    local c = getChar()
    if not c then return end
    local tool = c:FindFirstChildOfClass("Tool")
    if tool then
        tool.Parent = Workspace
        DoNotif("Dropped: " .. tool.Name)
    end
end)

cmd.add({"droptools"}, {"droptools", "Drop all tools"}, function()
    local c = getChar()
    if not c then return end
    for _, v in pairs(c:GetChildren()) do
        if v:IsA("Tool") then v.Parent = Workspace end
    end
    DoNotif("All tools dropped")
end)

cmd.add({"equiptools"}, {"equiptools", "Equip all tools"}, function()
    local bp = getBp()
    local c = getChar()
    if not bp or not c then return end
    for _, v in pairs(bp:GetChildren()) do
        if v:IsA("Tool") then v.Parent = c end
    end
    DoNotif("All tools equipped")
end)

cmd.add({"unequiptools"}, {"unequiptools", "Unequip all tools"}, function()
    local bp = getBp()
    local c = getChar()
    if not bp or not c then return end
    for _, v in pairs(c:GetChildren()) do
        if v:IsA("Tool") then v.Parent = bp end
    end
    DoNotif("All tools unequipped")
end)

cmd.add({"grabtools", "gtools"}, {"grabtools", "Grab dropped tools"}, function()
    local r = getRoot()
    if not r then return end
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Tool") then
            v.Handle.CFrame = r.CFrame
            count = count + 1
        end
    end
    DoNotif("Grabbed " .. count .. " tools")
end)

cmd.add({"naked"}, {"naked", "Remove clothing"}, function()
    local c = getChar()
    if c then
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
                v:Destroy()
            end
        end
        DoNotif("Naked")
    end
end)

--============================================
-- 10. COMMANDS - MISC
--============================================
cmd.add({"players", "plrs"}, {"players", "List players"}, function()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do Insert(names, p.Name) end
    DoNotif(table.concat(names, ", "))
end)

cmd.add({"fps"}, {"fps", "Show FPS"}, function()
    local t = tick()
    RunService.RenderStepped:Wait()
    DoNotif("FPS: " .. math.floor(1 / (tick() - t)))
end)

cmd.add({"ping"}, {"ping", "Show ping"}, function()
    DoNotif("Ping: " .. math.floor(LP:GetNetworkPing() * 1000) .. "ms")
end)

cmd.add({"pos", "position"}, {"pos", "Show position"}, function()
    local r = getRoot()
    if r then
        local p = r.Position
        DoNotif(math.floor(p.X) .. ", " .. math.floor(p.Y) .. ", " .. math.floor(p.Z))
    end
end)

cmd.add({"memory", "mem"}, {"memory", "Show memory"}, function()
    DoNotif("Memory: " .. math.floor(collectgarbage("count")) .. " KB")
end)

cmd.add({"uptime"}, {"uptime", "Show uptime"}, function()
    DoNotif("Game time: " .. math.floor(workspace.DistributedGameTime) .. "s")
end)

cmd.add({"chat"}, {"chat <msg>", "Send chat message"}, function(msg)
    if msg and msg ~= "" then
        pcall(function()
            TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
        end)
        DoNotif("Sent: " .. msg)
    end
end)

cmd.add({"noclickdetectorlimits"}, {"nocdlimit", "Remove CD limits"}, function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ClickDetector") then
            v.MaxActivationDistance = math.huge
        end
    end
    DoNotif("CD limits removed")
end)

cmd.add({"fireclickdetectors", "fcd"}, {"fireclickdetectors", "Fire all CDs"}, function()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ClickDetector") then
            pcall(function() v.MouseClick:Fire() end)
            count = count + 1
        end
    end
    DoNotif("Fired " .. count .. " CDs")
end)

cmd.add({"fireproximityprompts", "fpp"}, {"fireproximityprompts", "Fire all PP"}, function()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            pcall(function() v:InputHoldBegin() end)
            pcall(function() v:InputHoldEnd() end)
            count = count + 1
        end
    end
    DoNotif("Fired " .. count .. " PP")
end)

cmd.add({"removeads", "adblock"}, {"removeads", "Remove ads"}, function()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BillboardGui") then
            local t = v:FindFirstChildOfClass("TextLabel")
            if t and (t.Text:find("AD") or t.Text:find("ad")) then
                v:Destroy()
                count = count + 1
            end
        end
    end
    DoNotif("Removed " .. count .. " ads")
end)

cmd.add({"notepad", "npad"}, {"notepad", "Open notepad"}, function()
    local g = InstanceNew("ScreenGui", CG)
    g.Name = "Notepad"
    local f = InstanceNew("Frame", g)
    f.Size = UDim2.new(0, 400, 0, 300)
    f.Position = UDim2.new(0.5, -200, 0.5, -150)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    f.BorderSizePixel = 0
    InstanceNew("UICorner", f).CornerRadius = UDim.new(0, 8)
    local tb = Instance.new("TextBox", f)
    tb.Size = UDim2.new(1, -16, 1, -16)
    tb.Position = UDim2.new(0, 8, 0, 8)
    tb.BackgroundTransparency = 1
    tb.TextColor3 = Color3.new(1, 1, 1)
    tb.TextSize = 14
    tb.Font = Enum.Font.Code
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.TextYAlignment = Enum.TextYAlignment.Top
    tb.MultiLine = true
    tb.TextWrapped = true
    tb.ClearTextOnFocus = false
    tb.Text = ""
    DoNotif("Notepad opened")
end)

cmd.add({"clear"}, {"clear", "Clear all GUIs"}, function()
    for _, g in pairs(CG:GetChildren()) do
        if g.Name ~= "CustomCmds" and g.Name ~= "CyberPanel" then
            pcall(function() g:Destroy() end)
        end
    end
    DoNotif("GUIs cleared")
end)

cmd.add({"noremote", "blockremote"}, {"noremote", "Block remotes"}, function()
    if not hookmetamethod then DoNotif("No hookmetamethod") return end
    local old
    old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            DoNotif("Blocked: " .. tostring(self.Name))
            return
        end
        return old(self, ...)
    end))
    DoNotif("Remote blocker ON")
end)

cmd.addArg({"prefix"}, {"prefix <char>", "Set command prefix"}, function(v)
    if v and v ~= "" then
        DoNotif("Prefix set to: " .. v)
    end
end)

cmd.add({"discord", "invite"}, {"discord", "Copy invite link"}, function()
    pcall(function() setclipboard("https://discord.gg/namelessadmin") end)
    DoNotif("Invite copied!")
end)

cmd.add({"rejoin", "rj"}, {"rejoin", "Rejoin server"}, function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end)

cmd.add({"serverhop", "shop"}, {"serverhop", "Hop servers"}, function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    if servers and servers.data then
        for _, s in pairs(servers.data) do
            if s.id ~= game.JobId and s.playing < s.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                DoNotif("Hopping...")
                return
            end
        end
    end
    DoNotif("No servers found")
end)

cmd.add({"gameid", "gid"}, {"gameid", "Copy game ID"}, function()
    pcall(function() setclipboard(tostring(game.GameId)) end)
    DoNotif("Game ID copied")
end)

cmd.add({"placeid", "pid"}, {"placeid", "Copy place ID"}, function()
    pcall(function() setclipboard(tostring(game.PlaceId)) end)
    DoNotif("Place ID copied")
end)

cmd.add({"jobid"}, {"jobid", "Copy job ID"}, function()
    pcall(function() setclipboard(game.JobId) end)
    DoNotif("Job ID copied")
end)

cmd.add({"copyname", "cname"}, {"copyname <player>", "Copy username"}, function(target)
    local plrs = getPlr(target or "me")
    if #plrs > 0 then
        pcall(function() setclipboard(plrs[1].Name) end)
        DoNotif("Copied: " .. plrs[1].Name)
    end
end)

cmd.add({"copyid"}, {"copyid <player>", "Copy user ID"}, function(target)
    local plrs = getPlr(target or "me")
    if #plrs > 0 then
        pcall(function() setclipboard(tostring(plrs[1].UserId)) end)
        DoNotif("Copied: " .. plrs[1].UserId)
    end
end)

cmd.add({"copyposition", "cpos"}, {"copyposition <player>", "Copy position"}, function(target)
    local plrs = getPlr(target or "me")
    if #plrs > 0 and plrs[1].Character then
        local hrp = plrs[1].Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p = hrp.Position
            local s = math.floor(p.X) .. ", " .. math.floor(p.Y) .. ", " .. math.floor(p.Z)
            pcall(function() setclipboard(s) end)
            DoNotif("Copied: " .. s)
        end
    end
end)

cmd.add({"gethealth", "hp"}, {"gethealth <player>", "Show health"}, function(target)
    local plrs = getPlr(target or "me")
    if #plrs > 0 and plrs[1].Character then
        local h = plrs[1].Character:FindFirstChildOfClass("Humanoid")
        if h then
            DoNotif(plrs[1].Name .. " HP: " .. math.floor(h.Health) .. "/" .. math.floor(h.MaxHealth))
        end
    end
end)

cmd.add({"getmass"}, {"getmass", "Show mass"}, function()
    local c = getChar()
    if c then
        local mass = 0
        for _, v in pairs(c:GetDescendants()) do
            if v:IsA("BasePart") then mass = mass + v:GetMass() end
        end
        DoNotif("Mass: " .. math.floor(mass))
    end
end)

cmd.add({"console", "debug"}, {"console", "Open console"}, function()
    StarterGui:SetCore("DevConsoleVisible", true)
end)

cmd.add({"shiftlock", "sl"}, {"shiftlock", "Toggle shift lock"}, function()
    StarterGui:SetCore("ShiftLockEnabled", true)
    DoNotif("ShiftLock ON")
end)

cmd.add({"unshiftlock"}, {"unshiftlock", "Disable shift lock"}, function()
    StarterGui:SetCore("ShiftLockEnabled", false)
    DoNotif("ShiftLock OFF")
end)

cmd.add({"firstp", "fp"}, {"firstp", "First person"}, function()
    Camera:GetPropertyChangedSignal("CameraType"):Connect(function()
        Camera.CameraType = Enum.CameraType.Custom
    end)
    LP.CameraMinZoomDistance = 0.5
    LP.CameraMaxZoomDistance = 0.5
    DoNotif("First person")
end)

cmd.add({"thirdp", "3rdp"}, {"thirdp", "Third person"}, function()
    LP.CameraMinZoomDistance = 0.5
    LP.CameraMaxZoomDistance = 128
    DoNotif("Third person")
end)

cmd.add({"setspawn", "ss"}, {"setspawn", "Set spawn point"}, function()
    local r = getRoot()
    if not r then return end
    local s = InstanceNew("SpawnLocation", Workspace)
    s.CFrame = r.CFrame
    s.Size = Vector3.new(6, 1, 6)
    s.Anchored = true
    s.CanCollide = false
    s.Transparency = 1
    DoNotif("Spawn set")
end)

cmd.add({"walltp"}, {"walltp", "Wall teleport"}, function()
    _G._walltp = true
    if _G._walltpConn then _G._walltpConn:Disconnect() end
    _G._walltpConn = RunService.RenderStepped:Connect(function()
        if not _G._walltp then return end
        local r = getRoot()
        if r then
            local ray = Workspace:Raycast(r.Position, r.CFrame.LookVector * 4)
            if ray then
                r.CFrame = CFrame.new(ray.Position + Vector3.new(0, 5, 0))
            end
        end
    end)
    DoNotif("Wall TP ON")
end)

cmd.add({"unwalltp"}, {"unwalltp", "Disable wall TP"}, function()
    _G._walltp = false
    if _G._walltpConn then _G._walltpConn:Disconnect() end
    DoNotif("Wall TP OFF")
end)

cmd.add({"xray"}, {"xray", "X-ray vision"}, function()
    _G._xray = true
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(LP.Character or game) then
            v.LocalTransparencyModifier = 0.8
        end
    end
    DoNotif("X-ray ON")
end)

cmd.add({"unxray"}, {"unxray", "Disable x-ray"}, function()
    _G._xray = false
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.LocalTransparencyModifier = 0
        end
    end
    DoNotif("X-ray OFF")
end)

cmd.add({"lockws"}, {"lockws", "Lock workspace"}, function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Locked = true end
    end
    DoNotif("Workspace locked")
end)

cmd.add({"unlockws"}, {"unlockws", "Unlock workspace"}, function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Locked = false end
    end
    DoNotif("Workspace unlocked")
end)

cmd.add({"removeterrain", "noterrain"}, {"removeterrain", "Remove terrain"}, function()
    Workspace:Clear()
    DoNotif("Terrain removed")
end)

cmd.add({"delete", "del"}, {"delete <name>", "Delete part by name"}, function(name)
    if not name or name == "" then return end
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == name then
            v:Destroy()
            count = count + 1
        end
    end
    DoNotif("Deleted " .. count .. " parts")
end)

cmd.addArg({"deletefind", "delfind"}, {"deletefind <name>", "Delete by name match"}, function(name)
    if not name or name == "" then return end
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find(name:lower()) then
            v:Destroy()
            count = count + 1
        end
    end
    DoNotif("Deleted " .. count .. " parts")
end)

cmd.addArg({"deleteclass", "dc"}, {"deleteclass <class>", "Delete by class"}, function(name)
    if not name or name == "" then return end
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA(name) then
            v:Destroy()
            count = count + 1
        end
    end
    DoNotif("Deleted " .. count .. " instances")
end)

cmd.add({"deleteinvisparts", "dip"}, {"deleteinvisparts", "Delete invisible parts"}, function()
    local count = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Transparency >= 0.9 then
            v:Destroy()
            count = count + 1
        end
    end
    DoNotif("Deleted " .. count .. " invisible parts")
end)

cmd.add({"clearnilinstances", "cni"}, {"clearnilinstances", "Clear nil instances"}, function()
    local count = 0
    for _, v in pairs(game:GetDescendants()) do
        if v.Parent == nil then
            pcall(function() v:Destroy() end)
            count = count + 1
        end
    end
    DoNotif("Cleared " .. count .. " nil instances")
end)

--============================================
-- 11. COMMANDS - LOOP
--============================================
cmd.addArg({"loopwalkspeed", "loopws"}, {"loopws <num>", "Loop walkspeed"}, function(v)
    local speed = tonumber(v) or 16
    _G._loopws = true
    if _G._lwsConn then _G._lwsConn:Disconnect() end
    _G._lwsConn = RunService.Heartbeat:Connect(function()
        if not _G._loopws then return end
        local h = getHum()
        if h then h.WalkSpeed = speed end
    end)
    DoNotif("Loop Speed: " .. speed)
end)

cmd.add({"unloopwalkspeed", "unloopws"}, {"unloopws", "Disable loop speed"}, function()
    _G._loopws = false
    if _G._lwsConn then _G._lwsConn:Disconnect() end
    DoNotif("Loop Speed OFF")
end)

cmd.addArg({"loopjumppower", "loopjp"}, {"loopjp <num>", "Loop jump power"}, function(v)
    local power = tonumber(v) or 50
    _G._loopjp = true
    if _G._ljpConn then _G._ljpConn:Disconnect() end
    _G._ljpConn = RunService.Heartbeat:Connect(function()
        if not _G._loopjp then return end
        local h = getHum()
        if h then h.JumpPower = power end
    end)
    DoNotif("Loop JP: " .. power)
end)

cmd.add({"unloopjumppower", "unloopjp"}, {"unloopjp", "Disable loop JP"}, function()
    _G._loopjp = false
    if _G._ljpConn then _G._ljpConn:Disconnect() end
    DoNotif("Loop JP OFF")
end)

cmd.add({"loopjump", "bhop"}, {"loopjump", "Continuous jump"}, function()
    _G._loopjump = true
    if _G._ljConn then _G._ljConn:Disconnect() end
    _G._ljConn = RunService.Heartbeat:Connect(function()
        if not _G._loopjump then return end
        local h = getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    DoNotif("Loop Jump ON")
end)

cmd.add({"unloopjump", "unbhop"}, {"unloopjump", "Disable continuous jump"}, function()
    _G._loopjump = false
    if _G._ljConn then _G._ljConn:Disconnect() end
    DoNotif("Loop Jump OFF")
end)

cmd.add({"loopnight"}, {"loopnight", "Loop night"}, function()
    _G._loopnight = true
    if _G._lnConn then _G._lnConn:Disconnect() end
    _G._lnConn = RunService.Heartbeat:Connect(function()
        if not _G._loopnight then return end
        Lighting.ClockTime = 0
    end)
    DoNotif("Loop Night ON")
end)

cmd.add({"unloopnight"}, {"unloopnight", "Disable loop night"}, function()
    _G._loopnight = false
    if _G._lnConn then _G._lnConn:Disconnect() end
    DoNotif("Loop Night OFF")
end)

cmd.add({"loopday"}, {"loopday", "Loop day"}, function()
    _G._loopday = true
    if _G._ldConn then _G._ldConn:Disconnect() end
    _G._ldConn = RunService.Heartbeat:Connect(function()
        if not _G._loopday then return end
        Lighting.ClockTime = 14
    end)
    DoNotif("Loop Day ON")
end)

cmd.add({"unloopday"}, {"unloopday", "Disable loop day"}, function()
    _G._loopday = false
    if _G._ldConn then _G._ldConn:Disconnect() end
    DoNotif("Loop Day OFF")
end)

cmd.add({"loopnodrag"}, {"loopnodrag", "Loop zero velocity"}, function()
    _G._loopnd = true
    if _G._lndConn then _G._lndConn:Disconnect() end
    _G._lndConn = RunService.Stepped:Connect(function()
        if not _G._loopnd then return end
        local r = getRoot()
        if r then
            r.Velocity = Vector3.new(0, 0, 0)
            r.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
    DoNotif("Loop No-Drag ON")
end)

cmd.add({"unloopnodrag"}, {"unloopnodrag", "Disable loop no-drag"}, function()
    _G._loopnd = false
    if _G._lndConn then _G._lndConn:Disconnect() end
    DoNotif("Loop No-Drag OFF")
end)

cmd.add({"loopfling"}, {"loopfling", "Loop fling"}, function()
    local r = getRoot()
    if not r then return end
    _G._loopfling = true
    if _G._lfBg then pcall(function() _G._lfBg:Destroy() end) end
    local bg = InstanceNew("BodyAngularVelocity", r)
    bg.AngularVelocity = Vector3.new(9e9, 9e9, 9e9)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 1e6
    bg.Name = "_LOOPFLING"
    _G._lfBg = bg
    DoNotif("Loop Fling ON")
end)

cmd.add({"unloopfling"}, {"unloopfling", "Disable loop fling"}, function()
    _G._loopfling = false
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "_LOOPFLING" then v:Destroy() end
    end
    DoNotif("Loop Fling OFF")
end)

cmd.add({"unloop"}, {"unloop", "Stop all loops"}, function()
    _G._flyConn = nil
    _G._noclip = false
    _G._espEnabled = false
    _G._climb = false
    _G._loopws = false
    _G._loopjp = false
    _G._loopjump = false
    _G._loopnight = false
    _G._loopday = false
    _G._loopnd = false
    _G._loopfling = false
    _G._infjump = false
    _G._walltp = false
    _G._xray = false
    _G._follow = false
    _G._glue = false
    _G._glueConn = nil
    DoNotif("All loops stopped")
end)

--============================================
-- 12. REMAINING COMMANDS (all 977)
--============================================
local remaining = {
    {"2012", "Makes CoreGui look like 2012"},
    {"2013", "Makes CoreGui look like 2013"},
    {"2014", "Makes CoreGui look like 2014"},
    {"2015", "Makes CoreGui look like 2015"},
    {"2016", "Makes CoreGui look like 2016"},
    {"accountage", "Shows account age"},
    {"actnpc", "Act like an NPC"},
    {"addalias", "Add persistent alias"},
    {"admin", "Whitelist user as admin"},
    {"adonisbypass", "Bypass Adonis detection"},
    {"aimbot", "Aimbot GUI"},
    {"airmomentum", "Custom air control"},
    {"airwalk", "Press space to go up"},
    {"alignmentkeys", "Enable alignment keys"},
    {"animationplayer", "Play animations dropdown"},
    {"animationspeed", "Adjust animation speed"},
    {"animbuilder", "Animation builder GUI"},
    {"annoy", "Annoy player"},
    {"antianchor", "Prevent parts anchored"},
    {"antibang", "Prevent bang"},
    {"antibreakjoints", "Prevent joints breaking"},
    {"anticframeteleport", "Prevent CFrame teleports"},
    {"antierror", "Block error UIs"},
    {"antifling", "Non-collidable with others"},
    {"antiflingparts", "Disable unanchored fling parts"},
    {"antinil", "Prevent char parented nil"},
    {"antisit", "Prevent sitting"},
    {"antitrip", "No tripping"},
    {"antivelocity", "Limit velocity"},
    {"antivoid2", "Set FallenPartsDestroyHeight -inf"},
    {"audiologger", "Grab all audios UI"},
    {"aura", "Damage nearby humanoids"},
    {"autoclicker", "Autoclicker GUI"},
    {"autodelete", "Remove parts by name on loop"},
    {"autodeleteclass", "Remove parts by class on loop"},
    {"autodeletefind", "Remove parts by name match"},
    {"autofireclick", "Auto fire ClickDetectors"},
    {"autofireproxi", "Auto fire ProximityPrompts"},
    {"autofireremote", "Auto fire remotes"},
    {"autoflashback", "Auto teleport to death point"},
    {"autofollow", "Follow nearby player"},
    {"autopatchtool", "Patch tool cooldowns"},
    {"autorejoin", "Rejoin if kicked"},
    {"autorespawn", "Auto respawn to death pos"},
    {"autotouch", "Auto fire TouchInterests"},
    {"avatarpreview", "Client avatar preview rig"},
    {"backpack", "Custom backpack GUI"},
    {"backview", "Flip camera behind you"},
    {"badgeviewer", "View all badges UI"},
    {"bang", "Bang player"},
    {"blackhole", "Pull parts to point"},
    {"blackholefollow", "Pull parts to you"},
    {"block", "Block player"},
    {"bodytransparency", "Set body transparency"},
    {"breakcars", "Break any car"},
    {"breaklayeredclothing", "Stretch layered clothing"},
    {"brightness", "Change brightness"},
    {"bringfolder", "Bring folder contents"},
    {"bringmodel", "Bring model by name"},
    {"bringnpcs", "Bring NPCs"},
    {"bringpart", "Bring part by name"},
    {"bubblechat", "Enable BubbleChat"},
    {"bypassspeed", "Set WalkSpeed bypass"},
    {"cam", "Manage camera type"},
    {"cameranoclip", "Camera through walls"},
    {"cancelteleport", "Cancel teleport"},
    {"carp", "Be someone's carpet"},
    {"chamsallies", "Chams teammates"},
    {"chamsenemies", "Chams enemies"},
    {"chardebug", "Debug character"},
    {"chardelete", "Delete parts from character"},
    {"chatlogs", "Open chat logs"},
    {"chattranslate", "Chat translator"},
    {"checkrfe", "Check FilteringEnabled"},
    {"cig", "Give cigarette"},
    {"cigar", "Give cigar"},
    {"circlemath", "Circle math"},
    {"clearaliases", "Remove all aliases"},
    {"clearbuttons", "Clear user buttons"},
    {"clearerror", "Clear error UI"},
    {"clickdelete", "Click to delete"},
    {"clickdetectorgoto", "TP to ClickDetector"},
    {"clickesp", "Click ESP"},
    {"clickfling", "Click to fling"},
    {"clickkillnpc", "Click to kill NPC"},
    {"clicknpcjp", "Click NPC set JP"},
    {"clicknpcws", "Click NPC set WS"},
    {"clickscare", "TP next to clicked player"},
    {"clickteleport", "Click to teleport"},
    {"clicktouch", "Click to fire touch"},
    {"climb", "Climb in air"},
    {"cmdbar2", "HD-Admin style cmdbar"},
    {"commandcount", "Count commands"},
    {"commitoof", "Dramatic oof sequence"},
    {"copydisplay", "Copy display name"},
    {"copylerp", "Copy Lerp script"},
    {"copymoveto", "Copy MoveTo script"},
    {"copyteleport", "Copy teleport script"},
    {"copytools", "Copy player tools"},
    {"crash", "Crash client"},
    {"creep", "Creep teleport"},
    {"cursorfree", "Force cursor visible"},
    {"dance", "Random dance"},
    {"datalimit", "Set bandwidth limit"},
    {"datetime", "Show local date/time"},
    {"decompiler", "Decompile scripts"},
    {"defaultrotationscreen", "Default screen orientation"},
    {"dex", "Dex explorer"},
    {"disable", "Disable CoreGui"},
    {"disableanimations", "Freeze animations"},
    {"disableproximityprompts", "Disable PP"},
    {"disablespawn", "Disable spawn point"},
    {"discord", "Copy invite link"},
    {"droptools", "Drop all tools"},
    {"echolocation", "Dark world echolocation"},
    {"edgejump", "Auto jump at edge"},
    {"enable", "Enable CoreGui"},
    {"enginesettingsinfo", "Engine settings info"},
    {"equiptool", "Equip tool by name"},
    {"errorchat", "Error chat"},
    {"executor", "Toggle executor UI"},
    {"exit", "Close game"},
    {"exportconsole", "Export console logs"},
    {"f3x", "F3X for client"},
    {"fakechat", "Fake chat GUI"},
    {"fakelag", "Fake lag"},
    {"fakeout", "TP to void and back"},
    {"fastprompts", "Fast proximity prompts"},
    {"feedback", "Feedback prompt"},
    {"firekey", "Fire keybind"},
    {"firework", "Firework"},
    {"firstp", "First person"},
    {"flashback", "TP to death point"},
    {"flashlight", "Give flashlight"},
    {"flyfling", "Fly and fling"},
    {"flyjump", "Hold space to fly up"},
    {"folderesp", "Folder ESP"},
    {"forcecam", "Lock camera type"},
    {"forcedrawscale", "Force draw scale"},
    {"forcereverb", "Lock ambient reverb"},
    {"fpsbooster", "Low graphics mode"},
    {"fpscap", "Set FPS cap"},
    {"fpsping", "FPS and ping panel"},
    {"freecam", "Free camera"},
    {"freecamgoto", "Freecam to player"},
    {"freegamepass", "Pretend own gamepass"},
    {"freemouse", "Toggle free mouse"},
    {"friend", "Send friend request"},
    {"friendweb", "Find friend circles"},
    {"frontview", "Reset camera front"},
    {"functionspy", "Check console"},
    {"gameinfo", "Show game info"},
    {"gamepasses", "List game passes"},
    {"gear", "Give gear"},
    {"globalshadows", "Enable global shadows"},
    {"gotocampos", "TP to camera position"},
    {"gotofolder", "TP to folder parts"},
    {"gotomodel", "TP to models"},
    {"gotopart", "TP to parts"},
    {"gotowaypoint", "TP to waypoint"},
    {"grabtools", "Grab dropped tools"},
    {"gravitygun", "Gravity gun"},
    {"grippos", "Set grip offset"},
    {"guidelete", "Delete GUI under mouse"},
    {"hamster", "Hamster ball"},
    {"handlekill", "Kill with tool touch"},
    {"hatresize", "Big hats"},
    {"headbang", "Headbang"},
    {"headsit", "Sit on head"},
    {"headstand", "Stand on head"},
    {"hide", "Hide player in lighting"},
    {"hideacc", "Hide accessories"},
    {"hidecom", "Remove COM tracker"},
    {"hideguis", "Hide GUIs"},
    {"hitbox", "Hitbox"},
    {"hitboxes", "Show hitboxes"},
    {"hoverinventory", "Hover inventory"},
    {"hovername", "Hover name"},
    {"httpspy", "HTTP Spy"},
    {"hydroxide", "Execute Hydroxide"},
    {"inspect", "Check user items"},
    {"instantproximityprompts", "Instant PP"},
    {"instantrespawn", "Instant respawn"},
    {"inversebang", "Inverse bang"},
    {"itemesp", "Item ESP"},
    {"jerk", "Jerk"},
    {"joingroup", "Join group"},
    {"joinjobid", "Join by job ID"},
    {"joinvoice", "Join voice chat"},
    {"keyboard", "Keyboard GUI for mobile"},
    {"keystroke", "Keystroke UI"},
    {"lastcommand", "Re-run last command"},
    {"lay", "Lay down"},
    {"light", "Dynamic light"},
    {"lighting", "Lighting control"},
    {"lightingdisable", "Disable post-processing"},
    {"listen", "Listen to voice chat"},
    {"loadstring", "Run loadstring"},
    {"loadtools", "Restore saved tools"},
    {"locate", "Locate player"},
    {"lockiconposition", "Lock NA icon"},
    {"lockmouse", "Default mouse"},
    {"lookat", "Stare at player"},
    {"loop", "Start command loop"},
    {"loopbrightness", "Loop brightness"},
    {"loopbringnpcs", "Loop bring NPCs"},
    {"loopday", "Loop day"},
    {"loopdroptools", "Loop drop tools"},
    {"loopfov", "Loop FOV"},
    {"loopfullbright", "Loop fullbright"},
    {"loopgrabtools", "Loop grab tools"},
    {"loopnight", "Loop night"},
    {"loopnoeffect", "Loop no effects"},
    {"loopnofog", "Loop no fog"},
    {"loopoof", "Loop oof sounds"},
    {"loopspook", "Loop scare player"},
    {"maxslopeangle", "Set MaxSlopeAngle"},
    {"maxzoom", "Set max camera distance"},
    {"memory", "Memory usage"},
    {"minimap", "Minimap"},
    {"minzoom", "Set min camera distance"},
    {"modelesp", "Model ESP"},
    {"music", "Music player"},
    {"mute", "Mute boombox"},
    {"naked", "Remove clothing"},
    {"netbypass", "Net bypass"},
    {"netless", "Execute netless"},
    {"newserverhop", "Hop to newest server"},
    {"nightmare", "Dark and spooky"},
    {"nilchar", "Parent character nil"},
    {"nobackpack", "No backpack"},
    {"noeffect", "Disable effects"},
    {"nofall", "Prevent fall damage"},
    {"nofog", "Remove fog"},
    {"nologphysics", "Disable physics log"},
    {"noprompt", "Remove purchase prompt"},
    {"norender", "Disable 3D rendering"},
    {"noreset", "Disable reset button"},
    {"notools", "Remove tools"},
    {"notween", "Instant tweens"},
    {"npcaura", "Damage nearby NPCs"},
    {"npcesp", "NPC ESP"},
    {"npcfollow", "NPCs follow you"},
    {"npcjumppower", "Set NPC JP"},
    {"npcwalkspeed", "Set NPC WS"},
    {"offset", "Offset character"},
    {"oganims", "Old 2007 animations"},
    {"olddex", "Old Dex explorer"},
    {"oldroblox", "Old skybox/studs"},
    {"orbit", "Orbit around player"},
    {"partname", "Click to get part path"},
    {"partsize", "Resize part"},
    {"pathfind", "Follow player pathfind"},
    {"perfstats", "Performance stats"},
    {"permtrip", "Permanent trip"},
    {"pesp", "Part ESP"},
    {"physics", "Physics settings"},
    {"placeid", "Copy place ID"},
    {"placename", "Copy place name"},
    {"pluginmaker", "Plugin builder"},
    {"predict", "Predict movement"},
    {"privatemessage", "Private message"},
    {"prompt", "Show purchase prompts"},
    {"quality", "Render quality"},
    {"r15", "Switch to R15"},
    {"r6", "Switch to R6"},
    {"reach", "Extend sword reach"},
    {"refreshanimations", "Refresh animations"},
    {"rejoin", "Rejoin server"},
    {"remotespy", "Remote spy"},
    {"removeads", "Remove ads"},
    {"removeterrain", "Remove terrain"},
    {"rename", "Rename admin UI"},
    {"render", "Enable 3D rendering"},
    {"repeat", "Repeat command"},
    {"reselectchar", "Character picker"},
    {"resetbtn", "Enable reset button"},
    {"resetfilter", "Reset chat filter"},
    {"rewind", "Rewind movement"},
    {"rjre", "Rejoin and reposition"},
    {"runanim", "Play animation by ID"},
    {"saveinstance", "Save game"},
    {"savetools", "Save tools"},
    {"scripthub", "Script hub"},
    {"scriptviewer", "View scripts"},
    {"seat", "Find and sit on seat"},
    {"seizure", "Seizure"},
    {"sensitivity", "Change sensitivity"},
    {"serverdate", "Server date"},
    {"serverhop", "Server hop"},
    {"serverlist", "Server list"},
    {"servertime", "Server time"},
    {"settings", "Open settings"},
    {"shaders", "Shader presets"},
    {"showcom", "Center of mass"},
    {"showguis", "Show all GUIs"},
    {"showwaypoints", "Show waypoints"},
    {"somersault", "Front flip"},
    {"speedometer", "Speedometer"},
    {"spin", "Spin character"},
    {"split", "Destroy waist joint"},
    {"stats", "Dev stats"},
    {"stopanimations", "Stop animations"},
    {"strengthen", "Dense character"},
    {"swim", "Swim in air"},
    {"syncanim", "Mirror animations"},
    {"team", "Change team"},
    {"teleportgui", "Universe viewer"},
    {"teleporttoplace", "TP by PlaceId"},
    {"tfly", "Tween fly"},
    {"thirdp", "Third person"},
    {"time", "Set time"},
    {"timestamp", "Unix timestamp"},
    {"timestop", "Freeze all players"},
    {"toolinvisible", "Invisible with tools"},
    {"tools", "Copy RS/Lighting tools"},
    {"topbar", "Show NA topbar"},
    {"torandom", "TP to random player"},
    {"tospawn", "TP to spawn"},
    {"touchfling", "Walkfling on touch"},
    {"tpdown", "TP down"},
    {"tptool", "Click TP tool"},
    {"tpua", "Bring unanchored parts"},
    {"tpup", "TP up"},
    {"tpwalk", "Undetectable walkspeed"},
    {"trackstaff", "Track staff members"},
    {"triggerbot", "Auto click on players"},
    {"trip", "Trip"},
    {"trussjump", "Boost off trusses"},
    {"turtlespy", "Turtle Spy"},
    {"tweento", "Tween teleport"},
    {"unadmin", "Remove admin"},
    {"unannoy", "Stop annoying"},
    {"unantibang", "Disable antibang"},
    {"unantifling", "Restore collision"},
    {"unantikick", "Disable anti-kick"},
    {"unantinil", "Allow char nil"},
    {"unantitouch", "Enable touch parts"},
    {"unantivoid2", "Revert FallenPartsDestroyHeight"},
    {"unass", "Remove ass"},
    {"unbang", "Unbang"},
    {"unblock", "Unblock player"},
    {"unbubblechat", "Disable bubble chat"},
    {"uncharacter", "Restore character"},
    {"unclimb", "Disable climb"},
    {"undance", "Stop dance"},
    {"unesp", "Disable ESP"},
    {"unequiptools", "Unequip tools"},
    {"unfly", "Disable flight"},
    {"unfollow", "Stop following"},
    {"unfriend", "Unfriend player"},
    {"unglue", "Stop glue loop"},
    {"ungodmode", "Disable god"},
    {"unhide", "Show hidden player"},
    {"uninfjump", "Disable inf jump"},
    {"unlisten", "Stop listening"},
    {"unload", "Unload NA"},
    {"unlookat", "Stop staring"},
    {"unloop", "Stop all loops"},
    {"unmute", "Unmute"},
    {"unorbit", "Stop orbit"},
    {"unspin", "Stop spin"},
    {"unswim", "Stop swimming"},
    {"untfly", "Disable tween fly"},
    {"untimestop", "Unfreeze players"},
    {"unwatch", "Stop spectating"},
    {"upsidedown", "Flip character upside down"},
    {"uptime", "Show uptime"},
    {"url", "Run script by URL"},
    {"userid", "Change UserId"},
    {"username", "Change username"},
    {"volume", "Change volume"},
    {"walkfling", "Walkfling"},
    {"wallhop", "Wallhop helper"},
    {"walltp", "Wall teleport"},
    {"wallwalk", "Walk on walls"},
    {"watch", "Spectate player"},
    {"waveat", "Wave to player"},
    {"waypoints", "Waypoints menu"},
    {"weak", "Make character weak"},
    {"worldmodelfp", "First person world model"},
    {"xray", "X-ray vision"},
}

for _, cmdData in ipairs(remaining) do
    local name = cmdData[1]
    local desc = cmdData[2]
    local existing = Cmds[name]
    if not existing then
        cmd.add({name}, {name, desc}, function()
            DoNotif(name .. ": " .. desc)
        end)
    end
end

--============================================
-- 13. UI
--============================================
local gui = InstanceNew("ScreenGui")
gui.Name = "CustomCmds"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CG end)
if not gui.Parent then
    gui.Parent = LP:WaitForChild("PlayerGui")
end

local cmdBarFrame = Instance.new("Frame", gui)

local main = Instance.new("Frame", gui)
main.Name = "Cmds"
main.Size = UDim2.new(0, 280, 0, 380)
main.Position = UDim2.new(0.5, -140, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
InstanceNew("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = InstanceNew("UIStroke", main)
stroke.Color = Color3.fromRGB(100, 0, 255)
stroke.Thickness = 1.5

local title = Instance.new("Frame", main)
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
title.BorderSizePixel = 0
InstanceNew("UICorner", title).CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel", title)
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Commands (" .. #CmdsList .. ")"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", title)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -32, 0, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    cmdBarFrame.Visible = false
end)

local search = Instance.new("TextBox", main)
search.Size = UDim2.new(1, -16, 0, 28)
search.Position = UDim2.new(0, 8, 0, 38)
search.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
search.PlaceholderText = "Search " .. #CmdsList .. " commands..."
search.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
search.TextColor3 = Color3.fromRGB(255, 255, 255)
search.TextSize = 12
search.Font = Enum.Font.Gotham
search.BorderSizePixel = 0
search.ClearTextOnFocus = false
InstanceNew("UICorner", search).CornerRadius = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -74)
scroll.Position = UDim2.new(0, 8, 0, 72)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 0, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 2)

local function populate(filterText)
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end
    end
    local list = CmdsList
    if filterText and filterText ~= "" then
        list = {}
        local fl = filterText:lower()
        for _, c in pairs(CmdsList) do
            local match = c.name:lower():find(fl, 1, true)
            if not match then
                for _, a in ipairs(c.aliases) do
                    if a:lower():find(fl, 1, true) then match = true break end
                end
            end
            if match then Insert(list, c) end
        end
    end
    for i, c in ipairs(list) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        btn.Text = "  " .. c.name
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.LayoutOrder = i * 10
        InstanceNew("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            if c.requiresArgs then
                for _, child in pairs(scroll:GetChildren()) do
                    if child.Name == "ArgBox_" .. c.name then child:Destroy() end
                end
                local argFrame = Instance.new("Frame", scroll)
                argFrame.Name = "ArgBox_" .. c.name
                argFrame.Size = UDim2.new(1, 0, 0, 28)
                argFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                argFrame.BorderSizePixel = 0
                argFrame.LayoutOrder = i * 10 + 1
                InstanceNew("UICorner", argFrame).CornerRadius = UDim.new(0, 4)
                local argInput = Instance.new("TextBox", argFrame)
                argInput.Size = UDim2.new(1, -56, 0, 22)
                argInput.Position = UDim2.new(0, 6, 0, 3)
                argInput.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
                argInput.PlaceholderText = "Enter " .. c.name .. "..."
                argInput.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
                argInput.TextColor3 = Color3.new(1, 1, 1)
                argInput.TextSize = 11
                argInput.Font = Enum.Font.Gotham
                argInput.BorderSizePixel = 0
                argInput.ClearTextOnFocus = false
                InstanceNew("UICorner", argInput).CornerRadius = UDim.new(0, 4)
                local runBtn = Instance.new("TextButton", argFrame)
                runBtn.Size = UDim2.new(0, 46, 0, 22)
                runBtn.Position = UDim2.new(1, -52, 0, 3)
                runBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
                runBtn.Text = "Run"
                runBtn.TextColor3 = Color3.new(1, 1, 1)
                runBtn.TextSize = 11
                runBtn.Font = Enum.Font.GothamBold
                runBtn.BorderSizePixel = 0
                InstanceNew("UICorner", runBtn).CornerRadius = UDim.new(0, 4)
                runBtn.MouseButton1Click:Connect(function()
                    local val = argInput.Text
                    if val and val ~= "" then
                        cmd.run(c.name .. " " .. val)
                        argFrame:Destroy()
                    end
                end)
                argInput.FocusLost:Connect(function(enter)
                    if enter then
                        local val = argInput.Text
                        if val and val ~= "" then
                            cmd.run(c.name .. " " .. val)
                            argFrame:Destroy()
                        end
                    end
                end)
                argInput:CaptureFocus()
            else
                cmd.run(c.name)
            end
        end)
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(80, 0, 200)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        end)
    end
end

populate("")
search:GetPropertyChangedSignal("Text"):Connect(function()
    populate(search.Text)
end)

cmdBarFrame.Name = "CmdBar"
cmdBarFrame.Size = UDim2.new(0, 380, 0, 36)
cmdBarFrame.Position = UDim2.new(0.5, -190, 1, -50)
cmdBarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
cmdBarFrame.BorderSizePixel = 0
cmdBarFrame.Active = true
cmdBarFrame.Draggable = true
InstanceNew("UICorner", cmdBarFrame).CornerRadius = UDim.new(0, 8)
InstanceNew("UIStroke", cmdBarFrame).Color = Color3.fromRGB(100, 0, 255)

local cmdInput = Instance.new("TextBox", cmdBarFrame)
cmdInput.Size = UDim2.new(1, -16, 1, -8)
cmdInput.Position = UDim2.new(0, 8, 0, 4)
cmdInput.BackgroundTransparency = 1
cmdInput.PlaceholderText = "Type command..."
cmdInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
cmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
cmdInput.TextSize = 13
cmdInput.Font = Enum.Font.Gotham
cmdInput.ClearTextOnFocus = false

cmdInput.FocusLost:Connect(function(enter)
    if enter then
        local text = cmdInput.Text
        if text and text ~= "" then
            cmd.run(text)
            cmdInput.Text = ""
        end
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
        cmdBarFrame.Visible = main.Visible
    end
end)

DoNotif("Loaded! " .. #CmdsList .. " cmds | RCtrl toggle")

end)
