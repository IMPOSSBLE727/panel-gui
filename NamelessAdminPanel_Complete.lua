--[[
	Standalone Commands Panel - Extracted from Nameless Admin (NAUI.lua + Source.lua)
	Fetches commands.json from GitHub, builds the commands panel UI, and provides filtering.
	Run this in a Roblox exploit executor.
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 1: Fetch commands.json from GitHub
-- ═══════════════════════════════════════════════════════════════════════════════

local COMMANDS_URL = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/commands.json"

local function fetchCommands()
	local ok, raw = pcall(game.HttpGet, game, COMMANDS_URL)
	if not ok or type(raw) ~= "string" or raw == "" then
		warn("[CommandsPanel] Failed to fetch commands.json:", tostring(raw))
		return {}
	end
	local okDecode, data = pcall(HttpService.JSONDecode, HttpService, raw)
	if not okDecode or type(data) ~= "table" or type(data.commands) ~= "table" then
		warn("[CommandsPanel] Failed to parse commands.json")
		return {}
	end
	return data.commands
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 2: Build command entries from JSON data
-- ═══════════════════════════════════════════════════════════════════════════════

local function buildEntries(commands)
	local entries = {}
	for _, cmd in ipairs(commands) do
		if type(cmd) == "table" and type(cmd.name) == "string" then
			local name = cmd.name
			local aliases = cmd.aliases or {}
			local usage = cmd.usage or name
			local desc = cmd.desc or ""
			local args = cmd.args or ""

			-- Build searchable string: name + aliases + desc
			local aliasStr = ""
			for _, a in ipairs(aliases) do
				if type(a) == "string" and a:lower() ~= name:lower() then
					aliasStr = aliasStr .. " " .. a:lower()
				end
			end
			local searchable = name:lower() .. aliasStr .. " " .. desc:lower()

			-- Format display text with aliases like NA does: "name (alias1, alias2)"
			local displayAliases = {}
			for _, a in ipairs(aliases) do
				if type(a) == "string" and a:lower() ~= name:lower() then
					table.insert(displayAliases, a)
				end
			end
			local displayText = name
			if #displayAliases > 0 then
				displayText = name .. " (" .. table.concat(displayAliases, ", ") .. ")"
			end

			entries[#entries + 1] = {
				name = name,
				display = displayText,
				usage = usage,
				args = args,
				desc = desc,
				searchable = searchable,
				sortKey = name:lower(),
			}
		end
	end

	-- Sort alphabetically by display text
	table.sort(entries, function(a, b)
		return a.sortKey < b.sortKey
	end)

	return entries
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 3: Create the Commands Panel UI (from NAUI.lua)
-- ═══════════════════════════════════════════════════════════════════════════════

local function newCorner(parent, radius)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, radius or 4)
	return c
end

local function newStroke(parent, color, transparency)
	local s = Instance.new("UIStroke", parent)
	s.Thickness = 1
	s.Color = color or Color3.fromRGB(155, 100, 255)
	s.Transparency = transparency or 0.38
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return s
end

local function newGradient(parent, colors, rotation)
	local g = Instance.new("UIGradient", parent)
	g.Rotation = rotation or 90
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors[1]),
		ColorSequenceKeypoint.new(1, colors[2]),
	})
	return g
end

local robotoRegular = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local robotoMedium = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local robotoBold = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local iconFont = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local function buildCommandsPanel()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CommandsPanelUI"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false

	-- Main Commands Frame (G2L["1f"])
	local commandsFrame = Instance.new("Frame", screenGui)
	commandsFrame.Name = "Commands"
	commandsFrame.BorderSizePixel = 0
	commandsFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
	commandsFrame.Size = UDim2.new(0, 380, 0, 440)
	commandsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	commandsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	commandsFrame.Visible = true
	commandsFrame.BackgroundTransparency = 0.1
	commandsFrame.ClipsDescendants = true
	newCorner(commandsFrame, 10)
	newGradient(commandsFrame, {Color3.fromRGB(18, 19, 25), Color3.fromRGB(14, 15, 20)})
	newStroke(commandsFrame)

	-- Topbar (G2L["2a"])
	local topbar = Instance.new("Frame", commandsFrame)
	topbar.Name = "Topbar"
	topbar.BorderSizePixel = 0
	topbar.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
	topbar.Size = UDim2.new(1, 0, 0, 44)
	topbar.BackgroundTransparency = 0.12
	newCorner(topbar, 10)
	newGradient(topbar, {Color3.fromRGB(27, 28, 36), Color3.fromRGB(18, 19, 25)})
	newStroke(topbar)

	-- Header Accent
	local accent = Instance.new("Frame", topbar)
	accent.Name = "HeaderAccent"
	accent.BorderSizePixel = 0
	accent.BackgroundColor3 = Color3.fromRGB(155, 100, 255)
	accent.AnchorPoint = Vector2.new(0.5, 1)
	accent.Size = UDim2.new(0, 34, 0, 2)
	accent.Position = UDim2.new(0.5, 0, 1, -2)
	newCorner(accent, 1)

	-- Header Divider
	local divider = Instance.new("Frame", topbar)
	divider.Name = "HeaderDivider"
	divider.BorderSizePixel = 0
	divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider.BackgroundTransparency = 0.9
	divider.Position = UDim2.new(0, 14, 1, -1)
	divider.Size = UDim2.new(1, -28, 0, 1)

	-- Title
	local title = Instance.new("TextLabel", topbar)
	title.BorderSizePixel = 0
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.FontFace = robotoMedium
	title.TextColor3 = Color3.fromRGB(232, 234, 242)
	title.BackgroundTransparency = 1
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Size = UDim2.new(0, 150, 1, 0)
	title.Text = "Commands"
	title.Name = "Title"
	title.Position = UDim2.new(0.5, 0, 0.5, 0)

	-- Exit Button
	local exitBtn = Instance.new("TextButton", topbar)
	exitBtn.BorderSizePixel = 0
	exitBtn.TextSize = 16
	exitBtn.TextColor3 = Color3.fromRGB(255, 205, 212)
	exitBtn.BackgroundColor3 = Color3.fromRGB(60, 32, 39)
	exitBtn.FontFace = iconFont
	exitBtn.AnchorPoint = Vector2.new(1, 0.5)
	exitBtn.BackgroundTransparency = 0.08
	exitBtn.Size = UDim2.new(0, 28, 0, 28)
	exitBtn.Text = "x"
	exitBtn.Name = "Exit"
	exitBtn.Position = UDim2.new(1, -10, 0.5, 0)
	exitBtn.AutoButtonColor = false
	newCorner(exitBtn, 5)
	newStroke(exitBtn)

	-- Minimize Button
	local minimizeBtn = Instance.new("TextButton", topbar)
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.TextSize = 16
	minimizeBtn.TextColor3 = Color3.fromRGB(245, 246, 250)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(31, 32, 42)
	minimizeBtn.FontFace = iconFont
	minimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
	minimizeBtn.BackgroundTransparency = 0.18
	minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
	minimizeBtn.Text = "minus"
	minimizeBtn.Name = "Minimize"
	minimizeBtn.Position = UDim2.new(1, -78, 0.5, 0)
	minimizeBtn.AutoButtonColor = false
	newCorner(minimizeBtn, 5)
	newStroke(minimizeBtn)

	-- Maximize Button
	local maximizeBtn = Instance.new("TextButton", topbar)
	maximizeBtn.BorderSizePixel = 0
	maximizeBtn.TextSize = 16
	maximizeBtn.TextColor3 = Color3.fromRGB(245, 246, 250)
	maximizeBtn.BackgroundColor3 = Color3.fromRGB(31, 32, 42)
	maximizeBtn.FontFace = iconFont
	maximizeBtn.AnchorPoint = Vector2.new(1, 0.5)
	maximizeBtn.BackgroundTransparency = 0.18
	maximizeBtn.Size = UDim2.new(0, 28, 0, 28)
	maximizeBtn.Text = "square-corner-line"
	maximizeBtn.Name = "Maximize"
	maximizeBtn.Position = UDim2.new(1, -44, 0.5, 0)
	maximizeBtn.AutoButtonColor = false
	newCorner(maximizeBtn, 5)
	local maxStroke = newStroke(maximizeBtn)
	maxStroke.Name = "UIStroker"

	-- Container (G2L["20"])
	local container = Instance.new("Frame", commandsFrame)
	container.BorderSizePixel = 0
	container.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
	container.AnchorPoint = Vector2.new(0.5, 1)
	container.ClipsDescendants = true
	container.Size = UDim2.new(1, -20, 1, -66)
	container.Position = UDim2.new(0.5, 0, 1, -10)
	container.Name = "Container"
	container.BackgroundTransparency = 0.18
	newCorner(container, 4)
	newGradient(container, {Color3.fromRGB(25, 26, 34), Color3.fromRGB(18, 19, 25)})

	-- Filter TextBox (G2L["25"])
	local filter = Instance.new("TextBox", container)
	filter.Name = "Filter"
	filter.PlaceholderColor3 = Color3.fromRGB(148, 152, 168)
	filter.BorderSizePixel = 0
	filter.TextSize = 16
	filter.TextColor3 = Color3.fromRGB(232, 234, 242)
	filter.BackgroundColor3 = Color3.fromRGB(25, 26, 34)
	filter.FontFace = robotoRegular
	filter.AnchorPoint = Vector2.new(0.5, 0)
	filter.PlaceholderText = "Filter commands..."
	filter.Size = UDim2.new(1, -16, 0, 36)
	filter.Position = UDim2.new(0.5, 0, 0, 8)
	filter.Text = ""
	filter.BackgroundTransparency = 0.22
	filter.ClearTextOnFocus = false
	newCorner(filter, 5)
	newStroke(filter)

	-- List ScrollingFrame (G2L["21"])
	local list = Instance.new("ScrollingFrame", container)
	list.BorderSizePixel = 0
	list.Name = "List"
	list.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	list.Size = UDim2.new(1, -20, 1, -58)
	list.ScrollBarImageColor3 = Color3.fromRGB(92, 94, 110)
	list.Position = UDim2.new(0, 8, 0, 50)
	list.ScrollBarThickness = 0
	list.ScrollBarImageTransparency = 1
	list.BackgroundTransparency = 1
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new(0, 0, 0, 0)

	local listLayout = Instance.new("UIListLayout", list)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Padding = UDim.new(0, 5)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local listPadding = Instance.new("UIPadding", list)
	listPadding.PaddingTop = UDim.new(0, 4)
	listPadding.PaddingBottom = UDim.new(0, 8)

	-- Command template label (hidden, used as template for cloning - NA style)
	local commandTemplate = Instance.new("TextLabel", list)
	commandTemplate.TextWrapped = true
	commandTemplate.TextSize = 16
	commandTemplate.TextScaled = true
	commandTemplate.BackgroundColor3 = Color3.fromRGB(28, 29, 37)
	commandTemplate.FontFace = robotoRegular
	commandTemplate.TextColor3 = Color3.fromRGB(226, 228, 238)
	commandTemplate.BackgroundTransparency = 0.2
	commandTemplate.Size = UDim2.new(1, -12, 0, 32)
	commandTemplate.Text = ""
	commandTemplate.Name = "CommandTemplate"
	commandTemplate.Visible = false
	newCorner(commandTemplate, 4)

	-- Custom Scroll Bar (G2L["commands_scroll_bar"])
	local scrollBar = Instance.new("Frame", container)
	scrollBar.Name = "CustomScrollBar"
	scrollBar.BorderSizePixel = 0
	scrollBar.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
	scrollBar.BackgroundTransparency = 0.35
	scrollBar.Position = UDim2.new(1, -14, 0, 50)
	scrollBar.Size = UDim2.new(0, 10, 1, -58)
	scrollBar.Visible = false
	newCorner(scrollBar, 4)
	newStroke(scrollBar, Color3.fromRGB(155, 100, 255), 0.35)

	-- Scroll Up
	local scrollUp = Instance.new("TextButton", scrollBar)
	scrollUp.Name = "Up"
	scrollUp.BorderSizePixel = 0
	scrollUp.BackgroundColor3 = Color3.fromRGB(31, 32, 42)
	scrollUp.BackgroundTransparency = 0.12
	scrollUp.Size = UDim2.new(1, 0, 0, 12)
	scrollUp.AutoButtonColor = false
	scrollUp.Text = "^"
	scrollUp.TextColor3 = Color3.fromRGB(232, 234, 242)
	scrollUp.TextSize = 14
	scrollUp.FontFace = robotoBold
	newCorner(scrollUp, 3)

	-- Scroll Track
	local scrollTrack = Instance.new("TextButton", scrollBar)
	scrollTrack.Name = "Track"
	scrollTrack.BorderSizePixel = 0
	scrollTrack.BackgroundColor3 = Color3.fromRGB(23, 24, 31)
	scrollTrack.BackgroundTransparency = 0.1
	scrollTrack.Position = UDim2.new(0, 0, 0, 12)
	scrollTrack.Size = UDim2.new(1, 0, 1, -24)
	scrollTrack.AutoButtonColor = false
	scrollTrack.Text = ""
	newCorner(scrollTrack, 2)

	-- Scroll Thumb
	local scrollThumb = Instance.new("TextButton", scrollTrack)
	scrollThumb.Name = "Thumb"
	scrollThumb.BorderSizePixel = 0
	scrollThumb.BackgroundColor3 = Color3.fromRGB(86, 88, 104)
	scrollThumb.BackgroundTransparency = 0.05
	scrollThumb.Size = UDim2.new(1, 0, 0, 48)
	scrollThumb.AutoButtonColor = false
	scrollThumb.Text = ""
	newCorner(scrollThumb, 4)
	local thumbStroke = newStroke(scrollThumb, Color3.fromRGB(64, 66, 82), 0.25)

	-- Scroll Down
	local scrollDown = Instance.new("TextButton", scrollBar)
	scrollDown.Name = "Down"
	scrollDown.BorderSizePixel = 0
	scrollDown.BackgroundColor3 = Color3.fromRGB(31, 32, 42)
	scrollDown.BackgroundTransparency = 0.12
	scrollDown.Position = UDim2.new(0, 0, 1, -12)
	scrollDown.Size = UDim2.new(1, 0, 0, 12)
	scrollDown.AutoButtonColor = false
	scrollDown.Text = "v"
	scrollDown.TextColor3 = Color3.fromRGB(232, 234, 242)
	scrollDown.TextSize = 14
	scrollDown.FontFace = robotoBold
	newCorner(scrollDown, 3)

	-- Description label (shows on hover)
	local description = Instance.new("TextLabel", commandsFrame)
	description.Name = "Description"
	description.BorderSizePixel = 0
	description.TextSize = 13
	description.TextXAlignment = Enum.TextXAlignment.Center
	description.TextYAlignment = Enum.TextYAlignment.Center
	description.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
	description.FontFace = robotoRegular
	description.TextColor3 = Color3.fromRGB(184, 188, 202)
	description.BackgroundTransparency = 0.08
	description.AnchorPoint = Vector2.new(0.5, 1)
	description.Size = UDim2.new(1, -24, 0, 32)
	description.Position = UDim2.new(0.5, 0, 1, -4)
	description.Text = ""
	description.Visible = false
	description.TextWrapped = true
	description.ClipsDescendants = true
	newCorner(description, 4)
	newStroke(description, Color3.fromRGB(155, 100, 255), 0.5)

	return {
		ScreenGui = screenGui,
		Frame = commandsFrame,
		Container = container,
		Filter = filter,
		List = list,
		CommandTemplate = commandTemplate,
		Description = description,
		ExitBtn = exitBtn,
		MinimizeBtn = minimizeBtn,
		MaximizeBtn = maximizeBtn,
		ScrollBar = scrollBar,
		ScrollUp = scrollUp,
		ScrollDown = scrollDown,
		ScrollThumb = scrollThumb,
		ScrollTrack = scrollTrack,
	}
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 4: Command list rendering and filtering
-- ═══════════════════════════════════════════════════════════════════════════════

local function normalizeFilter(text)
	text = tostring(text or ""):lower()
	text = text:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
	return text
end

local function filterEntries(entries, searchText)
	if searchText == "" then
		return entries
	end
	local filtered = {}
	for _, entry in ipairs(entries) do
		local searchable = entry.searchable or ""
		if searchable:find(searchText, 1, true) then
			filtered[#filtered + 1] = entry
		end
	end
	return filtered
end

local function populateList(ui, entries)
	-- Remove old command labels (keep template)
	for _, child in ipairs(ui.List:GetChildren()) do
		if child.Name ~= "CommandTemplate" and child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	for i, entry in ipairs(entries) do
		local label = ui.CommandTemplate:Clone()
		label.Name = entry.name
		label.Text = " " .. entry.display
		label.LayoutOrder = i
		label.Visible = true
		label.Parent = ui.List

		-- Hover: show description
		local clickArea = Instance.new("TextButton", label)
		clickArea.Name = "ClickTarget"
		clickArea.BackgroundTransparency = 1
		clickArea.BorderSizePixel = 0
		clickArea.AutoButtonColor = false
		clickArea.Active = true
		clickArea.Text = ""
		clickArea.Size = UDim2.new(1, 0, 1, 0)
		clickArea.ZIndex = label.ZIndex + 2

		clickArea.MouseEnter:Connect(function()
			if entry.desc and entry.desc ~= "" then
				ui.Description.Visible = true
				ui.Description.Text = entry.desc
			end
		end)
		clickArea.MouseLeave:Connect(function()
			ui.Description.Visible = false
			ui.Description.Text = ""
		end)
	end

	ui.List.CanvasPosition = Vector2.new(0, 0)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 5: Custom Scroll Bar behavior
-- ═══════════════════════════════════════════════════════════════════════════════

local function setupCustomScroll(ui)
	local list = ui.List
	local scrollBar = ui.ScrollBar
	local scrollUp = ui.ScrollUp
	local scrollDown = ui.ScrollDown
	local scrollThumb = ui.ScrollThumb
	local scrollTrack = ui.ScrollTrack

	local function updateScroll()
		local canvasY = list.CanvasSize.Y.Offset
		local absY = list.AbsoluteSize.Y
		if canvasY <= absY then
			scrollBar.Visible = false
			return
		end
		scrollBar.Visible = true

		local ratio = absY / canvasY
		local thumbHeight = math.max(30, ratio * scrollTrack.AbsoluteSize.Y)
		scrollThumb.Size = UDim2.new(1, 0, 0, thumbHeight)

		local maxThumbY = scrollTrack.AbsoluteSize.Y - thumbHeight
		local maxScroll = canvasY - absY
		if maxScroll > 0 then
			local t = math.clamp(list.CanvasPosition.Y / maxScroll, 0, 1)
			scrollThumb.Position = UDim2.new(0, 0, 0, t * maxThumbY)
		end
	end

	-- Drag handling
	local dragging = false
	local dragStartY = 0
	local dragStartCanvasY = 0

	scrollThumb.MouseButton1Down:Connect(function()
		dragging = true
		dragStartY = game.Players.LocalPlayer:GetMouse().Y
		dragStartCanvasY = list.CanvasPosition.Y
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local deltaY = game.Players.LocalPlayer:GetMouse().Y - dragStartY
			local canvasY = list.CanvasSize.Y.Offset
			local absY = list.AbsoluteSize.Y
			local maxScroll = math.max(0, canvasY - absY)
			local pixelsPerScrollUnit = absY / math.max(1, canvasY)
			list.CanvasPosition = Vector2.new(0, math.clamp(dragStartCanvasY + deltaY / pixelsPerScrollUnit, 0, maxScroll))
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	scrollUp.MouseButton1Click:Connect(function()
		list.CanvasPosition = Vector2.new(0, math.max(0, list.CanvasPosition.Y - 40))
	end)

	scrollDown.MouseButton1Click:Connect(function()
		list.CanvasPosition = Vector2.new(0, list.CanvasPosition.Y + 40)
	end)

	scrollTrack.MouseButton1Click:Connect(function()
		local mouse = game.Players.LocalPlayer:GetMouse()
		local trackAbsPos = scrollTrack.AbsolutePosition.Y
		local trackAbsSize = scrollTrack.AbsoluteSize.Y
		local clickRatio = math.clamp((mouse.Y - trackAbsPos) / trackAbsSize, 0, 1)
		local canvasY = list.CanvasSize.Y.Offset
		local absY = list.AbsoluteSize.Y
		local maxScroll = math.max(0, canvasY - absY)
		list.CanvasPosition = Vector2.new(0, clickRatio * maxScroll)
	end)

	list:GetPropertyChangedSignal("CanvasPosition"):Connect(updateScroll)
	list:GetPropertyChangedSignal("CanvasSize"):Connect(updateScroll)
	scrollTrack:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScroll)

	-- Initial check
	task.defer(updateScroll)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 6: Window dragging
-- ═══════════════════════════════════════════════════════════════════════════════

local function setupDrag(ui)
	local topbar = ui.Frame:FindFirstChild("Topbar")
	if not topbar then return end

	local dragging, dragStart, startPos

	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = ui.Frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			game:GetService("UserInputService").InputChanged:Connect(function(update)
				if update == input and dragging then
					local delta = update.Position - dragStart
					ui.Frame.Position = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X,
						startPos.Y.Scale, startPos.Y.Offset + delta.Y
					)
				end
			end)
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION 7: Initialize
-- ═══════════════════════════════════════════════════════════════════════════════

local function init()
	print("[CommandsPanel] Fetching commands...")
	local commands = fetchCommands()
	print("[CommandsPanel] Loaded", #commands, "commands")

	local entries = buildEntries(commands)
	print("[CommandsPanel] Built", #entries, "entries")

	local ui = buildCommandsPanel()

	-- Parent to CoreGui (or PlayerGui if CoreGui fails)
	local ok, err = pcall(function()
		ui.ScreenGui.Parent = CoreGui
	end)
	if not ok then
		ui.ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	-- Populate list
	populateList(ui, entries)

	-- Wire up filter
	local debounce = 0
	ui.Filter:GetPropertyChangedSignal("Text"):Connect(function()
		debounce += 1
		local tick = debounce
		task.defer(function()
			if tick ~= debounce then return end
			local searchText = normalizeFilter(ui.Filter.Text)
			local filtered = filterEntries(entries, searchText)
			populateList(ui, filtered)
		end)
	end)

	-- Wire up buttons
	ui.ExitBtn.MouseButton1Click:Connect(function()
		ui.ScreenGui:Destroy()
	end)

	local minimized = false
	ui.MinimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		ui.Container.Visible = not minimized
		if minimized then
			ui.Frame.Size = UDim2.new(0, 380, 0, 44)
		else
			ui.Frame.Size = UDim2.new(0, 380, 0, 440)
		end
	end)

	-- Drag support
	setupDrag(ui)

	-- Custom scroll bar
	setupCustomScroll(ui)

	print("[CommandsPanel] Panel ready!")
end

init()
