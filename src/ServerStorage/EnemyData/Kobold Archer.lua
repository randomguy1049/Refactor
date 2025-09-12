return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 60,
	["MovementSpeed"] = 12,
	
	["Attack"] = {
		Range = 96,
		Damage = 5,
		AttackSpeed = 1.25,
		Speed = 32,
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
	["Difficulty"] = -1,
	
	-- special properties
	["CombatSeconds"] = 1,
	
	-- preserve model reference
	model = script["Kobold Archer"],
}