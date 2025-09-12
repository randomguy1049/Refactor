return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 80,
	["MovementSpeed"] = 8,
	
	["Attack"] = {
		Range = 32,
		Damage = 15,
		AttackSpeed = 2,
		Speed = 24,
		ProjectileModelName = "Arrow",
		ProjectileModelRotation = "UNSUPPORTED"
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
	["Difficulty"] = 4,
	
	-- preserve model reference
	model = script["Orc Archer"],
}