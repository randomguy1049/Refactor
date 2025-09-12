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
	["Difficulty"] = 20,
	
	-- special properties
	["HealAmount"] = 250,
	["HealRange"] = 24,
	["HealRestTime"] = 2.25,
	["HealAnimation"] = "ShamanCast",
	
	model = script["Undead Healer"],
}