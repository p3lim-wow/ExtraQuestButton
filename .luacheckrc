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
	-- FrameXML objects
	'UIParent', -- FrameXML/UIParent.xml
	'GameTooltip', -- ???
	'ItemMixin', -- FrameXML/ObjectAPI/Item.lua
	'ActionButtonUtil', -- FrameXML/ActionButtonUtil.lua
	'QuickKeybindButtonTemplateMixin', -- FrameXML/QuickKeybind.lua

	-- FrameXML functions
	'nop', -- FrameXML/UIParent.lua
	'GameTooltip_Hide', -- FrameXML/GameTooltip.lua
	'RegisterStateDriver', -- FrameXML/SecureStateDriver.lua
	'UnregisterStateDriver', -- FrameXML/SecureStateDriver.lua
	'CopyTable', -- FrameXML/TableUtil.lua 

	-- FrameXML constants
	'RANGE_INDICATOR', -- FrameXML/ActionButton.lua

	-- SharedXML functions
	'Mixin', -- SharedXML/Mixin.lua
	'GetItemInfoFromHyperlink', -- SharedXML/LinkUtil.lua
	'KeybindFrames_InQuickKeybindMode', -- SharedXML/BindingUtil.lua
	'FormatPercentage', -- SharedXML/FormattingUtil.lua

	-- namespaces
	'C_QuestLog',
	'C_Timer',
	'C_CVar',

	-- API
	'hooksecurefunc',
	'CreateFrame',
	'GetBindingKey',
	'GetBindingText',
	'GetItemCooldown',
	'GetItemCount',
	'GetItemInfo',
	'GetLocale',
	'GetQuestLogSpecialItemInfo',
	'GetTime',
	'InCombatLockdown',
	'IsCurrentItem',
	'IsItemInRange',
	'ItemHasRange',
	'QuestHasPOIInfo',

	-- exposed from other addons
	'LibStub',
}
