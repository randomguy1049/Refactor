return {
	-- behaviour type
	["BehaviorType"] = "ChaseMelee",
	
	-- stats
	["MaxHealth"] = 550,
	["MovementSpeed"] = 16,
	
	["Attack"] = {
		Size = 8,
		Range = 8,
		Damage = 50,
		AttackSpeed = 1,
		TelegraphTime = 1
	},
	
	-- sounds
	["Sounds"] = {
		Death = "StoneCrumble",
		Attack = "StoneSlamLarge",
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
	["CombatSeconds"] = 4.5,
	
	-- preserve model reference
	model = script["Corrupted Protector"],
}