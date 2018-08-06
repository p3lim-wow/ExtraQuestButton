local addonName = ...
local defaults = {
	scale = 1,
	artwork = true,
}

local function printf(msg, ...)
	print(string.format('|cff33ff99%s:|r', addonName), string.format(msg, ...))
end

local buttonMixin = {}
function buttonMixin:OnDragStart()
	self:GetParent():StartMoving()
end

function buttonMixin:OnDragStop()
	self:GetParent():StopMovingOrSizing()
end

function buttonMixin:OnClick()
	ExtraQuestButtonDB.artwork = not ExtraQuestButtonDB.artwork
	self:GetParent():UpdateArtwork()

	printf('Artwork is now %s.', ExtraQuestButtonDB.artwork and 'shown' or 'hidden')
end

function buttonMixin:OnMouseWheel(delta)
	local scale = ExtraQuestButtonDB.scale
	if(delta > 0) then
		scale = scale + 0.1
	else
		scale = scale - 0.1
	end

	scale = math.floor((scale + 0.05) * 10) / 10
	scale = math.max(math.min(scale, 3), 0.2)

	if(scale ~= ExtraQuestButtonDB.scale) then
		ExtraQuestButtonDB.scale = scale
		self:GetParent():UpdateScale()

		printf('Scale is now %d%%.', scale * 100)
	end
end

function buttonMixin:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	GameTooltip:SetText(addonName, 1, 1, 1)
	GameTooltip:AddLine('|cff33ff99Drag|r to move')
	GameTooltip:AddLine('|cff33ff99Scroll|r to scale')
	GameTooltip:AddLine('|cff33ff99Right-click|r to toggle artwork')
	GameTooltip:Show()
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
		self:SetSize(52, 52) -- default ExtraActionButton1 size
		self:SetScript('OnShow', self.OnShow)
		self:SetScript('OnHide', self.OnHide)

		-- add overlapping button for the anchor that we'll parent textures to
		-- so that when we scale the points it won't "nudge" the anchor (see issue #15)
		local Button = CreateFrame('Button', nil, self)
		Button:SetSize(52, 52)
		Button:SetPoint('CENTER')
		Button:RegisterForDrag('LeftButton')
		Button:RegisterForClicks('RightButtonUp')
		Button:SetScript('OnEnter', buttonMixin.OnEnter)
		Button:SetScript('OnLeave', GameTooltip_Hide)
		Button:SetScript('OnDragStart', buttonMixin.OnDragStart)
		Button:SetScript('OnDragStop', buttonMixin.OnDragStop)
		Button:SetScript('OnClick', buttonMixin.OnClick)
		Button:SetScript('OnMouseWheel', buttonMixin.OnMouseWheel)
		self.Button = Button

		local Texture = Button:CreateTexture()
		Texture:SetPoint('CENTER')
		Texture:SetSize(self:GetSize())
		Texture:SetTexture([[Interface\Icons\INV_Misc_Wrench_01]])
		Texture:SetVertexColor(0, 2/3, 1/3)

		local Artwork = Button:CreateTexture(nil, 'OVERLAY')
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

		-- re-anchor/size buttons
		ExtraActionButton1:ClearAllPoints()
		ExtraActionButton1:SetPoint('CENTER', self)
		ExtraActionButton1:SetSize(self:GetSize())

		ExtraQuestButton:ClearAllPoints()
		ExtraQuestButton:SetPoint('CENTER', self)
		ExtraQuestButton:SetSize(self:GetSize())
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

function Anchor:UpdateScale()
	local scale = ExtraQuestButtonDB.scale
	self.Button:SetScale(scale)
	ExtraQuestButton:SetScale(scale)
	ExtraActionButton1:SetScale(scale)
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
