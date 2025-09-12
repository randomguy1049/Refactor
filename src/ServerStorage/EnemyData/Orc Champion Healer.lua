return {
	-- behaviour type
	["BehaviorType"] = "CowardHealer",
	
	-- stats
	["MaxHealth"] = 300,
	["MovementSpeed"] = 14,
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath2",
		Attack = "",
		Spawn = "MonsterGrunt1",
		Hurt = "MonsterHurt2",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "ShamanCast"
	},
	
	-- difficulty
	["Difficulty"] = 35,
	
	-- special properties
	["HealAmount"] = 500,
	["HealRange"] = 16,
	["HealRestTime"] = 1.75,
	["HealAnimation"] = "ShamanCast",
	
	model = script["Orc Champion Healer"],
}