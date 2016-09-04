local BaseLayout = import(".BaseLayout")
local BaseScene = import(".BaseScene")
local BasePanel = class("BasePanel", BaseLayout)


function BasePanel:onEnterTransitionFinish()

    self.curOpenning_ = true

    self:setContentSize(display.size)
end

function BasePanel:onExit()
    self.curOpenning_ = false
end

function BasePanel:onEnterFinishUnifiedCallBack()
    --print("onEnterFinishUnifiedCallBack",self.__cname)
    g.eventcore:dispatch(g.mainEvent.onShowView , self.__cname)
end

function BasePanel:onEnxitUnifiedCallBack()
    --print("onEnxitUnifiedCallBack",self.__cname)
    g.eventcore:dispatch(g.mainEvent.onExitView , self.__cname)
end


function BasePanel:open()
    if self.curOpenning_ then return end
    local sceneManager      = g.mgr.scenemgr
    local scene         = sceneManager:getCurScene()

    if scene:getViewByViewName(self.__cname) then
        --print("\n")
        --logw(string.format("\n---------------------------------------------------------\nthe view is already exist %s\n---------------------------------------------------------\n",self.__cname ))
        return
    end

    local box = scene:getChildByTag(BaseScene.eLayerID.ELAYER_BOX)
    assert(box, "BasePanel:open ui, no box-layer.")

    self:setTouchEnabled(true)

    scene:setView(self , true)

    box:add(self)
end

function BasePanel:close()

    if not self.curOpenning_ then return end
    local sceneManager      = g.mgr.scenemgr
    local scene         = sceneManager:getCurScene()

    if not scene:getViewByViewName(self.__cname) then
        --print("\n")
        --logw(string.format("\n---------------------------------------------------------\nthe view is not  exist %s\n---------------------------------------------------------\n",self.__cname ))
        return
    end

    local box = scene:getChildByTag(BaseScene.eLayerID.ELAYER_BOX)
    assert(box, "BasePanel:close ui, no box-layer.")

    if self.clear then
        self:clear()
    end

    box:remove(self)
end

function BasePanel:remove()
    local sceneManager      = g.mgr.scenemgr
    local scene         = sceneManager:getCurScene()
    scene:setView(self , false)
    self:removeFromParent()
end

function BasePanel:refresh()
    -- body
end

function BasePanel:cover()
    -- body
end

function BasePanel:getIsOpen()
    return self.curOpenning_ or false
end

function BasePanel:enableCover(bClickClose, callBack)
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

return BasePanel
