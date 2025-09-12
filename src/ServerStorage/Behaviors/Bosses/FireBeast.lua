local BossFireBeast = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local States = {
	["Spawning"] = {
		Enter = function(self)
			self:AreaAttack()
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
				self:AnimationPlay("BossFireBeastWalk")
			end
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Chasing"] = {
		Enter = function(self)
			if not self.Active then return end
			self:AnimationPlay("BossFireBeastWalk")
		end,
		Update = function(self)
			if not self.Active then return end

			if self.Target then
				self:MoveTo(self.Target.Character.HumanoidRootPart.Position)

				if self:DistanceToCharacter(self.Target) < self.AttackRange then
					self:Attack()
				end

				self.Target = self:GetClosestPlayer()
			else
				self.StateMachine:SetState("Waiting")
				self:AnimationStop("BossFireBeastWalk")
			end
		end,
		Exit = function(self)
			self:AnimationStop("BossFireBeastWalk")
		end,
	},
	["Resting"] = {
		Enter = function(self)
			self:AnimationStop("BossFireBeastWalk")
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

function BossFireBeast.new(originalModel: Model, position: Vector3)
	-- Clone the model and set it up
	local model = originalModel:Clone()
	model.Parent = workspace
	model:MoveTo(position)

	-- Create the enemy instance
	local self = setmetatable({}, {__index = BossFireBeast})

	-- Core properties
	self.Model = model
	self.Root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	self.Humanoid = model:FindFirstChild("Humanoid")
	self.Active = true
	self.Health = 1000
	self.MaxHealth = 1000

	-- State management
	self.State = "Spawning"
	self.Target = nil
	self.RestDuration = 1

	-- Attack properties
	self.AreaAttackRestTime = 5
	self.AreaAttackTelegraphTime = 1.25
	self.AreaAttackDamage = 25

	self.LineAttackRestTime = 1.5
	self.LineAttackTelegraphTime = 0.8
	self.LineAttackDamage = 30

	self.ArcAttackRestTime = 1
	self.ArcAttackTelegraphTime = 0.75
	self.ArcAttackDamage = 40

	-- Attack pattern management
	self.AttackOrder = {
		"ArcAttack", "ArcAttack", "ArcAttack",
		"LineAttack", "LineAttack", "LineAttack",
		"ArcAttack", "LineAttack", "ArcAttack", "LineAttack",
		"AreaAttack",
	}
	self.AttackIndex = 1
	self.AttackRange = 12

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

function BossFireBeast:GetClosestPlayer()
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

function BossFireBeast:MoveTo(position)
	if self.Humanoid then
		self.Humanoid:MoveTo(position)
	end
end

function BossFireBeast:DistanceToCharacter(player)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return (self.Model:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude
	end
	return math.huge
end

function BossFireBeast:FaceTowardsPoint(position)
	local direction = (position - self.Model:GetPivot().Position).Unit
	self.Model:PivotTo(CFrame.lookAt(self.Model:GetPivot().Position, self.Model:GetPivot().Position + direction))
end

function BossFireBeast:GetPosition()
	return self.Model:GetPivot().Position
end

function BossFireBeast:GetFootPosition()
	return self.Model:GetPivot().Position + Vector3.new(0, -2, 0)
end

function BossFireBeast:AnimationPlay(animationName, fadeTime, weight, speed)
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

function BossFireBeast:AnimationStop(animationName)
	if self.Humanoid then
		for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.Name == animationName then
				track:Stop()
			end
		end
	end
end

function BossFireBeast:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossFireBeast:Rest(duration)
	self.RestDuration = duration or 1
	self.StateMachine:SetState("Resting")
end

function BossFireBeast:ArcAttack()
	if not self.Target then return end

	self:Rest(self.ArcAttackRestTime)

	local a = self:GetFootPosition()
	local b = self.Target.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)
	local directionCFrame = CFrame.new(a, Vector3.new(b.X, a.Y, b.Z))

	local radius = 6

	local lower = -90
	local upper = 90
	local step = (upper - lower) / 3
	for deltaTheta = lower, upper, step do
		local cframe = directionCFrame * CFrame.Angles(0, math.rad(deltaTheta), 0) * CFrame.new(0, 0, -radius)

		self:CreateTelegraph(cframe.Position, radius * 2, self.ArcAttackTelegraphTime, function()
			local players = self:GetPlayersInArea(cframe.Position, radius)
			for _, player in pairs(players) do
				self:DamagePlayer(player, self.ArcAttackDamage)
			end
		end)
	end

	self:AnimationPlay("BossFireBeastAttack")
	self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)

	spawn(function()
		task.wait(self.ArcAttackTelegraphTime)
		self:PlaySound("ExplosionFireSmall", {0.9, 1.1})
	end)
end

function BossFireBeast:LineAttack()
	if not self.Target then return end

	self:Rest(self.LineAttackRestTime)

	local direction = self.Target.Character.HumanoidRootPart.Position - self:GetPosition()
	direction = Vector3.new(direction.X, 0, direction.Z).Unit

	local radius = 8
	local attackDelay = 0
	local attackDelayStep = 0.1

	for distance = radius, radius * 4, radius do
		local point = self:GetFootPosition() + direction * distance

		spawn(function()
			task.wait(attackDelay)
			self:CreateTelegraph(point, radius * 2, self.LineAttackTelegraphTime, function()
				local players = self:GetPlayersInArea(point, radius)
				for _, player in pairs(players) do
					self:DamagePlayer(player, self.LineAttackDamage)
				end
				self:PlaySound("ExplosionSmall", {0.9, 1.1})
			end)
		end)

		attackDelay = attackDelay + attackDelayStep
	end

	self:FaceTowardsPoint(self:GetPosition() + direction)
	self:AnimationPlay("BossFireBeastChannel")
end

function BossFireBeast:AreaAttack()
	self:Rest(self.AreaAttackRestTime)

	local lower = 0
	local upper = math.pi * 2
	local step = (upper - lower) / 6
	local radius = 10
	local telegraphRadius = 8

	for theta = lower, upper, step do
		local dx = math.cos(theta) * radius
		local dz = math.sin(theta) * radius
		local point = self:GetFootPosition() + Vector3.new(dx, 0, dz)

		self:CreateTelegraph(point, telegraphRadius * 2, self.AreaAttackTelegraphTime, function()
			local players = self:GetPlayersInArea(point, telegraphRadius)
			for _, player in pairs(players) do
				self:DamagePlayer(player, self.AreaAttackDamage)
			end

			-- Create explosion effect
			local explosion = Instance.new("Explosion")
			explosion.BlastPressure = 0
			explosion.Position = point
			explosion.Parent = workspace
		end)
	end

	self:AnimationPlay("BossFireBeastChannel")

	spawn(function()
		task.wait(self.AreaAttackTelegraphTime)
		self:PlaySound("BossFireBeastRoar")
		self:AnimationPlay("BossFireBeastRoar")
	end)
end

function BossFireBeast:CreateTelegraph(position, size, time, callback)
	-- Create a visual telegraph sphere
	local telegraph = Instance.new("Part")
	telegraph.Name = "Telegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Ball
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Bright red")
	telegraph.Transparency = 0.7
	telegraph.Size = Vector3.new(size, size, size)
	telegraph.Position = position
	telegraph.Parent = workspace

	-- Add fire effect
	local fire = Instance.new("Fire")
	fire.Size = size / 4
	fire.Heat = 10
	fire.Parent = telegraph

	-- Animate the telegraph
	local tween = TweenService:Create(telegraph, 
		TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.3}
	)
	tween:Play()

	-- Execute callback and cleanup
	spawn(function()
		task.wait(time)
		tween:Cancel()
		telegraph:Destroy()

		if callback then
			callback()
		end
	end)
end

function BossFireBeast:GetPlayersInArea(position, radius)
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

function BossFireBeast:PlaySound(soundName, pitch)
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

function BossFireBeast:DamagePlayer(player, damage)
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
		label.TextColor3 = Color3.new(1, 0.3, 0) -- Fire orange
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

function BossFireBeast:DieIfDead()
	if self.Health <= 0 then
		self.Active = false

		-- Create explosive death sequence
		local parts = {}
		for _, obj in pairs(self.Model:GetChildren()) do
			if obj:IsA("BasePart") then
				table.insert(parts, obj)
			end
		end

		spawn(function()
			local duration = 7
			while duration > 0 and #parts > 0 do
				task.wait(0.5)
				duration = duration - 0.5

				local part = parts[math.random(1, #parts)]

				local explosion = Instance.new("Explosion")
				explosion.BlastPressure = 0
				explosion.Position = part.Position
				explosion.Parent = workspace

				self:PlaySound("ExplosionSmall")
			end

			if self.Model then
				self.Model:BreakJoints()
				Debris:AddItem(self.Model, 5)
			end
		end)
	end
end

function BossFireBeast:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
end

return BossFireBeast