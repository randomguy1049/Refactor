return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 450,
	["MovementSpeed"] = 6,
	
	["Attack"] = {
		Size = 7,
		Range = 10,
		Damage = 35,
		AttackSpeed = 1,
		TelegraphTime = 1
	},
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath2",
		Attack = "MonsterAttackBig",
		Spawn = "MonsterGrunt2",
		Hurt = "MonsterHurt2",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "HeavyPunch"
	},
	
	-- difficulty
	["Difficulty"] = 8,
	
	-- preserve model reference
	model = script["Armored Giant"],
}