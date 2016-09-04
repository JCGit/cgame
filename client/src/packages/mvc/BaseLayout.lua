--[[
@author : jc
@log : 
@todo : 
1、BaseLayout的enableNodeEvents，resetWidgetText，onLocateClickCallback等方法，extend widget后重写。

]]

local BaseLayout = class("BaseLayout", ccui.Layout)

function BaseLayout:ctor(...)
    if self.onCreate then self:onCreate(...) end
end

function BaseLayout:createCSBNode(filename)
    local fileUtils = cc.FileUtils:getInstance()

    local f = function ()
        assert(fileUtils:isFileExist(filename), string.format('csb:%s not exists.', filename))

        if self.resourceNode_ then
            self.resourceNode_:removeSelf()
            self.resourceNode_ = nil
        end

        self.csbName_ = filename
        self.resourceNode_ = cc.CSLoader:createNode(filename)
        assert(self.resourceNode_, string.format("BaseLayout:createCSBNode load resouce node from file \"%s\" failed", filename))
        self:addChild(self.resourceNode_)
    
        self:enableNodeEvents()

        -- 重定向点击事件
        self:registerLayoutHandlers()

        --重设控件的文本
        self:resetWidgetText()
        return self.resourceNode_
    end

    local ok, r = xpcall(f, __G__TRACKBACK__)
    if not ok then
        print(r)
    end
end

function BaseLayout:enableNodeEvents()
    if self.isNodeEventEnabled_ then
        return self
    end

    self:registerScriptHandler( function(state)
        if state == "enter" and self.onEnter then
            self:onEnter()
        elseif state == "exit" then
            if self.onExit then
                self:onExit()
            end
            if self.onEnxitUnifiedCallBack then
                self:onEnxitUnifiedCallBack()
            end
        elseif state == "enterTransitionFinish" then
            if self.onEnterTransitionFinish then
                self:onEnterTransitionFinish()
            end
            if self.onEnterFinishUnifiedCallBack then
                self:onEnterFinishUnifiedCallBack()
            end
        elseif state == "exitTransitionStart" and self.onExitTransitionStart then
            self:onExitTransitionStart()
        elseif state == "cleanup" and self.onCleanup then
            self:onCleanup()
        end
    end )
    self.isNodeEventEnabled_ = true

    return self
end

function BaseLayout:disableNodeEvents()
    self:unregisterScriptHandler()
    self.isNodeEventEnabled_ = false
    return self
end

function BaseLayout:resetWidgetText()
    local getText = g.mgr.tablemgr.getTextByKey

    local widgetType = {
        WIDGET_BUTTON = 1,
        WIDGET_LABLE = 2,
        WIDGET_TEXTFIELD = 3,
    }

    local textReflect
    textReflect = function(node)

        local children = node:getChildren()
        for _, v in ipairs(children) do
            if v.getCustomProperty then
                local key = v:getCustomProperty()
                if key ~= '' then 
                    local langtext = getText(key)

                    local Type = v:getWidgetType()
                    if widgetType.WIDGET_BUTTON == Type then
                        v:setTitleText(langtext)
                    elseif widgetType.WIDGET_LABLE == Type then
                        v:setString(langtext)
                    elseif widgetType.WIDGET_TEXTFIELD == Type then
                        v:setString(langtext)   
                    end
                end
            end

            textReflect(v)
        end
    end

    textReflect(self.resourceNode_)
end

function BaseLayout:registerLayoutHandlers()

    if not self.option then 
        self.option = {}
    end

    if not self.option.handlerMap then
        self.option.handlerMap = {}
    end

    local handlers = self.option.handlerMap
    self.onDispatch = function(_func, _sender)

        local callback = handlers[_func]
        if not callback then
            logf("BaseLayout registerLayout find no handler,evtName:%s!", evtName)
        else
            local f =function()
                if self[callback] then
                    self[callback](self, _sender, _func)
                else
                    logf("BaseLayout registerLayout find no handler,callback:%s!", callback)
                end
            end
            
            local ok, r = xpcall(f, __G__TRACKBACK__)
            if not ok then
                print(r)
            end
        end
    end

    local cbReflect
    cbReflect = function (node)
        for _, v in ipairs(node:getChildren()) do
            if v.getCallbackName then
                tolua.cast(v, "ccui.Widget")

                local _func = v:getCallbackName()
                if _func and _func ~= "" then
                    handlers[_func] = _func

                    v:addClickEventListener(function (_sender)
                        -- 分发触摸事件

                        if _func == "onBack" then
                            g.mgr.soundMgr:playEffectSound("commonBack")
                        else
                            g.mgr.soundMgr:playEffectSound("commonClick")
                        end

                        self.onDispatch(_func, _sender)
                    end)
                end
            end

            if v:getChildrenCount() > 0 then
                cbReflect(v)
            end
        end
    end

    cbReflect(self)
end

function BaseLayout:getCsbName()
    return self.csbName_ or ""
end

function BaseLayout:getLayoutTag()
    local arr = string.split(self.csbName_, '/')
    local panel = string.split(arr[3], '.')[1]
    local tag = string.format("app.%s.%s.%s", arr[1], arr[2], panel)
    return tag
end

function BaseLayout:getChildByName(name)
    return self.resourceNode_:getChildByName(name)
end

function BaseLayout:getChildByTag(tag)
    return self.resourceNode_:getChildByTag(tag)
end

function BaseLayout:seekWidgetByName(name)
   return uihelper.seekWidgetByName(self.resourceNode_, name)
end

return BaseLayout