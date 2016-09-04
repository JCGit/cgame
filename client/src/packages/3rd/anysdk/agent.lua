--[[
    File            :   agent.lua
    Description     :   anysdk接口集
    Author          :   Edward Chan
    Date            :   2016-07-09

    Copyright (C) 2016 - All Rights Reserved.
--]]

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if not (targetPlatform == cc.PLATFORM_OS_ANDROID
	or targetPlatform == cc.PLATFORM_OS_IPHONE
	or targetPlatform == cc.PLATFORM_OS_IPAD
	or targetPlatform == cc.PLATFORM_OS_MAC) then
	return false
end

-----------------------------华丽的分割线-------------------------------------
import(".anysdkConst")

local Anysdk
local agent
local user_plugin
local iap_plugin
local crash_plugin
local push_plugin

--用户系统回调
local function onUserListener( pPlugin, code, msg )
    if code == UserActionResultCode.kInitSuccessthen then 		--初始化SDK成功回调
        print("[sdk]", "sdk init success")
        Anysdk.initial = true
    elseif code == UserActionResultCode.kInitFail then   		--初始化SDK失败回调
        print("[sdk]", "sdk init fail", msg)
        Anysdk.initial = false

    elseif code == UserActionResultCode.kLoginSuccess then 		--登陆成功回调
    	print("[sdk]", "login success")
    	self.loginCallback(true)
	elseif code == UserActionResultCode.kLoginTimeOut			--登陆失败回调
		or code == UserActionResultCode.kLoginCancel   			--登陆取消回调
		or code == UserActionResultCode.kLoginFail then 		--登陆失败回调
		print("[sdk]", "login success", msg)
    	self.loginCallback(false)

	elseif code == UserActionResultCode.kLogoutSuccess then  	--用户登出成功回调
    	print("[sdk]", "logout success")
		self.logoutCallback(true)
	elseif code == UserActionResultCode.kLogoutFail then  		--用户登出失败回调
    	print("[sdk]", "logout fail", msg)
		self.logoutCallback(false)

	elseif code == UserActionResultCode.kPlatformEnter then  		--平台中心进入回调
	elseif code == UserActionResultCode.kPlatformBack then  		--平台中心退出回调
	elseif code == UserActionResultCode.kAccountSwitchSuccess then  --切换账号成功回调
	elseif code == UserActionResultCode.kAccountSwitchFail then   	--切换账号失败回调
	end
end

--支付系统回调
local function onIapListner( code, msg, info )
end

--android初始化
local function initAgentForAndroid()
	--注意：这里appKey, appSecret, privateKey，要替换成自己打包工具里面的值(登录打包工具，游戏管理界面上显示的那三个参数)。
    local appKey = "1DFEF1E0-5821-754C-DF97-5E0AF65044AA"
    local appSecret = "7b473c38530b099e1609add204ce6d87"
    local privateKey = "A506EBA5DEAA390C5FBD9703F2AD0559"
    local oauthLoginServer = "http://oauth.anysdk.com/api/OauthLoginDemo/Login.php"

    --agent
    agent = AgentManager:getInstance()
    --init
    agent:init(appKey, appSecret, privateKey, oauthLoginServer)
    --load
    agent:loadAllPlugins()

    --user
	user_plugin = agent:getUserPlugin()
	if user_plugin then
		user_plugin:setActionListener(onUserListener)
	end

	--iap
	local iap_plugins = agent:getIAPPlugin()
	for k,v in pairs(iap_plugins) do
	    iap_plugin = v
	end
	iap_plugin:setResultListener(onIapListner)

	--crash
	crash_plugin = agent:getCrashPlugin()

	--push
	push_plugin = agent:getPushPlugin()
end

--ios初始化
local function initAgentForIOS()
end

-----------------------------用户系统-------------------------------------
--登陆
--[[
	local info = {	--(可选)
	    server_id   = "2",
	    server_url  = "http://xxx.xxx.xxx",
	    key1        = "value1",
	    key2        = "value2"
	}
	local callback = func(param) --parma : 登陆成功或失败

	登陆参数可以传入一个表，可传入服务器id(server_id)、登陆验证地址(server_url)和透传参数（任意key值）。
	服务器id：key为server_id，服务端收到的参数名为server_id，不传则默认为1。
	登陆验证地址：key为server_url，传入的地址将覆盖掉配置的登陆验证地址。
	透传参数：key任意（以上两个key除外），服务端收到的参数名为server_ext_for_login，是个json字符串。
	PS：AnySDK客户端【渠道参数】的【登陆验证透传参数】，服务端收到的参数名为server_ext_for_client。
]]
function Anysdk:login(info, callback)
	if not user_plugin then return end

	local function login()
		timer:unschedule("initSDK")
		self.loginCallback = callback
		if info then
			user_plugin:login(info)
		else
			user_plugin:login()
		end
	end

	if self.initial then
		login()
	else
		local function scheduleLogin()
			if self.initial then
				login()
			end
		end
		timer:schedule("initSDK", scheduleLogin, 0.1)
	end
end

--登出
function Anysdk:logout(callback)
	if nil ~= user_plugin and user_plugin:isFunctionSupported("logout") then
		self.logoutCallback = callback
	    user_plugin:callFuncWithParam("logout")
	end
end

--进入平台中心
function Anysdk:enterPlarform(callback)
	if nil ~= user_plugin and user_plugin:isFunctionSupported("enterPlatform")  then
		self.enterPlarformCallback = callback
	    user_plugin:callFuncWithParam("enterPlatform")
	end
end

--显示悬浮框
function Anysdk:showToolBar()
	if nil ~= user_plugin and user_plugin:isFunctionSupported("showToolBar")  then
	    local param = PluginParam:create(ToolBarPlace.kToolBarMidLeft)
	    user_plugin:callFuncWithParam("showToolBar", param)
	end
end

--隐藏悬浮框
function Anysdk:hide()
	if nil ~= user_plugin and user_plugin:isFunctionSupported("hideToolBar")  then
	    user_plugin:callFuncWithParam("hideToolBar")
	end
end

--切换账号
function Anysdk:accountSwitch()
	if nil ~= user_plugin and user_plugin:isFunctionSupported("accountSwitch") then
	    user_plugin:callFuncWithParam("accountSwitch")
	end
end

--退出游戏确认
function Anysdk:exit()
	if nil ~= user_plugin and user_plugin:isFunctionSupported("exit") then
	    user_plugin:callFuncWithParam("exit")
	end
end

--暂停界面
function Anysdk:pause()
	if nil ~= user_plugin and user_plugin:isFunctionSupported("pause") then
	    user_plugin:callFuncWithParam("pause")
	end
end

--提交游戏数据(部分平台要)
--[[
	参数		是否必传	参数说明																备注
	dataType		Y		数据类型，1为进入游戏，2为创建角色，3为角色升级，4为退出	
	roleId			Y		角色ID	
	roleName		Y		角色名称	
	roleLevel		Y		角色等级	
	zoneId			Y		服务器ID	
	zoneName		Y		服务器名称	
	balance			Y		用户余额（RMB购买的游戏币）												37玩、猎宝
	partyName		Y		帮派、公会等，没有填空字符串											37玩
	vipLevel		Y		Vip等级，没有vip系统的传0												37玩
	roleCTime		Y		角色创建时间(单位：秒)（历史角色没记录时间的传-1，新创建的角色必须要）	uc
	roleLevelMTime	Y		角色等级变化时间(单位：秒)（创建角色和进入游戏时传-1）					uc
]]
function Anysdk:submitLoginGameRole(data)
	if user_plugin:isFunctionSupported("submitLoginGameRole") then
		local info = PluginParam:create(data)
		user_plugin:callFuncWithParam("submitLoginGameRole", info)
	end
end

-----------------------------支付系统-------------------------------------
--支付
--[[
	参数		是否必传	参数说明
	Product_Id		Y		商品id（联想、七匣子、酷派等商品id要与在渠道后台配置的商品id一致）	参数类型：字符串
	Product_Name	Y		商品名	参数类型：字符串
	Product_Price	Y		商品价格(元)，可能有的SDK只支持整数	参数类型：字符串
	Product_Count	Y		商品份数(除非游戏需要支持一次购买多份商品，否则传1即可)	参数类型：字符串
	Product_Desc	N		商品描述（不传则使用Product_Name）	参数类型：字符串
	Coin_Name		Y		虚拟币名称（如金币、元宝）	参数类型：字符串
	Coin_Rate		Y		虚拟币兑换比例（例如100，表示1元购买100虚拟币）	参数类型：字符串
	Role_Id			Y		游戏角色id参数类型：字符串
	Role_Name		Y		游戏角色名	参数类型：字符串
	Role_Grade		Y		游戏角色等级	参数类型：字符串
	Role_Balance	Y		用户游戏内虚拟币余额，如元宝，金币，符石	参数类型：字符串
	Vip_Level		Y		Vip等级	参数类型：字符串
	Party_Name		Y		帮派、公会等	参数类型：字符串
	Server_Id		Y		服务器id，若无填“1”	参数类型：字符串
	Server_Name		Y		服务器名	参数类型：字符串
	EXT				N		扩展字段		参数类型：字符串，可以使用json型字符串。
]]
function Anysdk:payForProduct(productInfo)
	iap_plugin:payForProduct(productInfo)
end

--获取订单号
function Anysdk:getOrderId()
	return iap_plugin:getOrderId()
end

--重置支付状态
function Anysdk:resetPayState()
	ProtocolIAP:resetPayState()
end

-----------------------------崩溃分析系统-------------------------------------
--设置用户标示
function Anysdk:setUserIdentifier()
	if crash_plugin ~= nil  then
	    crash_plugin:setUserIdentifier("AnySDK")
	end
end

-----------------------------渠道相关系统-------------------------------------
--获取渠道号
function Anysdk:getChannelId()
	return agent:getChannelId()
end

--获取渠道自定义参数
function Anysdk:getCustomParam()
	return agent:getCustomParam()
end


-----------------------------华丽的分割线-------------------------------------
if (targetPlatform == cc.PLATFORM_OS_ANDROID) then
	if not Anysdk then
    	initAgentForAndroid()
	end
elseif (targetPlatform == cc.PLATFORM_OS_IPHONE) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
	if not Anysdk then
    	initAgentForIOS()
    end
end

return Anysdk

