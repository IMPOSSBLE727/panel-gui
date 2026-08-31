--[[
    Custom Commands Panel
    Built from scratch - Nameless Admin Commands System
]]

-- SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")

-- LOCAL PLAYER
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- CHARACTER HELPERS
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

local function getHumRP()
    local c = getChar()
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h
end

-- COMMAND SYSTEM
local Cmds = {}
local CmdsList = {}

local function addCmd(aliases, info, func, requiresArgs)
    local data = {
        func = func,
        info = info,
        requiresArgs = requiresArgs or false,
        aliases = aliases
    }
    for _, alias in ipairs(aliases) do
        Cmds[alias:lower()] = data
    end
    table.insert(CmdsList, {
        name = aliases[1],
        aliases = aliases,
        info = info,
        requiresArgs = requiresArgs or false
    })
end

local function runCmd(input)
    if not input or input == "" then return end
    local args = string.split(input, " ")
    local cmdName = table.remove(args, 1):lower()
    local cmd = Cmds[cmdName]
    if cmd then
        local success, err = pcall(function()
            cmd.func(unpack(args))
        end)
        if not success then
            warn("[Cmd Error] " .. cmdName .. ": " .. tostring(err))
        end
    else
        warn("[Cmd] Unknown command: " .. cmdName)
    end
end

-- NOTIFICATION HELPER
local function notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Commands Panel",
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- ============================================
-- COMMANDS
-- ============================================

-- FLY
addCmd({"fly", "f"}, {"fly", "Enables flight"}, function(speed)
    localhum = getHum()
    localroot = getRoot()
    if not hum or not root then return end
    speed = tonumber(speed) or 50
    local flying = true
    local bp = Instance.new("BodyVelocity")
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.Velocity = Vector3.new(0, 0, 0)
    bp.Parent = root
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9000
    bg.D = 500
    bg.Parent = root
    _G._flyBP = bp
    _G._flyBG = bg
    _G._flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not bp.Parent then return end
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        bp.Velocity = dir * speed
        bg.CFrame = Workspace.CurrentCamera.CFrame
    end)
    notify("Fly enabled (speed: " .. speed .. ")")
end)

addCmd({"unfly", "nofly", "df"}, {"unfly", "Disables flight"}, function()
    if _G._flyConn then _G._flyConn:Disconnect() end
    if _G._flyBP then _G._flyBP:Destroy() end
    if _G._flyBG then _G._flyBG:Destroy() end
    _G._flyConn = nil
    _G._flyBP = nil
    _G._flyBG = nil
    notify("Fly disabled")
end)

-- SPEED
addCmd({"speed", "ws", "walkspeed"}, {"speed <number>", "Sets walkspeed"}, function(speed)
    local hum = getHum()
    if not hum then return end
    speed = tonumber(speed) or 16
    hum.WalkSpeed = speed
    notify("Speed set to " .. speed)
end)

addCmd({"normalspeed", "ns"}, {"normalspeed", "Resets walkspeed to 16"}, function()
    local hum = getHum()
    if not hum then return end
    hum.WalkSpeed = 16
    notify("Speed reset to 16")
end)

-- JUMPPower
addCmd({"jumppower", "jp"}, {"jumppower <number>", "Sets jump power"}, function(power)
    local hum = getHum()
    if not hum then return end
    power = tonumber(power) or 50
    hum.JumpPower = power
    notify("Jump power set to " .. power)
end)

addCmd({"normaljump", "nj"}, {"normaljump", "Resets jump power to 50"}, function()
    local hum = getHum()
    if not hum then return end
    hum.JumpPower = 50
    notify("Jump power reset to 50")
end)

-- NOCLIP
addCmd({"noclip", "nc"}, {"noclip", "Enables noclip"}, function()
    _G._noclip = true
    _G._noclipConn = RunService.Stepped:Connect(function()
        if not _G._noclip then return end
        local c = getChar()
        if c then
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)
    notify("Noclip enabled")
end)

addCmd({"clip", "reonclip"}, {"clip", "Disables noclip"}, function()
    _G._noclip = false
    if _G._noclipConn then _G._noclipConn:Disconnect() end
    notify("Noclip disabled")
end)

-- TELEPORT
addCmd({"tp", "teleport"}, {"tp <player>", "Teleports to a player"}, function(target)
    if not target or target == "" then return end
    local root = getRoot()
    if not root then return end
    local targetPlayer = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #target) == target:lower() or p.DisplayName:lower():sub(1, #target) == target:lower() then
            targetPlayer = p
            break
        end
    end
    if targetPlayer and targetPlayer.Character then
        local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            notify("Teleported to " .. targetPlayer.Name)
        end
    else
        notify("Player not found: " .. target)
    end
end)

-- GOTO
addCmd({"goto", "to"}, {"goto <player>", "Teleports to a player"}, function(target)
    if not target or target == "" then return end
    local root = getRoot()
    if not root then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #target) == target:lower() or p.DisplayName:lower():sub(1, #target) == target:lower() then
            if p.Character then
                local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
                    notify("Teleported to " .. p.Name)
                end
            end
            return
        end
    end
    notify("Player not found: " .. target)
end)

-- BRING
addCmd({"bring"}, {"bring <player>", "Brings a player to you"}, function(target)
    if not target or target == "" then return end
    local root = getRoot()
    if not root then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #target) == target:lower() or p.DisplayName:lower():sub(1, #target) == target:lower() then
            if p.Character then
                local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    targetRoot.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                    notify("Brought " .. p.Name)
                end
            end
            return
        end
    end
    notify("Player not found: " .. target)
end)

-- GOD
addCmd({"god", "godmode"}, {"god", "Enables god mode"}, function()
    local hum = getHum()
    if not hum then return end
    hum.MaxHealth = math.huge
    hum.Health = math.huge
    notify("God mode enabled")
end)

-- HEAL
addCmd({"heal"}, {"heal", "Full heal"}, function()
    local hum = getHum()
    if not hum then return end
    hum.Health = hum.MaxHealth
    notify("Healed")
end)

-- KILL
addCmd({"kill"}, {"kill <player>", "Kills a player"}, function(target)
    if not target or target == "" then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #target) == target:lower() or p.DisplayName:lower():sub(1, #target) == target:lower() then
            if p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = 0
                    notify("Killed " .. p.Name)
                end
            end
            return
        end
    end
    notify("Player not found: " .. target)
end)

-- INVISIBLE
addCmd({"invisible", "invis"}, {"invisible", "Makes you invisible"}, function()
    local char = getChar()
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Transparency = 1
        elseif v:IsA("Decal") then
            v.Transparency = 1
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Name = "Humanoid_" .. tick()
    end
    notify("Invisible")
end)

-- VISIBLE
addCmd({"visible", "vis"}, {"visible", "Makes you visible"}, function()
    local char = getChar()
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.Transparency = 0
        elseif v:IsA("Decal") then
            v.Transparency = 0
        end
    end
    notify("Visible")
end)

-- SIT
addCmd({"sit"}, {"sit", "Makes your character sit"}, function()
    local hum = getHum()
    if not hum then return end
    hum.Sit = true
    notify("Sitting")
end)

-- UNSIT
addCmd({"unsit", "stand"}, {"unsit", "Makes your character stand"}, function()
    local hum = getHum()
    if not hum then return end
    hum.Sit = false
    notify("Standing")
end)

-- JUMP
addCmd({"jump", "j"}, {"jump", "Makes you jump"}, function()
    local hum = getHum()
    if not hum then return end
    hum.Jump = true
    notify("Jumped")
end)

-- RESPAWN
addCmd({"respawn", "re"}, {"respawn", "Respawns your character"}, function()
    LP:LoadCharacter()
    notify("Respawning...")
end)

-- R15 / R6
addCmd({"torso"}, {"torso", "Shows torso info"}, function()
    local char = getChar()
    if not char then return end
    local r15 = char:FindFirstChild("UpperTorso") ~= nil
    notify(r15 and "R15" or "R6")
end)

-- FPS
addCmd({"fps"}, {"fps", "Shows your FPS"}, function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    notify("FPS: " .. fps)
end)

-- Ping
addCmd({"ping"}, {"ping", "Shows your ping"}, function()
    notify("Ping: " .. math.floor(LP:GetNetworkPing() * 1000) .. "ms")
end)

-- CFRAME SPEED (vehicle)
addCmd({"cframespeed", "cfspeed"}, {"cframespeed <number>", "Sets CFrame speed"}, function(speed)
    speed = tonumber(speed) or 1
    _G._cfspeed = speed
    _G._cfEnabled = true
    notify("CFrame speed: " .. speed)
end)

-- STOP CF
addCmd({"stopcf", "uncframespeed"}, {"stopcf", "Stops CFrame speed"}, function()
    _G._cfEnabled = false
    _G._cfspeed = nil
    notify("CFrame speed stopped")
end)

-- LIGHT
addCmd({"light", "bright"}, {"light", "Makes the map bright"}, function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    notify("Bright mode enabled")
end)

addCmd({"nolight", "darklight"}, {"nolight", "Resets lighting"}, function()
    Lighting.Brightness = 1
    Lighting.ClockTime = 12
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = true
    Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    notify("Lighting reset")
end)

-- ESP (simple box esp)
addCmd({"esp"}, {"esp", "Simple box ESP"}, function()
    _G._espEnabled = true
    _G._espConn = RunService.RenderStepped:Connect(function()
        if not _G._espEnabled then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local scale = 2000 / pos.Z
                        local size = Vector2.new(scale * 2, scale * 4)
                        local espGui = hrp:FindFirstChild("_ESP")
                        if not espGui then
                            espGui = Instance.new("BillboardGui")
                            espGui.Name = "_ESP"
                            espGui.Size = UDim2.new(0, 100, 0, 50)
                            espGui.AlwaysOnTop = true
                            espGui.Adornee = hrp
                            local frame = Instance.new("Frame", espGui)
                            frame.Size = UDim2.new(1, 0, 1, 0)
                            frame.BackgroundTransparency = 0.5
                            frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                            frame.BorderSizePixel = 0
                            local label = Instance.new("TextLabel", espGui)
                            label.Size = UDim2.new(1, 0, 0.5, 0)
                            label.BackgroundTransparency = 1
                            label.Text = p.Name
                            label.TextColor3 = Color3.new(1, 1, 1)
                            label.TextScaled = true
                            local hp = Instance.new("TextLabel", espGui)
                            hp.Position = UDim2.new(0, 0, 0.5, 0)
                            hp.Size = UDim2.new(1, 0, 0.5, 0)
                            hp.BackgroundTransparency = 1
                            hp.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                            hp.TextColor3 = Color3.new(0, 1, 0)
                            hp.TextScaled = true
                            espGui.Parent = hrp
                        end
                    end
                end
            end
        end
    end)
    notify("ESP enabled")
end)

addCmd({"unesp", "noesp"}, {"unesp", "Disables ESP"}, function()
    _G._espEnabled = false
    if _G._espConn then _G._espConn:Disconnect() end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local esp = hrp:FindFirstChild("_ESP")
                if esp then esp:Destroy() end
            end
        end
    end
    notify("ESP disabled")
end)

-- ============================================
-- UI - COMMANDS PANEL
-- ============================================

local function createUI()
    -- Remove old GUI if exists
    local old = CoreGui:FindFirstChild("CustomCmds")
    if old then old:Destroy() end

    -- Main ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "CustomCmds"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui

    -- Commands Frame
    local frame = Instance.new("Frame")
    frame.Name = "CommandsFrame"
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 0, 255)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    title.Text = "Commands"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.BorderSizePixel = 0
    title.Parent = frame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title

    -- Filter Box
    local filter = Instance.new("TextBox")
    filter.Size = UDim2.new(1, -16, 0, 30)
    filter.Position = UDim2.new(0, 8, 0, 40)
    filter.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    filter.PlaceholderText = "Search commands..."
    filter.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    filter.TextColor3 = Color3.fromRGB(255, 255, 255)
    filter.TextSize = 13
    filter.Font = Enum.Font.Gotham
    filter.BorderSizePixel = 0
    filter.ClearTextOnFocus = false
    filter.Parent = frame

    local filterCorner = Instance.new("UICorner")
    filterCorner.CornerRadius = UDim.new(0, 6)
    filterCorner.Parent = filter

    -- Commands Scrolling Frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "CommandsList"
    scroll.Size = UDim2.new(1, -16, 1, -80)
    scroll.Position = UDim2.new(0, 8, 0, 76)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 0, 255)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = scroll

    -- Populate commands
    local function populate(filterText)
        for _, child in pairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local filtered = CmdsList
        if filterText and filterText ~= "" then
            filtered = {}
            for _, cmd in pairs(CmdsList) do
                if cmd.name:lower():find(filterText:lower(), 1, true) then
                    table.insert(filtered, cmd)
                end
                for _, alias in ipairs(cmd.aliases) do
                    if alias:lower():find(filterText:lower(), 1, true) then
                        table.insert(filtered, cmd)
                        break
                    end
                end
            end
        end

        for _, cmd in ipairs(filtered) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            btn.Text = "  " .. cmd.name .. (cmd.requiresArgs and " ..." or "")
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            btn.Parent = scroll

            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                if cmd.requiresArgs then
                    filter.Text = cmd.name .. " "
                    filter:CaptureFocus()
                else
                    runCmd(cmd.name)
                    notify("Executed: " .. cmd.name)
                end
            end)

            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            end)
        end
    end

    populate("")

    filter:GetPropertyChangedSignal("Text"):Connect(function()
        populate(filter.Text)
    end)

    -- Command Bar (at bottom)
    local cmdBar = Instance.new("Frame")
    cmdBar.Name = "CmdBar"
    cmdBar.Size = UDim2.new(0, 400, 0, 40)
    cmdBar.Position = UDim2.new(0.5, -200, 1, -60)
    cmdBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    cmdBar.BorderSizePixel = 0
    cmdBar.Active = true
    cmdBar.Draggable = true
    cmdBar.Parent = gui

    local cmdBarCorner = Instance.new("UICorner")
    cmdBarCorner.CornerRadius = UDim.new(0, 8)
    cmdBarCorner.Parent = cmdBar

    local cmdBarStroke = Instance.new("UIStroke")
    cmdBarStroke.Color = Color3.fromRGB(100, 0, 255)
    cmdBarStroke.Thickness = 1.5
    cmdBarStroke.Parent = cmdBar

    local cmdInput = Instance.new("TextBox")
    cmdInput.Size = UDim2.new(1, -16, 1, -8)
    cmdInput.Position = UDim2.new(0, 8, 0, 4)
    cmdInput.BackgroundTransparency = 1
    cmdInput.PlaceholderText = "Type command here..."
    cmdInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    cmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    cmdInput.TextSize = 14
    cmdInput.Font = Enum.Font.Gotham
    cmdInput.ClearTextOnFocus = false
    cmdInput.Parent = cmdBar

    cmdInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local text = cmdInput.Text
            if text and text ~= "" then
                runCmd(text)
                cmdInput.Text = ""
            end
        end
    end)

    -- Toggle with RightControl
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            gui.Enabled = not gui.Enabled
        end
    end)

    notify("Commands Panel loaded! (" .. #CmdsList .. " commands) Press RightControl to toggle")
end

-- Initialize
createUI()
