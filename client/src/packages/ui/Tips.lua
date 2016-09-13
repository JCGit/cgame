
local BasePanel = import(".BasePanel")
local BaseScene = import(".BaseScene")
local BaseTips = class("BaseTips", BasePanel)

function BaseTips:onEnterTransitionFinish()

    self.curOpenning_ = true

    -- self:setPosition(cc.p(display.c_left, display.c_bottom))
    self:setContentSize(display.size)
end

function BaseTips:open()
    if self.curOpenning_ then return end

    local director = cc.Director:getInstance()
    local scene = director:getRunningScene()

    tolua.cast(scene, "BaseScene")
    local tip = scene:getChildByTag(BaseScene.eLayerID.ELAYER_TIPS)
    assert(tip, "BaseTips:open ui, no tips-layer.")
    tip:addChild(self)
end

function BaseTips:close() 
    self:removeFromParent()    
end

-- function BaseTips:remove()
--     self:
-- end

function BaseTips:enableCover(bClickClose, callBack)
    self:setTouchEnabled(true)
    self:setBackGroundColorType(LAYOUT_COLOR_SOLID)
    self:setBackGroundColor(cc.c3b(0,0,0))
    self:setBackGroundColorOpacity(150)

    if bClickClose then
        self:addClickEventListener(function(self)
            if callBack then
                callBack()
            end
        end)
    end
end

return BaseTips
