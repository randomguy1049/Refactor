-- Assassin behavior - now uses shared methods from EnemyLoader
local Assassin = {
	States = {
		["Waiting"] = {
			Enter = function(self)
				self.Target = nil
				self.Untargetable = false
			end,
			Update = function(self)
				if not self.Active then return end
				
				self.Target = self:GetClosestPlayer()
				if self.Target then
					self.StateMachine:SetState("Sneaking")
				end
			end,
		},
		["Sneaking"] = {
			Enter = function(self)
				if not self.Active then return end

				self:CreateSmokebomb()
				self:HideCharacter()
				self.Untargetable = true

				task.wait(2.5)
				if self.Active then
					self.StateMachine:SetState("Attacking")
				end
			end,
		},
		["Attacking"] = {
			Enter = function(self)
				if not self.Active or not self.Target or not self.Target.Character then 
					self.StateMachine:SetState("Waiting")
					return 
				end

				self:ShowCharacter()

				local targetPosition = self.Target.Character.HumanoidRootPart.Position
				local behindPosition = targetPosition + (self.Target.Character.HumanoidRootPart.CFrame.LookVector * -3)
				self.Root.CFrame = CFrame.new(behindPosition, targetPosition)

				self:AnimationPlay("Attack")
				local attackPosition = self.Target.Character.HumanoidRootPart.Position

				spawn(function()
					self:CircleAttackWithCallback(attackPosition, self.AttackSize / 2, self.AttackTelegraphTime, function()
						local playersInArea = self:GetPlayersInArea(attackPosition, self.AttackSize / 2)
						for _, player in pairs(playersInArea) do
							self:DamagePlayer(player, self.AttackDamage)
						end

						for i = 1, 3 do
							self:PlaySound("sword_slash")
							task.wait(0.1)
						end

						self.Untargetable = false

						if self.Active then
							self.StateMachine:SetState("Resting")
						end
					end)
				end)
			end,
		},
		["Resting"] = {
			Enter = function(self)
				task.wait(self.AttackRestTime)
				if self.Active then
					self.StateMachine:SetState("Waiting")
				end
			end,
		}
	}
}

-- Behavior-specific methods
function Assassin:HideCharacter()
	self.HiddenParts = {}
	local function recurse(root)
		for _, obj in pairs(root:GetChildren()) do
			if obj:IsA("BasePart") and obj ~= self.Root then
				table.insert(self.HiddenParts, {
					obj, obj.Transparency
				})
				obj.Transparency = 1
			elseif obj:IsA("Accessory") and obj:FindFirstChild("Handle") then
				table.insert(self.HiddenParts, {
					obj.Handle, obj.Handle.Transparency
				})
				obj.Handle.Transparency = 1
			end
			recurse(obj)
		end
	end
	recurse(self.Model)
end

function Assassin:ShowCharacter()
	if not self.HiddenParts then return end
	for _, data in pairs(self.HiddenParts) do
		if data[1] and data[1].Parent then
			data[1].Transparency = data[2]
		end
	end
	self.HiddenParts = nil
end

function Assassin:CreateSmokebomb()
	local smoke = Instance.new("Smoke")
	smoke.Size = 5
	smoke.Opacity = 0.8
	smoke.RiseVelocity = 2
	smoke.Parent = self.Root
	
	game:GetService("Debris"):AddItem(smoke, 2)
end

return Assassin