return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 130,
	["MovementSpeed"] = 12,
	
	["Attack"] = {
		Range = 32,
		Damage = 20,
		AttackSpeed = 4.5,
		Speed = 20,
		ProjectileCount = 3,
		FanAngle = 30,
		ProjectileModelName = "RedMagic",
		ProjectileModelRotation = "UNSUPPORTED"
	},
	
	-- sounds
	["Sounds"] = {
		Death = "WizardDeath1",
		Attack = "MagicPowerful",
		Spawn = "WizardLaugh1",
		Hurt = "WizardHurt1",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "MageCast"
	},
	
	-- difficulty
	["Difficulty"] = 11,
	
	model = script["Red Wizard"],
}