return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 900,
	["MovementSpeed"] = 18,
	
	["Attack"] = {
		Size = 7.5,
		Range = 6,
		Damage = 55,
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
		Attack = "BerzerkerSweep"
	},
	
	-- difficulty
	["Difficulty"] = 120,
	
	-- special properties
	["AttackType"] = "Arc",
	
	-- preserve model reference
	model = script["Elite Demon Berzerker"],
}