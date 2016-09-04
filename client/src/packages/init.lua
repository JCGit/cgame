--[[
    File            :   init.lua
    Description     :   底层框架的初始化文件，
						一些框架模块的init都在这里执行，
						上层业务的初始化工作绝b不能在这里执行，
						一经发现就准备下午茶
    Author          :   Edward Chan
    Date            :   2016-03-16

    Copyright (C) 2016 - All Rights Reserved.
]]

cc.load("eventcore")			--事件管理
cc.load("utils")				--通用工具函数模块
cc.load("network")				--网络通讯模块
cc.load("mvc")					--mvc
cc.load("platform")				--平台相关模块
cc.load("dataStatistics")		--数据统计模块
cc.load("storage")
cc.load("ui")                   --ui模块	
cc.load("envset")				--app环境
-- cc.load("anysdk")				--anysdk
