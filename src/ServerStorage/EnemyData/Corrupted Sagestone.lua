return {
	-- behaviour type
	["BehaviorType"] = "LineAttacker",
	
	-- stats
	["MaxHealth"] = 80,
	["MovementSpeed"] = 6,
	
	["Attack"] = {
		Range = 32,
		Damage = 40,
		AttackSpeed = 2.75,
		TelegraphTime = 1,
		Width = 4,
		Length = 32
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
	
	-- preserve model reference
	model = script["Corrupted Sagestone"],
}