local _, itemData = ...

local CONSOLIDATING_POWER = false

local activeWorldQuests = {}
local onAttributeChanged = [[
	if(name == 'state-combat') then
		local ExtraActionButton = self:GetFrameRef('ExtraActionButton')
		if(value == 'true') then
			ExtraActionButton:Hide()
			self:Show()
		elseif(HasExtraActionBar()) then
			ExtraActionButton:Show()
			self:Hide()
			self:ClearBindings()
		end
	else
		local inCombat = self:GetAttribute('state-combat') == 'true'
		if(name == 'item') then
			if(value and not self:IsShown() and (not HasExtraActionBar() or inCombat)) then
				self:Show()
			elseif(not value) then
				self:Hide()
				self:ClearBindings()
			end
		elseif(name == 'state-visible') then
			if(value == 'show') then
				self:CallMethod('Update')
			elseif(not inCombat) then
				self:Hide()
				self:ClearBindings()
			end
		end
	end

	if(self:IsShown() and (name == 'item' or name == 'binding' or name == 'state-combat')) then
		self:ClearBindings()

		local key = GetBindingKey('EXTRAACTIONBUTTON1')
		if(key) then
			self:SetBindingClick(1, key, self, 'LeftButton')
		end
	end
]]

ExtraQuestButtonMixin = {}
function ExtraQuestButtonMixin:OnLoad()
	RegisterStateDriver(self, 'visible', '[extrabar][petbattle] hide; show')
	SecureHandlerSetFrameRef(self, 'ExtraActionButton', ExtraActionButton1)

	self:SetAttribute('_onattributechanged', onAttributeChanged)
	self:SetAttribute('type', 'item')

	self:RegisterEvent('PLAYER_LOGIN')
end

function ExtraQuestButtonMixin:PostClick()
	self:UpdateState()
end

function ExtraQuestButtonMixin:OnEvent(event, ...)
	if(event == 'PLAYER_LOGIN') then
		-- register events
		self:RegisterEvent('UPDATE_BINDINGS')
		self:RegisterEvent('BAG_UPDATE_COOLDOWN')
		self:RegisterEvent('BAG_UPDATE_DELAYED')
		self:RegisterEvent('QUEST_LOG_UPDATE') -- Update
		self:RegisterEvent('QUEST_POI_UPDATE') -- Update
		self:RegisterEvent('QUEST_WATCH_LIST_CHANGED') -- Update
		self:RegisterEvent('QUEST_ACCEPTED')
		self:RegisterEvent('QUEST_REMOVED')
		self:RegisterEvent('ZONE_CHANGED') -- Update
		self:RegisterEvent('ZONE_CHANGED_NEW_AREA') -- Update
		self:RegisterEvent('VIGNETTES_UPDATED')
		self:RegisterEvent('CURRENT_SPELL_CAST_CHANGED')
	elseif(event == 'UPDATE_BINDINGS') then
		self:UpdateBindings()
	elseif(event == 'BAG_UPDATE_COOLDOWN') then
		if(self:IsShown() and self:HasItem()) then
			self:UpdateCooldown()
		end
	elseif(event == 'BAG_UPDATE_DELAYED') then
		if(self:HasItem()) then
			self:UpdateCount()
		end
	elseif(event == 'QUEST_LOG_UPDATE') then
		CONSOLIDATING_POWER = C_QuestLog.IsOnQuest(44067)

		if(InCombatLockdown()) then
			self.stateDriverQueued = true

			if(not self:IsEventRegistered('PLAYER_REGEN_ENABLED')) then
				self:RegisterEvent('PLAYER_REGEN_ENABLED')
			end
		else
			self:UpdateStateDriver()
		end

		self:Update()
	elseif(event == 'QUEST_ACCEPTED') then
		self:AddWorldQuest(...)
	elseif(event == 'QUEST_REMOVED') then
		self:RemoveWorldQuest(...)
	elseif(event == 'VIGNETTES_UPDATED') then
		-- this will fire every 2 seconds not in range of a quest area due to the minimap POI,
		-- which is perfect for our updating needs and update criteria
		if(not self:IsShown()) then
			self:Update()
		end
	elseif(event == 'PLAYER_REGEN_ENABLED') then
		self:UnregisterEvent(event)

		if(self.attributeUpdateQueued) then
			self.attributeUpdateQueued = false
			self:UpdateAttributes()
			self:SetAlpha(1)
		end

		if(self.stateDriverQueued) then
			self.stateDriverQueued = false
		end
	elseif(event == 'CURRENT_SPELL_CAST_CHANGED') then
		if(self:IsShown()) then
			self:UpdateState()
		end
	else
		self:Update()
	end
end

function ExtraQuestButtonMixin:OnEnter()
	local itemLink = self:GetItemLink()
	if(itemLink) then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
		GameTooltip:SetHyperlink(itemLink)
	end
end

function ExtraQuestButtonMixin:OnUpdate(elapsed)
	if(updateRange) then
		if((self.rangeTimer or 0) > TOOLTIP_UPDATE_TIME) then
			local HotKey = self.HotKey

			-- BUG: IsItemInRange() is broken versus friendly targets
			local inRange = IsItemInRange(self:GetItemLink(), 'target')
			if(inRange == false) then
				HotKey:SetTextColor(1, 0.1, 0.1)
			else
				HotKey:SetTextColor(0.6, 0.6, 0.6)
			end

			if(HotKey:GetText() == RANGE_INDICATOR) then
				HotKey:SetShown(inRange ~= nil)
			else
				HotKey:Show()
			end

			self.rangeTimer = 0
		else
			self.rangeTimer = (self.rangeTimer or 0) + elapsed
		end
	end

	if((self.updateTimer or 0) > 5) then
		self:Update()
		self.updateTimer = 0
	else
		self.updateTimer = (self.updateTimer or 0) + elapsed
	end
end

local itemIDs = setmetatable({}, {
	-- caching itemLinks to itemIDs
	__index = function(t, item)
		if(type(item) == 'number') then
			t[item] = item
			return item
		elseif(type(item) ~= 'string') then
			t[item] = false
			return
		end

		local itemID = GetItemInfoFromHyperlink(item)
		t[item] = itemID
		return itemID
	end
})

function ExtraQuestButtonMixin:SetItem(itemLink)
	if(itemLink) then
		self:SetItemLink(itemLink)
		self:SetItemID(itemIDs[itemLink])

		return not itemData.itemBlacklist[self:GetItemID()]
	else
		self.itemID = nil
		self.itemLink = nil
	end
end

function ExtraQuestButtonMixin:HasItem()
	return not not self.itemID
end

function ExtraQuestButtonMixin:SetItemLink(itemLink)
	self.itemLink = itemLink
end

function ExtraQuestButtonMixin:GetItemLink()
	return self.itemLink
end

function ExtraQuestButtonMixin:SetItemID(itemID)
	self.itemID = itemID
end

function ExtraQuestButtonMixin:GetItemID()
	return self.itemID
end

local function GetQuestDistanceAndItemLink(questLogIndex)
	-- returns the distance to the quest area and the item link if the quest has an item
	local _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(questLogIndex)
	if(not isHeader) then
		local itemLink, _, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
		if(not itemLink) then
			local itemID = itemData.questItems[questID]
			if(itemID and GetItemCount(itemID) > 0) then
				_, itemLink = GetItemInfo(itemID)
				showCompleted = itemData.questItemsShowComplete[itemID]
			end
		end

		if(itemLink) then
			local areaID = itemData.questAreas[questID]
			if(not areaID) then
				areaID = itemData.itemAreas[(GetItemInfoFromHyperlink(itemLink))]
			end

			if(not isComplete or (isComplete and showCompleted)) then
				if(areaID and (type(areaID) == 'boolean' or areaID == C_Map.GetBestMapForUnit('player'))) then
					return 62500, itemLink -- "maximum" distance, basically lowest priority
				elseif(QuestHasPOIInfo(questID)) then
					local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
					if(onContinent) then
						return distanceSq, itemLink
					end
				end
			end
		end
	end
end

function ExtraQuestButtonMixin:GetClosestQuestItem()
	-- iterate through world, watched and normal quests to find the closest one with an item
	local closestItemLink
	-- we can only get the distance to the center of the blob, so we only get the one the player
	-- is closest to the center of, and we limit this to a certain distance
	local shortestDistanceSq = 62500 -- start at 250 sq yards

	for _, questLogIndex in next, activeWorldQuests do
		local distanceSq, itemLink = GetQuestDistanceAndItemLink(questLogIndex)
		if(distanceSq and distanceSq <= shortestDistanceSq) then
			shortestDistanceSq = distanceSq
			closestItemLink = itemLink
		end
	end

	if(not closestItemLink) then
		for index = 1, GetNumQuestWatches() do
			local _, _, questLogIndex = GetQuestWatchInfo(index)
			if(questLogIndex) then
				local distanceSq, itemLink = GetQuestDistanceAndItemLink(questLogIndex)
				if(distanceSq and distanceSq <= shortestDistanceSq) then
					shortestDistanceSq = distanceSq
					closestItemLink = itemLink
				end
			end
		end
	end

	if(not closestItemLink) then
		for questLogIndex = 1, GetNumQuestLogEntries() do
			local distanceSq, itemLink = GetQuestDistanceAndItemLink(questLogIndex)
			if(distanceSq and distanceSq <= shortestDistanceSq) then
				shortestDistanceSq = distanceSq
				closestItemLink = itemLink
			end
		end
	end

	return closestItemLink
end

function ExtraQuestButtonMixin:Reset()
	self.HotKey:SetTextColor(1, 1, 1)
	self:UpdateState()
end

function ExtraQuestButtonMixin:Update()
	if(HasExtraActionBar() and not CONSOLIDATING_POWER) then
		-- don't bother updating, when the extra button disappears this method will be called again
		return
	end

	local item = self:GetClosestQuestItem()
	if(self:SetItem(item)) then
		self:Reset()
		self.Icon:SetTexture(GetItemIcon(self:GetItemID()))
		self.updateRange = ItemHasRange(self:GetItemLink())

		self:UpdateAttributes()
	elseif(self:IsShown() and not item) then
		self:UpdateAttributes()
	end
end

function ExtraQuestButtonMixin:UpdateState()
	self:SetChecked(IsCurrentItem(self:GetItemID()))
end

function ExtraQuestButtonMixin:UpdateAttributes()
	if(InCombatLockdown()) then
		return self:QueueAttributeUpdate()
	end

	if(self:HasItem()) then
		self:SetAttribute('item', 'item:' .. self:GetItemID())
		self:UpdateCooldown()
	else
		self:SetAttribute('item', nil)
	end
end

function ExtraQuestButtonMixin:QueueAttributeUpdate()
	self.attributeUpdateQueued = true

	if(not self:HasItem()) then
		self:SetAlpha(0) -- fake it 'till we make it
	end

	if(not self:IsEventRegistered('PLAYER_REGEN_ENABLED')) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	end
end

function ExtraQuestButtonMixin:UpdateStateDriver()
	if(CONSOLIDATING_POWER and not self:GetAttribute('state-combat')) then
		-- Consolidating Power, we need to change the display logic
		RegisterStateDriver(self, 'combat', '[combat] true; false')
	elseif(not CONSOLIDATING_POWER and self:GetAttribute('state-combat')) then
		UnregisterStateDriver(self, 'combat')
		-- we need to reset the state, this doesn't happen by itself
		self:SetAttribute('state-combat', nil)
	end
end

function ExtraQuestButtonMixin:AddWorldQuest(questLogIndex, questID)
	-- world quests are "hidden" in the quest log while active, so we have to track them manually
	if(questID and not IsQuestBounty(questID) and IsQuestTask(questID)) then
		local _, _, isWorldQuest = GetQuestTagInfo(questID)
		if(isWorldQuest) then
			local updateAfter = not not activeWorldQuests[questID]
			activeWorldQuests[questID] = questLogIndex

			if(updateAfter) then
				-- the world quest did not already exist in the list, run a full update
				self:Update()
			end
		end
	end
end

function ExtraQuestButtonMixin:RemoveWorldQuest(questID)
	-- remove if the quest was a world quest, then update
	if(activeWorldQuests[questID]) then
		activeWorldQuests[questID] = nil
		self:Update()
	end
end

function ExtraQuestButtonMixin:UpdateBindings()
	local HotKey = self.HotKey
	local key = GetBindingKey('EXTRAACTIONBUTTON1')
	if(key) then
		HotKey:SetText(GetBindingText(key, 1))
	else
		HotKey:SetText(RANGE_INDICATOR)
	end

	if(self:HasItem()) then
		-- trigger the secure handler to update the binding
		self:SetAttribute('binding', GetTime())
	end
end

function ExtraQuestButtonMixin:UpdateCooldown()
	local start, duration, enable = GetItemCooldown(self:GetItemID())
	if(duration > 0) then
		self.Cooldown:SetCooldown(start, duration)
		self.Cooldown:Show()
	else
		self.Cooldown:Hide()
	end
end

function ExtraQuestButtonMixin:UpdateCount()
	local num = GetItemCount(self:GetItemLink())
	self.Count:SetText(num and num > 1 and num or '')

	if(num == 0) then
		-- we probably don't want the item showing any more, let's update to be sure
		self:Update()
	end
end
