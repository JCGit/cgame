DCAgent = {}

--[[SDK初始化接口，该接口只在IOS平台起作用，android为空实现，不需要调用
	appId:游戏或应用在DataEye平台对应的ID号，请在DataEye官网申请 String类型
	channelId:游戏或应用将要发布的渠道，String类型
]]
function DCAgent.onStart(appId, channelId)
	DCLuaAgent:onStart(appId, channelId)
end

--[[SDK调试模式开关，android平台会将log打印到logcat中，IOS会在调试时将log打印到xcode中
	mode：调试模式开关，boolean类型，true为开，false为关
]]
function DCAgent.setDebugMode(mode)
    DCLuaAgent:setDebugMode(mode)
end

--[[设置SDK上报模式
	mode:其值为DC_DEFAULT、DC_AFTER_LOGIN二者之一，具体说明请参考文档
]]
function DCAgent.setReportMode(mode)
    DCLuaAgent:setReportMode(mode)
end

--[[设置SDK上报频率]]
function DCAgent.setUploadInterval(interval)
	DCLuaAgent:setUploadInterval(interval)
end

--[[设置应用版本号，该lua侧接口只在IOS平台有效，android平台请从java侧调用
	version:版本号，string类型
]]
function DCAgent.setVersion(version)
    DCLuaAgent:setVersion(version)
end

--[[自定义错误上报
	title:错误标题，string类型
	content:错误内容，建议传入错误的堆栈信息, stirng类型
]]
function DCAgent.reportError(title, content)
    DCLuaAgent:reportError(title, content)
end

--[[强制SDK立即上报数据]]
function DCAgent.uploadNow()
	DCLuaAgent:uploadNow()
end

--[[获取当前设备UID]]
function DCAgent.getUID()
	return DCLuaAgent:getUID()
end

--[[打开广告效果追踪功能]]
function DCAgent.openAdTracking()
	return DCLuaAgent:openAdTracking()
end

return DCAgent