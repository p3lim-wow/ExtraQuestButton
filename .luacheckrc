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
	'631', -- line is too long
}

exclude_files = {
}

globals = {
	-- savedvariables
	'ExtraQuestButtonDB3',
}

read_globals = {
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'ActionButtonUtil', -- FrameXML/ActionButtonUtil.lua
	'GameTooltip', -- ???
	'ItemMixin', -- FrameXML/ObjectAPI/Item.lua
	'QuickKeybindButtonTemplateMixin', -- FrameXML/QuickKeybind.lua
	'UIParent', -- FrameXML/UIParent.xml

	-- FrameXML functions
	'CopyTable', -- FrameXML/TableUtil.lua
	'GameTooltip_Hide', -- FrameXML/GameTooltip.lua
	'RegisterStateDriver', -- FrameXML/SecureStateDriver.lua
	'UnregisterStateDriver', -- FrameXML/SecureStateDriver.lua
	'nop', -- FrameXML/UIParent.lua

	-- FrameXML constants
	'RANGE_INDICATOR', -- FrameXML/ActionButton.lua

	-- SharedXML functions
	'FormatPercentage', -- SharedXML/FormattingUtil.lua
	'GetItemInfoFromHyperlink', -- SharedXML/LinkUtil.lua
	'KeybindFrames_InQuickKeybindMode', -- SharedXML/BindingUtil.lua
	'Mixin', -- SharedXML/Mixin.lua

	-- namespaces
	'C_CVar',
	'C_Item',
	'C_QuestLog',
	'C_Timer',

	-- API
	'CreateFrame',
	'GetBindingKey',
	'GetBindingText',
	'GetLocale',
	'GetQuestLogSpecialItemInfo',
	'GetTime',
	'InCombatLockdown',
	'QuestHasPOIInfo',
	'hooksecurefunc',

	-- exposed from other addons
	'LibStub',
}
