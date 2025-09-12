return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 120,
	["MovementSpeed"] = 12,
	
	["Attack"] = {
		Size = 5,
		Range = 6,
		Damage = 25,
		AttackSpeed = 1,
		TelegraphTime = 0.65,
		Type = "Predictive"
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
	["Difficulty"] = 5,
	
	model = script["Orc"],
}