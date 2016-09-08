local os_time   = os.time
local os_clock  = os.clock

local timer = {}

local _timeStart
local _timeStop

timer.list = {}

function timer.getTime()
    --应为获取服务器时间，等待江dada实现
end

function timer:start(timerName, moduleName)
    if type(timerName) ~= "string" then return end
    local moduleName = moduleName or "global"
    if not self.list[moduleName] then
        self.list[moduleName] = {}
    end
    local moduleTimer = self.list[moduleName]
    if not moduleTimer[timerName] then
        moduleTimer[timerName] = {
            startTime = 0,
            breakTime = 0,
            pauseDuration = 0,
            endTime = 0,
        }   
    end
    moduleTimer[timerName].startTime = os.time()
    return moduleTimer[timerName].startTime
end

--[[
    pause 和 continue 必须成对出现
]]
function timer:pause(timerName, moduleName)
    local moduleName = moduleName or "global"
    local moduleTimer = self.list[moduleName]
    if not moduleTimer[timerName] then return end
    moduleTimer[timerName].breaktime = os.time()
end

function timer:continue(timerName, moduleName)
    local moduleName = moduleName or "global"
    local moduleTimer = self.list[moduleName]
    if not moduleTimer[timerName] then return end
    local subTimer = moduleTimer[timerName]
    subTimer.pauseDuration = subTimer.pauseDuration + os.time() - subTimer.breaktime
    subTimer.breaktime = 0
end

function timer:stop(timerName, moduleName)
    local moduleName = moduleName or "global"
    local moduleTimer = self.list[moduleName]
    if not moduleTimer[timerName] then return 0 end
    local subTimer = moduleTimer[timerName]
    local duration = os.time() - subTimer.startTime - subTimer.pauseDuration
    self.list[timerName] = nil
    return duration
end

function timer:getDuration(timerName, moduleName)
    local moduleName = moduleName or "global"
    local moduleTimer = self.list[moduleName]
    if not moduleTimer[timerName] then return 0 end
    local subTimer = moduleTimer[timerName]
    return os.time() - subTimer.startTime - subTimer.pauseDuration
end

function timer:pauseModule(moduleName)
    local moduleName = moduleName or "global"
    local moduleTimer = self.list[moduleName]
    if not moduleTimer then return end
    for k,v in pairs(moduleTimer) do
        self:pause(k)
    end
end

function timer:continueModule(moduleName)
    local moduleName = moduleName or "global"
    local moduleTimer = self.list[moduleName]
    if not moduleTimer then return end
    for k,v in pairs(moduleTimer) do
        self:continue(k)
    end
end

function timer:pauseAll()
    for k,v in pairs(timer.list) do
        for sk,sv in pairs(v) do
            self:pause(sk)
        end
    end
end

function timer:continueAll()
    for k,v in pairs(timer.list) do
        for sk,sv in pairs(v) do
            self:continue(sk)
        end
    end
end

function timer:schedule(name, callfunc, delay)
    if not self.scheduleList then
        self.scheduleList = {}
    end
    if self.scheduleList[name] then
        self:unschedule(name)
    else
        local scheduler = cc.Director:getInstance():getScheduler()
        self.scheduleList[name] = scheduler:scheduleScriptFunc(callfunc, delay, false)
        return self.scheduleList[name]
    end
end

function timer:unschedule(name)
    if not self.scheduleList then return end
    if not self.scheduleList[name] then return end
    local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:unscheduleScriptEntry(self.scheduleList[name])
    self.scheduleList[name] = nil
end

function timer:getFormatTimeBySecond(time, bChinese)
    
    local day = 0
    local hour = 0
    local minute = 0
    local second = 0

    if time > 0 then
        --转换
        -- to day
        day = math.floor(time/(3600*24))
        --to hour
        hour = math.floor( (time-(3600*24*day) ) / 3600)
        --to minute
        minute = math.floor( (time - (3600*24*day) - (hour * 3600) )/60 )
        --to second
        second = time%60

        if hour < 0 then hour = 0 end
        if second < 0 then second = 0 end
        if minute < 0 then minute = 0 end
    end

    local formatTime = ""

    --格式化输出
    if bChinese then
        if day == 0 then
            formatTime = string.format(g.mgr.tablemgr.getTextByKey("@sevenDay.formate2"), hour, minute, second)
        else
            formatTime = string.format(g.mgr.tablemgr.getTextByKey("@sevenDay.formate1"), day, hour, minute, second)
        end
    else
        formatTime = string.format("%02d:%02d:%02d", hour, minute, second)
    end

    return formatTime
end


--private

_timeStart = function()
    if type(DEBUG) ~= "number" or DEBUG < 2 then return end
    return os.clock()
end

_timeStop = function(start)
    if type(DEBUG) ~= "number" or DEBUG < 2 then return end
    if type(start) ~= "number" then return end
    logd(os.clock() - start)
end

return timer