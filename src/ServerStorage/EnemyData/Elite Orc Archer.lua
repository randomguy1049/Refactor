return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 145,
	["MovementSpeed"] = 8,
	
	["Attack"] = {
		Range = 32,
		Damage = 15,
		AttackSpeed = 5,
		ProjectileCount = 3,
		FanAngle = 45,
		Speed = 24,
		ProjectileModelName = "Arrow",
		ProjectileModelRotation = "UNSUPPORTED",
		BurstTime = 1.5,
		BurstCount = 2
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
	["Difficulty"] = 13,
	
	-- preserve model reference
	model = script["Elite Orc Archer"],
}