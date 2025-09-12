local BossGhost = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local States = {
	["Spawning"] = {
		Enter = function(self)
			self:StormAttack()
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
				self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
				self:Attack()
			end

			if self.Health < (self.MaxHealth * 0.5) then
				self:Infuriate()
			end
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Chasing"] = {
		Enter = function(self)
			if not self.Active then return end
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
				self:AnimationStop("BossGhostWalk")
			end
		end,
		Exit = function(self)
			self:AnimationStop("BossGhostWalk")
		end,
	},
	["Resting"] = {
		Enter = function(self)
			self:AnimationStop("BossGhostWalk")
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

function BossGhost.new(originalModel: Model, position: Vector3)
	-- Clone the model and set it up
	local model = originalModel:Clone()
	model.Parent = workspace
	model:MoveTo(position)

	-- Create the enemy instance
	local self = setmetatable({}, {__index = BossGhost})

	-- Core properties
	self.Model = model
	self.Root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	self.Humanoid = model:FindFirstChild("Humanoid")
	self.Active = true
	self.Health = 2200
	self.MaxHealth = 2200

	-- State management
	self.State = "Spawning"
	self.Target = nil
	self.RestDuration = 1.25
	self.Infuriated = false

	-- Attack pattern management
	self.AttackOrder = {
		"TeleportAttack",
		"TeleportAttack",
		"TeleportAttack",
		"TeleportAttack",
		"TeleportAttack",
		"TeleportAttack",
		"TeleportAttack",
		"TeleportAttack",
		"LineAttack",
		"LineAttack",
		"LineAttack",
		"LineAttack",
		"StormAttack",
		"LineAttack",
		"LineAttack",
		"LineAttack",
		"LineAttack",
	}
	self.AttackIndex = 1
	self.AttackRange = 12
	self.DetectionRange = 64

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

function BossGhost:GetClosestPlayer()
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

function BossGhost:MoveTo(position)
	if self.Humanoid then
		self.Humanoid:MoveTo(position)
	end
end

function BossGhost:DistanceToCharacter(player)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return (self.Model:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude
	end
	return math.huge
end

function BossGhost:FaceTowardsPoint(position)
	local direction = (position - self.Model:GetPivot().Position).Unit
	self.Model:PivotTo(CFrame.lookAt(self.Model:GetPivot().Position, self.Model:GetPivot().Position + direction))
end

function BossGhost:GetPosition()
	return self.Model:GetPivot().Position
end

function BossGhost:GetFootPosition()
	return self.Model:GetPivot().Position + Vector3.new(0, -2, 0)
end

function BossGhost:AnimationPlay(animationName, fadeTime, weight, speed)
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

function BossGhost:AnimationStop(animationName)
	if self.Humanoid then
		for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.Name == animationName then
				track:Stop()
			end
		end
	end
end

function BossGhost:Infuriate()
	if self.Infuriated then return end

	for _, obj in pairs(self.Model:GetChildren()) do
		if obj:IsA("BasePart") then
			obj.BrickColor = BrickColor.new("Really red")
		end
	end

	self.Infuriated = true
end

function BossGhost:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossGhost:Rest(duration)
	self.RestDuration = duration or 1.25
	self.StateMachine:SetState("Resting")
end

function BossGhost:StormAttack()
	local damage = 50
	local radius = 6
	local telegraphTime = 1

	local timeBetweenHits = 0.1
	if self.Infuriated then
		timeBetweenHits = 0.075
	end

	-- Create spawn points around current position (simplified version)
	local spawnPoints = {}
	local centerPos = self:GetPosition()
	local range = 32
	for i = 1, 20 do
		local angle = (i / 20) * math.pi * 2
		local distance = math.random(8, range)
		local point = centerPos + Vector3.new(
			math.cos(angle) * distance,
			0,
			math.sin(angle) * distance
		)
		table.insert(spawnPoints, point)
	end

	spawn(function()
		local t = 15
		while t > 0 do
			t = t - task.wait(timeBetweenHits)

			local point = spawnPoints[math.random(1, #spawnPoints)]
			self:CircleAttack(point, radius, telegraphTime, damage)

			spawn(function()
				task.wait(telegraphTime)
				self:PlaySoundAtPosition(point, "ExplosionSmall", {0.9, 1.1})
			end)
		end
	end)

	self:AnimationPlay("BossGhostRoar")
	for moreLoudness = 1, 5 do
		self:PlaySound("BossGhostRoar")
	end
	self:Rest(15)
end

function BossGhost:LineAttack()
	local damage = 50
	local radius = 6
	local range = 64
	local telegraphTime = 1

	local function line(player, direction)
		for dz = -4, 4 do
			local point = (direction * CFrame.new(0, 0, dz * radius)).Position

			self:CircleAttack(point, radius, telegraphTime, damage)
		end

		spawn(function()
			task.wait(telegraphTime)
			self:PlaySoundAtPosition(direction.Position, "ExplosionSmall2", {0.9, 1.1})
		end)
	end

	spawn(function()
		task.wait(1.5 - telegraphTime)
		local players = self:GetPlayersInArea(self:GetPosition(), range)
		for _, player in pairs(players) do
			local direction = CFrame.new(player.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)) * CFrame.Angles(0, math.pi * 2 * math.random(), 0)
			line(player, direction)
		end
	end)

	-- Protect myself!
	local point = self:GetFootPosition()
	self:CircleAttack(point, 14, 1.5, damage)

	self:AnimationPlay("BossGhostAttack")
	if self.Infuriated then
		self:Rest(1.5)
	else
		self:Rest(3)
	end
end

function BossGhost:TeleportAttack()
	local radius = 16
	local damage = 50
	local telegraphTime = 1.5

	-- Generate random position around current area
	local currentPos = self:GetPosition()
	local angle = math.random() * math.pi * 2
	local distance = math.random(10, 20)
	local point = currentPos + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)

	self:CircleAttack(point, radius, telegraphTime, damage)

	self:AnimationPlay("BossGhostPower")		
	spawn(function()
		task.wait(1.5)
		self.Model:PivotTo(CFrame.new(point + Vector3.new(0, 5, 0)))
		self:PlaySound("Lightning", {0.9, 1.1})
		self:TurnInRandomDirection()
	end)

	if self.Infuriated then
		self:Rest(1)
	else
		self:Rest(2)
	end
end

function BossGhost:TurnInRandomDirection()
	local randomAngle = math.random() * math.pi * 2
	local currentPos = self:GetPosition()
	local direction = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
	self.Model:PivotTo(CFrame.lookAt(currentPos, currentPos + direction))
end

function BossGhost:CircleAttack(position, radius, telegraphTime, damage)
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

		-- Deal damage to players in the circular area
		local playersInArea = self:GetPlayersInArea(position, radius)
		for _, player in pairs(playersInArea) do
			self:DamagePlayer(player, damage)
		end
	end)
end

function BossGhost:GetPlayersInArea(position, radius)
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

function BossGhost:PlaySound(soundName, pitch)
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

function BossGhost:PlaySoundAtPosition(position, soundName, pitch)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds/" .. (soundName:lower()) .. ".mp3"
	sound.Volume = 0.7
	if typeof(pitch) == "table" then
		sound.Pitch = math.random(pitch[1] * 100, pitch[2] * 100) / 100
	else
		sound.Pitch = pitch or 1
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Parent = workspace
	sound.Parent = part
	sound:Play()

	sound.Ended:Connect(function()
		part:Destroy()
	end)
end

function BossGhost:DamagePlayer(player, damage)
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
		label.TextColor3 = Color3.new(0.5, 0, 0.8) -- Ghost purple
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

function BossGhost:DieIfDead()
	if self.Health <= 0 then
		self.Active = false

		-- Ghost floating away death animation
		local distance = 64
		local duration = 15
		local speed = distance / duration
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, speed, 0)
		bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bodyVelocity.Parent = self.Root

		spawn(function()
			task.wait(duration)
			if self.Model then
				self.Model:Destroy()
			end
		end)

		for moreLoudness = 1, 5 do
			self:PlaySound("BossGhostRoar")
		end
		self:AnimationPlay("BossGhostRoar")
	end
end

function BossGhost:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
end

return BossGhost