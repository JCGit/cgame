
local proxybase = class("proxybase")

function proxybase:ctor()

    if self.onCreate then self:onCreate() end
end

function proxybase:destroy()
	if self.onDestroy then self:onDestroy() end
end

function proxybase:doResp( )
    -- body
end

function proxybase:onEnter()
	-- body
end

function proxybase:onExit()
	-- body
end

return proxybase