-- Shover behavior - now uses shared methods from EnemyLoader
local Shover = {
	States = {
		["Waiting"] = {
			Enter = function(self)
				self.Target = nil
			end,
			Update = function(self)
				if not self.Active then return end

				self.Target = self:GetClosestPlayer()
				if self.Target then
					self.StateMachine:SetState("Shoving")
				end
			end,
		},
		["Shoving"] = {
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
function Shover:Attack()
	if not self.AttackAble then return end
	if not self.Target then return end

	self:Rest()

	self:AnimationPlay(self.AttackAnimation or "MonsterAttack")
	self:PlaySound(self.SoundAttackName or "push", {0.9, 1.1})

	local speed = 32
	local duration = self.AttackDistance / speed

	if self.Target.Character and self.Target.Character:FindFirstChild("HumanoidRootPart") then
		self:PushPlayer(self.Target, self.Root.CFrame.LookVector, speed, duration)
		self:DamagePlayer(self.Target, 20)

		-- Create visual effect for the push
		local effect = Instance.new("Part")
		effect.Name = "PushEffect"
		effect.Anchored = true
		effect.CanCollide = false
		effect.Shape = Enum.PartType.Ball
		effect.Material = Enum.Material.Neon
		effect.BrickColor = BrickColor.new("Bright green")
		effect.Transparency = 0.5
		effect.Size = Vector3.new(4, 4, 4)
		effect.Position = self.Target.Character.HumanoidRootPart.Position
		effect.Parent = workspace

		local TweenService = game:GetService("TweenService")
		local effectTween = TweenService:Create(effect,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = Vector3.new(1, 1, 1), Transparency = 1}
		)
		effectTween:Play()

		game:GetService("Debris"):AddItem(effect, 0.5)
	end
end

return Shover