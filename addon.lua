local addonName, addon = ...

local L = addon.L
local data = addon.data

local LEM = LibStub('LibEditMode')

local DEFAULTS = {
	position = {
		point = 'CENTER',
		x = 0,
		y = 0,
	},
	scale = 1,
	artworkAlpha = 1,
	artworkStyle = 'Default',
	noCooldownText = false,
	trackingOnly = false,
	zoneOnly = false,
	distanceYd = 1000,
}

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
		if value == 'show' and self:GetAttribute('item') ~= nil then
			-- trigger an update to check if we should show an item
			self:Show()
			self:CallMethod('UpdateState')
		else
			self:Hide()
			self:ClearBindings()
			self:SetAttribute('item', nil) -- avoid ghost clicks
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

local button = addon:CreateExtraButton('QuickKeybindButtonTemplate, SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate')
function button:OnLoad()
	self:Hide()

	-- add some more API
	Mixin(self, ItemMixin)

	-- set action type
	self:SetAttribute('type', 'item')

	-- register events for updating displayed data
	self:RegisterEvent('UPDATE_BINDINGS', self.UpdateBinding)
	self:RegisterEvent('BAG_UPDATE_DELAYED', self.UpdateCount)
	self:RegisterEvent('BAG_UPDATE_COOLDOWN', self.UpdateCooldown)

	-- update every 2 seconds for the distance check
	C_Timer.NewTicker(2, self.OnUpdate)

	-- quest and tracking related events that should cover all we need
	self:RegisterEvent('QUEST_LOG_UPDATE', self.UpdateState)
	self:RegisterEvent('QUEST_POI_UPDATE', self.UpdateState)
	self:RegisterEvent('QUEST_WATCH_LIST_CHANGED', self.UpdateState)
	self:RegisterEvent('ZONE_CHANGED', self.UpdateState)
	self:RegisterEvent('ZONE_CHANGED_NEW_AREA', self.UpdateState)
	self:RegisterEvent('PLAYER_INSIDE_QUEST_BLOB_STATE_CHANGED', self.UpdateState)
	self:RegisterEvent('WAYPOINT_UPDATE', self.UpdateState)
	self:RegisterEvent('BAG_UPDATE_DELAYED', self.UpdateState)
	self:RegisterUnitEvent('UNIT_AURA', 'player', self.UpdateState)

	-- some items are used directly on targets
	self:RegisterEvent('PLAYER_TARGET_CHANGED', self.UpdateTarget)

	-- update checked status
	self:RegisterEvent('CURRENT_SPELL_CAST_CHANGED', self.UpdateChecked)
	self:RegisterEvent('ACTIONBAR_UPDATE_STATE', self.UpdateChecked)
end

function button:UpdateBinding()
	if self.editing then
		return
	end

	if not InCombatLockdown() then
		local keyButton = addonName:upper()
		local key1 = GetBindingKey(keyButton)
		if not key1 then
			keyButton = 'EXTRAACTIONBUTTON1'
			key1 = GetBindingKey(keyButton)
		end

		-- update hotkey text
		self:SetHotKey(key1 and GetBindingText(key1, 1))

		-- reset state driver
		UnregisterStateDriver(self, 'visible')

		-- update state driver
		if keyButton == addonName:upper() then
			RegisterStateDriver(self, 'visible', '[petbattle] hide; show')
		else
			RegisterStateDriver(self, 'visible', '[extrabar][petbattle] hide; show')
		end

		-- update attribute handler
		self:SetAttribute('_onattributechanged', ATTRIBUTE_HANDLER:format(keyButton))

		-- trigger a state update for the binding
		self:SetAttribute('binding', GetTime())
	else
		addon:DeferMethod(self, 'UpdateBinding')
	end
end

function button:UpdateCount()
	if self.editing then
		return
	end

	if not self:IsItemEmpty() then
		-- update count
		local count = C_Item.GetItemCount(self:GetItemLink())
		self:SetCount(count)

		if count == 0 then
			-- player ran out of items, update the state
			self:UpdateState()
		end
	end
end

function button:UpdateCooldown()
	if self.editing then
		return
	end

	if not self:IsItemEmpty() then
		local start, duration = C_Item.GetItemCooldown(self:GetItemID())
		if duration > 0 then
			self:SetCooldown(start, duration)
		else
			self:ClearCooldown()
		end
	end
end

function button:UpdateState()
	if self.editing then
		return
	end

	local itemLink = self:GetTargetItem()
	if not itemLink then
		local layoutName = LEM:GetActiveLayoutName()
		local profile = ExtraQuestButtonDB3.profiles[layoutName]
		if profile then
			itemLink = addon:GetClosestQuestItem(profile.distanceYd, profile.zoneOnly, profile.trackingOnly)
		end
	end

	if itemLink then
		if itemLink ~= self:GetItemLink() then
			self:SetItem(itemLink)
		end
	elseif self:IsShown() then
		self:Reset()
	end
end

function button:UpdateTarget()
	if self.editing then
		return
	end

	local npcID = addon:GetUnitID('target')
	if npcID then
		local targetItemID = data.targetItems[npcID]
		if targetItemID then
			if C_Item.GetItemCount(targetItemID) > 0 then
				self:SetTargetItem(targetItemID)
				self:UpdateState()
				return
			end
		end
	end

	if self:GetTargetItem() then
		-- there's no npc ID or valid target item, time to reset
		self:SetTargetItem()
		self:UpdateState()
	end
end

function button:SetTargetItem(itemID)
	if self.editing then
		return
	end

	if itemID then
		-- need to turn this into an item link
		local _, itemLink = C_Item.GetItemInfo(itemID)
		itemID = itemLink
	end

	self.targetItem = itemID
end

function button:GetTargetItem()
	return self.targetItem
end

function button:UpdateAttributes()
	if self.editing then
		return
	end

	if self:IsItemEmpty() then
		self:SetAttribute('item', nil)
		self:ClearCooldown()
	else
		self:SetAttribute('item', 'item:' .. self:GetItemID())
		self:UpdateCooldown()
	end
end

function button:SetItem(itemLink)
	if not itemLink then
		return
	end

	self:SetItemLink(itemLink)
	self:SetIcon(self:GetItemIcon()) -- we're going to assume it's already loaded since it's a link
	self:EnableUpdateRange(C_Item.ItemHasRange(itemLink))

	addon:DeferMethod(self, 'UpdateAttributes')
	self:UpdateCount()
end

function button:Reset()
	if self.editing then
		return
	end

	self:Clear()
	self:EnableUpdateRange(false)

	addon:DeferMethod(self, 'UpdateAttributes')
end

function button.OnUpdate()
	button:UpdateState()
end

function button:OnEnter()
	if KeybindFrames_InQuickKeybindMode() then
		QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnEnter(self)
	else
		local itemLink = self:GetItemLink()
		if itemLink then
			GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
			GameTooltip:SetHyperlink(itemLink)
		end
	end
end

function button:OnLeave()
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnLeave(self)
	GameTooltip_Hide(self)
end

function button:OnPositionChanged(layoutName, point, x, y)
	ExtraQuestButtonDB3.profiles[layoutName].position = {
		point = point,
		x = x,
		y = y,
	}
end

function button:OnSettingsChanged(layoutName)
	-- update all button elements
	local profile = ExtraQuestButtonDB3.profiles[layoutName]
	self:SetScale(profile.scale)
	self:SetArtworkStyle(profile.artworkStyle)
	self:SetArtworkAlpha(profile.artworkAlpha)
	self:EnableCooldownText(not profile.noCooldownText)

	-- TODO: move this to the library
	local pos = profile.position
	self:ClearAllPoints()
	self:SetPoint(pos.point, pos.x, pos.y)
end

function button:EnableEditMode(isInEditMode)
	self.editing = isInEditMode
	if self.editing then
		if InCombatLockdown() then
			addon:Print('Can\'t modify in combat')
		end

		-- unregister state driver and attribute handler
		UnregisterStateDriver(self, 'visible')
		self:SetAttribute('_onattributechanged', nil)

		-- set custom texture, clear cooldowns and show
		self:SetIcon([[Interface\Icons\INV_Misc_Wrench_01]])
		self:ClearCooldown()
		self:Show()
	else
		if not InCombatLockdown() and self:IsItemEmpty() then
			-- hide right away
			self:Hide()
		else
			self:SetItem(self:GetItemLink())
		end

		-- let state enable itself
		addon:DeferMethod(self, 'UpdateBinding')
	end
end

function button.OnEditModeEnter()
	addon:DeferMethod(button, 'EnableEditMode', true)
end

function button.OnEditModeExit()
	addon:DeferMethod(button, 'EnableEditMode', false)
end

function button.OnEditModeLayout(layoutName)
	if not ExtraQuestButtonDB3 then
		ExtraQuestButtonDB3 = {profiles = {}}
	end

	if not ExtraQuestButtonDB3.profiles[layoutName] then
		ExtraQuestButtonDB3.profiles[layoutName] = CopyTable(DEFAULTS)
	end

	button:OnSettingsChanged(layoutName)
end

-- init
button:OnLoad()

-- inject into EditMode
LEM:AddFrame(button, button.OnPositionChanged, DEFAULTS.position)
LEM:RegisterCallback('enter', button.OnEditModeEnter)
LEM:RegisterCallback('exit', button.OnEditModeExit)
LEM:RegisterCallback('layout', button.OnEditModeLayout)

-- build LDD-compatible data
local ART_STYLE_OPTIONS = {}
for name in next, button:GetArtworkStyles() do
	table.insert(ART_STYLE_OPTIONS, {
		text = name,
		isRadio = true,
	})
end

local function sortByText(a, b)
	return a.text < b.text
end
table.sort(ART_STYLE_OPTIONS, sortByText)

LEM:AddFrameSettings(button, {
	{
		name = L['Button scale'],
		kind = LEM.SettingType.Slider,
		default = DEFAULTS.scale,
		get = function(layoutName)
			return ExtraQuestButtonDB3.profiles[layoutName].scale
		end,
		set = function(layoutName, value)
			ExtraQuestButtonDB3.profiles[layoutName].scale = value
			button:SetScale(value)
			-- TODO: fix position after scale has been set
		end,
		minValue = 0.1,
		maxValue = 5,
		valueStep = 0.1,
		formatter = function(value)
			return FormatPercentage(value, true)
		end,
	},
	{
		name = L['Artwork opacity'],
		kind = LEM.SettingType.Slider,
		default = DEFAULTS.artworkAlpha,
		get = function(layoutName)
			return ExtraQuestButtonDB3.profiles[layoutName].artworkAlpha
		end,
		set = function(layoutName, value)
			ExtraQuestButtonDB3.profiles[layoutName].artworkAlpha = value
			button:SetArtworkAlpha(value)
		end,
		minValue = 0,
		maxValue = 1,
		valueStep = 0.05,
		formatter = function(value)
			return FormatPercentage(value, true)
		end,
	},
	{
		name = L['Artwork style'],
		kind = LEM.SettingType.Dropdown,
		default = DEFAULTS.artworkStyle,
		get = function(layoutName)
			return ExtraQuestButtonDB3.profiles[layoutName].artworkStyle
		end,
		set = function(layoutName, value)
			ExtraQuestButtonDB3.profiles[layoutName].artworkStyle = value
			button:SetArtworkStyle(value)
		end,
		values = ART_STYLE_OPTIONS,
		height = 200,
	},
	{
		name = L['Hide cooldown text'],
		kind = LEM.SettingType.Checkbox,
		default = DEFAULTS.noCooldownText,
		get = function(layoutName)
			return ExtraQuestButtonDB3.profiles[layoutName].noCooldownText
		end,
		set = function(layoutName, value)
			ExtraQuestButtonDB3.profiles[layoutName].noCooldownText = value
			button:EnableCooldownText(not value)
		end,
	},
	{
		name = L['Only show for tracked quests'],
		kind = LEM.SettingType.Checkbox,
		default = DEFAULTS.trackingOnly,
		get = function(layoutName)
			return ExtraQuestButtonDB3.profiles[layoutName].trackingOnly
		end,
		set = function(layoutName, value)
			ExtraQuestButtonDB3.profiles[layoutName].trackingOnly = value
		end,
	},
	{
		name = L['Only show for quests in current zone'],
		kind = LEM.SettingType.Checkbox,
		default = DEFAULTS.zoneOnly,
		get = function(layoutName)
			return ExtraQuestButtonDB3.profiles[layoutName].zoneOnly
		end,
		set = function(layoutName, value)
			ExtraQuestButtonDB3.profiles[layoutName].zoneOnly = value
		end,
	},
	{
		name = L['Tracking distance'],
		kind = LEM.SettingType.Slider,
		default = DEFAULTS.distanceYd,
		get = function(layoutName)
			return ExtraQuestButtonDB3.profiles[layoutName].distanceYd
		end,
		set = function(layoutName, value)
			ExtraQuestButtonDB3.profiles[layoutName].distanceYd = value
		end,
		minValue = 5,
		maxValue = 10000,
		valueStep = 1,
		formatter = function(value)
			return math.floor(value + 0.5)
		end,
	},
})

-- adjust the EditMode selection to cover the artwork
button.Selection:SetAllPoints(button.Artwork)

-- set binding globals
_G['BINDING_HEADER_' .. addonName:upper()] = addonName
_G['BINDING_NAME_' .. addonName:upper()] = addonName

-- hook QuickKeyBind to apply our command and state
hooksecurefunc(ActionButtonUtil, 'SetAllQuickKeybindButtonHighlights', function(show)
	if not show and LEM:IsInEditMode() then
		return
	end

	addon:DeferMethod(button, 'EnableEditMode', show)

	button.commandName = show and addonName:upper()
	button.QuickKeybindHighlightTexture:SetShown(show)

	if show and InCombatLockdown() then
		-- TODO: can we even support this?
		addon:Print('Can\'t adjust bindings in combat, you\'ll probably get errors now.')
	end
end)

addon:RegisterSlash('/eqb', function()
	addon:Print('Settings moved to the Edit Mode.')
end)
