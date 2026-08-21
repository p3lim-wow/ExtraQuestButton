local _, addon = ...

local data = addon.data
local HBD = LibStub('HereBeDragons-2.0')
local sqrt = math.sqrt

local questItemsByPriority = {}
local processedQuests = {}

local function getQuestDistance(questID, maxDistanceYd, mapID, x, y)
	local distanceSq = C_QuestLog.GetDistanceSqToQuest(questID)
	if distanceSq then
		local distanceYd = sqrt(distanceSq)
		if distanceYd <= maxDistanceYd then
			return distanceYd
		end
	end

	local area = data.accurateQuestAreas[questID]
	if area then
		local distanceSqToPoint = HBD:GetZoneDistance(mapID, x, y, area[1], area[2], area[3])
		if distanceSqToPoint then
			return sqrt(distanceSqToPoint)
		end
	end

	area = data.inaccurateQuestAreas[questID]
	if area then
		local areaType = type(area)
		if areaType == 'boolean' then
			return maxDistanceYd - 1
		elseif areaType == 'number' then
			if area == mapID then
				return maxDistanceYd - 2
			end
		elseif areaType == 'table' then
			for _, questAreaMapID in next, area do
				if questAreaMapID == mapID then
					return maxDistanceYd - 2
				end
			end
		end
	end
end

local function isQuestOnCurrentMap(questID, mapID)
	if C_QuestLog.IsOnMap(questID) then
		return true
	end

	local area = data.accurateQuestAreas[questID]
	if area and area[1] == mapID then
		return true
	end

	area = data.inaccurateQuestAreas[questID]
	if area then
		local areaType = type(area)
		if areaType == 'boolean' then
			return true
		elseif areaType == 'number' then
			return area == mapID
		elseif areaType == 'table' then
			for _, questAreaMapID in next, area do
				if questAreaMapID == mapID then
					return true
				end
			end
		end
	end

	return false
end

local function getValidQuestItem(questID, mapID, itemLink, itemID)
	local showWhenComplete, _
	if not itemLink then
		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
		if not questLogIndex then
			return
		end

		itemLink, _, _, showWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
		if not itemLink then
			return
		end

		itemID = GetItemInfoFromHyperlink(itemLink)
	end

	if C_QuestLog.IsComplete(questID) then
		local noCompleteItem = data.noCompleteItems[itemID]
		if noCompleteItem then
			if type(noCompleteItem) ~= 'number' then
				return
			end

			itemID = noCompleteItem
			itemLink = addon:GetItemLinkFromID(itemID)
		end

		local completeItem = data.completeItems[itemID]
		if not showWhenComplete and not completeItem then
			return
		end

		if type(completeItem) == 'number' and completeItem ~= mapID then
			return
		end
	end

	if C_Item.GetItemCount(itemLink) == 0 then
		return
	end

	if data.itemBlacklist[itemID] then
		return
	end

	return itemLink, itemID
end

local function processQuestItem(questID, distance, mapID, ...)
	local itemLink, itemID = getValidQuestItem(questID, mapID, ...)
	if not itemLink then
		return
	end

	local priority = data.priorityItems[itemID]
	if not distance and priority == nil then
		return
	end

	if not priority then
		priority = 0
	end

	local current = questItemsByPriority[priority]
	if not current then
		questItemsByPriority[priority] = {
			itemLink,
			distance,
		}
	elseif distance and (not current[2] or distance < current[2]) then
		current[1] = itemLink
		current[2] = distance
	end
end

local function processQuestItemsFromData(questID, distance, mapID)
	local dataItem = data.questItems[questID]
	if not dataItem then
		return
	end

	if dataItem == 202247 and not C_Secrets.ShouldAurasBeSecret() then
		-- special handling for technoscrying quests
		if C_UnitAuras.GetPlayerAuraBySpellID(409668) or C_UnitAuras.GetPlayerAuraBySpellID(414539) then
			return
		end
	end

	if type(dataItem) == 'table' then
		for _, itemID in next, dataItem do
			local itemLink = addon:GetItemLinkFromID(itemID)
			if itemLink then
				processQuestItem(questID, distance, mapID, itemLink, itemID)
			end
		end
	elseif dataItem then
		local itemLink = addon:GetItemLinkFromID(dataItem)
		if itemLink then
			processQuestItem(questID, distance, mapID, itemLink, dataItem)
		end
	end
end

local function processQuest(questID, maxDistanceYd, zoneOnly, mapID, x, y)
	if not questID then
		return
	end

	if processedQuests[questID] then
		return
	end

	processedQuests[questID] = true

	if zoneOnly and not isQuestOnCurrentMap(questID, mapID) then
		return
	end

	local distance = getQuestDistance(questID, maxDistanceYd, mapID, x, y)
	processQuestItem(questID, distance, mapID)
	processQuestItemsFromData(questID, distance, mapID)
end

function addon:GetClosestQuestItem(maxDistanceYd, zoneOnly, trackingOnly)
	table.wipe(processedQuests)
	table.wipe(questItemsByPriority)

	-- query player position once and pass it through to avoid querying it for every quest
	local mapID = HBD:GetPlayerZone()
	local x, y = HBD:GetPlayerZonePosition()

	-- process supertracked quests
	for index = 1, C_QuestLog.GetNumWorldQuestWatches() do
		local questID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(index)
		processQuest(questID, maxDistanceYd, zoneOnly, mapID, x, y)
	end

	-- process tracked quests
	for index = 1, C_QuestLog.GetNumQuestWatches() do
		local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(index)
		if questID and QuestHasPOIInfo(questID) then
			processQuest(questID, maxDistanceYd, zoneOnly, mapID, x, y)
		end
	end

	-- process world quests / bonus objectives / quest log
	for index = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(index)
		if info and not info.isHeader and info.hasLocalPOI then
			local questID = info.questID
			if
				C_QuestLog.IsWorldQuest(questID) or
				info.questClassification == Enum.QuestClassification.BonusObjective or
				(trackingOnly and not info.isHidden)
			then
				processQuest(questID, maxDistanceYd, zoneOnly, mapID, x, y)
			end
		end
	end

	-- after processing all quests find the highest prioritized quest item, if any
	local highestPriority
	local questItem

	for priority, info in next, questItemsByPriority do
		if not highestPriority or priority > highestPriority then
			highestPriority = priority
			questItem = info[1]
		end
	end

	return questItem
end
