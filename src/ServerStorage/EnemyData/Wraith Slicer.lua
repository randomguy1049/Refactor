return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 1300,
	["MovementSpeed"] = 22,
	
	["Attack"] = {
		Size = 5,
		Range = 6,
		Damage = 90,
		AttackSpeed = 1 / 0.5,
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
		Attack = "BerzerkerSweep"
	},
	
	-- difficulty
	["Difficulty"] = 200,
	
	-- special properties
	["AttackType"] = "Arc",
	
	model = script["Wraith Slicer"],
}