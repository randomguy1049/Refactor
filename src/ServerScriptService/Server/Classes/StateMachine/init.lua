local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(owner: Enemy, states: { State }?) 
	assert(owner, "Owner must be passed to State Machines")
	
	local self = setmetatable({}, StateMachine) -- State Machine Inherits Enemy Properties

	self.Owner = owner
	self.OnUpdate = shared.Task.PostTicks:Connect(Update, self)
	self.CurrentState = nil
	self.States = states or {}
	
	print(self.CurrentState, self.States)
	
	return self
end

function Update(self: StateMachine)
	if self.CurrentState and self.CurrentState.Update then
		self.CurrentState.Update(self.Owner) -- Passing in "self" (State Machine inherits Enemy Properties)
	end
end

function StateMachine:AddState(state: State)
	self.States[state.Name] = state
end

function StateMachine:SetState(stateName: string)
	assert(self.States[stateName], "State Machine does not have "..stateName.." State")

	if self.CurrentState and self.CurrentState.Exit then
		self.CurrentState.Exit(self.Owner)
	end

	self.CurrentState = self.States[stateName]

	if self.CurrentState and self.CurrentState.Enter then
		self.CurrentState.Enter(self.Owner)
	end
end

return StateMachine