local BaseTips = require("packages.mvc.BaseTips")
local RichText = require("packages.ui.com.RichText")

local UINewsTicker = class("UINewsTicker", BaseTips)

UINewsTicker.textArray_ = {}
UINewsTicker.Panel_Bg_ = nil

UINewsTicker.instance_ = nil     --实例
UINewsTicker.moveSpeed_ = 300 --像素/每秒
UINewsTicker.bgSize_ = nil

function UINewsTicker:onCreate()

    self:createCSBNode("comm/UINewsTicker/UINewsTicker.csb")
    
    self.Panel_Bg_ = self.resourceNode_:getChildByName("Panel_Bg")
    self.bgSize_ = self.Panel_Bg_:getContentSize()
end

function UINewsTicker:showTicker(text)

    local function nextTicker()
        
        local str = self.textArray_[1]

        if nil == str then
            return
        end

        local bgWidth = self.instance_.bgSize_.width
        local bgHeight = self.instance_.bgSize_.height

        local params = {
	        fontSize = 30,
	        text = str
        }

        local label = RichText:create(params)
        label:setAnchorPoint(cc.p(0, 0.5))
        local labelSize = label:getLabelSize()
        label:setPosition(cc.p(bgWidth, bgHeight/2) )
        self.instance_.Panel_Bg_:addChild(label)
        local moveTime = (bgWidth + labelSize.width) / self.moveSpeed_

        local seq = cc.Sequence:create(cc.MoveBy:create(moveTime, cc.p(-1 * bgWidth - labelSize.width, 0)), 
                            cc.CallFunc:create(function (node, value)
                                            if self.textArray_[1] == nil then
                                                self.instance_:close()
                                                self.instance_ = nil
                                            else
                                                nextTicker()
                                            end
                                        end, {}))
        label:runAction(seq)
        table.remove(self.textArray_, 1)
    end

    table.insert(self.textArray_, text)

    if nil == self.instance_ then
        self.instance_ = self:create()
        self.instance_:open()

        nextTicker()
    end

end

function UINewsTicker:forceClose()

    if self.instance_ then
        self.instance_:close()
        self.instance_ = nil
        self.textArray_ = {}
    end
end

return UINewsTicker
