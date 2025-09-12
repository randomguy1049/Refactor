-- Eye boss behavior - now uses shared methods from EnemyLoader

local BossEye = {
	States = {
	["Spawning"] = {
		Enter = function(self)
			self.Target = self:GetClosestPlayer()
			if self.Target then
				self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
			end

			self:PlaySound("EyeSpawn")

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
				self:AnimationPlay("BossEyeWalk")
			end
		end,
		Exit = function(self)
			-- Clean up waiting state if needed
		end,
	},
	["Chasing"] = {
		Enter = function(self)
			if not self.Active then return end
			self:AnimationPlay("BossEyeWalk")
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
				self:AnimationStop("BossEyeWalk")
			end
		end,
		Exit = function(self)
			self:AnimationStop("BossEyeWalk")
		end,
	},
	["Resting"] = {
		Enter = function(self)
			self:AnimationStop("BossEyeWalk")
			task.wait(self.RestDuration or 0.75)
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


-- Behavior-specific methods

function BossEye:GetAttackRange()
	local currentAttack = self.AttackOrder[self.AttackIndex]
	if self.RangeByAttack[currentAttack] then
		return self.RangeByAttack[currentAttack]
	else
		return self.AttackRange
	end
end

function BossEye:Attack()
	local attackName = self.AttackOrder[self.AttackIndex]
	if self[attackName] then
		self[attackName](self)
	end

	self.AttackIndex = self.AttackIndex + 1
	if self.AttackIndex > #self.AttackOrder then
		self.AttackIndex = 1
	end
end

function BossEye:Rest(duration)
	self.RestDuration = duration or 0.75
	self.StateMachine:SetState("Resting")
end

function BossEye:SlashAttack()
	if self.Target then
		self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
	end

	self:AnimationPlay("BossEyeAttack")

	local length = 32
	local width = 4
	local t = 0.75
	for _, angle in pairs{-45, 0, 45} do
		local cframe = self.Root.CFrame * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, -4, -length/2)
		self:SquareAttack(cframe, width, length, t, 50)
	end
	spawn(function()
		task.wait(t)
		self:PlaySound("MetalStab")
	end)

	self:Rest(0.75)
end

function BossEye:SlashInvertAttack()
	self:AnimationPlay("BossEyeAttack")

	local length = 32
	local width = 4
	local t = 0.75
	for _, angle in pairs{-45/2, 45/2} do
		local cframe = self.Root.CFrame * CFrame.Angles(0, math.rad(angle), 0) * CFrame.new(0, -4, -length/2)
		self:SquareAttack(cframe, width, length, t, 50)
	end
	spawn(function()
		task.wait(t)
		self:PlaySound("MetalStab")
	end)

	self:Rest(0.75)
end

function BossEye:SpinAttack()
	if self.Target then
		self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)
	end

	local radius = 16
	local duration = 6
	local dps = 50
	local tph = 0.25

	self:AnimationPlay("BossEyeAttack")
	self:CircleAttack(self:GetFootPosition(), radius, 0.75, 0, {NoExplosion = true})

	spawn(function()
		task.wait(0.75)
		self:AnimationPlay("BossEyeSpin", nil, nil, 2)
		local timeLeft = duration
		while timeLeft > 0 do
			self:PlaySound("MetalStab", 1.4)

			if self.Target then
				self:MoveTo(self.Target.Character.HumanoidRootPart.Position)
			end
			self:CircleAttack(self:GetFootPosition(), radius, tph, dps * tph, {NoExplosion = true})

			task.wait(tph)
			timeLeft = timeLeft - tph
		end
		self:AnimationStop("BossEyeSpin")
	end)

	self:Rest(duration + 1)
end

function BossEye:BladeStormAttack()
	self:PlaySound("EyeSpawn")
	local startTheta = math.pi * 2 * math.random()

	for rots = 0, 1, 1/16 do
		local p = self:GetFootPosition()
		local theta = math.pi * 2 * rots + startTheta
		local radius = 32
		p = p + Vector3.new(math.cos(theta) * radius, 0, math.sin(theta) * radius)
		local cframe = CFrame.new(p, self:GetFootPosition())

		local t = 0.75 + rots
		self:SquareAttack(cframe, 4, 48, t, 50)
		spawn(function()
			task.wait(t)
			self:PlaySoundAtPosition(p, "MetalStab")
		end)
	end

	self:Rest(1)
end



return BossEye