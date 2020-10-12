local _, ns = ...
ns.mixins = ns.mixins or {}

-- original event methods
local RegisterEvent = UIParent.RegisterEvent
local RegisterUnitEvent = UIParent.RegisterUnitEvent
local UnregisterEvent = UIParent.UnregisterEvent
local IsEventRegistered = UIParent.IsEventRegistered
local UnregisterAllEvents = UIParent.UnregisterAllEvents

local EventHandlerMixin = {}
function EventHandlerMixin:OnLoad()
	self:SetScript('OnEvent', self.TriggerEvent)
end

function EventHandlerMixin:RegisterEvent(event, callback)
	if not self.eventCallbacks then
		self.eventCallbacks = {}
	end
	if not self.eventCallbacks[event] then
		self.eventCallbacks[event] = {}
	end

	self.eventCallbacks[event][callback] = true

	if event:match('^UNIT_') then
		RegisterUnitEvent(self, event, 'player')
	else
		RegisterEvent(self, event)
	end
end

function EventHandlerMixin:UnregisterEvent(event, callback)
	if not self.eventCallbacks then
		self.eventCallbacks = {}
	end
	if not self.eventCallbacks[event] then
		self.eventCallbacks[event] = {}
	end

	self.eventCallbacks[event][callback] = nil

	local numEventCallbacks = 0
	for _ in next, self.eventCallbacks[event] do
		numEventCallbacks = numEventCallbacks + 1
	end

	if numEventCallbacks > 0 and IsEventRegistered(self, event) then
		UnregisterEvent(self, event)
	end
end

function EventHandlerMixin:TriggerEvent(event, ...)
	if self.eventCallbacks and self.eventCallbacks[event] then
		for callback in next, self.eventCallbacks[event] do
			if callback(self, ...) then
				-- any callback that returns true will unregister itself
				self:UnregisterEvent(event, callback)
			end
		end
	end
end

function EventHandlerMixin:UnregisterAllEvents()
	UnregisterAllEvents(self)

	table.wipe(self.eventCallbacks)
end

ns.mixins.EventHandler = EventHandlerMixin
