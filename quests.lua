local _, ns = ...

-- Quests with incorrect or missing quest area blobs
ns.questAreas = {
	-- Global
	[24629] = true,

	-- Icecrown
	[14108] = 541,

	-- Northern Barrens
	[13998] = 11,

	-- Un'Goro Crater
	[24735] = 201,

	-- Darkmoon Island
	[29506] = 823,
	[29510] = 823,

	-- Mulgore
	[24440] = 9,
	[14491] = 9,
	[24456] = 9,
	[24524] = 9,

	-- Mount Hyjal
	[25577] = 606,
}

-- Quests items with incorrect or missing quest area blobs
ns.itemAreas = {
	-- Thousand Needles
	[56011] = 61,

	-- Tanaris
	[52715] = 161,

	-- The Jade Forest
	[84157] = 806,

	-- Hellfire Peninsula
	[28038] = 465,
	[28132] = 465,
}

-- Items that needs to be used on specific creatures
ns.creatureSpecific = {
	[25814] = 35401,
	[25758] = 35352,
	[25752] = 35352,
	[25753] = 35352,
}
