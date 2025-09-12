return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 120,
	["MovementSpeed"] = 8,
	
	["Attack"] = {
		Size = 12,
		Range = 10,
		Damage = 35,
		AttackSpeed = 1,
		TelegraphTime = 1,
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
	["Difficulty"] = 6,
	
	model = script["Red Giant"],
}