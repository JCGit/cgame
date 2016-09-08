
local BaseProxy = class("BaseProxy")

function BaseProxy:ctor()

    if self.onCreate then self:onCreate() end
end

function BaseProxy:destroy()
	if self.onDestroy then self:onDestroy() end
end

function BaseProxy:doResp( )
    -- body
end

function BaseProxy:onEnter()
	-- body
end

function BaseProxy:onExit()
	-- body
end

return BaseProxy