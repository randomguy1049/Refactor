return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 900,
	["MovementSpeed"] = 18,
	
	["Attack"] = {
		Size = 6,
		Range = 6,
		Damage = 45,
		AttackSpeed = 1,
		TelegraphTime = 0.7
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
		Attack = "BerzerkerSweep"
	},
	
	-- difficulty
	["Difficulty"] = 55,
	
	-- special properties
	["AttackType"] = "Arc",
	
	-- preserve model reference
	model = script["Demon Berzerker"],
}