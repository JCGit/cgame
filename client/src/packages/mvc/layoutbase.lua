local layoutbase = class("layoutbase", function ()
    return display.newLayer()    
end)

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
    
        -- 重定向点击事件
        self:registerLayoutHandlers()
        return self._csbNode
    end

    local ok, r = xpcall(f, __G__TRACKBACK__)
    if not ok then
        print(r)
    end
end

function layoutbase:registerLayoutHandlers()

    if not self.option then 
        self.option = {}
    end

    if not self.option.handlerMap then
        self.option.handlerMap = {}
    end

    local handlers = self.option.handlerMap
    self.onDispatch = function(cb, _sender)

        local callback = handlers[cb]
        if callback then
            local f =function()
                if self[callback] then
                    self[callback](self, _sender, cb)
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

                local cb = v:getCallbackName()
                if cb and cb ~= "" then
                    handlers[cb] = cb

                    v:addClickEventListener(function (_sender)
                        -- 分发触摸事件
                        self.onDispatch(cb, _sender)
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

function layoutbase:getChildByName(name)
    return self._csbNode:getChildByName(name)
end

function layoutbase:getChildByTag(tag)
    return self._csbNode:getChildByTag(tag)
end

return layoutbase