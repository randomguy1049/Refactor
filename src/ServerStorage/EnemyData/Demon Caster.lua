return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 1250,
	["MovementSpeed"] = 16,
	
	["Attack"] = {
		Size = 6,
		Range = 24,
		Damage = 40,
		AttackSpeed = 0.25,
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
	["Difficulty"] = 75,
	
	-- preserve model reference
	model = script["Demon Caster"],
}