
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if (targetPlatform == cc.PLATFORM_OS_ANDROID) then

elseif (targetPlatform == cc.PLATFORM_OS_IPHONE) or (cc.PLATFORM_OS_IPAD == targetPlatform) or (cc.PLATFORM_OS_MAC == targetPlatform) then
    require("packages.dataStatistics.DataEye.DCAccount")
    require("packages.dataStatistics.DataEye.DCAgent")
    --require("packages..dataStatistics.DataEye.DCCardsGame")
    require("packages.dataStatistics.DataEye.DCCoin")
    require("packages.dataStatistics.DataEye.DCConfigParams")
    require("packages.dataStatistics.DataEye.DCEvent")
    require("packages.dataStatistics.DataEye.DCItem")
    require("packages.dataStatistics.DataEye.DCLevels")
    require("packages.dataStatistics.DataEye.DCTask")
    require("packages.dataStatistics.DataEye.DCTracking")
    require("packages.dataStatistics.DataEye.DCVirtualCurrency")

    DCAgent.setReportMode(DC_AFTER_LOGIN)
    DCAgent.setDebugMode(false)
    if CC_ENV_CONFIG == 1 then
        DCAgent.onStart("AC16ACB4A0F45993DE83A49D6FC15BFD", "IOS-cn")
    elseif CC_ENV_CONFIG == 2 then
        DCAgent.onStart("580F05D9A5E49811F4550768856C5FE8", "IOS-hk")
    end
else
    require("packages.dataStatistics.DataEyeWin.DCAccount")
    require("packages.dataStatistics.DataEyeWin.DCAgent")
    --require("packages..dataStatistics.DataEyeWin.DCCardsGame")
    require("packages.dataStatistics.DataEyeWin.DCCoin")
    require("packages.dataStatistics.DataEyeWin.DCConfigParams")
    require("packages.dataStatistics.DataEyeWin.DCEvent")
    require("packages.dataStatistics.DataEyeWin.DCItem")
    require("packages.dataStatistics.DataEyeWin.DCLevels")
    require("packages.dataStatistics.DataEyeWin.DCTask")
    require("packages.dataStatistics.DataEyeWin.DCTracking")
    require("packages.dataStatistics.DataEyeWin.DCVirtualCurrency")
end
