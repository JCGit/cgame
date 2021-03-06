local layoutbase = import(".layoutbase")
local scenebase = import(".scenebase")
local panelbase = class("panelbase", layoutbase)

function panelbase:onEnterTransitionFinish()

    self._curOpened = true

    self:setContentSize(display.size)
end

function panelbase:onExit()
    self._curOpened = false
end

function panelbase:onEnterFinishUnifiedCallBack()
    --print("onEnterFinishUnifiedCallBack",self.__cname)
    g.eventcenter:dispatch(g.mainEvent.onShowView , self.__cname)
end

function panelbase:onEnxitUnifiedCallBack()
    --print("onEnxitUnifiedCallBack",self.__cname)
    g.eventcenter:dispatch(g.mainEvent.onExitView , self.__cname)
end


function panelbase:open(...)

    if self._curOpened then return end

    local params = {...}
    local scene = params[1]
    if scene then
        local box = scene:getUiBox()
        assert(box, "panelbase:open ui, no box-layer.")

        self:setTouchEnabled(true)

        box:add(self)
        self._scene = scene
    else
        g.logger.w("panelbase.open no target scene.")
    end
end

function panelbase:close()

    if not self._curOpened then return end
    local scene = self._scene

    local box = scene:getUiBox()
    assert(box, "panelbase:close ui, no box-layer.")

    if self.clear then
        self:clear()
    end

    box:remove(self)
end

function panelbase:remove()
    local sceneManager      = g.mgr.scenemgr
    local scene         = sceneManager:getCurScene()
    scene:setView(self , false)
    self:removeFromParent()
end

function panelbase:refresh()
    -- body
end

function panelbase:cover()
    -- body
end

function panelbase:getIsOpen()
    return self._curOpened or false
end

function panelbase:enableCover(bClickClose, callBack)
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

return panelbase
