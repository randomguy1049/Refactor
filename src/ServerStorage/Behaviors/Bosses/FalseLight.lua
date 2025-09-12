local BossFalseLight = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local States = {
	["Spawning"] = {
		Enter = function(self)
			-- Teleport to a random position and create a false light
			self:SummonFalseLight()
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
				self:AnimationPlay("BossWalk")
				self:AnimationStop("BossIdle")
			end
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Chasing"] = {
		Enter = function(self)
			if not self.Active then return end
			self:AnimationPlay("BossWalk")
			self:AnimationStop("BossIdle")
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
				self:AnimationStop("BossWalk")
				self:AnimationPlay("BossIdle")
			end
		end,
		Exit = function(self)
			self:AnimationStop("BossWalk")
		end,
	},
	["Resting"] = {
		Enter = function(self)
			self:AnimationStop("BossWalk")
			self:AnimationPlay("BossIdle")
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

function BossFalseLight.new(originalModel: Model, position: Vector3)
	-- Clone the model and set it up
	local model = originalModel:Clone()
	model.Parent = workspace
	model:MoveTo(position)

	-- Create the enemy instance
	local self = setmetatable({}, {__index = BossFalseLight})

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
	self.RestDuration = 1.25

	-- Attack pattern management
	self.AttackOrder = {
		"FanAttack",
		"FanAttack",
		"FanAttack",
		"CageAttack",
	}
	self.AttackIndex = 1
	self.AttackRange = 24

	-- False Light reference
	self.FalseLight = nil

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
			self:UpdateFalseLightConnection()
			self:DieIfDead()
			task.wait(0.1)
		end
	end)

	return self
end

function BossFalseLight:GetClosestPlayer()
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

function BossFalseLight:MoveTo(position)
	if self.Humanoid then
		self.Humanoid:MoveTo(position)
	end
end

function BossFalseLight:DistanceToCharacter(player)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return (self.Model:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude
	end
	return math.huge
end

function BossFalseLight:FaceTowardsPoint(position)
	local direction = (position - self.Model:GetPivot().Position).Unit
	self.Model:PivotTo(CFrame.lookAt(self.Model:GetPivot().Position, self.Model:GetPivot().Position + direction))
end

function BossFalseLight:GetPosition()
	return self.Model:GetPivot().Position
end

function BossFalseLight:GetFootPosition()
	return self.Model:GetPivot().Position + Vector3.new(0, -2, 0)
end

function BossFalseLight:AnimationPlay(animationName, fadeTime, weight, speed)
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

function BossFalseLight:AnimationStop(animationName)
	if self.Humanoid then
		for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.Name == animationName then
				track:Stop()
			end
		end
	end
end

function BossFalseLight:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossFalseLight:Rest(duration)
	self.RestDuration = duration or 1.25
	self.StateMachine:SetState("Resting")
end

function BossFalseLight:SummonFalseLight()
	-- Create a false light companion (simplified version)
	local falseLightModel = Instance.new("Part")
	falseLightModel.Name = "FalseLight"
	falseLightModel.Size = Vector3.new(4, 4, 4)
	falseLightModel.Shape = Enum.PartType.Ball
	falseLightModel.Material = Enum.Material.Neon
	falseLightModel.BrickColor = BrickColor.new("Bright yellow")
	falseLightModel.Anchored = true
	falseLightModel.CanCollide = false
	falseLightModel.Position = self:GetPosition() + Vector3.new(math.random(-10, 10), 5, math.random(-10, 10))
	falseLightModel.Parent = workspace

	-- Add a light effect
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Color = Color3.new(1, 1, 0.5)
	pointLight.Range = 20
	pointLight.Parent = falseLightModel

	self.FalseLight = {
		Model = falseLightModel,
		Health = self.MaxHealth,
		MaxHealth = self.MaxHealth
	}

	self:Rest(0.5)
end

function BossFalseLight:FanAttack()
	if self.Target then
		self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
	end

	self:AnimationPlay("BossDarkWizardAttack")
	self:PlaySound("MagicExplosionQuick", {0.5, 0.7})

	local radius = 64
	local step = 36
	local delta = math.random(0, 360)
	for deg = step, 360, step do
		local theta = math.rad(deg + delta)
		local dx = math.cos(theta) * (radius / 2)
		local dz = math.sin(theta) * (radius / 2)
		local a = self:GetFootPosition()
		local b = a + Vector3.new(dx, 0, dz)
		local cframe = CFrame.new(b, a)
		self:SquareAttack(cframe, 2.5, radius, 1, 45)
	end

	self:Rest(1)
end

function BossFalseLight:CageAttack()
	if not self.Target then return end

	local emptySpace = 12
	local thickness = 48
	local squareSize = (emptySpace * 2) + (thickness * 2)
	local rootCFrame = CFrame.new(self.Target.Character.HumanoidRootPart.Position) * CFrame.Angles(0, math.pi * 2 * math.random(), 0)
	local step = 90
	for deg = step, 360, step do
		local theta = math.rad(deg)
		local cframe = rootCFrame * CFrame.Angles(0, theta, 0) * CFrame.new(0, 0, -(emptySpace + thickness/2))
		self:SquareAttack(cframe, squareSize, thickness, 3, 45)
	end

	self:Rest(1.5)
end

function BossFalseLight:SquareAttack(cframe, width, length, telegraphTime, damage)
	-- Create a square telegraph
	local telegraph = Instance.new("Part")
	telegraph.Name = "SquareTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Block
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Bright yellow")
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

function BossFalseLight:GetPlayersInSquareArea(cframe, width, length)
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

function BossFalseLight:GetPlayersInArea(position, radius)
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

function BossFalseLight:UpdateFalseLightConnection()
	-- Keep boss invincible while false light is alive
	if self.FalseLight and self.FalseLight.Health > 0 then
		self.Health = self.MaxHealth
	end
end

function BossFalseLight:PlaySound(soundName, pitch)
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

function BossFalseLight:DamagePlayer(player, damage)
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
		label.TextColor3 = Color3.new(1, 1, 0) -- Bright yellow
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

function BossFalseLight:DieIfDead()
	if self.Health <= 0 then
		self.Active = false

		spawn(function()
			task.wait(1)
			if self.Model then
				self.Model:BreakJoints()
			end
			if self.FalseLight and self.FalseLight.Model then
				self.FalseLight.Model:Destroy()
			end
		end)
	end
end

function BossFalseLight:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
	if self.FalseLight and self.FalseLight.Model then
		self.FalseLight.Model:Destroy()
	end
end

return BossFalseLight