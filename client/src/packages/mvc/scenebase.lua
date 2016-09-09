local scenebase = class("scenebase", cc.Scene)
local uibox = import(".uibox")

scenebase.eLayerID ={
    ELAYER_GAME     = 0,		-- 场景层，战斗地图或背景ui
	ELAYER_WIDGET   = 1,		-- 场景部件层
	ELAYER_BOX      = 2,	    -- ui管理层
	ELAYER_POP      = 3,		-- 弹出层
    ELAYER_TIPS     = 4,        -- 广播层
    ELAYER_GUIDE    = 5,        -- 新手引导
	ELAYER_TOP      = 100,		-- 场景切换层 新手屏蔽层使用
}

function scenebase:ctor(...)
    self:enableNodeEvents()

    self._viewSet            = {}

    self._clickEventMap      = {}
    setmetatable(self._clickEventMap, {__mode = "k"})
    self._touchEventMap      = {}
    setmetatable(self._touchEventMap, {__mode = "k"})

    self._listenerCount      = 0

    if self.onCreate then self:onCreate(...) end
end

function scenebase:enableNodeEvents()
    if self._enableNodeEvent then
        return self
    end

    self:registerScriptHandler( function(state)
        if state == "enter" and self.onEnter then
            self:onEnter()
        elseif state == "exit" and self.onExit then
            self:onExit()
        elseif state == "enterTransitionFinish" and self.onEnterTransitionFinish then
            self:onEnterTransitionFinish()
        elseif state == "exitTransitionStart" and self.onExitTransitionStart then
            self:onExitTransitionStart()
        elseif state == "cleanup" and self.onCleanup then
            self:onCleanup()
        end
    end )
    self._enableNodeEvent = true

    return self
end

function scenebase:createLayer(layerid)
    local layer  = nil
    if layerid == self.eLayerID.ELAYER_BOX then
        layer = uibox:create()
    elseif layerid == self.eLayerID.ELAYER_TIPS then
        layer = uibox:create()
        cc.Director:getInstance():setNotificationNode(layer)
    else
        layer = cc.Layer:create()
    end
    return layer
end

function scenebase:removeLayer(layerid)
    
end

function scenebase:getLayerZOrder(layerid)
    return layerid
end

function scenebase:getLayer(layerid)
    return self:getChildByTag(layerid)
end

function scenebase:addLayer(layerid)

    local child = self:getLayer(layerid)
    if not child then

        local layer = self:createLayer(layerid)
        assert(layer, string.format("scenebase createLayer layer:%d error.", layerid))

        local zorder = self:getLayerZOrder(layerid)
        if self.eLayerID.ELAYER_TIPS == layerid then
            layer:removeFromParent()
        end
        self:addChild(layer, zorder, layerid)
        return layer
    end
    return child
end


function scenebase:setView(view , isStore)
    self._viewSet[view.__cname]      = isStore and view or nil
end

function scenebase:getViewByViewName(viewName)
    assert(type(viewName) == "string" , " viewName type is wrong")
    return self._viewSet[viewName]
end

function scenebase:setStoreClickEvent(widget , event)
    self._listenerCount      = self._listenerCount + 1
    --print("setStoreClickEvent" , self._listenerCount , self.__cname)
    self._clickEventMap[widget]      = event
end

function scenebase:getClickEvent(widget )
    return self._clickEventMap[widget]
end

function scenebase:setStoreTouchEvent(widget ,event)
    self._listenerCount      = self._listenerCount + 1
    --print("setStoreTouchEvent" , self._listenerCount , self.__cname)
    self._touchEventMap[widget]      = event

end

function scenebase:getTouchEvent(widget)
    return self._touchEventMap[widget]
end

function scenebase:getSceneID()
    return self.sceneID_ or 0
end

return scenebase