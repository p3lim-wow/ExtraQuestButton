local addonName, ns = ...

local defaults = {
	profile = {
		scale = 1,
		artwork = true,
		position = {'CENTER', 0, -math.floor(select(2, GetPhysicalScreenSize()) / 3)},
		trackingOnly = false,
	}
}

local EventHandler = Mixin(CreateFrame('Frame'), ns.mixins.EventHandler)
EventHandler:OnLoad()
EventHandler:RegisterEvent('ADDON_LOADED', function(self, addon)
	if addon == addonName then
		ns.db = LibStub('AceDB-3.0'):New('ExtraQuestButtonDB2', defaults, true)

		-- migrate old db
		if ExtraQuestButtonDB then
			ns.db.profile.scale = ExtraQuestButtonDB.scale
			ns.db.profile.artwork = ExtraQuestButtonDB.artwork
			if ExtraQuestButtonDB.position and ExtraQuestButtonDB.position[1] then
				ns.db.profile.position = ExtraQuestButtonDB.position
			end
			ExtraQuestButtonDB = nil
		end

		return true
	end
end)
