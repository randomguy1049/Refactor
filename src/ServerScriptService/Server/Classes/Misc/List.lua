local list, links = {}, {}
list.__index, links.__index = list, links

function list.new()
	local self = setmetatable({}, list)
	self.List = self
	self.Next = self
	self.Prev = self
	return self
end

function list:InsertBack(link)
	link.Next = self
	link.Prev = self.Prev
	self.Prev.Next = link
	self.Prev = link
	return setmetatable(link, links)
end

return list