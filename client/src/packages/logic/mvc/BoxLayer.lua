local BoxLayer = class("BoxLayer", cc.Layer)

function BoxLayer:ctor()
    
    local director = cc.Director:getInstance()
    local screenOrigin = director:getVisibleOrigin()
    local screenSize = director:getVisibleSize()

    self.container_ = ccui.Layout:create()
    self.container_:setContentSize(screenSize)
    self.container_:setPosition(screenOrigin)
    self.container_:setLocalZOrder(-1)
    self:addChild(self.container_)

    self.box_ = {}
end

function BoxLayer:add(layer)
    if layer and not layer:getParent() then
        local box_          = self.box_
        local index         = #box_
        if box_[index] and box_[index].cover then
            box_[index]:cover()
        end
        self.container_:addChild(layer)
        table.insert(box_, layer)
    end
end

function BoxLayer:addSystem(bar)
    self.container_:addChild(bar)
end

function BoxLayer:remove(layer)
    if not layer or not layer:getParent() then
        return
    end
    local box_      = self.box_
    local last      = #box_        
    for i,v in ipairs(box_) do
        if v == layer then
            if i == last then
                if box_[i - 1] and box_[i-1].refresh then
                    box_[i - 1]:refresh()
                end
            end
            table.remove(box_, i)
            layer:remove()
            break
        end
    end
end

function BoxLayer:clean()
    for i,v in ipairs(self.box_) do
        if v.clear then
            v:clear()
        end
        v:remove()
    end
    self.box_           = {}
end

function BoxLayer:checkOnTop(layer)
    if layer and layer:getParent() == self.container_ and #self.box_ > 0 then
        return self.box_[#self.box_-1] == layer
    end
    return false
end

return BoxLayer