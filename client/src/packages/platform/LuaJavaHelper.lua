--[[
** 用例：
local s = cc.Director:getInstance():getWinSize()
local function menuCallback(tag, pMenuItem)

    print("[warning]onCreate menu callback!")

    local ok,ret  = luaj_test()
    if not ok then
        print("luaj error:", ret)
    else
        print("The ret is:", ret)
    end

    luaj_callback()
end

local menu = cc.Menu:create()
menu:setPosition(cc.p(0, 0))

local item = cc.MenuItemFont:create("LuaJavaBridge")
item:registerScriptTapHandler(menuCallback)
item:setPosition(s.width / 2, s.height / 2)
menu:addChild(item)
self:addChild(menu)
]]--
-- local luaj = require "cocos.cocos2d.luaj"
-- --java class
-- local javaClassName = "com/ly/lua/LuaJavaHelper"

-- function luaj_test()
--     -- call Java method
--     local method = "addTwoNumbers"
--     local args = { 2 , 3}
--     local sigs = "(II)I"

--     logi(string.format("luaj_test class:%s method:%s sigs:%s", javaClassName, method, sigs))
--     return luaj.callStaticMethod(javaClassName, method, args, sigs)
-- end

-- function luaj_callback()

--     local function callbackLua(param)
--         if "success" == param then
--             logi("java call back success")
--         end
--     end

--     local args = { "callbacklua", callbackLua }
--     local sigs = "(Ljava/lang/String;I)V"
--     local ok = luaj.callStaticMethod(javaClassName, "callbackLua", args, sigs)
--     if not ok then
--         loge("call callback error")
--     end
-- end

local luaj = require "cocos.cocos2d.luaj"

function g_sdkLogin()
end

function g_showSdkLoginDialog()
end

function g_sdkloginSuccessCallback(func)
end

function g_sdkLogout()
end

function g_sdkPay(product)
end

function g_sdkPayCallback(func)
end
