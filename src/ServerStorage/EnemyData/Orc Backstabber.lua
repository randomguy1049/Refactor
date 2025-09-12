return {
	-- behaviour type
	["BehaviorType"] = "Assassin",
	
	-- stats
	["MaxHealth"] = 500,
	["MovementSpeed"] = 18,
	
	["Attack"] = {
		Size = 6,
		Range = 6,
		Damage = 40,
		AttackSpeed = 1.75,
		TelegraphTime = 1
	},
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath2",
		Attack = "MetalStab",
		Spawn = "MonsterGrunt1",
		Hurt = "MonsterHurt2",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "AssassinAttack"
	},
	
	-- difficulty
	["Difficulty"] = 35,
	
	-- preserve model reference
	model = script["Orc Backstabber"],
}