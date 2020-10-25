local _, ns = ...
ns.mixins = ns.mixins or {}

local function OnCooldownDone(self)
	self:GetParent():ClearCooldown()
end

local function OnEnter(self)
	if KeybindFrames_InQuickKeybindMode() then
		QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnEnter(self)
	else
		if self.UpdateTooltip then
			self:UpdateTooltip()
		end
	end
end

local function OnLeave(self)
	QuickKeybindButtonTemplateMixin.QuickKeybindButtonOnLeave(self)
	GameTooltip_Hide(self)
end

local function OnUpdate(self, elapsed)
	if (self.rangeTimer or 0) < 0.2 then
		self.rangeTimer = (self.rangeTimer or 0) + elapsed
	else
		self.rangeTimer = 0

		-- BUG: IsItemInRange() is broken versus friendly targets
		local inRange = IsItemInRange(self:GetItemLink(), 'target')
		if inRange == false then
			self.Hotkey:SetTextColor(1, 0.1, 0.1)
		else
			self.Hotkey:SetTextColor(0.6, 0.6, 0.6)
		end

		if self.Hotkey:GetText() == RANGE_INDICATOR then
			self.Hotkey:SetShown(inRange ~= nil)
		else
			self.Hotkey:Show()
		end
	end
end

local function PostClick(self)
	if self:IsShown() then
		self:SetChecked(IsCurrentItem(self:GetItemLink()))
	end
end

local QuestButtonMixin = {}
function QuestButtonMixin:OnLoad()
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', OnLeave)
	self:SetScript('PostClick', PostClick)
	self:SetSize(52, 52) -- same size as ExtraActionButton1

	self:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])
	self:GetHighlightTexture():SetBlendMode('ADD')
	self:SetCheckedTexture([[Interface\Buttons\CheckButtonHilight]])
	self:GetCheckedTexture():SetBlendMode('ADD')

	self:RegisterEvent('CURRENT_SPELL_CAST_CHANGED', PostClick)
	self:RegisterEvent('ACTIONBAR_UPDATE_STATE', PostClick)

	local Texture = self:CreateTexture('$parentIcon', 'BACKGROUND')
	Texture:SetAllPoints()
	self.Texture = Texture

	local Artwork = self:CreateTexture('$parentArtwork', 'OVERLAY')
	Artwork:SetPoint('CENTER', -2, 0)
	Artwork:SetSize(256, 128)
	Artwork:SetTexture([[Interface\ExtraButton\Default]])
	self.Artwork = Artwork

	local Cooldown = CreateFrame('Cooldown', '$parentCooldown', self, 'CooldownFrameTemplate')
	Cooldown:SetPoint('TOPLEFT', 1, -1)
	Cooldown:SetPoint('BOTTOMRIGHT', -1, 1)
	Cooldown:SetScript('OnCooldownDone', OnCooldownDone)
	self.Cooldown = Cooldown

	local StringParent = CreateFrame('Frame', nil, self)
	StringParent:SetPoint('CENTER')
	StringParent:SetSize(1, 1)

	local Hotkey = StringParent:CreateFontString('$parentIcon', nil, 'NumberFontNormalGray')
	Hotkey:SetPoint('TOPLEFT', -17, -7)
	Hotkey:SetSize(36, 10)
	Hotkey:SetJustifyH('RIGHT')
	self.Hotkey = Hotkey

	local Count = StringParent:CreateFontString('$parentCount', nil, 'NumberFontNormal')
	Count:SetPoint('BOTTOMRIGHT', -5, 5)
	Count:SetJustifyH('RIGHT')
	self.Count = Count
end

function QuestButtonMixin:EnableUpdateRange(state)
	self.shouldUpdateRange = state
	self.Hotkey:SetTextColor(1, 1, 1) -- reset to default value
	self:SetScript('OnUpdate', state and OnUpdate or nil)
end

function QuestButtonMixin:ShouldUpdateRange()
	return self.shouldUpdateRange
end

function QuestButtonMixin:SetCooldown(start, duration)
	self.Cooldown:SetCooldown(start, duration)
	self.Cooldown:Show()
end

function QuestButtonMixin:ClearCooldown()
	self.Cooldown:Clear()
	self.Cooldown:Hide()
end

function QuestButtonMixin:SetHotkey(key)
	self.Hotkey:SetText(key or RANGE_INDICATOR)
end

function QuestButtonMixin:SetCount(count)
	self.Count:SetText(count or '')
end

function QuestButtonMixin:SetTexture(texture)
	self.Texture:SetTexture(texture)
end

function QuestButtonMixin:GetTexture()
	return self.Texture:GetTexture()
end

ns.mixins.QuestButton = QuestButtonMixin
