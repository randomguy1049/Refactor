return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 600,
	["MovementSpeed"] = 16,
	
	["Attack"] = {
		Size = 5,
		Range = 6,
		Damage = 30,
		AttackSpeed = 1.75,
		TelegraphTime = 1
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
	["Difficulty"] = 20,
	
	-- special properties
	["AttackType"] = "Arc",
	
	-- preserve model reference
	model = script["Orc Berzerker"],
}