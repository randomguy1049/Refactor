return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 130,
	["MovementSpeed"] = 12,
	
	["Attack"] = {
		Range = 32,
		Damage = 2.5,
		AttackSpeed = 9,
		ProjectileCount = 18,
		FanAngle = 360,
		Speed = 10,
		ProjectileModelName = "BlueMagic",
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
	["Difficulty"] = 18,
	
	-- special properties
	["AttackEffect"] = "Slow",
	
	-- preserve model reference
	model = script["Blue Wizard"],
}