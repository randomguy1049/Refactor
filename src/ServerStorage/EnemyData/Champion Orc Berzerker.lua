return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 800,
	["MovementSpeed"] = 18,
	
	["Attack"] = {
		Size = 5,
		Range = 6,
		Damage = 30,
		AttackSpeed = 1.25,
		TelegraphTime = 0.8
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
	["Difficulty"] = 30,
	
	-- special properties
	["AttackType"] = "Arc",
	
	-- preserve model reference
	model = script["Champion Orc Berzerker"],
}