weapons = {{label = 'Pistol', value = 'WEAPON_PISTOL', cost = 400},
		   {label = 'Combat Pistol', value = 'WEAPON_COMBATPISTOL', cost = 700},
		   {label = 'Pump Shotgun', value = 'WEAPON_PUMPSHOTGUN', cost = 950}, 
		   {label = 'Carbine Rifle', value = 'WEAPON_CARBINERIFLE', cost = 1200},
		   {label = 'Weapon Flashlight', value = 'flashlight', cost = 300},
		   {label = 'Weapon Grip', value = 'grip', cost = 400}
		}

equip = 
{
	{label = 'Taser', value = 'WEAPON_STUNGUN', cost = 90},
	{label = 'Body Armor', value = 'armor', cost = 100},
	{label = 'Nightstick', value = 'WEAPON_NIGHTSTICK', cost = 60},
	{label = "Radio", value = 'radio', cost = 80},
	{label = 'Flashlight', value = 'WEAPON_FLASHLIGHT', cost = 100},
	{label = 'Flare', value = 'WEAPON_FLARE', cost = 15},
	{label = 'Flaregun', value = 'WEAPON_FLAREGUN', cost = 50},
	{label = 'Jerry Can', value = 'WEAPON_PETROLCAN', cost = 20},
	{label = 'Fire Extinguisher', value = 'WEAPON_FIREXTINGUISHER', cost = 35},
	{label = 'Breathalyzer', value = 'breathalyzer', cost = 25},
	{label = 'Scuba Tank', value = 'scubatank', cost = 200},
	{label = 'Rebreather', value = 'rebreather', cost = 100},
	{label = 'Parachute', value = 'GADGET_PARACHUTE', cost = 50}
}

medSupplies = {{label = 'Bandages', value = 'bandage', cost = 10},
			   {label = 'Med-Kit', value = 'medikit', cost = 30},
			   {label = 'Defibrillator', value = 'defib', cost = 100}}

pdVehicles = 
{
	{label = 'Charger', value = 'lspd2', extras = {1, 1, 0, 0, 1, 0, 0, 1, 0, 0}},
	{label = 'Charger Supervisor', value = 'lspd2', extras = {1, 1, 0, 0, 1, 0, 0, 1, 1, 0}},
	{label = 'Explorer', value = 'lspd3', extras = {1, 1, 0, 0, 1, 0, 0, 1, 0, 0}},
	{label = 'Explorer Supervisor', value = 'lspd3', extras = {1, 1, 0, 1, 1, 0, 0, 1, 1, 0}},
	{label = 'Taurus', value = 'lspd5', extras = {0, 0, 0, 1, 1, 0, 0, 0, 0, 1}},
	{label = 'Taurus Supervisor', value = 'lspd5', extras = {0, 0, 0, 1, 1, 0, 0, 0, 1, 0}},
	{label = 'Ghost Charger', value = 'lspdg2', extras = {1, 1, 0, 0, 1, 0, 0, 1, 1, 0}},
	{label = 'Unmarked Tahoe', value = 'lspdg1', extras = {1, 1, 0, 0, 1, 1, 0, 1, 1, 1}},
	{label = 'HP Charger', value = '2018charger', extras = {0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1}},
	{label = 'HP Charger Slicktop', value = '2018chargers', extras = {0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1}},
	{label = 'HP CVPI', value = '2011cvpi', extras = {0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1}},
	{label = 'HP CVPI Slicktop', value = '2011cvpis', extras = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}},
	{label = 'Vic', value = 'police', extras = nil},
	{label = 'Cruiser', value = 'police2', extras = nil},
	{label = 'Cruiser 2', value = 'police3', extras = nil},
	{label = 'Unmarked Vic', value = 'police4', extras = nil},
	{label = "Bike", value = 'policeb', extras = nil},
	{label = 'SWAT Bearcat', value = 'riot', extras = nil},
	{label = "Mustang", value = '2015polstang', extras = nil}
}

pdObjects = {{label = 'Spike Strip', value = 'p_ld_stinger_s'},
			 {label = 'Traffic cone', value = 'prop_roadcone02a'},
			 {label = 'Barrier', value = 'prop_barrier_work05'}}

uniforms = {{tshirt_1 = 15, tshirt_2 = 0, torso_1 = 93, torso_2 = 0, decals_1 = 0, decals_2 = 0, arms = 0, pants_1 = 22, pants_2 = 0, shoes_1 = 25, shoes_2 = 0, chain_1 = 0, chain_2 = 0, helmet_1 = 10, helmet_2 = 6}, --Cadet
			{tshirt_1 = 122, tshirt_2 = 0, torso_1 = 18, torso_2 = 0, decals_1 = 0, decals_2 = 0, arms = 30, pants_1 = 10, pants_2 = 3, shoes_1 = 51, shoes_2 = 0, chain_1 = 0, chain_2 = 0, helmet_1 = -1, helmet_2 = 0}, --Officer
			{tshirt_1 = 122, tshirt_2 = 0, torso_1 = 29, torso_2 = 0, decals_1 = 8, decals_2 = 0, arms = 30, pants_1 = 10, pants_2 = 3, shoes_1 = 51, shoes_2 = 0, chain_1 = 0, chain_2 = 0, helmet_1 = -1, helmet_2 = 0}, --Corporal
			{tshirt_1 = 122, tshirt_2 = 0, torso_1 = 29, torso_2 = 0, decals_1 = 11, decals_2 = 0, arms = 30, pants_1 = 10, pants_2 = 3, shoes_1 = 51, shoes_2 = 0, chain_1 = 0, chain_2 = 0, helmet_1 = -1, helmet_2 = 0}, --Sergant
			{tshirt_1 = 122, tshirt_2 = 0, torso_1 = 29, torso_2 = 2, decals_1 = 0, decals_2 = 0, arms = 30, pants_1 = 10, pants_2 = 3, shoes_1 = 51, shoes_2 = 0, chain_1 = 0, chain_2 = 0, helmet_1 = -1, helmet_2 = 0}, --Lieutenant
			{tshirt_1 = 122, tshirt_2 = 0, torso_1 = 29, torso_2 = 3, decals_1 = 0, decals_2 = 0, arms = 30, pants_1 = 10, pants_2 = 3, shoes_1 = 51, shoes_2 = 0, chain_1 = 0, chain_2 = 0, helmet_1 = -1, helmet_2 = 0}, --Major
			{tshirt_1 = 122, tshirt_2 = 0, torso_1 = 29, torso_2 = 3, decals_1 = 11, decals_2 = 0, arms = 30, pants_1 = 10, pants_2 = 3, shoes_1 = 51, shoes_2 = 0, chain_1 = 0, chain_2 = 0, helmet_1 = -1, helmet_2 = 0}, --Captain
			{tshirt_1 = 122, tshirt_2 = 0, torso_1 = 52, torso_2 = 3, decals_1 = 0, decals_2 = 0, arms = 30, pants_1 = 10, pants_2 = 3, shoes_1 = 51, shoes_2 = 0, chain_1 = 0, chain_2 = 0, helmet_1 = -1, helmet_2 = 0}, -- Deputy Chief
			{tshirt_1 = 122, tshirt_2 = 0, torso_1 = 52, torso_2 = 3, decals_1 = 0, decals_2 = 0, arms = 30, pants_1 = 10, pants_2 = 3, shoes_1 = 51, shoes_2 = 0, chain_1 = 0, chain_2 = 0, helmet_1 = -1, helmet_2 = 0}} --Chief

uniformsF = {{tshirt_1 = 3, torso_1 = 48, arms = 14, pants_1 = 23, pants_2 = 10, shoes_1 = 9}, --Cadet
			{tshirt_1 = 3, torso_1 = 48, arms = 14, pants_1 = 23, pants_2 = 10, shoes_1 = 9}}

dutyToggle =
{
	{x = 457.2861, y = -992.8768, z = 30.6893}
}