local BaseScene = class("BaseScene", cc.Scene)
local BoxLayer = import(".BoxLayer")

BaseScene.eLayerID ={
    ELAYER_GAME     = 0,		-- 场景层，战斗地图或背景ui
	ELAYER_WIDGET   = 1,		-- 场景部件层
	ELAYER_BOX      = 2,	    -- ui管理层
	ELAYER_POP      = 3,		-- 弹出层
    ELAYER_TIPS     = 4,        -- 广播层
    ELAYER_GUIDE    = 5,        -- 新手引导
	ELAYER_TOP      = 100,		-- 场景切换层 新手屏蔽层使用
}

function BaseScene:ctor(...)
    self:enableNodeEvents()

    self.viewSet            = {}

    self.clickEventMap      = {}
    setmetatable(self.clickEventMap, {__mode = "k"})
    self.touchEventMap      = {}
    setmetatable(self.touchEventMap, {__mode = "k"})

    self.listenerCount      = 0

    if self.onCreate then self:onCreate(...) end
end

function BaseScene:enableNodeEvents()
    if self.isNodeEventEnabled_ then
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
    self.isNodeEventEnabled_ = true

    return self
end

function BaseScene:createLayer(layerid)
    local layer  = nil
    if layerid == self.eLayerID.ELAYER_BOX then
        layer = BoxLayer:create()
    elseif layerid == self.eLayerID.ELAYER_TIPS then
        layer = BoxLayer:create()
        cc.Director:getInstance():setNotificationNode(layer)
    else
        layer = cc.Layer:create()
    end
    return layer
end

function BaseScene:removeLayer(layerid)
    
end

function BaseScene:getLayerZOrder(layerid)
    return layerid
end

function BaseScene:getLayer(layerid)
    return self:getChildByTag(layerid)
end

function BaseScene:addLayer(layerid)

    local _child = self:getLayer(layerid)
    if not _child then

        local _layer = self:createLayer(layerid)
        assert(_layer, string.format("BaseScene createLayer layer:%d error.", layerid))

        local zorder = self:getLayerZOrder(layerid)
        if self.eLayerID.ELAYER_TIPS == layerid then
            _layer:removeFromParent()
        end
        self:addChild(_layer, zorder, layerid)
        return _layer
    end
    return _child
end


function BaseScene:setView(view , isStore)
    self.viewSet[view.__cname]      = isStore and view or nil
end

function BaseScene:getViewByViewName(viewName)
    assert(type(viewName) == "string" , " viewName type is wrong")
    return self.viewSet[viewName]
end

function BaseScene:setStoreClickEvent(widget , event)
    self.listenerCount      = self.listenerCount + 1
    --print("setStoreClickEvent" , self.listenerCount , self.__cname)
    self.clickEventMap[widget]      = event
end

function BaseScene:getClickEvent(widget )
    return self.clickEventMap[widget]
end

function BaseScene:setStoreTouchEvent(widget ,event)
    self.listenerCount      = self.listenerCount + 1
    --print("setStoreTouchEvent" , self.listenerCount , self.__cname)
    self.touchEventMap[widget]      = event

end

function BaseScene:getTouchEvent(widget)
    return self.touchEventMap[widget]
end

function BaseScene:getSceneID()
    return self.sceneID_ or 0
end

return BaseScene