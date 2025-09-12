return {
	-- behaviour type
	["BehaviorType"] = "LineAttacker",
	
	-- stats
	["MaxHealth"] = 80,
	["MovementSpeed"] = 6,
	
	["Attack"] = {
		Range = 32,
		Damage = 40,
		TelegraphTime = 1,
		Length = 32,
		Width = 4
	},
	
	-- sounds
	["Sounds"] = {
		Death = "StoneCrumble",
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
	["AttackRestTime"] = 2.75,
	
	model = script["Spirit of Nature"],
}