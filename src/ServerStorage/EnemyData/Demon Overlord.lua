return {
	-- behaviour type
	["BehaviorType"] = "CowardHealer",
	
	-- stats
	["MaxHealth"] = 5000,
	["MovementSpeed"] = 14,
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath2",
		Spawn = "MonsterGrunt1",
		Hurt = "MonsterHurt2",
	},
	
	-- difficulty
	["Difficulty"] = 100,
	
	-- special properties
	["HealRestTime"] = 10,
	["HealAmount"] = 1500,
	["HealRange"] = 32,
	["HealAnimation"] = "ShamanCast",
	
	-- preserve model reference
	model = script["Demon Overlord"],
}