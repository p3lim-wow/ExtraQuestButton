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
		if fallbackItemID then
			if type(fallbackItemID) == 'table' then
				for _, itemID in next, fallbackItemID do
					local link = addon:GetItemLinkFromID(itemID)
					if GetItemCount(link) > 0 then
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

	if GetItemCount(itemLink) == 0 then
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

local function IsItemPrioritized(itemLink)
	local itemID = GetItemInfoFromHyperlink(itemLink or '') or -1
	return data.priorityItems[itemID]
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

local function sortPrioritizedItemLinks(a, b)
	return a[2] > b[2]
end

local prioritizedItemLinks = {}
-- adaptation of QuestSuperTracking_ChooseClosestQuest for quests with items
function addon:GetClosestQuestItem(maxDistanceYd, zoneOnly, trackingOnly)
	local closestQuestItemLink
	local closestDistance = maxDistanceYd -- yards

	local hasPrioritizedItem = false
	for index = 1, C_QuestLog.GetNumWorldQuestWatches() do
		-- this only tracks supertracked worldquests,
		-- e.g. stuff the player has shift-clicked on the map
		local questID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(index)
		if questID and (not zoneOnly or IsQuestOnMapCurrentMap(questID)) then
			local distance, itemLink = GetQuestDistanceWithItem(questID, maxDistanceYd)
			local priorityIndex = IsItemPrioritized(itemLink)
			if priorityIndex then
				if not hasPrioritizedItem then
					table.wipe(prioritizedItemLinks)
					hasPrioritizedItem = true
				end
				table.insert(prioritizedItemLinks, {itemLink, priorityIndex})
			elseif distance and distance <= closestDistance then
				closestDistance = distance
				closestQuestItemLink = itemLink
			end
		end
	end

	if not closestQuestItemLink then
		for index = 1, C_QuestLog.GetNumQuestWatches() do
			local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(index)
			if questID and QuestHasPOIInfo(questID) and (not zoneOnly or IsQuestOnMapCurrentMap(questID)) then
				local distance, itemLink = GetQuestDistanceWithItem(questID, maxDistanceYd)
				local priorityIndex = IsItemPrioritized(itemLink)
				if priorityIndex then
					if not hasPrioritizedItem then
						table.wipe(prioritizedItemLinks)
						hasPrioritizedItem = true
					end
					table.insert(prioritizedItemLinks, {itemLink, priorityIndex})
				elseif distance and distance <= closestDistance then
					closestDistance = distance
					closestQuestItemLink = itemLink
				end
			end
		end
	end

	if not closestQuestItemLink then
		for index = 1, C_QuestLog.GetNumQuestLogEntries() do
			local info = C_QuestLog.GetInfo(index)
			if info and not info.isHeader and QuestHasPOIInfo(info.questID) then
				local questID = info.questID
				-- world quests are always considered
				if not (trackingOnly or info.isHidden) or C_QuestLog.IsWorldQuest(questID) then
					if not zoneOnly or IsQuestOnMapCurrentMap(questID) then
						local distance, itemLink = GetQuestDistanceWithItem(questID, maxDistanceYd)
						local priorityIndex = IsItemPrioritized(itemLink)
						if priorityIndex then
							if not hasPrioritizedItem then
								table.wipe(prioritizedItemLinks)
								hasPrioritizedItem = true
							end
							table.insert(prioritizedItemLinks, {itemLink, priorityIndex})
						elseif distance and distance <= closestDistance then
							closestDistance = distance
							closestQuestItemLink = itemLink
						end
					end
				end
			end
		end
	end

	if hasPrioritizedItem then
		table.sort(prioritizedItemLinks, sortPrioritizedItemLinks)
		return prioritizedItemLinks[1][1]
	elseif closestQuestItemLink then
		return closestQuestItemLink
	end
end
