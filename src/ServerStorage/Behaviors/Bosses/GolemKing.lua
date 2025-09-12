local BossGolemKing = {}

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
				self:AnimationPlay("BossGolemKingRoll")
			end
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Chasing"] = {
		Enter = function(self)
			if not self.Active then return end
			self:AnimationPlay("BossGolemKingRoll")
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
				self:AnimationStop("BossGolemKingRoll")
			end
		end,
		Exit = function(self)
			self:AnimationStop("BossGolemKingRoll")
		end,
	},
	["Resting"] = {
		Enter = function(self)
			self:AnimationStop("BossGolemKingRoll")
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

function BossGolemKing.new(originalModel: Model, position: Vector3)
	-- Clone the model and set it up
	local model = originalModel:Clone()
	model.Parent = workspace
	model:MoveTo(position)

	-- Create the enemy instance
	local self = setmetatable({}, {__index = BossGolemKing})

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
	self.RestDuration = 1.25

	-- Attack parameters
	self.AreaAttackRestTime = 5
	self.AreaAttackTelegraphTime = 2
	self.AreaAttackDamage = 60

	self.LineAttackRestTime = 3
	self.LineAttackTelegraphTime = 1.5
	self.LineAttackDamage = 30

	self.ArcAttackRestTime = 2.25
	self.ArcAttackTelegraphTime = 1.5
	self.ArcAttackDamage = 40

	-- Attack pattern management
	self.AttackOrder = {
		"LineAttack",
		"LineAttack",
		"ArcAttack",
		"ArcAttack",
		"LineAttack",
		"LineAttack",
		"ArcAttack",
		"ArcAttack",
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

function BossGolemKing:GetClosestPlayer()
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

function BossGolemKing:MoveTo(position)
	if self.Humanoid then
		self.Humanoid:MoveTo(position)
	end
end

function BossGolemKing:DistanceToCharacter(player)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return (self.Model:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude
	end
	return math.huge
end

function BossGolemKing:FaceTowardsPoint(position)
	local direction = (position - self.Model:GetPivot().Position).Unit
	self.Model:PivotTo(CFrame.lookAt(self.Model:GetPivot().Position, self.Model:GetPivot().Position + direction))
end

function BossGolemKing:GetPosition()
	return self.Model:GetPivot().Position
end

function BossGolemKing:GetFootPosition()
	return self.Model:GetPivot().Position + Vector3.new(0, -2, 0)
end

function BossGolemKing:AnimationPlay(animationName, fadeTime, weight, speed)
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

function BossGolemKing:AnimationStop(animationName)
	if self.Humanoid then
		for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.Name == animationName then
				track:Stop()
			end
		end
	end
end

function BossGolemKing:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossGolemKing:Rest(duration)
	self.RestDuration = duration or 1.25
	self.StateMachine:SetState("Resting")
end

function BossGolemKing:ArcAttack()
	self:Rest(self.ArcAttackRestTime)

	if not self.Target then return end

	local a = self:GetFootPosition()
	local b = self.Target.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)
	local directionCFrame = CFrame.new(a, Vector3.new(b.X, a.Y, b.Z))

	local radius = 8

	local lower = -90
	local upper = 90
	local step = (upper - lower) / 3
	for deltaTheta = lower, upper, step do
		local cframe = directionCFrame * CFrame.Angles(0, math.rad(deltaTheta), 0) * CFrame.new(0, 0, -radius)

		self:CircleAttack(cframe.Position, radius, self.ArcAttackTelegraphTime, self.ArcAttackDamage)
	end

	self:AnimationPlay("BossGolemKingAttack")
	self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
	spawn(function()
		task.wait(self.ArcAttackTelegraphTime)
		self:PlaySound("ExplosionSmall2", {0.9, 1.1})
	end)
end

function BossGolemKing:LineAttack()
	self:Rest(self.LineAttackRestTime)

	if not self.Target then return end

	local directionVector = self.Target.Character.HumanoidRootPart.Position - self:GetPosition()
	directionVector = Vector3.new(
		directionVector.X,
		0,
		directionVector.Z
	).Unit
	local directionCFrame = CFrame.new(Vector3.new(), directionVector)

	for _, angle in pairs{0, math.pi/2, math.pi, -math.pi/2} do
		local direction = (directionCFrame * CFrame.Angles(0, angle, 0)).LookVector
		local radius = 6
		local attackDelay = 0
		local attackDelayStep = 0.1
		for distance = radius, radius * 4, radius do
			local point = self:GetFootPosition() + direction * distance
			spawn(function()
				task.wait(attackDelay)
				self:CircleAttack(point, radius, self.LineAttackTelegraphTime, self.LineAttackDamage)
			end)
			attackDelay = attackDelay + attackDelayStep
		end
	end

	self:FaceTowardsPoint(self:GetPosition() + directionVector)
	self:AnimationPlay("BossGolemKingStomp")

	spawn(function()
		task.wait(self.LineAttackTelegraphTime)
		self:PlaySound("ExplosionLoud")
	end)
end

function BossGolemKing:AreaAttack()
	self:Rest(self.AreaAttackRestTime)

	local players = self:GetPlayersInArea(self:GetPosition(), 64)
	for _, player in pairs(players) do
		local position = player.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)
		self:CircleAttack(position, 12, self.AreaAttackTelegraphTime, self.AreaAttackDamage)

		local rock = Instance.new("Part")
		rock.Size = Vector3.new(8, 8, 8)
		rock.Position = position + Vector3.new(0, 128 * self.AreaAttackTelegraphTime, 0)
		rock.Anchored = false
		rock.CanCollide = false
		rock.BrickColor = BrickColor.new("Dark stone grey")
		rock.Material = Enum.Material.Slate
		rock.CFrame = CFrame.new(rock.Position) * CFrame.Angles(math.random(), math.random(), math.random())
		rock.Parent = workspace

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = Vector3.new(0, -128, 0)
		bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bodyVelocity.Parent = rock

		spawn(function()
			task.wait(0.8)
			self:PlaySoundAtPosition(position, "ImpactHuge")
		end)

		-- Clean up the rock after it hits
		spawn(function()
			task.wait(5)
			if rock.Parent then
				rock:Destroy()
			end
		end)
	end

	self:AnimationPlay("BossGolemKingRoar")

	spawn(function()
		task.wait(self.AreaAttackTelegraphTime)
		self:PlaySound("BossGolemKingRoar")
	end)
end

function BossGolemKing:CircleAttack(position, radius, telegraphTime, damage)
	-- Create a circle telegraph
	local telegraph = Instance.new("Part")
	telegraph.Name = "CircleTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Cylinder
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Dark stone grey")
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

function BossGolemKing:GetPlayersInArea(position, radius)
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

function BossGolemKing:PlaySound(soundName, pitch)
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

function BossGolemKing:PlaySoundAtPosition(position, soundName, pitch)
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

function BossGolemKing:DamagePlayer(player, damage)
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
		label.TextColor3 = Color3.new(0.4, 0.3, 0.2) -- Stone brown
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

function BossGolemKing:DieIfDead()
	if self.Health <= 0 then
		self.Active = false

		self:AnimationPlay("BossGolemKingRoar")
		spawn(function()
			task.wait(self.AreaAttackTelegraphTime)
			self:PlaySound("BossGolemKingRoar")
			task.wait(1)
			if self.Model then
				self.Model:BreakJoints()
			end
		end)
	end
end

function BossGolemKing:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
end

return BossGolemKing