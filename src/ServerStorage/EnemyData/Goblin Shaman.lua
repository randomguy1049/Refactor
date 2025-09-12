return {
	-- behaviour type
	["BehaviorType"] = "CowardHealer",
	
	-- stats
	["MaxHealth"] = 100,
	["MovementSpeed"] = 12,
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath1",
		Spawn = "MonsterGrunt3",
		Hurt = "MonsterHurt1",
	},
	
	-- difficulty
	["Difficulty"] = 4,
	
	-- special properties
	["HealRestTime"] = 5,
	["HealAmount"] = 40,
	["HealRange"] = 16,
	["HealAnimation"] = "ShamanCast",
	
	-- preserve model reference
	model = script["Goblin Shaman"],
}