local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

for _, v in pairs(PG:GetChildren()) do
    if v.Name == "NACmds" then v:Destroy() end
end
pcall(function() if game.CoreGui:FindFirstChild("NACmds") then game.CoreGui:FindFirstChild("NACmds"):Destroy() end end)

local ok, raw = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/commands.json", true) end)
if not ok or not raw then warn("HttpGet failed") return end

local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
if not ok2 or not data then warn("JSON failed") return end

local cmds = {}
if data.commands then
    for _, c in ipairs(data.commands) do
        if c.name and c.usage then
            table.insert(cmds, {name = c.name, usage = c.usage, args = c.args or "", desc = c.desc or "", patched = false})
        end
    end
end
if data.patched_commands then
    for _, c in ipairs(data.patched_commands) do
        if c.name and c.usage then
            table.insert(cmds, {name = c.name, usage = c.usage, args = c.args or "", desc = c.desc or "", patched = true})
        end
    end
end

print("Comandos: " .. #cmds)

local sg = Instance.new("ScreenGui")
sg.Name = "NACmds"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = game.CoreGui end)
if not sg.Parent then sg.Parent = PG end

local mf = Instance.new("Frame", sg)
mf.Name = "Commands"
mf.Size = UDim2.new(0, 380, 0, 440)
mf.Position = UDim2.new(0.5, -190, 0.5, -220)
mf.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
mf.BorderSizePixel = 0
mf.Active = true
mf.Draggable = true
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)
local mfStroke = Instance.new("UIStroke", mf)
mfStroke.Color = Color3.fromRGB(155, 100, 255)
mfStroke.Thickness = 1
mfStroke.Transparency = 0.4

local tb = Instance.new("Frame", mf)
tb.Size = UDim2.new(1, 0, 0, 40)
tb.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
tb.BorderSizePixel = 0

local accent = Instance.new("Frame", tb)
accent.Size = UDim2.new(0, 34, 0, 2)
accent.Position = UDim2.new(0.5, 0, 1, 0)
accent.AnchorPoint = Vector2.new(0.5, 1)
accent.BackgroundColor3 = Color3.fromRGB(155, 100, 255)
accent.BorderSizePixel = 0
Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 1)

local title = Instance.new("TextLabel", tb)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Commands (" .. #cmds .. ")"
title.TextColor3 = Color3.fromRGB(232, 234, 242)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local function mkBtn(txt, pos, bg, tc)
    local b = Instance.new("TextButton", tb)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = pos
    b.AnchorPoint = Vector2.new(0, 0.5)
    b.BackgroundColor3 = bg
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = tc or Color3.fromRGB(245, 246, 250)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(155, 100, 255)
    s.Transparency = 0.6
    return b
end

local exitBtn = mkBtn("X", UDim2.new(1, -10, 0.5, 0), Color3.fromRGB(60, 32, 39), Color3.fromRGB(255, 205, 212))
local minBtn = mkBtn("-", UDim2.new(1, -46, 0.5, 0), Color3.fromRGB(31, 32, 42))

local container = Instance.new("Frame", mf)
container.Name = "Container"
container.Size = UDim2.new(1, -16, 1, -52)
container.Position = UDim2.new(0, 8, 0, 46)
container.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
container.ClipsDescendants = true
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

local filterFrame = Instance.new("Frame", container)
filterFrame.Size = UDim2.new(1, 0, 0, 32)
filterFrame.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
filterFrame.BorderSizePixel = 0
Instance.new("UICorner", filterFrame).CornerRadius = UDim.new(0, 6)
local fs = Instance.new("UIStroke", filterFrame)
fs.Color = Color3.fromRGB(155, 100, 255)
fs.Transparency = 0.6

local searchIcon = Instance.new("TextLabel", filterFrame)
searchIcon.Size = UDim2.new(0, 24, 1, 0)
searchIcon.Position = UDim2.new(0, 8, 0, 0)
searchIcon.BackgroundTransparency = 1
searchIcon.Text = "🔍"
searchIcon.TextColor3 = Color3.fromRGB(150, 150, 170)
searchIcon.Font = Enum.Font.Gotham
searchIcon.TextSize = 14

local searchBox = Instance.new("TextBox", filterFrame)
searchBox.Size = UDim2.new(1, -40, 1, 0)
searchBox.Position = UDim2.new(0, 34, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Filter commands..."
searchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.ClearTextOnFocus = false
searchBox.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame", container)
scroll.Name = "List"
scroll.Size = UDim2.new(1, 0, 1, -38)
scroll.Position = UDim2.new(0, 0, 0, 38)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(155, 100, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 2)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local detailFrame = Instance.new("Frame", mf)
detailFrame.Name = "Detail"
detailFrame.Size = UDim2.new(1, -16, 1, -52)
detailFrame.Position = UDim2.new(0, 8, 0, 46)
detailFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
detailFrame.BorderSizePixel = 0
detailFrame.Visible = false
Instance.new("UICorner", detailFrame).CornerRadius = UDim.new(0, 6)

local detailTitle = Instance.new("TextLabel", detailFrame)
detailTitle.Size = UDim2.new(1, -16, 0, 30)
detailTitle.Position = UDim2.new(0, 8, 0, 8)
detailTitle.BackgroundTransparency = 1
detailTitle.TextColor3 = Color3.fromRGB(155, 100, 255)
detailTitle.Font = Enum.Font.GothamBold
detailTitle.TextSize = 14
detailTitle.TextXAlignment = Enum.TextXAlignment.Left
detailTitle.Text = ""

local detailDesc = Instance.new("TextLabel", detailFrame)
detailDesc.Size = UDim2.new(1, -16, 0, 20)
detailDesc.Position = UDim2.new(0, 8, 0, 38)
detailDesc.BackgroundTransparency = 1
detailDesc.TextColor3 = Color3.fromRGB(150, 155, 165)
detailDesc.Font = Enum.Font.Gotham
detailDesc.TextSize = 11
detailDesc.TextXAlignment = Enum.TextXAlignment.Left
detailDesc.TextWrapped = true
detailDesc.Text = ""

local detailUsage = Instance.new("TextLabel", detailFrame)
detailUsage.Size = UDim2.new(1, -16, 0, 20)
detailUsage.Position = UDim2.new(0, 8, 0, 60)
detailUsage.BackgroundTransparency = 1
detailUsage.TextColor3 = Color3.fromRGB(100, 200, 255)
detailUsage.Font = Enum.Font.Code
detailUsage.TextSize = 12
detailUsage.TextXAlignment = Enum.TextXAlignment.Left
detailUsage.Text = ""

local argLabel = Instance.new("TextLabel", detailFrame)
argLabel.Size = UDim2.new(1, -16, 0, 18)
argLabel.Position = UDim2.new(0, 8, 0, 90)
argLabel.BackgroundTransparency = 1
argLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
argLabel.Font = Enum.Font.Gotham
argLabel.TextSize = 12
argLabel.TextXAlignment = Enum.TextXAlignment.Left
argLabel.Text = "Argumentos:"

local argBox = Instance.new("TextBox", detailFrame)
argBox.Size = UDim2.new(1, -16, 0, 34)
argBox.Position = UDim2.new(0, 8, 0, 112)
argBox.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
argBox.BorderSizePixel = 0
argBox.PlaceholderText = "Escribe los argumentos aquí..."
argBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
argBox.Text = ""
argBox.TextColor3 = Color3.fromRGB(255, 255, 255)
argBox.Font = Enum.Font.Code
argBox.TextSize = 13
argBox.ClearTextOnFocus = false
argBox.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", argBox).CornerRadius = UDim.new(0, 6)
local argStroke = Instance.new("UIStroke", argBox)
argStroke.Color = Color3.fromRGB(155, 100, 255)
argStroke.Transparency = 0.5

local previewLabel = Instance.new("TextLabel", detailFrame)
previewLabel.Size = UDim2.new(1, -16, 0, 20)
previewLabel.Position = UDim2.new(0, 8, 0, 152)
previewLabel.BackgroundTransparency = 1
previewLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
previewLabel.Font = Enum.Font.Code
previewLabel.TextSize = 12
previewLabel.TextXAlignment = Enum.TextXAlignment.Left
previewLabel.Text = "Preview: "

local backBtn = Instance.new("TextButton", detailFrame)
backBtn.Size = UDim2.new(0, 80, 0, 32)
backBtn.Position = UDim2.new(0, 8, 1, -44)
backBtn.BackgroundColor3 = Color3.fromRGB(31, 32, 42)
backBtn.BorderSizePixel = 0
backBtn.Text = "< Back"
backBtn.TextColor3 = Color3.fromRGB(200, 205, 215)
backBtn.Font = Enum.Font.GothamBold
backBtn.TextSize = 13
backBtn.AutoButtonColor = false
Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 6)

local runBtn = Instance.new("TextButton", detailFrame)
runBtn.Size = UDim2.new(0, 100, 0, 32)
runBtn.Position = UDim2.new(1, -108, 1, -44)
runBtn.BackgroundColor3 = Color3.fromRGB(28, 100, 60)
runBtn.BorderSizePixel = 0
runBtn.Text = "▶ Run"
runBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
runBtn.Font = Enum.Font.GothamBold
runBtn.TextSize = 14
runBtn.AutoButtonColor = false
Instance.new("UICorner", runBtn).CornerRadius = UDim.new(0, 6)

local currentCmd = nil

local function showDetail(cmd)
    currentCmd = cmd
    detailTitle.Text = cmd.name
    detailDesc.Text = cmd.desc
    detailUsage.Text = cmd.usage

    if cmd.args ~= "" then
        argLabel.Visible = true
        argLabel.Text = "Argumentos: " .. cmd.args
        argBox.Visible = true
        argBox.Text = ""
        previewLabel.Visible = true
        previewLabel.Text = "Preview: " .. cmd.name .. " "
        runBtn.Position = UDim2.new(1, -108, 1, -44)
        backBtn.Position = UDim2.new(0, 8, 1, -44)
    else
        argLabel.Visible = false
        argBox.Visible = false
        previewLabel.Visible = false
        runBtn.Position = UDim2.new(1, -108, 1, -44)
        backBtn.Position = UDim2.new(0, 8, 1, -44)
    end

    detailFrame.Visible = true
    scroll.Visible = false
    filterFrame.Visible = false
end

local function showList()
    detailFrame.Visible = false
    scroll.Visible = true
    filterFrame.Visible = true
    currentCmd = nil
end

argBox:GetPropertyChangedSignal("Text"):Connect(function()
    if currentCmd then
        local args = argBox.Text
        if args ~= "" then
            previewLabel.Text = "Preview: " .. currentCmd.name .. " " .. args
        else
            previewLabel.Text = "Preview: " .. currentCmd.name
        end
    end
end)

local function executeCommand(cmdName, args)
    local fullCmd = cmdName
    if args and args ~= "" then
        fullCmd = cmdName .. " " .. args
    end

    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SendCoreMessage("TypeChatMessage", {Prefix = ":", Message = fullCmd})
    end)

    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local TextChatService = game:GetService("TextChatService")

        if TextChatService and TextChatService.TextChannels then
            local General = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
            if General then
                General:SendAsync(":" .. fullCmd)
            end
        end
    end)

    pcall(function()
        local chatBar = LP.PlayerGui:FindFirstChild("Chat")
        if chatBar then
            chatBar = chatBar:FindFirstChild("ChatBar")
            if chatBar then
                chatBar:CaptureFocus()
                chatBar.Text = ":" .. fullCmd
                task.wait(0.05)
                pcall(function()
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                end)
            end
        end
    end)
end

runBtn.MouseButton1Click:Connect(function()
    if currentCmd then
        local args = argBox.Text
        executeCommand(currentCmd.name, args)
        runBtn.Text = "✓ Sent!"
        runBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
        task.wait(0.8)
        runBtn.Text = "▶ Run"
        runBtn.BackgroundColor3 = Color3.fromRGB(28, 100, 60)
    end
end)

backBtn.MouseButton1Click:Connect(function() showList() end)

local btns = {}
for i, cmd in ipairs(cmds) do
    local isPatched = cmd.patched
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -4, 0, 30)
    b.BackgroundColor3 = isPatched and Color3.fromRGB(45, 28, 20) or Color3.fromRGB(22, 23, 30)
    b.BorderSizePixel = 0
    b.Text = "  " .. cmd.usage
    b.TextColor3 = isPatched and Color3.fromRGB(220, 140, 70) or Color3.fromRGB(200, 205, 215)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.LayoutOrder = i
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    local normalBg = b.BackgroundColor3
    local hoverBg = isPatched and Color3.fromRGB(65, 40, 28) or Color3.fromRGB(32, 33, 42)

    b.MouseEnter:Connect(function() b.BackgroundColor3 = hoverBg end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = normalBg end)

    b.MouseButton1Click:Connect(function()
        showDetail(cmd)
    end)

    table.insert(btns, {btn = b, cmd = cmd})
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local f = searchBox.Text:lower()
    for _, d in ipairs(btns) do
        local show = f == ""
            or d.cmd.name:lower():find(f, 1, true)
            or d.cmd.usage:lower():find(f, 1, true)
            or d.cmd.desc:lower():find(f, 1, true)
        d.btn.Visible = show
    end
end)

exitBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    container.Visible = not minimized
    detailFrame.Visible = false
    scroll.Visible = not minimized
    filterFrame.Visible = not minimized
    mf.Size = minimized and UDim2.new(0, 380, 0, 40) or UDim2.new(0, 380, 0, 440)
end)

print("✅ Panel listo: " .. #cmds .. " comandos")
