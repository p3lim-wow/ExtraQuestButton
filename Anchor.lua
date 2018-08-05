local addonName = ...
local defaults = {
	scale = 1,
	artwork = true,
}

local function printf(msg, ...)
	print(string.format('|cff33ff99%s:|r', addonName), string.format(msg, ...))
end

local Anchor = CreateFrame('Button', 'ExtraQuestButtonAnchor', UIParent)
Anchor:Hide()
Anchor:SetMovable(true)
Anchor:RegisterEvent('PLAYER_LOGIN')
Anchor:SetScript('OnEvent', function(self, event)
	if(event == 'PLAYER_LOGIN') then
		-- load savedvariables
		ExtraQuestButtonDB = ExtraQuestButtonDB or {}

		-- upgrade savedvariables
		for key, value in next, defaults do
			if(ExtraQuestButtonDB[key] == nil) then
				ExtraQuestButtonDB[key] = value
			end
		end

		-- init anchor
		self:EnableMouse(true)
		self:EnableMouseWheel(true)
		self:SetClampedToScreen(true)
		self:SetFrameStrata('HIGH')
		self:RegisterForDrag('LeftButton')
		self:RegisterForClicks('RightButtonUp')
		self:SetSize(ExtraActionButton1:GetSize())

		self:SetScript('OnShow', self.OnShow)
		self:SetScript('OnHide', self.OnHide)
		self:SetScript('OnEnter', self.OnEnter)
		self:SetScript('OnLeave', GameTooltip_Hide)
		self:SetScript('OnDragStart', self.OnDragStart)
		self:SetScript('OnDragStop', self.OnDragStop)
		self:SetScript('OnClick', self.OnClick)
		self:SetScript('OnMouseWheel', self.OnMouseWheel)

		local Texture = self:CreateTexture()
		Texture:SetAllPoints()
		Texture:SetColorTexture(0, 2/3, 1/3)

		local Artwork = self:CreateTexture(nil, 'OVERLAY')
		Artwork:SetPoint('CENTER', -2, 0)
		Artwork:SetSize(256, 128)
		Artwork:SetTexture([[Interface\ExtraButton\Default]])
		Artwork:SetVertexColor(0, 2/3, 1/3)
		self.Artwork = Artwork

		-- update anchor
		self:UpdateScale()
		self:UpdateArtwork()

		if(not self:GetPoint()) then
			self:SetPoint('BOTTOM', 0, 160)
		end

		-- re-anchor buttons
		ExtraActionButton1:ClearAllPoints()
		ExtraActionButton1:SetAllPoints(self)

		ExtraQuestButton:ClearAllPoints()
		ExtraQuestButton:SetAllPoints(self)
	elseif(event == 'PLAYER_REGEN_DISABLED') then
		self:Hide()
		self:StopMovingOrSizing() -- for good measure
		printf('Repositioning halted due to combat.')
	end
end)

function Anchor:OnShow()
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
end

function Anchor:OnHide()
	self:UnregisterEvent('PLAYER_REGEN_DISABLED')
end

function Anchor:OnDragStart()
	self:StartMoving()
end

function Anchor:OnDragStop()
	self:StopMovingOrSizing()
end

function Anchor:OnClick(button)
	ExtraQuestButtonDB.artwork = not ExtraQuestButtonDB.artwork
	self:UpdateArtwork()

	printf('Artwork is now %s.', ExtraQuestButtonDB.artwork and 'shown' or 'hidden')
end

function Anchor:OnMouseWheel(delta)
	local scale = ExtraQuestButtonDB.scale
	if(delta > 0) then
		scale = scale + 0.1
	else
		scale = scale - 0.1
	end

	ExtraQuestButtonDB.scale = math.max(math.min(scale, 3), 0)
	self:UpdateScale()

	printf('Scale is now %d%%.', ExtraQuestButtonDB.scale * 100)
end

function Anchor:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	GameTooltip:SetText(addonName, 1, 1, 1)
	GameTooltip:AddLine('|cff33ff99Drag|r to move')
	GameTooltip:AddLine('|cff33ff99Scroll|r to scale')
	GameTooltip:AddLine('|cff33ff99Right-click|r to toggle artwork')
	GameTooltip:Show()
end

function Anchor:UpdateScale()
	self:SetScale(ExtraQuestButtonDB.scale)
	ExtraActionButton1:SetScale(ExtraQuestButtonDB.scale)
end

function Anchor:UpdateArtwork()
	local state = ExtraQuestButtonDB.artwork
	self.Artwork:SetShown(state)
	ExtraQuestButton.Artwork:SetShown(state)
	ExtraActionButton1.style:SetShown(state)
end

function Anchor:Reset()
	for key, value in next, defaults do
		ExtraQuestButtonDB[key] = value
	end

	self:UpdateScale()
	self:UpdateArtwork()
	self:ClearAllPoints()
	self:SetPoint('BOTTOM', 0, 160)

	printf('Reset to default.')
end

function Anchor:Toggle()
	if(InCombatLockdown()) then
		printf('Cannot move during combat!')
	else
		self:SetShown(not self:IsShown())
		printf('Button is now %s.', self:IsShown() and 'unlocked' or 'locked')
	end
end

SLASH_ExtraQuestButton1 = '/eqb'
SLASH_ExtraQuestButton2 = '/extraquestbutton'
SlashCmdList.ExtraQuestButton = function(msg)
	local option, value = strsplit(' ', msg)
	option = option:lower()

	if(option == 'reset') then
		Anchor:Reset()
	elseif(option == 'unlock' or option == 'lock') then
		Anchor:Toggle()
	else
		printf('Usage:')
		printf('/eqb lock  - Locks/unlocks position')
		printf('/eqb reset - Resets position')
	end
end
