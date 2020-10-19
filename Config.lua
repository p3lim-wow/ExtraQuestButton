local addonName, ns = ...

local defaults = {
	scale = 1,
	artwork = true,
	position = {'CENTER', 0, -math.floor(select(2, GetPhysicalScreenSize()) / 3)}
}

local SavedVariables = Mixin(CreateFrame('Frame'), ns.mixins.EventHandler)
SavedVariables:OnLoad()
SavedVariables:RegisterEvent('ADDON_LOADED', function(self, addon)
	if addon ~= addonName then
		return
	end

	ExtraQuestButtonDB = ExtraQuestButtonDB or {}

	-- upgrade savedvariables
	for key, value in next, defaults do
		if ExtraQuestButtonDB[key] == nil then
			ExtraQuestButtonDB[key] = value
		end
	end

	return true
end)

_G['SLASH_' .. addonName .. '1'] = '/eqb'
_G['SLASH_' .. addonName .. '2'] = '/extraquestbutton'

SlashCmdList[addonName] = function(msg)
	local option, value = strsplit(' ', msg)
	option = option:lower()

	if option == 'reset' then
		for key, value in next, defaults do
			ExtraQuestButtonDB[key] = value
		end

		ExtraQuestButtonAnchor:ClearAllPoints()
		ExtraQuestButtonAnchor:Initialize()
	elseif option == 'unlock' or option == 'lock' then
		ExtraQuestButtonAnchor:Toggle()
	else
		ns:Print('Usage:')
		ns:Print('/eqb lock  - locks/unlocks position, scale and style')
		ns:Print('/eqb reset - resets position, scale and style')
	end
end
