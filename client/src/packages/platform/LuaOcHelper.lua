
local luaoc = require "cocos.cocos2d.luaoc"

function g_sdkLogin()
    luaoc.callStaticMethod("AppController", "sdkLogin")
end

function g_showSdkLoginDialog()
    luaoc.callStaticMethod("AppController", "showLoginDialog")
end

function g_sdkloginSuccessCallback(func)
    luaoc.callStaticMethod("AppController", "registerLoginHandler", {listener = func})
end

function g_sdkLogout()
    luaoc.callStaticMethod("AppController", "sdkLogout")
end

function g_sdkPay(product)
    luaoc.callStaticMethod("IosIap", "sdkPay", product)
end

function g_sdkPayCallback(func)
    luaoc.callStaticMethod("IosIap", "registerPayHandler", {listener = func})
end