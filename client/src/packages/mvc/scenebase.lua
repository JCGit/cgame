local scenebase = class("scenebase", function()
    return display.newScene("scenebase")
end)

local eLayerID ={
    ELAYER_GAME     = 0,		-- 场景层，战斗地图或背景ui
	ELAYER_WIDGET   = 1,		-- 场景部件层
	ELAYER_BOX      = 2,	    -- ui管理层
	ELAYER_POP      = 3,		-- 弹出层
    ELAYER_TIPS     = 4,        -- 广播层
    ELAYER_GUIDE    = 5,        -- 新手引导
	ELAYER_TOP      = 100,		-- 场景切换层 新手屏蔽层使用
}

function scenebase:ctor(...)

    if self.onCreate then self:onCreate(...) end
end

function scenebase:createLayer(layerid)
    local layer

    if layerid == self.eLayerID.ELAYER_BOX then
    elseif layerid == self.eLayerID.ELAYER_TIPS then
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
        self:addChild(layer, zorder, layerid)

        return layer
    end
    return child
end

function scenebase:getSceneID()
    return self.sceneID_ or 0
end

return scenebase