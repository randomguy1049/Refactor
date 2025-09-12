-- CowardHealer behavior - now uses shared methods from EnemyLoader
local CowardHealer = {
	States = {
		["Waiting"] = {
			Enter = function(self)
				self.Attacker = nil
				self.Target = nil
			end,
			Update = function(self)
				if not self.Active then return end

				self.Attacker = self:GetClosestPlayer()
				if self.Attacker and self:DistanceToCharacter(self.Attacker) <= self.DetectionRange then
					self.StateMachine:SetState("Evading")
					self:AnimationPlay("MonsterWalk")
				else
					self.Target = self:GetEnemyToHeal()
					if self.Target then
						self.StateMachine:SetState("Healing")
					end
				end
			end,
		},
		["Healing"] = {
			Update = function(self)
				if not self.Active then return end

				if self.Target then
					if self:DistanceToEnemy(self.Target) > self.HealRange then
						self:MoveTo(self.Target:GetPosition())
						self:AnimationPlay("MonsterWalk")
					else
						if self:DistanceToEnemy(self.Target) <= self.HealRange then
							self:MoveStop()
							self:AnimationStop("MonsterWalk")

							if self.HealAble then
								self:Heal()
								self:Rest()
							end
						end
					end
				else
					self.StateMachine:SetState("Waiting")
					self:MoveStop()
					self:AnimationStop("MonsterWalk")
				end

				self.Attacker = self:GetClosestPlayer()
				if self.Attacker and self:DistanceToCharacter(self.Attacker) <= self.DetectionRange then
					self.StateMachine:SetState("Evading")
					self:AnimationPlay("MonsterWalk")
				end

				self.Target = self:GetEnemyToHeal()
			end,
			Exit = function(self)
				self:AnimationStop("MonsterWalk")
			end,
		},
		["Evading"] = {
			Enter = function(self)
				self:AnimationPlay("MonsterWalk")
			end,
			Update = function(self)
				if not self.Active then return end

				if self.Attacker then
					local attackerPosition = self.Attacker.Character.HumanoidRootPart.Position
					local delta = self:GetPosition() - attackerPosition
					local direction = delta.Unit
					local escapePoint = self:GetPosition() + (direction * 4)
					self:MoveTo(escapePoint)

					if self:DistanceToCharacter(self.Attacker) > self.EvadeRange then
						self.StateMachine:SetState("Waiting")
						self:MoveStop()
						self:AnimationStop("MonsterWalk")
					end

					self.Attacker = self:GetClosestPlayer()
				else
					self.StateMachine:SetState("Waiting")
				end
			end,
			Exit = function(self)
				self:AnimationStop("MonsterWalk")
			end,
		}
	}
}

return CowardHealer