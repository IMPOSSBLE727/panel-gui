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
            table.insert(cmds, c.usage)
        end
    end
end
if data.patched_commands then
    for _, c in ipairs(data.patched_commands) do
        if c.name and c.usage then
            table.insert(cmds, "[PATCHED] " .. c.usage)
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
mf.Size = UDim2.new(0, 380, 0, 440)
mf.Position = UDim2.new(0.5, -190, 0.5, -220)
mf.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
mf.BorderSizePixel = 0
mf.Active = true
mf.Draggable = true
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)

local tb = Instance.new("Frame", mf)
tb.Size = UDim2.new(1, 0, 0, 40)
tb.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
tb.BorderSizePixel = 0

local title = Instance.new("TextLabel", tb)
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Commands (" .. #cmds .. ")"
title.TextColor3 = Color3.fromRGB(155, 100, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local cb = Instance.new("TextButton", tb)
cb.Size = UDim2.new(0, 30, 0, 30)
cb.Position = UDim2.new(1, -35, 0.5, 0)
cb.AnchorPoint = Vector2.new(0, 0.5)
cb.BackgroundColor3 = Color3.fromRGB(60, 32, 39)
cb.BorderSizePixel = 0
cb.Text = "X"
cb.TextColor3 = Color3.fromRGB(255, 205, 212)
cb.Font = Enum.Font.GothamBold
cb.TextSize = 14
Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 5)
cb.MouseButton1Click:Connect(function() sg:Destroy() end)

local sb = Instance.new("TextBox", mf)
sb.Size = UDim2.new(1, -16, 0, 30)
sb.Position = UDim2.new(0, 8, 0, 46)
sb.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
sb.BorderSizePixel = 0
sb.PlaceholderText = "Filter commands..."
sb.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
sb.Text = ""
sb.TextColor3 = Color3.fromRGB(255, 255, 255)
sb.Font = Enum.Font.Gotham
sb.TextSize = 13
sb.ClearTextOnFocus = false
sb.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 6)

local scroll = Instance.new("ScrollingFrame", mf)
scroll.Size = UDim2.new(1, -16, 1, -86)
scroll.Position = UDim2.new(0, 8, 0, 82)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(155, 100, 255)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 2)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local btns = {}
for i, usage in ipairs(cmds) do
    local isPatched = string.sub(usage, 1, 9) == "[PATCHED]"
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -4, 0, 30)
    b.BackgroundColor3 = isPatched and Color3.fromRGB(45, 28, 20) or Color3.fromRGB(22, 23, 30)
    b.BorderSizePixel = 0
    b.Text = "  " .. usage
    b.TextColor3 = isPatched and Color3.fromRGB(220, 140, 70) or Color3.fromRGB(200, 205, 215)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.LayoutOrder = i
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    table.insert(btns, {btn = b, usage = usage, patched = isPatched})
end

sb:GetPropertyChangedSignal("Text"):Connect(function()
    local f = sb.Text:lower()
    for _, d in ipairs(btns) do
        d.btn.Visible = f == "" or d.usage:lower():find(f, 1, true)
    end
end)

print("Panel listo: " .. #cmds .. " comandos")
