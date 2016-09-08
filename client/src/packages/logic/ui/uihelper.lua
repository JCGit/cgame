local string_format = string.format


local uihelper = {}

function uihelper.seekWidgetByName(root, name)
	
	local recurse 
    recurse = function (root_, name)
        local nodename = root_:getName()
        if nodename == name then return root_ end
        
        local children = root_:getChildren()
        -- print(nodename, #children, name)
        for k,v in pairs(children) do
            local res = recurse(v, name)
            if res then
                return res
            end
        end
        return nil
    end
    
    if not root then return nil end
    return recurse(root, name)
end

function uihelper.loadTexture(target, uitype, icon, packtype)
    assert(type(uitype) == 'string', 'uitype should be sprite/image/button.')

    local f = function ()
        local loadFunc
        if uitype == 'sprite' then
            target:setTexture(icon)
            return
        elseif uitype == 'image' then
            loadFunc = target.loadTexture
        elseif uitype == 'button' then
            loadFunc = target.loadTextureNormal
        end

        assert(loadFunc, 'error target setTexture function.')
        loadFunc(target, icon, packtype)    
    end

    local ok, r = xpcall(f, __G__TRACKBACK__)
    if not ok then
        logw(string.format('texture icon:%s.', icon))
        print(r)
    end
end

--[[
    param = {
        name
        actionName 
        isLoop          0 not loop ; >0 loop ; <0 from the design            
        frameCall 
        endCall
        timeScale  
        pos
        parent
        bPlay 
    }
]]
function uihelper.createArmature(param)
    assert(type(param) == "table" , "param type is wrong")
    assert(type(param.name) == "string" , "armature name type is wrong")
    local isLoop            = param.isLoop  or -1 
    local actionName        = param.actionName or "play"
    local armature          = {}
    cc.bind(armature, "animation")

    armature:createArmature(param.name)
    
    if param.bPlay == nil or param.bPlay == true then
        armature:playAnimation(actionName , -1 , isLoop)
    end

    local target        = armature:getArmature()

    if param.pos then
        target:setPosition(param.pos)
    end
    
    if param.endCall then
        target:getAnimation():setMovementEventCallFunc(param.endCall)
    end

    if param.frameCall then
        target:getAnimation():setFrameEventCallFunc(param.frameCall)
    end
    if param.timeScale then
        target:getAnimation():setSpeedScale(param.timeScale)
    end
    if param.parent then
        param.parent:addChild(target)
    end
    return target , armature
end

return uihelper