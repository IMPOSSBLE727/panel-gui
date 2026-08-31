local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

for _, v in pairs(PG:GetChildren()) do
    if v.Name == "NACmds" then v:Destroy() end
end

local ok, raw = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/commands.json", true)
end)

local cmds = {}
if ok and raw then
    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if ok2 and data and data.commands then
        for _, c in ipairs(data.commands) do
            if c.name and c.usage then
                table.insert(cmds, {
                    name = c.name,
                    usage = c.usage,
                    desc = c.desc or "",
                    aliases = c.aliases or {},
                    patched = false
                })
            end
        end
    end
    if ok2 and data and data.patched_commands then
        for _, c in ipairs(data.patched_commands) do
            if c.name and c.usage then
                table.insert(cmds, {
                    name = c.name,
                    usage = "[PATCHED] " .. c.usage,
                    desc = c.desc or "",
                    aliases = c.aliases or {},
                    patched = true
                })
            end
        end
    end
end

table.sort(cmds, function(a, b)
    if a.patched ~= b.patched then return not a.patched end
    return a.name:lower() < b.name:lower()
end)

if #cmds == 0 then
    warn("No se pudo descargar commands.json")
    return
end

print("Cargados " .. #cmds .. " comandos")

local sg = Instance.new("ScreenGui")
sg.Name = "NACmds"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local okGui = pcall(function() sg.Parent = game.CoreGui end)
if not okGui then sg.Parent = PG end

local mf = Instance.new("Frame", sg)
mf.Name = "Commands"
mf.Size = UDim2.new(0, 380, 0, 440)
mf.Position = UDim2.new(0.5, -190, 0.5, -220)
mf.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
mf.BorderSizePixel = 0
mf.Active = true
mf.Draggable = true
mf.ClipsDescendants = true
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)
local mfStroke = Instance.new("UIStroke", mf)
mfStroke.Color = Color3.fromRGB(155, 100, 255)
mfStroke.Thickness = 1
mfStroke.Transparency = 0.4

local tb = Instance.new("Frame", mf)
tb.Name = "Topbar"
tb.Size = UDim2.new(1, 0, 0, 44)
tb.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)

local accent = Instance.new("Frame", tb)
accent.Size = UDim2.new(0, 34, 0, 2)
accent.Position = UDim2.new(0.5, 0, 1, -2)
accent.AnchorPoint = Vector2.new(0.5, 1)
accent.BackgroundColor3 = Color3.fromRGB(155, 100, 255)
accent.BorderSizePixel = 0
Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 1)

local divider = Instance.new("Frame", tb)
divider.Size = UDim2.new(1, -28, 0, 1)
divider.Position = UDim2.new(0, 14, 1, -1)
divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
divider.BackgroundTransparency = 0.9
divider.BorderSizePixel = 0

local title = Instance.new("TextLabel", tb)
title.Size = UDim2.new(1, -120, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Commands"
title.TextColor3 = Color3.fromRGB(232, 234, 242)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Center

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
container.Size = UDim2.new(1, -16, 1, -56)
container.Position = UDim2.new(0, 8, 0, 50)
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

local allBtns = {}

for i, cmd in ipairs(cmds) do
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -4, 0, 34)
    b.BackgroundColor3 = cmd.patched and Color3.fromRGB(45, 28, 20) or Color3.fromRGB(22, 23, 30)
    b.BorderSizePixel = 0
    b.Text = "  " .. cmd.usage
    b.TextColor3 = cmd.patched and Color3.fromRGB(220, 140, 70) or Color3.fromRGB(200, 205, 215)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.LayoutOrder = i
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    local normalBg = b.BackgroundColor3
    local hoverBg = cmd.patched and Color3.fromRGB(65, 40, 28) or Color3.fromRGB(32, 33, 42)

    b.MouseEnter:Connect(function() b.BackgroundColor3 = hoverBg end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = normalBg end)

    b.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then setclipboard(cmd.usage)
            elseif syn and syn.write_clipboard then syn.write_clipboard(cmd.usage)
            elseif clipboards then clipboards.set(cmd.usage) end
        end)
        local orig = b.Text
        b.Text = "  Copied!"
        b.TextColor3 = Color3.fromRGB(100, 255, 150)
        task.wait(0.6)
        b.Text = orig
        b.TextColor3 = cmd.patched and Color3.fromRGB(220, 140, 70) or Color3.fromRGB(200, 205, 215)
    end)

    allBtns[i] = {btn = b, cmd = cmd}
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local filter = searchBox.Text:lower()
    for _, d in ipairs(allBtns) do
        local show = filter == ""
            or d.cmd.name:lower():find(filter, 1, true)
            or d.cmd.usage:lower():find(filter, 1, true)
            or d.cmd.desc:lower():find(filter, 1, true)
        for _, a in ipairs(d.cmd.aliases) do
            if show then break end
            if a:lower():find(filter, 1, true) then show = true end
        end
        d.btn.Visible = show
    end
end)

exitBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    container.Visible = not minimized
    mf.Size = minimized and UDim2.new(0, 380, 0, 44) or UDim2.new(0, 380, 0, 440)
end)

print("✅ Panel de comandos cargado: " .. #cmds .. " comandos")
