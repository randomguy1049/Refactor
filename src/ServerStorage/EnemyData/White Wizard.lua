return {
	-- behaviour type
	["BehaviorType"] = "Summoner",
	
	-- stats
	["MaxHealth"] = 800,
	["MovementSpeed"] = 16,
	
	-- sounds
	["Sounds"] = {
		Death = "WizardDeath1",
		Attack = "MonsterAttackBig",
		Spawn = "WizardLaugh1",
		Hurt = "WizardHurt1",
	},
	
	-- animations
	["_Animations"] = {
		Attack = "CommanderTenHut"
	},
	
	-- difficulty
	["Difficulty"] = 25,
	
	-- special properties
	["SummonTime"] = 1,
	["SummonRestTime"] = 10,
	["SummonAnimation"] = "CommanderTenHut",
	["SummonNames"] = "Purple Wizard:7,Yellow Wizard:5,Red Wizard:3,Midnight Wizard:1,",
	
	model = script["White Wizard"],
}