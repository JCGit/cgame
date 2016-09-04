
local channel = import(".channel")

local selfChannel = channel.facebook
function g_getSdkChannel()
    return selfChannel
end

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if (targetPlatform == cc.PLATFORM_OS_ANDROID) then
    import(".LuaJavaHelper")
elseif (targetPlatform == cc.PLATFORM_OS_IPHONE) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
    import(".LuaOcHelper")
else
	print("Win Platform")
end
