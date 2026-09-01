pcall(function()

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
local TeleportService = game:GetService("TeleportService")
local SoundService = game:GetService("SoundService")
local TextChatService = game:GetService("TextChatService")

local Plr = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local loops = {}
local espList = {}
local chamsList = {}
local xrayData = {}
local wsData = {}
local antiFlags = {}

local function InstanceNew(class, props)
	local inst
	local ok = pcall(function() inst = Instance.new(class) end)
	if not ok then return nil end
	if props then
		for k, v in pairs(props) do
			pcall(function() inst[k] = v end)
		end
	end
	return inst
end

local function Lower(s) return s:lower() end
local function Sub(s, a, b) return s:sub(a, b) end
local function Find(s, p) return s:find(p) end
local function Format(n, p) return string.format(p or "%g", n) end
local function GSub(s, p, r) return s:gsub(p, r) end
local function Spawn(f) task.spawn(f) end
local function Defer(f) task.defer(f) end
local function Wait(n) return task.wait(n or 0.1) end

local function getChar()
	return Plr.Character or Plr.CharacterAdded:Wait()
end

local function getHum()
	local c = getChar()
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
	local c = getChar()
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHead()
	local c = getChar()
	return c and c:FindFirstChild("Head")
end

local function getBp()
	return Plr:FindFirstChildOfClass("Backpack")
end

local function getPlr(name)
	if not name or name == "" then return Plr end
	name = Lower(name)
	for _, p in pairs(Players:GetPlayers()) do
		if Lower(p.Name):sub(1, #name) == name or Lower(p.DisplayName):sub(1, #name) == name then
			return p
		end
	end
	return nil
end

local function DoNotif(text, dur)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Custom Commands",
			Text = tostring(text),
			Duration = dur or 3
		})
	end)
end

pcall(function()
	local old
	old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		local method = getnamecallmethod()
		if method == "Kick" and self == Plr and antiFlags.antikick then
			DoNotif("Anti-kick: Blocked!")
			return nil
		end
		if (method == "Teleport" or method == "TeleportToPlaceInstance") and self == TeleportService and antiFlags.antiteleport then
			DoNotif("Anti-teleport: Blocked!")
			return nil
		end
		return old(self, ...)
	end))
end)

local Cmds = {}
local CmdsList = {}
local cmd = {}

function cmd.add(name, desc, func)
	local n = Lower(name)
	Cmds[n] = func
	CmdsList[n] = desc or name
end

function cmd.addArg(name, desc, func)
	local n = Lower(name)
	Cmds[n] = func
	CmdsList[n] = desc or name
end

function cmd.run(input)
	input = input:match("^%s*(.-)%s*$")
	local space = input:find(" ")
	local name, arg
	if space then
		name = input:sub(1, space - 1)
		arg = input:sub(space + 1)
	else
		name = input
		arg = ""
	end
	local n = Lower(name)
	if Cmds[n] then
		if arg ~= "" then
			pcall(function() Cmds[n](arg) end)
		else
			pcall(function() Cmds[n]() end)
		end
	else
		DoNotif("Unknown: " .. name)
	end
end

cmd.add("antikick", "Bypass Kick on Most Games", function()
	antiFlags.antikick = true
	DoNotif("Anti-kick enabled")
end)

cmd.add("antiteleport", "Prevents TeleportService from moving you", function()
	antiFlags.antiteleport = true
	DoNotif("Anti-teleport enabled")
end)

cmd.add("antivoid", "Prevents you from falling into the void", function()
	if loops.antivoid then return DoNotif("Already enabled") end
	loops.antivoid = RunService.Heartbeat:Connect(function()
		local hrp = getRoot()
		if hrp and hrp.Position.Y < -50 then
			hrp.Velocity = Vector3.new(0, 100, 0)
			hrp.CFrame = CFrame.new(hrp.Position.X, 10, hrp.Position.Z)
		end
	end)
	DoNotif("Anti-void enabled")
end)

cmd.add("antiafk", "Prevents you from being kicked for being AFK", function()
	if loops.antiafk then return DoNotif("Already enabled") end
	loops.antiafk = Spawn(function()
		while true do
			Wait(60)
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:Button2Down(Vector2.new(0, 0), Camera.CFrame)
				vu:Button2Up(Vector2.new(0, 0), Camera.CFrame)
			end)
		end
	end)
	DoNotif("Anti-AFK enabled")
end)

cmd.add("antiknockback", "Disables knockback", function()
	if loops.antiknockback then return DoNotif("Already enabled") end
	loops.antiknockback = RunService.Heartbeat:Connect(function()
		local hrp = getRoot()
		if hrp then
			hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
		end
	end)
	DoNotif("Anti-knockback enabled")
end)

cmd.add("antitouch", "Disables touchable parts on character", function()
	if loops.antitouch then return DoNotif("Already enabled") end
	loops.antitouch = RunService.Heartbeat:Connect(function()
		local char = getChar()
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanTouch = false
				end
			end
		end
	end)
	DoNotif("Anti-touch enabled")
end)

cmd.add("antifling", "Makes other players non-collidable with you", function()
	if loops.antifling then return DoNotif("Already enabled") end
	loops.antifling = RunService.Heartbeat:Connect(function()
		local char = getChar()
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
	DoNotif("Anti-fling enabled")
end)

cmd.add("unantifling", "Restores collision for other players", function()
	if loops.antifling then
		loops.antifling:Disconnect()
		loops.antifling = nil
	end
	DoNotif("Anti-fling disabled")
end)

cmd.add("antivoid2", "Sets FallenPartsDestroyHeight to -inf", function()
	Workspace.FallenPartsDestroyHeight = -math.huge
	DoNotif("FallenPartsDestroyHeight set to -inf")
end)

cmd.add("unantivoid2", "Reverts FallenPartsDestroyHeight", function()
	Workspace.FallenPartsDestroyHeight = -500
	DoNotif("FallenPartsDestroyHeight reverted")
end)

cmd.add("freeze", "Freezes your character", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	hrp.Anchored = true
	DoNotif("Character frozen")
end)

cmd.add("unfreeze", "Unfreezes your character", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	hrp.Anchored = false
	DoNotif("Character unfrozen")
end)

cmd.add("fly", "Enable flight", function()
	local hrp = getRoot()
	local hum = getHum()
	if not hrp or not hum then return DoNotif("No character") end
	if loops.fly then
		loops.fly:Disconnect()
		loops.fly = nil
		for _, v in pairs(hrp:GetChildren()) do
			if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
				v:Destroy()
			end
		end
		hum.PlatformStand = false
		DoNotif("Flight disabled")
		return
	end
	local bv = InstanceNew("BodyVelocity", {
		Parent = hrp,
		MaxForce = Vector3.new(math.huge, math.huge, math.huge),
		Velocity = Vector3.new(0, 0, 0),
		P = 10000
	})
	local bg = InstanceNew("BodyGyro", {
		Parent = hrp,
		MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
		P = 10000,
		D = 500
	})
	local flySpeed = 60
	hum.PlatformStand = true
	loops.fly = RunService.RenderStepped:Connect(function()
		if not hrp or not hrp.Parent then
			loops.fly:Disconnect()
			loops.fly = nil
			return
		end
		local camCF = Camera.CFrame
		local dir = Vector3.new(0, 0, 0)
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.RightShift) then dir = dir - Vector3.new(0, 1, 0) end
		if dir.Magnitude > 0 then
			bv.Velocity = dir.Unit * flySpeed
		else
			bv.Velocity = Vector3.new(0, 0, 0)
		end
		bg.CFrame = camCF
	end)
	DoNotif("Flight enabled (WASD+Space/RightShift)")
end)

cmd.add("unfly", "Disable flight", function()
	local hrp = getRoot()
	local hum = getHum()
	if loops.fly then
		loops.fly:Disconnect()
		loops.fly = nil
	end
	if hrp then
		for _, v in pairs(hrp:GetChildren()) do
			if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
				v:Destroy()
			end
		end
	end
	if hum then hum.PlatformStand = false end
	DoNotif("Flight disabled")
end)

cmd.addArg("speed", "Sets your WalkSpeed [value]", function(val)
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	local n = tonumber(val)
	if not n then return DoNotif("Invalid number") end
	hum.WalkSpeed = n
	DoNotif("WalkSpeed set to " .. n)
end)

cmd.addArg("jumppower", "Sets your JumpPower [value]", function(val)
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	local n = tonumber(val)
	if not n then return DoNotif("Invalid number") end
	hum.JumpPower = n
	DoNotif("JumpPower set to " .. n)
end)

cmd.addArg("hipheight", "Changes your HipHeight [value]", function(val)
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	local n = tonumber(val)
	if not n then return DoNotif("Invalid number") end
	hum.HipHeight = n
	DoNotif("HipHeight set to " .. n)
end)

cmd.addArg("gravity", "Sets game gravity [value]", function(val)
	local n = tonumber(val)
	if not n then return DoNotif("Invalid number") end
	Workspace.Gravity = n
	DoNotif("Gravity set to " .. n)
end)

cmd.add("noclip", "Disable your player collision", function()
	if loops.noclip then return DoNotif("Already enabled") end
	loops.noclip = RunService.Stepped:Connect(function()
		local char = getChar()
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end
	end)
	DoNotif("Noclip enabled")
end)

cmd.add("clip", "Enable your player collision", function()
	if loops.noclip then
		loops.noclip:Disconnect()
		loops.noclip = nil
	end
	DoNotif("Noclip disabled")
end)

cmd.add("infjump", "Enables infinite jumping", function()
	if loops.infjump then
		loops.infjump:Disconnect()
		loops.infjump = nil
		DoNotif("Infjump disabled")
		return
	end
	loops.infjump = Plr.CharacterAdded:Connect(function(char)
		Wait(0.5)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
	local hum = getHum()
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
	DoNotif("Infjump enabled")
end)

cmd.add("swim", "Swim in the air", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum:ChangeState(Enum.HumanoidStateType.Swimming)
	if loops.swim then return end
	loops.swim = RunService.Heartbeat:Connect(function()
		local h = getHum()
		if h then h:ChangeState(Enum.HumanoidStateType.Swimming) end
	end)
	DoNotif("Swim enabled")
end)

cmd.add("unswim", "Stops the swim script", function()
	if loops.swim then
		loops.swim:Disconnect()
		loops.swim = nil
	end
	local hum = getHum()
	if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
	DoNotif("Swim disabled")
end)

cmd.add("climb", "Allows you to climb while in air", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum:ChangeState(Enum.HumanoidStateType.Climbing)
	if loops.climb then return end
	loops.climb = RunService.Heartbeat:Connect(function()
		local h = getHum()
		if h then h:ChangeState(Enum.HumanoidStateType.Climbing) end
	end)
	DoNotif("Climb enabled")
end)

cmd.add("unclimb", "Disables climb", function()
	if loops.climb then
		loops.climb:Disconnect()
		loops.climb = nil
	end
	local hum = getHum()
	if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
	DoNotif("Climb disabled")
end)

cmd.add("spin", "Makes your character spin", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	if loops.spin then return DoNotif("Already enabled") end
	local av = InstanceNew("AngularVelocity", {
		Parent = hrp,
		MaxTorque = math.huge,
		AngularVelocity = Vector3.new(0, 20, 0)
	})
	loops.spin = av
	DoNotif("Spin enabled")
end)

cmd.add("unspin", "Makes your character unspin", function()
	if loops.spin then
		if loops.spin.Parent then loops.spin:Destroy() end
		loops.spin = nil
	end
	DoNotif("Spin disabled")
end)

cmd.addArg("tpup", "Teleports you up [studs]", function(val)
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local n = tonumber(val) or 10
	hrp.CFrame = hrp.CFrame + Vector3.new(0, n, 0)
	DoNotif("Teleported up " .. n .. " studs")
end)

cmd.addArg("tpdown", "Teleports you down [studs]", function(val)
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local n = tonumber(val) or 10
	hrp.CFrame = hrp.CFrame - Vector3.new(0, n, 0)
	DoNotif("Teleported down " .. n .. " studs")
end)

cmd.add("tpworkspace", "Teleports you to workspace center", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	hrp.CFrame = CFrame.new(0, 50, 0)
	DoNotif("Teleported to workspace")
end)

cmd.add("breakvelocity", "Sets your characters velocity to zero", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	hrp.Velocity = Vector3.new(0, 0, 0)
	hrp.RotVelocity = Vector3.new(0, 0, 0)
	DoNotif("Velocity broken")
end)

cmd.addArg("tp", "Teleport to player [name]", function(val)
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local target = getPlr(val)
	if not target then return DoNotif("Player not found") end
	local char = target.Character
	if not char then return DoNotif("Target has no character") end
	local thrp = char:FindFirstChild("HumanoidRootPart")
	if not thrp then return DoNotif("Target has no root") end
	hrp.CFrame = thrp.CFrame
	DoNotif("Teleported to " .. target.Name)
end)

cmd.addArg("goto", "Teleport to the given player [name]", function(val)
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local target = getPlr(val)
	if not target then return DoNotif("Player not found") end
	local char = target.Character
	if not char then return DoNotif("Target has no character") end
	local thrp = char:FindFirstChild("HumanoidRootPart")
	if not thrp then return DoNotif("Target has no root") end
	hrp.CFrame = thrp.CFrame
	DoNotif("Teleported to " .. target.Name)
end)

cmd.addArg("bring", "Teleport a player to you [name]", function(val)
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local target = getPlr(val)
	if not target then return DoNotif("Player not found") end
	local char = target.Character
	if not char then return DoNotif("Target has no character") end
	local thrp = char:FindFirstChild("HumanoidRootPart")
	if not thrp then return DoNotif("Target has no root") end
	thrp.CFrame = hrp.CFrame
	DoNotif("Brought " .. target.Name)
end)

cmd.addArg("cbring", "Brings the player once on your client [name]", function(val)
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local target = getPlr(val)
	if not target then return DoNotif("Player not found") end
	local char = target.Character
	if not char then return DoNotif("Target has no character") end
	local thrp = char:FindFirstChild("HumanoidRootPart")
	if not thrp then return DoNotif("Target has no root") end
	thrp.CFrame = hrp.CFrame
	DoNotif("Client brought " .. target.Name)
end)

cmd.addArg("follow", "Follow a player wherever they go [name]", function(val)
	if loops.follow then
		loops.follow:Disconnect()
		loops.follow = nil
	end
	local target = getPlr(val)
	if not target then return DoNotif("Player not found") end
	loops.follow = RunService.Heartbeat:Connect(function()
		local hrp = getRoot()
		local char = target.Character
		if not hrp or not char then return end
		local thrp = char:FindFirstChild("HumanoidRootPart")
		if not thrp then return end
		hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 5)
	end)
	DoNotif("Following " .. target.Name)
end)

cmd.add("unfollow", "Stop all attempts to follow a player", function()
	if loops.follow then
		loops.follow:Disconnect()
		loops.follow = nil
	end
	DoNotif("Follow stopped")
end)

cmd.addArg("glue", "Loop teleport to a player [name]", function(val)
	if loops.glue then
		loops.glue:Disconnect()
		loops.glue = nil
	end
	local target = getPlr(val)
	if not target then return DoNotif("Player not found") end
	loops.glue = RunService.Heartbeat:Connect(function()
		local hrp = getRoot()
		local char = target.Character
		if not hrp or not char then return end
		local thrp = char:FindFirstChild("HumanoidRootPart")
		if not thrp then return end
		hrp.CFrame = thrp.CFrame
	end)
	DoNotif("Glued to " .. target.Name)
end)

cmd.add("unglue", "Stops teleporting you to a player", function()
	if loops.glue then
		loops.glue:Disconnect()
		loops.glue = nil
	end
	DoNotif("Glue stopped")
end)

cmd.add("tospawn", "Teleports you to a SpawnLocation", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("SpawnLocation") then
			hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
			DoNotif("Teleported to spawn")
			return
		end
	end
	DoNotif("No spawn found")
end)

cmd.add("god", "Enable invincibility", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.MaxHealth = math.huge
	hum.Health = math.huge
	DoNotif("God mode enabled")
end)

cmd.add("heal", "Heals your character", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.Health = hum.MaxHealth
	DoNotif("Healed")
end)

cmd.add("kill", "Kills your character", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.Health = 0
	DoNotif("Killed")
end)

cmd.add("fling", "Fling the given player", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local av = InstanceNew("AngularVelocity", {
		Parent = hrp,
		MaxTorque = math.huge,
		AngularVelocity = Vector3.new(0, 50000, 0)
	})
	Spawn(function()
		Wait(0.3)
		if av and av.Parent then av:Destroy() end
	end)
	DoNotif("Fling activated")
end)

cmd.add("boxreach", "Creates a box-shaped hitbox around your tool", function()
	local char = getChar()
	if not char then return DoNotif("No character") end
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return DoNotif("No tool equipped") end
	local handle = tool:FindFirstChild("Handle")
	if not handle then return DoNotif("No handle") end
	local box = InstanceNew("Part", {
		Parent = tool,
		Name = "BoxReach",
		Size = Vector3.new(10, 10, 10),
		Transparency = 1,
		Anchored = false,
		CanCollide = false
	})
	InstanceNew("Weld", {
		Parent = box,
		Part0 = handle,
		Part1 = box,
		C0 = CFrame.new(0, 0, -5)
	})
	DoNotif("Box reach enabled")
end)

cmd.add("resetreach", "Resets tool to normal size", function()
	local char = getChar()
	if not char then return end
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return end
	local box = tool:FindFirstChild("BoxReach")
	if box then box:Destroy() end
	DoNotif("Reach reset")
end)

cmd.add("esp", "Locate where the players are", function()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= Plr and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp and not espList[p] then
				local bb = InstanceNew("BillboardGui", {
					Parent = hrp,
					Name = "CCEsp",
					Size = UDim2.new(0, 100, 0, 40),
					StudsOffset = Vector3.new(0, 3, 0),
					Adornee = hrp,
					AlwaysOnTop = true
				})
				InstanceNew("TextLabel", {
					Parent = bb,
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundTransparency = 1,
					Text = p.Name,
					TextColor3 = Color3.new(1, 1, 1),
					TextStrokeTransparency = 0.5,
					TextScaled = true,
					Font = Enum.Font.GothamBold
				})
				espList[p] = bb
			end
		end
	end
	DoNotif("ESP enabled")
end)

cmd.add("unesp", "Disables esp", function()
	for p, bb in pairs(espList) do
		if bb and bb.Parent then bb:Destroy() end
		espList[p] = nil
	end
	espList = {}
	DoNotif("ESP disabled")
end)

cmd.add("chams", "ESP but without the text", function()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= Plr and p.Character then
			if not chamsList[p] then
				local highlights = {}
				for _, part in pairs(p.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						local hl = InstanceNew("Highlight", {
							Parent = part,
							Adornee = part,
							FillColor = Color3.fromRGB(255, 0, 0),
							OutlineColor = Color3.fromRGB(255, 255, 255),
							FillTransparency = 0.5,
							OutlineTransparency = 0,
							DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						})
						table.insert(highlights, hl)
					end
				end
				chamsList[p] = highlights
			end
		end
	end
	DoNotif("Chams enabled")
end)

cmd.add("unchams", "Disables chams", function()
	for p, hls in pairs(chamsList) do
		for _, hl in pairs(hls) do
			if hl and hl.Parent then hl:Destroy() end
		end
		chamsList[p] = nil
	end
	chamsList = {}
	DoNotif("Chams disabled")
end)

cmd.add("ff", "Gives you a ForceField", function()
	local char = getChar()
	if not char then return DoNotif("No character") end
	InstanceNew("ForceField", {Parent = char})
	DoNotif("ForceField added")
end)

cmd.add("noff", "Removes your ForceField", function()
	local char = getChar()
	if not char then return end
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("ForceField") then v:Destroy() end
	end
	DoNotif("ForceField removed")
end)

cmd.add("fullbright", "Makes dark games bright without destroying effects", function()
	Lighting.Brightness = 2
	Lighting.ClockTime = 14
	Lighting.FogEnd = 100000
	Lighting.GlobalShadows = false
	Lighting.Ambient = Color3.fromRGB(178, 178, 178)
	DoNotif("Fullbright enabled")
end)

cmd.add("nofog", "Removes all fog from the game", function()
	Lighting.FogEnd = 100000
	Lighting.FogStart = 0
	DoNotif("Fog removed")
end)

cmd.add("noeffect", "Disables Lighting and CurrentCamera effects", function()
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("PostEffect") then
			v.Enabled = false
		end
	end
	DoNotif("Effects disabled")
end)

cmd.add("day", "Makes it day", function()
	Lighting.ClockTime = 14
	DoNotif("Time set to day")
end)

cmd.add("night", "Makes it night", function()
	Lighting.ClockTime = 0
	DoNotif("Time set to night")
end)

cmd.addArg("brightness", "Changes the brightness [value]", function(val)
	local n = tonumber(val)
	if not n then return DoNotif("Invalid number") end
	Lighting.Brightness = n
	DoNotif("Brightness set to " .. n)
end)

cmd.addArg("time", "Sets the time [0-24]", function(val)
	local n = tonumber(val)
	if not n then return DoNotif("Invalid number") end
	Lighting.ClockTime = n
	DoNotif("Time set to " .. n)
end)

cmd.addArg("fov", "Sets your FOV [value]", function(val)
	local n = tonumber(val)
	if not n then return DoNotif("Invalid number") end
	Camera.FieldOfView = n
	DoNotif("FOV set to " .. n)
end)

cmd.add("globalshadows", "Enables global shadows", function()
	Lighting.GlobalShadows = true
	DoNotif("Global shadows enabled")
end)

cmd.add("invisible", "Sets invisibility", function()
	local char = getChar()
	if not char then return DoNotif("No character") end
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
		elseif v:IsA("Decal") then
			v.Transparency = 1
		end
	end
	local hum = getHum()
	if hum then
		for _, v in pairs(hum:GetAccessories()) do
			if v:IsA("Accessory") then
				local handle = v:FindFirstChild("Handle")
				if handle then handle.Transparency = 1 end
			end
		end
	end
	DoNotif("Invisible")
end)

cmd.add("visible", "Makes you visible again", function()
	local char = getChar()
	if not char then return DoNotif("No character") end
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			if v.Name == "HumanoidRootPart" then
				v.Transparency = 1
			else
				v.Transparency = 0
			end
		elseif v:IsA("Decal") then
			v.Transparency = 0
		end
	end
	DoNotif("Visible")
end)

cmd.add("sit", "Sit your player", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.Sit = true
	DoNotif("Sitting")
end)

cmd.add("unsit", "Unsit your player", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.Sit = false
	DoNotif("Standing")
end)

cmd.add("jump", "Jump", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)

cmd.add("reset", "Makes your health be 0", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.Health = 0
end)

cmd.add("respawn", "Respawn your character", function()
	pcall(function()
		Plr:LoadCharacter()
	end)
	DoNotif("Respawning")
end)

cmd.add("breakjoints", "Break your character joints", function()
	local char = getChar()
	if not char then return DoNotif("No character") end
	char:BreakJoints()
	DoNotif("Joints broken")
end)

cmd.addArg("material", "Sets every BasePart in your character to a material [name]", function(val)
	local char = getChar()
	if not char then return DoNotif("No character") end
	local mat = Enum.Material[val] or Enum.Material.SmoothPlastic
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Material = mat
		end
	end
	DoNotif("Material set to " .. val)
end)

cmd.add("stopanimations", "Stops running animations", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	local animator = hum:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in pairs(animator:GetPlayingAnimationTracks()) do
			track:Stop(0)
		end
	end
	DoNotif("Animations stopped")
end)

cmd.add("btools", "Gives Building Tools", function()
	local bp = getBp()
	if not bp then return DoNotif("No backpack") end
	for _, name in pairs({"F3X", "Building Tools"}) do
		pcall(function()
			local tool = InstanceNew("Tool", {
				Parent = bp,
				Name = name,
				CanBeDropped = false
			})
			InstanceNew("Part", {Parent = tool, Name = "Handle"})
		end)
	end
	DoNotif("Building tools given")
end)

cmd.add("droptool", "Drop one of your tools", function()
	local char = getChar()
	if not char then return end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then
		tool.Parent = Workspace
		DoNotif("Tool dropped")
	else
		DoNotif("No tool equipped")
	end
end)

cmd.add("droptools", "Drop all of your tools", function()
	local char = getChar()
	if not char then return end
	local bp = getBp()
	if bp then
		for _, tool in pairs(bp:GetChildren()) do
			if tool:IsA("Tool") then
				tool.Parent = Workspace
			end
		end
	end
	for _, tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			tool.Parent = Workspace
		end
	end
	DoNotif("Tools dropped")
end)

cmd.add("equiptools", "Equips every tool in your inventory", function()
	local bp = getBp()
	if not bp then return end
	for _, tool in pairs(bp:GetChildren()) do
		if tool:IsA("Tool") then
			tool.Parent = getChar()
		end
	end
	DoNotif("Tools equipped")
end)

cmd.add("unequiptools", "Unequips every tool you are holding", function()
	local char = getChar()
	local bp = getBp()
	if not char or not bp then return end
	for _, tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			tool.Parent = bp
		end
	end
	DoNotif("Tools unequipped")
end)

cmd.add("grabtools", "Grabs dropped tools", function()
	local bp = getBp()
	local char = getChar()
	if not bp or not char then return end
	local hrp = getRoot()
	if not hrp then return end
	local count = 0
	for _, v in pairs(Workspace:GetChildren()) do
		if v:IsA("Tool") then
			local handle = v:FindFirstChild("Handle")
			if handle then
				local dist = (handle.Position - hrp.Position).Magnitude
				if dist < 20 then
					v.Parent = bp
					count = count + 1
				end
			end
		end
	end
	DoNotif("Grabbed " .. count .. " tools")
end)

cmd.add("naked", "Removes clothing", function()
	local char = getChar()
	if not char then return end
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
			v:Destroy()
		end
	end
	DoNotif("Clothing removed")
end)

cmd.add("players", "Lists all players in server", function()
	local list = ""
	for _, p in pairs(Players:GetPlayers()) do
		list = list .. p.Name .. (p == Plr and " (you)" or "") .. "\n"
	end
	DoNotif(list, 10)
end)

cmd.add("fps", "Shows your frames per second", function()
	local fps = math.floor(1 / RunService.RenderStepped:Wait())
	DoNotif("FPS: " .. fps)
end)

cmd.add("ping", "Shows your network latency", function()
	local ping = math.floor(Plr:GetNetworkPing() * 1000)
	DoNotif("Ping: " .. ping .. "ms")
end)

cmd.add("pos", "Shows your current position", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local p = hrp.Position
	DoNotif("Pos: " .. math.floor(p.X) .. ", " .. math.floor(p.Y) .. ", " .. math.floor(p.Z))
end)

cmd.add("memory", "Shows your current memory usage", function()
	local mem = math.floor(collectgarbage("count") / 1024)
	DoNotif("Memory: " .. mem .. " MB")
end)

cmd.addArg("chat", "Chats a message [text]", function(val)
	pcall(function()
		game:GetService("TextChatService"):Chat(val, Enum.TextChatMessageTextSourceConfiguration.TextSource)
	end)
	pcall(function()
		game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer(val, "All")
	end)
	DoNotif("Chatted: " .. val)
end)

cmd.add("noclickdetectorlimits", "Sets all click detectors MaxActivationDistance to huge", function()
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			v.MaxActivationDistance = math.huge
			count = count + 1
		end
	end
	DoNotif("Modified " .. count .. " ClickDetectors")
end)

cmd.add("fireclickdetectors", "Fires every ClickDetector in Workspace", function()
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			pcall(function() v.MouseClickFire:Fire() end)
			count = count + 1
		end
	end
	DoNotif("Fired " .. count .. " ClickDetectors")
end)

cmd.add("fireproximityprompts", "Fires every ProximityPrompt in Workspace", function()
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			pcall(function() v:InputHoldBegin() end)
			pcall(function() v:InputHoldEnd() end)
			count = count + 1
		end
	end
	DoNotif("Fired " .. count .. " ProximityPrompts")
end)

cmd.add("removeads", "Removes billboard advertisements", function()
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("BillboardGui") and v.Name:lower():find("ad") then
			v:Destroy()
			count = count + 1
		end
	end
	DoNotif("Removed " .. count .. " ads")
end)

cmd.add("notepad", "Opens a notepad", function()
	local gui = InstanceNew("ScreenGui", {Parent = CG, Name = "CCNotepad"})
	local frame = InstanceNew("Frame", {
		Parent = gui,
		Size = UDim2.new(0, 400, 0, 300),
		Position = UDim2.new(0.5, -200, 0.5, -150),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel = 0
	})
	InstanceNew("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 8)})
	local close = InstanceNew("TextButton", {
		Parent = frame,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 5),
		BackgroundColor3 = Color3.fromRGB(200, 50, 50),
		Text = "X",
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		BorderSizePixel = 0
	})
	InstanceNew("UICorner", {Parent = close, CornerRadius = UDim.new(0, 4)})
	close.MouseButton1Click:Connect(function() gui:Destroy() end)
	InstanceNew("TextBox", {
		Parent = frame,
		Size = UDim2.new(1, -20, 1, -50),
		Position = UDim2.new(0, 10, 0, 40),
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		MultiLine = true,
		ClearTextOnFocus = false,
		Text = "",
		Font = Enum.Font.Code,
		TextSize = 14,
		BorderSizePixel = 0
	})
	InstanceNew("UICorner", {Parent = frame, CornerRadius = UDim.new(0, 8)})
	DoNotif("Notepad opened")
end)

cmd.add("clear", "Clears output", function()
	pcall(function() print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n") end)
	DoNotif("Cleared")
end)

cmd.add("noremote", "Blocks remote firing", function()
	if loops.noremote then return DoNotif("Already enabled") end
	pcall(function()
		local old
		old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			if loops.noremote and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
				DoNotif("Blocked remote: " .. self.Name)
				return nil
			end
			return old(self, ...)
		end))
		loops.noremote = true
	end)
	DoNotif("Remote blocking enabled")
end)

cmd.add("rejoin", "Rejoin the game", function()
	pcall(function()
		game:GetService("TeleportService"):Teleport(game.PlaceId, Plr)
	end)
	DoNotif("Rejoining")
end)

cmd.add("serverhop", "Server hop", function()
	pcall(function()
		local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
		if servers and servers.data then
			for _, s in pairs(servers.data) do
				if s.id ~= game.JobId and s.playing < s.maxPlayers then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Plr)
					DoNotif("Hopping to server")
					return
				end
			end
		end
		DoNotif("No servers found")
	end)
end)

cmd.add("gameid", "Copies the GameId", function()
	pcall(function()
		setclipboard(tostring(game.GameId))
	end)
	DoNotif("GameId copied: " .. game.GameId)
end)

cmd.add("placeid", "Copies the PlaceId", function()
	pcall(function()
		setclipboard(tostring(game.PlaceId))
	end)
	DoNotif("PlaceId copied: " .. game.PlaceId)
end)

cmd.add("jobid", "Copies your job id", function()
	pcall(function()
		setclipboard(tostring(game.JobId))
	end)
	DoNotif("JobId copied: " .. game.JobId)
end)

cmd.add("copyname", "Copies the username of the target", function()
	pcall(function()
		setclipboard(Plr.Name)
	end)
	DoNotif("Name copied: " .. Plr.Name)
end)

cmd.add("copyid", "Copies the UserId of the target", function()
	pcall(function()
		setclipboard(tostring(Plr.UserId))
	end)
	DoNotif("UserId copied: " .. Plr.UserId)
end)

cmd.add("copyposition", "Get the position of the player", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local p = hrp.Position
	local str = tostring(math.floor(p.X)) .. ", " .. tostring(math.floor(p.Y)) .. ", " .. tostring(math.floor(p.Z))
	pcall(function() setclipboard(str) end)
	DoNotif("Position copied: " .. str)
end)

cmd.add("gethealth", "Shows your current health", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	DoNotif("Health: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth))
end)

cmd.add("getmass", "Get your mass", function()
	local char = getChar()
	if not char then return DoNotif("No character") end
	local mass = 0
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			mass = mass + v:GetMass()
		end
	end
	DoNotif("Mass: " .. math.floor(mass * 100) / 100)
end)

cmd.add("console", "Opens developer console", function()
	StarterGui:SetCore("DevConsoleVisible", true)
	DoNotif("Console opened")
end)

cmd.add("shiftlock", "Toggles shiftlock", function()
	pcall(function()
		local sets = Plr:FindFirstChild("PlayerGui"):FindFirstChild("MouseLockController")
		if sets then
			sets.Enabled = not sets.Enabled
		end
	end)
	DoNotif("Shift lock toggled")
end)

cmd.add("firstp", "Makes you go in first person", function()
	Camera.CameraType = Enum.CameraType.Custom
	Plr.CameraMaxZoomDistance = 0.5
	DoNotif("First person mode")
end)

cmd.add("thirdp", "Makes you go in third person", function()
	Plr.CameraMinZoomDistance = 0.5
	Plr.CameraMaxZoomDistance = 128
	DoNotif("Third person mode")
end)

cmd.add("setspawn", "Sets your spawn point", function()
	local hrp = getRoot()
	if not hrp then return DoNotif("No character") end
	local spawn = InstanceNew("SpawnLocation", {
		Parent = Workspace,
		Position = hrp.Position,
		Anchored = true,
		Transparency = 1,
		CanCollide = false,
		Size = Vector3.new(5, 1, 5)
	})
	DoNotif("Spawn set")
end)

cmd.add("walltp", "Toggles wall top teleport", function()
	if loops.walltp then
		loops.walltp:Disconnect()
		loops.walltp = nil
		DoNotif("Wall TP disabled")
		return
	end
	loops.walltp = RunService.Heartbeat:Connect(function()
		local hrp = getRoot()
		if not hrp then return end
		local ray = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 5)
		if ray then
			local top = ray.Position + Vector3.new(0, 5, 0)
			hrp.CFrame = CFrame.new(top)
		end
	end)
	DoNotif("Wall TP enabled")
end)

cmd.add("unwalltp", "Disables wall top teleport", function()
	if loops.walltp then
		loops.walltp:Disconnect()
		loops.walltp = nil
	end
	DoNotif("Wall TP disabled")
end)

cmd.add("xray", "Enables X-ray vision", function()
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency < 1 then
			xrayData[v] = v.Transparency
			v.Transparency = 0.7
		end
	end
	DoNotif("X-ray enabled")
end)

cmd.add("unxray", "Disables X-ray vision", function()
	for v, t in pairs(xrayData) do
		if v and v.Parent then
			v.Transparency = t
		end
	end
	xrayData = {}
	DoNotif("X-ray disabled")
end)

cmd.add("lockws", "Locks the whole workspace", function()
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			wsData[v] = v.Anchored
			v.Anchored = true
		end
	end
	DoNotif("Workspace locked")
end)

cmd.add("unlockws", "Unlocks everything in Workspace", function()
	for v, a in pairs(wsData) do
		if v and v.Parent then
			v.Anchored = a
		end
	end
	wsData = {}
	DoNotif("Workspace unlocked")
end)

cmd.add("removeterrain", "Clears terrain", function()
	Workspace:ClearForStaticObjects()
	DoNotif("Terrain cleared")
end)

cmd.addArg("delete", "Removes any part with a certain name [name]", function(val)
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v.Name == val then
			v:Destroy()
			count = count + 1
		end
	end
	DoNotif("Deleted " .. count .. " parts named " .. val)
end)

cmd.addArg("deletefind", "Removes any part containing text [text]", function(val)
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v.Name:lower():find(val:lower()) then
			v:Destroy()
			count = count + 1
		end
	end
	DoNotif("Deleted " .. count .. " parts")
end)

cmd.addArg("deleteclass", "Removes any part with a classname [class]", function(val)
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA(val) then
			v:Destroy()
			count = count + 1
		end
	end
	DoNotif("Deleted " .. count .. " " .. val .. " instances")
end)

cmd.add("deleteinvisparts", "Deletes invisible parts", function()
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency >= 1 and v.Name ~= "HumanoidRootPart" then
			v:Destroy()
			count = count + 1
		end
	end
	DoNotif("Deleted " .. count .. " invisible parts")
end)

cmd.add("clearnilinstances", "Removes nil instances", function()
	local count = 0
	for _, v in pairs(Workspace:GetChildren()) do
		if v.Parent == nil then
			v:Destroy()
			count = count + 1
		end
	end
	DoNotif("Cleared " .. count .. " nil instances")
end)

cmd.addArg("loopwalkspeed", "Loop walkspeed [value]", function(val)
	local n = tonumber(val)
	if not n then return DoNotif("Invalid number") end
	if loops.loopwalkspeed then loops.loopwalkspeed:Disconnect() end
	loops.loopwalkspeed = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum then hum.WalkSpeed = n end
	end)
	DoNotif("Loop WalkSpeed: " .. n)
end)

cmd.add("unloopwalkspeed", "Disable loop walkspeed", function()
	if loops.loopwalkspeed then
		loops.loopwalkspeed:Disconnect()
		loops.loopwalkspeed = nil
	end
	DoNotif("Loop WalkSpeed disabled")
end)

cmd.addArg("loopjumppower", "Loop JumpPower [value]", function(val)
	local n = tonumber(val)
	if not n then return DoNotif("Invalid number") end
	if loops.loopjumppower then loops.loopjumppower:Disconnect() end
	loops.loopjumppower = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum then hum.JumpPower = n end
	end)
	DoNotif("Loop JumpPower: " .. n)
end)

cmd.add("unloopjumppower", "Disable loop JumpPower", function()
	if loops.loopjumppower then
		loops.loopjumppower:Disconnect()
		loops.loopjumppower = nil
	end
	DoNotif("Loop JumpPower disabled")
end)

cmd.add("loopjump", "Continuously jump", function()
	if loops.loopjump then return DoNotif("Already enabled") end
	loops.loopjump = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
	DoNotif("Loop jump enabled")
end)

cmd.add("unloopjump", "Stop continuous jumping", function()
	if loops.loopjump then
		loops.loopjump:Disconnect()
		loops.loopjump = nil
	end
	DoNotif("Loop jump disabled")
end)

cmd.add("loopnight", "Moonlight", function()
	if loops.loopnight then return DoNotif("Already enabled") end
	loops.loopnight = RunService.Heartbeat:Connect(function()
		Lighting.ClockTime = 0
	end)
	DoNotif("Loop night enabled")
end)

cmd.add("unloopnight", "No more moonlight", function()
	if loops.loopnight then
		loops.loopnight:Disconnect()
		loops.loopnight = nil
	end
	DoNotif("Loop night disabled")
end)

cmd.add("loopday", "Sunshiiiine", function()
	if loops.loopday then return DoNotif("Already enabled") end
	loops.loopday = RunService.Heartbeat:Connect(function()
		Lighting.ClockTime = 14
	end)
	DoNotif("Loop day enabled")
end)

cmd.add("unloopday", "No more sunshine", function()
	if loops.loopday then
		loops.loopday:Disconnect()
		loops.loopday = nil
	end
	DoNotif("Loop day disabled")
end)

cmd.add("loopnodrag", "No character drag", function()
	if loops.loopnodrag then return DoNotif("Already enabled") end
	loops.loopnodrag = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum then
			hum.PlatformStand = false
			hum.PlatformStand = true
		end
	end)
	DoNotif("Loop no drag enabled")
end)

cmd.add("unloopnodrag", "Re-enable drag", function()
	if loops.loopnodrag then
		loops.loopnodrag:Disconnect()
		loops.loopnodrag = nil
	end
	local hum = getHum()
	if hum then hum.PlatformStand = false end
	DoNotif("Loop no drag disabled")
end)

cmd.addArg("loopfling", "Loop fling a player [name]", function(val)
	local target = getPlr(val)
	if not target then return DoNotif("Player not found") end
	if loops.loopfling then loops.loopfling:Disconnect() end
	loops.loopfling = RunService.Heartbeat:Connect(function()
		local hrp = getRoot()
		local char = target.Character
		if not hrp or not char then return end
		local thrp = char:FindFirstChild("HumanoidRootPart")
		if not thrp then return end
		hrp.CFrame = thrp.CFrame
		hrp.Velocity = Vector3.new(9999, 9999, 9999)
		hrp.RotVelocity = Vector3.new(9999, 9999, 9999)
	end)
	DoNotif("Loop fling on " .. target.Name)
end)

cmd.add("unloopfling", "Stops loop flinging a player", function()
	if loops.loopfling then
		loops.loopfling:Disconnect()
		loops.loopfling = nil
	end
	DoNotif("Loop fling disabled")
end)

cmd.add("walkfling", "Walk fling", function()
	if loops.walkfling then
		loops.walkfling:Disconnect()
		loops.walkfling = nil
		DoNotif("Walk fling disabled")
		return
	end
	loops.walkfling = RunService.Heartbeat:Connect(function()
		local hrp = getRoot()
		if hrp then
			hrp.RotVelocity = Vector3.new(9999, 9999, 9999)
		end
	end)
	DoNotif("Walk fling enabled")
end)

cmd.add("unwalkfling", "Stop walk fling", function()
	if loops.walkfling then
		loops.walkfling:Disconnect()
		loops.walkfling = nil
	end
	DoNotif("Walk fling disabled")
end)

cmd.addArg("toolreach", "Extended tool reach [value]", function(val)
	local char = getChar()
	if not char then return DoNotif("No character") end
	local tool = char:FindFirstChildOfClass("Tool")
	if not tool then return DoNotif("No tool equipped") end
	local handle = tool:FindFirstChild("Handle")
	if not handle then return DoNotif("No handle") end
	local n = tonumber(val) or 20
	tool.GripSize = Vector3.new(n, n, n)
	DoNotif("Tool reach: " .. n)
end)

cmd.add("untoolreach", "Reset tool reach", function()
	local char = getChar()
	if not char then return end
	local tool = char:FindFirstChildOfClass("Tool")
	if tool then
		tool.GripSize = Vector3.new(1, 2, 3)
	end
	DoNotif("Tool reach reset")
end)

cmd.add("tpwalk", "Undetectable walkspeed", function()
	if loops.tpwalk then
		loops.tpwalk:Disconnect()
		loops.tpwalk = nil
		DoNotif("TP walk disabled")
		return
	end
	loops.tpwalk = RunService.Heartbeat:Connect(function()
		local hrp = getRoot()
		local hum = getHum()
		if hrp and hum then
			local moveDir = hum.MoveDirection
			if moveDir.Magnitude > 0 then
				hrp.CFrame = hrp.CFrame + moveDir * 2
			end
		end
	end)
	DoNotif("TP walk enabled")
end)

cmd.add("untpwalk", "Stops the tpwalk command", function()
	if loops.tpwalk then
		loops.tpwalk:Disconnect()
		loops.tpwalk = nil
	end
	DoNotif("TP walk disabled")
end)

cmd.add("unloop", "Stops all active command loops", function()
	for key, conn in pairs(loops) do
		if typeof(conn) == "RBXScriptConnection" then
			conn:Disconnect()
		elseif typeof(conn) == "Instance" then
			pcall(function() conn:Destroy() end)
		end
		loops[key] = nil
	end
	DoNotif("All loops stopped")
end)

cmd.add("sitnpcs", "Makes NPCS sit", function()
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("Humanoid") and not Players:GetPlayerFromCharacter(v.Parent) then
			v.Sit = true
			count = count + 1
		end
	end
	DoNotif("Sat " .. count .. " NPCs")
end)

cmd.add("unsitnpcs", "Makes NPCS unsit", function()
	local count = 0
	for _, v in pairs(Workspace:GetDescendants()) do
		if v:IsA("Humanoid") and not Players:GetPlayerFromCharacter(v.Parent) then
			v.Sit = false
			count = count + 1
		end
	end
	DoNotif("Unsat " .. count .. " NPCs")
end)

-- COMMAND DATABASE

-- COMMAND DATABASE

local DB = [[2012=Makes your Pedoblox CoreGui look like the 2012 CoreGui|2013=Makes your Pedoblox CoreGui look like the 2013 CoreGui|2014=Makes your Pedoblox CoreGui look like the 2014 CoreGui|2015=Makes your Pedoblox CoreGui look like the 2015 CoreGui|2016=Makes your Pedoblox CoreGui look like the 2016 CoreGui|accountage=Tells the account age of a player in the server|actnpc=Start acting like an NPC|addalias=Adds a persistent alias for an existing command|addallplugins=Move all .na to Nameless-Admin/Plugins and all .iy to Nameless-Admin/PluginsIY, then load them|addautoexec=Add a command to autoexecute|addbutton=Add a mobile button|addplugin=Move one .na to Plugins or one .iy to PluginsIY, then load it|admin=Whitelist the user to have access to *your* client-side commands, anything they type runs on *you*, not on themselves|adonisbypass=bypasses adonis admin detection|aimbot=aimbot and yeah|airmomentum=Overrides default in-air horizontal movement with custom air control|airwalk=Press space to go up, unairwalk to stop|alignmentkeys=Enable alignment keys|animationassetdata=Set Show Active Animation Asset|animationplayer=dropdown menu with all the animations the game has to be played|animationspeed=Adjusts the speed of currently playing animations|animbuilder=Opens animation builder GUI|animcopycore=Copy core animations from target|animdata=Shows you information about your current animations|animresetcore=Reset core animations to saved|animspoofer=Loads up an animation spoofer,spoofs animations that use rbxassetid|annoy=Annoys the given player|antiafk=Prevents you from being kicked for being AFK|antianchor=Prevent your parts from being anchored|antibang=prevents users to bang you (still WORK IN PROGRESS)|antibreakjoints=Prevents local character joints from breaking when possible|anticframeteleport=Prevents client teleports|antierror=Continuously blocks and clears any future error or disconnected UI|antifling=makes other players non-collidable with you|antiflingparts=Disables collision on nearby unanchored non-player parts above the velocity threshold|antikick=Bypass Kick on Most Games|antiknockback=Disables knockback|antinil=Prevents your character from being parented to nil|antisit=Prevents the player from sitting|antistaff=Automatically leave or advanced-serverhop when staff is detected|antiteleport=Prevents TeleportService from moving you to another place|antitouch=Disables touchable parts|antitrip=no tripping today bruh|antivelocity=Limits your character's velocity to the provided value|antivelocityinstances=Continuously destroys force, torque, position, orientation, and velocity mover instances inside your character|antivoid=Prevents you from falling into the void by launching you upwards|antivoid2=sets FallenPartsDestroyHeight to -inf|ass=Ass|audiologger=Gives an UI that grabs all audios on the game|aura=Continuously damages all nearby humanoid targets with equipped tool|autoclicker=provides a autoclicker gui|autodelete=Removes any part with a certain name from the workspace on loop|autodeleteclass=Removes any part with a certain classname from the workspace on loop|autodeletefind=Auto removes parts with names containing text|autofireclick=Automatically fires ClickDetectors matching [target] every <interval> seconds|autofireclickfind=Automatically fires ClickDetectors matching [target] using substring matching every <interval> seconds|autofireproxi=Automatically fires ProximityPrompts matching [target] every <interval> seconds|autofireproxifind=Automatically fires ProximityPrompts matching [target] using substring matching every <interval> seconds|autofireremote=Automatically fires remotes matching [target] every <interval> seconds|autofireremotefind=Automatically fires remotes matching [target] using substring matching every <interval> seconds|autoflashback=Auto-teleports you to your last death point on respawn|autoflashbackalt=Auto-teleports you to the 0 HP flashback point on respawn|autofollow=Automatically follow any player who comes close|autopatchtool=Aggressively patches common cooldown, reload, recoil, spread, ammo, fire-rate, range, and damage settings for a tool|autorejoin=Rejoins the server if you get kicked / disconnected|autoreport=Automatically reports players to get them banned|autorespawn=Teleports you back to your death position after respawn|autotouch=Automatically fires TouchInterests on parts matching [target] every <interval> seconds|autotouchfind=Automatically fires TouchInterests on parts matching [target] using substring matching every <interval> seconds|autouwuify=Stylizes chat input before sending|avatarpreview=Creates a client-only avatar preview rig|awakeparts=Set Awake Parts Highlighted|backpack=provides a custom backpack gui|backview=Flip the camera behind you and invert movement controls|badgeviewer=loads up a badge viewer UI that views all badges in the game you're in|bang=fucks the player by attaching to them|binders=Open the event binder menu|blackhole=Makes unanchored parts teleport to the black hole|blackholefollow=Pulls unanchored parts to you with spin|block=Open block / unblock prompt for target player|blockremote=Block a remote event/function by name (or pick from list)|bodytransparency=Sets LocalTransparencyModifier on selected body parts (no Head) to a value (0-1). UI supports multi-select.|boobs=Boobs|boxreach=Creates a box-shaped hitbox around your tool|breakcars=Breaks any car|breakjoints=Break your character joints and die|breaklayeredclothing=Streches your layered clothing|breakvelocity=Sets your character's velocity to zero momentarily|brightness=Changes the brightness lighting property|bringfolder=Brings all parts in a folder or a specified part|bringmodel=Brings a model to your character by name|bringmodelfind=Brings all models whose name contains the given text to your character|bringnpcs=Brings NPCs|bringpart=Brings a part to your character by name|bringpartfind=Brings all parts containing name to your character|bubblechat=Enables BubbleChat|bypassspeed=Set WalkSpeed (bypass variant)|cam=Manage camera type settings|cameranoclip=Makes your camera clip through walls|cancelteleport=Cancel an in-progress teleport|cancelteleportloop=Repeatedly cancels in-progress teleport|carpet=Be someone's carpet|cartornado=Tornados a car just sit in the car|cbring=Brings the player once on your client|cframefly=Enable CFrame-based flight with respawn-safe cleanup|chams=ESP but without the text :shock:|chamsallies=Chams players on your current team|chamsenemies=Chams players outside your team|chamsteam=Chams players in a specific team; no args = current team/allies|chardebug=debug your character|chardelete=Removes any part with a certain name from your character|chardeleteclass=Removes any part with a certain classname from your character|chardeletefind=Removes parts in your character with names containing text|chat=Chats for you, useful if you're muted|chatlogs=Open the chat logs|chattranslate=the very old chat translator came back after years|checkrfe=Checks if the game has respect filtering enabled off|cig=Gives a cigarette pack (client R6)|cigar=Gives a cigar (client R6)|circlemath=Gay circle math\\nModes: a,b,c,d,e|clearaliases=Removes all aliases created using addalias.|clearautoexec=Clear all AutoExec commands|clearavatarpreview=Removes the client-only avatar preview rig|clearbuttons=Clear all user buttons|clearerror=Clears any current error or disconnected UI immediately|clearnilinstances=Removes nil instances|clearremovespecifictool=Stops all specific tool removal loops|clickdelete=Bind-only click delete (hold bind + left click)|clickdetectorgoto=Teleports to the nearest ClickDetector part, optionally matching its name/parent/model|clickesp=clickesp|clickfling=Fling a player by clicking them|clickkillnpc=Click on an NPC to kill it|clicknpcjp=Click on an NPC to set its JumpPower|clicknpcws=Click on an NPC to set its WalkSpeed|clickscare=Teleports next to a clicked player for a few seconds|clickteleport=Bind-only click teleport (hold bind + left click)|clicktouch=Click a TouchTransmitter part to fire a touch|clickvoidnpc=Click to void NPCs|climb=Allows you to climb while in air|clip=Enable your player's collision|closespeedometer=Closes the speedometer|cmdbar2=Opens a HD-Admin style cmdbar (black & white)|cobaltspy=cobaltspy (cobalt,cspy)|collisioncosts=Set Collision Costs Shown|collisionesp=collisionesp|commandcount=Counts how many commands NA has|commandkeybinds=Open the command keybinds window|commandloop=Run a command on loop|commands=Open the command list|commitoof=Triggers a dramatic oof sequence for the player|console=Opens developer console|contactpoints=Set Contact Points Shown|controllock=Set Shiftlock keys to Control for this session|copydisplay=Copies the display name of the target|copyid=Copies the UserId of the target|copylerp=Copies a CFrame:Lerp script that moves you to your coordinates|copymoveto=Copies a Humanoid:MoveTo script that moves you to your coordinates|copyname=Copies the username of the target|copyposition=Get the position of another player|copyteleport=Copies a script that teleports you to your coordinates|copytools=Copies the tools the given player has|copytptogame=Copies a script for teleporting to the game you are currently in|copytptoserver=Copies a script for teleporting to your current game server|copytween=Copies a TweenService script that moves you to your coordinates|crash=crashes ur client lol (why would you even use this tho)|creep=Teleports from a player behind them and under the floor to the top|cursorfree=Forces the mouse cursor to remain visible and unlocked|cursorreset=Forces Roblox's default visible and unlocked cursor|cursorrestore=Stops cursor enforcement and restores the saved game cursor state|cursorvisible=Forces the mouse cursor to remain visible without changing its lock mode|dance=Does a random dance|datalimit=Set outgoing bandwidth limit in KBps|datetime=Shows your full local date and time|day=Makes it day|decompiler=Choose lua.expert or Luacid to decompile LocalScript/ModuleScript bytecode|decompositiongeometry=Set Decomposition Geometry|defaultrotationscreen=Changes ScreenOrientation to Default|delete=Removes any part with a certain name from the workspace|deleteclass=Removes any part with a certain classname from the workspace|deletefind=Removes any part with a name containing the given text from the workspace|deleteinvisparts=Deletes invisible parts|deletelighting=Removes all descendants (objects) within Lighting.|deleteselectedtool=Deletes currently equipped tools|deletevelocity=removes any velocity/force instanceson your character|desync=Toggle NextGenReplicator desync / sync (run again to disable)|devproducts=Lists Developer Products|dex=Better version of dex|disable=Disables a specific CoreGui|disablealignmentkeys=Disable alignment keys|disableanimations=Freezes your animations|disablehumanoidstate=Opens a picker to disable one humanoid state|disableproximityprompts=Disable ProximityPrompts (all or matching)|disableproximitypromptservice=disable proximity prompt buttons|disablespawn=Disables the previously set spawn point|discord=Copy an invite link|drawconstraintsforce=Set Draw Constraints Net Force|drawcontactsforce=Set Draw Contacts Net Force|drawtotalforce=Set Draw Total Net Force|droptool=Drop one of your tools|droptools=Drop all of your tools|eagerbulkexecution=Set Eager Bulk Execution|echolocation=[BETA] Darkens the world and reveals geometry and entities from movement, landings, and spatial Sound/AudioEmitter sources|echoping=Emit a strong manual echolocation ping|edgejump=Automatically jumps when you get to the edge of an object|enable=Enables a specific CoreGui|enablehumanoidstate=Restores one humanoid state or all disabled states|enableproximityprompts=Enable ProximityPrompts (all or matching)|enableproximitypromptservice=enable proximity prompt buttons|enginesettingsinfo=Show Roblox settings service diagnostics|equiptool=Equip a specific tool by name or selection|equiptools=Equips every tool in your inventory at once|errorchat=Makes the chat error appear when roblox chat is slow|esp=locate where the players are|espall=ESP all players and clear team filtering|espallies=ESP players on your current team|espenemies=ESP players outside your team; no-team games fall back to all others|esplocator=|espteam=ESP players in a specific team; no args = current team/allies|eventinfo=Shows an experience event with copy/details/RSVP options|executor=Toggle the integrated executor UI|exit=Close down pedoblox|experienceevents=Shows upcoming experience events with copy/details/RSVP options|exportconsole=Exports the current NA Console records with timestamps, duplicate counts, and structured context|exportmergebymaterial=Set Export Merge By Material|f3x=F3X for client|fakechat=Fake a chat gui|fakelag=fake lag|fakeout=tp to void and back|fastprompts=Makes proximity prompts use the specified speed multiplier, defaulting to 2x|fatesadmin=Executes fates admin|feedback=Opens Roblox's client experience feedback prompt|fireclickdetectors=Fires every ClickDetector in Workspace|fireclickdetectorsfind=Fires ClickDetectors substring-matching [target] in Workspace|firekey=makes you fire a keybind using VirtualInputManager|fireproximityprompts=Fires every ProximityPrompt in Workspace|fireproximitypromptsfind=Fires ProximityPrompts substring-matching [target] in Workspace|fireremote=Fire one remote by selection, name, or full path|fireremotes=Fires every remote with arguments|firetouchinterests=Fires every TouchInterest in Workspace|firetouchinterestsfind=Fires TouchInterests substring-matching [target] in Workspace|firework=pop|firstp=Makes you go in first person mode|fixcam=Fix your camera|flashback=Teleports you to your last death point|flashbackalt=Teleports you to the 0 HP flashback point|flashlight=Gives you a flashlight tool|fling=Fling the given player|flingnpcs=Flings NPCs|fluidforcedrawscale=fluidforcedrawscale <number> - Set Fluid Force Draw Scale|fly=Enable flight|flyfling=makes you fly and fling|flyjump=Allows you to hold space to fly up|folderesp=Highlights folder contents (parts or models)|follow=Follow a player wherever they go|forcecam=Lock camera type and auto-restore if changed|forcedrawscale=forcedrawscale <number> - Set Force Draw Scale|forceinstancenames=Set Force Instance Names|forcereverb=Lock ambient reverb and auto-restore if changed|forcesmoothingsteps=forcesmoothingsteps <0-100> - Set Force Smoothing Steps|fov=Sets your FOV to a custom value (1Ã¢â‚¬â€œ300)|fps=Shows your frames per second|fpsbooster=Enables maximum-performance low graphics mode, run again to restore|fpscap=Sets the fps cap to whatever you want|fpsping=Shows the legacy FPS and ping panel|freecam=Enable free camera|freecamgoto=Start or move freecam to a player|freecamgotopart=Start or move freecam to an exact part name|freegamepass=Pretends you own every gamepass and fires product purchase signals|freemouse=Toggle cursor unlock while world model first person is active|freeze=Freezes your character|freezeunanchored=Freezes unanchored non-character parts|friend=Sends a friend request to your target|friendweb=Finds friend circles in the current server|frontview=Reset WFCP camera state and return to a normal front view|fullbright=makes dark games bright without destroying effects|functionspy=Check console|gameid=Copies the GameId/Universe Id of the game you're in|gameinfo=shows info about the game you're playing|gamepasses=Prompt & list Game Passes (manual IDs)|gamescripts=Show scripts listed for the current game|gamma=gamma vision (real)|gcsearch=Searches getgc tables, function metadata, constants, and upvalues for text|gear=This is client sided and will probably not work|gethealth=Shows your current health|getidfromusername=Copy a user's UserId by Username|getmass=Get your mass|getuserfromid=Copy a user's Username by ID|globalshadows=Enables global shadows|glue=Loop teleport to a player|glueback=Loop teleport behind a player|godmode=Pick and enable an invincibility method|goto=Teleport to the given player, NPC, or X,Y,Z coordinates|gotobreak=Stop the active goto sequence and clear duplicate selections.|gotocampos=Teleports you to your camera position works with free cam but freezes you|gotofolder=Teleports you to all parts in a folder|gotofoldernext=Teleport sequentially through folder contents with optional prefix.|gotomodel=Teleports to each model with name once|gotomodelfind=Teleports to each model containing name once|gotomodelnext=Teleport sequentially to models with optional prefix and duplicate handling.|gotonpcs=Teleports to each NPC|gotopart=Teleports you to each matching part by name once|gotopartclass=Teleports to each part of class once|gotopartfind=Teleports to each part containing name once|gotopartnext=Teleport sequentially to parts with optional prefix and duplicate handling.|gotowaypoint=Teleport to a saved waypoint|grabtools=Grabs dropped tools|gravity=sets game gravity to whatever u want|gravitygun=Probably the best gravity gun script thats fe|grippos=Opens a UI to manually input grip offset and rotation.|guidelete=Deletes GUI under mouse with Backspace/Delete, or under tap on mobile|hamster=Hamster ball|handlekill=Kills a player using a tool that deals damage on touch|harked=Executes Comet which is like harked|hatresize=Makes your hats very big r15 only|headbang=Bang them in the mouth because you are gay|headsit=sit on someone's head|headstand=Stand on someone's head.|height=Changes your hipheight|hide=places the selected player to lighting|hideacc=Hide or restore local accessory parts|hidecom=Remove COM tracker|hidecurrentguis=Hides only currently visible GUIs|hideguis=Hides GUIs|hideicon=Hides the NA icon|hidepathwaypoint=Hide waypoint path route nodes and stop waypoint pathfinding|hidetargetgui=Hides a specific GUI by name|hidewaypoints=Hide saved waypoint ESP markers|hitbox=|hitboxes=shows all the hitboxes|homebrew=Executes homebrew admin|hoverinventory=Shows a player's inventory on hover|hovername=Shows player's username on hover|httpspy=HTTP Spy|hug=huggies time (click on a target to hug)|hydroxide=executes hydroxide|ibtools=Load the iBuild Tools helper tool|ifundone=Runs a command only if that exact command has not been done this session|imagescanner=Gives an UI that grabs all images on the game|improvetextures=Switches Textures|infjump=Enables infinite jumping|inspect=checks a user's items|inspectoutfit=Open a user's saved outfits and inspect a selected outfit|instantproximityprompts=Sets proximity prompt HoldDuration values to 0.01 and keeps them near-instant|instantrespawn=respawn instantly|interpolationthrottle=Set Interpolation Throttle Shown|inversebang=you're the one getting fucked today ;)|invisbind=set a custom keybind for the 'Invisible' command|invisfling=Enables invisible fling (the invis part is patched, try using the god command before using this)|invisible=Sets invisibility to scare people or something|invisibleparts=Shows invisible parts|invitefriends=Opens Roblox's client invite prompt, optionally targeting a user|itemesp=Highlight dropped in-game tools/items|jerk=jorking it|jerkuser=Lay under them and vibe|jobid=Copies your job id|joinbreakdown=Set Print Join Size Breakdown|joingroup=Open the Pedoblox join prompt for a group|joinjobid=Joins the job id you put in|jointcoords=Set Joint Coordinates Shown|joinvoice=let's you use vc if you were suspended|jp=Sets your JumpPower|jump=jump.|jumpboost=Adds extra jump velocity without changing JumpPower|keyboard=provides a keyboard gui for mobile users|keystroke=Executes a keystroke ui script|killnpcs=Kills NPCs|landscaperotationscreen=Changes ScreenOrientation to Landscape Sensor|lastcommand=Re-run your previously executed command|lay=zzzzzzzz|light=Gives your player dynamic light|lighting=Manage lighting technology settings|lightingdisable=Disables all post-processing effects in Lighting instead of deleting them.|listen=Listen to your target's voice chat|loadstring=Run code using loadstring|loadtools=Restores your saved tools to your backpack|localdate=Shows your current date|localtime=Shows your current time|locate=locate where the specified player(s) are|lockiconposition=Locks the NA icon's position (can't be dragged)|lockmouse=Default Mouse Behaviour (idk any description)|lockmouse2=Locks your mouse in the center|lockws=Locks the whole workspace|logphysics=Enable Physics Error Logging|lookat=Stare at a player or NPC|loop=Directly starts a command loop without opening the loop popup|loopantitouch=Enables AntiTouch live tracking without opening the method popup|loopbrightness=Lock the brightness lighting property|loopbringnpcs=Loops NPC bringing|loopbypassspeed=Loop WalkSpeed (bypass variant)|loopcbring=Continuously brings the player on your client|loopday=Sunshiiiine!|loopdroptools=Loop drops your tools|loopenableproximityprompts=Continuously enable ProximityPrompts (all or matching)|loopequiptool=Keeps a specific tool equipped until disabled|loopfling=Loop voids a player|loopfov=Locks your FOV target (1Ã¢â‚¬â€œ300)|loopfullbright=Sunshiiiine!|loopgamma=loop gamma vision (mega real)|loopgrabtools=Loop grabs dropped tools|loopjump=Continuously jump.|loopjumppower=Loop JumpPower|loopmaxslopeangle=Loop MaxSlopeAngle|loopmaxzoom=Loop your maximum camera distance and restore it when changed|loopminzoom=Loop your minimum camera distance and restore it when changed|loopmute=Loop mutes the player's boombox|loopnight=Moonlight.|loopnoeffect=Keeps Lighting and CurrentCamera effects disabled|loopnofog=See clearly forever!|loopnpcfollow=Makes NPCS follow you in a loop|loopoof=Loops everyone's character sounds (everyone can hear)|looppath=Continuously path to a saved waypoint after death or respawn|looppathteleportdelay=Set loop path teleport delay between route nodes|looppathtweenspeed=Set loop path tween speed in studs per second|loopspook=Teleports next to a player repeatedly|loopteleportpath=Loop path to a waypoint by teleporting between route nodes|looptweenpath=Loop path to a waypoint using tween movement|loopwalkpath=Loop path to a waypoint using walking movement|loopwalkspeed=Loop walkspeed|loopwaveat=Wave to a player in a loop|massfollowedinto=Shows everyone in the server that followed someone into the game|material=Sets every BasePart in your character to a selected material|maxslopeangle=Changes your character's MaxSlopeAngle|maxzoom=Set your maximum camera distance|mechanismsshown=Set Mechanisms Shown|memory=Shows you your current memory usage|meshcachesize=meshcachesize <number> - Set Mesh Cache Size|mimic=Clone target movement with optional delay|mimicchat=Mimics the chat of a player|minimap=just a minimap lol|minzoom=Set your minimum camera distance|modelesp=Highlights matching models|moduleeditor=loads the module editor UI|mstop=Stop mimic and restore defaults|multitool=Allows stacking equipped tools from your inventory|music=Open the NA music player|mute=Mutes the player's boombox|naked=no clothing gang|netbypass=Net bypass|netless=Executes netless which makes scripts more stable|networkpause=Re-enable Roblox network pause overlay|newserverhop=serverhop to one of the newest active servers|night=Makes it night|nightmare=Make it dark and spooky|nilchar=Parents your character to nil|noblackholefollow=Stops blackhole follow and clears constraints|noclickdetectorlimits=Sets all click detectors MaxActivationDistance to math.huge|noclip=Disable your player's collision|nocollisionesp=nocollisionesp|nocooldown=Override game-script cooldown timing with the chosen number of seconds; defaults to 0 when omitted|noeffect=Disables Lighting and CurrentCamera effects|nofall=Prevents fall damage by slowing falls and cancelling landing velocity (STILL IN BETA)|nofog=Removes all fog from the game|nohats=Drop all of your hats|nologphysics=Disable Physics Error Logging|nonetworkpause=Disable Roblox network pause overlay|noprompt=remove the stupid purchase prompt|noproximitypromptlimits=Sets all proximity prompts MaxActivationDistance to math.huge|norender=Disable 3d Rendering to decrease the amount of CPU the client uses|noreset=disable reset button|notepad=integrated notepad|notools=Remove your tools|notween=Forces all TweenService-created tweens, including NA/executor UI tweens, to the chosen duration; defaults to 0|npcaura=Continuously damages nearby NPCs with equipped tool|npcesp=locate all NPCs or only NPCs matching a name/filter|npcfollow=Makes NPCS follow you|npcjumppower=Sets all NPC JumpPower to <power> (default 50)|npcwalkspeed=Sets all NPC WalkSpeed to <speed> (default 16)|offset=Offsets and rotates your character for others using the Character-tab customization|oganims=Old animations from 2007|oldconsole=opens old version of the developer console|olddex=Using this you can see the parts / guis / scripts etc with this. A really good and helpful script.|oldroblox=Old skybox and studs|oldserverhop=serverhop to one of the oldest active servers|oldversionhop=serverhop to the oldest currently active place version|oofspam=Spams oof|orbit=Orbit around a player|ownerid=masks you as the game owner's ID and Username|partname=gives a ui and allows you click on a part to grab it's path|partsize=Grow a part or model named exactly <name> to the cube size you choose.|partsizefind=Grow every part or model whose name contains <term> to the cube size you choose.|pathfind=Follow a player using the pathfinder API wherever they go|pathfindwaypoint=Pathfind to a saved waypoint and show the route nodes|penis=penis|perfstats=Shows or hides performance stats|permtrip=Permanent trip that keeps you down|pesp=pesp {partname}|pespfind=pespfind {partname}|physallowsleep=Set Physics Allow Sleep|physanchors=Set Physics Anchors Shown|physassemblies=Set Physics Assemblies Shown|physbodytypes=Set Physics Body Types Shown|physowners=Set Physics Owners Shown|physregions=Set Physics Regions Shown|phystree=Set Physics Tree Shown|ping=Shows your network latency|pingserverhop=serverhop to the best estimated-latency server|pipe=Gives a smoking pipe (client R6)|placeid=Copies the PlaceId of the game you're in|placename=Copies the game's place name to your clipboard|pluginmaker=Open the no-code .na/.iy plugin builder|portraitrotationscreen=Changes ScreenOrientation to Portrait|predict=Visualize predicted player movement|prefix=Changes the admin prefix|preftransparency=Preferred UI transparency|preventtools=Prevents any item from being equipped|privatemessage=Sends a private message to a player|prompt=allows the stupid purchase prompt|propertychanged=Runs a command when an instance property changes|propertyesp=ESP instances with a matching readable property value|proximityesp=proximityesp|proximitypromptgoto=Teleports to the nearest ProximityPrompt part, optionally matching its name/object/action/parent/model|punch=punch tool that flings|quality=Manage rendering quality settings|r15=Shows a prompt that will switch your character rig type into R15|r6=Shows a prompt that will switch your character rig type into R6|raknetdesync=Enables RakNet desync using raknet.desync(true)|randomizejoinorder=Set Randomize Join Instance Order|rc7=RC7 Internal UI|reach=Extends sword reach in one direction|receiveage=Set Receive Age Shown|refreshanimations=Reload character animations|regionhop=serverhop to a public server in a requested RoValra region|rejoin=Rejoin the game|reloadassets=Set RenderSettings.ReloadAssets|reloadplugin=Reload plugin files (reloads all if no name provided)|remotespy=executes simplespy that supports both pc and mobile|removeads=Removes billboard advertisements as they appear|removealias=Select and remove a saved alias|removeallplugins=Move all plugins from Nameless-Admin/Plugins and Nameless-Admin/PluginsIY back to workspace|removeautoexec=Remove a command from autoexecute|removebutton=Remove a user button|removeplugin=Move a plugin file from Nameless-Admin/Plugins or Nameless-Admin/PluginsIY back to workspace|removespecifictool=Automatically removes a specific tool from backpack/character|removeterrain=clears terrain|removewaypoint=Remove a saved waypoint|rename=Renames the admin UI placeholder to the given name|render=Enable 3d Rendering|renderautofrm=renderautofrm <number> - Set Auto FRM Level|renderboundingboxes=Set Render Bounding Boxes|rendercsgtriangles=Set Render CSG Triangles Debug|renderfrm=Set Frame Rate Manager|renderstreamedregions=Set Render Streamed Regions|repeat=Runs a command a repeated amount of times|replicationlag=Set IncomingReplicationLag|reselectchar=Re-open the character picker|reserveserver=Teleports to a reserved server or creates one if code is missing|reset=Makes your health be 0|resetanims=Restores your previous animations|resetbtn=enable reset button|resetfilter=If Pedoblox keeps tagging your messages, run this to reset the filter|resetlock=Resets your Shiftlock keybinds to default (LeftShift)|resetreach=Resets tool to normal size|respawn=Respawn your character|reverb=Manage sound reverb settings|rewind=Enable rewind with hold-R on PC or a draggable mobile button|rewindspeed=Set rewind frames skipped per heartbeat|rewindtime=Set how many seconds rewind stores|rjre=Rejoins and teleports you to your previous position|rolewatch=Notify if someone from a watched group joins with a specific role|rolewatchleave=Toggle leaving the server if the watched role joins|rolewatchstop=Disable Rolewatch monitoring|rsvpevent=Opens Roblox's RSVP prompt for an experience event|runanim=Plays an animation by ID with optional speed multiplier|saveinstance=Saves the game with SaveInstance 420 Edition using your saved options|saveprefix=Saves the prefix to a file and applies it|savetools=Saves your tools to memory|screenorientation=Manage ScreenOrientation|scripthub=Open the built-in Script Hub using RScripts, RobloxScripts, HaxHell, and ScriptBlox|scriptload=Run a saved script from the NA executor saved scripts folder|scriptlogger=Load SecureScripts Logger before running a suspicious script|scriptviewer=Can view scripts made by 0866|seat=Finds a seat and automatically sits on it|seizure=Gives you a seizure|sensitivity=Changes your sensitivity|sensorrotationscreen=Changes ScreenOrientation to Sensor|serverdate=Shows the server's current date|serverhop=serverhop|serverlist=list of servers to join in|serverremotespy=Gives an UI that logs all the remotes being called from the server (thanks SolSpy lol)|servertime=Shows the server's current time|setfflag=Set a fast flag (use 'save' to store it)|setkiller=Sets killer animation set|setmass=Sets your character mass as close as Roblox allows|setpsycho=Sets psycho animation set|setsimradius=Set sim radius using available methods. Usage: setsimradius <radius>|setspawn=Sets your spawn point to the current character's position|settings=Open the settings menu|settweenspeed=Set how long tween teleport commands take|setwaypoint=Store your current position, or create/update with custom coordinates|setwaypointpos=Create or edit a waypoint using custom coordinates|shaders=Enable a shader preset for Lighting|shapeesp=ESP Part instances with the selected Shape|shiftlock=Toggles shiftlock|showcom=Create a glass sphere with a Highlight at your center of mass|showguis=Enables every UI|showicon=Shows the NA icon|showpathwaypoint=Show PathfindingService route nodes to a saved waypoint|showtargetgui=Shows only a specific GUI by name|showwaypoints=Show saved waypoint ESP markers for this place|sit=Sit your player|sitesp=sitesp|sitnpcs=Makes NPCS sit|sleepon=Enable AllowSleep|smallserverhop=serverhop to a small server in the best-latency region|somersault=Makes you do a clean front flip|soundwarnings=Set Report Sound Warnings|speedometer=Toggles a NA-themed speedometer|spin=Makes your character spin as fast as you want|split=Destroys waist joint|spoofclientid=Spoofs GetClientId() to the value you provide|spook=Teleports next to a player for a few seconds|starenear=Stare at the closest player|stats=Shows FPS, physics, network and memory stats|stealaudio=Save all sounds a player is playing to a file -Cyrus|stopanimations=Stops running animations|stoploop=Stop a running loop|stopmimicchat=Stops mimicking a player|stoptrackstaff=Stop tracking staff members|streamquota=Set Print Stream Instance Quota|strengthen=Makes your character more dense (CustomPhysicalProperties)|suck=suck it|suslay=Lay down in a suspicious way|swim=Swim in the air|swordfighter=Activates a sword fighting bot that engages in automated PvP combat|synapsedex=Loads SynapseX's dex explorer|syncanim=Mirror target animations (live)|syncstop=Stop live sync and restore defaults|tailsway=Load the TailSway physics/wagging script|tas=Launch TAS Recorder Redux; optionally auto-load and play a saved run|team=Changes your team (for the client)|teleportgui=Open the universe subplace and public-server viewer|teleporttoplace=Teleports you using PlaceId|tfly=Enables smooth flying|thawunanchored=Thaws parts frozen by freezeunanchored|thirdp=Makes you go in third person mode|throttle=Set PhysicsEnvironmentalThrottle (1 = default, 2 = disabled)|throttleadjusttime=throttleadjusttime <seconds> - Set Throttle Adjust Time|thru=Move forward by distance|time=Sets the time|timestamp=Shows current Unix timestamp|timestop=freezes all players (ZA WARUDO)|toolinvisible=Be invisible while still being able to use tools|tools=Copies tools from ReplicatedStorage and Lighting|toolview=3D tool viewer above a player's head|toolview2=Live-updating tool viewer|topbar=Shows the NA topbar|torandom=Teleports to a random player|torquedrawscale=torquedrawscale <number> - Set Torque Draw Scale|tospawn=Teleports you to a SpawnLocation|touchesp=touchesp|touchfling=walkfling only when touching a player or NPC|touchinterestgoto=Teleports to the nearest TouchInterest part, optionally matching its name/parent/part/model|tpdown=Teleports you down by the given amount of studs|tpjump=|tptool=Create click/tween teleport buttons or backpack tools|tpua=Brings every unanchored part on the map to the player|tpup=Teleports you up by the given amount of studs|tpwalk=More undetectable walkspeed script|trackstaff=Track, highlight, and notify when a staff member joins the server|triggerbot=Executes a script that automatically clicks the mouse when the mouse is on a player|trip=get up NOW|trussjump=Boost off trusses when you jump|turtlespy=executes Turtle Spy that supports both pc and mobile|tweengotocampos=Another version of goto camera position but bypassing more anti-cheats|tweengotopart=Tween to each matching part by name once|tweengotopartfind=Tweens to each part containing name once|tweento=Teleportation method that bypasses some anticheats|unactnpc=Stop acting like an NPC|unadmin=removes someone from being admin|unairmomentum=Stops the custom air momentum command|unairwalk=Stops the airwalk command|unalignedparts=Set Unaligned Parts Shown|unanchored=unanchored|unanimationassetdata=Disable Show Active Animation Asset|unanimationspeed=Stops the animation speed adjustment loop|unanimdata=|unannoy=Stops the annoy command|unantiafk=Allows you to be kicked for being AFK|unantianchor=Allow your parts to be anchored|unantibang=disables antibang|unantibreakjoints=Disables AntiBreakJoints|unanticframeteleport=Disables Anti CFrame Teleport|unantierror=Disables Anti Error|unantifling=restores collision for other players|unantiflingparts=Restores collision for unanchored parts changed by antiflingparts|unantikick=Disables Anti-Kick protection|unantiknockback=Disables antiknockback|unantinil=Stops preventing your character from being parented to nil|unantisit=Allows the player to sit again|unantistaff=Disable automatic staff avoidance|unantiteleport=Disables Anti-Teleport protection|unantitouch=Re-enables touchable parts|unantitrip=tripping allowed now|unantivelocity=Disables the antivelocity limiter|unantivelocityinstances=Stops removing force and velocity mover instances from your character|unantivoid=Disables antivoid|unantivoid2=reverts FallenPartsDestroyHeight|unass=Ass|unaura=Stops aura loop and removes visualizer|unautodelete=Disables autodelete|unautodeleteclass=Disables autodeleteclass|unautodeletefind=Stops autodeletefind|unautofireclick=Stops all AutoFireClick loops|unautofireclickfind=Stops substring-matching AutoFireClick loops|unautofireproxi=Stops all AutoFireProxi loops|unautofireproxifind=Stops substring-matching AutoFireProxi loops|unautofireremote=Stops all AutoFireRemote loops|unautofireremotefind=Stops substring-matching AutoFireRemote loops|unautoflashback=Disables auto deathpos|unautoflashbackalt=Disables auto flashback alt|unautofollow=Stop automatically following nearby players|unautopatchtool=Restores values changed by Auto Patch Tool and disables its guards|unautorejoin=Disables auto rejoin command|unautorespawn=Stops AutoRespawn|unautotouch=Stops all AutoTouch loops|unautotouchfind=Stops substring-matching AutoTouch loops|unautouwuify=Stops chat input styling|unawakeparts=Disable Awake Parts Highlighted|unbang=Unbangs the player|unblock=Open unblock prompt for target player|unblockremote=Unblock a remote by name, or pick from blocked list|unbodytransparency=Stops transparency loop|unboobs=Boobs|unbubblechat=Disabled BubbleChat|uncameranoclip=Restores normal camera|uncancelteleportloop=Disable cancelteleport loop|uncarpet=Undoes carpet|uncframefly=Disable CFrame-based flight|unchardebug=disable character debug|unclickesp=unclickesp|unclickfling=disables clickfling|unclickkillnpc=Disable clickkillnpc|unclicknpcjp=Disable clicknpcjp|unclicknpcws=Disable clicknpcws|unclickscare=Disables clickscare|unclicktouch=Disable clicktouch|unclicktptool=Remove teleport buttons or tools|unclickvoidnpc=Disable click-void|unclimb=Disables climb|uncollisioncosts=Disable Collision Costs Shown|uncollisionesp=uncollisionesp|uncontactpoints=Disable Contact Points Shown|uncontrollock=Restore Shiftlock keys to default (Shift)|UNCTest=Test how many functions your executor supports|undance=Stops the dance command|undecompositiongeometry=Disable Decomposition Geometry|undesync=Disable offset desync|undisableanimations=Unfreezes your animations|undotextures=Switches Textures|undrawconstraintsforce=Disable Draw Constraints Net Force|undrawcontactsforce=Disable Draw Contacts Net Force|undrawtotalforce=Disable Draw Total Net Force|uneagerbulkexecution=Disable Eager Bulk Execution|unecholocation=Disable echolocation and restore Lighting|unedgejump=Disables edgejump|unequiptools=Unequips every tool you are currently holding|unesp=Disables esp/chams|unesplocator=|unexportmergebymaterial=Disable Export Merge By Material|unfakelag=stops the fake lag command|unfastprompts=Restores tracked proximity prompt HoldDuration values|unfly=Disable flight|unflyfling=stops fly and fling|unflyjump=Disables flyjump|unfolderesp=Disables folder ESP for a folder or all|unfollow=Stop all attempts to follow a player|unforcecam=Stop forcing camera type|unforceinstancenames=Disable Force Instance Names|unforcereverb=Stop forcing ambient reverb|unfreecam=Disable free camera|unfreeze=Unfreezes your character|unfriend=Prompts to unfriend your target|unglobalshadows=Disables global shadows|unglue=Stops teleporting you to a player|unglueback=Stops teleporting you to a player|ungodmode=Disable invincibility|unguidelete=Disables GUI delete|unhamster=Disable hamster ball|unheadbang=Stops headbang|unheadsit=Stop the headsit command.|unheadstand=Stop the headstand command.|unhide=places the selected player back to workspace|unhidecurrentguis=Restores GUIs hidden by hidecurrentguis|unhideguis=Restores GUIs hidden by hideguis|unhidetargetgui=Restores GUIs hidden by hidetargetgui|unhitbox=|unhitboxes=removes the hitboxes outline|unhoverinventory=Disables hoverinventory|unhovername=Disables hovername|unhug=no huggies :(|unibtools=Remove the iBuild Tools helper tool|uninfjump=Disables infinite jumping|uninstantproximityprompts=Restores tracked proximity prompt HoldDuration values|uninterpolationthrottle=Disable Interpolation Throttle Shown|uninversebang=no more fun|uninvisibleparts=Makes parts affected by invisparts return to normal|unitemesp=Disable dropped item ESP|unjerkuser=Stop the jerk user action|unjoinbreakdown=Disable Print Join Size Breakdown|unjointcoords=Disable Joint Coordinates Shown|unjumpboost=Disables extra jump boost|unlight=Removes dynamic light from your player|unlisten=Stops listening|unload=Unload Nameless Admin and clean up its active runtime|unloadbackpack=unloads the custom backpack gui|unlocate=unlocate <username1> <username2>|unlockiconposition=Unlocks the NA icon's position (can be dragged again)|unlockmouse=Unlocks your mouse (fr this time)|unlockmouse2=Unlocks your mouse|unlockws=Unlocks everything in Workspace|unlookat=Stops staring|unloop=Stops all active command loops|unloopbrightness=Stop locking brightness|unloopbringnpcs=Stops NPC bring loop|unloopbypassspeed=Disable loop WalkSpeed (bypass variant)|unloopcbring=Disable looped client bring|unloopday=No more sunshine|unloopdroptools=Stops loop dropping tools|unloopenableproximityprompts=Stop enabling loop|unloopequiptool=Stops the loop equip behaviour|unloopfling=Stops loop flinging a player|unloopfov=Stops FOV loop|unloopfullbright=No more sunshine|unloopgamma=stop gamma vision (real)|unloopgrabtools=Stops the loop grab command|unloopjump=Stop continuous jumping.|unloopjumppower=Disable loop jump power|unloopmaxslopeangle=Disable loop MaxSlopeAngle|unloopmaxzoom=Stop looping your maximum camera distance|unloopminzoom=Stop looping your minimum camera distance|unloopmute=Unloop mutes the player's boombox|unloopnight=No more moonlight.|unloopnoeffect=Restores Lighting and CurrentCamera effects|unloopnofog=No more sight.|unloopnpcfollow=Makes NPCS not follow you in a loop|unloopoof=Stops the oof chaos|unlooppath=Stop persistent waypoint pathfinding|unloopspook=Stops the loopspook command|unloopwalkspeed=Disable loop walkspeed|unloopwaveat=Stops the loopwaveat command|unmaterial=Restores character materials changed by material|unmechanismsshown=Disable Mechanisms Shown|unmodelesp=Disables model ESP for a model or all|unmultitool=Disables multitool mode|unname=Resets the admin UI placeholder name to default|unnightmare=Disable nightmare mode|unnilchar=Restores your nil-parented character|unnocollisionesp=unnocollisionesp|unnocooldown=Disable the game-script cooldown timing override|unnofall=Disables nofall|unnotween=Stops overriding game-created tween durations|unnpcaura=Stops NPC aura loop and removes visualizer|unnpcesp=stop locating npcs|unoffset=Disables offset customization and restores your character|unoldroblox=Restore skybox and studs|unorbit=Stop orbiting|unpartsize=Undo partsizeÃ¢â‚¬â€return those parts back to their original size and collision.|unpartsizefind=Undo partsizefindÃ¢â‚¬â€return those resized parts back to their original size and collision.|unpenis=penis|unpermtrip=Disable permanent trip|unpesp=Remove exact-name part ESP by name or All|unpespfind=Remove partial-name part ESP by name or All|unphysallowsleep=Disable Physics Allow Sleep|unphysanchors=Disable Physics Anchors Shown|unphysassemblies=Disable Physics Assemblies Shown|unphysbodytypes=Disable Physics Body Types Shown|unphysowners=Disable Physics Owners Shown|unphysregions=Disable Physics Regions Shown|unphystree=Disable Physics Tree Shown|unpredict=Remove prediction orb|unpreventtools=Self-explanatory|unpropertychanged=Stops propertychanged listeners|unpropertyesp=Disable property ESP entries|unproximityesp=unproximityesp|unraknetdesync=Disables RakNet desync using raknet.desync(false)|unrandomizejoinorder=Disable Randomize Join Instance Order|unreceiveage=Disable Receive Age Shown|unremoveads=Stop removing billboard advertisements|unremovespecifictool=Stops removing a specific tool|unrenderboundingboxes=Disable Render Bounding Boxes|unrendercsgtriangles=Disable Render CSG Triangles Debug|unrenderfrm=Disable Frame Rate Manager|unrenderstreamedregions=Disable Render Streamed Regions|unrewind=Disable rewind and clear its saved frames|unseizure=Stops you from having a seizure not in real life noob|unshaders=Disable the shader preset and restore Lighting|unshapeesp=Disable Shape ESP entries|unshiftlock=Disables shiftlock|unshowguis=Restores UI states set by showguis|unshowtargetgui=Restores GUI states changed by showtargetgui|unsitesp=unsitesp|unsitnpcs=Makes NPCS unsit|unsleepon=Disable AllowSleep|unsomersault=Disable somersault button and keybind|unsoundwarnings=Disable Report Sound Warnings|unspam=Stop all attempts to lag/spam|unspin=Makes your character unspin|unspoofclientid=Restores normal GetClientId() behavior|unstarenear=Stop staring at closest player|unstreamquota=Disable Print Stream Instance Quota|unsuck=no more fun|unsuslay=Stand up from the sussy lay|unswim=Stops the swim script|unsyncreset=Stop sync and reset saved|untfly=Disables tween flying|untimestop=unfreeze all players|untoolview=Removes the tool viewer above a player's head|untopbar=Hides the NA topbar|untouchesp=untouchesp|untouchfling=stop the touchfling command|untpjump=Stops the tpjump command|untpwalk=Stops the tpwalk command|untrussjump=Disable trussjump|ununalignedparts=Disable Unaligned Parts Shown|ununanchored=ununanchored|unupsidedown=Disables the upside down replication and restores your character|unuwuaffix=Disables suffix styling|unuwustutter=Disables stutter styling|unvehiclesitesp=unvehiclesitesp|unvehiclespeed=Stops the vehiclespeed command|unvfly=disable vehicle fly|unvideocapture=Disable Video Capture Enabled|unviewpart=Resets the camera to the local humanoid|unwaitcap=Disables the game-script wait/delay cap|unwalkfling=stop the walkfling command|unwallhop=disable wallhop helper|unwalltp=Disables wall top teleport|unwatch=Stop spectating|unwatch2=|unweaken=Sets your characters CustomPhysicalProperties to default|unxray=Disables X-ray vision|uporbit=Orbit around a player on the Y axis|upsidedown=Flips your character upside down for others using the offset replication method|uptime=Shows how long the game/session has been running|upvalueeditor=loads the upvalue editor UI|url=Run the script using URL|userid=changes your UserId to any ID you enter|username=changes your Username to any name you enter|userpreview=show info about a user you name|usetools=Equips all tools, uses them, and unequips them|uwuaffix=Enables suffix styling|uwuify=Stylizes and sends chat text|uwustutter=Enables stutter styling|vcworld=Toggle default spatial voice routing|vehicleclip=Enables vehicle collision|vehiclenoclip=Disables vehicle collision|vehicleseat=Sits you in a vehicle seat, useful for trying to find cars in games|vehiclesitesp=vehiclesitesp|vehiclespeed=Change the vehicle speed|versionhop=serverhop to a server running a specific active place version|vfly=be able to fly vehicles|videocapture=Set Video Capture Enabled|viewpart=Focuses camera on a part, model, or folder|viewpartfind=Focuses camera on a part, model, or folder with name containing the given text|visible=turn visible|voidnpcs=Teleports NPC's to void|volume=Changes your volume|vulnerabilitytest=Test if your executor is Vulnerable|waitcap=Caps game-script wait/delay durations without shortening waits already below the cap|walkfling=probably the best fling lol|wallhop=wallhop helper|walltp=Toggles wall top teleport (BETA)|wallwalk=Makes you walk on walls|watch=Spectate player|watch2=|waveat=Wave to a player|waypoints=Open the waypoints menu|weaken=Makes your character less dense|worldmodelfp=WFCP world-model first person camera|ws=Sets your WalkSpeed|xray=Enables X-ray vision to see through walls]]

local entries = DB:split("|")
for _, entry in ipairs(entries) do
	local eq = entry:find("=")
	if eq then
		local name = entry:sub(1, eq - 1)
		local desc = entry:sub(eq + 1)
		if name ~= "" and Cmds[Lower(name)] == nil then
			cmd.add(name, name .. " - " .. desc, function()
				DoNotif(name .. ": " .. desc)
			end)
		end
	end
end

-- UI
local gui = InstanceNew("ScreenGui", {
	Parent = CG,
	Name = "CustomCommandsPanel",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local mainFrame = InstanceNew("Frame", {
	Parent = gui,
	Name = "Main",
	Size = UDim2.new(0, 420, 0, 520),
	Position = UDim2.new(0.5, -210, 0.5, -260),
	BackgroundColor3 = Color3.fromRGB(22, 22, 28),
	BorderSizePixel = 0,
	Active = true,
	Draggable = true
})
InstanceNew("UICorner", {Parent = mainFrame, CornerRadius = UDim.new(0, 8)})

local titleBar = InstanceNew("Frame", {
	Parent = mainFrame,
	Size = UDim2.new(1, 0, 0, 36),
	BackgroundColor3 = Color3.fromRGB(30, 30, 38),
	BorderSizePixel = 0
})
InstanceNew("UICorner", {Parent = titleBar, CornerRadius = UDim.new(0, 8)})

local titleLabel = InstanceNew("TextLabel", {
	Parent = titleBar,
	Size = UDim2.new(1, -40, 1, 0),
	Position = UDim2.new(0, 12, 0, 0),
	BackgroundTransparency = 1,
	Text = "Custom Commands Panel",
	TextColor3 = Color3.fromRGB(0, 170, 255),
	TextScaled = true,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left
})

local closeBtn = InstanceNew("TextButton", {
	Parent = titleBar,
	Size = UDim2.new(0, 30, 0, 28),
	Position = UDim2.new(1, -34, 0, 4),
	BackgroundColor3 = Color3.fromRGB(200, 50, 50),
	Text = "X",
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0
})
InstanceNew("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0, 4)})

local searchBox = InstanceNew("TextBox", {
	Parent = mainFrame,
	Size = UDim2.new(1, -20, 0, 32),
	Position = UDim2.new(0, 10, 0, 42),
	BackgroundColor3 = Color3.fromRGB(35, 35, 42),
	TextColor3 = Color3.fromRGB(200, 200, 200),
 PlaceholderText = "Search commands...",
 PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
	Font = Enum.Font.Gotham,
	TextSize = 14,
	BorderSizePixel = 0,
	ClearTextOnFocus = false
})
InstanceNew("UICorner", {Parent = searchBox, CornerRadius = UDim.new(0, 6)})

local scrollFrame = InstanceNew("ScrollingFrame", {
	Parent = mainFrame,
	Size = UDim2.new(1, -20, 1, -130),
	Position = UDim2.new(0, 10, 0, 80),
	BackgroundColor3 = Color3.fromRGB(28, 28, 34),
	BorderSizePixel = 0,
	ScrollBarThickness = 6,
	ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y
})
InstanceNew("UICorner", {Parent = scrollFrame, CornerRadius = UDim.new(0, 6)})

local uiList = InstanceNew("UIListLayout", {
	Parent = scrollFrame,
	Padding = UDim.new(0, 2),
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center
})
InstanceNew("UIPadding", {Parent = scrollFrame, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)})

local cmdBarFrame = InstanceNew("Frame", {
	Parent = gui,
	Name = "CmdBar",
	Size = UDim2.new(0, 420, 0, 44),
	Position = UDim2.new(0.5, -210, 0.5, 270),
	BackgroundColor3 = Color3.fromRGB(22, 22, 28),
	BorderSizePixel = 0
})
InstanceNew("UICorner", {Parent = cmdBarFrame, CornerRadius = UDim.new(0, 8)})

local cmdBarInput = InstanceNew("TextBox", {
	Parent = cmdBarFrame,
	Size = UDim2.new(1, -60, 1, -12),
	Position = UDim2.new(0, 8, 0, 6),
	BackgroundColor3 = Color3.fromRGB(35, 35, 42),
	TextColor3 = Color3.fromRGB(200, 200, 200),
	PlaceholderText = "Type command here...",
	PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
	Font = Enum.Font.Code,
	TextSize = 13,
	BorderSizePixel = 0,
	ClearTextOnFocus = false
})
InstanceNew("UICorner", {Parent = cmdBarInput, CornerRadius = UDim.new(0, 6)})

local cmdBarBtn = InstanceNew("TextButton", {
	Parent = cmdBarFrame,
	Size = UDim2.new(0, 44, 1, -12),
	Position = UDim2.new(1, -52, 0, 6),
	BackgroundColor3 = Color3.fromRGB(0, 120, 215),
	Text = "Run",
	TextColor3 = Color3.new(1, 1, 1),
	TextScaled = true,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0
})
InstanceNew("UICorner", {Parent = cmdBarBtn, CornerRadius = UDim.new(0, 6)})

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	cmdBarFrame.Visible = false
end)

local function createCmdButton(name, desc)
	local btn = InstanceNew("TextButton", {
		Parent = scrollFrame,
		Size = UDim2.new(1, -8, 0, 28),
		BackgroundColor3 = Color3.fromRGB(35, 35, 42),
		TextColor3 = Color3.fromRGB(200, 200, 200),
		Text = "  " .. name .. " - " .. desc,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0,
		AutoButtonColor = true
	})
	InstanceNew("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 4)})
	btn.MouseButton1Click:Connect(function()
		cmd.run(name)
	end)
	btn.MouseEnter:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	end)
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	end)
	return btn
end

local cmdButtons = {}
local sortedNames = {}
for name in pairs(CmdsList) do
	table.insert(sortedNames, name)
end
table.sort(sortedNames)

for _, name in ipairs(sortedNames) do
	local btn = createCmdButton(name, CmdsList[name])
	cmdButtons[name] = btn
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local query = Lower(searchBox.Text)
	for name, btn in pairs(cmdButtons) do
		if query == "" or name:find(query) or Lower(CmdsList[name]):find(query) then
			btn.Visible = true
		else
			btn.Visible = false
		end
	end
end)

cmdBarBtn.MouseButton1Click:Connect(function()
	local input = cmdBarInput.Text
	if input ~= "" then
		cmd.run(input)
		cmdBarInput.Text = ""
	end
end)

cmdBarInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local input = cmdBarInput.Text
		if input ~= "" then
			cmd.run(input)
			cmdBarInput.Text = ""
		end
	end
end)

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		gui.Enabled = not gui.Enabled
		cmdBarFrame.Visible = gui.Enabled
	end
end)

DoNotif("Custom Commands Panel loaded! RightControl to toggle")

end)
