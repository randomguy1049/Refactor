local ticksPerSecond = 20
local connection = nil
local TaskLists = {}

local self = {}

function self.initialize()
	self.Tick = 0
	self.OnTick = shared.Event.new()
	self.PostTicks = shared.Event.new()
	self.TickSpeed = ticksPerSecond
end

function self:Start(st)
	if connection ~= nil then
		return false
	end
	self.StartTime = st
	connection = game:GetService("RunService").Heartbeat:Connect(Loop)
	return true
end

function self:Stop()
	if connection == nil then
		return false
	end
	connection:Disconnect()
	connection = nil
	self.Tick = 0
	return true
end

function self:Wait(amount)
	local scheduled = self.Tick + math.max(amount, 1)
	local TaskList = TaskLists[scheduled]
	if TaskList == nil then
		TaskList = shared.List.new()
		TaskLists[scheduled] = TaskList
	end
	TaskList:InsertBack({ Thread = coroutine.running() })
	return coroutine.yield()
end

function self:Delay(amount, func, ...)
	local scheduled = self.Tick + math.max(amount, 1)
	local TaskList = TaskLists[scheduled]
	if TaskList == nil then
		TaskList = shared.List.new()
		TaskLists[scheduled] = TaskList
	end
	return TaskList:InsertBack({ Function = func, Parameters = { ... } })
end

function Loop(delta: number)
	local CurrentTick = math.round((workspace:GetServerTimeNow() - self.StartTime) * ticksPerSecond)
	if self.Tick >= CurrentTick then
		return
	end
	while self.Tick < CurrentTick do
		self.Tick += 1
		self.OnTick:Fire(self.Tick)
		local TaskList = TaskLists[self.Tick]
		if TaskList == nil then
			continue
		end
		local ScheduledTask = TaskList.Next
		while ScheduledTask ~= TaskList do
			if ScheduledTask.Thread then
				task.spawn(ScheduledTask.Thread, self.Tick)
			else
				shared.Thread:Spawn(ScheduledTask.Function, table.unpack(ScheduledTask.Parameters))
			end
			ScheduledTask = ScheduledTask.Next
		end

		TaskList[self.Tick] = nil
	end
	self.PostTicks:Fire(self.Tick)
end

return self