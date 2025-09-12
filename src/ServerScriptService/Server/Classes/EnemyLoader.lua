type EnemyData = {
	BehaviorType: string,
}

local ServerStorage = game:GetService("ServerStorage")

local EnemyLoader = {}

function EnemyLoader.new(Name, Position)
	assert(Name, "Must Pass In Name.")
	assert(Position, "Must Pass In Position.")
	
	-- set enemy data to self
	local data = require(ServerStorage.EnemyData[Name])
	assert(data, "Data not found.")
	
	-- create self with data
	local self = setmetatable(data, {__index = EnemyLoader})
	
	-- with data get the enemy behaviour
	local behavior = ServerStorage.Behaviors[self.BehaviorType] or ServerStorage.Behaviors.Bosses[self.BehaviorType]
	assert(behavior, "No Behaviour Found.")
	behavior = require(behavior)
	
	-- make model here maybe
	self.Model = ServerStorage.EnemyModel[Name]:Clone()
	self.Model.Parent = workspace

	-- Set position
	if self.Model.PrimaryPart then
		self.Model:SetPrimaryPartCFrame(CFrame.new(Position))
		self.Root = self.Model.PrimaryPart
	else
		-- If no PrimaryPart, find the first part and use it as root
		for _, part in pairs(self.Model:GetChildren()) do
			if part:IsA("BasePart") then
				self.Root = part
				self.Root.CFrame = CFrame.new(Position)
				break
			end
		end
	end
	
	-- shared properties
	self.Active = true
	self.Health = 100
	self.MaxHealth = 100

	-- State management
	--self.State = "Waiting"
	self.Target = nil

	-- Attack properties
	self.AttackType = "Targeted" -- Can be "Targeted", "Predictive", "Anti-Predictive", "Linear", "Arc"
	self.AttackRange = 16
	self.AttackSize = 8
	self.AttackDamage = 25
	self.AttackTelegraphTime = 0.5
	self.AttackRestTime = 1
	
	self.Animations = shared.AnimationLoader.new(self.Model)
	self.Animations:Load("MonsterWalk")
	for _, name in self._Animations do self.Animations:Load(name) end
	
	-- with the behaviour spawn the enemy model at correct position
	-- take it as a table and load state machine in here
	self.StateMachine = shared.StateMachine.new(self, behavior.States)
	self.StateMachine:SetState("Waiting")
	
	return self
end

-- Common Utility Methods (extracted from behavior files)
function EnemyLoader:GetClosestPlayer()
	local closestPlayer = nil
	local closestDistance = math.huge
	
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (self:GetPosition() - player.Character.HumanoidRootPart.Position).Magnitude
			if distance < closestDistance then
				closestPlayer = player
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer
end

function EnemyLoader:MoveTo(position)
	if self.Humanoid then
		self.Humanoid:MoveTo(position)
	end
end

function EnemyLoader:MoveStop()
	if self.Humanoid then
		self.Humanoid:MoveTo(self:GetPosition())
	end
end

function EnemyLoader:DistanceToCharacter(player)
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return (self:GetPosition() - player.Character.HumanoidRootPart.Position).Magnitude
	end
	return math.huge
end

function EnemyLoader:DistanceToEnemy(enemy)
	if enemy and enemy.Model then
		return (self:GetPosition() - enemy.Model:GetPivot().Position).Magnitude
	end
	return math.huge
end

function EnemyLoader:CanSeePoint(position)
	local raycast = workspace:Raycast(self:GetPosition(), position - self:GetPosition())
	if raycast and raycast.Instance then
		local character = raycast.Instance.Parent
		if character and character:FindFirstChild("Humanoid") then
			return true
		end
		return false
	end
	return true
end

function EnemyLoader:FaceTowardsPoint(position)
	local direction = (position - self:GetPosition()).Unit
	self.Model:PivotTo(CFrame.lookAt(self:GetPosition(), self:GetPosition() + direction))
end

function EnemyLoader:GetPosition()
	return self.Model:GetPivot().Position
end

function EnemyLoader:GetFootPosition()
	return self:GetPosition() + Vector3.new(0, -2, 0)
end

function EnemyLoader:AnimationPlay(animationName, fadeTime, weight, speed)
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

function EnemyLoader:AnimationStop(animationName)
	if self.Humanoid then
		for _, track in pairs(self.Humanoid:GetPlayingAnimationTracks()) do
			if track.Animation.Name == animationName then
				track:Stop()
			end
		end
	end
end

function EnemyLoader:PlaySound(soundName, pitch)
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

function EnemyLoader:PlaySoundAtPosition(position, soundName, pitch)
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

function EnemyLoader:GetPlayersInArea(position, radius)
	local playersInArea = {}
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (position - player.Character.HumanoidRootPart.Position).Magnitude
			if distance <= radius then
				table.insert(playersInArea, player)
			end
		end
	end
	return playersInArea
end

function EnemyLoader:GetPlayersInSquareArea(cframe, width, length)
	local playersInArea = {}
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
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

function EnemyLoader:DamagePlayer(player, damage)
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid:TakeDamage(damage)
		
		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.new(0, 100, 0, 50)
		gui.Adornee = player.Character:FindFirstChild("Head")
		gui.Parent = workspace
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "-" .. damage
		label.TextColor3 = Color3.new(0.8, 0.2, 0.2)
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Parent = gui
		
		local TweenService = game:GetService("TweenService")
		local tween = TweenService:Create(label,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Position = UDim2.new(0, 0, -1, 0), TextTransparency = 1}
		)
		tween:Play()
		
		game:GetService("Debris"):AddItem(gui, 1)
	end
end

function EnemyLoader:DieIfDead()
	if self.Health <= 0 then
		self.Active = false
		
		spawn(function()
			task.wait(0.1)
			if self.Model then
				self.Model:BreakJoints()
			end
		end)
	end
end

function EnemyLoader:Destroy()
	self.Active = false
	if self.Model then
		self.Model:Destroy()
	end
end

-- Attack and Telegraph Methods
function EnemyLoader:CircleAttack(position, radius, telegraphTime, damage, options)
	options = options or {}
	
	local telegraph = Instance.new("Part")
	telegraph.Name = "CircleTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Cylinder
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = options.Color or BrickColor.new("Bright red")
	telegraph.Transparency = 0.7
	telegraph.Size = Vector3.new(1, radius * 2, radius * 2)
	telegraph.Position = position
	telegraph.Orientation = Vector3.new(0, 0, 90)
	telegraph.Parent = workspace
	
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(telegraph, 
		TweenInfo.new(telegraphTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.3}
	)
	tween:Play()
	
	spawn(function()
		task.wait(telegraphTime)
		tween:Cancel()
		telegraph:Destroy()
		
		if not options.NoExplosion and damage > 0 then
			local playersInArea = self:GetPlayersInArea(position, radius)
			for _, player in pairs(playersInArea) do
				self:DamagePlayer(player, damage)
			end
		end
	end)
end

function EnemyLoader:SquareAttack(cframe, width, length, telegraphTime, damage)
	local telegraph = Instance.new("Part")
	telegraph.Name = "SquareTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Bright yellow")
	telegraph.Transparency = 0.7
	telegraph.Size = Vector3.new(width, 1, length)
	telegraph.CFrame = cframe
	telegraph.Parent = workspace
	
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(telegraph, 
		TweenInfo.new(telegraphTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.3}
	)
	tween:Play()
	
	spawn(function()
		task.wait(telegraphTime)
		tween:Cancel()
		telegraph:Destroy()
		
		local playersInArea = self:GetPlayersInSquareArea(cframe, width, length)
		for _, player in pairs(playersInArea) do
			self:DamagePlayer(player, damage)
		end
	end)
end

function EnemyLoader:CircleAttackWithCallback(position, radius, telegraphTime, callback)
	local telegraph = Instance.new("Part")
	telegraph.Name = "CircleTelegraph"
	telegraph.Anchored = true
	telegraph.CanCollide = false
	telegraph.Shape = Enum.PartType.Cylinder
	telegraph.Material = Enum.Material.ForceField
	telegraph.BrickColor = BrickColor.new("Bright red")
	telegraph.Transparency = 0.7
	telegraph.Size = Vector3.new(1, radius * 2, radius * 2)
	telegraph.Position = position
	telegraph.Orientation = Vector3.new(0, 0, 90)
	telegraph.Parent = workspace
	
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(telegraph, 
		TweenInfo.new(telegraphTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{Transparency = 0.3}
	)
	tween:Play()
	
	spawn(function()
		task.wait(telegraphTime)
		tween:Cancel()
		telegraph:Destroy()
		callback()
	end)
end

-- Projectile Methods
function EnemyLoader:FireProjectile(modelName, rotation, speed, targetPosition, damage, startPosition)
	startPosition = startPosition or self:GetPosition()
	
	local projectile = Instance.new("Part")
	projectile.Name = "Projectile"
	projectile.Size = Vector3.new(1, 1, 3)
	projectile.Shape = Enum.PartType.Block
	projectile.Material = Enum.Material.Neon
	projectile.BrickColor = BrickColor.new("Bright blue")
	projectile.CanCollide = false
	projectile.Anchored = true
	projectile.Position = startPosition
	projectile.Parent = workspace
	
	local direction = (targetPosition - startPosition).Unit
	local distance = (targetPosition - startPosition).Magnitude
	local time = distance / speed
	
	projectile.CFrame = CFrame.lookAt(startPosition, targetPosition)
	
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(projectile,
		TweenInfo.new(time, Enum.EasingStyle.Linear),
		{Position = targetPosition}
	)
	tween:Play()
	
	local checkConnection
	checkConnection = game:GetService("RunService").Heartbeat:Connect(function()
		local playersHit = self:GetPlayersInArea(projectile.Position, 2)
		if #playersHit > 0 then
			checkConnection:Disconnect()
			tween:Cancel()
			
			for _, player in pairs(playersHit) do
				self:DamagePlayer(player, damage)
			end
			
			projectile:Destroy()
		end
	end)
	
	local connection
	connection = tween.Completed:Connect(function()
		connection:Disconnect()
		if checkConnection then checkConnection:Disconnect() end
		
		local playersHit = self:GetPlayersInArea(targetPosition, 3)
		for _, player in pairs(playersHit) do
			self:DamagePlayer(player, damage)
		end
		
		projectile:Destroy()
	end)
	
	game:GetService("Debris"):AddItem(projectile, time + 1)
end

-- Push/Knockback Methods  
function EnemyLoader:PushPlayer(player, direction, force, duration)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local push = Instance.new("BodyVelocity")
		push.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		push.Velocity = direction * force
		push.Parent = player.Character.HumanoidRootPart
		game:GetService("Debris"):AddItem(push, duration)
	end
end

-- Healing Methods (for CowardHealer behavior)
function EnemyLoader:GetEnemyToHeal()
	local enemies = {}
	
	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj ~= self.Model and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChild("Humanoid") then
			local isPlayer = false
			for _, player in pairs(game:GetService("Players"):GetPlayers()) do
				if player.Character == obj then
					isPlayer = true
					break
				end
			end
			
			if not isPlayer then
				local distance = (self:GetPosition() - obj:GetPivot().Position).Magnitude
				if distance <= 64 then
					local mockEnemy = {
						Model = obj,
						Health = obj.Humanoid.Health,
						MaxHealth = obj.Humanoid.MaxHealth,
						GetPosition = function() return obj:GetPivot().Position end
					}
					table.insert(enemies, mockEnemy)
				end
			end
		end
	end
	
	local damagedEnemies = {}
	for _, enemy in pairs(enemies) do
		if enemy.Health < enemy.MaxHealth then
			table.insert(damagedEnemies, enemy)
		end
	end
	
	if #damagedEnemies > 0 then
		local bestEnemy = damagedEnemies[1]
		local lowestHealth = bestEnemy.Health
		
		if #damagedEnemies > 1 then
			for index = 2, #damagedEnemies do
				local enemy = damagedEnemies[index]
				if enemy.Health < lowestHealth then
					lowestHealth = enemy.Health
					bestEnemy = enemy
				end
			end
		end
		
		return bestEnemy
	end
	
	return nil
end

function EnemyLoader:Heal(target, amount)
	target = target or self.Target
	amount = amount or (self.HealAmount or 30)
	
	if target and target.Model and target.Model:FindFirstChild("Humanoid") then
		local humanoid = target.Model.Humanoid
		humanoid.Health = math.min(humanoid.Health + amount, humanoid.MaxHealth)
		
		if target.Model:FindFirstChild("HumanoidRootPart") then
			local emitter = Instance.new("ParticleEmitter")
			emitter.Texture = "rbxassetid://241650934"
			emitter.Lifetime = NumberRange.new(0.5, 1.2)
			emitter.Rate = 100
			emitter.SpreadAngle = Vector2.new(360, 360)
			emitter.Speed = NumberRange.new(2, 5)
			emitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
			emitter.Parent = target.Model.HumanoidRootPart
			
			spawn(function()
				task.wait(0.25)
				emitter.Enabled = false
				task.wait(1)
				emitter:Destroy()
			end)
		end
	end
end

-- Rest/Cooldown Methods
function EnemyLoader:Rest(duration)
	if self.AttackAble ~= nil then
		self.AttackAble = false
		spawn(function()
			task.wait(duration or self.AttackRestTime or 1)
			self.AttackAble = true
		end)
	end
	
	if self.HealAble ~= nil then
		self.HealAble = false
		spawn(function()
			task.wait(duration or self.HealRestTime or 3)
			self.HealAble = true
		end)
	end
end

return EnemyLoader