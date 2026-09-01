pcall(function()
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer
    local StarterGui = game:GetService("StarterGui")
    local g = Instance.new("ScreenGui", game:GetService("CoreGui"))
    g.Name = "Test"
    local f = Instance.new("Frame", g)
    f.Size = UDim2.new(0,200,0,100)
    f.Position = UDim2.new(0.5,-100,0.5,-50)
    f.BackgroundColor3 = Color3.fromRGB(0,255,0)
    f.BorderSizePixel = 0
    f.Active = true
    f.Draggable = true
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1,0,1,0)
    t.BackgroundTransparency = 1
    t.Text = "IT WORKS"
    t.TextColor3 = Color3.new(1,1,1)
    t.TextSize = 24
    t.Font = Enum.Font.GothamBold
    pcall(function() StarterGui:SetCore("SendNotification",{Title="OK",Text="Panel loaded!"}) end)
end)
