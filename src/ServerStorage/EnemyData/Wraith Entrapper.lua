return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 1100,
	["MovementSpeed"] = 22,
	
	["Attack"] = {
		Size = 5,
		Range = 24,
		Damage = 90,
		AttackSpeed = 1 / 0.5,
		TelegraphTime = 0.75
	},
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath2",
		Attack = "MonsterAttackBig",
		Spawn = "MonsterGrunt1",
		Hurt = "MonsterHurt2",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "HeavyPunch"
	},
	
	-- difficulty
	["Difficulty"] = 220,
	
	-- special properties
	["AttackType"] = "Linear",
	
	model = script["Wraith Entrapper"],
}