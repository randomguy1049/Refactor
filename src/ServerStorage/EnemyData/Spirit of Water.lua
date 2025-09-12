return {
	-- behaviour type
	["BehaviorType"] = "DamageZoneMaker",
	
	-- stats
	["MaxHealth"] = 80,
	["MovementSpeed"] = 6,
	
	["Attack"] = {
		Size = 8,
		Range = 24,
		Damage = 120,
		TelegraphTime = 1.5,
		Duration = 6
	},
	
	-- sounds
	["Sounds"] = {
		Death = "",
		Attack = "MagicElectric",
		Spawn = "",
		Hurt = "",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "MageCast"
	},
	
	-- difficulty
	["Difficulty"] = -1,
	
	-- special properties
	["AttackRestTime"] = 3,
	
	model = script["Spirit of Water"],
}