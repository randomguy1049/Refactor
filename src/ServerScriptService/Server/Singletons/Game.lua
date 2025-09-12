local self = {}

function self.start()
	shared.Task:Start(workspace:GetServerTimeNow())
	
	shared.EnemyLoader.new("Goblin", Vector3.new(0,20,0))
end

return self