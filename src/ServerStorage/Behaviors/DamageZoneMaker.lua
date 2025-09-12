-- DamageZoneMaker behavior - now uses shared methods from EnemyLoader
local DamageZoneMaker = {
	States = {
		["Waiting"] = {
			Enter = function(self)
				self.Target = nil
			end,
			Update = function(self)
				if not self.Active then return end

				self.Target = self:GetClosestPlayer()
				if self.Target then
					self.StateMachine:SetState("Attacking")
				end
			end,
		},
		["Attacking"] = {
			Update = function(self)
				if not self.Active then return end

				if self.Target then
					self:FaceTowardsPoint(self.Target.Character.HumanoidRootPart.Position)

					local distance = self:DistanceToCharacter(self.Target)
					if distance < self.AttackRange then
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
function DamageZoneMaker:Attack()
	if not self.AttackAble then return end
	if not self.Target then return end

	self:Rest()

	self:AnimationPlay(self.AttackAnimation or "MonsterCast")
	self:PlaySound(self.SoundAttackName or "magicexplosion", {0.9, 1.1})

	local function damageZone(position, size, duration, dps, rate)
		spawn(function()
			for t = 0, duration, rate do
				self:CircleAttack(position, size, rate, dps * rate, {NoExplosion = true})
				task.wait(rate)
			end
		end)
	end

	local position = self.Target.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)
	local theta = math.pi * 2 * math.random()
	local radius = self.AttackSize * math.random()
	position = position + Vector3.new(math.cos(theta) * radius, 0, math.sin(theta) * radius)

	self:CircleAttack(position, self.AttackSize, self.AttackTelegraphTime, 0, {NoExplosion = true})
	spawn(function()
		task.wait(self.AttackTelegraphTime)
		damageZone(position, self.AttackSize, self.AttackDuration, self.AttackDamage / self.AttackDuration, 0.25)
	end)
end

return DamageZoneMaker