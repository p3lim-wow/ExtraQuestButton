local addonName, ns = ...

_G['SLASH_' .. addonName .. '1'] = '/eqb'
_G['SLASH_' .. addonName .. '2'] = '/extraquestbutton'
SlashCmdList[addonName] = function(msg)
	local option, value = strsplit(' ', msg)
	option = option:lower()

	if option == 'reset' then
		-- TODO
		-- for key, value in next, defaults do
		-- 	ExtraQuestButtonDB[key] = value
		-- end

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
