--
-- Author: Kite Hu
-- Date: 2016-08-04 19:28:20
--

local ImageView     = ccui.ImageView

if ImageView.isExtend then return end

local mt        = getmetatable(ImageView)
local mt2       = getmetatable(mt)
mt2.addTouchEventListenerForLua         = mt2.addTouchEventListener
mt2.addTouchEventListener       = function( widget , callback )
    local scene 						= g.mgr.scenemgr:getCurScene()
    scene:setStoreTouchEvent(widget ,callback)
    widget:addTouchEventListenerForLua(callback)
end

mt2.addClickEventListenerForLua         = mt2.addClickEventListener
mt2.addClickEventListener               = function( widget ,callback )
    local scene 						= g.mgr.scenemgr:getCurScene()
    scene:setStoreClickEvent(widget , callback)
    widget:addClickEventListenerForLua(callback)
end

ImageView.isExtend = true
