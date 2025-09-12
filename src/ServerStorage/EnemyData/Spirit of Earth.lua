return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 80,
	["MovementSpeed"] = 10,
	
	["Attack"] = {
		Range = 32,
		Damage = 40,
		AttackSpeed = 20,
		ProjectileCount = 1,
		FanAngle = 0,
		ProjectileModelName = "EarthSpiritRock",
		ProjectileModelRotation = "UNSUPPORTED"
	},
	
	-- sounds
	["Sounds"] = {
		Death = "",
		Attack = "StoneCrumble",
		Spawn = "",
		Hurt = "",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "MageCast"
	},
	
	-- difficulty
	["Difficulty"] = -1,
	
	-- special properties
	["AttackRestTime"] = 2.75,
	
	model = script["Spirit of Earth"],
}