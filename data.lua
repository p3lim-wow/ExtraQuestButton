local data = {}

data.itemBlacklist = {
	-- sometimes Blizzard does what I want to do, let them handle it
	[113191] = true,
	[110799] = true,
	[109164] = true,
	[191729] = true,
}

-- items that should be used on specific mobs (npcID = itemID)
-- these have high priority during collision
data.targetItems = {
	[9999] = 11804, -- Un'Goro Crater
	[25321] = 34711, -- Borean Tundra
	[25322] = 34711, -- Borean Tundra
	[25752] = 35352, -- Borean Tundra
	[25753] = 35352, -- Borean Tundra
	[25758] = 35352, -- Borean Tundra
	[25814] = 35401, -- Borean Tundra
	[26811] = 36859, -- Grizzly Hills
	[26812] = 36859, -- Grizzly Hills
	[26841] = 37887, -- Dragonblight
	[27122] = 37887, -- Dragonblight
	[27808] = 37887, -- Dragonblight
	[28750] = 39157, -- Zul'Drak
	[28802] = 39206, -- Zul'Drak
	[28843] = 39238, -- Zul'Drak
	[28931] = 39664, -- Zul'Drak
	[29747] = 41265, -- Icecrown
	[34925] = 46954, -- Icecrown
	[35092] = 46954, -- Icecrown
	[36845] = 49647, -- Mulgore
	[36922] = 49679, -- Azshara
	[42681] = 58167, -- Deepholm
	[42682] = 58167, -- Deepholm
	[43814] = 60206, -- Duskwood
	[43923] = 60225, -- Duskwood
	[44218] = 60490, -- Deepholm
	[44262] = 60503, -- Loch Modan
	[48136] = 63426, -- Hillsbrad Foothills
	[48269] = 63508, -- Hillsbrad Foothills
	[48741] = 64445, -- Hillsbrad Foothills
	[48742] = 64445, -- Hillsbrad Foothills
	[81183] = 115475, -- Spires of Arak
	[141501] = 162450, -- Zuldazar
	[158532] = 172950, -- Ardenweald
	[166958] = 183689, -- Icecrown
	[166959] = 183689, -- Icecrown
	[167395] = 172020, -- Maldraxxus
	[169206] = 179921, -- Ardenweald
	[171211] = 180613, -- Bastion
	[175857] = 186199, -- Night Fae Assault in Maw
	[176131] = 186199, -- Night Fae Assault in Maw
	[178693] = 186097, -- Night Fae Assault in Maw
	[178704] = 186097, -- Night Fae Assault in Maw
	[178786] = 186199, -- Night Fae Assault in Maw
	[178855] = 186199, -- Night Fae Assault in Maw
	[178859] = 186199, -- Night Fae Assault in Maw
	[178878] = 186199, -- Night Fae Assault in Maw
	[179217] = 186199, -- Night Fae Assault in Maw
	[226580] = 219322, -- Azj-Kahet
}

-- items that should be used for a quest but aren't (questID = itemID)
-- these have low priority during collision
data.questItems = {
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
	[12007] = 35797, -- Grizzly Hills
	[12066] = 36751, -- Dragonblight
	[12026] = 35739, -- Grizzly Hills
	[12415] = 37716, -- Grizzly Hills
	[12456] = 37881, -- Dragonblight
	[12470] = 37923, -- Dragonblight
	[12484] = 38149, -- Grizzly Hills
	[12661] = 41390, -- Zul'Drak
	[12713] = 38699, -- Zul'Drak
	[12861] = 41161, -- Zul'Drak
	[12925] = 41612, -- Storm Peaks
	[13343] = 44450, -- Dragonblight
	[13425] = 41612, -- Storm Peaks
	[13542] = 44868, -- Darkshore
	[13890] = 46365, -- Ashenvale
	[26868] = 60681, -- Loch Modan
	[27384] = 12888, -- Eastern Plaguelands
	[28317] = 63357, -- Burning Steppes
	[28318] = 63357, -- Burning Steppes
	[28319] = 63357, -- Burning Steppes
	[28450] = 63357, -- Burning Steppes
	[28451] = 63357, -- Burning Steppes
	[28452] = 63357, -- Burning Steppes
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
	[53476] = 163852, -- Zandalar/Kul Tiras
	[58586] = 174465, -- Venthyr Covenant
	[59063] = 175137, -- Night Fae Covenant
	[59809] = 177904, -- Night Fae Covenant
	[60188] = 178464, -- Night Fae Covenant
	[60609] = {180008, 180009}, -- Ardenweald
	[60649] = 180170, -- Ardenweald
	[61708] = 174043, -- Maldraxxus, untested
	[63892] = 185963, -- Korthia
	[12022] = 169219, -- Brewfest
	[12191] = 169219, -- Brewfest
	[66439] = 192545, -- The Waking Shores
	[77891] = 209017, -- Emerald Dream
	[77483] = 202247, -- Technoscrying
	[77484] = 202247, -- Technoscrying
	[77434] = 202247, -- Technoscrying
	[78931] = 202247, -- Technoscrying
	[78820] = 202247, -- Technoscrying
	[78616] = 202247, -- Technoscrying
	[78755] = 211483, -- Khaz Algar
	[79960] = 216664, -- Azj-Kahet
	[84672] = {229824, 229825, 229805}, -- Undermine
}

-- quests that doesn't have a defined area on the map (questID = bool/mapID/{mapID,...})
-- these have low priority during collision
data.inaccurateQuestAreas = {
	[11731] = {84, 87, 103}, -- alliance capitals (missing Darnassus)
	[11921] = {84, 87, 103}, -- alliance capitals (missing Darnassus)
	[11922] = {18, 85, 88, 110}, -- horde capitals
	[11926] = {18, 85, 88, 110}, -- horde capitals
	[12779] = 124, -- Scarlet Enclave (Death Knight starting zone)
	[13798] = 63, -- Ashenvale
	[13875] = 63, -- Ashenvale
	[13998] = 11, -- Northern Barrens
	[14246] = 66, -- Desolace
	[24440] = 7, -- Mulgore
	[24456] = 7, -- Mulgore
	[24524] = 7, -- Mulgore
	[24629] = {84, 85, 87, 88, 103, 110}, -- major capitals (missing Darnassus & Undercity)
	[25577] = 198, -- Mount Hyjal
	[25798] = 64, -- Thousand Needles (TODO: test if we need to associate the item with the zone instead)
	[25799] = 64, -- Thousand Needles (TODO: test if we need to associate the item with the zone instead)
	[29506] = 407, -- Darkmoon Island
	[29510] = 407, -- Darkmoon Island
	[29515] = 407, -- Darkmoon Island
	[29516] = 407, -- Darkmoon Island
	[29517] = 407, -- Darkmoon Island
	[34461] = 590, -- Horde Garrison
	[34587] = 582, -- Alliance Garrison
	[49813] = true, -- anywhere
	[49846] = true, -- anywhere
	[49860] = true, -- anywhere
	[49864] = true, -- anywhere
	[53476] = true,
	[59809] = true,
	[63892] = {1961, 2006, 2007}, -- Korthia and sub-zones
	[75923] = 2023, -- Ohn'ahran Plains
	[66439] = 2022, -- The Waking Shores
	[77891] = 2200, -- Emerald Dream
	[78068] = true, -- anywhere
	[78070] = true, -- anywhere
	[78075] = true, -- anywhere
	[78081] = true, -- anywhere
	[79960] = 2255,
	[13103] = 125, -- Dalaran (Northrend)
	[13115] = 125, -- Dalaran (Northrend)
	[13107] = 125, -- Dalaran (Northrend)
	[13116] = 125, -- Dalaran (Northrend)
	[13114] = {125, 127}, -- Crystalsong Forest
	[13102] = {125, 127}, -- Crystalsong Forest
	[86603] = 2371, -- K'aresh
	[89056] = 2371, -- K'aresh
}

-- same as above, just accurate (questID = {mapID, x, y})
-- TODO: replace the above with this one wherever we can
data.accurateQuestAreas = {
	[12484] = {116, 0.1683, 0.4834}, -- Grizzly Hills
	[27389] = {23, 0.3596, 0.4573}, -- Eastern Plaguelands
	[27451] = {23, 0.5526, 0.6225}, -- Eastern Plaguelands
	[35001] = {542, 0.6681, 0.4553}, -- Spires of Arak
	[57455] = {1565, 0.3075, 0.3568}, -- Ardenweald
	[63971] = {1543, 0.2308, 0.3729}, -- The Maw
	[82266] = {2213, 0.3081, 0.3343}, -- City of Threads, Azj-Kahet
}

-- items that needs to be shown even after the quest is complete but aren't (itemID = bool/mapID)
-- these have low priority during collision
data.completeItems = {
	[35797] = 116, -- Grizzly Hills
	[41058] = 120, -- Storm Peaks
	[52853] = true, -- Mount Hyjal
	[57412] = 205, -- Shimmering Expanse
	[60273] = 50, -- Northern Stranglethorn Vale
	[62508] = 241, -- Twilight Highlands
	[63357] = 36, -- Burning Steppes
	[64660] = 241, -- Twilight Highlands
	[177904] = true,
}

-- items that are shown after quest is complete but shouldn't (itemID = bool/itemID)
-- optionally the value can be the replacement item ID
data.noCompleteItems = {
	[23680] = 60273, -- Northern Stranglethorn Vale
}

-- items that should have priority in an area where there are multiple quest items
data.priorityItems = {
	[46316] = -10, -- Orc-Hair Braid, Ashenvale
	[63508] = 1, -- Helcular's Rod, Hillsbrad Foothills
	[64471] = 1, -- Goblin Pocket-Nuke, Hillsbrad Foothills
	[64583] = 2, -- Water Barrel, Hillsbrad Foothills
	[232466] = -10, -- Leave the Storm, Siren Isle
	[228988] = 1, -- Rock Reviver, Siren Isle
}

local _, addon = ...
addon.data = data
