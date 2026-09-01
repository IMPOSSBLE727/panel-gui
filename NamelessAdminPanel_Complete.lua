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
local StarterPack = game:GetService("StarterPack")

local Plr = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local loops = {}
local espList = {}
local chamsList = {}
local xrayData = {}
local wsData = {}
local antiFlags = {}
local espLocatorData = {}
local collisionEspData = {}
local modelEspData = {}
local folderEspData = {}
local pespData = {}
local pespFindData = {}
local proxEspData = {}
local siteEspData = {}
local touchEspData = {}
local unanchoredData = {}
local vehicleSiteEspData = {}
local itemEspData = {}
local clickEspData = {}
local hoverInvData = {}
local hoverNameData = {}
local partSizeData = {}
local savedTools = {}
local savedAnims = {}
local blockedRemotes = {}
local autoExecList = {}
local waypointData = {}
local materialData = {}
local bodyTransData = {}
local hideAccData = {}
local fFlagData = {}

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
local function GSub(s, p, r) return s:gsub(p, r) end
local function Spawn(f) task.spawn(f) end
local function Defer(f) task.defer(f) end
local function Wait(n) return task.wait(n or 0.1) end

local function getChar()
	return Plr.Character or Plr.CharacterAdded:Wait()
end

local function getHum()
	local c = Plr.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
	local c = Plr.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHead()
	local c = Plr.Character
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

local function IsR15(plr)
	local c = plr.Character
	if not c then return false end
	local h = c:FindFirstChildOfClass("Humanoid")
	if not h then return false end
	return h.RigType == Enum.HumanoidRigType.R15
end

local function ClearLoop(tag)
	if loops[tag] then
		if typeof(loops[tag]) == "RBXScriptConnection" then
			loops[tag]:Disconnect()
		elseif typeof(loops[tag]) == "Instance" then
			pcall(function() loops[tag]:Destroy() end)
		elseif type(loops[tag]) == "thread" then
			pcall(function() task.cancel(loops[tag]) end)
		end
		loops[tag] = nil
	end
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
-- ===================== ANTI-* COMMANDS =====================
cmd.add("antikick", "Bypass Kick on Most Games", function()
	antiFlags.antikick = true
	DoNotif("Anti-kick enabled")
end)
cmd.add("unantikick", "Disables Anti-Kick", function()
	antiFlags.antikick = nil
	DoNotif("Anti-kick disabled")
end)
cmd.add("antiteleport", "Prevents TeleportService from moving you", function()
	antiFlags.antiteleport = true
	DoNotif("Anti-teleport enabled")
end)
cmd.add("unantiteleport", "Disables Anti-Teleport", function()
	antiFlags.antiteleport = nil
	DoNotif("Anti-teleport disabled")
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
cmd.add("unantivoid", "Disables antivoid", function()
	ClearLoop("antivoid")
	DoNotif("Anti-void disabled")
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
cmd.add("unantiafk", "Allows you to be kicked for being AFK", function()
	ClearLoop("antiafk")
	DoNotif("Anti-AFK disabled")
end)
cmd.add("antiknockback", "Disables knockback", function()
	if loops.antiknockback then return DoNotif("Already enabled") end
	loops.antiknockback = RunService.Heartbeat:Connect(function()
		local hrp = getRoot()
		if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z) end
	end)
	DoNotif("Anti-knockback enabled")
end)
cmd.add("unantiknockback", "Disables antiknockback", function()
	ClearLoop("antiknockback")
	DoNotif("Anti-knockback disabled")
end)
cmd.add("antitouch", "Disables touchable parts on character", function()
	if loops.antitouch then return DoNotif("Already enabled") end
	loops.antitouch = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then v.CanTouch = false end
			end
		end
	end)
	DoNotif("Anti-touch enabled")
end)
cmd.add("unantitouch", "Re-enables touchable parts", function()
	ClearLoop("antitouch")
	DoNotif("Anti-touch disabled")
end)
cmd.add("antifling", "Makes other players non-collidable with you", function()
	if loops.antifling then return DoNotif("Already enabled") end
	loops.antifling = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end)
	DoNotif("Anti-fling enabled")
end)
cmd.add("unantifling", "Restores collision for other players", function()
	ClearLoop("antifling")
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
cmd.add("antisit", "Prevents the player from sitting", function()
	if loops.antisit then return DoNotif("Already enabled") end
	loops.antisit = RunService.Heartbeat:Connect(function()
		local h = getHum()
		if h and h.Sit then h.Sit = false end
	end)
	DoNotif("Anti-sit enabled")
end)
cmd.add("unantisit", "Allows the player to sit", function()
	ClearLoop("antisit")
	DoNotif("Anti-sit disabled")
end)
cmd.add("antianchor", "Prevent your parts from being anchored", function()
	if loops.antianchor then return DoNotif("Already enabled") end
	loops.antianchor = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then v.Anchored = false end
			end
		end
	end)
	DoNotif("Anti-anchor enabled")
end)
cmd.add("unantianchor", "Allow parts to be anchored", function()
	ClearLoop("antianchor")
	DoNotif("Anti-anchor disabled")
end)
cmd.add("antibreakjoints", "Prevents character joints from breaking", function()
	if loops.antibreakjoints then return DoNotif("Already enabled") end
	loops.antibreakjoints = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("WeldConstraint") then
					v.Archivable = true
				end
			end
		end
	end)
	DoNotif("Anti-break joints enabled")
end)
cmd.add("unantibreakjoints", "Disables AntiBreakJoints", function()
	ClearLoop("antibreakjoints")
	DoNotif("Anti-break joints disabled")
end)
cmd.add("antitrip", "No tripping", function()
	if loops.antitrip then return DoNotif("Already enabled") end
	loops.antitrip = RunService.Heartbeat:Connect(function()
		local h = getHum()
		if h then
			h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		end
	end)
	DoNotif("Anti-trip enabled")
end)
cmd.add("unantitrip", "Tripping allowed now", function()
	ClearLoop("antitrip")
	local h = getHum()
	if h then
		h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	end
	DoNotif("Anti-trip disabled")
end)
cmd.addArg("antivelocity", "Limits your velocity [value]", function(val)
	if loops.antivelocity then ClearLoop("antivelocity") end
	local cap = tonumber(val) or 50
	loops.antivelocity = RunService.Heartbeat:Connect(function()
		local r = getRoot()
		if r then
			local vel = r.AssemblyLinearVelocity
			if vel.Magnitude > cap then r.AssemblyLinearVelocity = vel.Unit * cap end
		end
	end)
	DoNotif("Anti-velocity: " .. cap)
end)
cmd.add("unantivelocity", "Disables antivelocity", function()
	ClearLoop("antivelocity")
	DoNotif("Anti-velocity disabled")
end)
cmd.add("antivelocityinstances", "Destroys mover instances in character", function()
	if loops.antivelocityinstances then return DoNotif("Already enabled") end
	loops.antivelocityinstances = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyPosition") or v:IsA("BodyAngularVelocity") or v:IsA("LinearVelocity") or v:IsA("AngularVelocity") or v:IsA("VectorForce") or v:IsA("Torque") then
					pcall(function() v:Destroy() end)
				end
			end
		end
	end)
	DoNotif("Anti-velocity instances enabled")
end)
cmd.add("unantivelocityinstances", "Stops removing mover instances", function()
	ClearLoop("antivelocityinstances")
	DoNotif("Anti-velocity instances disabled")
end)
cmd.add("antinil", "Prevents character from being parented to nil", function()
	if loops.antinil then return DoNotif("Already enabled") end
	loops.antinil = Plr.CharacterAdded:Connect(function(char)
		Wait(0.5)
		if not char.Parent then
			char.Parent = Workspace
			DoNotif("Character restored from nil")
		end
	end)
	DoNotif("Anti-nil enabled")
end)
cmd.add("unantinil", "Stops preventing character from nil", function()
	ClearLoop("antinil")
	DoNotif("Anti-nil disabled")
end)
cmd.add("anticframeteleport", "Prevents client teleports", function()
	if loops.anticframeteleport then return DoNotif("Already enabled") end
	local origCF = nil
	loops.anticframeteleport = RunService.Heartbeat:Connect(function()
		local r = getRoot()
		if r then
			if not origCF then origCF = r.CFrame return end
			if (r.Position - origCF.Position).Magnitude > 100 then
				r.CFrame = origCF
				DoNotif("CFrame teleport blocked!")
			else
				origCF = r.CFrame
			end
		end
	end)
	DoNotif("Anti CFrame teleport enabled")
end)
cmd.add("unanticframeteleport", "Disables Anti CFrame Teleport", function()
	ClearLoop("anticframeteleport")
	DoNotif("Anti CFrame teleport disabled")
end)
cmd.add("antierror", "Blocks error/disconnect UI", function()
	if loops.antierror then return DoNotif("Already enabled") end
	loops.antierror = RunService.Heartbeat:Connect(function()
		pcall(function()
			for _, gui in pairs(CG:GetDescendants()) do
				if gui:IsA("ScreenGui") and (gui.Name:find("Error") or gui.Name:find("Disconnect")) then
					gui.Enabled = false
				end
			end
			for _, gui in pairs(Plr.PlayerGui:GetDescendants()) do
				if gui:IsA("ScreenGui") and (gui.Name:find("Error") or gui.Name:find("Disconnect")) then
					gui.Enabled = false
				end
			end
		end)
	end)
	DoNotif("Anti-error enabled")
end)
cmd.add("unantierror", "Disables Anti Error", function()
	ClearLoop("antierror")
	DoNotif("Anti-error disabled")
end)
cmd.add("antiflingparts", "Disables collision on fast unanchored parts", function()
	if loops.antiflingparts then return DoNotif("Already enabled") end
	loops.antiflingparts = RunService.Heartbeat:Connect(function()
		for _, v in pairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") and not v.Anchored and not Players:GetPlayerFromCharacter(v.Parent) then
				if v.AssemblyLinearVelocity.Magnitude > 50 then v.CanCollide = false end
			end
		end
	end)
	DoNotif("Anti-fling parts enabled")
end)
cmd.add("unantiflingparts", "Restores collision for unanchored parts", function()
	ClearLoop("antiflingparts")
	DoNotif("Anti-fling parts disabled")
end)
-- ===================== MOVEMENT & PHYSICS =====================
cmd.add("fly", "Enable flight (WASD+Space/RightShift)", function()
	if loops.fly then return DoNotif("Already enabled") end
	local hum = getHum()
	local root = getRoot()
	if not hum or not root then return DoNotif("No character") end
	local bp = getBp()
	local speed = 50
	local flying = true
	hum.PlatformStand = true
	local bg = InstanceNew("BodyGyro", {P = 9e4, maxTorque = Vector3.new(9e9,9e9,9e9), Parent = root})
	local bv = InstanceNew("BodyVelocity", {velocity = Vector3.zero, maxForce = Vector3.new(9e9,9e9,9e9), Parent = root})
	loops.fly = RunService.RenderStepped:Connect(function()
		if not flying then return end
		local cam = Camera
		local dir = Vector3.zero
		local keys = UIS:GetKeysPressed()
		for _, k in pairs(keys) do
			if k.KeyCode == Enum.KeyCode.W then dir = dir + cam.CFrame.LookVector end
			if k.KeyCode == Enum.KeyCode.S then dir = dir - cam.CFrame.LookVector end
			if k.KeyCode == Enum.KeyCode.A then dir = dir - cam.CFrame.RightVector end
			if k.KeyCode == Enum.KeyCode.D then dir = dir + cam.CFrame.RightVector end
			if k.KeyCode == Enum.KeyCode.Space then dir = dir + Vector3.new(0,1,0) end
			if k.KeyCode == Enum.KeyCode.RightShift then dir = dir - Vector3.new(0,1,0) end
		end
		if dir.Magnitude > 0 then
			bv.Velocity = dir.Unit * speed
		else
			bv.Velocity = Vector3.zero
		end
		bg.CFrame = cam.CFrame
	end)
	DoNotif("Fly enabled")
end)
cmd.add("unfly", "Disable flight", function()
	ClearLoop("fly")
	local root = getRoot()
	if root then
		for _, v in pairs(root:GetChildren()) do
			if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
		end
	end
	local hum = getHum()
	if hum then hum.PlatformStand = false end
	DoNotif("Fly disabled")
end)
cmd.add("cframefly", "CFrame-based flight", function()
	if loops.cfly then return DoNotif("Already enabled") end
	local root = getRoot()
	if not root then return DoNotif("No character") end
	local speed = 3
	local target = InstanceNew("Part", {Anchored = true, Transparency = 1, CanCollide = false, Size = Vector3.new(1,1,1), CFrame = root.CFrame})
	local weld = InstanceNew("WeldConstraint", {Part0 = target, Part1 = root, Parent = target})
	target.Parent = Workspace
	loops.cfly = RunService.RenderStepped:Connect(function()
		local cam = Camera
		local moveDir = Vector3.zero
		local keys = UIS:GetKeysPressed()
		for _, k in pairs(keys) do
			if k.KeyCode == Enum.KeyCode.W then moveDir = moveDir + cam.CFrame.LookVector end
			if k.KeyCode == Enum.KeyCode.S then moveDir = moveDir - cam.CFrame.LookVector end
			if k.KeyCode == Enum.KeyCode.A then moveDir = moveDir - cam.CFrame.RightVector end
			if k.KeyCode == Enum.KeyCode.D then moveDir = moveDir + cam.CFrame.RightVector end
			if k.KeyCode == Enum.KeyCode.E then moveDir = moveDir + Vector3.new(0,1,0) end
			if k.KeyCode == Enum.KeyCode.Q then moveDir = moveDir - Vector3.new(0,1,0) end
		end
		if moveDir.Magnitude > 0 then
			target.CFrame = CFrame.new(target.Position + moveDir.Unit * speed, target.Position + cam.CFrame.LookVector)
		end
	end)
	DoNotif("CFrame fly enabled")
end)
cmd.add("uncframefly", "Disable CFrame fly", function()
	ClearLoop("cfly")
	local root = getRoot()
	if root then
		for _, v in pairs(Workspace:GetChildren()) do
			if v:IsA("Part") and v.Transparency == 1 and v.Anchored and v:FindFirstChildOfClass("WeldConstraint") then
				local w = v:FindFirstChildOfClass("WeldConstraint")
				if w and w.Part1 == root then v:Destroy() end
			end
		end
	end
	DoNotif("CFrame fly disabled")
end)
cmd.add("noclip", "Disable your player's collision", function()
	if loops.noclip then return DoNotif("Already enabled") end
	loops.noclip = RunService.PreSimulation:Connect(function()
		local char = Plr.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end
	end)
	DoNotif("Noclip enabled")
end)
cmd.add("clip", "Enable your player's collision", function()
	ClearLoop("noclip")
	DoNotif("Noclip disabled")
end)
cmd.add("infjump", "Enables infinite jumping", function()
	if loops.infjump then return DoNotif("Already enabled") end
	loops.infjump = UIS.JumpRequest:Connect(function()
		local hum = getHum()
		if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
	DoNotif("Inf jump enabled")
end)
cmd.add("uninfjump", "Disables infinite jumping", function()
	ClearLoop("infjump")
	DoNotif("Inf jump disabled")
end)
cmd.add("swim", "Swim in the air", function()
	if loops.swim then return DoNotif("Already enabled") end
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
	loops.swim = hum:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		if hum.FloorMaterial == Enum.Material.Air then
			hum:ChangeState(Enum.HumanoidStateType.Swimming)
		end
	end)
	DoNotif("Swim enabled")
end)
cmd.add("unswim", "Stops the swim script", function()
	ClearLoop("swim")
	DoNotif("Swim disabled")
end)
cmd.add("climb", "Allows you to climb while in air", function()
	if loops.climb then return DoNotif("Already enabled") end
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	loops.climb = hum:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
		if hum.FloorMaterial == Enum.Material.Air then
			hum:ChangeState(Enum.HumanoidStateType.Climbing)
		end
	end)
	DoNotif("Climb enabled")
end)
cmd.add("unclimb", "Disables climb", function()
	ClearLoop("climb")
	DoNotif("Climb disabled")
end)
cmd.add("spin", "Makes your character spin", function()
	if loops.spin then return DoNotif("Already enabled") end
	local root = getRoot()
	if not root then return DoNotif("No character") end
	local spinPart = InstanceNew("Part", {Anchored = false, CanCollide = false, Transparency = 1, Size = Vector3.new(1,1,1), CFrame = root.CFrame})
	local angular = InstanceNew("BodyAngularVelocity", {MaxTorque = Vector3.new(0, math.huge, 0), AngularVelocity = Vector3.new(0, 20, 0), Parent = spinPart})
	local weld = InstanceNew("WeldConstraint", {Part0 = spinPart, Part1 = root, Parent = spinPart})
	spinPart.Parent = Workspace
	loops.spin = spinPart
	DoNotif("Spin enabled")
end)
cmd.add("unspin", "Makes your character unspin", function()
	ClearLoop("spin")
	DoNotif("Spin disabled")
end)
cmd.addArg("speed", "Sets your WalkSpeed [value]", function(val)
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.WalkSpeed = tonumber(val) or 16
	DoNotif("Speed: " .. hum.WalkSpeed)
end)
cmd.addArg("jumppower", "Sets your JumpPower [value]", function(val)
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	local n = tonumber(val) or 50
	if hum.UseJumpPower then
		hum.JumpPower = n
	else
		hum.JumpHeight = (n^2) / (2 * Workspace.Gravity)
	end
	DoNotif("JumpPower: " .. n)
end)
cmd.addArg("hipheight", "Changes your HipHeight [value]", function(val)
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.HipHeight = tonumber(val) or 0
	DoNotif("HipHeight: " .. hum.HipHeight)
end)
cmd.addArg("gravity", "Sets game gravity [value]", function(val)
	Workspace.Gravity = tonumber(val) or 196.2
	DoNotif("Gravity: " .. Workspace.Gravity)
end)
cmd.addArg("bypassspeed", "Set WalkSpeed bypass variant [value]", function(val)
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	local n = tonumber(val) or 16
	ClearLoop("bypassspeed")
	loops.bypassspeed = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		if root and hum then
			hum.WalkSpeed = 0
			local cam = Camera
			local moveDir = Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
			if moveDir.Magnitude > 0 then
				root.CFrame = root.CFrame + moveDir.Unit * n * 0.016
			end
		end
	end)
	DoNotif("Bypass speed: " .. n)
end)
cmd.add("unbypassspeed", "Disable bypass speed", function()
	ClearLoop("bypassspeed")
	local hum = getHum()
	if hum then hum.WalkSpeed = 16 end
	DoNotif("Bypass speed disabled")
end)
cmd.add("edgejump", "Automatically jumps when you get to the edge", function()
	if loops.edgejump then return DoNotif("Already enabled") end
	local lastCF = nil
	loops.edgejump = RunService.RenderStepped:Connect(function()
		local hum = getHum()
		local root = getRoot()
		if not hum or not root then return end
		local state = hum:GetState()
		if state == Enum.HumanoidStateType.Freefall and lastCF then
			root.CFrame = lastCF
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, hum.JumpPower or 50, root.AssemblyLinearVelocity.Z)
		end
		lastCF = root.CFrame
	end)
	DoNotif("Edge jump enabled")
end)
cmd.add("unedgejump", "Disables edgejump", function()
	ClearLoop("edgejump")
	DoNotif("Edge jump disabled")
end)
cmd.add("wallhop", "Wallhop helper", function()
	if loops.wallhop then return DoNotif("Already enabled") end
	loops.wallhop = UIS.JumpRequest:Connect(function()
		local root = getRoot()
		local hum = getHum()
		if root and hum then
			local ray = Workspace:Raycast(root.Position, root.CFrame.LookVector * 3, RaycastParams.new())
			if ray then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
				root.AssemblyLinearVelocity = Vector3.new(0, hum.JumpPower or 50, 0)
			end
		end
	end)
	DoNotif("Wallhop enabled")
end)
cmd.add("unwallhop", "Disable wallhop", function()
	ClearLoop("wallhop")
	DoNotif("Wallhop disabled")
end)
cmd.add("tpwalk", "More undetectable walkspeed script", function()
	if loops.tpwalk then return DoNotif("Already enabled") end
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	local n = 50
	loops.tpwalk = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		if root and hum then
			hum.WalkSpeed = 0
			local cam = Camera
			local moveDir = Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
			if moveDir.Magnitude > 0 then
				root.CFrame = root.CFrame + moveDir.Unit * n * 0.016
			end
		end
	end)
	DoNotif("Tpwalk enabled")
end)
cmd.add("untpwalk", "Stops the tpwalk command", function()
	ClearLoop("tpwalk")
	local hum = getHum()
	if hum then hum.WalkSpeed = 16 end
	DoNotif("Tpwalk disabled")
end)
cmd.add("walkfling", "Probably the best fling", function()
	if loops.walkfling then return DoNotif("Already enabled") end
	loops.walkfling = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		if root then
			local v = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = v + Vector3.new(0, 50, 0)
		end
	end)
	DoNotif("Walkfling enabled")
end)
cmd.add("unwalkfling", "Stop the walkfling", function()
	ClearLoop("walkfling")
	DoNotif("Walkfling disabled")
end)
cmd.add("airwalk", "Press space to go up", function()
	if loops.airwalk then return DoNotif("Already enabled") end
	loops.airwalk = UIS.JumpRequest:Connect(function()
		local root = getRoot()
		if root then
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 50, root.AssemblyLinearVelocity.Z)
		end
	end)
	DoNotif("Air walk enabled")
end)
cmd.add("unairwalk", "Disables air walk", function()
	ClearLoop("airwalk")
	DoNotif("Air walk disabled")
end)
cmd.add("airmomentum", "Overrides default in-air horizontal movement", function()
	if loops.airmomentum then return DoNotif("Already enabled") end
	loops.airmomentum = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		local root = getRoot()
		if hum and root and hum:GetState() == Enum.HumanoidStateType.Freefall then
			local cam = Camera
			local moveDir = Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
			if moveDir.Magnitude > 0 then
				root.AssemblyLinearVelocity = Vector3.new(moveDir.Unit.X * 50, root.AssemblyLinearVelocity.Y, moveDir.Unit.Z * 50)
			end
		end
	end)
	DoNotif("Air momentum enabled")
end)
cmd.add("unairmomentum", "Disables air momentum", function()
	ClearLoop("airmomentum")
	DoNotif("Air momentum disabled")
end)
cmd.add("flyfling", "Makes you fly and fling", function()
	if loops.flyfling then return DoNotif("Already enabled") end
	local root = getRoot()
	if not root then return DoNotif("No character") end
	local speed = 50
	local bg = InstanceNew("BodyGyro", {P = 9e4, maxTorque = Vector3.new(9e9,9e9,9e9), Parent = root})
	local bv = InstanceNew("BodyVelocity", {velocity = Vector3.zero, maxForce = Vector3.new(9e9,9e9,9e9), Parent = root})
	loops.flyfling = RunService.RenderStepped:Connect(function()
		local cam = Camera
		local dir = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.RightShift) then dir = dir - Vector3.new(0,1,0) end
		if dir.Magnitude > 0 then bv.Velocity = dir.Unit * speed else bv.Velocity = Vector3.new(0,50,0) end
		bg.CFrame = cam.CFrame
	end)
	DoNotif("Fly fling enabled")
end)
cmd.add("unflyfling", "Stops fly and fling", function()
	ClearLoop("flyfling")
	local root = getRoot()
	if root then
		for _, v in pairs(root:GetChildren()) do
			if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
		end
	end
	DoNotif("Fly fling disabled")
end)
cmd.add("flyjump", "Allows you to hold space to fly up", function()
	if loops.flyjump then return DoNotif("Already enabled") end
	loops.flyjump = RunService.Heartbeat:Connect(function()
		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			local root = getRoot()
			if root then root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 50, root.AssemblyLinearVelocity.Z) end
		end
	end)
	DoNotif("Fly jump enabled")
end)
cmd.add("unflyjump", "Disables flyjump", function()
	ClearLoop("flyjump")
	DoNotif("Fly jump disabled")
end)
cmd.add("nofall", "Prevents fall damage", function()
	if loops.nofall then return DoNotif("Already enabled") end
	loops.nofall = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		local hum = getHum()
		if root and hum then
			if root.AssemblyLinearVelocity.Y < -50 then
				root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -50, root.AssemblyLinearVelocity.Z)
			end
		end
	end)
	DoNotif("No fall enabled")
end)
cmd.add("unnofall", "Disables nofall", function()
	ClearLoop("nofall")
	DoNotif("No fall disabled")
end)
cmd.add("somersault", "Makes you do a clean front flip", function()
	local root = getRoot()
	if not root then return DoNotif("No character") end
	local cf = root.CFrame
	for i = 1, 20 do
		root.CFrame = cf * CFrame.Angles(math.rad(i * 18), 0, 0)
		Wait(0.016)
	end
	DoNotif("Somersault done")
end)
cmd.add("upsidedown", "Flips your character upside down", function()
	if loops.upsidedown then return DoNotif("Already enabled") end
	loops.upsidedown = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		if root then root.CFrame = root.CFrame * CFrame.Angles(math.rad(180), 0, 0) end
	end)
	DoNotif("Upside down enabled")
end)
cmd.add("unupsidedown", "Disables upside down", function()
	ClearLoop("upsidedown")
	DoNotif("Upside down disabled")
end)
cmd.addArg("setmass", "Sets your character mass [value]", function(val)
	local n = tonumber(val) or 50
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function() part.CustomPhysicalProperties = PhysicalProperties.new(n, 0.3, 0.5, 1, 1) end)
		end
	end
	DoNotif("Mass set to " .. n)
end)
cmd.add("strengthen", "Makes your character more dense", function()
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function() part.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5, 1, 1) end)
		end
	end
	DoNotif("Strengthened")
end)
cmd.add("weaken", "Makes your character less dense", function()
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function() part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0.3, 0.5, 1, 1) end)
		end
	end
	DoNotif("Weakened")
end)
cmd.add("unweaken", "Sets properties to default", function()
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function() part.CustomPhysicalProperties = PhysicalProperties.new() end)
		end
	end
	DoNotif("Properties reset")
end)
cmd.addArg("maxslopeangle", "Changes your MaxSlopeAngle [value]", function(val)
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.MaxSlopeAngle = tonumber(val) or 89
	DoNotif("MaxSlopeAngle: " .. hum.MaxSlopeAngle)
end)
cmd.add("trussjump", "Boost off trusses when you jump", function()
	if loops.trussjump then return DoNotif("Already enabled") end
	loops.trussjump = UIS.JumpRequest:Connect(function()
		local root = getRoot()
		if root then
			local ray = Workspace:Raycast(root.Position, Vector3.new(0, -3, 0), RaycastParams.new())
			if ray and ray.Instance:IsA("TrussPart") then
				root.AssemblyLinearVelocity = Vector3.new(0, 80, 0)
			end
		end
	end)
	DoNotif("Truss jump enabled")
end)
cmd.add("untrussjump", "Disable trussjump", function()
	ClearLoop("trussjump")
	DoNotif("Truss jump disabled")
end)
cmd.add("jumpboost", "Adds extra jump velocity [value]", function(val)
	if loops.jumpboost then ClearLoop("jumpboost") end
	local n = tonumber(val) or 20
	loops.jumpboost = UIS.JumpRequest:Connect(function()
		Wait(0.05)
		local root = getRoot()
		if root then
			root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, root.AssemblyLinearVelocity.Y + n, root.AssemblyLinearVelocity.Z)
		end
	end)
	DoNotif("Jump boost: " .. n)
end)
cmd.add("unjumpboost", "Disables extra jump boost", function()
	ClearLoop("jumpboost")
	DoNotif("Jump boost disabled")
end)

-- ===================== ESP & VISUAL =====================
local function addESP(player, color)
	local char = player.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if not head then return end
	if espList[player] then pcall(function() espList[player]:Destroy() end) end
	local bb = InstanceNew("BillboardGui", {Adornee = head, Size = UDim2.new(0, 200, 0, 50), StudsOffset = Vector3.new(0, 2, 0), AlwaysOnTop = true, Parent = head})
	local label = InstanceNew("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = color or Color3.fromRGB(255, 0, 0), TextStrokeTransparency = 0, Text = player.Name .. " [" .. math.floor((head.Position - getRoot().Position).Magnitude) .. "m]", Font = Enum.Font.GothamBold, TextScaled = true, Parent = bb})
	espList[player] = bb
end
local function removeESP(player)
	if espList[player] then pcall(function() espList[player]:Destroy() end) espList[player] = nil end
end
cmd.add("esp", "Locate where the players are", function()
	if loops.esp then return DoNotif("Already enabled") end
	loops.esp = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr then addESP(p, Color3.fromRGB(255, 0, 0)) end
		end
	end)
	DoNotif("ESP enabled")
end)
cmd.add("unesp", "Disables esp", function()
	ClearLoop("esp")
	for p, _ in pairs(espList) do removeESP(p) end
	espList = {}
	DoNotif("ESP disabled")
end)
cmd.add("espall", "ESP all players and clear team filtering", function()
	if loops.esp then return DoNotif("Already enabled") end
	loops.esp = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr then addESP(p, Color3.fromRGB(255, 255, 255)) end
		end
	end)
	DoNotif("ESP all enabled")
end)
cmd.add("espallies", "ESP players on your current team", function()
	if loops.esp then return DoNotif("Already enabled") end
	loops.esp = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr and p.Team == Plr.Team then addESP(p, Color3.fromRGB(0, 255, 0)) end
		end
	end)
	DoNotif("ESP allies enabled")
end)
cmd.add("espenemies", "ESP players outside your team", function()
	if loops.esp then return DoNotif("Already enabled") end
	loops.esp = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr and p.Team ~= Plr.Team then addESP(p, Color3.fromRGB(255, 0, 0)) end
		end
	end)
	DoNotif("ESP enemies enabled")
end)
cmd.addArg("espteam", "ESP players in a specific team [teamname]", function(name)
	if loops.esp then return DoNotif("Already enabled") end
	loops.esp = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr and p.Team and Lower(p.Team.Name):find(Lower(name)) then addESP(p, Color3.fromRGB(0, 0, 255)) end
		end
	end)
	DoNotif("ESP team: " .. name)
end)
cmd.add("esplocator", "Track ESP with distance/direction", function()
	if loops.esplocator then return DoNotif("Already enabled") end
	local screenGui = InstanceNew("ScreenGui", {Parent = CG})
	loops.esplocator = screenGui
	RunService.Heartbeat:Connect(function()
		screenGui:ClearAllChildren()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr and p.Character and p.Character:FindFirstChild("Head") then
				local head = p.Character:FindFirstChild("Head")
				local pos, onScreen = Camera:WorldToScreenPoint(head.Position)
				if onScreen then
					local label = InstanceNew("TextLabel", {Position = UDim2.new(0, pos.X, 0, pos.Y), Size = UDim2.new(0, 150, 0, 20), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 0), TextStrokeTransparency = 0, Text = p.Name .. " " .. math.floor((head.Position - getRoot().Position).Magnitude) .. "m", Font = Enum.Font.GothamBold, TextSize = 14, Parent = screenGui})
				end
			end
		end
	end)
	DoNotif("ESP locator enabled")
end)
cmd.add("unesplocator", "Disables ESP locator", function()
	if loops.esplocator then pcall(function() loops.esplocator:Destroy() end) loops.esplocator = nil end
	DoNotif("ESP locator disabled")
end)
local function addChams(player, color)
	local char = player.Character
	if not char then return end
	if chamsList[player] then pcall(function() chamsList[player]:Destroy() end) end
	local hl = InstanceNew("Highlight", {FillTransparency = 0.5, OutlineTransparency = 0, FillColor = color or Color3.fromRGB(255, 0, 0), OutlineColor = Color3.fromRGB(255, 255, 255), Adornee = char, Parent = char})
	chamsList[player] = hl
end
local function removeChams(player)
	if chamsList[player] then pcall(function() chamsList[player]:Destroy() end) chamsList[player] = nil end
end
cmd.add("chams", "ESP but without the text", function()
	if loops.chams then return DoNotif("Already enabled") end
	loops.chams = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr then addChams(p, Color3.fromRGB(255, 0, 0)) end
		end
	end)
	DoNotif("Chams enabled")
end)
cmd.add("unchams", "Disables chams", function()
	ClearLoop("chams")
	for p, _ in pairs(chamsList) do removeChams(p) end
	chamsList = {}
	DoNotif("Chams disabled")
end)
cmd.add("chamsallies", "Chams players on your current team", function()
	if loops.chams then return DoNotif("Already enabled") end
	loops.chams = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr and p.Team == Plr.Team then addChams(p, Color3.fromRGB(0, 255, 0)) end
		end
	end)
	DoNotif("Chams allies enabled")
end)
cmd.add("chamsenemies", "Chams players outside your team", function()
	if loops.chams then return DoNotif("Already enabled") end
	loops.chams = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr and p.Team ~= Plr.Team then addChams(p, Color3.fromRGB(255, 0, 0)) end
		end
	end)
	DoNotif("Chams enemies enabled")
end)
cmd.add("collisionesp", "Visualize collision boxes", function()
	if loops.colesp then return DoNotif("Already enabled") end
	loops.colesp = RunService.Heartbeat:Connect(function()
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Plr and p.Character then
				for _, part in pairs(p.Character:GetDescendants()) do
					if part:IsA("BasePart") and not part:FindFirstChild("CollisionESP") then
						local sb = InstanceNew("SelectionBox", {Adornee = part, Color3 = Color3.fromRGB(255, 255, 0), LineThickness = 0.05, Transparency = 0.5, Parent = part})
						sb.Name = "CollisionESP"
					end
				end
			end
		end
	end)
	DoNotif("Collision ESP enabled")
end)
cmd.add("uncollisionesp", "Disables collision ESP", function()
	ClearLoop("colesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "CollisionESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Collision ESP disabled")
end)
cmd.addArg("pesp", "Highlight specific parts by name [partname]", function(name)
	if loops.pesp then ClearLoop("pesp") end
	loops.pesp = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("BasePart") and Lower(desc.Name) == Lower(name) and not desc:FindFirstChild("PesPHL") then
				local hl = InstanceNew("Highlight", {FillTransparency = 0.5, OutlineTransparency = 0, FillColor = Color3.fromRGB(255, 0, 255), Adornee = desc, Parent = desc})
				hl.Name = "PesPHL"
			end
		end
	end)
	DoNotif("Part ESP: " .. name)
end)
cmd.add("unpesp", "Remove part ESP", function()
	ClearLoop("pesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "PesPHL" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Part ESP disabled")
end)
cmd.addArg("pespfind", "Highlight parts containing name [text]", function(name)
	if loops.pespfind then ClearLoop("pespfind") end
	loops.pespfind = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("BasePart") and Lower(desc.Name):find(Lower(name)) and not desc:FindFirstChild("PesPFHL") then
				local hl = InstanceNew("Highlight", {FillTransparency = 0.5, OutlineTransparency = 0, FillColor = Color3.fromRGB(255, 128, 0), Adornee = desc, Parent = desc})
				hl.Name = "PesPFHL"
			end
		end
	end)
	DoNotif("Part ESP find: " .. name)
end)
cmd.add("unpespfind", "Remove partial-name part ESP", function()
	ClearLoop("pespfind")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "PesPFHL" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Part ESP find disabled")
end)
cmd.add("modelesp", "Highlights matching models", function()
	if loops.modelesp then ClearLoop("modelesp") end
	loops.modelesp = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("Model") and desc:FindFirstChildOfClass("PrimaryPart") and not desc:FindFirstChild("ModelESP") then
				local hl = InstanceNew("Highlight", {FillTransparency = 0.7, OutlineTransparency = 0, FillColor = Color3.fromRGB(0, 200, 255), Adornee = desc, Parent = desc})
				hl.Name = "ModelESP"
			end
		end
	end)
	DoNotif("Model ESP enabled")
end)
cmd.add("unmodelesp", "Disables model ESP", function()
	ClearLoop("modelesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "ModelESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Model ESP disabled")
end)
cmd.add("folderesp", "Highlights folder contents", function()
	if loops.folderesp then ClearLoop("folderesp") end
	loops.folderesp = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("Folder") then
				for _, child in pairs(desc:GetDescendants()) do
					if child:IsA("BasePart") and not child:FindFirstChild("FolderESP") then
						local hl = InstanceNew("Highlight", {FillTransparency = 0.7, OutlineTransparency = 0, FillColor = Color3.fromRGB(200, 200, 0), Adornee = child, Parent = child})
						hl.Name = "FolderESP"
					end
				end
			end
		end
	end)
	DoNotif("Folder ESP enabled")
end)
cmd.add("unfolderesp", "Disables folder ESP", function()
	ClearLoop("folderesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "FolderESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Folder ESP disabled")
end)
cmd.add("sitesp", "Highlight SpawnLocations", function()
	if loops.sitesp then ClearLoop("sitesp") end
	loops.sitesp = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("SpawnLocation") and not desc:FindFirstChild("SiteESP") then
				local hl = InstanceNew("Highlight", {FillTransparency = 0.5, OutlineTransparency = 0, FillColor = Color3.fromRGB(0, 255, 0), Adornee = desc, Parent = desc})
				hl.Name = "SiteESP"
			end
		end
	end)
	DoNotif("Site ESP enabled")
end)
cmd.add("unsitesp", "Disables site ESP", function()
	ClearLoop("sitesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "SiteESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Site ESP disabled")
end)
cmd.add("touchesp", "Highlight TouchInterest parts", function()
	if loops.touchesp then ClearLoop("touchesp") end
	loops.touchesp = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("TouchTransmitter") and desc.Parent and not desc.Parent:FindFirstChild("TouchESP") then
				local hl = InstanceNew("Highlight", {FillTransparency = 0.5, OutlineTransparency = 0, FillColor = Color3.fromRGB(255, 0, 0), Adornee = desc.Parent, Parent = desc.Parent})
				hl.Name = "TouchESP"
			end
		end
	end)
	DoNotif("Touch ESP enabled")
end)
cmd.add("untouchesp", "Disables touch ESP", function()
	ClearLoop("touchesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "TouchESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Touch ESP disabled")
end)
cmd.add("unanchored", "Highlight unanchored parts", function()
	if loops.unanchored then ClearLoop("unanchored") end
	loops.unanchored = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("BasePart") and not desc.Anchored and not Players:GetPlayerFromCharacter(desc.Parent) and not desc:FindFirstChild("UnanchESP") then
				local hl = InstanceNew("Highlight", {FillTransparency = 0.7, OutlineTransparency = 0, FillColor = Color3.fromRGB(255, 128, 0), Adornee = desc, Parent = desc})
				hl.Name = "UnanchESP"
			end
		end
	end)
	DoNotif("Unanchored ESP enabled")
end)
cmd.add("ununanchored", "Disables unanchored ESP", function()
	ClearLoop("unanchored")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "UnanchESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Unanchored ESP disabled")
end)
cmd.add("proximityesp", "Highlight nearby ProximityPrompts", function()
	if loops.proxesp then ClearLoop("proxesp") end
	loops.proxesp = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("ProximityPrompt") and desc.Parent and not desc.Parent:FindFirstChild("ProxESP") then
				local hl = InstanceNew("Highlight", {FillTransparency = 0.5, OutlineTransparency = 0, FillColor = Color3.fromRGB(0, 128, 255), Adornee = desc.Parent, Parent = desc.Parent})
				hl.Name = "ProxESP"
			end
		end
	end)
	DoNotif("Proximity ESP enabled")
end)
cmd.add("unproximityesp", "Disables proximity ESP", function()
	ClearLoop("proxesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "ProxESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Proximity ESP disabled")
end)
cmd.add("itemesp", "Highlight dropped tools", function()
	if loops.itemesp then ClearLoop("itemesp") end
	loops.itemesp = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("Tool") and desc:FindFirstChild("Handle") and not desc:FindFirstChild("ItemESP") then
				local hl = InstanceNew("Highlight", {FillTransparency = 0.5, OutlineTransparency = 0, FillColor = Color3.fromRGB(255, 255, 0), Adornee = desc, Parent = desc})
				hl.Name = "ItemESP"
			end
		end
	end)
	DoNotif("Item ESP enabled")
end)
cmd.add("unitemesp", "Disable dropped item ESP", function()
	ClearLoop("itemesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "ItemESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Item ESP disabled")
end)
cmd.add("npcesp", "Locate all NPCs", function()
	if loops.npcesp then ClearLoop("npcesp") end
	loops.npcesp = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) and not desc:FindFirstChild("NpcESP") then
				local head = desc:FindFirstChild("Head")
				if head then
					local hl = InstanceNew("Highlight", {FillTransparency = 0.7, OutlineTransparency = 0, FillColor = Color3.fromRGB(200, 0, 200), Adornee = desc, Parent = desc})
					hl.Name = "NpcESP"
				end
			end
		end
	end)
	DoNotif("NPC ESP enabled")
end)
cmd.add("unnpcesp", "Stop locating NPCs", function()
	ClearLoop("npcesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "NpcESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("NPC ESP disabled")
end)
cmd.add("invisibleparts", "Shows invisible parts with highlights", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and desc.Transparency >= 0.9 then
			local hl = InstanceNew("Highlight", {FillTransparency = 0.3, OutlineTransparency = 0, FillColor = Color3.fromRGB(0, 255, 255), Adornee = desc, Parent = desc})
			hl.Name = "InvisHL"
		end
	end
	DoNotif("Invisible parts highlighted")
end)
cmd.add("uninvisibleparts", "Makes invisible parts normal", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "InvisHL" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Invisible parts normal")
end)
cmd.add("hitbox", "Create transparent parts showing hitboxes", function()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= Plr and p.Character then
			for _, part in pairs(p.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					local box = InstanceNew("BoxHandleAdornment", {Adornee = part, Size = part.Size, Color3 = Color3.fromRGB(255, 0, 0), Transparency = 0.7, ZIndex = 0, AlwaysOnTop = true, Parent = part})
					box.Name = "HitboxAdorn"
				end
			end
		end
	end
	DoNotif("Hitboxes shown")
end)
cmd.add("clickesp", "Highlight parts near mouse", function()
	if loops.clickesp then return DoNotif("Already enabled") end
	loops.clickesp = UIS.MouseButton1Down:Connect(function()
		local mouse = Plr:GetMouse()
		local target = mouse.Target
		if target then
			local hl = InstanceNew("Highlight", {FillTransparency = 0.3, OutlineTransparency = 0, FillColor = Color3.fromRGB(255, 0, 255), Adornee = target, Parent = target})
			hl.Name = "ClickESP"
			Defer(function() Wait(2) pcall(function() hl:Destroy() end) end)
		end
	end)
	DoNotif("Click ESP enabled")
end)
cmd.add("unclickesp", "Disables click ESP", function()
	ClearLoop("clickesp")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "ClickESP" then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Click ESP disabled")
end)
cmd.add("xray", "Enables X-ray vision", function()
	if loops.xray then return DoNotif("Already enabled") end
	xrayData = {}
	loops.xray = RunService.Heartbeat:Connect(function()
		for _, part in pairs(Workspace:GetDescendants()) do
			if part:IsA("BasePart") then
				if xrayData[part] == nil then xrayData[part] = part.LocalTransparencyModifier end
				part.LocalTransparencyModifier = 0.7
			end
		end
	end)
	DoNotif("X-ray enabled")
end)
cmd.add("unxray", "Disables X-ray vision", function()
	ClearLoop("xray")
	for part, val in pairs(xrayData) do
		if part and part.Parent then pcall(function() part.LocalTransparencyModifier = val end) end
	end
	xrayData = {}
	DoNotif("X-ray disabled")
end)

-- ===================== CHARACTER MODIFICATIONS =====================
cmd.add("god", "Enable invincibility", function()
	if loops.godmode then return DoNotif("Already enabled") end
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	local function applyGod()
		hum.MaxHealth = 1e9
		hum.Health = 1e9
		hum.BreakJointsOnDeath = false
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	end
	applyGod()
	loops.godmode = hum.HealthChanged:Connect(function()
		if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
	end)
	DoNotif("God mode enabled")
end)
cmd.add("ungodmode", "Disable invincibility", function()
	ClearLoop("godmode")
	local hum = getHum()
	if hum then
		hum.MaxHealth = 100
		hum.Health = 100
		hum.BreakJointsOnDeath = true
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
	end
	DoNotif("God mode disabled")
end)
cmd.add("heal", "Heals your character", function()
	local hum = getHum()
	if hum then hum.Health = hum.MaxHealth end
	DoNotif("Healed")
end)
cmd.add("kill", "Kills your character", function()
	local hum = getHum()
	if hum then hum.Health = 0 end
end)
cmd.add("reset", "Makes your health be 0", function()
	local hum = getHum()
	if hum then hum.Health = 0 end
end)
cmd.add("respawn", "Respawn your character", function()
	pcall(function() Plr:LoadCharacter() end)
	DoNotif("Respawning...")
end)
cmd.add("breakjoints", "Break your character joints and die", function()
	local char = Plr.Character
	if char then char:BreakJoints() end
end)
cmd.add("sit", "Sit your player", function()
	local hum = getHum()
	if hum then hum.Sit = true end
end)
cmd.add("unsit", "Unsit your player", function()
	local hum = getHum()
	if hum then hum.Sit = false end
end)
cmd.add("jump", "Jump", function()
	local hum = getHum()
	if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
cmd.add("invisible", "Sets invisibility", function()
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	char.Archivable = true
	local clone = char:Clone()
	clone.Parent = Workspace
	local origCF = getRoot(char).CFrame
	getRoot(char).CFrame = CFrame.new(0, 999999, 0)
	char.Parent = RS
	for _, v in pairs(clone:GetDescendants()) do
		if v:IsA("BasePart") then v.Transparency = v.Name == "HumanoidRootPart" and 1 or 0.5 end
	end
	Plr.Character = clone
	Camera.CameraSubject = getHum(clone)
	loops.invisRestore = {origChar = char, origCF = origCF}
	DoNotif("Invisible enabled")
end)
cmd.add("visible", "Turn visible", function()
	if loops.invisRestore then
		local data = loops.invisRestore
		Plr.Character = data.origChar
		data.origChar.Parent = Workspace
		getRoot(data.origChar).CFrame = data.origCF
		Camera.CameraSubject = getHum(data.origChar)
		loops.invisRestore = nil
	end
	DoNotif("Visible")
end)
cmd.add("naked", "No clothing gang", function()
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Destroy() end
	end
	DoNotif("Naked")
end)

local pinkColor = Color3.fromRGB(255, 100, 150)
local ringColor = Color3.fromRGB(225, 80, 120)
local bodyModConn = nil

local function getSkinColor()
	local char = Plr.Character
	if not char then return Color3.new(1, 0.8, 0.6) end
	local part = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	return (part and part.Color) or Color3.new(1, 0.8, 0.6)
end

local function makeModPart(shape, size, color, name, parent)
	local part = InstanceNew("Part")
	part.Shape = shape
	part.Size = size
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Name = name
	part.Parent = parent
	return part
end

local function cleanBodyMods(tags)
	local char = Plr.Character
	if not char then return end
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			for tag in pairs(tags) do
				if v.Name == tag then pcall(function() v:Destroy() end) end
			end
		end
		if v:IsA("SurfaceGui") or v:IsA("Frame") then
			for tag in pairs(tags) do
				if v.Name == tag or (v.Parent and v.Parent.Name == tag) then pcall(function() v:Destroy() end) end
			end
		end
	end
end

local function bodyModLoop(kind, fn)
	if bodyModConn then bodyModConn:Disconnect() bodyModConn = nil end
	bodyModConn = RunService.RenderStepped:Connect(fn)
end

local function stopBodyModLoop()
	if bodyModConn then bodyModConn:Disconnect() bodyModConn = nil end
end

cmd.addArg("boobs", "Boobs <size 1-8>", function(val)
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	if not torso then return DoNotif("No torso") end
	cleanBodyMods({Boob = true, Nipple = true})
	local size = math.clamp(tonumber(val) or 1, 1, 8)
	local skin = getSkinColor()
	local sizeScale = math.clamp(size / 4, 0.3, 2)
	local baseSize = Vector3.new(1.72, 1.54, 1.42)
	local boobSize = Vector3.new(baseSize.X * size * (1.08 + sizeScale * 0.13), baseSize.Y * size * (1.05 + sizeScale * 0.11), baseSize.Z * size * (1.04 + sizeScale * 0.15))
	local nippleSize = Vector3.new(0.19 * size * (1.05 + sizeScale * 0.10), 0.19 * size * (1.05 + sizeScale * 0.10), 0.19 * size * (0.98 + sizeScale * 0.09))
	local ox = math.clamp(torso.Size.X * 0.24 + boobSize.X * 0.145, 0.46, math.max(0.72, torso.Size.X * 0.56))
	local oy = torso.Size.Y * 0.14 + boobSize.Y * 0.055
	local oz = -(torso.Size.Z * 0.5 + math.max(0.14, (boobSize.Z * 0.5) * 0.66) - 0.025)
	local parts = {}
	for _, side in ipairs({-1, 1}) do
		local boob = makeModPart(Enum.PartType.Ball, boobSize, skin, "Boob", char)
		boob.CFrame = torso.CFrame * CFrame.new(side * ox, oy, oz)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = torso
		weld.Part1 = boob
		weld.Parent = boob
		boob.Anchored = false
		table.insert(parts, boob)
		local nipple = makeModPart(Enum.PartType.Ball, nippleSize, pinkColor, "Nipple", char)
		nipple.CFrame = boob.CFrame * CFrame.new(0, 0, -(boobSize.Z * 0.5 + 0.035))
		local nw = Instance.new("WeldConstraint")
		nw.Part0 = boob
		nw.Part1 = nipple
		nw.Parent = nipple
		nipple.Anchored = false
		table.insert(parts, nipple)
		local areola = Instance.new("SurfaceGui")
		areola.Name = "Areola"
		areola.Face = Enum.NormalId.Front
		areola.AlwaysOnTop = false
		areola.LightInfluence = 1
		areola.Parent = boob
		local disk = Instance.new("Frame")
		disk.Name = "Disk"
		disk.AnchorPoint = Vector2.new(0.5, 0.5)
		disk.Position = UDim2.fromScale(0.5, 0.5)
		disk.Size = UDim2.fromScale(0.35, 0.35)
		disk.BackgroundColor3 = ringColor
		disk.BorderSizePixel = 0
		disk.Parent = areola
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent = disk
	end
	bodyModLoop("boobs", function()
		local c = Plr.Character
		if not c or not c.Parent then return end
		for _, p in pairs(c:GetDescendants()) do
			if p:IsA("BasePart") and (p.Name == "Boob" or p.Name == "Nipple") then
				if p.Name == "Boob" or p.Name == "Nipple" then
					p.Color = p.Name == "Nipple" and pinkColor or getSkinColor()
				end
			end
		end
	end)
	DoNotif("Boobs " .. size)
end, true)
cmd.add("unboobs", "Boobs off", function()
	stopBodyModLoop()
	cleanBodyMods({Boob = true, Nipple = true})
	DoNotif("Boobs removed")
end)

cmd.addArg("ass", "Ass <size 1-8>", function(val)
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local torso
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then
		torso = char:FindFirstChild("LowerTorso")
	end
	torso = torso or char:FindFirstChild("Torso")
	if not torso then return DoNotif("No torso") end
	cleanBodyMods({Cheek = true})
	local size = math.clamp(tonumber(val) or 1, 1, 8)
	local skin = getSkinColor()
	local sizeScale = math.clamp(size / 4, 0.3, 2)
	local baseSize = Vector3.new(1.58, 1.48, 1.36)
	local cheekSize = Vector3.new(baseSize.X * size * (1.06 + sizeScale * 0.10), baseSize.Y * size * (1.04 + sizeScale * 0.07), baseSize.Z * size * (1.05 + sizeScale * 0.13))
	local ox = math.clamp(torso.Size.X * 0.25 + cheekSize.X * 0.135, 0.46, math.max(0.70, torso.Size.X * 0.55))
	local oy
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then
		oy = torso.Size.Y * 0.30 + cheekSize.Y * 0.035
	else
		oy = -(0.66 + cheekSize.Y * 0.05)
	end
	local oz = torso.Size.Z * 0.42 + cheekSize.Y * 0.5 * 0.41
	for _, side in ipairs({-1, 1}) do
		local cheek = makeModPart(Enum.PartType.Ball, cheekSize, skin, "Cheek", char)
		cheek.CFrame = torso.CFrame * CFrame.new(side * ox, oy, oz)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = torso
		weld.Part1 = cheek
		weld.Parent = cheek
		cheek.Anchored = false
	end
	DoNotif("Ass " .. size)
end, true)
cmd.add("unass", "Ass off", function()
	cleanBodyMods({Cheek = true})
	DoNotif("Ass removed")
end)

cmd.addArg("penis", "Penis <length 0.5-6>", function(val)
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local torso
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then
		torso = char:FindFirstChild("LowerTorso")
	end
	torso = torso or char:FindFirstChild("Torso")
	if not torso then return DoNotif("No torso") end
	cleanBodyMods({Balls = true, penis = true})
	local value = math.clamp(tonumber(val) or 1, 0.5, 6)
	local skin = getSkinColor()
	local shaftLength = 1.42 + value * 0.85
	local shaftRadius = math.clamp(0.34 + value * 0.042, 0.35, 0.58)
	local ballRadius = math.clamp(0.49 + value * 0.042, 0.50, 0.78)
	local tipRadius = math.clamp(shaftRadius * 1.24, 0.39, 0.65)
	local offsetY = (hum and hum.RigType == Enum.HumanoidRigType.R15) and -0.98 or -1.40
	local scrotumSpread = math.clamp(ballRadius * 0.44, 0.21, 0.36)
	local shaftBaseOffset = (hum and hum.RigType == Enum.HumanoidRigType.R15) and 0.46 or 0.62
	local shaftBaseZ = -(torso.Size.Z * 0.5 + shaftRadius * 0.11)
	local shaftForwardBias = math.max(0, shaftLength * 0.5 - shaftRadius * 0.88)
	local leftBall = makeModPart(Enum.PartType.Ball, Vector3.new(ballRadius * 2, ballRadius * 2.08, ballRadius * 1.98), skin, "Balls", char)
	leftBall.CFrame = torso.CFrame * CFrame.new(-scrotumSpread, offsetY, -0.74 - shaftRadius * 0.46)
	local lw1 = Instance.new("WeldConstraint")
	lw1.Part0 = torso
	lw1.Part1 = leftBall
	lw1.Parent = leftBall
	leftBall.Anchored = false
	local rightBall = makeModPart(Enum.PartType.Ball, Vector3.new(ballRadius * 2, ballRadius * 2.08, ballRadius * 1.98), skin, "Balls", char)
	rightBall.CFrame = torso.CFrame * CFrame.new(scrotumSpread, offsetY, -0.74 - shaftRadius * 0.46)
	local lw2 = Instance.new("WeldConstraint")
	lw2.Part0 = torso
	lw2.Part1 = rightBall
	lw2.Parent = rightBall
	rightBall.Anchored = false
	local shaft = makeModPart(Enum.PartType.Cylinder, Vector3.new(shaftLength, shaftRadius * 2, shaftRadius * 2), skin, "penis", char)
	local shaftCF = torso.CFrame * CFrame.new(0, offsetY + shaftBaseOffset, shaftBaseZ) * CFrame.Angles(0, math.rad(270), 0) * CFrame.new(-shaftForwardBias, 0, 0)
	shaft.CFrame = shaftCF
	local sw = Instance.new("WeldConstraint")
	sw.Part0 = torso
	sw.Part1 = shaft
	sw.Parent = shaft
	shaft.Anchored = false
	local tip = makeModPart(Enum.PartType.Ball, Vector3.new(tipRadius * 2.15, tipRadius * 2.05, tipRadius * 2.05), pinkColor, "penis", char)
	tip.CFrame = shaft.CFrame * CFrame.new(-shaftLength * 0.5, 0, 0)
	local tw = Instance.new("WeldConstraint")
	tw.Part0 = shaft
	tw.Part1 = tip
	tw.Parent = tip
	tip.Anchored = false
	DoNotif("Penis " .. value)
end, true)
cmd.add("unpenis", "Penis off", function()
	cleanBodyMods({Balls = true, penis = true})
	DoNotif("Penis removed")
end)

cmd.add("ff", "Gives you a ForceField", function()
	local char = Plr.Character
	if char then InstanceNew("ForceField", {Parent = char}) end
	DoNotif("ForceField given")
end)
cmd.add("noff", "Removes your ForceField", function()
	local char = Plr.Character
	if char then
		for _, v in pairs(char:GetChildren()) do
			if v:IsA("ForceField") then v:Destroy() end
		end
	end
	DoNotif("ForceField removed")
end)
cmd.add("stopanimations", "Stops running animations", function()
	local hum = getHum()
	if hum then
		for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop() end
	end
	DoNotif("Animations stopped")
end)
cmd.addArg("material", "Sets character material [materialname]", function(name)
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	local mat = Enum.Material[name] or Enum.Material.SmoothPlastic
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then part.Material = mat end
	end
	DoNotif("Material: " .. name)
end)
cmd.add("unmaterial", "Restores character materials", function()
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then part.Material = Enum.Material.Plastic end
	end
	DoNotif("Materials restored")
end)
cmd.addArg("animationspeed", "Adjusts animation speed [value]", function(val)
	if loops.animspeed then ClearLoop("animspeed") end
	local n = tonumber(val) or 1
	loops.animspeed = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum then
			for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(n) end
		end
	end)
	DoNotif("Animation speed: " .. n)
end)
cmd.add("unanimationspeed", "Stops animation speed adjustment", function()
	ClearLoop("animspeed")
	DoNotif("Animation speed reset")
end)
cmd.add("disableanimations", "Freezes your animations", function()
	local hum = getHum()
	if hum then
		for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop() end
	end
	loops.stopAnims = true
	DoNotif("Animations frozen")
end)
cmd.add("undisableanimations", "Unfreezes animations", function()
	loops.stopAnims = false
	DoNotif("Animations unfrozen")
end)
cmd.addArg("bodytransparency", "Sets body transparency [value]", function(val)
	if loops.bodytrans then ClearLoop("bodytrans") end
	local n = tonumber(val) or 0.5
	loops.bodytrans = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then pcall(function() part.LocalTransparencyModifier = n end) end
			end
		end
	end)
	DoNotif("Body transparency: " .. n)
end)
cmd.add("unbodytransparency", "Stops transparency loop", function()
	ClearLoop("bodytrans")
	DoNotif("Body transparency stopped")
end)
cmd.add("dance", "Does a random dance animation", function()
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	local anims = {"rbxassetid://507771019", "rbxassetid://507776043", "rbxassetid://507777268", "rbxassetid://507779092"}
	local anim = InstanceNew("Animation", {AnimationId = anims[math.random(1, #anims)]})
	local track = hum:LoadAnimation(anim)
	track:Play()
	DoNotif("Dancing")
end)
cmd.add("hatresize", "Makes your hats very big (R15 only)", function()
	local char = Plr.Character
	if not char then return DoNotif("No character") end
	if not IsR15(Plr) then return DoNotif("R15 only") end
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("Accessory") then
			local handle = v:FindFirstChild("Handle")
			if handle then handle.Size = handle.Size * 5 end
		end
	end
	DoNotif("Hats resized")
end)
cmd.addArg("offset", "Offsets your character [x,y,z]", function(val)
	if loops.offset then ClearLoop("offset") end
	local args = val:split(",")
	local x = tonumber(args[1]) or 0
	local y = tonumber(args[2]) or 0
	local z = tonumber(args[3]) or 0
	loops.offset = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		if root then root.CFrame = root.CFrame * CFrame.new(x, y, z) end
	end)
	DoNotif("Offset: " .. x .. "," .. y .. "," .. z)
end)
cmd.add("unoffset", "Disables offset", function()
	ClearLoop("offset")
	DoNotif("Offset disabled")
end)
cmd.add("seizure", "Gives you a seizure", function()
	if loops.seizure then return DoNotif("Already enabled") end
	loops.seizure = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then pcall(function() part.LocalTransparencyModifier = math.random() end) end
			end
		end
	end)
	DoNotif("Seizure enabled")
end)
cmd.add("unseizure", "Stops seizure", function()
	ClearLoop("seizure")
	local char = Plr.Character
	if char then
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then pcall(function() part.LocalTransparencyModifier = 0 end) end
		end
	end
	DoNotif("Seizure disabled")
end)
cmd.add("commitoof", "Triggers a dramatic oof sequence", function()
	local char = Plr.Character
	if not char then return end
	local hum = getHum()
	if hum then
		hum.Health = 0
		DoNotif("Oof!")
	end
end)
cmd.add("actnpc", "Start acting like an NPC", function()
	if loops.actnpc then return DoNotif("Already enabled") end
	local hum = getHum()
	if not hum then return DoNotif("No humanoid") end
	hum.WalkSpeed = 0
	hum.JumpPower = 0
	DoNotif("Acting like NPC")
end)
-- ===================== TOOL COMMANDS =====================
cmd.add("btools", "Gives Building Tools", function()
	local bp = getBp()
	if not bp then return end
		local tools = {"Move", "Resize", "Rotate", "Surface", "Paint", "Material", "Anchor", "Weld", "Delete", "Game"}
	for _, name in pairs({"Move", "Resize", "Rotate", "Surface", "Paint", "Material", "Anchor", "Weld", "Delete"}) do
		local t = InstanceNew("Tool", {CanBeDropped = false, Name = name, RequiresHandle = false})
		t.Parent = bp
	end
	DoNotif("BTools given")
end)
cmd.add("droptool", "Drop one of your tools", function()
	local char = Plr.Character
	if not char then return end
	for _, tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") then tool.Parent = Workspace break end
	end
end)
cmd.add("droptools", "Drop all of your tools", function()
	local char = Plr.Character
	if not char then return end
	for _, tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") then tool.Parent = Workspace end
	end
end)
cmd.add("equiptools", "Equip all of your tools", function()
	local bp = getBp()
	if not bp then return end
	for _, tool in pairs(bp:GetChildren()) do
		if tool:IsA("Tool") then tool.Parent = Plr.Character end
	end
end)
cmd.add("unequiptools", "Unequips every tool you are holding", function()
	local char = Plr.Character
	local bp = getBp()
	if not char or not bp then return end
	for _, tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") then tool.Parent = bp end
	end
end)
cmd.add("grabtools", "Grabs dropped tools", function()
	local root = getRoot()
	if not root then return end
	for _, tool in pairs(Workspace:GetChildren()) do
		if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
			pcall(function()
				local att = InstanceNew("Attachment", tool.Handle)
				local align = InstanceNew("AlignPosition", tool.Handle)
				att.Position = Vector3.new(0, 0, 0)
				align.Attachment0 = att
				align.Mode = Enum.AttachmentPositionMode.OneAttachment
				align.Position = root.Position
				align.Responsiveness = 200
				align.MaxForce = 1e9
			end)
		end
	end
end)
cmd.add("multitool", "Allows stacking equipped tools", function()
	if loops.multitool then return DoNotif("Already enabled") end
	loops.multitool = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, tool in pairs(char:GetChildren()) do
				if tool:IsA("Tool") then
					for _, part in pairs(tool:GetDescendants()) do
						if part:IsA("BasePart") then part.CanCollide = false end
					end
				end
			end
		end
	end)
	DoNotif("Multitool enabled")
end)
cmd.add("unmultitool", "Disables multitool mode", function()
	ClearLoop("multitool")
	DoNotif("Multitool disabled")
end)
cmd.add("notools", "Remove your tools", function()
	local bp = getBp()
	if bp then
		for _, tool in pairs(bp:GetChildren()) do
			if tool:IsA("Tool") then tool:Destroy() end
		end
	end
end)
cmd.add("savetools", "Saves your tools to memory", function()
	savedTools = {}
	local bp = getBp()
	if bp then
		for _, tool in pairs(bp:GetChildren()) do
			if tool:IsA("Tool") then table.insert(savedTools, tool:Clone()) end
		end
	end
	DoNotif("Tools saved: " .. #savedTools)
end)
cmd.add("loadtools", "Restores your saved tools", function()
	local bp = getBp()
	if bp and #savedTools > 0 then
		for _, tool in pairs(savedTools) do tool:Clone().Parent = bp end
		DoNotif("Tools loaded")
	else
		DoNotif("No saved tools")
	end
end)
cmd.add("toolreach", "Extended tool reach", function()
	local tool = Plr.Character and Plr.Character:FindFirstChildOfClass("Tool")
	if tool then
		for _, part in pairs(tool:GetDescendants()) do
			if part:IsA("BasePart") then
				pcall(function() part.Size = Vector3.new(20, 20, 20) end)
			end
		end
	end
	DoNotif("Tool reach extended")
end)
cmd.add("untoolreach", "Reset tool reach", function()
	local tool = Plr.Character and Plr.Character:FindFirstChildOfClass("Tool")
	if tool then
		for _, part in pairs(tool:GetDescendants()) do
			if part:IsA("BasePart") then
				pcall(function() part.Size = Vector3.new(1, 1, 1) end)
			end
		end
	end
	DoNotif("Tool reach reset")
end)
cmd.add("boxreach", "Creates a box-shaped hitbox around your tool", function()
	local tool = Plr.Character and Plr.Character:FindFirstChildOfClass("Tool")
	if tool then
		for _, part in pairs(tool:GetDescendants()) do
			if part:IsA("BasePart") then
				pcall(function() part.Size = Vector3.new(10, 10, 10) end)
			end
		end
	end
	DoNotif("Box reach enabled")
end)
cmd.add("resetreach", "Resets tool to normal size", function()
	local tool = Plr.Character and Plr.Character:FindFirstChildOfClass("Tool")
	if tool then
		for _, part in pairs(tool:GetDescendants()) do
			if part:IsA("BasePart") then
				pcall(function() part.Size = Vector3.new(2, 1, 1) end)
			end
		end
	end
	DoNotif("Reach reset")
end)
cmd.add("nohats", "Drop all of your hats", function()
	local char = Plr.Character
	if not char then return end
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("Accessory") then v.Parent = Workspace end
	end
end)

-- ===================== CAMERA COMMANDS =====================
cmd.addArg("fov", "Sets your FOV [value]", function(val)
	Camera.FieldOfView = tonumber(val) or 70
	DoNotif("FOV: " .. Camera.FieldOfView)
end)
cmd.add("freecam", "Enable free camera", function()
	if loops.freecam then return DoNotif("Already enabled") end
	local camPart = InstanceNew("Part", {Transparency = 1, Anchored = true, CanCollide = false, CFrame = Camera.CFrame, Parent = Workspace})
	Camera.CameraSubject = camPart
	loops.freecam = RunService.RenderStepped:Connect(function()
		local speed = 2
		local cf = camPart.CFrame
		local moveDir = CFrame.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + CFrame.new(0, 0, -speed) end
		if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir + CFrame.new(0, 0, speed) end
		if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir + CFrame.new(-speed, 0, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + CFrame.new(speed, 0, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + CFrame.new(0, speed, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir + CFrame.new(0, -speed, 0) end
		camPart.CFrame = CFrame.new(cf.Position) * CFrame.Angles(cf:ToEulerAnglesYXZ()) * moveDir
		Camera.CFrame = camPart.CFrame
	end)
	DoNotif("Freecam enabled")
end)
cmd.add("unfreecam", "Disable free camera", function()
	ClearLoop("freecam")
	local char = Plr.Character
	if char then Camera.CameraSubject = getHum(char) end
	DoNotif("Freecam disabled")
end)
cmd.add("cameranoclip", "Makes your camera clip through walls", function()
	Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
	DoNotif("Camera noclip enabled")
end)
cmd.add("uncameranoclip", "Restores normal camera", function()
	Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
	DoNotif("Camera noclip disabled")
end)
cmd.addArg("watch", "Spectate player [playername]", function(name)
	local target = getPlr(name)
	if not target then return DoNotif("Player not found") end
	local char = target.Character
	if char then Camera.CameraSubject = getHum(char) end
	loops.watch = target.CharacterAdded:Connect(function(c) Camera.CameraSubject = getHum(c) end)
	DoNotif("Watching: " .. target.Name)
end)
cmd.add("unwatch", "Stop spectating", function()
	ClearLoop("watch")
	local char = Plr.Character
	if char then Camera.CameraSubject = getHum(char) end
	DoNotif("Stopped watching")
end)
cmd.addArg("freecamgoto", "Start or move freecam to a player [playername]", function(name)
	local target = getPlr(name)
	if not target then return DoNotif("Player not found") end
	local char = target.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then Camera.CFrame = hrp.CFrame * CFrame.new(0, 5, 10) end
	end
	DoNotif("Freecam to " .. target.Name)
end)
cmd.addArg("gotocampos", "Teleports you to your camera position", function()
	local root = getRoot()
	if root then root.CFrame = Camera.CFrame end
end)
cmd.addArg("loopfov", "Locks your FOV [value]", function(val)
	if loops.loopfov then ClearLoop("loopfov") end
	local n = tonumber(val) or 70
	loops.loopfov = RunService.RenderStepped:Connect(function() Camera.FieldOfView = n end)
	DoNotif("Loop FOV: " .. n)
end)
cmd.add("unloopfov", "Stops FOV loop", function()
	ClearLoop("loopfov")
	DoNotif("FOV loop stopped")
end)
cmd.addArg("maxzoom", "Set your maximum camera distance [value]", function(val)
	Plr.CameraMaxZoomDistance = tonumber(val) or 128
	DoNotif("Max zoom: " .. Plr.CameraMaxZoomDistance)
end)
cmd.addArg("minzoom", "Set your minimum camera distance [value]", function(val)
	Plr.CameraMinZoomDistance = tonumber(val) or 0.5
	DoNotif("Min zoom: " .. Plr.CameraMinZoomDistance)
end)
cmd.add("globalshadows", "Enables global shadows", function()
	Lighting.GlobalShadows = true
	DoNotif("Global shadows enabled")
end)
cmd.add("unglobalshadows", "Disables global shadows", function()
	Lighting.GlobalShadows = false
	DoNotif("Global shadows disabled")
end)
cmd.addArg("backview", "Flip the camera behind you", function()
	local root = getRoot()
	if root then Camera.CFrame = root.CFrame * CFrame.new(0, 5, 15) end
end)
cmd.add("frontview", "Reset camera to normal front view", function()
	local root = getRoot()
	if root then Camera.CFrame = root.CFrame * CFrame.new(0, 2, -8) end
end)
cmd.addArg("watch2", "Spectate player alt [playername]", function(name)
	local target = getPlr(name)
	if not target then return DoNotif("Player not found") end
	local char = target.Character
	if char then Camera.CameraSubject = getHum(char) end
	DoNotif("Watching (alt): " .. target.Name)
end)
cmd.add("unwatch2", "Stop spectating alt", function()
	local char = Plr.Character
	if char then Camera.CameraSubject = getHum(char) end
	DoNotif("Stopped watching alt")
end)
cmd.addArg("viewpart", "Focuses camera on a part [partname]", function(name)
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and Lower(desc.Name) == Lower(name) then
			Camera.CFrame = desc.CFrame * CFrame.new(0, 5, 10)
			loops.viewpart = desc
			DoNotif("Viewing: " .. desc.Name)
			return
		end
	end
	DoNotif("Part not found")
end)
cmd.add("unviewpart", "Resets the camera", function()
	loops.viewpart = nil
	local root = getRoot()
	if root then Camera.CFrame = root.CFrame * CFrame.new(0, 2, -8) end
end)
cmd.add("freemouse", "Toggle cursor unlock", function()
	Plr:GetMouse().Icon = Plr:GetMouse().Icon == "" and "rbxassetid://0" or ""
end)
-- ===================== LIGHTING & ENVIRONMENT =====================
cmd.add("fullbright", "Makes dark games bright", function()
	Lighting.Brightness = 1
	Lighting.ClockTime = 12
	Lighting.FogEnd = 786543
	Lighting.GlobalShadows = false
	Lighting.Ambient = Color3.fromRGB(178, 178, 178)
	DoNotif("Fullbright enabled")
end)
cmd.add("nofog", "Removes all fog", function()
	Lighting.FogEnd = 786543
	Lighting.FogStart = 0
	DoNotif("No fog")
end)
cmd.add("noeffect", "Disables Lighting effects", function()
	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("PostEffect") then v.Enabled = false end
	end
	DoNotif("Effects disabled")
end)
cmd.add("day", "Makes it day", function()
	Lighting.ClockTime = 12
end)
cmd.add("night", "Makes it night", function()
	Lighting.ClockTime = 0
end)
cmd.addArg("brightness", "Changes the brightness [value]", function(val)
	Lighting.Brightness = tonumber(val) or 1
	DoNotif("Brightness: " .. Lighting.Brightness)
end)
cmd.addArg("time", "Sets the time [value]", function(val)
	Lighting.ClockTime = tonumber(val) or 12
	DoNotif("Time: " .. Lighting.ClockTime)
end)
cmd.addArg("gamma", "Sets gamma/exposure [value]", function(val)
	Lighting.ExposureCompensation = tonumber(val) or 0
	DoNotif("Gamma: " .. Lighting.ExposureCompensation)
end)
cmd.add("nightmare", "Make it dark and spooky", function()
	Lighting.ClockTime = 0
	Lighting.Brightness = 0
	Lighting.FogEnd = 100
	Lighting.Ambient = Color3.fromRGB(0, 0, 0)
	DoNotif("Nightmare mode")
end)
cmd.add("unnightmare", "Disable nightmare mode", function()
	Lighting.ClockTime = 12
	Lighting.Brightness = 1
	Lighting.FogEnd = 786543
	DoNotif("Nightmare disabled")
end)
cmd.add("loopfullbright", "Loop fullbright", function()
	if loops.loopfb then ClearLoop("loopfb") end
	loops.loopfb = RunService.Heartbeat:Connect(function()
		Lighting.Brightness = 1
		Lighting.ClockTime = 12
		Lighting.FogEnd = 786543
		Lighting.GlobalShadows = false
	end)
	DoNotif("Loop fullbright enabled")
end)
cmd.add("unloopfullbright", "No more sunshine", function()
	ClearLoop("loopfb")
end)
cmd.add("loopnofog", "See clearly forever", function()
	if loops.loopnf then ClearLoop("loopnf") end
	loops.loopnf = RunService.Heartbeat:Connect(function()
		Lighting.FogEnd = 786543
		Lighting.FogStart = 0
	end)
	DoNotif("Loop no fog enabled")
end)
cmd.add("unloopnofog", "No more sight", function()
	ClearLoop("loopnf")
end)
cmd.add("removeterrain", "Clears terrain", function()
	Workspace:ClearForPhysics()
end)
cmd.add("oldroblox", "Old skybox and studs", function()
	local sky = InstanceNew("Sky", {Parent = Lighting})
	sky.SkyboxBk = "rbxassetid://154996226"
	sky.SkyboxDn = "rbxassetid://154996225"
	sky.SkyboxFt = "rbxassetid://154996224"
	sky.SkyboxLf = "rbxassetid://154996227"
	sky.SkyboxRt = "rbxassetid://154996223"
	sky.SkyboxUp = "rbxassetid://154996222"
	DoNotif("Old Roblox skybox")
end)
cmd.add("unoldroblox", "Restore skybox", function()
	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("Sky") then v:Destroy() end
	end
end)
cmd.add("shaders", "Enable shader preset", function()
	local cc = InstanceNew("ColorCorrectionEffect", {Brightness = 0.05, Contrast = 0.1, Saturation = 0.3, TintColor = Color3.fromRGB(255, 245, 235), Parent = Lighting})
	local bl = InstanceNew("BlurEffect", {Size = 4, Parent = Lighting})
	DoNotif("Shaders enabled")
end)
cmd.add("unshaders", "Disable shader preset", function()
	for _, v in pairs(Lighting:GetDescendants()) do
		if v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") then v:Destroy() end
	end
end)
-- ===================== FUN & ROLEPLAY =====================
cmd.addArg("bang", "Bang the given player [playername]", function(name)
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	if loops.bang then ClearLoop("bang") end
	local hum = getHum()
	if not hum then return end
	local anim = InstanceNew("Animation", {AnimationId = IsR15(Plr) and "rbxassetid://5918726674" or "rbxassetid://148840371"})
	local track = hum:LoadAnimation(anim)
	track:Play(0.1, 1, 1)
	track:AdjustSpeed(10)
	loops.bang = RunService.RenderStepped:Connect(function()
		local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		local lRoot = getRoot()
		if tRoot and lRoot then
			lRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1.1)
			lRoot.AssemblyLinearVelocity = Vector3.zero
		end
	end)
	DoNotif("Banging " .. target.Name)
end)
cmd.add("unbang", "Unbangs the player", function()
	ClearLoop("bang")
	local hum = getHum()
	if hum then for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop() end end
	DoNotif("Unbanged")
end)
cmd.addArg("hug", "Hug the target [playername]", function(name)
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	if loops.hug then ClearLoop("hug") end
	local hum = getHum()
	if not hum then return end
	local anim = InstanceNew("Animation", {AnimationId = "rbxassetid://484200871"})
	local track = hum:LoadAnimation(anim)
	track:Play(0.1, 1, 1)
	loops.hug = RunService.RenderStepped:Connect(function()
		local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		local lRoot = getRoot()
		if tRoot and lRoot then
			lRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1.5)
		end
	end)
	DoNotif("Hugging " .. target.Name)
end)
cmd.add("unhug", "No huggies", function()
	ClearLoop("hug")
	DoNotif("Unhugged")
end)
cmd.addArg("waveat", "Wave to a player [playername]", function(name)
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	local hum = getHum()
	if not hum then return end
	local anim = InstanceNew("Animation", {AnimationId = "rbxassetid://507770239"})
	local track = hum:LoadAnimation(anim)
	track:Play(0.1, 1, 1)
	DoNotif("Waving at " .. target.Name)
end)
cmd.add("unwaveat", "Stop waving", function()
	local hum = getHum()
	if hum then for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop() end end
end)
cmd.add("spook", "Teleports next to a player for a few seconds", function(name)
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	local lRoot = getRoot()
	if tRoot and lRoot then
		local savedCF = lRoot.CFrame
		lRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -2)
		Wait(2)
		lRoot.CFrame = savedCF
	end
end)
cmd.addArg("lookat", "Stare at a player [playername]", function(name)
	if loops.lookat then ClearLoop("lookat") end
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	loops.lookat = RunService.RenderStepped:Connect(function()
		local tHead = target.Character and target.Character:FindFirstChild("Head")
		local lRoot = getRoot()
		if tHead and lRoot then
			lRoot.CFrame = CFrame.new(lRoot.Position, Vector3.new(tHead.Position.X, lRoot.Position.Y, tHead.Position.Z))
		end
	end)
	DoNotif("Looking at " .. target.Name)
end)
cmd.add("unlookat", "Stops staring", function()
	ClearLoop("lookat")
	DoNotif("Stopped staring")
end)
cmd.addArg("fling", "Fling the given player [playername]", function(name)
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	local lRoot = getRoot()
	if not lRoot then return end
	local origCF = lRoot.CFrame
	loops.fling = RunService.Heartbeat:Connect(function()
		lRoot.CFrame = CFrame.new(0, 999999, 0)
		lRoot.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
	end)
	Wait(1)
	ClearLoop("fling")
	lRoot.CFrame = origCF
	lRoot.AssemblyAngularVelocity = Vector3.zero
	DoNotif("Flinged " .. target.Name)
end)
cmd.add("invisfling", "Enables invisible fling", function()
	if loops.invisfling then return DoNotif("Already enabled") end
	loops.invisfling = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		if root then
			root.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
			root.AssemblyLinearVelocity = Vector3.new(0, 50, 0)
		end
	end)
	DoNotif("Invisible fling enabled")
end)
cmd.add("uninvisfling", "Disables invisible fling", function()
	ClearLoop("invisfling")
	local root = getRoot()
	if root then root.AssemblyAngularVelocity = Vector3.zero end
end)
cmd.addArg("annoy", "Annoys the given player [playername]", function(name)
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	if loops.annoy then ClearLoop("annoy") end
	loops.annoy = RunService.Heartbeat:Connect(function()
		local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		local lRoot = getRoot()
		if tRoot and lRoot then
			lRoot.CFrame = tRoot.CFrame * CFrame.new(math.random(-3, 3), 0, math.random(-3, 3))
		end
	end)
	DoNotif("Annoying " .. target.Name)
end)
cmd.add("unannoy", "Stops the annoy command", function()
	ClearLoop("annoy")
	DoNotif("Stopped annoying")
end)
cmd.addArg("orbit", "Orbit around a player [playername]", function(name)
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	if loops.orbit then ClearLoop("orbit") end
	local angle = 0
	loops.orbit = RunService.RenderStepped:Connect(function()
		angle = angle + 0.05
		local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		local lRoot = getRoot()
		if tRoot and lRoot then
			lRoot.CFrame = tRoot.CFrame * CFrame.new(math.cos(angle) * 5, 0, math.sin(angle) * 5)
		end
	end)
	DoNotif("Orbiting " .. target.Name)
end)
cmd.add("unorbit", "Stop orbiting", function()
	ClearLoop("orbit")
end)
cmd.addArg("headbang", "Bang them in the mouth [playername]", function(name)
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	if loops.headbang then ClearLoop("headbang") end
	local hum = getHum()
	if not hum then return end
	local anim = InstanceNew("Animation", {AnimationId = "rbxassetid://5918726674"})
	local track = hum:LoadAnimation(anim)
	track:Play(0.1, 1, 1)
	loops.headbang = RunService.RenderStepped:Connect(function()
		local tHead = target.Character and target.Character:FindFirstChild("Head")
		local lRoot = getRoot()
		if tHead and lRoot then
			lRoot.CFrame = tHead.CFrame * CFrame.new(0, 0, -1.2)
		end
	end)
	DoNotif("Headbanging " .. target.Name)
end)
cmd.add("unheadbang", "Stops headbang", function()
	ClearLoop("headbang")
	local hum = getHum()
	if hum then for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop() end end
end)
cmd.addArg("headsit", "Sit on someone's head [playername]", function(name)
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	if loops.headsit then ClearLoop("headsit") end
	local hum = getHum()
	if hum then hum.Sit = true end
	loops.headsit = RunService.RenderStepped:Connect(function()
		local tHead = target.Character and target.Character:FindFirstChild("Head")
		local lRoot = getRoot()
		if tHead and lRoot then
			lRoot.CFrame = tHead.CFrame * CFrame.new(0, 1.5, 0)
		end
	end)
	DoNotif("Headsitting " .. target.Name)
end)
cmd.add("unheadsit", "Stop the headsit command", function()
	ClearLoop("headsit")
	local hum = getHum()
	if hum then hum.Sit = false end
end)
cmd.add("firework", "Firework particles", function()
	local root = getRoot()
	if not root then return end
	local firePart = InstanceNew("Part", {Anchored = true, CanCollide = false, Transparency = 1, CFrame = root.CFrame + Vector3.new(0, 5, 0), Parent = Workspace})
	local fire = InstanceNew("Fire", {Size = 15, Heat = 10, Parent = firePart})
	Defer(function() Wait(3) firePart:Destroy() end)
end)
cmd.add("light", "Gives your player dynamic light", function()
	local head = getHead()
	if head then
		InstanceNew("PointLight", {Brightness = 1, Range = 30, Parent = head})
	end
end)
cmd.add("unlight", "Removes dynamic light", function()
	local head = getHead()
	if head then
		for _, v in pairs(head:GetChildren()) do
			if v:IsA("PointLight") then v:Destroy() end
		end
	end
end)

-- ===================== WORKSPACE MANIPULATION =====================
cmd.addArg("delete", "Removes any part with a certain name [partname]", function(name)
	for _, desc in pairs(Workspace:GetDescendants()) do
		if Lower(desc.Name) == Lower(name) then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Deleted: " .. name)
end)
cmd.addArg("deletefind", "Removes any part containing name [text]", function(name)
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and Lower(desc.Name):find(Lower(name)) then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Deleted find: " .. name)
end)
cmd.addArg("deleteclass", "Removes parts of a classname [classname]", function(name)
	for _, desc in pairs(Workspace:GetDescendants()) do
		if Lower(desc.ClassName) == Lower(name) then pcall(function() desc:Destroy() end) end
	end
	DoNotif("Deleted class: " .. name)
end)
local partsizeData = {exact = {}, partial = {}, orig = {}}
local function cachePart(p)
	if not (p and p.Parent) then return end
	if not partsizeData.orig[p] then
		partsizeData.orig[p] = {Size = p.Size, Transparency = p.Transparency, CanCollide = p.CanCollide, Material = p.Material, Color = p.Color}
	end
end
local function applyPartsize(p, sizeVec)
	if not (p and p.Parent and p:IsA("BasePart")) then return end
	cachePart(p)
	pcall(function()
		p.Size = sizeVec
		p.Transparency = 0.5
		p.CanCollide = false
		p.Material = Enum.Material.Neon
		p.Color = Color3.new(0, 0, 0)
	end)
end
local function restorePart(p)
	local pr = partsizeData.orig[p]
	if pr and p and p.Parent then
		pcall(function()
			p.Size = pr.Size
			p.Transparency = pr.Transparency
			p.CanCollide = pr.CanCollide
			p.Material = pr.Material
			p.Color = pr.Color
		end)
	end
	partsizeData.orig[p] = nil
end
cmd.addArg("partsize", "Grow part exact name [name size]", function(arg)
	local name, s = arg:match("^(.-)%s+(.+)$")
	if not name or not s then return DoNotif("Usage: partsize name size") end
	local n = tonumber(s)
	if not n then return DoNotif("Invalid size") end
	n = math.clamp(n, 0.1, 10000)
	partsizeData.exact[Lower(name)] = Vector3.new(n, n, n)
	local count = 0
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and Lower(desc.Name) == Lower(name) then
			applyPartsize(desc, Vector3.new(n, n, n))
			count = count + 1
		end
	end
	DoNotif("Partsize " .. name .. " = " .. n .. " (" .. count .. " parts)")
end, true)
cmd.addArg("partsizefind", "Grow part partial name [term size]", function(arg)
	local name, s = arg:match("^(.-)%s+(.+)$")
	if not name or not s then return DoNotif("Usage: partsizefind term size") end
	local n = tonumber(s)
	if not n then return DoNotif("Invalid size") end
	n = math.clamp(n, 0.1, 10000)
	partsizeData.partial[Lower(name)] = Vector3.new(n, n, n)
	local count = 0
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and Lower(desc.Name):find(Lower(name), 1, true) then
			applyPartsize(desc, Vector3.new(n, n, n))
			count = count + 1
		end
	end
	DoNotif("Partsizefind " .. name .. " = " .. n .. " (" .. count .. " parts)")
end, true)
cmd.add("unpartsize", "Undo all partsize changes", function()
	for p, _ in pairs(partsizeData.orig) do restorePart(p) end
	partsizeData.exact = {}
	partsizeData.partial = {}
	partsizeData.orig = {}
	DoNotif("Partsize undone")
end)
cmd.add("deleteinvisparts", "Deletes invisible parts", function()
	local count = 0
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and desc.Transparency >= 0.9 then pcall(function() desc:Destroy() end) count = count + 1 end
	end
	DoNotif("Deleted " .. count .. " invisible parts")
end)
cmd.add("clearnilinstances", "Removes nil instances", function()
	local count = 0
	for _, desc in pairs(game:GetDescendants()) do
		if not desc.Parent then pcall(function() desc:Destroy() end) count = count + 1 end
	end
	DoNotif("Cleared " .. count .. " nil instances")
end)
cmd.add("lockws", "Locks the whole workspace", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") then desc.Locked = true end
	end
end)
cmd.add("unlockws", "Unlocks everything in Workspace", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") then desc.Locked = false end
	end
end)
cmd.addArg("bringpart", "Brings a part to your character [partname]", function(name)
	local root = getRoot()
	if not root then return end
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and Lower(desc.Name) == Lower(name) then
			desc.CFrame = root.CFrame * CFrame.new(0, 0, -3)
		end
	end
end)
cmd.addArg("bringpartfind", "Brings all parts containing name [text]", function(name)
	local root = getRoot()
	if not root then return end
	local count = 0
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and Lower(desc.Name):find(Lower(name)) then
			desc.CFrame = root.CFrame * CFrame.new(0, 0, -3 - count * 3)
			count = count + 1
		end
	end
	DoNotif("Brought " .. count .. " parts")
end)
cmd.addArg("bringmodel", "Brings a model to your character [modelname]", function(name)
	local root = getRoot()
	if not root then return end
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and Lower(desc.Name) == Lower(name) and desc:FindFirstChildOfClass("PrimaryPart") then
			desc:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 0, -5))
		end
	end
end)
cmd.add("bringnpcs", "Brings NPCs", function()
	local root = getRoot()
	if not root then return end
	local count = 0
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) and desc:FindFirstChildOfClass("PrimaryPart") then
			pcall(function() desc:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 0, -5 - count * 5)) end)
			count = count + 1
		end
	end
	DoNotif("Brought " .. count .. " NPCs")
end)
cmd.addArg("gotopart", "Teleports you to a part [partname]", function(name)
	local root = getRoot()
	if not root then return end
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and Lower(desc.Name) == Lower(name) then
			root.CFrame = desc.CFrame * CFrame.new(0, 3, 0)
			return
		end
	end
	DoNotif("Part not found")
end)
cmd.addArg("gotopartfind", "Teleports you to part containing name [text]", function(name)
	local root = getRoot()
	if not root then return end
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and Lower(desc.Name):find(Lower(name)) then
			root.CFrame = desc.CFrame * CFrame.new(0, 3, 0)
			return
		end
	end
	DoNotif("Part not found")
end)
cmd.add("gotonpcs", "Teleports to each NPC", function()
	local root = getRoot()
	if not root then return end
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) and desc:FindFirstChild("HumanoidRootPart") then
			root.CFrame = desc.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
			Wait(0.5)
		end
	end
end)
cmd.add("loopbringnpcs", "Loops NPC bringing", function()
	if loops.loopbringnpcs then ClearLoop("loopbringnpcs") end
	loops.loopbringnpcs = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		if root then
			for _, desc in pairs(Workspace:GetDescendants()) do
				if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) and desc:FindFirstChild("HumanoidRootPart") then
					pcall(function() desc.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, -5) end)
				end
			end
		end
	end)
	DoNotif("Loop bring NPCs enabled")
end)
cmd.add("unloopbringnpcs", "Stops NPC bring loop", function()
	ClearLoop("loopbringnpcs")
end)
cmd.addArg("killnpcs", "Kills NPCs", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) then
			pcall(function() desc:FindFirstChildOfClass("Humanoid").Health = 0 end)
		end
	end
end)
cmd.add("voidnpcs", "Teleports NPCs to void", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) and desc:FindFirstChild("HumanoidRootPart") then
			pcall(function() desc.HumanoidRootPart.CFrame = CFrame.new(0, -500, 0) end)
		end
	end
end)
cmd.addArg("npcwalkspeed", "Sets all NPC WalkSpeed [value]", function(val)
	local n = tonumber(val) or 16
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) then
			pcall(function() desc:FindFirstChildOfClass("Humanoid").WalkSpeed = n end)
		end
	end
end)
cmd.addArg("npcjumppower", "Sets all NPC JumpPower [value]", function(val)
	local n = tonumber(val) or 50
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) then
			pcall(function() desc:FindFirstChildOfClass("Humanoid").JumpPower = n end)
		end
	end
end)
cmd.add("sitnpcs", "Makes NPCs sit", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) then
			pcall(function() desc:FindFirstChildOfClass("Humanoid").Sit = true end)
		end
	end
end)
cmd.add("unsitnpcs", "Makes NPCs unsit", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("Model") and desc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(desc) then
			pcall(function() desc:FindFirstChildOfClass("Humanoid").Sit = false end)
		end
	end
end)
cmd.add("tpua", "Brings every unanchored part to the player", function()
	local root = getRoot()
	if not root then return end
	local count = 0
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and not desc.Anchored and not Players:GetPlayerFromCharacter(desc.Parent) then
			pcall(function() desc.CFrame = root.CFrame * CFrame.new(0, 0, -5) end)
			count = count + 1
		end
	end
	DoNotif("Brought " .. count .. " unanchored parts")
end)
cmd.add("freezeunanchored", "Freezes unanchored non-character parts", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and not desc.Anchored and not Players:GetPlayerFromCharacter(desc.Parent) then
			desc.Anchored = true
		end
	end
end)
cmd.add("thawunanchored", "Thaws frozen parts", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BasePart") and desc.Anchored and not Players:GetPlayerFromCharacter(desc.Parent) then
			desc.Anchored = false
		end
	end
end)
cmd.add("blackhole", "Makes unanchored parts teleport to the black hole", function()
	if loops.blackhole then return DoNotif("Already enabled") end
	local folder = InstanceNew("Folder", {Parent = Workspace})
	local anchorPart = InstanceNew("Part", {Anchored = true, CanCollide = false, Transparency = 1, Parent = folder})
	local attachment = InstanceNew("Attachment", {Parent = anchorPart})
	loops.blackhole = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		if root then anchorPart.CFrame = root.CFrame end
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("BasePart") and not desc.Anchored and not Players:GetPlayerFromCharacter(desc.Parent) then
				pcall(function()
					if not desc:FindFirstChild("BlackholeAlign") then
						local att = Instance.new("Attachment", desc)
						local align = Instance.new("AlignPosition", desc)
						align.Name = "BlackholeAlign"
						align.Attachment0 = att
						align.Attachment1 = attachment
						align.MaxForce = 1e9
						align.Responsiveness = 200
					end
				end)
			end
		end
	end)
	DoNotif("Blackhole enabled")
end)
cmd.add("noblackhole", "Disables blackhole", function()
	ClearLoop("blackhole")
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc.Name == "BlackholeAlign" then pcall(function() desc:Destroy() end) end
	end
end)
cmd.add("fireclickdetectors", "Fires every ClickDetector", function()
	local count = 0
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("ClickDetector") then pcall(fireclickdetector, desc) count = count + 1 end
	end
	DoNotif("Fired " .. count .. " click detectors")
end)
cmd.add("noclickdetectorlimits", "Sets all ClickDetectors MaxActivationDistance to math.huge", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("ClickDetector") then desc.MaxActivationDistance = math.huge end
	end
end)
cmd.add("fireproximityprompts", "Fires every ProximityPrompt", function()
	local count = 0
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("ProximityPrompt") and desc.Enabled then pcall(fireproximityprompt, desc) count = count + 1 end
	end
	DoNotif("Fired " .. count .. " proximity prompts")
end)
cmd.add("removeads", "Removes billboard advertisements", function()
	for _, desc in pairs(Workspace:GetDescendants()) do
		if desc:IsA("BillboardGui") and desc.Name:lower():find("ad") then pcall(function() desc:Destroy() end) end
	end
end)
-- ===================== NETWORK & REMOTE =====================
cmd.addArg("noremote", "Blocks remote firing [remotename]", function(name)
	if loops.noremote then ClearLoop("noremote") end
	blockedRemotes[name:lower()] = true
	DoNotif("Blocked remote: " .. name)
end)
cmd.add("netbypass", "Net bypass", function()
	pcall(function()
		if setfflag then
			setfflag("DebugRLPFromClientLUA", "0")
			setfflag("DataCenterReplicationR ccpUsage", "0")
		end
	end)
	DoNotif("Net bypass enabled")
end)
cmd.add("netless", "Executes netless", function()
	if loops.netless then return DoNotif("Already enabled") end
	loops.netless = RunService.Heartbeat:Connect(function()
		pcall(function()
			local root = getRoot()
			if root then root.Velocity = root.Velocity * Vector3.new(0.01, 1, 0.01) end
		end)
	end)
	DoNotif("Netless enabled")
end)
-- ===================== AUTOMATION =====================
cmd.add("autoclicker", "Provides an autoclicker GUI", function()
	if loops.autoclicker then return DoNotif("Already enabled") end
	loops.autoclicker = Spawn(function()
		while true do
			Wait(0.1)
			pcall(function()
				local mouse = Plr:GetMouse()
				mouse.Button1Down = true
				Wait(0.05)
				mouse.Button1Up = true
			end)
		end
	end)
	DoNotif("Autoclicker enabled")
end)
cmd.add("unautoclicker", "Stops autoclicker", function()
	ClearLoop("autoclicker")
end)
cmd.addArg("autofireclick", "Fires ClickDetectors matching target [name]", function(name)
	local key = "afc_" .. name:lower()
	if loops[key] then ClearLoop(key) end
	loops[key] = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("ClickDetector") and desc.Parent and Lower(desc.Parent.Name) == Lower(name) then
				pcall(fireclickdetector, desc)
			end
		end
	end)
	DoNotif("Auto fire click: " .. name)
end)
cmd.add("unautofireclick", "Stops all AutoFireClick loops", function()
	for k, _ in pairs(loops) do
		if k:sub(1, 4) == "afc_" then ClearLoop(k) end
	end
end)
cmd.addArg("autofireproxi", "Fires ProximityPrompts matching target [name]", function(name)
	local key = "afp_" .. name:lower()
	if loops[key] then ClearLoop(key) end
	loops[key] = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("ProximityPrompt") and desc.Enabled and desc.Parent and Lower(desc.Parent.Name) == Lower(name) then
				pcall(fireproximityprompt, desc)
			end
		end
	end)
	DoNotif("Auto fire proxi: " .. name)
end)
cmd.add("unautofireproxi", "Stops AutoFireProxi loops", function()
	for k, _ in pairs(loops) do
		if k:sub(1, 4) == "afp_" then ClearLoop(k) end
	end
end)
cmd.addArg("autotouch", "Fires TouchInterests matching target [name]", function(name)
	local key = "at_" .. name:lower()
	if loops[key] then ClearLoop(key) end
	loops[key] = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("TouchTransmitter") and desc.Parent and Lower(desc.Parent.Name) == Lower(name) then
				pcall(function() desc.Parent.CFrame = getRoot().CFrame end)
			end
		end
	end)
	DoNotif("Auto touch: " .. name)
end)
cmd.add("unautotouch", "Stops AutoTouch loops", function()
	for k, _ in pairs(loops) do
		if k:sub(1, 3) == "at_" then ClearLoop(k) end
	end
end)
cmd.add("autoflashback", "Auto-teleports to your last death point", function()
	if loops.autoflashback then return DoNotif("Already enabled") end
	local lastDeath = nil
	loops.autoflashback = Plr.CharacterAdded:Connect(function()
		Wait(1)
		if lastDeath then
			local root = getRoot()
			if root then root.CFrame = lastDeath end
		end
	end)
	loops.autoflashbackPos = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum and hum.Health <= 0 then
			local root = getRoot()
			if root then lastDeath = root.CFrame end
		end
	end)
	DoNotif("Autoflashback enabled")
end)
cmd.add("unautoflashback", "Stops autoflashback", function()
	ClearLoop("autoflashback")
	ClearLoop("autoflashbackPos")
end)
cmd.add("autorespawn", "Teleports you back to your death position after respawn", function()
	if loops.autorespawn then return DoNotif("Already enabled") end
	local lastPos = nil
	loops.autorespawn = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum and hum.Health <= 0 then
			local root = getRoot()
			if root then lastPos = root.CFrame end
		end
	end)
	loops.autorespawnTele = Plr.CharacterAdded:Connect(function()
		Wait(1)
		if lastPos then
			local root = getRoot()
			if root then root.CFrame = lastPos end
		end
	end)
	DoNotif("Auto respawn enabled")
end)
cmd.add("unautorespawn", "Stops autorespawn", function()
	ClearLoop("autorespawn")
	ClearLoop("autorespawnTele")
end)
cmd.add("loopgrabtools", "Loop grabs dropped tools", function()
	if loops.loopgrabtools then ClearLoop("loopgrabtools") end
	loops.loopgrabtools = RunService.Heartbeat:Connect(function()
		local root = getRoot()
		if root then
			for _, tool in pairs(Workspace:GetChildren()) do
				if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
					pcall(function()
						local att = Instance.new("Attachment", tool.Handle)
						local align = Instance.new("AlignPosition", tool.Handle)
						att.Position = Vector3.new(0, 0, 0)
						align.Attachment0 = att
						align.Mode = Enum.AttachmentPositionMode.OneAttachment
						align.Position = root.Position
						align.Responsiveness = 200
						align.MaxForce = 1e9
					end)
				end
			end
		end
	end)
end)
cmd.add("unloopgrabtools", "Stops loop grab", function()
	ClearLoop("loopgrabtools")
end)
cmd.add("loopdroptools", "Loop drops your tools", function()
	if loops.loopdrop then ClearLoop("loopdrop") end
	loops.loopdrop = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, tool in pairs(char:GetChildren()) do
				if tool:IsA("Tool") then tool.Parent = Workspace end
			end
		end
	end)
end)
cmd.add("unloopdroptools", "Stops loop drop", function()
	ClearLoop("loopdrop")
end)
cmd.add("loopcbring", "Continuously brings the player", function(name)
	if loops.loopcbring then ClearLoop("loopcbring") end
	local target = getPlr(name)
	if not target then return DoNotif("Player not found") end
	loops.loopcbring = RunService.Heartbeat:Connect(function()
		local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		local lRoot = getRoot()
		if tRoot and lRoot then lRoot.CFrame = tRoot.CFrame end
	end)
end)
cmd.add("unloopcbring", "Disable looped client bring", function()
	ClearLoop("loopcbring")
end)
cmd.add("unloop", "Stops all active command loops", function()
	for k, v in pairs(loops) do
		if typeof(v) == "RBXScriptConnection" then pcall(function() v:Disconnect() end)
		elseif typeof(v) == "Instance" then pcall(function() v:Destroy() end)
		elseif type(v) == "thread" then pcall(function() task.cancel(v) end) end
	end
	loops = {}
	DoNotif("All loops stopped")
end)

-- ===================== INFORMATION & UTILITY =====================
cmd.add("players", "Lists all players in server", function()
	local list = {}
	for _, p in pairs(Players:GetPlayers()) do table.insert(list, p.Name) end
	DoNotif(table.concat(list, ", "))
end)
cmd.add("fps", "Shows your frames per second", function()
	local fps = math.floor(1 / RunService.RenderStepped:Wait())
	DoNotif("FPS: " .. fps)
end)
cmd.add("ping", "Shows your network latency", function()
	DoNotif("Ping: " .. Plr:GetNetworkPing() * 1000 .. "ms")
end)
cmd.add("pos", "Shows your current position", function()
	local root = getRoot()
	if root then DoNotif("Position: " .. tostring(root.Position)) end
end)
cmd.add("memory", "Shows your current memory usage", function()
	local mem = math.floor(collectgarbage("count") / 1024)
	DoNotif("Memory: " .. mem .. "MB")
end)
cmd.addArg("chat", "Chats for you [message]", function(msg)
	pcall(function()
		LocalPlayer:Chat(msg)
	end)
end)
cmd.add("console", "Opens developer console", function()
	StarterGui:SetCore("DevConsoleVisible", true)
end)
cmd.add("shiftlock", "Toggles shiftlock", function()
	Plr.DevEnableMouseLock = not Plr.DevEnableMouseLock
end)
cmd.add("firstp", "Makes you go in first person mode", function()
	Plr.CameraMinZoomDistance = 0.5
	Plr.CameraMaxZoomDistance = 0.5
end)
cmd.add("thirdp", "Makes you go in third person mode", function()
	Plr.CameraMinZoomDistance = 10
	Plr.CameraMaxZoomDistance = 10
end)
cmd.add("rejoin", "Rejoin the game", function()
	pcall(function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Plr)
	end)
end)
cmd.add("serverhop", "Server hop", function()
	pcall(function()
		local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
		for _, s in pairs(servers.data) do
			if s.id ~= game.JobId and s.playing < s.maxPlayers then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Plr)
				break
			end
		end
	end)
end)
cmd.add("gameid", "Copies the GameId/UniverseId", function()
	if setclipboard then setclipboard(tostring(game.GameId)) end
	DoNotif("Game ID copied: " .. game.GameId)
end)
cmd.add("placeid", "Copies the PlaceId", function()
	if setclipboard then setclipboard(tostring(game.PlaceId)) end
	DoNotif("Place ID copied: " .. game.PlaceId)
end)
cmd.add("jobid", "Copies your job id", function()
	if setclipboard then setclipboard(tostring(game.JobId)) end
	DoNotif("Job ID copied")
end)
cmd.addArg("copyname", "Copies the username of the target [playername]", function(name)
	local target = getPlr(name)
	if target and setclipboard then setclipboard(target.Name) DoNotif("Copied: " .. target.Name) end
end)
cmd.addArg("copyid", "Copies the UserId of the target [playername]", function(name)
	local target = getPlr(name)
	if target and setclipboard then setclipboard(tostring(target.UserId)) DoNotif("Copied: " .. target.UserId) end
end)
cmd.add("gethealth", "Shows your current health", function()
	local hum = getHum()
	if hum then DoNotif("Health: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)) end
end)
cmd.add("getmass", "Get your mass", function()
	local char = Plr.Character
	if not char then return end
	local total = 0
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then total = total + part:GetMass() end
	end
	DoNotif("Mass: " .. math.floor(total))
end)
cmd.add("accountage", "Tells the account age", function()
	DoNotif("Account age: " .. Plr.AccountAge .. " days")
end)
cmd.addArg("copydisplay", "Copies the display name [playername]", function(name)
	local target = getPlr(name)
	if target and setclipboard then setclipboard(target.DisplayName) DoNotif("Copied: " .. target.DisplayName) end
end)
cmd.add("discord", "Copy an invite link", function()
	if setclipboard then setclipboard("https://discord.gg/namelessadmin") end
	DoNotif("Discord link copied")
end)
cmd.add("commandcount", "Counts how many commands NA has", function()
	local count = 0
	for _ in pairs(Cmds) do count = count + 1 end
	DoNotif("Commands: " .. count)
end)
cmd.add("notepad", "Integrated notepad", function()
	local sg = InstanceNew("ScreenGui", {Parent = CG})
	local frame = InstanceNew("Frame", {Position = UDim2.new(0.3, 0, 0.3, 0), Size = UDim2.new(0.4, 0, 0.4, 0), BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0, Parent = sg})
	local tb = InstanceNew("TextBox", {Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), BackgroundColor3 = Color3.fromRGB(40, 40, 40), TextColor3 = Color3.fromRGB(255, 255, 255), Text = "", TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, MultiLine = true, ClearTextOnFocus = false, Font = Enum.Font.RobotoMono, TextSize = 14, Parent = frame})
end)
cmd.add("clear", "Clears output", function()
	pcall(function() rconsoleclear() end)
end)
cmd.add("gameinfo", "Shows info about the game", function()
	DoNotif("Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
end)
cmd.add("stats", "Shows FPS, physics, network and memory stats", function()
	DoNotif("FPS: " .. math.floor(1 / RunService.RenderStepped:Wait()) .. " | Ping: " .. math.floor(Plr:GetNetworkPing() * 1000) .. "ms | Mem: " .. math.floor(collectgarbage("count") / 1024) .. "MB")
end)
cmd.add("loopwalkspeed", "Loop walkspeed [value]", function(val)
	if loops.loopws then ClearLoop("loopws") end
	local n = tonumber(val) or 16
	loops.loopws = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum then hum.WalkSpeed = n end
	end)
end)
cmd.add("unloopwalkspeed", "Disable loop walkspeed", function()
	ClearLoop("loopws")
	local hum = getHum()
	if hum then hum.WalkSpeed = 16 end
end)
cmd.add("loopjumppower", "Loop JumpPower [value]", function(val)
	if loops.loopjp then ClearLoop("loopjp") end
	local n = tonumber(val) or 50
	loops.loopjp = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum then hum.JumpPower = n end
	end)
end)
cmd.add("unloopjumppower", "Disable loop JumpPower", function()
	ClearLoop("loopjp")
end)
cmd.add("loopjump", "Continuously jump [value]", function(val)
	if loops.loopjump then ClearLoop("loopjump") end
	local n = tonumber(val) or 2
	loops.loopjump = Spawn(function()
		while true do
			Wait(n)
			local hum = getHum()
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end)
end)
cmd.add("unloopjump", "Stop continuous jumping", function()
	ClearLoop("loopjump")
end)
cmd.add("loopnight", "Moonlight", function()
	if loops.loopnight then ClearLoop("loopnight") end
	loops.loopnight = RunService.Heartbeat:Connect(function()
		Lighting.ClockTime = 0
	end)
end)
cmd.add("unloopnight", "No more moonlight", function()
	ClearLoop("loopnight")
end)
cmd.add("loopday", "Sunshine", function()
	if loops.loopday then ClearLoop("loopday") end
	loops.loopday = RunService.Heartbeat:Connect(function()
		Lighting.ClockTime = 12
	end)
end)
cmd.add("unloopday", "No more sunshine", function()
	ClearLoop("loopday")
end)
cmd.add("loopnodrag", "No character drag", function()
	if loops.loopnodrag then ClearLoop("loopnodrag") end
	loops.loopnodrag = RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum then pcall(function() hum.PlatformStand = false end) end
	end)
end)
cmd.add("unloopnodrag", "Re-enable drag", function()
	ClearLoop("loopnodrag")
end)
cmd.add("loopfling", "Loop flings unanchored parts", function()
	if loops.loopfling then ClearLoop("loopfling") end
	loops.loopfling = RunService.Heartbeat:Connect(function()
		for _, desc in pairs(Workspace:GetDescendants()) do
			if desc:IsA("BasePart") and not desc.Anchored and not Players:GetPlayerFromCharacter(desc.Parent) then
				desc.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
			end
		end
	end)
end)
cmd.add("unloopfling", "Stops loop flinging", function()
	ClearLoop("loopfling")
end)
cmd.add("loopspook", "Teleports next to a player repeatedly", function(name)
	if loops.loopspook then ClearLoop("loopspook") end
	local target = getPlr(name)
	if not target or target == Plr then return DoNotif("Invalid target") end
	loops.loopspook = RunService.Heartbeat:Connect(function()
		local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		local lRoot = getRoot()
		if tRoot and lRoot then lRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -2) end
	end)
end)
cmd.add("unloopspook", "Stops the loopspook command", function()
	ClearLoop("loopspook")
end)
-- ===================== SERVER-SIDE (IMPOSSIBLE) COMMANDS =====================
local function serverSide(cmdname)
	cmd.add(cmdname, "Server-side command - requires server access", function()
		DoNotif(cmdname .. " requires server access (not possible client-side)")
	end)
end
serverSide("admin")
serverSide("unadmin")
serverSide("mute")
serverSide("unmute")
serverSide("servershutdown")
serverSide("shutdown")
serverSide("timestop")
serverSide("untimestop")
serverSide("bubblechat")
serverSide("unbubblechat")
serverSide("r15")
serverSide("r6")
serverSide("freegamepass")
serverSide("privatemessage")
serverSide("resetfilter")
serverSide("checkrfe")
serverSide("ownerid")
serverSide("massfollowedinto")
serverSide("rolewatch")
serverSide("rolewatchstop")
-- ===================== CANCEL TELEPORT =====================
cmd.add("cancelteleport", "Cancel an in-progress teleport", function()
	pcall(function() TeleportService:CancelTeleport() end)
end)
cmd.add("cancelteleportloop", "Repeatedly cancels in-progress teleport", function()
	if loops.canceltploop then ClearLoop("canceltploop") end
	loops.canceltploop = Spawn(function()
		while true do
			Wait(0.1)
			pcall(function() TeleportService:CancelTeleport() end)
		end
	end)
end)
cmd.add("uncancelteleportloop", "Disable cancelteleport loop", function()
	ClearLoop("canceltploop")
end)
-- ===================== ADDITIONAL CLIENT-SIDE =====================
cmd.add("adonisbypass", "Bypasses adonis admin detection", function()
	pcall(function()
		if getrawmetatable then
			local mt = getrawmetatable(game)
			setreadonly(mt, false)
			local oldIndex = mt.__index
			mt.__index = newcclosure(function(self, key)
				if tostring(key):lower() == "kick" then return function() end end
				return oldIndex(self, key)
			end)
			setreadonly(mt, true)
		end
	end)
	DoNotif("Adonis bypass enabled")
end)
cmd.add("inherit", "Inherit character appearance from target", function(name)
	local target = getPlr(name)
	if not target then return DoNotif("Player not found") end
	pcall(function() Plr.CharacterAppearanceId = target.UserId end)
end)
cmd.add("setspawn", "Sets your spawn point", function()
	local root = getRoot()
	if root then
		local pos = root.Position
		for _, v in pairs(Workspace:GetChildren()) do
			if v:IsA("SpawnLocation") then
				v.CFrame = CFrame.new(pos)
				DoNotif("Spawn set")
				return
			end
		end
		local sp = InstanceNew("SpawnLocation", {CFrame = CFrame.new(pos), Anchored = true, Size = Vector3.new(5, 1, 5), Parent = Workspace})
		DoNotif("Spawn created")
	end
end)
cmd.add("aimbot", "Aimbot GUI (Vyperia)", function()
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/NewAimbot.lua"))()
	end)
	DoNotif("Aimbot loaded!")
end)
cmd.add("nocooldown", "No cooldown on tools", function()
	if loops.nocooldown then return DoNotif("Already enabled") end
	loops.nocooldown = RunService.Heartbeat:Connect(function()
		local char = Plr.Character
		if char then
			for _, tool in pairs(char:GetChildren()) do
				if tool:IsA("Tool") then
					pcall(function() tool:GetAttribute("Cooldown", 0) end)
				end
			end
		end
	end)
end)
cmd.add("unnocooldown", "Disable cooldown override", function()
	ClearLoop("nocooldown")
end)
cmd.add("instantrespawn", "Respawn instantly", function()
	pcall(function() Plr:LoadCharacter() end)
end)
cmd.add("spam", "Spams chat [message]", function(msg)
	if loops.spam then ClearLoop("spam") end
	loops.spam = Spawn(function()
		while true do
			Wait(0.5)
			pcall(function() LocalPlayer:Chat(msg or "lol") end)
		end
	end)
end)
cmd.add("unspam", "Stop spam", function()
	ClearLoop("spam")
end)
cmd.add("unc", "UNC test", function()
	local tests = {}
	pcall(function() hookmetamethod(game, "__index", newcclosure(function() end)) tests.hookmeta = true end)
	pcall(function() getrawmetatable(game) tests.rawmeta = true end)
	pcall(function() setreadonly({}, false) tests.readonly = true end)
	pcall(function() getnamecallmethod() tests.namecall = true end)
	local passed = 0
	for _, v in pairs(tests) do if v then passed = passed + 1 end end
	DoNotif("UNC: " .. passed .. " tests passed")
end)
-- ===================== LOADSTRING =====================
cmd.add("loadstring", "Run code using loadstring [code]", function(code)
	if loadstring then
		local func, err = loadstring(code)
		if func then
			pcall(func)
			DoNotif("Code executed")
		else
			DoNotif("Error: " .. tostring(err))
		end
	else
		DoNotif("loadstring not available")
	end
end)
-- ===================== SAVEINSTANCE =====================
cmd.add("saveinstance", "Saves the game", function()
	pcall(function()
		if saveinstance then saveinstance() DoNotif("Game saved") else DoNotif("saveinstance not available") end
	end)
end)
-- ===================== UNLOAD =====================
cmd.add("unload", "Unload Nameless Admin", function()
	for k, v in pairs(loops) do
		if typeof(v) == "RBXScriptConnection" then pcall(function() v:Disconnect() end)
		elseif typeof(v) == "Instance" then pcall(function() v:Destroy() end)
		elseif type(v) == "thread" then pcall(function() task.cancel(v) end) end
	end
	loops = {}
	espList = {}
	chamsList = {}
	pcall(function() CG:ClearAllChildren() end)
	pcall(function() Plr.PlayerGui:ClearAllChildren() end)
	DoNotif("Unloaded")
end)
cmd.add("exit", "Close down Roblox", function()
	pcall(function() game:Shutdown() end)
end)

-- ===================== UI CODE =====================
local function createUI()
	local existing = CG:FindFirstChild("CustomCommandsUI") or Plr.PlayerGui:FindFirstChild("CustomCommandsUI")
	if existing then existing:Destroy() end

	local sg = InstanceNew("ScreenGui", {Name = "CustomCommandsUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
	pcall(function() sg.Parent = CG end)
	if not sg.Parent then sg.Parent = Plr.PlayerGui end

	local mainFrame = InstanceNew("Frame", {
		Position = UDim2.new(0.35, 0, 0.25, 0),
		Size = UDim2.new(0.3, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(25, 25, 30),
		BorderSizePixel = 0,
		Parent = sg
	})
	InstanceNew("UICorner", {CornerRadius = UDim.new(0, 8), Parent = mainFrame})

	local title = InstanceNew("TextLabel", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(35, 35, 45),
		Text = "Custom Commands Panel",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		Parent = mainFrame
	})
	InstanceNew("UICorner", {CornerRadius = UDim.new(0, 8), Parent = title})

	local closeBtn = InstanceNew("TextButton", {
		Position = UDim2.new(1, -30, 0, 5),
		Size = UDim2.new(0, 25, 0, 25),
		BackgroundColor3 = Color3.fromRGB(200, 50, 50),
		Text = "X",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Parent = title
	})
	InstanceNew("UICorner", {CornerRadius = UDim.new(0, 4), Parent = closeBtn})
	closeBtn.MouseButton1Click:Connect(function() sg.Enabled = false end)

	local searchBox = InstanceNew("TextBox", {
		Position = UDim2.new(0, 5, 0, 45),
		Size = UDim2.new(1, -10, 0, 25),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		PlaceholderText = "Search commands...",
		PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		ClearTextOnFocus = false,
		Parent = mainFrame
	})
	InstanceNew("UICorner", {CornerRadius = UDim.new(0, 4), Parent = searchBox})

	local scrollFrame = InstanceNew("ScrollingFrame", {
		Position = UDim2.new(0, 5, 0, 75),
		Size = UDim2.new(1, -10, 1, -110),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = mainFrame
	})
	InstanceNew("UIListLayout", {Padding = UDim.new(0, 2), Parent = scrollFrame})

	local inputBox = InstanceNew("TextBox", {
		Position = UDim2.new(0, 5, 1, -30),
		Size = UDim2.new(1, -10, 0, 25),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		PlaceholderText = "Type command...",
		PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		ClearTextOnFocus = false,
		Parent = mainFrame
	})
	InstanceNew("UICorner", {CornerRadius = UDim.new(0, 4), Parent = inputBox})

	local execBtn = InstanceNew("TextButton", {
		Position = UDim2.new(1, -60, 1, -30),
		Size = UDim2.new(0, 55, 0, 25),
		BackgroundColor3 = Color3.fromRGB(50, 150, 50),
		Text = "Exec",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		Parent = mainFrame
	})
	InstanceNew("UICorner", {CornerRadius = UDim.new(0, 4), Parent = execBtn})

	local function buildList(filter)
		for _, child in pairs(scrollFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		local count = 0
		for name, desc in pairs(CmdsList) do
			if not filter or Lower(name):find(Lower(filter)) or Lower(desc):find(Lower(filter)) then
				local btn = InstanceNew("TextButton", {
					Size = UDim2.new(1, -5, 0, 22),
					BackgroundColor3 = Color3.fromRGB(35, 35, 45),
					Text = "  " .. name .. " - " .. desc,
					TextColor3 = Color3.fromRGB(200, 200, 200),
					TextXAlignment = Enum.TextXAlignment.Left,
					Font = Enum.Font.Gotham,
					TextSize = 11,
					Parent = scrollFrame
				})
				InstanceNew("UICorner", {CornerRadius = UDim.new(0, 3), Parent = btn})
				btn.MouseButton1Click:Connect(function()
					inputBox.Text = name
					pcall(function() cmd.run(name) end)
				end)
				btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80) end)
				btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end)
				count = count + 1
			end
		end
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 24)
	end

	buildList()

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		buildList(searchBox.Text ~= "" and searchBox.Text or nil)
	end)

	execBtn.MouseButton1Click:Connect(function()
		if inputBox.Text ~= "" then cmd.run(inputBox.Text) end
	end)
	inputBox.FocusLost:Connect(function(enterPressed)
		if enterPressed and inputBox.Text ~= "" then cmd.run(inputBox.Text) end
	end)

	local dragging, dragStart, startPos
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	return sg
end

local ui = createUI()
ui.Enabled = true

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		ui.Enabled = not ui.Enabled
	end
end)

DoNotif("Custom Commands Panel loaded! Press RightShift to toggle UI.")
end)
