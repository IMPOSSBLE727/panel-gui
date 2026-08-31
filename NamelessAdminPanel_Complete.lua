-- Custom Commands Panel - Built from scratch
-- Toggle: RightControl

local success, err = pcall(function()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer

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

local Cmds = {}
local CmdsList = {}

local function addCmd(aliases, info, func, requiresArgs)
    local data = {func = func, info = info, requiresArgs = requiresArgs or false}
    for _, alias in ipairs(aliases) do
        Cmds[alias:lower()] = data
    end
    table.insert(CmdsList, {name = aliases[1], aliases = aliases, info = info, requiresArgs = requiresArgs or false})
end

local function runCmd(input)
    if not input or input == "" then return end
    local args = input:split(" ")
    local cmdName = table.remove(args, 1):lower()
    local cmd = Cmds[cmdName]
    if cmd then
        pcall(function() cmd.func(unpack(args)) end)
    end
end

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = "Cmds", Text = text, Duration = 3})
    end)
end

-- COMMANDS

addCmd({"fly"}, {"fly", "Enables flight"}, function(speed)
    local hum = getHum()
    local root = getRoot()
    if not hum or not root then return end
    speed = tonumber(speed) or 50
    local bp = Instance.new("BodyVelocity", root)
    bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bp.Velocity = Vector3.zero
    local bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9000
    bg.D = 500
    _G._flyBP = bp
    _G._flyBG = bg
    _G._flyConn = RunService.RenderStepped:Connect(function()
        if not bp.Parent then return end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        bp.Velocity = dir * speed
        bg.CFrame = workspace.CurrentCamera.CFrame
    end)
    notify("Fly ON (speed: " .. speed .. ")")
end)

addCmd({"unfly","nofly"}, {"unfly", "Disables flight"}, function()
    if _G._flyConn then _G._flyConn:Disconnect() end
    if _G._flyBP then _G._flyBP:Destroy() end
    if _G._flyBG then _G._flyBG:Destroy() end
    _G._flyConn = nil _G._flyBP = nil _G._flyBG = nil
    notify("Fly OFF")
end)

addCmd({"speed","ws"}, {"speed <num>", "Sets walkspeed"}, function(v)
    local h = getHum() if not h then return end
    h.WalkSpeed = tonumber(v) or 16
    notify("Speed: " .. h.WalkSpeed)
end)

addCmd({"jumppower","jp"}, {"jp <num>", "Sets jump power"}, function(v)
    local h = getHum() if not h then return end
    h.JumpPower = tonumber(v) or 50
    notify("JumpPower: " .. h.JumpPower)
end)

addCmd({"hipheight","hh"}, {"hh <num>", "Sets hip height"}, function(v)
    local h = getHum() if not h then return end
    h.HipHeight = tonumber(v) or 0
    notify("HipHeight: " .. h.HipHeight)
end)

addCmd({"noclip","nc"}, {"noclip", "Enables noclip"}, function()
    _G._noclip = true
    _G._noclipConn = RunService.Stepped:Connect(function()
        if not _G._noclip then return end
        local c = getChar()
        if c then
            for _, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
    notify("Noclip ON")
end)

addCmd({"clip"}, {"clip", "Disables noclip"}, function()
    _G._noclip = false
    if _G._noclipConn then _G._noclipConn:Disconnect() end
    notify("Noclip OFF")
end)

addCmd({"tp","teleport"}, {"tp <player>", "Teleport to player"}, function(target)
    if not target or target == "" then return end
    local root = getRoot() if not root then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #target) == target:lower() or p.DisplayName:lower():sub(1, #target) == target:lower() then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                root.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                notify("TP to " .. p.Name)
            end
            return
        end
    end
    notify("Player not found")
end)

addCmd({"goto"}, {"goto <player>", "Go to player"}, function(target)
    if not target or target == "" then return end
    local root = getRoot() if not root then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #target) == target:lower() or p.DisplayName:lower():sub(1, #target) == target:lower() then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                root.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                notify("Goto " .. p.Name)
            end
            return
        end
    end
    notify("Player not found")
end)

addCmd({"bring"}, {"bring <player>", "Bring player to you"}, function(target)
    if not target or target == "" then return end
    local root = getRoot() if not root then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #target) == target:lower() or p.DisplayName:lower():sub(1, #target) == target:lower() then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0,3,0)
                notify("Brought " .. p.Name)
            end
            return
        end
    end
    notify("Player not found")
end)

addCmd({"god","godmode"}, {"god", "God mode"}, function()
    local h = getHum() if not h then return end
    h.MaxHealth = 9e9
    h.Health = 9e9
    notify("God ON")
end)

addCmd({"heal"}, {"heal", "Full health"}, function()
    local h = getHum() if not h then return end
    h.Health = h.MaxHealth
    notify("Healed")
end)

addCmd({"kill"}, {"kill <player>", "Kill player"}, function(target)
    if not target or target == "" then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #target) == target:lower() or p.DisplayName:lower():sub(1, #target) == target:lower() then
            if p.Character then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if h then h.Health = 0 notify("Killed " .. p.Name) end
            end
            return
        end
    end
    notify("Player not found")
end)

addCmd({"invisible","invis"}, {"invisible", "Turn invisible"}, function()
    local c = getChar() if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") then v.Transparency = 1 end
        if v:IsA("Decal") then v.Transparency = 1 end
    end
    notify("Invisible")
end)

addCmd({"visible","vis"}, {"visible", "Turn visible"}, function()
    local c = getChar() if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
        if v:IsA("Decal") then v.Transparency = 0 end
    end
    notify("Visible")
end)

addCmd({"sit"}, {"sit", "Sit"}, function()
    local h = getHum() if h then h.Sit = true notify("Sitting") end
end)

addCmd({"unsit","stand"}, {"unsit", "Stand"}, function()
    local h = getHum() if h then h.Sit = false notify("Standing") end
end)

addCmd({"jump","j"}, {"jump", "Jump"}, function()
    local h = getHum() if h then h.Jump = true end
end)

addCmd({"respawn","re"}, {"respawn", "Respawn"}, function()
    LP:LoadCharacter()
    notify("Respawning...")
end)

addCmd({"light","bright"}, {"light", "Bright mode"}, function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(178,178,178)
    notify("Bright ON")
end)

addCmd({"dark"}, {"dark", "Dark mode"}, function()
    Lighting.Brightness = 0
    Lighting.ClockTime = 0
    Lighting.GlobalShadows = true
    Lighting.Ambient = Color3.fromRGB(0,0,0)
    notify("Dark ON")
end)

addCmd({"esp"}, {"esp", "Box ESP on all players"}, function()
    _G._espEnabled = true
    _G._espConns = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and not hrp:FindFirstChild("_ESP") then
                local bb = Instance.new("BillboardGui", hrp)
                bb.Name = "_ESP"
                bb.Size = UDim2.new(0,100,0,50)
                bb.AlwaysOnTop = true
                bb.StudsOffset = Vector3.new(0,3,0)
                local f = Instance.new("Frame", bb)
                f.Size = UDim2.new(1,0,1,0)
                f.BackgroundColor3 = Color3.fromRGB(255,0,0)
                f.BackgroundTransparency = 0.5
                f.BorderSizePixel = 0
                Instance.new("UICorner", f).CornerRadius = UDim.new(0,4)
                local t = Instance.new("TextLabel", bb)
                t.Size = UDim2.new(1,0,1,0)
                t.BackgroundTransparency = 1
                t.Text = p.Name
                t.TextColor3 = Color3.new(1,1,1)
                t.TextScaled = true
            end
        end
    end
    _G._espPlayerAdded = Players.PlayerAdded:Connect(function(p)
        if not _G._espEnabled then return end
        p.CharacterAdded:Connect(function(c)
            task.wait(1)
            if not _G._espEnabled then return end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp and not hrp:FindFirstChild("_ESP") then
                local bb = Instance.new("BillboardGui", hrp)
                bb.Name = "_ESP"
                bb.Size = UDim2.new(0,100,0,50)
                bb.AlwaysOnTop = true
                bb.StudsOffset = Vector3.new(0,3,0)
                local f = Instance.new("Frame", bb)
                f.Size = UDim2.new(1,0,1,0)
                f.BackgroundColor3 = Color3.fromRGB(255,0,0)
                f.BackgroundTransparency = 0.5
                f.BorderSizePixel = 0
                Instance.new("UICorner", f).CornerRadius = UDim.new(0,4)
                local t = Instance.new("TextLabel", bb)
                t.Size = UDim2.new(1,0,1,0)
                t.BackgroundTransparency = 1
                t.Text = p.Name
                t.TextColor3 = Color3.new(1,1,1)
                t.TextScaled = true
            end
        end)
    end)
    notify("ESP ON")
end)

addCmd({"unesp","noesp"}, {"unesp", "Disable ESP"}, function()
    _G._espEnabled = false
    if _G._espPlayerAdded then _G._espPlayerAdded:Disconnect() end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local e = hrp:FindFirstChild("_ESP")
                if e then e:Destroy() end
            end
        end
    end
    notify("ESP OFF")
end)

addCmd({"ff","forcefield"}, {"ff", "Add forcefield"}, function()
    local c = getChar() if not c then return end
    Instance.new("ForceField", c)
    notify("ForceField ON")
end)

addCmd({"noff","noforcefield"}, {"noff", "Remove forcefield"}, function()
    local c = getChar() if not c then return end
    for _, v in pairs(c:GetChildren()) do
        if v:IsA("ForceField") then v:Destroy() end
    end
    notify("ForceField OFF")
end)

addCmd({"speedfeet"}, {"speedfeet", "Particle trails on feet"}, function()
    local c = getChar() if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("foot") or v.Name:lower():find("leg")) then
            local att = Instance.new("Attachment", v)
            local pe = Instance.new("ParticleEmitter", att)
            pe.Color = ColorSequence.new(Color3.fromRGB(100, 0, 255))
            pe.Size = NumberSequence.new(0.5)
            pe.Lifetime = NumberRange.new(0.2, 0.5)
            pe.Rate = 50
            pe.Speed = NumberRange.new(0, 2)
        end
    end
    notify("Speed feet ON")
end)

addCmd({"char","character"}, {"char <meshid>", "Change character mesh"}, function(id)
    if not id or id == "" then return end
    notify("Mesh ID: " .. id .. " (limited support)")
end)

addCmd({"btools"}, {"btools", "Building tools"}, function()
    local c = getChar() if not c then return end
    local backpack = LP:FindFirstChildOfClass("Backpack")
    if backpack then
        local tool = Instance.new("Tool", backpack)
        tool.Name = "BTool"
        tool.CanBeDropped = false
        local handle = Instance.new("Part", tool)
        handle.Name = "Handle"
        handle.Size = Vector3.new(1,1,1)
        handle.Transparency = 1
    end
    notify("BTools given")
end)

addCmd({"notepad"}, {"notepad <text>", "Show text on screen"}, function(text)
    if not text or text == "" then return end
    local gui = Instance.new("ScreenGui", CoreGui)
    gui.Name = "NotepadCmd"
    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0, 400, 0, 200)
    f.Position = UDim2.new(0.5, -200, 0.3, 0)
    f.BackgroundColor3 = Color3.fromRGB(25,25,35)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(100,0,255)
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1,-20,1,-20)
    t.Position = UDim2.new(0,10,0,10)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = Color3.new(1,1,1)
    t.TextSize = 18
    t.TextWrapped = true
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Top
    t.Font = Enum.Font.Gotham
    task.delay(5, function() gui:Destroy() end)
end)

addCmd({"clear"}, {"clear", "Clear notepad/notifications"}, function()
    local gui = CoreGui:FindFirstChild("NotepadCmd")
    if gui then gui:Destroy() end
    notify("Cleared")
end)

addCmd({"players","plrs"}, {"players", "List all players"}, function()
    local list = {}
    for _, p in pairs(Players:GetPlayers()) do
        table.insert(list, p.Name)
    end
    notify(table.concat(list, ", "))
end)

addCmd({"fps"}, {"fps", "Show FPS"}, function()
    local t = tick()
    RunService.RenderStepped:Wait()
    local fps = math.floor(1 / (tick() - t))
    notify("FPS: " .. fps)
end)

addCmd({"ping"}, {"ping", "Show ping"}, function()
    notify("Ping: " .. math.floor(LP:GetNetworkPing() * 1000) .. "ms")
end)

addCmd({"pos","position"}, {"pos", "Show position"}, function()
    local r = getRoot() if not r then return end
    local p = r.Position
    notify(math.floor(p.X) .. ", " .. math.floor(p.Y) .. ", " .. math.floor(p.Z))
end)

addCmd({"気軽","gravity"}, {"gravity <num>", "Set gravity"}, function(v)
    workspace.Gravity = tonumber(v) or 196.2
    notify("Gravity: " .. workspace.Gravity)
end)

addCmd({"tpworkspace","tpws"}, {"tpws <x,y,z>", "Teleport to coordinates"}, function(x,y,z)
    local root = getRoot() if not root then return end
    x = tonumber(x) or 0
    y = tonumber(y) or 50
    z = tonumber(z) or 0
    root.CFrame = CFrame.new(x, y, z)
    notify("Teleported to " .. x .. "," .. y .. "," .. z)
end)

addCmd({"removegui","nogui"}, {"removegui", "Remove this panel"}, function()
    local gui = CoreGui:FindFirstChild("CustomCmds")
    if gui then gui:Destroy() notify("Panel removed") end
end)

-- ============================================
-- UI
-- ============================================

local gui = Instance.new("ScreenGui")
gui.Name = "CustomCmds"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame", gui)
mainFrame.Name = "Cmds"
mainFrame.Size = UDim2.new(0, 280, 0, 380)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local mfCorner = Instance.new("UICorner", mainFrame)
mfCorner.CornerRadius = UDim.new(0, 10)
local mfStroke = Instance.new("UIStroke", mainFrame)
mfStroke.Color = Color3.fromRGB(100, 0, 255)
mfStroke.Thickness = 1.5

-- Title bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BorderSizePixel = 0
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleText = Instance.new("TextLabel", titleBar)
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Commands (" .. #CmdsList .. ")"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -32, 0, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- Search box
local search = Instance.new("TextBox", mainFrame)
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
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 6)

-- Commands list
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -16, 1, -74)
scroll.Position = UDim2.new(0, 8, 0, 72)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 0, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 2)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function populate(filterText)
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local list = CmdsList
    if filterText and filterText ~= "" then
        list = {}
        for _, cmd in pairs(CmdsList) do
            local match = false
            if cmd.name:lower():find(filterText:lower(), 1, true) then match = true end
            for _, a in ipairs(cmd.aliases) do
                if a:lower():find(filterText:lower(), 1, true) then match = true break end
            end
            if match then table.insert(list, cmd) end
        end
    end
    for i, cmd in ipairs(list) do
        local btn = Instance.new("TextButton", scroll)
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        btn.Text = "  " .. cmd.name .. (cmd.requiresArgs and " ..." or "")
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 11
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.LayoutOrder = i
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            if cmd.requiresArgs then
                search.Text = cmd.name .. " "
                search:CaptureFocus()
            else
                runCmd(cmd.name)
            end
        end)
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(80, 0, 200) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45) end)
    end
end

populate("")
search:GetPropertyChangedSignal("Text"):Connect(function() populate(search.Text) end)

-- Command bar at bottom
local cmdBar = Instance.new("Frame", gui)
cmdBar.Name = "CmdBar"
cmdBar.Size = UDim2.new(0, 380, 0, 36)
cmdBar.Position = UDim2.new(0.5, -190, 1, -50)
cmdBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
cmdBar.BorderSizePixel = 0
cmdBar.Active = true
cmdBar.Draggable = true
Instance.new("UICorner", cmdBar).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", cmdBar).Color = Color3.fromRGB(100, 0, 255)

local cmdInput = Instance.new("TextBox", cmdBar)
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
            runCmd(text)
            cmdInput.Text = ""
        end
    end
end)

-- Toggle with RightControl
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        mainFrame.Visible = not mainFrame.Visible
        cmdBar.Visible = mainFrame.Visible
    end
end)

-- Auto open
mainFrame.Visible = true
cmdBar.Visible = true

task.delay(1, function()
    notify("Custom Commands loaded! (" .. #CmdsList .. " cmds) RCtrl to toggle")
end)

end)

if not success then
    warn("[CustomCmds] Error: " .. tostring(err))
end
