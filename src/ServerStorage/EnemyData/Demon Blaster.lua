return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 1100,
	["MovementSpeed"] = 20,
	
	["Attack"] = {
		Size = 16,
		Range = 16,
		Damage = 40,
		AttackSpeed = 3,
		TelegraphTime = 1.25
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
	["Difficulty"] = 85,
	
	-- preserve model reference
	model = script["Demon Blaster"],
}