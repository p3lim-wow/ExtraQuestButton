std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'212/element', -- unused argument element
	'312/event', -- unused value of argument event
	'312/unit', -- unused value of argument unit
	'431', -- shadowing an upvalue
	'512', -- loop is executed only once
	'631', -- line is too long
}

globals = {
	-- savedvariables
	'ExtraQuestButtonDB3',
}

read_globals = {
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'ActionButtonUtil',
	'GameTooltip',
	'ItemMixin',
	'QuickKeybindButtonTemplateMixin',
	'UIParent',

	-- FrameXML functions
	'CopyTable',
	'FormatPercentage',
	'GameTooltip_Hide',
	'KeybindFrames_InQuickKeybindMode',
	'Mixin',
	'RegisterStateDriver', -- deprecated
	'UnregisterStateDriver', -- deprecated
	'GetItemInfoFromHyperlink',

	-- FrameXML constants
	'RANGE_INDICATOR',

	-- namespaces
	'C_Item',
	'C_QuestLog',
	'C_Timer',
	'C_UnitAuras',
	'Enum',

	-- API
	'CreateFrame',
	'GetBindingKey',
	'GetBindingText',
	'GetQuestLogSpecialItemInfo',
	'GetTime',
	'InCombatLockdown',
	'QuestHasPOIInfo',
	'UnitCreatureID',
	'hooksecurefunc',
	'issecretvalue',

	-- exposed from other addons
	'LibStub',
}
