local string_gsub = string.gsub
local cc_storage = cc.UserDefault:getInstance()

local storage = class("storage")

function storage:isXMLFileExist()
    -- return cc_storage:isXMLFileExist()
    return cc.UserDefault:isXMLFileExist()
end

function storage:processKey(key)
    local processedKey = string_gsub(string_gsub(key, "/", ""), " ", "")
    return processedKey
end

function storage:setInt(key, value)
    cc_storage:setIntegerForKey(self:processKey(key), value)
end

function storage:setString(key, value)
    if value == nil then
      return
    end
    cc_storage:setStringForKey(self:processKey(key), value)
end

function storage:setBool(key, value)
    if value ~= nil then
      cc_storage:setBoolForKey(self:processKey(key), value)
    end
end

function storage:getInt(key, defaultValue)
    local value = cc_storage:getIntegerForKey(self:processKey(key), defaultValue)
    
    local retValue
    if value ~= nil then
        retValue = value
    elseif defaultValue ~= nil then
        retValue = defaultValue
    else
        retValue = 0
    end
    return retValue
end

function storage:getString(key, defaultValue)
    local value = cc_storage:getStringForKey(self:processKey(key), defaultValue)
    local retValue
    
    if value ~= nil and value ~= "" then
        retValue = value
    elseif defaultValue ~= nil then
        retValue = defaultValue
    else
        retValue = ""
    end
    return retValue
end

function storage:getBool(key, defaultValue)
    local value
    if defaultValue ~= nil then
        value = cc_storage:getBoolForKey(self:processKey(key), defaultValue)
    else
        value = cc_storage:getBoolForKey(self:processKey(key), defaultValue)
    end
    return value
end

function storage:flush()
    cc_storage:flush()
end

return storage
