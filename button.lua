local addonName, addon = ...

local Masque = LibStub('Masque', true)

local ART_STYLES = {
	AirStrike = [[Interface\ExtraButton\AirStrike]],
	Amber = [[Interface\ExtraButton\Amber]],
	Ardenweald = [[Interface\ExtraButton\ardenweald-extrabutton]],
	Bastion = [[Interface\ExtraButton\bastion-extrabutton]],
	BrewmoonKeg = [[Interface\ExtraButton\BrewmoonKeg]],
	ChampionLight = [[Interface\ExtraButton\ChampionLight]],
	Default = [[Interface\ExtraButton\Default]],
	Engineering = [[Interface\ExtraButton\Engineering]],
	EyeOfTerrok = [[Interface\ExtraButton\EyeofTerrok]],
	Fel = [[Interface\ExtraButton\Fel]],
	FengBarrier = [[Interface\ExtraButton\FengBarrier]],
	FengShroud = [[Interface\ExtraButton\FengShroud]],
	GarrisonAlliance = [[Interface\ExtraButton\GarrZoneAbility-BarracksAlliance]], -- size is slightly off
	GarrisonArmory = [[Interface\ExtraButton\GarrZoneAbility-Armory]], -- size is slightly off
	GarrisonHorde = [[Interface\ExtraButton\GarrZoneAbility-BarracksHorde]], -- size is slightly off
	GarrisonInn = [[Interface\ExtraButton\GarrZoneAbility-Inn]], -- size is slightly off
	GarrisonLumberMill = [[Interface\ExtraButton\GarrZoneAbility-LumberMill]], -- size is slightly off
	GarrisonMageTower = [[Interface\ExtraButton\GarrZoneAbility-MageTower]], -- size is slightly off
	GarrisonStables = [[Interface\ExtraButton\GarrZoneAbility-Stables]], -- size is slightly off
	GarrisonTradingPost = [[Interface\ExtraButton\GarrZoneAbility-TradingPost]], -- size is slightly off
	GarrisonTrainingPit = [[Interface\ExtraButton\GarrZoneAbility-TrainingPit]], -- size is slightly off
	GarrisonWorkshop = [[Interface\ExtraButton\GarrZoneAbility-Workshop]], -- size is slightly off
	Generic = [[Interface\ExtraButton\ExtraButtonGeneric]],
	GreenstoneKeg = [[Interface\ExtraButton\GreenstoneKeg]],
	HeartActive = [[Interface\ExtraButton\HearthofAzeroth-ExtraButton-Active]],
	HeartInactive = [[Interface\ExtraButton\HearthofAzeroth-ExtraButton-Disabled]],
	Hozu = [[Interface\ExtraButton\HozuBar]],
	LightningKeg = [[Interface\ExtraButton\LightningKeg]],
	Maldraxxus = [[Interface\ExtraButton\maldraxxus-extrabutton]],
	Revendreth = [[Interface\ExtraButton\venthyr-extrabutton]],
	Smash = [[Interface\ExtraButton\Smash]],
	SoulCage = [[Interface\ExtraButton\SoulCage]],
	SoulSwap = [[Interface\ExtraButton\SoulSwap]],
	-- Torghast = [[Interface\ExtraButton\ExtraButtonTorghast]], -- size is completely wrong
	Ultraxxion = [[Interface\ExtraButton\Ultraxion]],
	Ysera = [[Interface\ExtraButton\Ysera]],
}

local function onEnter(self)
	if self.OnEnter then
		self:OnEnter()
	end
end

local function onLeave(self)
	if self.OnLeave then
		self:OnLeave()
	end
end

local function onCooldownDone(self)
	self:GetParent():ClearCooldown()
end

local function onRangeUpdate(self, elapsed)
	if (self.rangeTimer or 0) < 0.2 then
		self.rangeTimer = (self.rangeTimer or 0) + elapsed
	elseif not InCombatLockdown() and self:GetItemLink() then -- C_Item.IsItemInRange is combat restricted now...
		self.rangeTimer = 0

		-- BUG: C_Item.IsItemInRange() is broken versus friendly targets
		local inRange = C_Item.IsItemInRange(self:GetItemLink(), 'target')
		if inRange == false then
			self.HotKey:SetTextColor(1, 0.1, 0.1)
		else
			self.HotKey:SetTextColor(0.6, 0.6, 0.6)
		end

		if self.HotKey:GetText() == RANGE_INDICATOR then
			self.HotKey:SetShown(inRange ~= nil)
		else
			self.HotKey:Show()
		end
	end
end

local buttonMixin = {}
function buttonMixin:SetIcon(path)
	self.Icon:SetTexture(path)
end

function buttonMixin:SetHotKey(key)
	self.HotKey:SetText(key or RANGE_INDICATOR)
end

function buttonMixin:SetCount(count)
	self.Count:SetText(count and count > 1 and count or '')
end

function buttonMixin:SetCooldown(start, duration)
	self.Cooldown:SetCooldown(start, duration)
	self.Cooldown:Show()
end

function buttonMixin:ClearCooldown()
	self.Cooldown:Clear()
	self.Cooldown:Hide()
end

function buttonMixin:EnableCooldownText(state)
	self.Cooldown:SetHideCountdownNumbers(not state)
end

function buttonMixin:SetArtworkStyle(kind)
	self.Artwork:SetTexture(ART_STYLES[kind])
end

function buttonMixin:GetArtworkStyles()
	return ART_STYLES
end

function buttonMixin:SetArtworkAlpha(alpha)
	self.Artwork:SetAlpha(alpha)
end

function buttonMixin:EnableUpdateRange(state)
	self.isRangeUpdateEnabled = state
	self.HotKey:SetTextColor(1, 1, 1) -- reset to default value
	self:SetScript('OnUpdate', state and onRangeUpdate or nil)
end

function buttonMixin:IsUpdatingRange()
	return self.isRangeUpdateEnabled
end

function buttonMixin:UpdateChecked()
	if self:IsShown() and self:GetItemLink() then
		self:SetChecked(C_Item.IsCurrentItem(self:GetItemLink()))
	end
end

function buttonMixin:GetItemLink()
	-- stub
end

function addon:CreateExtraButton(extraTemplates)
	local Button = Mixin(addon:CreateButton('CheckButton', addonName, UIParent, extraTemplates), buttonMixin)
	-- local Button = Mixin(CreateFrame('CheckButton', addonName, UIParent, extraTemplates), buttonMixin, addon.eventMixin)
	Button:SetSize(52, 52)
	Button:SetClampedToScreen(true)
	Button:SetScript('OnEnter', onEnter)
	Button:SetScript('OnLeave', onLeave)
	Button:SetScript('PostClick', Button.UpdateChecked)

	local Icon = Button:CreateTexture('$parentIcon', 'BACKGROUND')
	Icon:SetAllPoints()
	Button.Icon = Icon

	local Mask = Button:CreateMaskTexture('$parentMask', 'BACKGROUND')
	Mask:SetSize(76, 76)
	Mask:SetPoint('CENTER', Icon, 0, -1)
	Mask:SetTexture([[Interface\HUD\UIActionBarIconFrameMask]], 'CLAMPTOBLACKADDITIVE', 'CLAMPTOBLACKADDITIVE')
	Icon:AddMaskTexture(Mask)

	-- local Flash = Button:CreateTexture('$parentFlash', 'ARTWORK')
	-- Flash:SetPoint('TOPLEFT')
	-- Flash:SetSize(54, 53)
	-- Flash:SetAtlas('UI-HUD-ActionBat-IconFrame-Flash')

	local Artwork = Button:CreateTexture('$parentArtwork', 'OVERLAY')
	Artwork:SetPoint('CENTER')
	Artwork:SetSize(256, 128)
	Button.Artwork = Artwork

	local Cooldown = CreateFrame('Cooldown', '$parentCooldown', Button, 'CooldownFrameTemplate')
	Cooldown:SetPoint('TOPLEFT', 4, -4)
	Cooldown:SetPoint('BOTTOMRIGHT', -3, 4)
	Cooldown:SetScript('OnCooldownDone', onCooldownDone)
	Cooldown:Hide()
	Button.Cooldown = Cooldown

	-- use a string parent that has a higher frame level than the cooldown to ensure
	-- text is not rendered below the cooldown
	local overlayParent = CreateFrame('Frame', '$parentText', Button)
	overlayParent:SetAllPoints() -- this frame needs a position and size for children to be rendered

	local HotKey = overlayParent:CreateFontString('$parentHotKey', 'ARTWORK', 'NumberFontNormalGray')
	HotKey:SetPoint('TOPRIGHT', -6, -6)
	HotKey:SetJustifyH('RIGHT')
	Button.HotKey = HotKey

	local Count = overlayParent:CreateFontString('$parentCount', 'ARTWORK', 'NumberFontNormal')
	Count:SetPoint('BOTTOMRIGHT', -6, 6)
	Count:SetJustifyH('RIGHT')
	Button.Count = Count

	-- TODO: cooldown renderes above all of the following textures, fix that
	local NormalTexture = Button:CreateTexture('$parentNormalTexture')
	NormalTexture:SetPoint('TOPLEFT')
	NormalTexture:SetSize(55, 54)
	NormalTexture:SetAtlas('UI-HUD-ActionBar-IconFrame')
	Button:SetNormalTexture(NormalTexture)

	local PushedTexture = Button:CreateTexture('$parentPushedTexture', 'OVERLAY')
	PushedTexture:SetPoint('TOPLEFT')
	PushedTexture:SetSize(55, 54)
	PushedTexture:SetAtlas('UI-HUD-ActionBar-IconFrame-Down')
	Button:SetPushedTexture(PushedTexture)

	local HighlightTexture = Button:CreateTexture('$parentHighlightTexture', 'OVERLAY')
	HighlightTexture:SetPoint('TOPLEFT')
	HighlightTexture:SetSize(54, 53)
	HighlightTexture:SetAtlas('UI-HUD-ActionBar-IconFrame-Mouseover')
	Button:SetHighlightTexture(HighlightTexture)

	local CheckedTexture = Button:CreateTexture('$parentCheckedTexture', 'OVERLAY')
	CheckedTexture:SetPoint('TOPLEFT')
	CheckedTexture:SetSize(54, 53)
	CheckedTexture:SetAtlas('UI-HUD-ActionBar-IconFrame-Mouseover')
	Button:SetCheckedTexture(CheckedTexture)

	if Button.QuickKeybindHighlightTexture then
		Button.QuickKeybindHighlightTexture:SetParent(overlayParent)
		Button.QuickKeybindHighlightTexture:ClearAllPoints()
		Button.QuickKeybindHighlightTexture:SetPoint('TOPLEFT')
		Button.QuickKeybindHighlightTexture:SetSize(54, 53)
	end

	if Masque then
		-- https://github.com/SFX-WoW/Masque/wiki/Group-API
		-- https://github.com/SFX-WoW/Masque/wiki/AddButton
		-- https://github.com/SFX-WoW/Masque/wiki/Regions
		Masque:Group(addonName, addonName):AddButton(Button, {
			-- Common
			Cooldown = Cooldown,
			Count = Count,
			Icon = Icon,
			Mask = Mask,
			Normal = NormalTexture,

			-- Action
			Checked = CheckedTexture,
			Highlight = HighlightTexture,
			HotKey = HotKey,
			Pushed = PushedTexture,
		})
	end

	return Button
end
