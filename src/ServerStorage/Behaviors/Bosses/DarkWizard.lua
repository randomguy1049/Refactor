local BossDarkWizard = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local States = {
	["Spawning"] = {
		Enter = function(self)
			self:FanAttack()
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
				self:AnimationPlay("BossDarkWizardFloat")
			end
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Chasing"] = {
		Enter = function(self)
			if not self.Active then return end
			self:AnimationPlay("BossDarkWizardFloat")
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
				self:AnimationStop("BossDarkWizardFloat")
			end
		end,
		Exit = function(self)
			self:AnimationStop("BossDarkWizardFloat")
		end,
	},
	["Resting"] = {
		Enter = function(self)
			self:AnimationStop("BossDarkWizardFloat")
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

function BossDarkWizard.new(originalModel: Model, position: Vector3)
	-- Clone the model and set it up
	local model = originalModel:Clone()
	model.Parent = workspace
	model:MoveTo(position)

	-- Create the enemy instance
	local self = setmetatable({}, {__index = BossDarkWizard})

	-- Core properties
	self.Model = model
	self.Root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	self.Humanoid = model:FindFirstChild("Humanoid")
	self.Active = true
	self.Health = 1200
	self.MaxHealth = 1200

	-- State management
	self.State = "Spawning"
	self.Target = nil
	self.RestDuration = 1.25

	-- Attack pattern management
	self.AttackOrder = {
		"FanAttack", "FanAttack", "FanAttack", "FanAttack",
		"BlastAttack",
		"FanAttack", "FanAttack",
		"TeleportAttack",
		"BlastAttack",
	}
	self.AttackIndex = 1
	self.AttackRange = 24

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

function BossDarkWizard:GetClosestPlayer()
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

function BossDarkWizard:MoveTo(position)
	if self.Humanoid then
		self.Humanoid:MoveTo(position)
	end
end

function BossDarkWizard:DistanceToCharacter(player)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return (self.Model:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude
	end
	return math.huge
end

function BossDarkWizard:FaceTowardsPoint(position)
	local direction = (position - self.Model:GetPivot().Position).Unit
	self.Model:PivotTo(CFrame.lookAt(self.Model:GetPivot().Position, self.Model:GetPivot().Position + direction))
end

function BossDarkWizard:GetPosition()
	return self.Model:GetPivot().Position
end

function BossDarkWizard:GetFootPosition()
	return self.Model:GetPivot().Position + Vector3.new(0, -2, 0)
end

function BossDarkWizard:AnimationPlay(animationName, fadeTime, weight, speed)
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

function BossDarkWizard:AnimationStop(animationName)
	if self.Humanoid then
		for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.Name == animationName then
				track:Stop()
			end
		end
	end
end

function BossDarkWizard:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossDarkWizard:Rest(duration)
	self.RestDuration = duration or 1.25
	self.StateMachine:SetState("Resting")
end

function BossDarkWizard:FanAttack()
	if self.Target then
		self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
	end

	self:AnimationPlay("BossDarkWizardAttack")

	self:PlaySound("MagicExplosionSeries", {0.8, 1.2})

	for _, theta in pairs{-45, 0, 45} do
		local cframe = self.Model:GetPivot() * CFrame.Angles(0, math.rad(theta), 0)

		local d = 0
		for distance = 6, 6 * 4, 6 do
			spawn(function()
				task.wait(d)
				local point = (cframe * CFrame.new(0, 0, -distance)).Position
				self:CircleAttack(point, 4, 1, 45)
			end)
			d = d + 0.05
		end
	end

	self:Rest(1.25)
end

function BossDarkWizard:BlastAttack()
	self:AnimationPlay("BossDarkWizardBlast")
	self:CircleAttack(self:GetPosition(), 12, 2, 60)

	spawn(function()
		task.wait(2)
		self:PlaySound("MagicExplosionQuick", {0.8, 1.2})
	end)

	self:Rest(2.25)
end

function BossDarkWizard:TeleportAttack()
	-- Simplified teleport - pick a random position around the current area
	local currentPos = self:GetPosition()
	local angle = math.random() * math.pi * 2
	local distance = math.random(10, 20)
	local teleportPos = currentPos + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)

	self:CircleAttack(teleportPos, 8, 1, 50)

	spawn(function()
		task.wait(1)
		self.Model:PivotTo(CFrame.new(teleportPos + Vector3.new(0, 5, 0)))
		local randomDir = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit
		self.Model:PivotTo(CFrame.lookAt(teleportPos, teleportPos + randomDir))
		self:PlaySound("MagicExplosionQuick", {0.8, 1.2})
	end)

	self:Rest(1)
end

function BossDarkWizard:CircleAttack(position, radius, telegraphTime, damage)
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

function BossDarkWizard:GetPlayersInArea(position, radius)
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

function BossDarkWizard:PlaySound(soundName, pitch)
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

function BossDarkWizard:DamagePlayer(player, damage)
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
		label.TextColor3 = Color3.new(0.3, 0, 0.8) -- Dark wizard purple
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

function BossDarkWizard:DieIfDead()
	if self.Health <= 0 then
		self.Active = false

		self:AnimationPlay("BossDarkWizardRoar")
		spawn(function()
			task.wait(1)
			self:PlaySound("BossDarkWizardRoar")
			task.wait(1)
			if self.Model then
				self.Model:BreakJoints()
			end
		end)
	end
end

function BossDarkWizard:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
end

return BossDarkWizard