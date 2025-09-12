return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 350,
	["MovementSpeed"] = 12,
	
	["Attack"] = {
		Range = 32,
		Damage = 15,
		AttackSpeed = 20,
		ProjectileCount = 3,
		FanAngle = 60,
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
	["Difficulty"] = 35,
	
	-- special properties
	["AttackRestTime"] = 5,
	
	model = script["Orc Champion Archer"],
}