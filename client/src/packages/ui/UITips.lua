local BaseTips = require("packages.mvc.BaseTips")
local RichText = require("packages.ui.com.RichText")

local UITips = class("UITips", BaseTips)

UITips.textCount_ = 0

UITips.instance_ = nil     --实例
UITips.moveTime_       = 1
UITips.moveDistance_ = 300 --上飘距离

function UITips:onCreate()

    self:createCSBNode("comm/UITips/UITips.csb")
end

function UITips:showTip(_text)

    self.textCount_ = self.textCount_ + 1

    if nil == self.instance_ then
        self.instance_ = self:create()
        self.instance_:open()
    end

    local function moveEnd(node, value)

        node:removeFromParent()

        if self.textCount_ == node:getTag() then
            self.instance_:close()
            self.instance_ = nil
            self.textCount_ = 0
        end
    end

    local params = {
	    fontSize = 30,
	    text = _text,
        bCenter = true,
    }

    local winSize = cc.Director:getInstance():getWinSize()
    local label = RichText:create(params)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setTag(self.textCount_)
    label:setPosition(cc.p(winSize.width/2, winSize.height/2))
    self.instance_.resourceNode_:addChild(label)
    label:runAction(cc.Sequence:create(cc.JumpBy:create(self.moveTime_, cc.p(0, self.moveDistance_), 100, 1), cc.CallFunc:create(moveEnd, {})) )
end

function UITips:forceClose(args)

    if self.instance_ then
        self.instance_:close()
        self.instance_ = nil
        self.textCount_ = 0
    end
end


return UITips