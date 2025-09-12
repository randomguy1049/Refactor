-- EvadeProjectile behavior - now uses shared methods from EnemyLoader
local EvadeProjectile = {
	States = {
		["Waiting"] = {
			Enter = function(self)
				self.Target = nil
			end,
			Update = function(self)
				if not self.Active then return end

				self.Target = self:GetClosestPlayer()
				if self.Target then
					self.StateMachine:SetState("Firing")
				end
			end,
		},
		["Evading"] = {
			Enter = function(self)
				self:AnimationPlay("MonsterWalk")
			end,
			Update = function(self)
				if not self.Active then return end

				if self.Target then
					local targetPosition = self.Target.Character.HumanoidRootPart.Position
					local delta = self:GetPosition() - targetPosition
					local direction = delta.Unit
					local escapePoint = self:GetPosition() + (direction * 4)
					self:MoveTo(escapePoint)

					if self:DistanceToCharacter(self.Target) > self.EvadeRange then
						self.StateMachine:SetState("Firing")
						self:MoveStop()
						self:AnimationStop("MonsterWalk")
					end

					self.Target = self:GetClosestPlayer()
				else
					self.StateMachine:SetState("Waiting")
				end
			end,
			Exit = function(self)
				self:AnimationStop("MonsterWalk")
			end,
		},
		["Firing"] = {
			Update = function(self)
				if not self.Active then return end

				if self.Target then
					self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)

					local distance = self:DistanceToCharacter(self.Target)
					if distance < self.EvadeRange then
						self.StateMachine:SetState("Evading")
						self:AnimationPlay("MonsterWalk")
					elseif distance < self.AttackRange then
						self:Attack()
					end

					self.Target = self:GetClosestPlayer()
				else
					self.StateMachine:SetState("Waiting")
				end
			end,
		}
	}
}

-- Behavior-specific methods
function EvadeProjectile:Attack()
	if not self.AttackAble then return end
	self:Rest()

	if self.AttackBurstCount == 1 then
		self:AttackImplementation()
	else
		local step = 1 / self.AttackBurstCount
		for attackNumber = 0, self.AttackBurstCount - 1 do
			spawn(function()
				task.wait(step * attackNumber)
				self:AttackImplementation()
			end)
		end
	end
end

function EvadeProjectile:AttackImplementation()
	if not self.Target then return end

	self:AnimationPlay(self.AttackAnimation or "MonsterAttack")

	if self.AttackProjectileCount == 1 then
		self:FireProjectile(self.ProjectileModelName, self.ProjectileModelRotation, self.AttackSpeed, self.Target.Character.HumanoidRootPart.Position, self.AttackDamage)
	else
		self:FireFan()
	end
end

function EvadeProjectile:FireFan()
	if not self.Target then return end

	local targetPoint = self.Target.Character.HumanoidRootPart.Position
	local delta = targetPoint - self:GetPosition()
	local directTheta = math.atan2(delta.Z, delta.X)
	local fanAngle = math.rad(self.AttackFanAngle)
	local lower = directTheta - (fanAngle / 2)
	local upper = directTheta + (fanAngle / 2)
	local step = (upper - lower) / (self.AttackProjectileCount - 1)

	for theta = lower, upper, step do
		local unit = Vector3.new(math.cos(theta), 0, math.sin(theta))
		self:FireProjectile(self.ProjectileModelName, self.ProjectileModelRotation, self.AttackSpeed, self:GetPosition() + unit, self.AttackDamage)
	end
end

function EvadeProjectile:ApplyAttackEffect(player)
	if self.AttackEffect == "Slow" and player.Character and player.Character:FindFirstChild("Humanoid") then
		local humanoid = player.Character.Humanoid
		local originalSpeed = humanoid.WalkSpeed
		local slowAmount = originalSpeed * 0.5

		humanoid.WalkSpeed = humanoid.WalkSpeed - slowAmount
		spawn(function()
			task.wait(1.5)
			humanoid.WalkSpeed = humanoid.WalkSpeed + slowAmount
		end)
	end
end

return EvadeProjectile