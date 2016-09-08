local print_log     = printLog
local print_info    = printInfo
local print_error   = printError

local logger = class("logger")

local _M = logger

_M.n = print_log 
_M.i = print_info
_M.e = print_error

_M.f = function(fmt, ...)

    if type(DEBUG) ~= "number" or DEBUG < 2 then return end
    print_info(string.format(tostring(fmt), ...))
end

_M.w = function(fmt, ...)

    if type(DEBUG) ~= "number" or DEBUG < 2 then return end
    print_log("WARN", fmt, ...)
end

_M.d = function(fmt, ...)

    if type(DEBUG) ~= "number" or DEBUG < 2 then return end

    local info = debug.getinfo(2)
    print_info("----------------" .. info.name .. "------------------")
    print_info("FilePosition :" .. info.source)
    print_info("LineNum :" .. info.currentline)
    print_log("DEBUG", fmt, ...)
    print_info("------------------------------------------------------")
end

return logger