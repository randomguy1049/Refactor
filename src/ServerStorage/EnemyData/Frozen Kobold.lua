return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 550,
	["MovementSpeed"] = 16,
	
	["Attack"] = {
		Size = 4.5,
		Range = 8,
		Damage = 50,
		AttackSpeed = 0.5,
		TelegraphTime = 0.35
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
	["Difficulty"] = -1,
	
	-- special properties
	["CombatSeconds"] = 10,
	
	-- preserve model reference
	model = script["Frozen Kobold"],
}