local _, addon = ...
local data = addon.data

local HBD = LibStub('HereBeDragons-2.0')
local sqrt = math.sqrt

local function GetDistanceSqToPoint(mapID, x, y)
	local playerX, playerY, playerMapID = HBD:GetPlayerZonePosition()
	return (HBD:GetZoneDistance(playerMapID, playerX, playerY, mapID, x, y))
end

local function GetQuestDistanceWithItem(questID, maxDistanceYd)
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
	if not questLogIndex then
		return
	end

	local itemLink, _, _, showWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
	if not itemLink then
		local fallbackItemID = data.questItems[questID]
		if fallbackItemID == 202247 then
			-- extra handling for technoscrying quests
			if C_UnitAuras.GetPlayerAuraBySpellID(409668) or C_UnitAuras.GetPlayerAuraBySpellID(414539) then
				fallbackItemID = nil
			end
		end
		if fallbackItemID then
			if type(fallbackItemID) == 'table' then
				for _, itemID in next, fallbackItemID do
					local link = addon:GetItemLinkFromID(itemID)
					if C_Item.GetItemCount(link) > 0 then
						itemLink = link
						break
					end
				end
			else
				itemLink = addon:GetItemLinkFromID(fallbackItemID)
			end
		end
	end

	if not itemLink then
		return
	end

	local itemID = GetItemInfoFromHyperlink(itemLink)
	if C_QuestLog.IsComplete(questID) then
		local completeItemZone = data.completeItems[itemID]
		if not showWhenComplete and not completeItemZone then
			return
		end

		if completeItemZone and type(completeItemZone) == 'number' then
			if HBD:GetPlayerZone() ~= completeItemZone then
				return
			end
		end

		local noCompleteItem = data.noCompleteItems[itemID]
		if noCompleteItem then
			if type(noCompleteItem) == 'number' then
				itemLink = addon:GetItemLinkFromID(noCompleteItem)
				itemID = noCompleteItem
			else
				return
			end
		end
	end

	if C_Item.GetItemCount(itemLink) == 0 then
		-- no point showing items we don't have
		return
	end

	if data.itemBlacklist[itemID] then
		-- don't show items we specifically want to ignore
		return
	end

	local distanceSq = C_QuestLog.GetDistanceSqToQuest(questID)
	 -- the square root of distanceSq is in yards, much easier to work with
	local distanceYd = distanceSq and sqrt(distanceSq)
	if distanceYd and distanceYd <= maxDistanceYd then
		return distanceYd, itemLink
	end

	local accurateQuestAreaData = data.accurateQuestAreas[questID]
	if accurateQuestAreaData then
		local distanceSqToPoint = GetDistanceSqToPoint(accurateQuestAreaData[1], accurateQuestAreaData[2], accurateQuestAreaData[3])
		if distanceSqToPoint then
			return sqrt(distanceSqToPoint), itemLink
		end
	end

	local questMapID = data.inaccurateQuestAreas[questID]
	if questMapID then
		if type(questMapID) == 'boolean' then
			return maxDistanceYd - 1, itemLink
		elseif type(questMapID) == 'number' then
			if questMapID == HBD:GetPlayerZone() then
				return maxDistanceYd - 2, itemLink
			end
		elseif type(questMapID) == 'table' then
			local playerMapID = HBD:GetPlayerZone()
			for _, mapID in next, questMapID do
				if mapID == playerMapID then
					return maxDistanceYd - 2, itemLink
				end
			end
		end
	end
end

local function IsQuestOnMapCurrentMap(questID)
	local isOnMap = C_QuestLog.IsOnMap(questID)
	if not isOnMap then
		local accurateQuestAreaInfo = data.accurateQuestAreas[questID]
		if accurateQuestAreaInfo then
			isOnMap = accurateQuestAreaInfo[1] == HBD:GetPlayerZone()
		end
	end

	if not isOnMap then
		local inaccurateQuestAreaInfo = data.inaccurateQuestAreas[questID]
		if inaccurateQuestAreaInfo then
			if type(inaccurateQuestAreaInfo) == 'boolean' then
				isOnMap = true
			elseif type(inaccurateQuestAreaInfo) == 'table' then
				local playerMapID = HBD:GetPlayerZone()
				for _, mapID in next, inaccurateQuestAreaInfo do
					if mapID == playerMapID then
						isOnMap = true
						break
					end
				end
			else
				isOnMap = inaccurateQuestAreaInfo == HBD:GetPlayerZone()
			end
		end
	end

	return isOnMap
end

local function sortByClosestDistance(a, b)
	return a[2] < b[2]
end

local function GetItemPriority(itemLink)
	local itemID = GetItemInfoFromHyperlink(itemLink or '') or -1
	return data.priorityItems[itemID]
end

local uniqueItems = {}
local prioritizedItemLinks = {}
local function addPrioritizedItem(questID, maxDistanceYd)
	local distance, itemLink = GetQuestDistanceWithItem(questID, maxDistanceYd)
	local priorityIndex = GetItemPriority(itemLink)
	if distance or priorityIndex then
		if not priorityIndex then
			priorityIndex = 0
		end

		if not prioritizedItemLinks[priorityIndex] then
			prioritizedItemLinks[priorityIndex] = {}
		end

		if not uniqueItems[itemLink] then
			table.insert(prioritizedItemLinks[priorityIndex], {itemLink, distance})
			uniqueItems[itemLink] = true
		end
	end
end

function addon:GetClosestQuestItem(maxDistanceYd, zoneOnly, trackingOnly)
	table.wipe(prioritizedItemLinks)
	table.wipe(uniqueItems)

	for index = 1, C_QuestLog.GetNumWorldQuestWatches() do
		-- this only tracks supertracked worldquests,
		-- e.g. stuff the player has shift-clicked on the map
		local questID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(index)
		if questID and (not zoneOnly or IsQuestOnMapCurrentMap(questID)) then
			addPrioritizedItem(questID, maxDistanceYd)
		end
	end

	for index = 1, C_QuestLog.GetNumQuestWatches() do
		local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(index)
		if questID and QuestHasPOIInfo(questID) and (not zoneOnly or IsQuestOnMapCurrentMap(questID)) then
			addPrioritizedItem(questID, maxDistanceYd)
		end
	end

	for index = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(index)
		if info and not info.isHeader and info.hasLocalPOI then
			local questID = info.questID
			if C_QuestLog.IsWorldQuest(questID) or info.questClassification == Enum.QuestClassification.BonusObjective or (trackingOnly and not info.isHidden) then
				if not zoneOnly or IsQuestOnMapCurrentMap(questID) then
					addPrioritizedItem(questID, maxDistanceYd)
				end
			end
		end
	end

	for _, items in next, prioritizedItemLinks do
		if #items > 0 then
			if #items > 1 then
				table.sort(items, sortByClosestDistance)
			end

			for _, itemInfo in next, items do
				return itemInfo[1]
			end
		end
	end
end
