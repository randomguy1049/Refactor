return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 350,
	["MovementSpeed"] = 6,
	
	["Attack"] = {
		Size = 16,
		Range = 6,
		Damage = 70,
		AttackSpeed = 5,
		TelegraphTime = 2
	},
	
	-- sounds
	["Sounds"] = {
		Death = "RockDeath",
		Attack = "RockAttack",
		Spawn = "Silence",
		Hurt = "Silence",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "HeavyPunch"
	},
	
	-- difficulty
	["Difficulty"] = 8,
	
	-- special properties
	["AttackType"] = "Targeted",
	
	-- preserve model reference
	model = script["Golem"],
}