return {
	-- behaviour type
	["BehaviorType"] = "Assassin",
	
	-- stats
	["MaxHealth"] = 300,
	["MovementSpeed"] = 18,
	
	["Attack"] = {
		Size = 6,
		Range = 6,
		Damage = 40,
		AttackSpeed = 1 / 2.5,
		TelegraphTime = 1
	},
	
	-- sounds
	["Sounds"] = {
		Death = "WizardDeath1",
		Attack = "MetalStab",
		Spawn = " ",
		Hurt = "WizardHurt1",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "AssassinAttack"
	},
	
	-- difficulty
	["Difficulty"] = 20,
	
	model = script["Rogue"],
}