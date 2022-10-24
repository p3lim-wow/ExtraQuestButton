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
	-- FrameXML objects we mutate
	'SlashCmdList', -- FrameXML/ChatFrame.lua

	-- savedvariables
	'ExtraQuestButtonDB',

	-- binding constants
	'BINDING_HEADER_EXTRAQUESTBUTTON',
	'BINDING_NAME_EXTRAQUESTBUTTON',
}

read_globals = {
	string = {fields = {'split'}},
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'UIParent', -- FrameXML/UIParent.xml
	'GameTooltip', -- ???
	'ItemMixin', -- FrameXML/ObjectAPI/Item.lua
	'ActionButtonUtil', -- FrameXML/ActionButtonUtil.lua
	'QuickKeybindButtonTemplateMixin', -- FrameXML/QuickKeybind.lua

	'InterfaceOptionsFrameAddOns', -- OLD

	-- FrameXML functions
	'nop', -- FrameXML/UIParent.lua
	'GameTooltip_Hide', -- FrameXML/GameTooltip.lua
	'RegisterStateDriver', -- FrameXML/SecureStateDriver.lua
	'UnregisterStateDriver', -- FrameXML/SecureStateDriver.lua

	'InterfaceAddOnsList_Update', -- OLD
	'InterfaceOptionsFrame_OpenToCategory', -- OLD

	-- FrameXML constants
	'RANGE_INDICATOR', -- FrameXML/ActionButton.lua

	-- SharedXML objects
	'Settings', -- SharedXML/Settings/Blizzard_Settings.lua
	'SettingsPanel', -- SharedXML/Settings/Blizzard_SettingsPanel.xml

	-- SharedXML functions
	'Mixin', -- SharedXML/Mixin.lua
	'GetItemInfoFromHyperlink', -- SharedXML/LinkUtil.lua
	'KeybindFrames_InQuickKeybindMode', -- SharedXML/BindingUtil.lua

	-- namespaces
	'C_QuestLog',
	'C_Timer',

	-- API
	'hooksecurefunc',
	'CreateFrame',
	'GetBindingKey',
	'GetBindingText',
	'GetBuildInfo',
	'GetItemCooldown',
	'GetItemCount',
	'GetItemInfo',
	'GetLocale',
	'GetPhysicalScreenSize',
	'GetQuestLogSpecialItemInfo',
	'GetTime',
	'InCombatLockdown',
	'IsCurrentItem',
	'IsItemInRange',
	'ItemHasRange',
	'QuestHasPOIInfo',
	'UnitGUID',

	-- exposed globals
	'ExtraQuestButton',
	'ExtraQuestButtonAnchor',

	-- exposed from other addons
	'LibStub',
}
