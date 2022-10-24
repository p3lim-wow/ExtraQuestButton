local addonName, ns = ...
local L = ns.L

local function CreateOptions()
	CreateOptions = nop -- we only want to load this once

	LibStub('AceConfig-3.0'):RegisterOptionsTable(addonName, {
		type = 'group',
		get = function(info)
			return ns.db.profile[info[#info]]
		end,
		set = function(info, value)
			ns.db.profile[info[#info]] = value

			-- update state
			ExtraQuestButton:UpdateState()
		end,
		args = {
			trackingOnly = {
				order = 1,
				name = L['Only show for tracked quests'],
				type = 'toggle',
				width = 'double',
			},
			zoneOnly = {
				order = 2,
				name = L['Only show for quests in current zone'],
				type = 'toggle',
				width = 'double',
			},
			distanceYd = {
				order = 3,
				name = L['Distance in yards how far away the quest can be'],
				type = 'range',
				min = 5,
				max = 1e4,
				step = 1,
				width = 'double',
			},
			activate = {
				order = 5,
				name = L['Activate on button press'],
				type = 'select',
				values = {
					UP = L['Up'],
					DOWN = L['Down'],
					BOTH = L['Both'],
				},
				disabled = InCombatLockdown,
				width = 'double',
			},
		},
	})

	LibStub('AceConfigDialog-3.0'):AddToBlizOptions(addonName)
end

InterfaceOptionsFrameAddOns:HookScript('OnShow', function()
	CreateOptions() -- LoD

	-- we load too late, so we have to manually refresh the list
	InterfaceAddOnsList_Update()
end)

_G['SLASH_' .. addonName .. '1'] = '/eqb'
_G['SLASH_' .. addonName .. '2'] = '/extraquestbutton'
SlashCmdList[addonName] = function(msg)
	local option = msg:lower()

	if option == 'reset' then
		ns.db:ResetProfile()

		ExtraQuestButtonAnchor:ClearAllPoints()
		ExtraQuestButtonAnchor:Initialize()
	elseif option == 'unlock' or option == 'lock' then
		ExtraQuestButtonAnchor:Toggle()
	elseif option == 'config' then
		CreateOptions() -- LoD

		InterfaceOptionsFrame_OpenToCategory(addonName)
		InterfaceOptionsFrame_OpenToCategory(addonName) -- load twice due to an old bug
	else
		ns:Print('Usage:')
		ns:Print('/eqb lock   - locks/unlocks position, scale and style')
		ns:Print('/eqb reset  - resets position, scale and style')
		ns:Print('/eqb config - opens up options panel')
	end
end
