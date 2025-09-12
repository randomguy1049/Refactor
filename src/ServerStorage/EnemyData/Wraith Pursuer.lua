return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 1100,
	["MovementSpeed"] = 32,
	
	["Attack"] = {
		Size = 6,
		Range = 6,
		Damage = 90,
		AttackSpeed = 1 / 0.1,
		TelegraphTime = 0.75
	},
	
	-- sounds
	["Sounds"] = {
		Death = "",
		Attack = "MonsterAttackBig",
		Spawn = "",
		Hurt = "",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "HeavyPunch"
	},
	
	-- difficulty
	["Difficulty"] = 250,
	
	model = script["Wraith Pursuer"],
}