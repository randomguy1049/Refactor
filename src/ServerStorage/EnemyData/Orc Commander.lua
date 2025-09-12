return {
	-- behaviour type
	["BehaviorType"] = "Summoner",
	
	-- stats
	["MaxHealth"] = 800,
	["MovementSpeed"] = 16,
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath2",
		Attack = "MonsterAttackBig",
		Spawn = "MonsterGrunt1",
		Hurt = "MonsterHurt2",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "CommanderTenHut"
	},
	
	-- difficulty
	["Difficulty"] = 20,
	
	-- special properties
	["SummonTime"] = 1,
	["SummonRestTime"] = 5,
	["SummonAnimation"] = "CommanderTenHut",
	["SummonNames"] = "Orc:5,Orc Knight:3,Orc Archer:1,",
	
	model = script["Orc Commander"],
}