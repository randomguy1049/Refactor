local BossCorruptedMatrix = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local States = {
	["Spawning"] = {
		Enter = function(self)
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
			self:Attack()
		end,
		Update = function(self)
			-- Waiting behavior handled in Enter function
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Resting"] = {
		Enter = function(self)
			task.wait(self.RestDuration or 1.5)
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

function BossCorruptedMatrix.new(originalModel: Model, position: Vector3)
	-- Clone the model and set it up
	local model = originalModel:Clone()
	model.Parent = workspace
	model:MoveTo(position)

	-- Create the enemy instance
	local self = setmetatable({}, {__index = BossCorruptedMatrix})

	-- Core properties
	self.Model = model
	self.Root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	self.Humanoid = model:FindFirstChild("Humanoid")
	self.Active = true
	self.Health = 1800
	self.MaxHealth = 1800

	-- State management
	self.State = "Spawning"
	self.Target = nil
	self.RestDuration = 1.5

	-- Attack pattern management
	self.AttackOrder = {
		"FanAttack",
		"ExplosionAttack",
	}
	self.AttackIndex = 1

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

function BossCorruptedMatrix:GetClosestPlayer()
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

function BossCorruptedMatrix:GetPosition()
	return self.Model:GetPivot().Position
end

function BossCorruptedMatrix:GetFootPosition()
	return self.Model:GetPivot().Position + Vector3.new(0, -2, 0)
end

function BossCorruptedMatrix:GetPlayersInRange(range)
	local playersInRange = {}
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (self:GetPosition() - player.Character.HumanoidRootPart.Position).Magnitude
			if distance <= (range or 128) then
				table.insert(playersInRange, player)
			end
		end
	end
	return playersInRange
end

function BossCorruptedMatrix:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossCorruptedMatrix:Rest(duration)
	self.RestDuration = duration or 1.5
	self.StateMachine:SetState("Resting")
end

function BossCorruptedMatrix:FanAttack()
	self:Rest(1.5)

	self:PlaySound("MagicExplosionQuick", {0.9, 1.1})

	local here = self:GetFootPosition()
	local players = self:GetPlayersInRange()
	for _, player in pairs(players) do
		local there = player.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)
		local cframe = CFrame.new(here, there)
		local width = 8
		local length = (there - here).Magnitude + 8
		cframe = cframe * CFrame.new(0, 0, -length / 2)

		self:SquareAttack(cframe, width, length, 0.66, 75)
	end
end

function BossCorruptedMatrix:ExplosionAttack()
	self:Rest(1.5)

	self:PlaySound("MagicExplosionQuick", 2)

	local players = self:GetPlayersInRange()
	for _, player in pairs(players) do
		local there = player.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)
		local t = 0.8
		self:CircleAttack(there, 8, t, 50)
		spawn(function()
			task.wait(t)
			local cframe = CFrame.new(there + Vector3.new(0, 2, 0)) * CFrame.Angles(0, math.pi * 2 * math.random(), 0)
			local shots = 7
			local step = math.pi * 2 / shots
			for n = 1, shots do
				cframe = cframe * CFrame.Angles(0, step, 0)
				self:FireProjectile("PurpleMagic", Vector3.new(90, 0, 0), 16, cframe.Position + cframe.LookVector, 50, cframe.Position)
			end
		end)
	end
end

function BossCorruptedMatrix:SquareAttack(cframe, width, length, telegraphTime, damage)
	-- Create a square telegraph
	local telegraph = Instance.new("Part")
	telegraph.Name = "SquareTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Bright violet")
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

function BossCorruptedMatrix:CircleAttack(position, radius, telegraphTime, damage)
	-- Create a circle telegraph
	local telegraph = Instance.new("Part")
	telegraph.Name = "CircleTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Cylinder
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Bright violet")
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

function BossCorruptedMatrix:FireProjectile(modelName, rotation, speed, targetPosition, damage, startPosition)
	-- Create a simple projectile
	local projectile = Instance.new("Part")
	projectile.Name = "Projectile"
	projectile.Size = Vector3.new(2, 2, 2)
	projectile.Shape = Enum.PartType.Ball
	projectile.Material = Enum.Material.Neon
	projectile.BrickColor = BrickColor.new("Bright violet")
	projectile.CanCollide = false
	projectile.Anchored = true
	projectile.Position = startPosition
	projectile.Parent = workspace

	local direction = (targetPosition - startPosition).Unit
	local distance = (targetPosition - startPosition).Magnitude
	local time = distance / speed

	-- Animate projectile movement
	local tween = TweenService:Create(projectile,
		TweenInfo.new(time, Enum.EasingStyle.Linear),
		{Position = targetPosition}
	)
	tween:Play()

	-- Handle collision and cleanup
	local connection
	connection = tween.Completed:Connect(function()
		connection:Disconnect()

		-- Check for players at target location
		local playersHit = self:GetPlayersInArea(targetPosition, 3)
		for _, player in pairs(playersHit) do
			self:DamagePlayer(player, damage)
		end

		projectile:Destroy()
	end)

	-- Cleanup if projectile takes too long
	Debris:AddItem(projectile, time + 1)
end

function BossCorruptedMatrix:GetPlayersInArea(position, radius)
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

function BossCorruptedMatrix:GetPlayersInSquareArea(cframe, width, length)
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

function BossCorruptedMatrix:PlaySound(soundName, pitch)
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

function BossCorruptedMatrix:DamagePlayer(player, damage)
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
		label.TextColor3 = Color3.new(0.6, 0, 0.8) -- Corrupted matrix purple
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

function BossCorruptedMatrix:DieIfDead()
	if self.Health <= 0 then
		self.Active = false

		if self.Model then
			self.Model:BreakJoints()
		end
	end
end

function BossCorruptedMatrix:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
end

return BossCorruptedMatrix