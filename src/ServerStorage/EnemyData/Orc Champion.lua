return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 500,
	["MovementSpeed"] = 14,
	
	["Attack"] = {
		Size = 5,
		Range = 6,
		Damage = 35,
		AttackSpeed = 1,
		TelegraphTime = 0.65
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
	["Difficulty"] = 35,
	
	-- special properties
	["AttackType"] = "Linear",
	
	model = script["Orc Champion"],
}