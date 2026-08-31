local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

for _, v in pairs(PG:GetChildren()) do
    if v.Name == "NAPanel" then v:Destroy() end
end

local sg = Instance.new("ScreenGui")
sg.Name = "NAPanel"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = PG

local mf = Instance.new("Frame")
mf.Name = "Main"
mf.Size = UDim2.new(0, 420, 0, 520)
mf.Position = UDim2.new(0.5, -210, 0.5, -260)
mf.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mf.BorderSizePixel = 0
mf.Active = true
mf.Draggable = true
mf.Parent = sg

Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 8)
local s = Instance.new("UIStroke", mf)
s.Color = Color3.fromRGB(138, 43, 226)
s.Thickness = 2

local tb = Instance.new("Frame", mf)
tb.Size = UDim2.new(1, 0, 0, 36)
tb.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)

local tl = Instance.new("TextLabel", tb)
tl.Size = UDim2.new(1, -120, 1, 0)
tl.Position = UDim2.new(0, 10, 0, 0)
tl.BackgroundTransparency = 1
tl.Text = "Commands"
tl.TextColor3 = Color3.fromRGB(138, 43, 226)
tl.Font = Enum.Font.GothamBold
tl.TextSize = 16
tl.TextXAlignment = Enum.TextXAlignment.Left

local function mkbtn(n, txt, pos, hc)
    local b = Instance.new("TextButton", tb)
    b.Name = n
    b.Size = UDim2.new(0, 30, 0, 26)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = hc end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end)
    return b
end

local cb = mkbtn("Close", "X", UDim2.new(1, -34, 0, 5), Color3.fromRGB(200, 40, 40))
local mb = mkbtn("Max", "□", UDim2.new(1, -68, 0, 5), Color3.fromRGB(60, 60, 80))
local mnb = mkbtn("Min", "—", UDim2.new(1, -102, 0, 5), Color3.fromRGB(60, 60, 80))

local cf = Instance.new("Frame", mf)
cf.Size = UDim2.new(1, -16, 1, -46)
cf.Position = UDim2.new(0, 8, 0, 42)
cf.BackgroundTransparency = 1

local sf = Instance.new("Frame", cf)
sf.Size = UDim2.new(1, 0, 0, 32)
sf.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
sf.BorderSizePixel = 0
Instance.new("UICorner", sf).CornerRadius = UDim.new(0, 6)
local ss = Instance.new("UIStroke", sf)
ss.Color = Color3.fromRGB(138, 43, 226)
ss.Thickness = 1
ss.Transparency = 0.5

local si = Instance.new("TextLabel", sf)
si.Size = UDim2.new(0, 24, 1, 0)
si.Position = UDim2.new(0, 8, 0, 0)
si.BackgroundTransparency = 1
si.Text = "🔍"
si.TextColor3 = Color3.fromRGB(150, 150, 170)
si.Font = Enum.Font.Gotham
si.TextSize = 14

local sb = Instance.new("TextBox", sf)
sb.Name = "Search"
sb.Size = UDim2.new(1, -40, 1, 0)
sb.Position = UDim2.new(0, 34, 0, 0)
sb.BackgroundTransparency = 1
sb.PlaceholderText = "Filter commands..."
sb.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
sb.Text = ""
sb.TextColor3 = Color3.fromRGB(255, 255, 255)
sb.Font = Enum.Font.Gotham
sb.TextSize = 13
sb.ClearTextOnFocus = false
sb.TextXAlignment = Enum.TextXAlignment.Left

local scroll = Instance.new("ScrollingFrame", cf)
scroll.Name = "List"
scroll.Size = UDim2.new(1, 0, 1, -40)
scroll.Position = UDim2.new(0, 0, 0, 40)
scroll.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.ScrollBarImageColor3 = Color3.fromRGB(138, 43, 226)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 3)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local allCmds = {}
local btns = {}

local function mkcmd(usage, patched)
    table.insert(allCmds, {usage = usage, patched = patched})
end

local function refresh(filter)
    filter = filter or ""
    filter = string.lower(filter)
    for _, d in ipairs(allCmds) do
        local show = filter == "" or string.find(string.lower(d.usage), filter, 1, true)
        if btns[d.usage] then
            btns[d.usage].Visible = show
        end
    end
end

local function buildBtns()
    for i, d in ipairs(allCmds) do
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(1, 0, 0, 36)
        b.BackgroundColor3 = d.patched and Color3.fromRGB(60, 35, 25) or Color3.fromRGB(35, 35, 45)
        b.BorderSizePixel = 0
        b.Text = d.usage
        b.TextColor3 = d.patched and Color3.fromRGB(220, 140, 70) or Color3.fromRGB(255, 255, 255)
        b.Font = d.patched and Enum.Font.GothamBold or Enum.Font.Gotham
        b.TextSize = 13
        b.LayoutOrder = i
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

        b.MouseEnter:Connect(function()
            if not d.patched then b.BackgroundColor3 = Color3.fromRGB(50, 50, 65) end
        end)
        b.MouseLeave:Connect(function()
            if not d.patched then b.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end
        end)
        b.MouseButton1Click:Connect(function()
            pcall(function()
                if setclipboard then
                    setclipboard(d.usage)
                elseif syn and syn.write_clipboard then
                    syn.write_clipboard(d.usage)
                end
            end)
            local orig = b.Text
            b.Text = "Copied!"
            task.wait(0.5)
            b.Text = orig
        end)
        btns[d.usage] = b
    end
end

sb:GetPropertyChangedSignal("Text"):Connect(function() refresh(sb.Text) end)

cb.MouseButton1Click:Connect(function() sg:Destroy() end)
local minimized = false
mnb.MouseButton1Click:Connect(function()
    minimized = not minimized
    cf.Visible = not minimized
    mf.Size = minimized and UDim2.new(0, 420, 0, 36) or UDim2.new(0, 420, 0, 520)
end)
local maximized = false
mb.MouseButton1Click:Connect(function()
    maximized = not maximized
    if maximized then
        mf.Size = UDim2.new(0, 600, 0, 700)
        mf.Position = UDim2.new(0.5, -300, 0.5, -350)
    else
        mf.Size = UDim2.new(0, 420, 0, 520)
        mf.Position = UDim2.new(0.5, -210, 0.5, -260)
    end
end)

-- Fetch from GitHub
task.spawn(function()
    local ok, res = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/commands.json", true)
    end)
    if ok and res then
        local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
        if ok2 and data then
            if data.commands then
                for _, c in ipairs(data.commands) do
                    if c.usage and c.usage ~= "" then mkcmd(c.usage, false) end
                end
            end
            if data.patched_commands then
                for _, c in ipairs(data.patched_commands) do
                    if c.usage and c.usage ~= "" then mkcmd("[PATCHED] " .. c.usage, true) end
                end
            end
        end
    end
    if #allCmds == 0 then
        warn("No se pudo descargar, usando respaldo")
        mkcmd("unload", false)
        mkcmd("loadstring <code> (ls)", false)
        mkcmd("fly", false)
        mkcmd("noclip (nc)", false)
        mkcmd("ws <number> (speed)", false)
        mkcmd("jp <number> (jumppower)", false)
        mkcmd("goto <player> (tp)", false)
        mkcmd("invisible (invis)", false)
        mkcmd("godmode (god)", false)
        mkcmd("esp", false)
        mkcmd("commands (cmds)", false)
        mkcmd("[PATCHED] breaklayeredclothing (blc)", true)
    end
    buildBtns()
    refresh()
end)
