return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 1100,
	["MovementSpeed"] = 20,
	
	["Attack"] = {
		Size = 5,
		Range = 12,
		Damage = 40,
		AttackSpeed = 0.5,
		TelegraphTime = 0.5
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
	["Difficulty"] = 65,
	
	-- special properties
	["AttackType"] = "Linear",
	
	-- preserve model reference
	model = script["Demon Champion"],
}