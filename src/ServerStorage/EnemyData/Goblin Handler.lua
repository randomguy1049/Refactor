return {
	-- behaviour type
	["BehaviorType"] = "Summoner",
	
	-- stats
	["MaxHealth"] = 600,
	["MovementSpeed"] = 16,
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath2",
		Attack = "MonsterAttackBig",
		Spawn = "MonsterGrunt1",
		Hurt = "MonsterHurt2",
	},
	
	-- difficulty
	["Difficulty"] = 15,
	
	-- special properties
	["SummonRestTime"] = 3,
	["SummonTime"] = 1,
	["SummonAnimation"] = "CommanderTenHut",
	["SummonNames"] = "Goblin:1,Predictive Goblin:1,Tricky Goblin:1,",
	
	-- preserve model reference
	model = script["Goblin Handler"],
}