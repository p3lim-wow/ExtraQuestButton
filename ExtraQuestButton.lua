local addonName, ns = ...
local mixins = ns.mixins
local itemData = ns.itemData

local ATTRIBUTE_HANDLER = [[
	local bindingParent = '%s'

	if name == 'item' then
		-- update when the item attribute changes
		if value and not self:IsShown() and not (bindingParent == 'EXTRAACTIONBUTTON1' and HasExtraActionBar()) then
			self:Show()
		elseif not value then
			self:Hide()
			self:ClearBindings()
		end
	elseif name == 'state-visible' then
		-- there is (or was) a pet battle
		if value == 'show' then
			-- trigger an update to check if we should show an item
			self:CallMethod('UpdateState')
			self:Show()
		else
			self:Hide()
			self:ClearBindings()
		end
	end

	if self:IsShown() then
		self:ClearBindings()

		local key1, key2 = GetBindingKey(bindingParent)
		if key1 then
			self:SetBindingClick(1, key1, self, 'LeftButton')
		end
		if key2 then
			self:SetBindingClick(2, key2, self, 'LeftButton')
		end
	end
]]

local Anchor = CreateFrame('CheckButton', addonName .. 'Anchor', UIParent)
Mixin(Anchor, mixins.EventHandler, mixins.QuestButton, mixins.Anchor)
Anchor:OnLoad()

local ExtraQuestButton = CreateFrame('CheckButton', addonName, UIParent, 'QuickKeybindButtonTemplate, SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate')
Mixin(ExtraQuestButton, mixins.EventHandler, mixins.QuestButton)
ExtraQuestButton:SetAllPoints(Anchor)

function ExtraQuestButton:OnLoad()
	-- trigger inherited loaders
	mixins.QuestButton.OnLoad(self)
	mixins.EventHandler.OnLoad(self)

	-- set action type
	self:SetAttribute('type', 'item')

	-- register events for updating displayed data
	self:RegisterEvent('UPDATE_BINDINGS', self.UpdateBinding)
	self:RegisterEvent('BAG_UPDATE_DELAYED', self.UpdateCount)
	self:RegisterEvent('BAG_UPDATE_COOLDOWN', self.UpdateCooldown)

	-- VIGNETTES_UPDATED will trigger approx every 2 seconds while not in range of a quest area
	-- due to the minimap POI, which is perfect for out updating criteria
	self:RegisterEvent('VIGNETTES_UPDATED', self.UpdateState)

	-- quest and tracking related events that should cover all we need
	self:RegisterEvent('QUEST_LOG_UPDATE', self.UpdateState)
	self:RegisterEvent('QUEST_POI_UPDATE', self.UpdateState)
	self:RegisterEvent('QUEST_WATCH_LIST_CHANGED', self.UpdateState)
	self:RegisterEvent('ZONE_CHANGED', self.UpdateState)
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', self.UpdateState)
	self:RegisterEvent('WAYPOINT_UPDATE', self.UpdateState)
	self:RegisterEvent('BAG_UPDATE_DELAYED', self.UpdateState)

	-- some items are used directly on targets
	self:RegisterEvent('PLAYER_TARGET_CHANGED', self.UpdateTarget)
end

function ExtraQuestButton:UpdateBinding()
	local key = GetBindingKey(ExtraQuestButtonDB.copyBindings and 'EXTRAACTIONBUTTON1' or addonName)
	self:SetHotkey(key and GetBindingText(key, 1))

	if not InCombatLockdown() then
		-- reset state driver
		UnregisterStateDriver(self, 'visible')

		-- update the state driver and attribute handler
		if ExtraQuestButtonDB.copyBindings then
			RegisterStateDriver(self, 'visible','[extrabar][petbattle] hide; show')
			self:SetAttribute('_onattributechanged', ATTRIBUTE_HANDLER:format('EXTRAACTIONBUTTON1'))
		else
			RegisterStateDriver(self, 'visible','[petbattle] hide; show')
			self:SetAttribute('_onattributechanged', ATTRIBUTE_HANDLER:format(addonName))
		end

		-- trigger a state update for the binding
		self:SetAttribute('binding', GetTime())

		-- unregister in case we came from combat
		if self:IsEventRegistered('PLAYER_REGEN_ENABLED') then
			self:UnregisterEvent('PLAYER_REGEN_ENABLED', self.UpdateBinding)
		end
	else
		self:RegisterEvent('PLAYER_REGEN_ENABLED', self.UpdateBinding)
	end
end

function ExtraQuestButton:UpdateCount()
	if self:HasItem() then
		local count = GetItemCount(self:GetItemLink())
		self:SetCount(count and count > 1 and count)

		if count == 0 then
			-- trigger an update since we have no items left
			self:UpdateState()
		end
	end
end

function ExtraQuestButton:UpdateCooldown()
	if self:HasItem() then
		local start, duration, enable = GetItemCooldown(self:GetItemID())
		if duration > 0 then
			self:SetCooldown(start, duration)
		else
			self:ClearCooldown()
		end
	end
end

function ExtraQuestButton:UpdateTooltip()
	local itemLink = self:GetItemLink()
	if itemLink then
		GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
		GameTooltip:SetHyperlink(itemLink)
	end
end

function ExtraQuestButton:UpdateState()
	local itemLink = self:GetTargetItem()
	if not itemLink then
		itemLink = ns:GetClosestQuestItem()
	end

	if itemLink then
		if itemLink ~= self:GetItemLink() then
			self:SetItem(itemLink)
		end
	elseif self:IsShown() then
		self:Reset()
	end
end

function ExtraQuestButton:UpdateTarget()
	local npcID = ns:GetNPCID('target')
	if npcID then
		local targetItemID = itemData.targetItems[npcID]
		if targetItemID then
			if GetItemCount(targetItemID) > 0 then
				self:SetTargetItem(targetItemID)
				self:UpdateState()
				return
			end
		end
	end

	if self:GetTargetItem() then
		-- there's no npc ID or valid target item, we need to reset
		self:SetTargetItem()
		self:UpdateState()
	end
end

function ExtraQuestButton:SetTargetItem(itemID)
	if itemID then
		-- need to turn this into an item link
		local _, itemLink = GetItemInfo(itemID)
		itemID = itemLink
	end

	self.targetItem = itemID
end

function ExtraQuestButton:GetTargetItem()
	return self.targetItem
end

function ExtraQuestButton:UpdateAttributes()
	if InCombatLockdown() then
		-- can't update attributes in combat
		self:QueueAttributeUpdate()
		return
	else
		self:SetAlpha(1)
	end

	if self:HasItem() then
		self:SetAttribute('item', 'item:' .. self:GetItemID())
		self:UpdateCooldown()
	else
		self:SetAttribute('item', nil)
		self:ClearCooldown()
	end

	return true -- to unregister the attribute queue
end

function ExtraQuestButton:QueueAttributeUpdate()
	if not self:HasItem() and self:IsShown() then
		-- pretend like it's gone already
		self:SetAlpha(0)
	end

	if not self:IsEventRegistered('PLAYER_REGEN_ENABLED') then
		self:RegisterEvent('PLAYER_REGEN_ENABLED', self.UpdateAttributes)
	end
end

function ExtraQuestButton:SetItem(itemLink)
	self.itemLink = itemLink
	self.itemID = GetItemInfoFromHyperlink(itemLink)

	self:SetTexture(GetItemIcon(itemLink))
	self:EnableUpdateRange(ItemHasRange(itemLink))

	self:UpdateAttributes()
	self:UpdateCount()
end

function ExtraQuestButton:Reset()
	self.itemLink = nil
	self.itemID = nil
	self:EnableUpdateRange(false)

	self:UpdateAttributes()
end

function ExtraQuestButton:HasItem()
	return not not self.itemLink
end

function ExtraQuestButton:GetItemLink()
	return self.itemLink
end

function ExtraQuestButton:GetItemID()
	-- some APIs can't handle item links
	return self.itemID
end

-- init
ExtraQuestButton:OnLoad()

-- Binding UI global names
-- BUG: this will taint the binding UI if bindings are changed in combat, no way around it
BINDING_HEADER_EXTRAQUESTBUTTON = addonName
BINDING_NAME_EXTRAQUESTBUTTON = addonName

-- quick binding support, this + mixin + some customizations to the enter/leave scripts
hooksecurefunc(ActionButtonUtil, 'SetAllQuickKeybindButtonHighlights', function(show)
	ExtraQuestButton.commandName = show and addonName:upper() -- the mixin uses this to generate the tooltip
	ExtraQuestButton.QuickKeybindHighlightTexture:SetShown(show)

	if show and InCombatLockdown() then
		-- TODO: figure out if we can realistically support this, the problem is that we can't
		--       update the attributes in combat
		ns:Print('Can\'t quick bind while in combat, you will see errors!')
	end
end)
