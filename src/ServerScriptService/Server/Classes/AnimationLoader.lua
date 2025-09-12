local AnimationLoader = {}

function AnimationLoader.new(model: Model)
	assert(model, "Must pass in a model.")
	local self = setmetatable({}, {__index = AnimationLoader})
	
	self.Animator = model:FindFirstChildOfClass("Humanoid")
	self.Animations = {}
	
	return self
end

function AnimationLoader:Load(name: string)
	assert(name, "Must pass in animation.")
	local animation = game.ReplicatedStorage.Assets.Animations[name]
	self.Animations[name] = self.Animator:LoadAnimation(animation)
end

function AnimationLoader:Play(name: string)
	assert(name, "Must pass in name.")
	self.Animations[name]:Play()
end

function AnimationLoader:Stop(name: string)
	assert(name, "Must pass in name.")
	self.Animations[name]:Stop()
end

return AnimationLoader