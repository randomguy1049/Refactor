-- Helper functions for ChaseMelee behavior
local function GetPredictionDelta(enemy)
	if not enemy.Target or not enemy.Target.Character then return Vector3.new(0, 0, 0) end
	local velocity = enemy.Target.Character.HumanoidRootPart.Velocity
	velocity = Vector3.new(velocity.X, 0, velocity.Z)
	return velocity * enemy.AttackTelegraphTime
end

local function GetTargetedAttackPosition(enemy)
	if not enemy.Target then return enemy:GetFootPosition() end
	return enemy.Target.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0)
end

local function GetPredictiveAttackPosition(enemy)
	return GetTargetedAttackPosition(enemy) + GetPredictionDelta(enemy)
end

local function GetAntiPredictiveAttackPosition(enemy)
	return GetTargetedAttackPosition(enemy) - GetPredictionDelta(enemy)
end

local function GetAttackPosition(enemy)
	if enemy.AttackType == "Targeted" then
		return GetTargetedAttackPosition(enemy)
	elseif enemy.AttackType == "Predictive" then
		return GetPredictiveAttackPosition(enemy)
	elseif enemy.AttackType == "Anti-Predictive" then
		return GetAntiPredictiveAttackPosition(enemy)
	else
		return GetTargetedAttackPosition(enemy)
	end
end

local function PerformAttackTelegraph(enemy, position)
	enemy:FaceTowardsPoint(position)
	enemy:CircleAttackWithCallback(position, enemy.AttackSize, enemy.AttackTelegraphTime, function()
		local players = enemy:GetPlayersInArea(position, enemy.AttackSize)
		for _, player in pairs(players) do
			enemy:DamagePlayer(player, enemy.AttackDamage)
		end
	end)
end

local function ArcAttack(enemy)
	if not enemy.Target then return end

	local directionVector = (enemy.Target.Character.HumanoidRootPart.Position - enemy:GetPosition())
	directionVector = Vector3.new(directionVector.X, 0, directionVector.Z)
	local directionCFrame = CFrame.new(enemy:GetPosition(), enemy:GetPosition() + directionVector)

	for _, angleDegrees in pairs{-75, 0, 75} do
		local angle = math.rad(angleDegrees)
		local attackPoint = enemy:GetFootPosition() + (directionCFrame * CFrame.Angles(0, angle, 0)).LookVector * enemy.AttackSize
		PerformAttackTelegraph(enemy, attackPoint)
	end
end

local function Attack(enemy)
	if enemy.State == "Resting" then return end
	if not enemy.Target then return end

	enemy.StateMachine:SetState("Resting")
	enemy:MoveStop()
	enemy:AnimationPlay(enemy.AttackAnimation or "MonsterAttack", nil, nil, 0.5 / enemy.AttackTelegraphTime)

	if enemy.AttackType == "Linear" then
		for _, attackPosition in ipairs{
			GetPredictiveAttackPosition(enemy),
			GetAntiPredictiveAttackPosition(enemy),
			GetTargetedAttackPosition(enemy),
			} do
			PerformAttackTelegraph(enemy, attackPosition)
		end
	elseif enemy.AttackType == "Arc" then
		ArcAttack(enemy)
	else
		local attackPosition = GetAttackPosition(enemy)
		PerformAttackTelegraph(enemy, attackPosition)
	end
end

-- ChaseMelee behavior - now uses shared methods from EnemyLoader
local ChaseMelee = {
	States = {
		["Spawning"] = {
			Enter = function(self)
				task.wait(0.25)
				if self.Active then
					self.StateMachine:SetState("Waiting")
				end
			end,
		},
		["Waiting"] = {
			Enter = function(self)
				self.Target = nil
			end,
			Update = function(self)
				if not self.Active then return end
				print("ayo")
				self.Target = self:GetClosestPlayer()
				if self.Target then
					self.StateMachine:SetState("Chasing")
					self:AnimationPlay("MonsterWalk")
				end
			end,
		},
		["Chasing"] = {
			Enter = function(self)
				if not self.Active then return end
				self:AnimationPlay("MonsterWalk")
			end,
			Update = function(self)
				if not self.Active then return end

				if self.Target then
					self:MoveTo(self.Target.Character.HumanoidRootPart.Position)

					if self:DistanceToCharacter(self.Target) < self.AttackRange and self:CanSeePoint(self.Target.Character.HumanoidRootPart.Position) then
						Attack(self)
					end

					self.Target = self:GetClosestPlayer()
				else
					self.StateMachine:SetState("Waiting")
					self:AnimationStop("MonsterWalk")
				end
			end,
			Exit = function(self)
				self:AnimationStop("MonsterWalk")
			end,
		},
		["Resting"] = {
			Enter = function(self)
				self:AnimationStop("MonsterWalk")
				task.wait(self.AttackTelegraphTime + self.AttackRestTime)
				if self.Active then
					self.StateMachine:SetState("Chasing")
					self:AnimationPlay("MonsterWalk")
				end
			end,
		}
	}
}

return ChaseMelee