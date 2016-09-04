
local EventCore = class("EventCore")

function EventCore:ctor()

	cc.bind(self, "event")
end

function EventCore:dispatch(name, param)
	local event = {}
	event.name = name
	event.param = param
	self:dispatchEvent(event)
end	

return EventCore