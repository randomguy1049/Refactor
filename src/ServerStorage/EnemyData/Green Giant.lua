return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 120,
	["MovementSpeed"] = 8,
	
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
	["Difficulty"] = 3,
	
	-- preserve model reference
	model = script["Green Giant"],
}