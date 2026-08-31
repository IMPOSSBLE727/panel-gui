--[[
    Custom Commands Panel v2
    From scratch - minimal infrastructure + commands
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

--============================================
-- 2. LOCAL PLAYER
--============================================
local LP = Players.LocalPlayer

--============================================
-- 3. CHARACTER HELPERS
--============================================
local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function getHum()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")
end

local function getHead()
    local c = getChar()
    if not c then return nil end
    return c:FindFirstChild("Head")
end

local function getBp()
    return LP:FindFirstChildOfClass("Backpack")
end

local function getPlr(input)
    if not input or input == "" then return {LP} end
    input = input:lower()
    local results = {}
    if input == "me" or input == "self" then
        return {LP}
    elseif input == "all" then
        return Players:GetPlayers()
    elseif input == "others" or input == "others" then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP then table.insert(results, p) end
        end
        return results
    elseif input == "random" then
        local all = Players:GetPlayers()
        if #all > 0 then return {all[math.random(#all)]} end
        return {LP}
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():sub(1, #input) == input or p.DisplayName:lower():sub(1, #input) == input then
                table.insert(results, p)
            end
        end
        return results
    end
    return results
end

--============================================
-- 4. GLOBAL ALIASES
--============================================
local Insert = table.insert
local Remove = table.remove
local Lower = string.lower
local Sub = string.sub
local Find = string.find
local Format = string.format
local GSub = string.gsub

local function Spawn(fn, ...)
    task.spawn(fn, ...)
end

local function Defer(fn, ...)
    task.defer(fn, ...)
end

local function Wait(n)
    task.wait(n)
end

local function InstanceNew(class, parent)
    local obj = Instance.new(class)
    if parent then obj.Parent = parent end
    return obj
end

local function InstanceNewNC(class)
    return Instance.new(class)
end

--============================================
-- 5. NOTIFICATION
--============================================
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
-- 6. CMD SYSTEM
--============================================
local Cmds = {}
local CmdsList = {}
local cmd = {}

function cmd.add(aliases, info, func, requiresArgs)
    local data = {
        func = func,
        info = info,
        requiresArgs = requiresArgs or false
    }
    for _, alias in ipairs(aliases) do
        Cmds[Lower(alias)] = data
    end
    Insert(CmdsList, {
        name = aliases[1],
        aliases = aliases,
        info = info,
        requiresArgs = requiresArgs or false
    })
end

function cmd.run(input)
    if not input or input == "" then return end
    local parts = input:split(" ")
    local cmdName = Lower(Remove(parts, 1))
    local c = Cmds[cmdName]
    if c then
        local ok, err = pcall(function()
            c.func(unpack(parts))
        end)
        if not ok then
            DoNotif("Error: " .. tostring(err), 5)
        end
    else
        DoNotif("Unknown: " .. cmdName)
    end
end

--============================================
-- 7. COMMANDS
--============================================

-- FLY
cmd.add({"fly"}, {"fly", "Enables flight"}, function(speed)
    local hum = getHum()
    local root = getRoot()
    if not hum or not root then return end
    speed = tonumber(speed) or 50
    if _G._flyBP then _G._flyBP:Destroy() end
    if _G._flyBG then _G._flyBG:Destroy() end
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
        if UIS:IsKeyDown(Enum.KeyCode.W) then
            dir = dir + Workspace.CurrentCamera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            dir = dir - Workspace.CurrentCamera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            dir = dir - Workspace.CurrentCamera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            dir = dir + Workspace.CurrentCamera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            dir = dir + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            dir = dir - Vector3.new(0, 1, 0)
        end
        bp.Velocity = dir * speed
        bg.CFrame = Workspace.CurrentCamera.CFrame
    end)
    DoNotif("Fly ON " .. speed)
end)

cmd.add({"unfly", "nofly"}, {"unfly", "Disables flight"}, function()
    if _G._flyConn then _G._flyConn:Disconnect() end
    if _G._flyBP then _G._flyBP:Destroy() end
    if _G._flyBG then _G._flyBG:Destroy() end
    _G._flyConn = nil
    _G._flyBP = nil
    _G._flyBG = nil
    DoNotif("Fly OFF")
end)

-- SPEED
cmd.add({"speed", "ws"}, {"speed <num>", "Sets walkspeed"}, function(v)
    local h = getHum()
    if not h then return end
    h.WalkSpeed = tonumber(v) or 16
    DoNotif("Speed: " .. h.WalkSpeed)
end)

cmd.add({"jumppower", "jp"}, {"jp <num>", "Sets jump power"}, function(v)
    local h = getHum()
    if not h then return end
    h.JumpPower = tonumber(v) or 50
    DoNotif("JumpPower: " .. h.JumpPower)
end)

cmd.add({"hipheight", "hh"}, {"hh <num>", "Sets hip height"}, function(v)
    local h = getHum()
    if not h then return end
    h.HipHeight = tonumber(v) or 0
    DoNotif("HipHeight: " .. h.HipHeight)
end)

cmd.add({"gravity"}, {"gravity <num>", "Sets gravity"}, function(v)
    Workspace.Gravity = tonumber(v) or 196.2
    DoNotif("Gravity: " .. Workspace.Gravity)
end)

-- NOCLIP
cmd.add({"noclip", "nc"}, {"noclip", "Enables noclip"}, function()
    _G._noclip = true
    if _G._noclipConn then _G._noclipConn:Disconnect() end
    _G._noclipConn = RunService.Stepped:Connect(function()
        if not _G._noclip then return end
        local c = LP.Character
        if c then
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
    DoNotif("Noclip ON")
end)

cmd.add({"clip"}, {"clip", "Disables noclip"}, function()
    _G._noclip = false
    if _G._noclipConn then _G._noclipConn:Disconnect() end
    DoNotif("Noclip OFF")
end)

-- TELEPORT
cmd.add({"tp", "teleport"}, {"tp <player>", "Teleport to player"}, function(target)
    if not target or target == "" then return end
    local root = getRoot()
    if not root then return end
    local plrs = getPlr(target)
    if #plrs > 0 and plrs[1] ~= LP then
        local p = plrs[1]
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                root.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                DoNotif("TP -> " .. p.Name)
            end
        end
    else
        DoNotif("Player not found")
    end
end)

cmd.add({"goto"}, {"goto <player>", "Go to player"}, function(target)
    if not target or target == "" then return end
    local root = getRoot()
    if not root then return end
    local plrs = getPlr(target)
    if #plrs > 0 and plrs[1] ~= LP then
        local p = plrs[1]
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                root.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                DoNotif("Goto " .. p.Name)
            end
        end
    else
        DoNotif("Player not found")
    end
end)

cmd.add({"bring"}, {"bring <player>", "Bring player to you"}, function(target)
    if not target or target == "" then return end
    local root = getRoot()
    if not root then return end
    local plrs = getPlr(target)
    if #plrs > 0 and plrs[1] ~= LP then
        local p = plrs[1]
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                DoNotif("Brought " .. p.Name)
            end
        end
    else
        DoNotif("Player not found")
    end
end)

-- GOD
cmd.add({"god", "godmode"}, {"god", "God mode"}, function()
    local h = getHum()
    if not h then return end
    h.MaxHealth = 9e9
    h.Health = 9e9
    DoNotif("God ON")
end)

cmd.add({"heal"}, {"heal", "Full health"}, function()
    local h = getHum()
    if not h then return end
    h.Health = h.MaxHealth
    DoNotif("Healed")
end)

-- KILL
cmd.add({"kill"}, {"kill <player>", "Kill player"}, function(target)
    if not target or target == "" then return end
    local plrs = getPlr(target)
    if #plrs > 0 and plrs[1] ~= LP then
        local p = plrs[1]
        if p.Character then
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if h then
                h.Health = 0
                DoNotif("Killed " .. p.Name)
            end
        end
    else
        DoNotif("Player not found")
    end
end)

-- INVISIBLE / VISIBLE
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

-- SIT / UNSIT
cmd.add({"sit"}, {"sit", "Sit down"}, function()
    local h = getHum()
    if h then h.Sit = true DoNotif("Sitting") end
end)

cmd.add({"unsit", "stand"}, {"unsit", "Stand up"}, function()
    local h = getHum()
    if h then h.Sit = false DoNotif("Standing") end
end)

-- JUMP
cmd.add({"jump"}, {"jump", "Jump"}, function()
    local h = getHum()
    if h then h.Jump = true end
end)

-- RESPAWN
cmd.add({"respawn", "re"}, {"respawn", "Respawn character"}, function()
    LP:LoadCharacter()
    DoNotif("Respawning...")
end)

-- LIGHT
cmd.add({"light", "bright"}, {"light", "Bright mode"}, function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    DoNotif("Bright ON")
end)

cmd.add({"dark"}, {"dark", "Dark mode"}, function()
    Lighting.Brightness = 0
    Lighting.ClockTime = 0
    Lighting.GlobalShadows = true
    Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    DoNotif("Dark ON")
end)

-- ESP
cmd.add({"esp"}, {"esp", "Box ESP"}, function()
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

cmd.add({"unesp", "noesp"}, {"unesp", "Disable ESP"}, function()
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

-- FORCEFIELD
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

-- BTOOLS
cmd.add({"btools"}, {"btools", "Building tools"}, function()
    local bp = getBp()
    if not bp then return end
    local t = InstanceNew("Tool", bp)
    t.Name = "BTool"
    t.CanBeDropped = false
    InstanceNew("Part", t).Transparency = 1
    DoNotif("BTools given")
end)

-- PLAYERS LIST
cmd.add({"players", "plrs"}, {"players", "List players"}, function()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        Insert(names, p.Name)
    end
    DoNotif(table.concat(names, ", "))
end)

-- FPS
cmd.add({"fps"}, {"fps", "Show FPS"}, function()
    local t = tick()
    RunService.RenderStepped:Wait()
    local fps = math.floor(1 / (tick() - t))
    DoNotif("FPS: " .. fps)
end)

-- PING
cmd.add({"ping"}, {"ping", "Show ping"}, function()
    DoNotif("Ping: " .. math.floor(LP:GetNetworkPing() * 1000) .. "ms")
end)

-- POSITION
cmd.add({"pos", "position"}, {"pos", "Show position"}, function()
    local r = getRoot()
    if not r then return end
    local p = r.Position
    DoNotif(math.floor(p.X) .. ", " .. math.floor(p.Y) .. ", " .. math.floor(p.Z))
end)

-- GOTO COORDS
cmd.add({"tpws", "tpworkspace"}, {"tpws <x,y,z>", "Teleport to coords"}, function(x, y, z)
    local root = getRoot()
    if not root then return end
    x = tonumber(x) or 0
    y = tonumber(y) or 50
    z = tonumber(z) or 0
    root.CFrame = CFrame.new(x, y, z)
    DoNotif("TP -> " .. x .. "," .. y .. "," .. z)
end)

--============================================
-- 8. UI - COMMANDS PANEL
--============================================
local gui = InstanceNew("ScreenGui")
gui.Name = "CustomCmds"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CG end)
if not gui.Parent then
    gui.Parent = LP:WaitForChild("PlayerGui")
end

-- Main Frame
local main = InstanceNew("Frame", gui)
main.Name = "Cmds"
main.Size = UDim2.new(0, 280, 0, 380)
main.Position = UDim2.new(0.5, -140, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
InstanceNew("UICorner", main).CornerRadius = UDim.new(0, 10)
local stroke = InstanceNew("UIStroke", main)
stroke.Color = Color3.fromRGB(100, 0, 255)
stroke.Thickness = 1.5

-- Title
local title = InstanceNew("Frame", main)
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
title.BorderSizePixel = 0
InstanceNew("UICorner", title).CornerRadius = UDim.new(0, 10)

local titleText = InstanceNew("TextLabel", title)
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

-- Search
local search = Instance.new("TextBox", main)
search.Size = UDim2.new(1, -16, 0, 28)
search.Position = UDim2.new(0, 8, 0, 38)
search.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
search.PlaceholderText = "Search..."
search.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
search.TextColor3 = Color3.fromRGB(255, 255, 255)
search.TextSize = 12
search.Font = Enum.Font.Gotham
search.BorderSizePixel = 0
search.ClearTextOnFocus = false
InstanceNew("UICorner", search).CornerRadius = UDim.new(0, 6)

-- Scroll
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
        if child:IsA("TextButton") then child:Destroy() end
    end
    local list = CmdsList
    if filterText and filterText ~= "" then
        list = {}
        for _, c in pairs(CmdsList) do
            local match = c.name:lower():find(filterText:lower(), 1, true)
            if not match then
                for _, a in ipairs(c.aliases) do
                    if a:lower():find(filterText:lower(), 1, true) then
                        match = true
                        break
                    end
                end
            end
            if match then Insert(list, c) end
        end
    end
    for i, c in ipairs(list) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        btn.Text = "  " .. c.name
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.LayoutOrder = i
        InstanceNew("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            if c.requiresArgs then
                search.Text = c.name .. " "
                search:CaptureFocus()
            else
                cmd.run(c.name)
            end
        end)
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(80, 0, 200)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        end)
    end
end

populate("")
search:GetPropertyChangedSignal("Text"):Connect(function()
    populate(search.Text)
end)

-- Command Bar
local cmdBarFrame = Instance.new("Frame", gui)
cmdBarFrame.Name = "CmdBar"
cmdBarFrame.Size = UDim2.new(0, 380, 0, 36)
cmdBarFrame.Position = UDim2.new(0.5, -190, 1, -50)
cmdBarFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
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
cmdInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
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

-- Toggle
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
        cmdBarFrame.Visible = main.Visible
    end
end)

DoNotif("Loaded! " .. #CmdsList .. " cmds | RCtrl toggle")

end)
