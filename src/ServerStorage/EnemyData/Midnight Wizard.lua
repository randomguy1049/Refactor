return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 80,
	["MovementSpeed"] = 6,
	
	["Attack"] = {
		Range = 32,
		Damage = 5,
		AttackSpeed = 5,
		ProjectileCount = 5,
		FanAngle = 90,
		Speed = 8,
		ProjectileModelName = "MidnightMagic",
		ProjectileModelRotation = "UNSUPPORTED",
		BurstTime = 2,
		BurstCount = 2
	},
	
	-- sounds
	["Sounds"] = {
		Death = "WizardDeath1",
		Attack = "MagicElectric",
		Spawn = "WizardLaugh1",
		Hurt = "WizardHurt1",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "MageCast"
	},
	
	-- difficulty
	["Difficulty"] = 20,
	
	-- preserve model reference
	model = script["Midnight Wizard"],
}