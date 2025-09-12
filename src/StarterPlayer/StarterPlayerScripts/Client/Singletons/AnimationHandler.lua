local cs = game.CollectionService
local animations = game.ReplicatedStorage.Assets.Remotes.Animations

local self = {}

function self.start()
	-- load player animations
	
	
	-- load enemy animations
	for _, existing in cs:GetTagged("Enemy") do
		local Enemy = shared.AnimationLoader.new{
			Anim1 = "rbxassetid://29342039",
			Anim2 = "rbxassetid://48493532",
			Anim3 = "rbxassetid://69043870",
		}
	end
	cs:GetInstanceAddedSignal("Enemy"):Connect(function()
		local Enemy = shared.AnimationLoader.new{
			Anim1 = "rbxassetid://29342039",
			Anim2 = "rbxassetid://48493532",
			Anim3 = "rbxassetid://69043870",
		}
	end)
	cs:GetInstanceRemovedSignal("Enemy"):Connect(function()
		-- cleanup animations
	end)
	
	animations.OnClientEvent:Connect(function(EnemyId, AnimationName)
		
	end)
end

return self