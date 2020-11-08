local _, ns = ...
ns.itemData = {}

-- Warlords of Draenor intro quest items which inspired this addon (itemID = bool)
-- just let the ExtraActionBar handle these
ns.itemData.itemBlacklist = {
	[113191] = true,
	[110799] = true,
	[109164] = true,
}

-- items that should be used on specific mobs (npcID = itemID)
-- these have high priority during collision
ns.itemData.targetItems = {
	[9999] = 11804, -- Un'Goro Crater
	[26811] = 36859, -- Grizzly Hills
	[26812] = 36859, -- Grizzly Hills
	[34925] = 46954, -- Icecrown
	[35092] = 46954, -- Icecrown
	[36845] = 49647, -- Mulgore
	[169206] = 179921, -- Ardenwald
	[42681] = 58167, -- Deepholm
	[42682] = 58167, -- Deepholm
	[44218] = 60490, -- Deepholm
	[25753] = 35352, -- Borean Tundra
	[25752] = 35352, -- Borean Tundra
	[25758] = 35352, -- Borean Tundra
	[25814] = 35401, -- Borean Tundra
	[25321] = 34711, -- Borean Tundra
	[25322] = 34711, -- Borean Tundra
	[26841] = 37887, -- Dragonblight
	[27122] = 37887, -- Dragonblight
	[27808] = 37887, -- Dragonblight
	[28750] = 39157, -- Zul'Drak
	[28843] = 39238, -- Zul'Drak
	[28802] = 39206, -- Zul'Drak
	[28931] = 39664, -- Zul'Drak
	[29747] = 41265, -- Icecrown
	[141501] = 162450, -- Zuldazar
	[43923] = 60225, -- Duskwood
	[43814] = 60206, -- Duskwood
	[48269] = 63508, -- Hillsbrad Foothills
	[48136] = 63426, -- Hillsbrad Foothills
	[48741] = 64445, -- Hillsbrad Foothills
	[48742] = 64445, -- Hillsbrad Foothills
	[81183] = 115475, -- Spires of Arak
}

-- items that should be used for a quest but aren't (questID = itemID)
-- these have low priority during collision
ns.itemData.questItems = {
	-- (TODO: test if we need to associate any of these items with a zone directly instead)
	[10129] = 28038, -- Hellfire Peninsula
	[10146] = 28038, -- Hellfire Peninsula
	[10162] = 28132, -- Hellfire Peninsula
	[10163] = 28132, -- Hellfire Peninsula
	[10346] = 28132, -- Hellfire Peninsula
	[10347] = 28132, -- Hellfire Peninsula
	[11617] = 34772, -- Borean Tundra
	[11633] = 34782, -- Borean Tundra
	[11894] = 35288, -- Borean Tundra
	[11982] = 35734, -- Grizzly Hills
	[11986] = 35739, -- Grizzly Hills
	[11989] = 38083, -- Grizzly Hills
	[12026] = 35739, -- Grizzly Hills
	[12415] = 37716, -- Grizzly Hills
	[12007] = 35797, -- Grizzly Hills
	[12456] = 37881, -- Dragonblight
	[12470] = 37923, -- Dragonblight
	[12484] = 38149, -- Grizzly Hills
	[12661] = 41390, -- Zul'Drak
	[12713] = 38699, -- Zul'Drak
	[12861] = 41161, -- Zul'Drak
	[13343] = 44450, -- Dragonblight
	[29821] = 84157, -- Jade Forest
	[31112] = 84157, -- Jade Forest
	[31769] = 89769, -- Jade Forest
	[35237] = 11891, -- Ashenvale
	[36848] = 36851, -- Grizzly Hills
	[37565] = 118330, -- Azsuna
	[39385] = 128287, -- Stormheim
	[39847] = 129047, -- Dalaran (Broken Isles)
	[40003] = 129161, -- Stormheim
	[40965] = 133882, -- Suramar
	[43827] = 129161, -- Stormheim
	[49402] = 154878, -- Tiragarde Sound
	[50164] = 154878, -- Tiragarde Sound
	[51646] = 154878, -- Tiragarde Sound
}

-- quests that doesn't have a defined area on the map (questID = bool/mapID/{mapID,...})
-- these have low priority during collision
ns.itemData.inaccurateQuestAreas = {
	[11731] = {84, 87, 103}, -- alliance capitals (missing Darnassus)
	[11921] = {84, 87, 103}, -- alliance capitals (missing Darnassus)
	[11922] = {18, 85, 88, 110}, -- horde capitals
	[11926] = {18, 85, 88, 110}, -- horde capitals
	[12779] = 124, -- Scarlet Enclave (Death Knight starting zone)
	[13998] = 11, -- Northern Barrens
	[14246] = 66, -- Desolace
	[24440] = 7, -- Mulgore
	[24456] = 7, -- Mulgore
	[24524] = 7, -- Mulgore
	[24629] = {84, 85, 87, 88, 103, 110}, -- major capitals (missing Darnassus & Undercity)
	[25577] = 198, -- Mount Hyjal
	[29506] = 407, -- Darkmoon Island
	[29510] = 407, -- Darkmoon Island
	[29515] = 407, -- Darkmoon Island
	[29516] = 407, -- Darkmoon Island
	[29517] = 407, -- Darkmoon Island
	[49813] = true, -- anywhere
	[49846] = true, -- anywhere
	[49860] = true, -- anywhere
	[49864] = true, -- anywhere
	[25798] = 64, -- Thousand Needles (TODO: test if we need to associate the item with the zone instead)
	[25799] = 64, -- Thousand Needles (TODO: test if we need to associate the item with the zone instead)
	[34461] = 590, -- Horde Garrison
}

-- same as above, just accurate (questID = {mapID, x, y})
-- TODO: replace the above with this one wherever we can
ns.itemData.accurateQuestAreas = {
	[12484] = {116, 0.1683, 0.4834}, -- Grizzly Hills
	[35001] = {542, 0.6681, 0.4553}, -- Spires of Arak
}

-- items that needs to be shown even after the quest is complete but aren't (itemID = bool/mapID)
-- these have low priority during collision
ns.itemData.completeItems = {
	[35797] = 116, -- Grizzly Hills
	[60273] = 50, -- Northern Stranglethorn Vale
	[52853] = true, -- Mount Hyjal
}

-- items that are shown after quest is complete but shouldn't (itemID = bool/itemID)
-- optionally the value can be the replacement item ID
ns.itemData.noCompleteItems = {
	[23680] = 60273, -- Northern Stranglethorn Vale
}
