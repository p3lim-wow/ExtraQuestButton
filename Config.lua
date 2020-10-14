local addonName, ns = ...

local defaults = {
	scale = 1,
	artwork = true,
	copyBindings = true,
}

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('ADDON_LOADED')
Handler:SetScript('OnEvent', function(self, event, addon)
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

	self:UnregisterEvent(event)
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
	elseif option == 'binding' then
		if InCombatLockdown() then
			ns:Print('Can\'t do that while in combat')
			return
		end

		ExtraQuestButtonDB.copyBindings = not ExtraQuestButtonDB.copyBindings
		ExtraQuestButton:UpdateBinding()

		if ExtraQuestButtonDB.copyBindings then
			ns:Print('Now using same binding as ExtraActionButton')
		else
			ns:Print('Now using separate binding')
		end
	else
		ns:Print('Usage:')
		ns:Print('/eqb lock    - locks/unlocks position')
		ns:Print('/eqb reset   - resets position, scale and style')
		ns:Print('/eqb binding - toggles shared/separate binding')
	end
end
