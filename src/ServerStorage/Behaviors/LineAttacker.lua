-- LineAttacker behavior - now uses shared methods from EnemyLoader
local LineAttacker = {
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
		["Firing"] = {
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
function LineAttacker:Attack()
	if not self.AttackAble then return end
	self:Rest()

	self:AnimationPlay(self.AttackAnimation or "MonsterAttack")
	self:PlaySound(self.SoundAttackName or "slash", {0.9, 1.1})

	local cframe = (self.Root.CFrame - Vector3.new(0, 2.5, 0)) * CFrame.new(0, 0, -self.AttackLength / 2)
	self:SquareAttack(cframe, self.AttackWidth, self.AttackLength, self.AttackTelegraphTime, self.AttackDamage)
end

return LineAttacker