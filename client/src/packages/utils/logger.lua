--[[
    File            :   looger.lua
    Description     :   日志
    Author          :   Edward Chan
    Date            :   2016-03-23

    Copyright (C) 2016 - All Rights Reserved.
]]

log = printLog      --自定义标签打印
logi = printInfo    --info标签打印
loge = printError   --error标签打印

--format打印
function logf(fmt, ...)
    if type(DEBUG) ~= "number" or DEBUG < 2 then return end
    logi(string.format(tostring(fmt), ...))
end

--warn标签打印
function logw(fmt, ...)
    if type(DEBUG) ~= "number" or DEBUG < 2 then return end
    log("WARN", fmt, ...)
end

--debug标签定位打印
function logd(fmt, ...)
    if type(DEBUG) ~= "number" or DEBUG < 2 then return end
    local info = debug.getinfo(2)
    print("----------------" .. info.name .. "------------------")
    print("FilePosition :" .. info.source)
    print("LineNum :" .. info.currentline)
    log("DEBUG", fmt, ...)
    print("------------------------------------------------------")
end