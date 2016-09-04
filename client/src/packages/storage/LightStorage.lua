local LightStorage = class("LightStorage")
local storage = cc.UserDefault:getInstance()

function LightStorage:isXMLFileExist()
    -- return storage:isXMLFileExist()
    return cc.UserDefault:isXMLFileExist()
end

function LightStorage:processKey(key)
    local processedKey = string.gsub(string.gsub(key, "/", ""), " ", "")
    return processedKey
end

function LightStorage:setInt(key, value)
    storage:setIntegerForKey(self:processKey(key), value)
end

function LightStorage:setString(key, value)
    if value == nil then
      return
    end
    storage:setStringForKey(self:processKey(key), value)
end

function LightStorage:setBool(key, value)
    if value ~= nil then
      storage:setBoolForKey(self:processKey(key), value)
    end
end

function LightStorage:getInt(key, defaultValue)
    local value = storage:getIntegerForKey(self:processKey(key), defaultValue)
    
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

function LightStorage:getString(key, defaultValue)
    local value = storage:getStringForKey(self:processKey(key), defaultValue)
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

function LightStorage:getBool(key, defaultValue)
    local value
    if defaultValue ~= nil then
        value = storage:getBoolForKey(self:processKey(key), defaultValue)
    else
        value = storage:getBoolForKey(self:processKey(key), defaultValue)
    end
    return value
end

function LightStorage:flush()
    storage:flush()
end

return LightStorage
