return {
	-- behaviour type
	["BehaviorType"] = "EvadeProjectile",
	
	-- stats
	["MaxHealth"] = 80,
	["MovementSpeed"] = 6,
	
	["Attack"] = {
		Range = 32,
		Damage = 5,
		AttackSpeed = 14,
		Speed = 10,
		ProjectileModelName = "YellowMagic",
		ProjectileModelRotation = "UNSUPPORTED"
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
	["Difficulty"] = 7,
	
	-- special properties
	["AttackRestTime"] = 0.8,
	
	model = script["Yellow Wizard"],
}