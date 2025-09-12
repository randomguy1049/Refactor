local BossNecromancer = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local States = {
	["Spawning"] = {
		Enter = function(self)
			self:Taunt("How foolish... come, join my legion!")
			self:Rest(1)
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
				self:AnimationPlay("BossNecromancerWalk")
				self:AnimationStop("BossNecromancerIdle")
			end
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Chasing"] = {
		Enter = function(self)
			if not self.Active then return end
			self:AnimationPlay("BossNecromancerWalk")
			self:AnimationStop("BossNecromancerIdle")
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
				self:AnimationStop("BossNecromancerWalk")
				self:AnimationPlay("BossNecromancerIdle")
			end
		end,
		Exit = function(self)
			self:AnimationStop("BossNecromancerWalk")
		end,
	},
	["Resting"] = {
		Enter = function(self)
			self:AnimationStop("BossNecromancerWalk")
			self:AnimationPlay("BossNecromancerIdle")
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

function BossNecromancer.new(originalModel: Model, position: Vector3)
	-- Clone the model and set it up
	local model = originalModel:Clone()
	model.Parent = workspace
	model:MoveTo(position)

	-- Create the enemy instance
	local self = setmetatable({}, {__index = BossNecromancer})

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
		"EvasionSequence",
		"RechargeTaunt",
		"SummonBerzerkers",
		"EvasionSequence",
		"SummonHealer",
		"EvasionSequence",
		"RechargeTaunt",
		"SummonArchers",
	}
	self.AttackIndex = 1
	self.AttackRange = 24

	-- Taunt arrays
	self.BerzerkerTaunts = {
		"My legion shall slice your frail flesh!",
		"My legion shall cleave your bones!",
		"Your life shall be cut from you!",
		"I summon swordsmen from my legion!",
		"Mortuus excavare armis!",
	}

	self.ArcherTaunts = {
		"My legion will pierce your heart!",
		"Be pierced by the cold of death!",
		"Your impaled bodies will join my legion!",
		"I summon archers from my legion!",
		"Mortuus excavare sagittariis!",
	}

	self.HealerTaunts = {
		"Witness the immortality of undeath!",
		"The power of death courses within me!",
		"You cannot kill what is already dead!",
		"I summon a healer from my legion!",
		"Mortuus excavare medicus!",
	}

	self.RechargeTaunts = {
		"Muahahahahahahahaha!",
		"You cannot stand against my legion!",
		"My power grows as your life fades!",
		"You will serve me eternal, mortal!",
		"Soon, you join me in death!",
		"I am unstoppable!",
	}

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

function BossNecromancer:GetClosestPlayer()
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

function BossNecromancer:MoveTo(position)
	if self.Humanoid then
		self.Humanoid:MoveTo(position)
	end
end

function BossNecromancer:DistanceToCharacter(player)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return (self.Model:GetPivot().Position - player.Character.HumanoidRootPart.Position).Magnitude
	end
	return math.huge
end

function BossNecromancer:FaceTowardsPoint(position)
	local direction = (position - self.Model:GetPivot().Position).Unit
	self.Model:PivotTo(CFrame.lookAt(self.Model:GetPivot().Position, self.Model:GetPivot().Position + direction))
end

function BossNecromancer:GetPosition()
	return self.Model:GetPivot().Position
end

function BossNecromancer:GetFootPosition()
	return self.Model:GetPivot().Position + Vector3.new(0, -2, 0)
end

function BossNecromancer:AnimationPlay(animationName, fadeTime, weight, speed)
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

function BossNecromancer:AnimationStop(animationName)
	if self.Humanoid then
		for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.Name == animationName then
				track:Stop()
			end
		end
	end
end

function BossNecromancer:IsLow()
	return self.Health < (self.MaxHealth / 2)
end

function BossNecromancer:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossNecromancer:Rest(duration)
	self.RestDuration = duration or 1.25
	self.StateMachine:SetState("Resting")
end

function BossNecromancer:Taunt(message)
	if game:GetService("Chat") then
		game:GetService("Chat"):Chat(self.Model:FindFirstChild("Head"), message, Enum.ChatColor.Red)
	end
end

function BossNecromancer:SummonBerzerkers()
	-- Simplified summoning - create visual effects without actual enemies
	local centerPos = self:GetPosition()

	self:AnimationPlay("BossNecromancerCast")

	local count = 3
	if self:IsLow() then count = 6 end

	for berzerker = 1, count do
		-- Generate random spawn point around boss
		local angle = math.random() * math.pi * 2
		local distance = math.random(8, 16)
		local point = centerPos + Vector3.new(
			math.cos(angle) * distance,
			0,
			math.sin(angle) * distance
		)

		self:CircleAttack(point, 4, 0.5, 50)

		spawn(function()
			task.wait(0.5)
			-- Create a visual effect for summoned enemy
			local summonEffect = Instance.new("Part")
			summonEffect.Name = "SummonEffect"
			summonEffect.Size = Vector3.new(4, 8, 4)
			summonEffect.Material = Enum.Material.Neon
			summonEffect.BrickColor = BrickColor.new("Really red")
			summonEffect.Anchored = true
			summonEffect.CanCollide = false
			summonEffect.Position = point
			summonEffect.Parent = workspace

			-- Fade out the effect
			local tween = TweenService:Create(summonEffect,
				TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Transparency = 1}
			)
			tween:Play()

			Debris:AddItem(summonEffect, 3)
		end)
	end

	self:Taunt(self.BerzerkerTaunts[math.random(1, #self.BerzerkerTaunts)])

	self:Rest(0.5)
end

function BossNecromancer:SummonArchers()
	-- Simplified summoning - create visual effects without actual enemies
	local centerPos = self:GetPosition()

	self:AnimationPlay("BossNecromancerCast")

	local count = 2
	if self:IsLow() then count = 4 end

	for archer = 1, count do
		-- Generate random spawn point around boss
		local angle = math.random() * math.pi * 2
		local distance = math.random(12, 20)
		local point = centerPos + Vector3.new(
			math.cos(angle) * distance,
			0,
			math.sin(angle) * distance
		)

		self:CircleAttack(point, 4, 0.5, 50)

		spawn(function()
			task.wait(0.5)
			-- Create a visual effect for summoned enemy
			local summonEffect = Instance.new("Part")
			summonEffect.Name = "SummonEffect"
			summonEffect.Size = Vector3.new(4, 8, 4)
			summonEffect.Material = Enum.Material.Neon
			summonEffect.BrickColor = BrickColor.new("Dark green")
			summonEffect.Anchored = true
			summonEffect.CanCollide = false
			summonEffect.Position = point
			summonEffect.Parent = workspace

			-- Fade out the effect
			local tween = TweenService:Create(summonEffect,
				TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Transparency = 1}
			)
			tween:Play()

			Debris:AddItem(summonEffect, 3)
		end)
	end

	self:Taunt(self.ArcherTaunts[math.random(1, #self.ArcherTaunts)])

	self:Rest(0.5)
end

function BossNecromancer:SummonHealer()
	-- Simplified summoning - create visual effect and heal self
	local centerPos = self:GetPosition()

	self:AnimationPlay("BossNecromancerCast")

	-- Generate random spawn point around boss
	local angle = math.random() * math.pi * 2
	local distance = math.random(10, 16)
	local point = centerPos + Vector3.new(
		math.cos(angle) * distance,
		0,
		math.sin(angle) * distance
	)

	self:CircleAttack(point, 4, 0.5, 50)

	spawn(function()
		task.wait(0.5)
		-- Create a visual effect for summoned healer
		local healerEffect = Instance.new("Part")
		healerEffect.Name = "HealerEffect"
		healerEffect.Size = Vector3.new(4, 8, 4)
		healerEffect.Material = Enum.Material.Neon
		healerEffect.BrickColor = BrickColor.new("Bright green")
		healerEffect.Anchored = true
		healerEffect.CanCollide = false
		healerEffect.Position = point
		healerEffect.Parent = workspace

		-- Heal the necromancer
		self.Health = math.min(self.Health + 300, self.MaxHealth)
		if self.Humanoid then
			self.Humanoid.Health = self.Health
		end

		-- Show healing effect on necromancer
		self:ShowHealingEffect()

		-- Fade out the effect
		local tween = TweenService:Create(healerEffect,
			TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Transparency = 1}
		)
		tween:Play()

		Debris:AddItem(healerEffect, 3)
	end)

	self:Taunt(self.HealerTaunts[math.random(1, #self.HealerTaunts)])

	self:Rest(0.5)
end

function BossNecromancer:ShowHealingEffect()
	local healGui = Instance.new("BillboardGui")
	healGui.Size = UDim2.new(0, 100, 0, 50)
	healGui.Adornee = self.Model:FindFirstChild("Head")
	healGui.Parent = workspace

	local healLabel = Instance.new("TextLabel")
	healLabel.Size = UDim2.new(1, 0, 1, 0)
	healLabel.BackgroundTransparency = 1
	healLabel.Text = "+300"
	healLabel.TextColor3 = Color3.new(0, 1, 0) -- Green
	healLabel.TextScaled = true
	healLabel.Font = Enum.Font.SourceSansBold
	healLabel.Parent = healGui

	-- Animate healing text
	local tween = TweenService:Create(healLabel,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = UDim2.new(0, 0, -1, 0), TextTransparency = 1}
	)
	tween:Play()

	Debris:AddItem(healGui, 1)
end

function BossNecromancer:RechargeTaunt()
	self:Taunt(self.RechargeTaunts[math.random(1, #self.RechargeTaunts)])
	self:Rest(5)
end

function BossNecromancer:TeleportAttack()
	-- Generate random position around current area
	local currentPos = self:GetPosition()
	local angle = math.random() * math.pi * 2
	local distance = math.random(10, 20)
	local point = currentPos + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)

	self:CircleAttack(point, 6, 0.5, 50)

	self:AnimationPlay("BossNecromancerCast")
	spawn(function()
		task.wait(0.5)
		self.Model:PivotTo(CFrame.new(point + Vector3.new(0, 5, 0)))
		self:TurnInRandomDirection()
		self:PlaySound("MagicExplosionQuick", {0.8, 1.2})
	end)
end

function BossNecromancer:TurnInRandomDirection()
	local randomAngle = math.random() * math.pi * 2
	local currentPos = self:GetPosition()
	local direction = Vector3.new(math.cos(randomAngle), 0, math.sin(randomAngle))
	self.Model:PivotTo(CFrame.lookAt(currentPos, currentPos + direction))
end

function BossNecromancer:BlastAttack()
	self:AnimationPlay("BossNecromancerCast")
	self:CircleAttack(self:GetPosition(), 10, 0.5, 60)
	spawn(function()
		task.wait(0.5)
		self:PlaySound("MagicExplosionQuick", {0.8, 1.2})
	end)
end

function BossNecromancer:EvasionSequence()
	local teleportRest = 0.5
	local blastRest = 1
	local count = 3
	if self:IsLow() then
		teleportRest = 0.25
		blastRest = 0.75
		count = 5
	end
	local total = (teleportRest + blastRest) * count + 1

	spawn(function()
		for dodge = 1, count do
			self:TeleportAttack()
			task.wait(teleportRest)
			self:BlastAttack()
			task.wait(blastRest)
		end
	end)

	self:Rest(total)
end

function BossNecromancer:CircleAttack(position, radius, telegraphTime, damage)
	-- Create a circle telegraph
	local telegraph = Instance.new("Part")
	telegraph.Name = "CircleTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Cylinder
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Really black")
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

function BossNecromancer:GetPlayersInArea(position, radius)
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

function BossNecromancer:PlaySound(soundName, pitch)
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

function BossNecromancer:DamagePlayer(player, damage)
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
		label.TextColor3 = Color3.new(0.2, 0, 0.4) -- Dark purple
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

function BossNecromancer:DieIfDead()
	if self.Health <= 0 then
		self.Active = false

		spawn(function()
			task.wait(1)
			self:Taunt("No...")
			task.wait(1)
			self:Taunt("No, this...")
			task.wait(1)
			self:Taunt("THIS IS IMPOSSIBLE!!!")
			task.wait(1)
			if self.Model then
				self.Model:BreakJoints()
			end
		end)
	end
end

function BossNecromancer:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
end

return BossNecromancer