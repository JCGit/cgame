DCTracking = {}

--[[自定义效果点
	taskId:任务ID String类型
	map:事件属性字典，table类型（键值对）
]]
function DCTracking.setEffectPoint(pointId, map)
	DCLuaTracking:setEffectPoint(pointId, map)
end

return DCTracking