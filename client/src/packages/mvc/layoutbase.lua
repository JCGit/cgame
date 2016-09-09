--[[
@author : jc
@log : 
@todo : 
1、LayoutBase的enableNodeEvents，resetWidgetText，onLocateClickCallback等方法，extend widget后重写。

]]
local ccui_layout = ccui.layout
local lang_text = nil--g.mgr.tablemgr.getTextByKey
local layoutbase = class("layoutbase", ccui.Layout)

function layoutbase:ctor(...)
    if self.onCreate then self:onCreate(...) end
end

function layoutbase:createCSBNode(filename)
    local fileUtils = cc.FileUtils:getInstance()

    local f = function ()
        assert(fileUtils:isFileExist(filename), string.format('csb:%s not exists.', filename))

        if self._csbNode then
            self._csbNode:removeSelf()
            self._csbNode = nil
        end

        self._csbName = filename
        self._csbNode = cc.CSLoader:createNode(filename)
        assert(self._csbNode, string.format("layoutbase:createCSBNode load resouce node from file \"%s\" failed", filename))
        self:addChild(self._csbNode)
    
        self:enableNodeEvents()

        -- 重定向点击事件
        self:registerLayoutHandlers()

        --重设控件的文本
        self:resetWidgetText()
        return self._csbNode
    end

    local ok, r = xpcall(f, __G__TRACKBACK__)
    if not ok then
        print(r)
    end
end

function layoutbase:enableNodeEvents()
    if self.enableNodeEvent then
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
    self.enableNodeEvent = true

    return self
end

function layoutbase:disableNodeEvents()
    self:unregisterScriptHandler()
    self.enableNodeEvent = false
    return self
end

function layoutbase:resetWidgetText()

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
                    local langtext = lang_text(key)

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

    textReflect(self._csbNode)
end

function layoutbase:registerLayoutHandlers()

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
            logf("layoutbase registerLayout find no handler,evtName:%s!", evtName)
        else
            local f =function()
                if self[callback] then
                    self[callback](self, _sender, _func)
                else
                    logf("layoutbase registerLayout find no handler,callback:%s!", callback)
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

                        --[[ if _func == "onBack" then
                            g.mgr.soundMgr:playEffectSound("commonBack")
                        else
                            g.mgr.soundMgr:playEffectSound("commonClick")
                        end
                        ]] --
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

function layoutbase:getCsbName()
    return self._csbName or ""
end

function layoutbase:getLayoutTag()
    local arr = string.split(self._csbName, '/')
    local panel = string.split(arr[3], '.')[1]
    local tag = string.format("app.%s.%s.%s", arr[1], arr[2], panel)
    return tag
end

function layoutbase:getChildByName(name)
    return self._csbNode:getChildByName(name)
end

function layoutbase:getChildByTag(tag)
    return self._csbNode:getChildByTag(tag)
end

function layoutbase:seekWidgetByName(name)
   return uihelper.seekWidgetByName(self._csbNode, name)
end

return layoutbase