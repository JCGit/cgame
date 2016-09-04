--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local BasePanel = require("packages.mvc.BasePanel")
local BaseScene = require("packages.mvc.BaseScene")
local ConfirmDialog = class("ConfirmDialog", BasePanel)

ConfirmDialog.Image_Bg_ = nil
ConfirmDialog.Text_Content_ = nil
ConfirmDialog.Button_Cancel_ = nil
ConfirmDialog.Button_Ok_ = nil
ConfirmDialog.callBack_ = nil
ConfirmDialog.Button_Close = nil

function ConfirmDialog:onCreate()
    self:enableCover(true)

    self:createCSBNode("comm/ConfirmDialog/ConfirmDialog.csb")
    
    self.Image_Bg_ = self.resourceNode_:getChildByName("Image_Bg")
    self.Text_Content_ = self.Image_Bg_:getChildByName("Text_Content")
    self.Button_Cancel_ = self.Image_Bg_:getChildByName("Button_Cancel")
    self.Button_Ok_ = self.Image_Bg_:getChildByName("Button_Ok")
    self.Button_Close_ = self.Image_Bg_:getChildByName("Button_Close")
    
    local winSize = cc.Director:getInstance():getWinSize()
    self.Image_Bg_:setPosition(cc.p(winSize.width/2, winSize.height/2))

end

function ConfirmDialog:openNormal(text, callBackOk, callBackCancel)
    
    self:open_(text, true, true, callBackOk, callBackCancel)
end

function ConfirmDialog:openNoCancel(text, callBackOk, callBackCancel)

    self:open_(text, false, true, callBackOk, callBackCancel)
end

function ConfirmDialog:openOnlyOk(text, callBackOk)
    
    self:open_(text, false, false, callBackOk)
end

function ConfirmDialog:open_(text, cancelVisiable, closeVisiable, callBackOk, callBackCancel)
    
    --添加自己
    if self.curOpenning_ then return end

    local director = cc.Director:getInstance()
    local scene = director:getRunningScene()

    tolua.cast(scene, "BaseScene")
    local pop = scene:getChildByTag(BaseScene.eLayerID.ELAYER_POP)
    assert(pop, "ConfirmDialog:open ui, no pop-layer.")

    pop:addChild(self)
    
    --数据设置
    assert(text ~= nil, "ConfirmDialog open empty text.")
    self.Text_Content_:setString(text)
    
    if not cancelVisiable then
        self.Button_Cancel_:setVisible(false)
        local midpoint = self.Image_Bg_:getContentSize().width/2
        self.Button_Ok_:setPositionX(midpoint)
    end

    if not closeVisiable then
        self.Button_Close_:setVisible(false)
    end

    self.callBackOk_ = callBackOk
    self.callBackCancel_ = callBackCancel
end

function ConfirmDialog:close()
    self:removeFromParent()    
end

function ConfirmDialog:onOk(sender, callback)
    if self.callBackOk_ then
        self.callBackOk_()
    end

    self:close()
end

function ConfirmDialog:onCancel(sender, callback)
    if self.callBackCancel_ then
        self.callBackCancel_()
    end
    
    self:close()
end

function ConfirmDialog:onClose(sender, callback)

    self:close()
end

return ConfirmDialog


--endregion
