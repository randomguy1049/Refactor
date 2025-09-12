return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 550,
	["MovementSpeed"] = 16,
	
	["Attack"] = {
		Size = 4.5,
		Range = 8,
		Damage = 50,
		AttackSpeed = 0.5,
		TelegraphTime = 0.35
	},
	
	-- sounds
	["Sounds"] = {
		Death = "StoneCrumble",
		Attack = "StoneSlamSmall",
		Spawn = "",
		Hurt = "",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "HeavyPunch"
	},
	
	-- difficulty
	["Difficulty"] = -1,
	
	-- special properties
	["CombatSeconds"] = 1.5,
	
	-- preserve model reference
	model = script["Corrupted Guardian"],
}