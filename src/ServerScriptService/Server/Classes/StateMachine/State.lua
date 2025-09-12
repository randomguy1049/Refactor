local State = {}
State.__index = State

function State.new(name: string, functions: { () -> () })
	assert(name, "Name must be provided for a new State")
	--assert(functions.Update, "Update function must be provided for a new State")

	local self = setmetatable({}, State)

	self.Name = name
	self.Enter = functions.Enter
	self.Update = functions.Update
	self.Exit = functions.Exit

	return self
end

return State