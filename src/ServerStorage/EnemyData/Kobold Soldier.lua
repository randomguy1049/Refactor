return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 180,
	["MovementSpeed"] = 13.5,
	
	["Attack"] = {
		Size = 4.5,
		Range = 6,
		Damage = 45,
		AttackSpeed = 3.25,
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
	["CombatSeconds"] = 1.5,
	
	-- preserve model reference
	model = script["Kobold Soldier"],
}