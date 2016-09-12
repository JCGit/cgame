local TipDialog = require('app.main.common.TipDialog')
local ConnectDialog = require("app.main.common.ConnectDialog")
local CONFIG_NET = require('app.config.net')
local UPDINFO = CONFIG_NET.UPDINFO
local BasePanel = mvc.BasePanel
local scheduler = cc.Director:getInstance():getScheduler()
local UpdView = class('UpdView', BasePanel)
local simp2trad = utils.simp2trad
local ConfirmDialog = ui.com.ConfirmDialog

local option = {
	pullTimeout = 10,
}

function UpdView:onCreate()

	self:createCSBNode("login/update/upd.csb")

	self.checkBox = self:seekWidgetByName('Sprite_1')
	self.downInfo = self:seekWidgetByName('Node_1')

	self.contentText = self.checkBox:getChildByName('Text_content')
	self.progressText = self:seekWidgetByName('Text_1')
	self.downingText = self:seekWidgetByName('Text_2')
	self.progress = self:seekWidgetByName('LoadingBar_1')

	g.eventcenter:addEventListener("ME_CHECK_VERLIST", 	handler(self, self.checkVerlist))
	g.eventcenter:addEventListener("ME_DOWNLOAD_ZIPS", 	handler(self, self.downloadZips))
	g.eventcenter:addEventListener("ME_DOWNLOAD_OVER", 	handler(self, self.downloadOver))
	g.eventcenter:addEventListener("ME_DOWNLOAD_SO_OVER", handler(self, self.downloadSoOver))
	g.eventcenter:addEventListener("ME_DOWNLOAD_APK", 	handler(self, self.downloadApkTip))
end

function UpdView:clear()
	g.eventcenter:removeEventListenersByEvent("ME_CHECK_VERLIST")
	g.eventcenter:removeEventListenersByEvent("ME_DOWNLOAD_ZIPS")
	g.eventcenter:removeEventListenersByEvent("ME_DOWNLOAD_OVER")
	g.eventcenter:removeEventListenersByEvent("ME_DOWNLOAD_SO_OVER")
	g.eventcenter:removeEventListenersByEvent("ME_DOWNLOAD_APK")
end

function UpdView:checkVerlist(event)
	local info = event.info
	local code = UPDINFO.CODE

	local errcode = info.errcode
	local errstr  = info.errstr

	if errcode == nil and errstr == nil then
		logi('checkVerlist pull verlist.')
		self:pullVerlist()

	elseif errcode == code.ERROR_OK then
		logi('checkVerlist pull verlist ok.')
		self:doPullVerList(info.isUpd)
	else
		self:doPullVerListFail(DEBUG ~= 0 and errstr or simp2trad(errcode))
	end
end

function UpdView:downloadZips(event)
	local info = event.info
	local code = UPDINFO.CODE

	local errcode = info.errcode
	local errstr  = info.errstr
	local progress= info.progress

	if errcode == code.ERROR_OK then 	--下载zip完成
		logi('downloadZips down ok')

	elseif errcode == code.ERROR_DOWN_VERFILE and errstr ~= nil then --下载zip失败
		logw('down failed.')
		-- local tips = TipDialog:create(simp2trad(errcode))
		-- tips:open()
		local dialog = ConfirmDialog:create()
		dialog:openOnlyOk(simp2trad(errcode), function()
			cc.Director:getInstance():endToLua()
		end)

	elseif progress ~= nil then 		--显示下载进度
		self:onProgress(progress)
		-- local progress = progress.received * 100 / progress.expected

		-- logf('down progress:%f.', progress)
		-- self.progress:setPercent(progress)
		-- self.progressText:setText(string.format("%d%%", math.floor(progress)))
	else 								--请求确认是否下载提示
		logi('is download zips prompt...')
		self:showCheckUpd(info.fileSize or " ")
	end
end

function UpdView:downloadOver(event)
	self:clear()
	logi('downloadOver down ok')
end

function UpdView:downloadSoOver(event)
	self.checkBox:setVisible(false)
	self.downInfo:setVisible(false)
	self:clear()
	logi('download so over, now need to restart')

	local code = UPDINFO.CODE.NEED_RESTART
	local dialog = ConfirmDialog:create()
	dialog:openOnlyOk(simp2trad(code), function()
		cc.Director:getInstance():endToLua()
	end)
end

function UpdView:downloadApkTip(event)
	self.checkBox:setVisible(false)
	self.downInfo:setVisible(false)
	self:clear()
	logi('download apk tip')

	local code = UPDINFO.CODE.GOTO_URL
	local dialog = ConfirmDialog:create()
	dialog:openOnlyOk(simp2trad(code), function()
		cc.Director:getInstance():endToLua()
	end)
end

function UpdView:pullVerlist()
	local VERLIST_WAIT = option.pullTimeout

	local timeoutUICB = function(...)
		self:doPullVerList()

		local errcode = UPDINFO.CODE.ERROR_PULL_VERLIST
		-- local tips = TipDialog:create(simp2trad(errcode))
		-- tips:open()
		local dialog = ConfirmDialog:create()
		dialog:openOnlyOk(simp2trad(errcode), function()
			self:pullVerlist()
		end)
	end

	ConnectDialog:create()

	self.timeoutUICB_ = scheduler:scheduleScriptFunc(timeoutUICB, VERLIST_WAIT, false)
end

function UpdView:doPullVerList(isUpd)

	ConnectDialog:removeSelf()

	scheduler:unscheduleScriptEntry(self.timeoutUICB_)

	if not isUpd then
		self:clear()
	end
end

function UpdView:doPullVerListFail(errorstr)
	self:doPullVerList()
	-- self:clear()

	-- local tips = TipDialog:create(errorstr)
	-- tips:open()
	local dialog = ConfirmDialog:create()
	dialog:openOnlyOk(errorstr, function()
		self:pullVerlist()
	end)
end

function UpdView:showCheckUpd(fileSize)
	self.contentText:setString(string.format(g.mgr.tablemgr.getTextByKey("@upd.title"), fileSize))
	self.checkBox:setVisible(true)
	self.downInfo:setVisible(false)

	self.onExitGame = function()
		logi('end game...')
		cc.Director:getInstance():endToLua()
	end

	self.onStartDown = function()
		self.checkBox:setVisible(false)
		self.downInfo:setVisible(true)

		g.eventcenter:dispatchEvent({name="ME_CONTINUE_UPDATE"})
	end
end

function UpdView:onProgress(event)
	local progress = event.received * 100 / event.expected
	logf('down progress:%f.', progress)
	self.progress:setPercent(progress)
	self.progressText:setText(string.format("%d%%", math.floor(progress)))
end


return UpdView
