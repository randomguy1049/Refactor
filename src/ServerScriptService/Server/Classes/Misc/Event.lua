local e, c = {}, {}
e.__index, c.__index = e, c

function e.new()
	local self = setmetatable({}, e)
	self.Next = self
	self.Prev = self
	return self
end

function e:Connect(func, param)
	local connection = {}
	connection.Func = func
	connection.Param = param
	connection.Next = self
	connection.Prev = self.Prev
	self.Prev.Next = connection
	self.Prev = connection
	return setmetatable(connection, c)
end

function e:Fire(...)
	local connection = self.Prev
	while connection ~= self do
		shared.Thread:Spawn(connection.Func, connection.Param, ...)
		connection = connection.Prev
	end
end

function c:Disconnect()
	self.Prev.Next = self.Next
	self.Next.Prev = self.Prev
end

return e
