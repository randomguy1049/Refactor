return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 210,
	["MovementSpeed"] = 8,
	
	["Attack"] = {
		Range = 32,
		Damage = 15,
		AttackSpeed = 24,
		ProjectileModelName = "Arrow",
		ProjectileModelRotation = "UNSUPPORTED",
		BurstTime = 2,
		BurstCount = 3
	},
	
	-- sounds
	["Sounds"] = {
		Death = "MonsterDeath2",
		Attack = "BowShot",
		Spawn = "MonsterGrunt1",
		Hurt = "MonsterHurt2",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "BowShoot"
	},
	
	-- difficulty
	["Difficulty"] = 15,
	
	-- special properties
	["AttackRestTime"] = 7,
	
	model = script["Undead Archer"],
}