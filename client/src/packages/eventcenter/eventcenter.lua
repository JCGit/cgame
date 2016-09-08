
local EventCenter = class("EventCenter")

function EventCenter:ctor()

	cc.bind(self, "event")
end

function EventCenter:dispatch(name, param)
	local event = {}
	event.name = name
	event.param = param
	self:dispatchEvent(event)
end	

return EventCenter