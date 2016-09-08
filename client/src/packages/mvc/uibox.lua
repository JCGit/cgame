local cc_layer = cc.Layer

local uibox = class("uibox", cc_layer)

function uibox:ctor()
    
    local _director = cc.Director:getInstance()
    local _origin = _director:getVisibleOrigin()
    local _size = _director:getVisibleSize()

    local _container = ccui.Layout:create()
    _container:setContentSize(_size)
    _container:setPosition(_origin)
    _container:setLocalZOrder(-1)
    self:addChild(_container)

    self._container = _container
    self._box = {}
end

function uibox:add(layer)
    if layer and not layer:getParent() then
        local box          = self._box
        local idx         = #box

        if box[idx] and box[idx].cover then
            box[idx]:cover()
        end
        self._container:addChild(layer)
        table.insert(box, layer)
    end
end


function uibox:addSystem(bar)
    self._container:addChild(bar)
end


function uibox:remove(layer)
    if not layer or not layer:getParent() then
        return
    end
    local box      = self._box
    local last      = #box        
    for i,v in ipairs(box) do
        if v == layer then
            if i == last then
                if box[i - 1] and box[i-1].refresh then
                    box[i - 1]:refresh()
                end
            end
            table.remove(box, i)
            layer:remove()
            break
        end
    end
end


function uibox:clean()
    for i,v in ipairs(self._box) do
        if v.clear then
            v:clear()
        end
        v:remove()
    end
    self._box = {}
end


function uibox:checkOnTop(layer)
    local box = self._box

    if layer and layer:getParent() == self._container and #box > 0 then
        return box[#box-1] == layer
    end
    return false
end


return uibox