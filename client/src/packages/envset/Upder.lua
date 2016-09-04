local lfs 		= require('lfs')
local dlder 	= import('.Download')
local UpdView 	= import('.UpdView')
local CONFIG_NET= require('app.config.net')
local UPDINFO 	= CONFIG_NET.UPDINFO
require "cocos.cocos2d.json"
local scheduler = cc.Director:getInstance():getScheduler()
local upder = {}

local writePath = cc.FileUtils:getInstance():getWritablePath()
local updPath = writePath .. 'upd/'

local option = {

	urlVer = UPDINFO.VERLIST_URL,
	curVer = writePath .. 'version.json',
}

function upder:startUpdate()

	g.eventcore:addEventListener("ME_CONTINUE_UPDATE", handler(self, self.doContinueUpdate))

	self.view_ = UpdView:create()
	self.view_:retain()

	if not self.dlder then
		self.dlder= dlder
	end

	self.updateOK_ = false

	if UPDINFO.ENABLEL_UPD then
		self:doUpdate()
	else
		self:clear()
	end
end

function upder:doUpdate()
	local cf = coroutine.create(function()
		while not self.updateOK_ do

			if not self:checkVersion() then
				self.updateFail()
				return false
			end

			local ziplist = self.updatelist or {}
			if #ziplist > 0 then

				local ret, errcode, errstr = self:downloadZip()
				if not ret then
					self.updateFail()
					return false
				end

				if not self:restart() then
					self.updateFail()
					return false
				end
			end

			self.updateSuccess()
			DCAgent.setVersion(self:localVersion())
			return self.updateOK_
		end
	end)

	self.resumeUpdate = function()
		if not self.updateOK_ then
			-- print("----------------resume")
			coroutine.resume(cf)
		end
	end

	self.suspendUpdate = function(...)
		-- print("----------------suspend")
		coroutine.yield()
	end

	self.updateFail = function(...)
		self:clear()
	end

	self.updateSuccess = function(...)
		self:clear()
	end
	self.resumeUpdate()
end

function upder:clear()
	if self.view_:getParent() then
		self.view_:removeFromParent()
	end
	self.view_:release()
	g.eventcore:removeEventListenersByEvent("ME_CONTINUE_UPDATE")

	local LoginEvent = require("app.login.event.LoginEvent")
	g.eventcore:dispatchEvent({name=LoginEvent.updateDone})
end

function upder:checkVersion()
	--[[
	--@desc 比较本地版本号和服务器版本号，判断是否需要更新该服务器版本.
	--@v1 local version
	--@v2 server target version
	--@return "apk"/"so"/"res"/nil
	]]
	local compareVersion = function(v1, v2)
		assert(type(v1)=='string' and type(v2)=='string', 'version type error')

		local arr1 = string.split(v1, '.')
		local arr2 = string.split(v2, '.')
		assert(#arr1 == 4 and #arr2 == 4, 'version data error')

		if tonumber(arr2[1]) < tonumber(arr1[1]) then
			return nil
		elseif tonumber(arr2[1]) > tonumber(arr1[1]) then
			return "apk"
		elseif tonumber(arr2[2]) > tonumber(arr1[2]) then
			return "so"
		elseif tonumber(arr2[3]) > tonumber(arr1[3]) then
			return "res"
		else
			return nil
		end
	end

	local verlistParse = function(path)
		local cur = self:localVersion()

		local updatelist = {}

		local f = function()
			local jsonstr = cc.FileUtils:getInstance():getStringFromFile(path)
			local vljson = json.decode(jsonstr,1)

			for k,v in pairs(vljson.versions) do
				local thisversion = v.ver

				local result = compareVersion(cur, thisversion)
				if result then
					local tt = { updType = result }
					if result ~= "apk" then
						tt.addr = vljson.rootAddr .. v.pkg
						tt.tag = v.tag
						tt.size = tonumber(v.size)
					end
					table.insert(updatelist, tt)
					logf("cur version:%s, compare version:%s.", cur, thisversion)
				end
			end
		end

		local ok, r = xpcall(f, __G__TRACKBACK__)
        if not ok then
            logw("verlistParse parse verlist.json error.")
        end

		return updatelist, jsonstr
	end

	local ret = false
	local stateinfo = {
		state = UPDINFO.STATE.CHECK_VERSION
	}

	local verlistCB = function (tag, ...)
		-- print('[INFO]', tag, ...)
		local params = {...}

		if tag == 'progress' then
			return 	--不处理verlist的下载进度
		elseif tag == 'fileError' then
			stateinfo.errcode = UPDINFO.CODE.ERROR_PULL_VERLIST
			stateinfo.errstr  = tostring(params[1]) .. "[:]" .. params[3]
		elseif tag == 'fileSuccess' then
			-- parse file verlist.json
			ret = true
			self.updatelist = verlistParse(params[3])
			stateinfo.errcode = UPDINFO.CODE.ERROR_OK

			-- 有更新列表
			if #self.updatelist > 0 then
				stateinfo.isUpd = true
			end
		end

		g.eventcore:dispatchEvent({name="ME_CHECK_VERLIST", info=stateinfo})
		self.resumeUpdate()
	end

	g.eventcore:dispatchEvent({name="ME_CHECK_VERLIST", info=stateinfo})
	self.dlder.downloadFile(option.urlVer, writePath, verlistCB)
	self.suspendUpdate()
	return ret
end

function upder:downloadZip()
	local ret = true
	local curTag
	local updType
	local stateinfo = {
		state = UPDINFO.STATE.VER_DOWNLOAD
	}

	local verzipCB = function(tag, ...)
		-- print('[INFO]', tag, ...)
		local params = {...}

		if tag == 'progress' then
			stateinfo.progress = {
				received=params[2],
				expected=params[3]
			}
			g.eventcore:dispatchEvent({name="ME_DOWNLOAD_ZIPS", info=stateinfo})
			return
		elseif tag == 'fileError' then
			ret = false
			stateinfo.errcode = UPDINFO.CODE.ERROR_DOWN_VERFILE
			stateinfo.errstr  = tostring(params[1]) .. "[:]" .. params[3]
		elseif tag == 'fileSuccess' then
			local _,_, ver = string.find(params[3], ".+_(%d*.%d*.%d*.%d*).%a+")
			logf("zip file:Resources_%s download success, start uncompress...", ver)

			stateinfo.errcode = UPDINFO.CODE.ERROR_OK
			ZipUtils:uncompressZip(params[3], updPath)	--主线程操作

			self:writeLocalVersion(ver, curTag)
		end

		g.eventcore:dispatchEvent({name="ME_DOWNLOAD_ZIPS", info=stateinfo})

		stateinfo.errcode = nil
		stateinfo.errstr  = nil
		stateinfo.progress= nil

		-- 更新完so后，用户自行重启游戏
		if updType == "so" then
			g.eventcore:dispatchEvent({name="ME_DOWNLOAD_SO_OVER"})
			return
		end
		self.resumeUpdate()
	end

	if not self:isFileExist(updPath) then
		lfs.mkdir(updPath)
	end

	--检查大版本更新，自行前往应用商店
	local ziplist = self.updatelist or {}
	local fileSize = 0
	for k,v in pairs(ziplist) do
		if v.updType == "apk"
			or (v.updType == "so" and (CC_ENV_CONFIG == 1 or CC_ENV_CONFIG == 2)) then
			g.eventcore:dispatchEvent({name="ME_DOWNLOAD_APK"})
			self.suspendUpdate()
			break
		end
		if v.updType == "res" then
			fileSize = fileSize + (v.size or 0)
		elseif v.updType == "so" then
			logw(v.size)
			fileSize = fileSize + (v.size or 0)
			break
		end
	end

	--计算本次更新的总文件大小
	stateinfo.fileSize = (function()
		local sizeStr = ""
		local mSize = 1024 * 1024
		if fileSize >= mSize then
			sizeStr = math.ceil(fileSize / mSize) .. "M"
		elseif fileSize >= 1024 then
			sizeStr = math.ceil(fileSize / 1024) .. "K"
		else
			sizeStr = "1K"
		end
		return sizeStr
	end)()

	self.view_:open()
	g.eventcore:dispatchEvent({name="ME_DOWNLOAD_ZIPS", info=stateinfo})
	self.suspendUpdate()

	--小版本更新
	for i=1,#ziplist do
		local info = ziplist[i]
		updType = info.updType
		logf(string.format('request zip:%s...', info.addr))

		curTag = info.tag
		self.dlder.downloadFile(info.addr, updPath, verzipCB)
		self.suspendUpdate()
		if not ret then
			return false, stateinfo
		end
	end

	g.eventcore:dispatchEvent({name="ME_DOWNLOAD_OVER", info=stateinfo})
	self.view_:close()
	return true
end

function upder:restart()
	logi("upder:restart reload game")
	self.state = UPDINFO.STATE.GAME_START
	require('appentry')

	return true
end

function upder:localVersion()

	if not self:isFileExist(option.curVer) then
		return CONFIG_NET.VERSION
	else
		local jsonstr = cc.FileUtils:getInstance():getStringFromFile(option.curVer)
		local vljson = json.decode(jsonstr,1)
		return vljson['version']
	end
end

function upder:writeLocalVersion(ver, tag)

	local verTag = ''
	if tag then
		verTag = string.format(', \"tag\" : \"%s\"', tag)
	end

	local content = string.format('{\"version\" : \"%s\"%s}', ver, verTag)

	logf('upder:writeLocalVersion ver:%s verTag:%s.', ver, verTag)
	io.writefile(option.curVer, content, 'w')
end

function upder:isFileExist(filename)
	local filepath = cc.FileUtils:getInstance():fullPathForFilename(filename)
	return cc.FileUtils:getInstance():isFileExist(filepath)
end

function upder:isDirectoryExist(dirname)
	return cc.FileUtils:getInstance():isDirectoryExist(dirname)
end

function upder:doContinueUpdate()
	self.resumeUpdate()
end

return upder
