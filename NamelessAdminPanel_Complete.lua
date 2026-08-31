-- Nameless Admin Commands Panel
-- Exact replica of the Nameless Admin UI

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Colors
local BG_COLOR = Color3.fromRGB(20, 20, 30)
local BORDER_COLOR = Color3.fromRGB(138, 43, 226)
local BTN_BG = Color3.fromRGB(35, 35, 45)
local BTN_HOVER = Color3.fromRGB(50, 50, 65)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local TITLE_COLOR = Color3.fromRGB(138, 43, 226)
local SEARCH_BG = Color3.fromRGB(30, 30, 42)
local CLOSE_HOVER = Color3.fromRGB(200, 40, 40)
local PATCHED_COLOR = Color3.fromRGB(180, 90, 40)
local SCROLLBAR_COLOR = Color3.fromRGB(138, 43, 226)

-- Remove existing GUI if any
for _, v in pairs(PlayerGui:GetChildren()) do
    if v.Name == "NAPanel" then v:Destroy() end
end
pcall(function()
    if game.CoreGui:FindFirstChild("NAPanel") then
        game.CoreGui:FindFirstChild("NAPanel"):Destroy()
    end
end)

-- Create ScreenGui (try CoreGui first, fall back to PlayerGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NAPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
local guiParent = PlayerGui
pcall(function()
    if game.CoreGui then
        guiParent = game.CoreGui
    end
end)
ScreenGui.Parent = guiParent

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 420, 0, 520)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = BORDER_COLOR
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -120, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Commands"
TitleLabel.TextColor3 = TITLE_COLOR
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Window buttons
local function MakeWinBtn(name, text, pos, hoverColor)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 30, 0, 26)
    btn.Position = pos
    btn.AnchorPoint = Vector2.new(0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = TEXT_COLOR
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = TitleBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = hoverColor
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    end)

    return btn
end

local CloseBtn = MakeWinBtn("Close", "X", UDim2.new(1, -34, 0, 5), CLOSE_HOVER)
local MaxBtn = MakeWinBtn("Max", "□", UDim2.new(1, -68, 0, 5), Color3.fromRGB(60, 60, 80))
local MinBtn = MakeWinBtn("Min", "—", UDim2.new(1, -102, 0, 5), Color3.fromRGB(60, 60, 80))

-- Content area
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, -16, 1, -46)
ContentFrame.Position = UDim2.new(0, 8, 0, 42)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Search Box
local SearchFrame = Instance.new("Frame")
SearchFrame.Name = "SearchFrame"
SearchFrame.Size = UDim2.new(1, 0, 0, 32)
SearchFrame.BackgroundColor3 = SEARCH_BG
SearchFrame.BorderSizePixel = 0
SearchFrame.Parent = ContentFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 6)
SearchCorner.Parent = SearchFrame

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = BORDER_COLOR
SearchStroke.Thickness = 1
SearchStroke.Transparency = 0.5
SearchStroke.Parent = SearchFrame

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Name = "Icon"
SearchIcon.Size = UDim2.new(0, 24, 1, 0)
SearchIcon.Position = UDim2.new(0, 8, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextColor3 = Color3.fromRGB(150, 150, 170)
SearchIcon.Font = Enum.Font.Gotham
SearchIcon.TextSize = 14
SearchIcon.Parent = SearchFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "Search"
SearchBox.Size = UDim2.new(1, -40, 1, 0)
SearchBox.Position = UDim2.new(0, 34, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Filter commands..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
SearchBox.TextColor3 = TEXT_COLOR
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 14
SearchBox.ClearTextOnFocus = false
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Parent = SearchFrame

-- Scrolling Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "List"
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.Position = UDim2.new(0, 0, 0, 38)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = SCROLLBAR_COLOR
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ScrollFrame.Parent = ContentFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Name = "Layout"
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 3)
ListLayout.Parent = ScrollFrame

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 2)
ListPadding.PaddingBottom = UDim.new(0, 8)
ListPadding.Parent = ScrollFrame

-- Draggable logic
local dragging, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Minimize / Maximize state
local minimized = false
local maximized = false
local normalSize = MainFrame.Size
local normalPos = MainFrame.Position

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ContentFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 420, 0, 36)
        MinBtn.Text = "+"
    else
        ContentFrame.Visible = true
        MainFrame.Size = normalSize
        MinBtn.Text = "—"
    end
end)

MaxBtn.MouseButton1Click:Connect(function()
    maximized = not maximized
    if maximized then
        normalSize = MainFrame.Size
        normalPos = MainFrame.Position
        MainFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
        MainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
    else
        MainFrame.Size = normalSize
        MainFrame.Position = normalPos
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Command data storage
local allCommands = {} -- {usage = string, patched = bool}
local commandButtons = {}

-- Create a command button
local function CreateCommandButton(cmd)
    local btn = Instance.new("TextButton")
    btn.Name = "Cmd"
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = cmd.patched and Color3.fromRGB(60, 35, 25) or BTN_BG
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = ScrollFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = cmd.patched and ("[PATCHED]  " .. cmd.usage) or cmd.usage
    label.TextColor3 = cmd.patched and Color3.fromRGB(220, 140, 70) or TEXT_COLOR
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = btn

    local bgDefault = cmd.patched and Color3.fromRGB(60, 35, 25) or BTN_BG
    local bgHover = cmd.patched and Color3.fromRGB(80, 45, 30) or BTN_HOVER

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = bgHover
    end)
    btn.MouseLeave:Connect(function()
        if btn.Parent then
            btn.BackgroundColor3 = bgDefault
        end
    end)

    btn.MouseButton1Click:Connect(function()
        -- Copy usage to clipboard
        if setclipboard then
            setclipboard(cmd.usage)
        elseif StarterGui:SetCore then
            pcall(function()
                StarterGui:SetCore("SetClipboard", cmd.usage)
            end)
        end

        -- Visual feedback
        local origText = label.Text
        local origColor = label.TextColor3
        label.Text = "Copied!"
        label.TextColor3 = Color3.fromRGB(100, 255, 100)
        task.delay(0.5, function()
            if label and label.Parent then
                label.Text = origText
                label.TextColor3 = origColor
            end
        end)
    end)

    return btn
end

-- Refresh the visible commands based on search filter
local function RefreshList(filter)
    filter = filter or ""
    filter = string.lower(filter)

    -- Clear existing buttons
    for _, btn in pairs(commandButtons) do
        btn:Destroy()
    end
    commandButtons = {}

    local order = 0
    for _, cmd in ipairs(allCommands) do
        if filter == "" or string.find(string.lower(cmd.usage), filter, 1, true) then
            order = order + 1
            local btn = CreateCommandButton(cmd)
            btn.LayoutOrder = order
            table.insert(commandButtons, btn)
        end
    end
end

-- Search box filtering
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    RefreshList(SearchBox.Text)
end)

-- Fetch commands from GitHub JSON
local function FetchCommands()
    local url = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/commands.json"
    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)

    if not success then
        -- Fallback: use the local file data
        warn("[NAPanel] Failed to fetch from GitHub, using fallback data")
        LoadFallbackData()
        return
    end

    local parseSuccess, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not parseSuccess or not data then
        warn("[NAPanel] Failed to parse JSON, using fallback data")
        LoadFallbackData()
        return
    end

    -- Extract commands
    if data.commands then
        for _, cmd in ipairs(data.commands) do
            if cmd.usage then
                table.insert(allCommands, {
                    usage = cmd.usage,
                    patched = false
                })
            end
        end
    end

    -- Extract patched commands
    if data.patched_commands then
        for _, cmd in ipairs(data.patched_commands) do
            if cmd.usage then
                table.insert(allCommands, {
                    usage = "[PATCHED] " .. cmd.usage,
                    patched = true
                })
            end
        end
    end

    -- Sort: non-patched first, then patched
    table.sort(allCommands, function(a, b)
        if a.patched ~= b.patched then
            return not a.patched
        end
        return a.usage < b.usage
    end)

    RefreshList()
end

-- Fallback data from the commands_usage.txt file
function LoadFallbackData()
    local fallbackLines = {
        "unload|unload", "pluginmaker|pluginmaker", "addallplugins|addallplugins",
        "addplugin|addplugin", "reloadplugin|reloadplugin [name]", "removeplugin|removeplugin",
        "removeallplugins|removeallplugins", "cmdbar2|cmdbar2 (cbar2)", "url|url <link>",
        "loadstring|loadstring <code> (ls, lstring, loads, execute)",
        "nocooldown|nocooldown <number> (ncd)", "unnocooldown|unnocooldown (unncd)",
        "waitcap|waitcap <seconds> (maxwait)", "unwaitcap|unwaitcap (unmaxwait)",
        "notween|notween [seconds] (instanttween)", "unnotween|unnotween (uninstanttween)",
        "gcsearch|gcsearch <text> (gcs)", "autopatchtool|autopatchtool [tool|all] (apt)",
        "unautopatchtool|unautopatchtool (unapt)",
        "tailsway|tailsway (tailwag, tailwagging, tailswaying)",
        "scriptlogger|scriptlogger [gui/console/both] (sslogger, securescriptslogger, securelogger)",
        "tas|tas [file] [smooth] [fps] [path] [velocity] [nocamera]",
        "scriptload|scriptload <name> (sload, loadscript)",
        "shaders|shaders (shader, rtx, hd)", "unshaders|unshaders (shadersoff, rtxoff)",
        "ibtools|ibtools", "unibtools|unibtools",
        "setfflag|setfflag <flag> <value> [save] (setff)",
        "addalias|addalias <command> <alias>", "removealias|removealias",
        "clearaliases|clearaliases",
        "addbutton|addbutton <command> <label> [<command2>] (ab)",
        "removebutton|removebutton (rb)", "clearbuttons|clearbuttons (clearbtns, cb)",
        "addautoexec|addautoexec <command> [arguments] (aaexec, addae, addauto, aexecadd)",
        "removeautoexec|removeautoexec (raexec, removeae, removeauto, aexecremove)",
        "clearautoexec|clearautoexec (caexec, clearauto, autoexecclear, aexecclear, aeclear)",
        "executor|executor (exec)", "lastcommand|lastcommand (lastcmd)",
        "ifundone|ifundone <command> [arguments]",
        "commandloop|commandloop", "stoploop|stoploop",
        "scripthub|scripthub (hub)",
        "gamescripts|gamescripts [refresh/on/off] (supportedscripts, gamesupport)",
        "uiscale|uiscale (uscale)", "prefix|prefix <symbol>",
        "saveprefix|saveprefix <symbol>", "chatlogs|chatlogs (clogs)",
        "music|music (musicplayer)", "gotocampos|gotocampos (tocampos,tcp)",
        "teleportgui|teleportgui", "imagescanner|imagescanner",
        "audiologger|audiologger", "serverremotespy|serverremotespy (srs,sremotespy)",
        "cig|cig (givecig,cigarette)", "cigar|cigar (givecigar)",
        "pipe|pipe (givepipe)", "discord|discord",
        "clickfling|clickfling (mousefling)", "unclickfling|unclickfling (unmousefling)",
        "offset|offset [x y z|y]", "upsidedown|upsidedown",
        "unoffset|unoffset", "unupsidedown|unupsidedown",
        "clickscare|clickscare (clickspook)", "unclickscare|unclickscare (unclickspook)",
        "hovername|hovername", "unhovername|unhovername",
        "hoverinventory|hoverinventory (hoverinv)", "unhoverinventory|unhoverinventory (unhoverinv)",
        "resetfilter|resetfilter", "ping|ping", "fps|fps",
        "fpsping|fpsping (pingfps)", "stats|stats (devstats, loadstats)",
        "speedometer|speedometer (sps,speedo)", "closespeedometer|closespeedometer (nosps,unspeedo)",
        "commands|commands", "settings|settings",
        "commandkeybinds|commandkeybinds (cmdkeybinds, ckeybinds)",
        "inspectoutfit|inspectoutfit <user/player/userid|outfit:id>",
        "avatarpreview|avatarpreview <me/player/userId/outfitId>",
        "clearavatarpreview|clearavatarpreview",
        "waypoints|waypoints", "binders|binders",
        "showwaypoints|showwaypoints", "hidewaypoints|hidewaypoints",
        "showpathwaypoint|showpathwaypoint <name...>",
        "hidepathwaypoint|hidepathwaypoint",
        "pathfindwaypoint|pathfindwaypoint <name...>",
        "looppath|looppath [tween|teleport|walk] <waypoint name...>",
        "looptweenpath|looptweenpath <waypoint name...>",
        "loopteleportpath|loopteleportpath <waypoint name...>",
        "loopwalkpath|loopwalkpath <waypoint name...>",
        "unlooppath|unlooppath",
        "looppathtweenspeed|looppathtweenspeed <speed>",
        "looppathteleportdelay|looppathteleportdelay <seconds>",
        "setwaypoint|setwaypoint <name...> [x y z]",
        "setwaypointpos|setwaypointpos <name...> <x> <y> <z>",
        "gotowaypoint|gotowaypoint <name...>",
        "removewaypoint|removewaypoint <name...>",
        "chardebug|chardebug (cdebug)", "unchardebug|unchardebug (uncdebug)",
        "naked|naked", "somersault|somersault (frontflip)",
        "unsomersault|unsomersault (unfrontflip)",
        "rolewatch|rolewatch <groupId> <role name>",
        "rolewatchstop|rolewatchstop", "rolewatchleave|rolewatchleave (unrolewatch)",
        "joingroup|joingroup [groupId] (groupjoin)",
        "trackstaff|trackstaff (staffwatch)",
        "stoptrackstaff|stoptrackstaff (untrackstaff, unstaffwatch)",
        "antistaff|antistaff [leave/serverhop] (staffescape, staffavoid)",
        "unantistaff|unantistaff (unstaffescape, unstaffavoid)",
        "rewind|rewind [seconds]", "unrewind|unrewind (stoprewind)",
        "rewindspeed|rewindspeed <frames>", "rewindtime|rewindtime <seconds>",
        "freemouse|freemouse", "hideacc|hideacc (accessories)",
        "backview|backview (rearview, rear, f5)",
        "worldmodelfp|worldmodelfp (wfcpfp, realfirstperson, fpmodel)",
        "frontview|frontview (resetcam)",
        "deletevelocity|deletevelocity (dv, removevelocity, removeforces)",
        "screenorientation|screenorientation [type]",
        "sensorrotationscreen|sensorrotationscreen",
        "landscaperotationscreen|landscaperotationscreen",
        "portraitrotationscreen|portraitrotationscreen",
        "defaultrotationscreen|defaultrotationscreen",
        "commandcount|commandcount (cc)",
        "flyfling|flyfling (ff)", "unflyfling|unflyfling (unff)",
        "walkfling|walkfling (wfling,wf) <speed>",
        "unwalkfling|unwalkfling (unwfling,unwf)",
        "touchfling|touchfling (tfling,tf) <speed>",
        "untouchfling|untouchfling (untfling,untf)",
        "rjre|rjre (rejoinrefresh)", "cancelteleport|cancelteleport",
        "cancelteleportloop|cancelteleportloop [interval]",
        "uncancelteleportloop|uncancelteleportloop",
        "rejoin|rejoin (rj)", "teleporttoplace|teleporttoplace <id>",
        "adonisbypass|adonisbypass (bypassadonis,badonis,adonisb)",
        "antinil|antinil (anticharnil, antinilchar, charantinil, keepchar)",
        "unantinil|unantinil (unanticharnil, unantinilchar, allowcharnil, unkeepchar)",
        "nilchar|nilchar (nilcharacter, charnil, nchar)",
        "unnilchar|unnilchar (unnilcharacter, uncharnil, nonilchar, restorechar, bringchar)",
        "accountage|accountage <player> (accage)",
        "hitboxes|hitboxes", "unhitboxes|unhitboxes",
        "vfly|vehiclefly (vfly)", "unvfly|unvfly",
        "equiptools|equiptools", "usetools|usetools (uset)",
        "settweenspeed|tweenspeed [seconds]",
        "tpup|tpup <studs>", "tpdown|tpdown <studs>",
        "tweento|tweengoto <player|npc:filter>",
        "reach|reach [number] (swordreach)", "boxreach|boxreach [number]",
        "resetreach|resetreach (normalreach, unreach)",
        "aura|aura [distance]", "unaura|unaura",
        "npcaura|npcaura [distance]", "unnpcaura|unnpcaura",
        "antivoid|antivoid", "unantivoid|unantivoid",
        "nofall|nofall [limit] [slow]", "unnofall|unnofall",
        "fakeout|fakeout", "invisfling|invisfling", "split|split",
        "antivoid2|antivoid2", "unantivoid2|unantivoid2",
        "antivelocity|antivelocity [limit]", "unantivelocity|unantivelocity",
        "antivelocityinstances|antivelocityinstances (antimovers)",
        "unantivelocityinstances|unantivelocityinstances (unantimovers)",
        "antiknockback|antiknockback (akb)", "unantiknockback|unantiknockback (unakb)",
        "showcom|showcom [radiusStuds]", "predict|predict <player> [leadSeconds]",
        "unpredict|unpredict <player>", "hidecom|hidecom",
        "droptool|droptool", "droptools|dropalltools",
        "loopdroptools|loopdroptools", "unloopdroptools|unloopdroptools",
        "notools|notools", "fpsbooster|fpsbooster",
        "annoy|annoy <player>", "unannoy|unannoy",
        "deleteinvisparts|deleteinvisparts",
        "invisibleparts|invisibleparts", "uninvisibleparts|uninvisibleparts",
        "datalimit|datalimit <kbps>",
        "removeads|removeads (adblock)", "unremoveads|unremoveads (noadblock,disableads)",
        "reloadassets|reloadassets", "enginesettingsinfo|enginesettingsinfo",
        "replicationlag|replicationlag (backtrack)",
        "animdata|animdata", "unanimdata|unanimdata",
        "sleepon|sleepon", "unsleepon|unsleepon",
        "throttle|throttle", "quality|quality <1-21>",
        "logphysics|logphysics", "nologphysics|nologphysics",
        "norender|norender", "render|render",
        "noreset|noreset", "resetbtn|resetbtn",
        "loopoof|loopoof", "unloopoof|unloopoof",
        "strengthen|strengthen", "unweaken|unweaken (unstrengthen)",
        "weaken|weaken", "setmass|setmass <mass>",
        "seat|seat", "vehicleseat|vehicleseat (vseat)",
        "copytools|copytools <player> (ctools)",
        "localtime|localtime (yourtime)", "localdate|localdate (yourdate)",
        "servertime|servertime (svtime)", "serverdate|serverdate (svdate)",
        "datetime|datetime (localdatetime)", "uptime|uptime",
        "timestamp|timestamp (epoch)",
        "cartornado|cartornado (ctornado)", "unspam|unspam",
        "unctest|UNCTest (UNC)", "vulnerabilitytest|vulnerabilitytest (vulntest)",
        "respawn|respawn (re)", "antisit|antisit", "unantisit|unantisit",
        "antikick|antikick (nokick, bypasskick, bk)",
        "antiteleport|antiteleport (noteleport, blocktp)",
        "unantikick|unantikick", "unantiteleport|unantiteleport",
        "anticframeteleport|anticframeteleport (acframetp,acftp)",
        "unanticframeteleport|unanticframeteleport (unacframetp,unacftp)",
        "lay|lay", "trip|trip", "permtrip|permtrip (ptrip)",
        "unpermtrip|unpermtrip (unptrip)",
        "antitrip|antitrip", "unantitrip|unantitrip",
        "disablehumanoidstate|disablehumanoidstate",
        "enablehumanoidstate|enablehumanoidstate [state/all]",
        "checkrfe|checkrfe", "sit|sit",
        "oldroblox|oldroblox", "unoldroblox|unoldroblox",
        "2012|2012", "2013|2013", "2014|2014", "2015|2015", "2016|2016",
        "f3x|f3x (fex)", "harked|harked (comet)",
        "triggerbot|triggerbot (tbot)",
        "setspawn|setspawn (spawnpoint, ss)",
        "disablespawn|disablespawn (unsetspawn, ds)",
        "autoflashback|autoflashback", "unautoflashback|unautoflashback",
        "flashback|flashback", "flashbackalt|flashbackalt (fba)",
        "autoflashbackalt|autoflashbackalt (afba)",
        "unautoflashbackalt|unautoflashbackalt",
        "tospawn|tospawn (ts)",
        "hamster|hamster <number>", "unhamster|unhamster",
        "antiafk|antiafk (noafk)", "unantiafk|unantiafk (unnoafk)",
        "tptool|tptool", "unclicktptool|unclicktptool",
        "clickteleport|clickteleport", "clickdelete|clickdelete",
        "thru|thru <distance>",
        "olddex|olddex", "dex|dex", "minimap|minimap",
        "animationplayer|animationplayer", "decompiler|decompiler",
        "getidfromusername|getidfromusername (gidu)",
        "getuserfromid|getuserfromid (guid)",
        "ownerid|ownerid", "userid|userid <id>",
        "username|username <name>",
        "spoofclientid|spoofclientid <value> (spoofclid)",
        "unspoofclientid|unspoofclientid (unspoofclid)",
        "synapsedex|synapsedex (sdex)",
        "antifling|antifling", "unantifling|unantifling",
        "antiflingparts|antiflingparts [linearVelocity] [angularVelocity]",
        "unantiflingparts|unantiflingparts",
        "gravitygun|gravitygun",
        "lockws|lockws (lockworkspace)", "unlockws|unlockws (unlockworkspace)",
        "vehiclespeed|vehiclespeed <amount> (vspeed)",
        "unvehiclespeed|unvehiclespeed (unvspeed)",
        "shiftlock|shiftlock (sl)", "unshiftlock|unshiftlock (unsl)",
        "enable|enable", "disable|disable",
        "reverb|reverb (reverbcontrol)", "forcereverb|forcereverb",
        "unforcereverb|unforcereverb (ufreverb, ufr)",
        "cam|cam (camera, cameratype)", "forcecam|forcecam",
        "unforcecam|unforcecam (ufcam, ufc)",
        "alignmentkeys|alignmentkeys", "disablealignmentkeys|disablealignmentkeys",
        "esp|esp (espplayers, playeresp)", "espall|espall (allesp)",
        "espenemies|espenemies (espnonteam, espnoteam)",
        "espallies|espallies (espteammates)",
        "espteam|espteam <team prefix>",
        "chams|chams", "chamsenemies|chamsenemies (chamsnonteam)",
        "chamsallies|chamsallies (chamsteammates)",
        "chamsteam|chamsteam <team prefix>",
        "locate|locate <username1> <username2> etc (optional)",
        "npcesp|npcesp [npc:name|filter] (espnpc)",
        "unnpcesp|unnpcesp (unespnpc)",
        "unesp|unesp (unchams)",
        "unlocate|unlocate <username1> <username2>",
        "vehiclenoclip|vehiclenoclip (vnoclip)",
        "vehicleclip|vehicleclip (vclip, unvnoclip, unvehiclenoclip)",
        "handlekill|handlekill <player> (hkill)",
        "creep|creep <player>",
        "netless|netless (net)", "reset|reset (die)",
        "gethealth|gethealth",
        "antibreakjoints|antibreakjoints", "unantibreakjoints|unantibreakjoints",
        "breakjoints|breakjoints",
        "desync|desync (ngrep)", "undesync|undesync (undg,syncdesync)",
        "raknetdesync|raknetdesync (rkdesync,rkds,rkd)",
        "unraknetdesync|unraknetdesync (unrkdesync,unrkds,unrkd)",
        "runanim|runanim <id> [speed] (playanim,anim)",
        "animbuilder|animbuilder (abuilder)",
        "setkiller|setkiller (killeranim)",
        "setpsycho|setpsycho (psychoanim)",
        "resetanims|resetanims (defaultanims,animsreset)",
        "animcopycore|animcopycore <target>",
        "syncanim|syncanim <target>", "syncstop|syncstop",
        "animresetcore|animresetcore", "unsyncreset|unsyncreset",
        "mimic|mimic <target> [delay]", "mstop|mstop",
        "bubblechat|bubblechat (bchat)", "unbubblechat|unbubblechat (unbchat)",
        "hideicon|hideicon", "showicon|showicon",
        "topbar|topbar (showtopbar)", "untopbar|untopbar (hidetopbar)",
        "lockiconposition|lockiconposition", "unlockiconposition|unlockiconposition",
        "saveinstance|saveinstance (savegame)",
        "admin|admin <player>", "unadmin|unadmin <player>",
        "partname|partname (partpath,partgrabber)",
        "jobid|jobid", "joinjobid|joinjobid <jobid>",
        "copyteleport|copyteleport (ct)", "copytween|copytween (ctw)",
        "copymoveto|copymoveto (cmt)", "copylerp|copylerp (cl)",
        "copytptogame|copytptogame (cttg)", "copytptoserver|copytptoserver (ctts)",
        "serverhop|serverhop [default/advanced] (shop)",
        "smallserverhop|smallserverhop (sshop)",
        "pingserverhop|pingserverhop (pshop)",
        "oldserverhop|oldserverhop (oldhop)",
        "newserverhop|newserverhop (newhop)",
        "versionhop|versionhop <version> (vhop)",
        "oldversionhop|oldversionhop (ovhop)",
        "regionhop|regionhop <region/city> (rhop)",
        "autorejoin|autorejoin (autorj)", "unautorejoin|unautorejoin (unautorj)",
        "functionspy|functionspy",
        "fly|fly [speed]", "unfly|unfly",
        "cframefly|cframefly [speed] (cfly)", "uncframefly|uncfly",
        "tfly|tfly [speed] (tweenfly)", "untfly|untfly",
        "noclip|noclip", "clip|clip",
        "antianchor|antianchor", "unantianchor|unantianchor",
        "antibang|antibang", "unantibang|unantibang",
        "orbit|orbit <player> <distance> [speed]",
        "uporbit|uporbit <player> <distance> [speed]",
        "unorbit|unorbit",
        "freecam|freecam [speed] (fc,fcam)",
        "freecamgoto|freecamgoto <player> (fcgoto,fcgo,fcg,freecamto,fcto)",
        "freecamgotopart|freecamgotopart <partname> (fcgotopart,fcgpart,fcgp,freecamtopart,fctopart,fctp)",
        "unfreecam|unfreecam (unfc,unfcam)",
        "nohats|nohats (drophats)",
        "instantrespawn|instantrespawn (instantr, irespawn)",
        "circlemath|circlemath <mode> <size>",
        "grippos|grippos (setgrip)",
        "seizure|seizure", "unseizure|unseizure",
        "fakelag|fakelag (flag)", "unfakelag|unfakelag (unflag)",
        "hide|hide <player> (unshow)", "unhide|show <player> (unhide)",
        "aimbot|aimbot (aimbotui,aimbotgui)",
        "grabtools|grabtools [range]",
        "loopgrabtools|loopgrabtools [range]",
        "unloopgrabtools|unloopgrabtools",
        "dance|dance", "undance|undance",
        "animspoofer|animspoofer (animationspoofer, spoofanim, animspoof)",
        "badgeviewer|badgeviewer (badgeview, bviewer, badgev, bv)",
        "bodytransparency|bodytransparency <number> [part1] [part2] ... (btransparency,bodyt)",
        "unbodytransparency|unbodytransparency (unbtransparency,unbodyt)",
        "material|material <material> (mat, charmaterial, cmat, bodymaterial, bmat)",
        "unmaterial|unmaterial (unmat, uncharmaterial, uncmat, unbodymaterial, unbmat)",
        "animationspeed|animationspeed <speed> (animspeed,aspeed)",
        "unanimationspeed|unanimationspeed (unanimspeed,unaspeed)",
        "placeid|placeid (pid)", "gameid|gameid (universeid,gid)",
        "firework|firework", "placename|placename (pname)",
        "gameinfo|gameinfo (ginfo)", "userpreview|userpreview",
        "copyname|copyname <player> (cname)",
        "copydisplay|copydisplay <player> (cdisplay)",
        "copyid|copyid <player> (id)",
        "antitouch|antitouch [remove/cantouch/loop] (antikillbrick, antikb)",
        "loopantitouch|loopantitouch (loopantikillbrick, loopantikb)",
        "unantitouch|unantitouch (unantikillbrick, unantikb)",
        "height|height <number> (hipheight,hh)",
        "netbypass|netbypass (netb)",
        "day|day", "night|night", "time|time <number>",
        "chat|chat <text> (message)",
        "uwuify|uwuify <text> (cutechat)",
        "autouwuify|autouwuify (autocutechat)",
        "unautouwuify|unautouwuify (unautocutechat)",
        "uwustutter|uwustutter (chatstutter)",
        "unuwustutter|unuwustutter (unchatstutter)",
        "uwuaffix|uwuaffix (chataffix)", "unuwuaffix|unuwuaffix (unchataffix)",
        "privatemessage|privatemessage <player> <text> (pm)",
        "mimicchat|mimicchat <player> (mimic)",
        "stopmimicchat|stopmimicchat (unmimicchat)",
        "fixcam|fixcam", "fling|fling <player>",
        "commitoof|commitoof (suicide, kys)",
        "volume|volume <0-10> (vol)",
        "perfstats|perfstats <on/off>",
        "preftransparency|preftransparency <0-15>",
        "sensitivity|sensitivity <1-10> (sens)",
        "torandom|torandom (tr)",
        "timestop|timestop (tstop)", "untimestop|untimestop (untstop)",
        "team|team <team name>",
        "reselectchar|reselectchar",
        "goto|goto <player|npc:filter|X,Y,Z>",
        "lookat|lookat <player|npc:filter>", "unlookat|unlookat",
        "starenear|starenear (stareclosest)",
        "unstarenear|unstarenear (unstareclosest)",
        "watch|watch <Player> (view, spectate)", "unwatch|unwatch (unview)",
        "watch2|watch2", "unwatch2|unwatch2",
        "stealaudio|stealaudio <player>",
        "follow|follow <player>", "unfollow|unfollow",
        "autofollow|autofollow (autostalk,proxfollow)",
        "unautofollow|unautofollow (stopautofollow,unproxfollow)",
        "pathfind|pathfind <player>",
        "freeze|freeze (thaw,anchor,fr)", "unfreeze|unfreeze (unthaw,unanchor,unfr)",
        "blackhole|blackhole",
        "disableanimations|disableanimations (disableanims)",
        "undisableanimations|undisableanimations (undisableanims)",
        "hatresize|hatresize", "exit|exit",
        "firekey|firekey [key] (fkey)",
        "loopfling|loopfling <player>", "unloopfling|unloopfling",
        "freegamepass|freegamepass (freegp)",
        "devproducts|devproducts (products)",
        "gamepasses|gamepasses (passes)",
        "listen|listen <player>", "vcworld|vcworld <on/off>",
        "unlisten|unlisten", "gear|gear [id]",
        "lockmouse|lockmouse (lockm)", "unlockmouse|unlockmouse (unlockm)",
        "lockmouse2|lockmouse2 (lockm2)", "unlockmouse2|unlockmouse2 (unlockm2)",
        "cursorvisible|cursorvisible (mousevisible)",
        "cursorfree|cursorfree (mousefree)",
        "cursorreset|cursorreset (mousereset)",
        "cursorrestore|cursorrestore (mouserestore)",
        "headsit|headsit <player>", "unheadsit|unheadsit",
        "walltp|walltp", "unwalltp|unwalltp (nowalltp)",
        "wallhop|wallhop", "unwallhop|unwallhop",
        "joinvoice|joinvoice",
        "jump|jump", "loopjump|loopjump (bhop)",
        "unloopjump|unloopjump (unbhop)",
        "jumpboost|jumpboost <number> (jboost)",
        "unjumpboost|unjumpboost (unjboost)",
        "trussjump|trussjump", "untrussjump|untrussjump",
        "chattranslate|chattranslate",
        "headstand|headstand <player>", "unheadstand|unheadstand",
        "loopwalkspeed|loopwalkspeed <number> (loopws,lws)",
        "unloopwalkspeed|unloopwalkspeed",
        "loopjumppower|loopjumppower <number> (loopjp,ljp)",
        "unloopjumppower|unloopjumppower (unloopjp,unljp)",
        "stopanimations|stopanimations (stopanims,stopanim,noanim)",
        "refreshanimations|refreshanimations (refreshanimation,refreshanims,refreshanim)",
        "loopwaveat|loopwaveat <player> (loopwat)",
        "unloopwaveat|unloopwaveat (unloopwat)",
        "tools|tools (gears)",
        "toolview|toolview <player> (tview)",
        "untoolview|untview <player> (untview)",
        "toolview2|toolview2 (tview2)",
        "waveat|waveat <player> (wat)",
        "headbang|headbang <player> (mouthbang,headfuck,mouthfuck,facebang,facefuck,hb,mb)",
        "unheadbang|unheadbang (unmouthbang,unhb,unmb)",
        "jerkuser|jerkuser <player> (jorkuser, handjob, hjob, handj)",
        "unjerkuser|unjerkuser (unjorkuser, unhandjob, unhjob, unhandj)",
        "suck|suck <player> <number>", "unsuck|unsuck",
        "improvetextures|improvetextures", "undotextures|undotextures",
        "serverlist|serverlist (serverlister,slist)",
        "keyboard|keyboard", "autoclicker|autoclicker",
        "backpack|backpack", "unloadbackpack|unloadbackpack (unbackpack)",
        "edgejump|edgejump (ejump)",
        "unedgejump|unedgejump (noedgejump, noejump, unejump)",
        "equiptools|equiptools (etools,equipt)",
        "unequiptools|unequiptools",
        "equiptool|equiptool (etool)",
        "loopequiptool|loopequiptool <tool name>",
        "unloopequiptool|unloopequiptool",
        "multitool|multitool (mtool)", "unmultitool|unmultitool (nomultitool)",
        "bang|bang <player> <number> (fuck)", "unbang|unbang (unfuck)",
        "carpet|carpet <player>", "uncarpet|uncarpet (nocarpet)",
        "climb|climb", "unclimb|unclimb",
        "inversebang|inversebang <player> <number>",
        "uninversebang|uninversebang",
        "suslay|suslay (laysus)", "unsuslay|unsuslay",
        "jerk|jerk (jork)",
        "hug|hug (clickhug)", "unhug|unhug",
        "glue|glue <player>", "unglue|unglue",
        "glueback|glueback <player>", "unglueback|unglueback",
        "spook|spook <player> (scare)",
        "loopspook|loopspook <player>", "unloopspook|unloopspook",
        "airwalk|airwalk (float, aw)", "unairwalk|unairwalk (unfloat, unaw)",
        "airmomentum|airmomentum (amomentum, aircontrol)",
        "unairmomentum|unairmomentum (unamomentum, unaircontrol)",
        "cbring|cbring <player> [distance]",
        "loopcbring|loopcbring <player> [distance]",
        "unloopcbring|unloopcbring",
        "mute|mute <player> (muteboombox)",
        "tpwalk|tpwalk <number>", "untpwalk|untpwalk",
        "tpjump|tpjump <number>", "untpjump|untpjump",
        "loopmute|loopmute <player> (loopmuteboombox)",
        "unloopmute|unloopmute <player> (unloopmuteboombox)",
        "getmass|getmass <player>",
        "copyposition|copyposition <player>",
        "removeterrain|removeterrain (rterrain, noterrain)",
        "memory|memory",
        "clearnilinstances|clearnilinstances (nonilinstances, cni)",
        "inspect|inspect",
        "noprompt|noprompt (nopurchaseprompts,noprompts,np)",
        "prompt|prompt (purchaseprompts,showprompts,showpurchaseprompts,ppr)",
        "nonetworkpause|nonetworkpause (disableNetworkPause,nnw,nnpause)",
        "networkpause|networkpause (enablenetworkpause,nw,npause)",
        "wallwalk|wallwalk",
        "hideguis|hideguis", "unhideguis|unhideguis",
        "hidecurrentguis|hidecurrentguis", "unhidecurrentguis|unhidecurrentguis",
        "showguis|showguis", "unshowguis|unshowguis",
        "hidetargetgui|hidetargetgui <name>", "unhidetargetgui|unhidetargetgui",
        "showtargetgui|showtargetgui <name>", "unshowtargetgui|unshowtargetgui",
        "spin|spin", "unspin|unspin",
        "notepad|notepad", "rc7|rc7",
        "scriptviewer|scriptviewer (viewscripts)",
        "moduleeditor|moduleeditor",
        "upvalueeditor|upvalueeditor",
        "hydroxide|hydroxide (hydro)",
        "remotespy|remotespy (simplespy,rspy)",
        "cobaltspy|cobaltspy (cobalt,cspy)",
        "turtlespy|turtlespy (tspy)",
        "gravity|gravity <amount> (grav)",
        "fireclickdetectors|fireclickdetectors (fcd,firecd)",
        "fireclickdetectorsfind|fireclickdetectorsfind <target> (fcdfind,firecdfind)",
        "fireproximityprompts|fireproximityprompts (fpp,firepp)",
        "fireproximitypromptsfind|fireproximitypromptsfind <target> (fppfind,fireppfind)",
        "firetouchinterests|firetouchinterests (fti)",
        "firetouchinterestsfind|firetouchinterestsfind <target> (ftifind,firetifind)",
        "proximitypromptgoto|proximitypromptgoto [name] (promptgoto, ppgoto)",
        "clickdetectorgoto|clickdetectorgoto [name] (clickgoto, cdgoto)",
        "touchinterestgoto|touchinterestgoto [name] (touchgoto, tigoto)",
        "autofireproxi|autofireproxi <interval> [target]",
        "autofireproxifind|autofireproxifind <interval> [target]",
        "autofireclick|autofireclick <interval> [target]",
        "autofireclickfind|autofireclickfind <interval> [target]",
        "autotouch|autotouch <interval> [target]",
        "autotouchfind|autotouchfind <interval> [target]",
        "autofireremote|autofireremote <interval> [target]",
        "autofireremotefind|autofireremotefind <interval> [target]",
        "unautofireproxi|unautofireproxi (uafp)",
        "unautofireclick|unautofireclick (uafc)",
        "unautotouch|unautotouch (uat)",
        "unautofireremote|unautofireremote (uafr)",
        "unautotouchfind|unautotouchfind (uatfind)",
        "unautofireproxifind|unautofireproxifind (uafpfind)",
        "unautofireclickfind|unautofireclickfind (uafcfind)",
        "unautofireremotefind|unautofireremotefind (uafrfind)",
        "noclickdetectorlimits|noclickdetectorlimits <limit> (nocdlimits,removecdlimits)",
        "noproximitypromptlimits|noproximitypromptlimits <limit> (nopplimits,removepplimits)",
        "instantproximityprompts|instantproximityprompts (instantpp,ipp)",
        "uninstantproximityprompts|uninstantproximityprompts (uninstantpp,unipp)",
        "fastprompts|fastprompts [speed] (fastproximityprompts,fastpp)",
        "unfastprompts|unfastprompts (unfastproximityprompts,unfastpp)",
        "enableproximitypromptservice|enableproximitypromptservice (enablepps,epps,ppson,ppon)",
        "disableproximitypromptservice|disableproximitypromptservice (disablepps,dpps,ppsoff,ppoff)",
        "enableproximityprompts|enableproximityprompts [name]",
        "disableproximityprompts|disableproximityprompts [name]",
        "loopenableproximityprompts|loopenableproximityprompts [name]",
        "unloopenableproximityprompts|unloopenableproximityprompts",
        "r6|r6", "r15|r15",
        "breakvelocity|breakvelocity (breakv,bvel,zvel,zerovel,stopvel,brkvel)",
        "maxslopeangle|maxslopeangle <number> (msa)",
        "loopmaxslopeangle|loopmaxslopeangle <number> (loopmsa,lmsa)",
        "unloopmaxslopeangle|unloopmaxslopeangle (unloopmsa,unlmsa)",
        "godmode|godmode (god)", "ungodmode|ungodmode (ungod)",
        "controllock|controllock (ctrllock)",
        "uncontrollock|uncontrollock (unctrllock)",
        "resetlock|resetlock",
        "flashlight|flashlight (fl)",
        "light|light <range> <brightness> <hexColor>",
        "unlight|unlight (nolight)",
        "lighting|lighting (lightingcontrol)",
        "friend|friend <player>", "unfriend|unfriend <player>",
        "block|block <player> (blockuser)",
        "unblock|unblock <player> (unblockuser)",
        "invitefriends|invitefriends [username/userId] (invite)",
        "experienceevents|experienceevents (events)",
        "eventinfo|eventinfo <eventId>",
        "rsvpevent|rsvpevent <eventId> (eventrsvp)",
        "feedback|feedback",
        "friendweb|friendweb (fweb)",
        "massfollowedinto|massfollowedinto",
        "tweengotocampos|tweengotocampos (tweentcp)",
        "delete|delete", "deletefind|deletefind",
        "deletelighting|deletelighting (removelighting, removel, ldel)",
        "lightingdisable|lightingdisable (disablelighting, ldisable)",
        "autodelete|autodelete", "unautodelete|unautodelete",
        "autodeletefind|autodeletefind",
        "unautodeletefind|unautodeletefind (unautoremovefind,unautodelfind)",
        "deleteclass|deleteclass",
        "autodeleteclass|autodeleteclass", "unautodeleteclass|unautodeleteclass",
        "chardelete|chardelete",
        "chardeletefind|chardeletefind",
        "chardeleteclass|chardeleteclass",
        "gotopartnext|gotopartnext [prefix] <start> [end] [delay] (gpn)",
        "gotomodelnext|gotomodelnext [prefix] <start> [end] [delay] (gmn)",
        "gotofoldernext|gotofoldernext [prefix] <start> [end] [delay] (gfn)",
        "gotobreak|gotobreak (gb)", "gotopart|gotopart",
        "tweengotopart|tweengotopart <partName>",
        "gotopartfind|gotopartfind",
        "tweengotopartfind|tweengotopartfind",
        "gotopartclass|gotopartclass",
        "bringpart|bringpart", "bringpartfind|bringpartfind",
        "bringmodel|bringmodel", "bringmodelfind|bringmodelfind",
        "bringfolder|bringfolder",
        "gotomodel|gotomodel", "gotomodelfind|gotomodelfind",
        "gotofolder|gotofolder",
        "swim|swim", "unswim|unswim",
        "punch|punch",
        "tpua|tpua <player>",
        "blackholefollow|blackholefollow",
        "noblackholefollow|noblackholefollow",
        "swordfighter|swordfighter (sfighter, swordf, swordbot, sf)",
        "touchesp|touchesp", "untouchesp|untouchesp",
        "proximityesp|proximityesp", "unproximityesp|unproximityesp",
        "clickesp|clickesp", "unclickesp|unclickesp",
        "itemesp|itemesp", "unitemesp|unitemesp",
        "sitesp|sitesp", "unsitesp|unsitesp",
        "vehiclesitesp|vehiclesitesp", "unvehiclesitesp|unvehiclesitesp",
        "pesp|pesp", "unpesp|unpesp [name|All]",
        "pespfind|pespfind", "unpespfind|unpespfind [name|All]",
        "unanchored|unanchored", "ununanchored|ununanchored",
        "collisionesp|collisionesp", "uncollisionesp|uncollisionesp",
        "nocollisionesp|nocollisionesp", "unnocollisionesp|unnocollisionesp",
        "propertyesp|propertyesp <Property> <Value> [class:ClassName]",
        "unpropertyesp|unpropertyesp [Property] [Value|All]",
        "shapeesp|shapeesp [Block|Ball|Cylinder|Wedge|CornerWedge]",
        "unshapeesp|unshapeesp [shape|All]",
        "esplocator|esplocator", "unesplocator|unesplocator",
        "folderesp|folderesp", "modelesp|modelesp",
        "unfolderesp|unfolderesp [folderName]",
        "unmodelesp|unmodelesp [modelName]",
        "viewpart|viewpart", "unviewpart|unviewpart (unviewp)",
        "viewpartfind|viewpartfind",
        "console|console (debug)", "oldconsole|oldconsole",
        "exportconsole|exportconsole [txt|json] (consoleexport, conexport)",
        "hitbox|hitbox", "unhitbox|unhitbox <player>",
        "partsize|partsize", "partsizefind|partsizefind",
        "unpartsize|unpartsize", "unpartsizefind|unpartsizefind",
        "breakcars|breakcars (bcars)",
        "setsimradius|setsimradius <number>",
        "infjump|infjump (infinitejump)",
        "uninfjump|uninfjump (uninfinitejump)",
        "flyjump|flyjump", "unflyjump|unflyjump (noflyjump)",
        "xray|xray (xrayon)", "unxray|unxray (xrayoff)",
        "echolocation|echolocation (echo, echolocate)",
        "unecholocation|unecholocation (unecho, noecho)",
        "echoping|echoping (eping, sonarping)",
        "fullbright|fullbright (fullb,fb)",
        "loopday|loopday", "unloopday|unloopday",
        "loopfullbright|loopfullbright", "unloopfullbright|unloopfullbright",
        "loopnight|loopnight", "unloopnight|unloopnight",
        "loopnoeffect|loopnoeffect", "unloopnoeffect|unloopnoeffect",
        "noeffect|noeffect",
        "loopnofog|loopnofog", "unloopnofog|unloopnofog",
        "nofog|nofog",
        "nightmare|nightmare", "unnightmare|unnightmare (unnm)",
        "brightness|brightness <number>",
        "loopbrightness|loopbrightness (loopbri,loopb)",
        "unloopbrightness|unloopbrightness (unloopbri,unloopb)",
        "globalshadows|globalshadows",
        "unglobalshadows|unglobalshadows (nogshadows,ungshadows,noglobalshadows)",
        "gamma|gamma (exposure)",
        "loopgamma|loopgamma (loopexposure)",
        "unloopgamma|unloopgamma (unlgamma, unloopexposure, unlexposure)",
        "firstp|firstperson (1stp,firstp,fp)",
        "thirdp|thirdperson (3rdp,thirdp)",
        "maxzoom|maxzoom <amount>", "minzoom|minzoom <amount>",
        "loopmaxzoom|loopmaxzoom <amount> (lmaxzoom,lmzoom,lmz,forcemaxzoom,fmaxzoom)",
        "unloopmaxzoom|unloopmaxzoom (unlmaxzoom,unlmzoom,unlmz,unforcemaxzoom,unfmaxzoom)",
        "loopminzoom|loopminzoom <amount> (lminzoom,lnzoom,lnz,forceminzoom,fminzoom)",
        "unloopminzoom|unloopminzoom (unlminzoom,unlnzoom,unlnz,unforceminzoom,unfminzoom)",
        "cameranoclip|cameranoclip (camnoclip,cnoclip,nccam)",
        "uncameranoclip|uncameranoclip (uncamnoclip,uncnoclip,unnccam)",
        "oganims|oganims", "fakechat|fakechat",
        "fpscap|fpscap <number>",
        "toolinvisible|toolinvisible (tinvis)",
        "invisible|invisible (invis)", "visible|visible",
        "invisbind|invisbind (invisiblebind, bindinvis)",
        "fireremote|fireremote [select|remote name/full name] (fremote, frmt)",
        "fireremotes|fireremotes (fremotes, frem)",
        "keepna|keepna", "unkeepna|unkeepna",
        "fov|fov <number>",
        "loopfov|loopfov <number> (lfov)", "unloopfov|unloopfov (unlfov)",
        "savetools|savetools (stools)", "loadtools|loadtools (ltools)",
        "preventtools|preventtools (noequip,antiequip)",
        "unpreventtools|unpreventtools (unnoequip,unantiequip)",
        "ws|walkspeed <number> (speed,ws)",
        "jp|jumppower <number> (jp)",
        "blockremote|blockremote [name]",
        "unblockremote|unblockremote [name|all]",
        "bypassspeed|bypassspeed <number> (bps,bpws)",
        "loopbypassspeed|loopbypassspeed <number|off> (lbps,lbws)",
        "unloopbypassspeed|unloopbypassspeed (unlbps,unlbws)",
        "oofspam|oofspam", "httpspy|httpspy",
        "keystroke|keystroke",
        "errorchat|errorchat", "clearerror|clearerror",
        "antierror|antierror", "unantierror|unantierror",
        "boobs|boobs <size> (boobies)",
        "unboobs|unboobs (unboobies,noboobs,noboobies)",
        "ass|ass <size> (booty)", "unass|unass (noass)",
        "penis|penis <length> (pp)",
        "unpenis|unpenis (unpp,nopenis,nopp)",
        "flingnpcs|flingnpcs",
        "npcfollow|npcfollow",
        "loopnpcfollow|loopnpcfollow", "unloopnpcfollow|unloopnpcfollow",
        "sitnpcs|sitnpcs", "unsitnpcs|unsitnpcs",
        "killnpcs|killnpcs",
        "npcwalkspeed|npcwalkspeed <speed>",
        "npcjumppower|npcjumppower <power>",
        "bringnpcs|bringnpcs [distance]",
        "loopbringnpcs|loopbringnpcs [distance] (lbnpcs, loopbnpcs, lbringnpcs)",
        "unloopbringnpcs|unloopbringnpcs (unlbnpcs, unloopbnpcs, unlbringnpcs)",
        "gotonpcs|gotonpcs",
        "actnpc|actnpc", "unactnpc|unactnpc (stopnpc)",
        "clicktouch|clicktouch (ctouch)", "unclicktouch|unclicktouch (unctouch)",
        "clickkillnpc|clickkillnpc (cknpc)",
        "unclickkillnpc|unclickkillnpc (uncknpc)",
        "voidnpcs|voidnpcs (vnpcs)",
        "clickvoidnpc|clickvoidnpc (cvnpc)",
        "unclickvoidnpc|unclickvoidnpc (uncvnpc)",
        "clicknpcws|clicknpcws", "unclicknpcws|unclicknpcws",
        "clicknpcjp|clicknpcjp", "unclicknpcjp|unclicknpcjp",
        "rename|rename <text>", "unname|unname",
        "autorespawn|autorespawn (autore,arespawn)",
        "unautorespawn|unautorespawn (unautore,unarespawn)",
        "guidelete|guidelete (gdel,guidel)",
        "unguidelete|unguidelete (noguidelete,ungdel,unguidel)",
        "deleteselectedtool|deleteselectedtool (dst,dstool,delstool)",
        "removespecifictool|removespecifictool <name> (rstool,rsptool,rmsptool)",
        "unremovespecifictool|unremovespecifictool <name> (unrstool,unrsptool,unrmsptool)",
        "clearremovespecifictool|clearremovespecifictool (clrrstool,clearrstool,crstool)",
        "propertychanged|propertychanged <path> <property> <command> [args]",
        "unpropertychanged|unpropertychanged [path] [property]",
        "loop|loop [delay] <command> [args]", "unloop|unloop",
        "repeat|repeat [amount] [delay] <command> [args]",
        "freezeunanchored|freezeunanchored (freezeua,fua)",
        "thawunanchored|thawunanchored (thawua,unfreezeua,tua)",
        "renderstreamedregions|renderstreamedregions [on/off]",
        "unrenderstreamedregions|unrenderstreamedregions",
        "joinbreakdown|joinbreakdown [on/off]",
        "unjoinbreakdown|unjoinbreakdown",
        "streamquota|streamquota [on/off]", "unstreamquota|unstreamquota",
        "animationassetdata|animationassetdata [on/off]",
        "unanimationassetdata|unanimationassetdata",
        "randomizejoinorder|randomizejoinorder [on/off]",
        "unrandomizejoinorder|unrandomizejoinorder",
        "physallowsleep|physallowsleep [on/off]",
        "unphysallowsleep|unphysallowsleep",
        "physanchors|physanchors [on/off]", "unphysanchors|unphysanchors",
        "physassemblies|physassemblies [on/off]",
        "unphysassemblies|unphysassemblies",
        "physbodytypes|physbodytypes [on/off]",
        "unphysbodytypes|unphysbodytypes",
        "collisioncosts|collisioncosts [on/off]",
        "uncollisioncosts|uncollisioncosts",
        "jointcoords|jointcoords [on/off]", "unjointcoords|unjointcoords",
        "physowners|physowners [on/off]", "unphysowners|unphysowners",
        "physregions|physregions [on/off]", "unphysregions|unphysregions",
        "awakeparts|awakeparts [on/off]", "unawakeparts|unawakeparts",
        "contactpoints|contactpoints [on/off]",
        "uncontactpoints|uncontactpoints",
        "mechanismsshown|mechanismsshown [on/off]",
        "unmechanismsshown|unmechanismsshown",
        "unalignedparts|unalignedparts [on/off]",
        "ununalignedparts|ununalignedparts",
        "receiveage|receiveage [on/off]", "unreceiveage|unreceiveage",
        "interpolationthrottle|interpolationthrottle [on/off]",
        "uninterpolationthrottle|uninterpolationthrottle",
        "phystree|phystree [on/off]", "unphystree|unphystree",
        "decompositiongeometry|decompositiongeometry [on/off]",
        "undecompositiongeometry|undecompositiongeometry",
        "drawcontactsforce|drawcontactsforce [on/off]",
        "undrawcontactsforce|undrawcontactsforce",
        "drawconstraintsforce|drawconstraintsforce [on/off]",
        "undrawconstraintsforce|undrawconstraintsforce",
        "drawtotalforce|drawtotalforce [on/off]",
        "undrawtotalforce|undrawtotalforce",
        "forceinstancenames|forceinstancenames [on/off]",
        "unforceinstancenames|unforceinstancenames",
        "renderboundingboxes|renderboundingboxes [on/off]",
        "unrenderboundingboxes|unrenderboundingboxes",
        "rendercsgtriangles|rendercsgtriangles [on/off]",
        "unrendercsgtriangles|unrendercsgtriangles",
        "renderfrm|renderfrm [on/off]", "unrenderfrm|unrenderfrm",
        "eagerbulkexecution|eagerbulkexecution [on/off]",
        "uneagerbulkexecution|uneagerbulkexecution",
        "exportmergebymaterial|exportmergebymaterial [on/off]",
        "unexportmergebymaterial|unexportmergebymaterial",
        "soundwarnings|soundwarnings [on/off]",
        "unsoundwarnings|unsoundwarnings",
        "videocapture|videocapture [on/off]",
        "unvideocapture|unvideocapture",
        "forcedrawscale|forcedrawscale <number>",
        "torquedrawscale|torquedrawscale <number>",
        "fluidforcedrawscale|fluidforcedrawscale <number>",
        "forcesmoothingsteps|forcesmoothingsteps <0-100>",
        "throttleadjusttime|throttleadjusttime <seconds>",
        "renderautofrm|renderautofrm <number>",
        "meshcachesize|meshcachesize <number>",
    }

    for _, line in ipairs(fallbackLines) do
        local parts = string.split(line, "|")
        local usage
        local patched = false

        if #parts >= 3 and parts[2] == "PATCHED" then
            patched = true
            usage = parts[3]
            -- Trim leading space if present
            usage = string.match(usage, "^%s*(.-)%s*$") or usage
        elseif #parts >= 2 then
            usage = parts[2]
        else
            usage = parts[1]
        end

        if usage and usage ~= "" then
            table.insert(allCommands, {
                usage = usage,
                patched = patched
            })
        end
    end

    -- Add the two patched commands from the file that aren't in JSON format
    table.insert(allCommands, {usage = "breaklayeredclothing (blc)", patched = true})
    table.insert(allCommands, {usage = "reserveserver [code/link] [instanceId] | reserveserver debug [placeId] [seed]", patched = true})

    -- Sort
    table.sort(allCommands, function(a, b)
        if a.patched ~= b.patched then
            return not a.patched
        end
        return a.usage < b.usage
    end)

    RefreshList()
end

-- Initialize
task.spawn(function()
    local success, err = pcall(FetchCommands)
    if not success then
        warn("[NAPanel] Error: " .. tostring(err))
        LoadFallbackData()
    end
end)
