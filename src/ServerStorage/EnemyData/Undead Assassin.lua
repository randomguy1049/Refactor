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
		TelegraphTime = 0.6
	},
	
	-- sounds
	["Sounds"] = {
		Death = " ",
		Attack = "MetalStab",
		Spawn = " ",
		Hurt = " ",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "AssassinAttack"
	},
	
	-- difficulty
	["Difficulty"] = 30,
	
	model = script["Undead Assassin"],
}