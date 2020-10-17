local addonName, ns = ...
ns.mixins = ns.mixins or {}

local AnchorMixin = {}
function AnchorMixin:OnLoad()
	-- trigger inherited loaders
	ns.mixins.EventHandler.OnLoad(self)
	ns.mixins.QuestButton.OnLoad(self)

	-- add handlers
	self:SetScript('OnDragStart', self.OnDragStart)
	self:SetScript('OnDragStop', self.OnDragStop)
	self:SetScript('OnMouseWheel', self.OnMouseWheel)
	self:SetScript('OnEnter', self.UpdateTooltip)
	self:SetScript('OnLeave', GameTooltip_Hide)
	self:SetScript('OnClick', self.OnClick)

	self:SetMovable(true)
	self:EnableMouse(true)
	self:EnableMouseWheel(true)
	self:SetClampedToScreen(true)
	self:SetFrameStrata('HIGH')
	self:RegisterForDrag('LeftButton')
	self:RegisterForClicks('RightButtonUp')
	self:Hide()

	-- disable default handlers
	self:SetScript('PostClick', nil)
	self:UnregisterAllEvents()

	-- stylize
	self:SetTexture([[Interface\Icons\INV_Misc_Wrench_01]])
	self.Texture:SetVertexColor(2/5, 1, 2/5)
	self.Artwork:SetVertexColor(2/5, 1, 2/5)

	self:RegisterEvent('PLAYER_REGEN_DISABLED', self.UpdateCombat)
	self:RegisterEvent('PLAYER_LOGIN', self.Initialize)
end

function AnchorMixin:Initialize()
	if not self:GetPoint() then
		-- set default position
		self:SetPoint(unpack(ExtraQuestButtonDB.position))
	end

	self:UpdateScale()
	self:UpdateArtwork()

	return true
end

function AnchorMixin:OnDragStart()
	self:StartMoving(true)
end

function AnchorMixin:OnDragStop()
	self:StopMovingOrSizing()
	ExtraQuestButtonDB.position = {self:GetPoint()}
end

function AnchorMixin:OnMouseWheel(delta)
	local scale = ExtraQuestButtonDB.scale
	if delta > 0 then
		scale = scale + 0.1
	else
		scale = scale - 0.1
	end

	scale = math.floor((scale + 0.05) * 10) / 10
	scale = math.max(math.min(scale, 3), 0.2)

	if scale ~= ExtraQuestButtonDB.scale then
		ExtraQuestButtonDB.scale = scale

		self:UpdateScale()
		self:UpdateTooltip()
	end
end

function AnchorMixin:OnClick()
	ExtraQuestButtonDB.artwork = not ExtraQuestButtonDB.artwork

	self:UpdateArtwork()
end

function AnchorMixin:UpdateTooltip()
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	GameTooltip:SetText(addonName, 1, 1, 1)
	GameTooltip:AddLine('|cff33ff99Drag|r to move')
	GameTooltip:AddLine(string.format('|cff33ff99Scroll|r to scale (%d%%)', ExtraQuestButtonDB.scale))
	GameTooltip:AddLine('|cff33ff99Right-click|r to toggle background')
	GameTooltip:Show()
end

function AnchorMixin:UpdateScale()
	self:SetScale(ExtraQuestButtonDB.scale)
	ExtraQuestButton:SetScale(ExtraQuestButtonDB.scale)
end

function AnchorMixin:UpdateArtwork()
	self.Artwork:SetShown(ExtraQuestButtonDB.artwork)
	ExtraQuestButton.Artwork:SetShown(ExtraQuestButtonDB.artwork)
end

function AnchorMixin:UpdateCombat()
	if InCombatLockdown() and self:IsShown() then
		self:Hide()
		self:StopMovingOrSizing() -- for good measure
		ns:Print('Repositioning halted due to combat.')
	end
end

function AnchorMixin:Toggle()
	if not InCombatLockdown() then
		self:SetShown(not self:IsShown())
	end
end

ns.mixins.Anchor = AnchorMixin
