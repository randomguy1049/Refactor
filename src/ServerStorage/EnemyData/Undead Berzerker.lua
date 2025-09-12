return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 900,
	["MovementSpeed"] = 18,
	
	["Attack"] = {
		Size = 5,
		Range = 6,
		Damage = 30,
		AttackSpeed = 1 / 0.8,
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
	["Difficulty"] = 35,
	
	-- special properties
	["AttackType"] = "Arc",
	
	model = script["Undead Berzerker"],
}