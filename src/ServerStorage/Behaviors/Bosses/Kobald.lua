local BossKobold = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local States = {
	["Spawning"] = {
		Enter = function(self)
			self:Rest(0.5)
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
				self:AnimationPlay("BossKoboldWalk")
			end
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Chasing"] = {
		Enter = function(self)
			if not self.Active then return end
			self:AnimationPlay("BossKoboldWalk")
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
				self:AnimationStop("BossKoboldWalk")
			end
		end,
		Exit = function(self)
			self:AnimationStop("BossKoboldWalk")
		end,
	},
	["Resting"] = {
		Enter = function(self)
			self:AnimationStop("BossKoboldWalk")
			task.wait(self.RestDuration or 1.25)
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

function BossKobold.new(originalModel: Model, position: Vector3)
	-- Clone the model and set it up
	local model = originalModel:Clone()
	model.Parent = workspace
	model:MoveTo(position)

	-- Create the enemy instance
	local self = setmetatable({}, {__index = BossKobold})

	-- Core properties
	self.Model = model
	self.Root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	self.Humanoid = model:FindFirstChild("Humanoid")
	self.Active = true
	self.Health = 2000
	self.MaxHealth = 2000

	-- State management
	self.State = "Spawning"
	self.Target = nil
	self.RestDuration = 1.25

	-- Attack pattern management
	self.AttackOrder = {
		"RoarAttack",
		"BasicAttack", "BasicAttack",
		"ShockwaveAttack",
		"BasicAttack", "BasicAttack",
		"LeapAttack",
		"BasicAttack",
		"ShockwaveAttack",
		"BasicAttack", "BasicAttack", "BasicAttack",
		"LeapAttack", "LeapAttack",
		"BasicAttack",
		"ShockwaveAttack",
		"BasicAttack",
		"RoarAttack",
		"BasicAttack", "BasicAttack",
		"LeapAttack",
		"BasicAttack",
	}
	self.RangeByAttack = {
		ShockwaveAttack = 64,
		RoarAttack = 32,
		LeapAttack = 64,
	}
	self.AttackIndex = 1
	self.AttackRange = 8
	self.Rhythm = 0.5

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

function BossKobold:GetClosestPlayer()
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

function BossKobold:MoveTo(position)
	if self.Humanoid then
		self.Humanoid:MoveTo(position)
	end
end

function BossKobold:DistanceToCharacter(player)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return (self.Model:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude
	end
	return math.huge
end

function BossKobold:FaceTowardsPoint(position)
	local direction = (position - self.Model:GetPivot().Position).Unit
	self.Model:PivotTo(CFrame.lookAt(self.Model:GetPivot().Position, self.Model:GetPivot().Position + direction))
end

function BossKobold:GetPosition()
	return self.Model:GetPivot().Position
end

function BossKobold:GetFootPosition()
	return self.Model:GetPivot().Position + Vector3.new(0, -2, 0)
end

function BossKobold:AnimationPlay(animationName, fadeTime, weight, speed)
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

function BossKobold:AnimationStop(animationName)
	if self.Humanoid then
		for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.Name == animationName then
				track:Stop()
			end
		end
	end
end

function BossKobold:Lerp(a, b, t)
	return a + (b - a) * t
end

function BossKobold:GetAttackRange()
	local currentAttack = self.AttackOrder[self.AttackIndex]
	if self.RangeByAttack[currentAttack] then
		return self.RangeByAttack[currentAttack]
	else
		return self.AttackRange
	end
end

function BossKobold:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossKobold:Rest(duration)
	self.Rhythm = self:Lerp(0.5, 1.1, 1 - (self.Health / self.MaxHealth))

	self.RestDuration = duration or 1.25
	self.StateMachine:SetState("Resting")
end

function BossKobold:BasicAttack()
	if not self.Target then return end
	self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)

	self:AnimationPlay("BossKoboldBasic", nil, nil, self.Rhythm)

	local function hitPosition()
		return (self.Model:GetPivot() * CFrame.new(0, 0, -2.5)).Position
	end

	-- First hit
	self:CircleAttack(hitPosition(), 8, 0.6 / self.Rhythm, 45)
	spawn(function()
		task.wait(0.6 / self.Rhythm)
		self:PlaySound("ExplosionSmall")
	end)

	-- Second hit
	spawn(function()
		task.wait(0.9 / self.Rhythm)
		self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
		self:CircleAttack(hitPosition(), 8, 0.5 / self.Rhythm, 45)
		spawn(function()
			task.wait(0.5 / self.Rhythm)
			self:PlaySound("ExplosionSmall")
		end)

		-- Third hit
		spawn(function()
			task.wait(0.5 / self.Rhythm)
			self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
			self:CircleAttack(hitPosition(), 12, 0.7 / self.Rhythm, 45)
			spawn(function()
				task.wait(0.7 / self.Rhythm)
				self:PlaySound("ExplosionSmall2")
			end)
		end)
	end)

	self:Rest(3 / self.Rhythm)
end

function BossKobold:ShockwaveAttack()
	local players = self:GetPlayersInArea(self:GetPosition(), 64)
	local index = 1

	self:AnimationPlay("BossKoboldBasic", nil, nil, self.Rhythm)

	local function sendShockwave(player)
		self:PlaySound("ExplosionLoud")

		local here = self:GetFootPosition()
		local there = player.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)
		local distance = (there - here).Magnitude
		there = there + player.Character.HumanoidRootPart.Velocity * (distance / 32)

		local position = here
		local velocity = (there - here).Unit * 8
		local acceleration = 128

		spawn(function()
			local t = 0
			while t < 1.5 do
				local dt = task.wait(0.125)
				t = t + dt

				local speed = velocity.Magnitude
				position = position + velocity * dt
				velocity = velocity.Unit * (speed + acceleration * dt)
				self:CircleAttack(position, speed / 8, 0.25 / self.Rhythm, 45)
			end
		end)
	end

	local function nextTarget()
		local target = players[index]
		index = index + 1
		if index > #players then
			index = 1
		end
		return target
	end

	-- First hit
	spawn(function()
		task.wait(0.6 / self.Rhythm)
		if #players > 0 then
			sendShockwave(nextTarget())
		end
	end)

	-- Second hit
	spawn(function()
		task.wait(0.9 / self.Rhythm)
		spawn(function()
			task.wait(0.5 / self.Rhythm)
			if #players > 0 then
				sendShockwave(nextTarget())
			end
		end)

		-- Third hit
		spawn(function()
			task.wait(0.5 / self.Rhythm)
			spawn(function()
				task.wait(0.7 / self.Rhythm)
				if #players > 0 then
					sendShockwave(nextTarget())
				end
			end)
		end)
	end)

	self:Rest(3 / self.Rhythm)
end

function BossKobold:RoarAttack()
	local animationSpeed = 0.5

	self:AnimationPlay("BossKoboldRoar", nil, nil, animationSpeed * self.Rhythm)

	self:InvertedCircleAttack(self:GetPosition(), 12, 128, 1.2 / animationSpeed / self.Rhythm, 100)
	spawn(function()
		task.wait(1.2 / animationSpeed / self.Rhythm)
		self:PlaySound("MonsterDeath2", 0.8)
	end)

	self:Rest(1.2 / animationSpeed / self.Rhythm + 0.5)
end

function BossKobold:LeapAttack()
	local players = self:GetPlayersInArea(self:GetPosition(), 128)
	if #players == 0 then return end

	local target = players[math.random(1, #players)]

	self:AnimationPlay("BossKoboldLeap", nil, nil, self.Rhythm)

	spawn(function()
		task.wait(0.5 / self.Rhythm)
		local cframe = CFrame.new(target.Character.HumanoidRootPart.Position) * CFrame.Angles(0, math.random() * math.pi * 2, 0) * CFrame.new(0, 0, -2)
		self:CircleAttack(cframe.Position, 6, 0.7 / self.Rhythm, 55)

		spawn(function()
			task.wait(0.2 / self.Rhythm)
			self.Model:PivotTo(cframe * CFrame.Angles(0, math.pi, 0))

			spawn(function()
				task.wait(0.1 / self.Rhythm)
				self:PlaySound("ExplosionLoud", 0.8)
			end)
		end)
	end)

	self:Rest(2 / self.Rhythm)
end

function BossKobold:CircleAttack(position, radius, telegraphTime, damage)
	-- Create a circle telegraph
	local telegraph = Instance.new("Part")
	telegraph.Name = "CircleTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Cylinder
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Really red")
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

		-- Deal damage to players in the circular area
		local playersInArea = self:GetPlayersInArea(position, radius)
		for _, player in pairs(playersInArea) do
			self:DamagePlayer(player, damage)
		end
	end)
end

function BossKobold:InvertedCircleAttack(position, innerRadius, outerRadius, telegraphTime, damage)
	-- Create an inverted circle telegraph (ring shape)
	local outerTelegraph = Instance.new("Part")
	outerTelegraph.Name = "OuterCircleTelegraph"
	outerTelegraph.Anchored = true
	outerTelegraph.CanCollide = false
	outerTelegraph.Shape = Enum.PartType.Cylinder
	outerTelegraph.Material = Enum.Material.ForceField
	outerTelegraph.BrickColor = BrickColor.new("Really red")
	outerTelegraph.Transparency = 0.7
	outerTelegraph.Size = Vector3.new(1, outerRadius * 2, outerRadius * 2)
	outerTelegraph.Position = position
	outerTelegraph.Orientation = Vector3.new(0, 0, 90)
	outerTelegraph.Parent = workspace

	local innerTelegraph = Instance.new("Part")
	innerTelegraph.Name = "InnerCircleTelegraph"
	innerTelegraph.Anchored = true
	innerTelegraph.CanCollide = false
	innerTelegraph.Shape = Enum.PartType.Cylinder
	innerTelegraph.Material = Enum.Material.ForceField
	innerTelegraph.BrickColor = BrickColor.new("Bright green")
	innerTelegraph.Transparency = 0.3
	innerTelegraph.Size = Vector3.new(1.1, innerRadius * 2, innerRadius * 2)
	innerTelegraph.Position = position
	innerTelegraph.Orientation = Vector3.new(0, 0, 90)
	innerTelegraph.Parent = workspace

	-- Animate the telegraphs
	local outerTween = TweenService:Create(outerTelegraph, 
		TweenInfo.new(telegraphTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.3}
	)
	outerTween:Play()

	-- Execute damage and cleanup
	spawn(function()
		task.wait(telegraphTime)
		outerTween:Cancel()
		outerTelegraph:Destroy()
		innerTelegraph:Destroy()

		-- Deal damage to players in the ring area (outside inner circle but inside outer circle)
		local playersInArea = self:GetPlayersInArea(position, outerRadius)
		for _, player in pairs(playersInArea) do
			local distance = (position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance > innerRadius then
				self:DamagePlayer(player, damage)
			end
		end
	end)
end

function BossKobold:GetPlayersInArea(position, radius)
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

function BossKobold:PlaySound(soundName, pitch)
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

function BossKobold:DamagePlayer(player, damage)
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
		label.TextColor3 = Color3.new(0.8, 0, 0) -- Kobold red
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

function BossKobold:DieIfDead()
	if self.Health <= 0 then
		self.Active = false

		self:AnimationPlay("BossKoboldRoar")
		spawn(function()
			task.wait(1)
			self:PlaySound("BossKoboldRoar")
			task.wait(1)
			if self.Model then
				self.Model:BreakJoints()
			end
		end)
	end
end

function BossKobold:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
end

return BossKobold