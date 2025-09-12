local BossAncientEvil = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local States = {
	["Spawning"] = {
		Enter = function(self)
			self:PlaySound("ExplosionMassive")
			self:PlaySound("AncientEvilLaugh")
			self:AnimationPlay("BossAEIdle")
			task.wait(0.5)
			if self.Active then
				self.StateMachine:SetState("Waiting")
			end
		end,
		Update = function(self)
			-- Spawning behavior handled in Enter function
		end,
		Exit = function(self)
			-- Clean up spawning state if needed
		end,
	},
	["Waiting"] = {
		Enter = function(self)
			self.Target = nil
		end,
		Update = function(self)
			if not self.Active then return end

			self.Target = self:GetClosestPlayer()
			if self.Target then
				self.StateMachine:SetState("Chasing")
				self:AnimationPlay("BossAEWalk")
			end
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Chasing"] = {
		Enter = function(self)
			if not self.Active then return end
			self:AnimationPlay("BossAEWalk")
		end,
		Update = function(self)
			if not self.Active then return end

			if self.Target then
				self:MoveTo(self.Target.Character.HumanoidRootPart.Position)

				if self:DistanceToCharacter(self.Target) < self:GetAttackRange() then
					self:Attack()
				end

				self.Target = self:GetClosestPlayer()
			else
				self.StateMachine:SetState("Waiting")
				self:AnimationStop("BossAEWalk")
			end
		end,
		Exit = function(self)
			self:AnimationStop("BossAEWalk")
		end,
	},
	["Resting"] = {
		Enter = function(self)
			self:AnimationStop("BossAEWalk")
			task.wait(self.RestDuration or 1)
			if self.Active then
				self.StateMachine:SetState("Waiting")
			end
		end,
		Update = function(self)
			-- Resting behavior handled in Enter function
		end,
		Exit = function(self)
			-- Clean up resting state if needed
		end,
	}
}

function BossAncientEvil.new(originalModel: Model, position: Vector3)
	-- Clone the model and set it up
	local model = originalModel:Clone()
	model.Parent = workspace
	model:MoveTo(position)

	-- Create the enemy instance
	local self = setmetatable({}, {__index = BossAncientEvil})

	-- Core properties
	self.Model = model
	self.Root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	self.Humanoid = model:FindFirstChild("Humanoid")
	self.Active = true
	self.Health = 2500
	self.MaxHealth = 2500

	-- State management
	self.State = "Spawning"
	self.Target = nil
	self.RestDuration = 1

	-- Attack pattern management
	self.AttackOrder = {
		"CastAttack",
		"SlashAttack",
		"PullAttack",
		"DashAttack",
		"CastAttack",
		"PushAttack",
		"PentagramAttack",
		"PullAttack",
		"SlashAttack",
		"DashAttack",
		"PullAttack",
		"SlashAttack",
		"DashAttack",
		"SlashAttack",
		"SlashAttack",
		"SlashAttack",
		"DashAttack",
		"DashAttack",
	}
	self.RangeByAttack = {
		DashAttack = 28,
		SlashAttack = 16,
		CastAttack = 128,
		PullAttack = 128,
		PentagramAttack = 64,
	}
	self.AttackIndex = 1
	self.AttackRange = 16

	-- Set up health
	if self.Humanoid then
		self.Humanoid.MaxHealth = self.Health
		self.Humanoid.Health = self.Health
	end

	-- Create state machine
	self.StateMachine = {
		CurrentState = nil,
		SetState = function(stateMachine, newState)
			if self.StateMachine.CurrentState and States[self.StateMachine.CurrentState] and States[self.StateMachine.CurrentState].Exit then
				States[self.StateMachine.CurrentState].Exit(self)
			end

			self.StateMachine.CurrentState = newState
			self.State = newState

			if States[newState] and States[newState].Enter then
				spawn(function()
					States[newState].Enter(self)
				end)
			end
		end,
		Update = function(stateMachine)
			if self.StateMachine.CurrentState and States[self.StateMachine.CurrentState] and States[self.StateMachine.CurrentState].Update then
				States[self.StateMachine.CurrentState].Update(self)
			end
		end
	}

	-- Initialize the state machine
	self.StateMachine:SetState("Spawning")

	-- Start the update loop
	spawn(function()
		while self.Active do
			self.StateMachine:Update()
			self:DieIfDead()
			task.wait(0.1)
		end
	end)

	return self
end

function BossAncientEvil:GetClosestPlayer()
	local closestPlayer = nil
	local closestDistance = math.huge

	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (self.Model:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance < closestDistance then
				closestPlayer = player
				closestDistance = distance
			end
		end
	end

	return closestPlayer
end

function BossAncientEvil:MoveTo(position)
	if self.Humanoid then
		self.Humanoid:MoveTo(position)
	end
end

function BossAncientEvil:DistanceToCharacter(player)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return (self.Model:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude
	end
	return math.huge
end

function BossAncientEvil:FaceTowardsPoint(position)
	local direction = (position - self.Model:GetPivot().Position).Unit
	self.Model:PivotTo(CFrame.lookAt(self.Model:GetPivot().Position, self.Model:GetPivot().Position + direction))
end

function BossAncientEvil:GetPosition()
	return self.Model:GetPivot().Position
end

function BossAncientEvil:GetFootPosition()
	return self.Model:GetPivot().Position + Vector3.new(0, -2, 0)
end

function BossAncientEvil:AnimationPlay(animationName, fadeTime, weight, speed)
	if self.Humanoid then
		local animFolder = self.Model:FindFirstChild("Animations")
		if animFolder and animFolder:FindFirstChild(animationName) then
			local anim = self.Humanoid:LoadAnimation(animFolder[animationName])
			if speed then anim.Speed = speed end
			anim:Play(fadeTime, weight)
			return anim
		end
	end
end

function BossAncientEvil:AnimationStop(animationName)
	if self.Humanoid then
		for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.Name == animationName then
				track:Stop()
			end
		end
	end
end

function BossAncientEvil:GetAttackRange()
	local currentAttack = self.AttackOrder[self.AttackIndex]
	if self.RangeByAttack[currentAttack] then
		return self.RangeByAttack[currentAttack]
	else
		return self.AttackRange
	end
end

function BossAncientEvil:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossAncientEvil:Rest(duration)
	self.RestDuration = duration or 1
	self.StateMachine:SetState("Resting")
end

function BossAncientEvil:SlashAttack()
	if self.Target then
		self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
	end

	self:AnimationPlay("BossAESlash1")

	local length = 32
	local width = 8
	local t = 0.75
	local cframe = self.Root.CFrame * CFrame.new(0, -5, -length/2)
	self:SquareAttack(cframe, width, length, t, 50)
	spawn(function()
		task.wait(t)
		self:PlaySound("MonsterAttackBig")
	end)

	self:Rest(1)
end

function BossAncientEvil:DashAttack()
	if self.Target then
		self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
	end

	self:AnimationPlay("BossAESlash1")

	local length = 32
	local width = 8
	local t = 0.75 + (0.25 / 2)
	local cframe = self.Root.CFrame * CFrame.new(0, -5, -length/2)
	self:SquareAttack(cframe, width, length, t, 50)
	spawn(function()
		task.wait(t)
		self:PlaySound("ExplosionSmall2")
	end)

	spawn(function()
		task.wait(0.75)
		self:AnimationStop("BossAESlash1")
		self:AnimationPlay("BossAEDash")

		local dashTime = 0.25
		local speed = length / dashTime

		local v = Instance.new("BodyVelocity")
		v.Velocity = self.Root.CFrame.lookVector * speed
		v.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		v.Parent = self.Root

		spawn(function()
			task.wait(dashTime)
			v.Velocity = Vector3.new(0, 0, 0)
			self:AnimationStop("BossAEDash")

			task.wait(0.1)
			v:Destroy()
		end)
	end)

	self:Rest(1.25)
end

function BossAncientEvil:CastAttack()
	self:AnimationPlay("BossAECast")
	local players = self:GetPlayersInRange(128)

	local function damageZone(position, size, duration, dps, rate)
		spawn(function()
			for t = 0, duration, rate do
				self:CircleAttack(position, size, rate, dps * rate, {NoExplosion = true})
				task.wait(rate)
			end
		end)
	end

	spawn(function()
		task.wait(0.75)
		for _, player in pairs(players) do
			damageZone(player.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0), 8, 10, 20, 0.5)
		end
	end)

	self:Rest(1.25)
end

function BossAncientEvil:PentagramAttack()
	self:PlaySound("AncientEvilLaugh")

	local totalTelegraph = 1.8

	self:AnimationPlay("BossAECast", nil, nil, 1 / totalTelegraph)

	local center = self:GetFootPosition()
	local vertexCount = 7
	local thetaBase = math.pi * 2 * math.random()
	local thetaStep = math.pi * 2 / vertexCount
	local radius = 64
	local points = {}

	for lineNumber = 1, vertexCount do
		local theta = ((lineNumber - 1) * thetaStep) + thetaBase
		local dx = math.cos(theta) * radius
		local dz = math.sin(theta) * radius
		table.insert(points, center + Vector3.new(dx, 0, dz))  
	end

	local tStep = totalTelegraph / vertexCount

	for bottomIndex = 1, vertexCount do
		local delayTime = tStep * (bottomIndex - 1)

		spawn(function()
			task.wait(delayTime)
			local topIndex = bottomIndex + 3
			if topIndex > vertexCount then
				topIndex = topIndex - vertexCount
			end

			local here = points[bottomIndex]
			local there = points[topIndex]
			local cframe = CFrame.new((here + there) / 2, there)
			local dist = (there - here).magnitude

			self:SquareAttack(cframe, 8, dist, totalTelegraph - delayTime, 50)
		end)
	end

	self:Rest(totalTelegraph + 1)
end

function BossAncientEvil:PushAttack()
	local point = self:GetFootPosition()
	local radius = 16
	local telegraphTime = 0.25

	local distance = 16
	local duration = 0.25

	self:CircleAttackWithCallback(point, radius, telegraphTime, function()
		local playersHit = self:GetPlayersInArea(point, radius)
		for _, player in pairs(playersHit) do
			local there = player.Character.HumanoidRootPart.Position

			local direction = there - Vector3.new(point.X, there.Y, point.Z)
			direction = direction.Unit

			self:PushPlayer(player, direction * (distance / duration), duration)
		end
	end, {BrickColor = BrickColor.new("Bright violet")})

	self:Rest(0.5)
end

function BossAncientEvil:PullAttack()
	local players = self:GetPlayersInRange(128)

	local point = self:GetFootPosition()
	local radius = 6
	local telegraphTime = 0.25
	local duration = 0.25

	local function pullZone(position)
		self:CircleAttackWithCallback(position, radius, telegraphTime, function()
			local playersHit = self:GetPlayersInArea(position, radius)
			for _, playerHit in pairs(playersHit) do
				local here = playerHit.Character.HumanoidRootPart.Position

				local delta = point - here
				delta = Vector3.new(delta.X, 0, delta.Z)

				local distance = delta.Magnitude
				local direction = delta / distance

				local pullDistance = distance - 12

				self:PushPlayer(playerHit, direction * (pullDistance / duration), duration)
			end
		end, {BrickColor = BrickColor.new("Bright violet")})
	end

	for _, player in pairs(players) do
		pullZone(player.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0))
	end

	self:Rest(0.5)
end

function BossAncientEvil:SquareAttack(cframe, width, length, telegraphTime, damage)
	-- Create a square telegraph
	local telegraph = Instance.new("Part")
	telegraph.Name = "SquareTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Dark indigo")
	telegraph.Transparency = 0.7
	telegraph.Size = Vector3.new(width, 1, length)
	telegraph.CFrame = cframe
	telegraph.Parent = workspace

	-- Animate the telegraph
	local tween = TweenService:Create(telegraph, 
		TweenInfo.new(telegraphTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.3}
	)
	tween:Play()

	-- Execute damage and cleanup
	spawn(function()
		task.wait(telegraphTime)
		tween:Cancel()
		telegraph:Destroy()

		-- Deal damage to players in the square area
		local playersInArea = self:GetPlayersInSquareArea(cframe, width, length)
		for _, player in pairs(playersInArea) do
			self:DamagePlayer(player, damage)
		end
	end)
end

function BossAncientEvil:CircleAttack(position, radius, telegraphTime, damage, options)
	options = options or {}

	-- Create a circle telegraph
	local telegraph = Instance.new("Part")
	telegraph.Name = "CircleTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Cylinder
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Dark indigo")
	telegraph.Transparency = 0.7
	telegraph.Size = Vector3.new(1, radius * 2, radius * 2)
	telegraph.Position = position
	telegraph.Orientation = Vector3.new(0, 0, 90)
	telegraph.Parent = workspace

	-- Animate the telegraph
	local tween = TweenService:Create(telegraph, 
		TweenInfo.new(telegraphTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.3}
	)
	tween:Play()

	-- Execute damage and cleanup
	spawn(function()
		task.wait(telegraphTime)
		tween:Cancel()
		telegraph:Destroy()

		if not options.NoExplosion then
			-- Deal damage to players in the circular area
			local playersInArea = self:GetPlayersInArea(position, radius)
			for _, player in pairs(playersInArea) do
				self:DamagePlayer(player, damage)
			end
		end
	end)
end

function BossAncientEvil:CircleAttackWithCallback(position, radius, telegraphTime, callback, options)
	options = options or {}

	-- Create a circle telegraph
	local telegraph = Instance.new("Part")
	telegraph.Name = "CircleTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Cylinder
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = options.BrickColor or BrickColor.new("Dark indigo")
	telegraph.Transparency = 0.7
	telegraph.Size = Vector3.new(1, radius * 2, radius * 2)
	telegraph.Position = position
	telegraph.Orientation = Vector3.new(0, 0, 90)
	telegraph.Parent = workspace

	-- Animate the telegraph
	local tween = TweenService:Create(telegraph, 
		TweenInfo.new(telegraphTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.3}
	)
	tween:Play()

	-- Execute callback and cleanup
	spawn(function()
		task.wait(telegraphTime)
		tween:Cancel()
		telegraph:Destroy()
		callback()
	end)
end

function BossAncientEvil:GetPlayersInRange(range)
	local playersInRange = {}
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (self:GetPosition() - player.Character.HumanoidRootPart.Position).Magnitude
			if distance <= range then
				table.insert(playersInRange, player)
			end
		end
	end
	return playersInRange
end

function BossAncientEvil:GetPlayersInArea(position, radius)
	local playersInArea = {}
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance <= radius then
				table.insert(playersInArea, player)
			end
		end
	end
	return playersInArea
end

function BossAncientEvil:GetPlayersInSquareArea(cframe, width, length)
	local playersInArea = {}
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local playerPos = player.Character.HumanoidRootPart.Position
			local localPos = cframe:PointToObjectSpace(playerPos)

			if math.abs(localPos.X) <= width/2 and math.abs(localPos.Z) <= length/2 then
				table.insert(playersInArea, player)
			end
		end
	end
	return playersInArea
end

function BossAncientEvil:PushPlayer(player, velocity, duration)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local push = Instance.new("BodyVelocity")
		push.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		push.Velocity = velocity
		push.Parent = player.Character.HumanoidRootPart
		Debris:AddItem(push, duration)
	end
end

function BossAncientEvil:PlaySound(soundName, pitch)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds/" .. (soundName:lower()) .. ".mp3"
	sound.Volume = 0.7
	if typeof(pitch) == "table" then
		sound.Pitch = math.random(pitch[1] * 100, pitch[2] * 100) / 100
	else
		sound.Pitch = pitch or 1
	end
	sound.Parent = self.Model
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

function BossAncientEvil:DamagePlayer(player, damage)
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid:TakeDamage(damage)

		-- Visual effect for damage
		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.new(0, 100, 0, 50)
		gui.Adornee = player.Character:FindFirstChild("Head")
		gui.Parent = workspace

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "-" .. damage
		label.TextColor3 = Color3.new(0.5, 0, 0.5) -- Ancient evil purple
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Parent = gui

		-- Animate damage text
		local tween = TweenService:Create(label,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = UDim2.new(0, 0, -1, 0), TextTransparency = 1}
		)
		tween:Play()

		Debris:AddItem(gui, 1)
	end
end

function BossAncientEvil:DieIfDead()
	if self.Health <= 0 then
		self.Active = false

		self:AnimationPlay("BossKoboldRoar")
		spawn(function()
			task.wait(1)
			self:PlaySound("AncientEvilDeath")
			task.wait(2)
			if self.Model then
				self.Model:BreakJoints()
			end
		end)
	end
end

function BossAncientEvil:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
end

return BossAncientEvil