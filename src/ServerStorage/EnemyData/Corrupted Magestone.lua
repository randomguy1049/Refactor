return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 80,
	["MovementSpeed"] = 6,
	
	["Attack"] = {
		Range = 32,
		Damage = 40,
		AttackSpeed = 2.75,
		ProjectileCount = 3,
		FanAngle = 120,
		Speed = 12,
		ProjectileModelName = "PurpleMagic",
		ProjectileModelRotation = "UNSUPPORTED"
	},
	
	-- sounds
	["Sounds"] = {
		Death = "StoneCrumble",
		Attack = "MagicElectric",
		Spawn = "",
		Hurt = "",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "MageCast"
	},
	
	-- difficulty
	["Difficulty"] = -1,
	
	-- preserve model reference
	model = script["Corrupted Magestone"],
}