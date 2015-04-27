local Button = CreateFrame('Button', (...), UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate')
Button:SetMovable(true)
Button:RegisterEvent('PLAYER_LOGIN')
Button:SetScript('OnEvent', function(self, event, ...)
	if(self[event]) then
		self[event](self, event, ...)
	elseif(self:IsEnabled()) then
		self:Update()
	end
end)

local visibilityState = '[extrabar][petbattle] hide; show'
local onAttributeChanged = [[
	if(name == 'item') then
		if(value and not self:IsShown() and not HasExtraActionBar()) then
			self:Show()
		elseif(not value) then
			self:Hide()
			self:ClearBindings()
		end
	elseif(name == 'state-visible') then
		if(value == 'show') then
			self:CallMethod('Update')
		else
			self:Hide()
			self:ClearBindings()
		end
	end

	if(self:IsShown() and (name == 'item' or name == 'binding')) then
		self:ClearBindings()

		local key = GetBindingKey('EXTRAACTIONBUTTON1')
		if(key) then
			self:SetBindingClick(1, key, self, 'LeftButton')
		end
	end
]]

function Button:BAG_UPDATE_COOLDOWN()
	if(self:IsShown() and self:IsEnabled()) then
		local start, duration, enable = GetItemCooldown(self.itemID)
		if(duration > 0) then
			self.Cooldown:SetCooldown(start, duration)
			self.Cooldown:Show()
		else
			self.Cooldown:Hide()
		end
	end
end

function Button:BAG_UPDATE_DELAYED()
	self:Update()

	if(self:IsShown() and self:IsEnabled()) then
		local count = GetItemCount(self.itemLink)
		self.Count:SetText(count and count > 1 and count or '')
	end
end

function Button:PLAYER_REGEN_ENABLED(event)
	self:SetAttribute('item', self.attribute)
	self:UnregisterEvent(event)
	self:BAG_UPDATE_COOLDOWN()
end

function Button:UPDATE_BINDINGS()
	if(self:IsShown() and self:IsEnabled()) then
		self:SetItem()
		self:SetAttribute('binding', GetTime())
	end
end

function Button:PLAYER_LOGIN()
	RegisterStateDriver(self, 'visible', visibilityState)
	self:SetAttribute('_onattributechanged', onAttributeChanged)
	self:SetAttribute('type', 'item')

	if(not self:GetPoint()) then
		self:SetPoint('CENTER', ExtraActionButton1)
	end

	self:SetSize(ExtraActionButton1:GetSize())
	self:SetScale(ExtraActionButton1:GetScale())
	self:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])
	self:SetPushedTexture([[Interface\Buttons\CheckButtonHilight]])
	self:GetPushedTexture():SetBlendMode('ADD')
	self:SetScript('OnLeave', GameTooltip_Hide)
	self:SetClampedToScreen(true)
	self:SetToplevel(true)

	self.updateTimer = 0
	self.rangeTimer = 0
	self:Hide()

	local Icon = self:CreateTexture('$parentIcon', 'BACKGROUND')
	Icon:SetAllPoints()
	self.Icon = Icon

	local HotKey = self:CreateFontString('$parentHotKey', nil, 'NumberFontNormal')
	HotKey:SetPoint('BOTTOMRIGHT', -5, 5)
	self.HotKey = HotKey

	local Count = self:CreateFontString('$parentCount', nil, 'NumberFontNormal')
	Count:SetPoint('TOPLEFT', 7, -7)
	self.Count = Count

	local Cooldown = CreateFrame('Cooldown', '$parentCooldown', self, 'CooldownFrameTemplate')
	Cooldown:ClearAllPoints()
	Cooldown:SetPoint('TOPRIGHT', -2, -3)
	Cooldown:SetPoint('BOTTOMLEFT', 2, 1)
	Cooldown:Hide()
	self.Cooldown = Cooldown

	local Artwork = self:CreateTexture('$parentArtwork', 'OVERLAY')
	Artwork:SetPoint('CENTER', -2, 0)
	Artwork:SetSize(256, 128)
	Artwork:SetTexture([[Interface\ExtraButton\Default]])
	self.Artwork = Artwork

	self:RegisterEvent('UPDATE_BINDINGS')
	self:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
	self:RegisterEvent('BAG_UPDATE_COOLDOWN')
	self:RegisterEvent('BAG_UPDATE_DELAYED')
	self:RegisterEvent('WORLD_MAP_UPDATE')
	self:RegisterEvent('QUEST_LOG_UPDATE')
	self:RegisterEvent('QUEST_POI_UPDATE')
	self:RegisterEvent('QUEST_WATCH_LIST_CHANGED')
end

Button:SetScript('OnEnter', function(self)
	GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
	GameTooltip:SetHyperlink(self.itemLink)
end)

Button:SetScript('OnUpdate', function(self, elapsed)
	if(not self:IsEnabled()) then
		return
	end

	if(self.rangeTimer > TOOLTIP_UPDATE_TIME) then
		local HotKey = self.HotKey

		-- BUG: IsItemInRange() is broken versus friendly npcs (and possibly others)
		local inRange = IsItemInRange(self.itemLink, 'target')
		if(HotKey:GetText() == RANGE_INDICATOR) then
			if(inRange == false) then
				HotKey:SetTextColor(1, 0.1, 0.1)
				HotKey:Show()
			elseif(inRange) then
				HotKey:SetTextColor(1, 1, 1)
				HotKey:Show()
			else
				HotKey:Hide()
			end
		else
			if(inRange == false) then
				HotKey:SetTextColor(1, 0.1, 0.1)
			else
				HotKey:SetTextColor(1, 1, 1)
			end
		end

		self.rangeTimer = 0
	else
		self.rangeTimer = self.rangeTimer + elapsed
	end

	if(self.updateTimer > 5) then
		self:Update()
		self.updateTimer = 0
	else
		self.updateTimer = self.updateTimer + elapsed
	end
end)

Button:SetScript('OnEnable', function(self)
	RegisterStateDriver(self, 'visible', visibilityState)
	self:SetAttribute('_onattributechanged', onAttributeChanged)
	self.Artwork:SetTexture([[Interface\ExtraButton\Default]])
	self:Update()
	self:SetItem()
end)

Button:SetScript('OnDisable', function(self)
	if(not self:IsMovable()) then
		self:SetMovable(true)
	end

	RegisterStateDriver(self, 'visible', 'show')
	self:SetAttribute('_onattributechanged', nil)
	self.Icon:SetTexture([[Interface\Icons\INV_Misc_Wrench_01]])
	self.Artwork:SetTexture([[Interface\ExtraButton\Ultraxion]])
	self.HotKey:Hide()
end)

local zoneWide = {
	[14108] = 541,
	[13998] = 11,
	[25798] = 61,
	[25799] = 61,
	[25112] = 161,
	[25111] = 161,
	[24735] = 201,
	[29821] = 806,
	[31112] = 806,
	[29510] = 823,
	[24629] = true,
}

-- Sometimes blizzard does actually do what I want
local blacklist = {
	[113191] = true,
	[110799] = true,
	[109164] = true,
}

function Button:SetItem(itemLink, texture)
	if(itemLink) then
		self.Icon:SetTexture(texture)

		if(itemLink == self.itemLink and self:IsShown()) then
			return
		end

		local itemID, itemName = string.match(itemLink, '|Hitem:(.-):.-|h%[(.+)%]|h')
		self.itemID = tonumber(itemID)
		self.itemName = itemName
		self.itemLink = itemLink

		if(blacklist[self.itemID]) then
			return
		end
	end

	local HotKey = self.HotKey
	local key = GetBindingKey('EXTRAACTIONBUTTON1')
	if(key) then
		HotKey:SetText(GetBindingText(key, 1))
		HotKey:Show()
	elseif(ItemHasRange(self.itemLink)) then
		HotKey:SetText(RANGE_INDICATOR)
		HotKey:Show()
	else
		HotKey:Hide()
	end

	if(InCombatLockdown()) then
		self.attribute = self.itemName
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:SetAttribute('item', self.itemName)
		self:BAG_UPDATE_COOLDOWN()
	end
end

function Button:RemoveItem()
	if(InCombatLockdown()) then
		self.attribute = nil
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:SetAttribute('item', nil)
	end
end

local ticker
function Button:Update()
	if(not self:IsEnabled()) then
		return
	end

	local numItems = 0
	local shortestDistance = 62500 -- 250 yards²
	local closestQuestLink, closestQuestTexture

	for index = 1, GetNumQuestWatches() do
		local questID, _, questIndex, _, _, isComplete = GetQuestWatchInfo(index)
		if(questID and QuestHasPOIInfo(questID)) then
			local link, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questIndex)
			if(link) then
				local areaID = zoneWide[questID]
				local valueType = type(areaID)
				if(areaID and (type(areaID) == 'boolean' or areaID == GetCurrentMapAreaID())) then
					closestQuestLink = link
					closestQuestTexture = texture
				elseif(not isComplete or (isComplete and showCompleted)) then
					local distanceSq, onContinent = GetDistanceSqToQuest(questIndex)
					if(onContinent and distanceSq < shortestDistance) then
						shortestDistance = distanceSq
						closestQuestLink = link
						closestQuestTexture = texture
					end
				end

				numItems = numItems + 1
			end
		end
	end

	if(closestQuestLink and not HasExtraActionBar()) then
		self:SetItem(closestQuestLink, closestQuestTexture)
	elseif(self:IsShown()) then
		self:RemoveItem()
	end

	if(numItems > 0 and not ticker) then
		ticker = C_Timer.NewTicker(30, function() -- might want to lower this
			Button:Update()
		end)
	elseif(numItems == 0 and ticker) then
		ticker:Cancel()
		ticker = nil
	end
end

local Drag = CreateFrame('Frame', nil, Button)
Drag:SetAllPoints()
Drag:SetFrameStrata('HIGH')
Drag:EnableMouse(true)
Drag:RegisterForDrag('LeftButton')
Drag:Hide()

Drag:SetScript('OnShow', function(self)
	Button:Disable()
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
end)

Drag:SetScript('OnHide', function(self)
	Button:Enable()
	self:UnregisterEvent('PLAYER_REGEN_DISABLED')
end)

Drag:SetScript('OnEvent', function(self)
	self:Hide()
	Button:StopMovingOrSizing()
end)

Drag:SetScript('OnDragStart', function()
	Button:StartMoving()
end)

Drag:SetScript('OnDragStop', function()
	Button:StopMovingOrSizing()
end)

SLASH_ExtraQuestButton1 = '/eqb'
SlashCmdList.ExtraQuestButton = function(message)
	if(InCombatLockdown()) then
		print('|cff33ff99ExtraQuestButton:|r', 'Cannot move during combat.')
		return
	end

	if(string.lower(message) == 'reset') then
		Button:ClearAllPoints()
		Button:SetPoint('CENTER', ExtraActionButton1)
		Button:SetMovable(false)
		Drag:Hide()

		print('|cff33ff99ExtraQuestButton:|r', 'Reset to default position.')
		return
	end

	if(Drag:IsShown()) then
		Drag:Hide()
	else
		Drag:Show()
		Button:Show()
	end
end
