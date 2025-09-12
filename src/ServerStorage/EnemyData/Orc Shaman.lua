return {
	-- behaviour type
	["BehaviorType"] = "CowardHealer",
	
	-- stats
	["MaxHealth"] = 150,
	["MovementSpeed"] = 12,
	
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
	["Difficulty"] = 10,
	
	-- special properties
	["HealAmount"] = 100,
	["HealRange"] = 16,
	["HealRestTime"] = 3,
	["HealAnimation"] = "ShamanCast",
	
	model = script["Orc Shaman"],
}