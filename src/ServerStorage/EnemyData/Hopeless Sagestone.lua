return {
	-- behaviour type
	["BehaviorType"] = "Shover",
	
	-- stats
	["MaxHealth"] = 80,
	["MovementSpeed"] = 6,
	
	["Attack"] = {
		Range = 6,
		AttackSpeed = 4,
		Distance = 24
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
	model = script["Hopeless Sagestone"],
}