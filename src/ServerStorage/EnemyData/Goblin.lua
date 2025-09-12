return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 60,
	["MovementSpeed"] = 12,
	
	["Attack"] = {
		Size = 4,
		Range = 6,
		Damage = 10,
		AttackSpeed = 1,
		TelegraphTime = 0.5
	},
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath1",
		Attack = "MonsterAttackSmall",
		Spawn = "MonsterGrunt3",
		Hurt = "MonsterHurt1",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "HeavyPunch"
	},
	
	-- difficulty
	["Difficulty"] = 1,
}