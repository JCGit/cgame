DCTask = {}

--[[任务开始
	taskId:任务ID String类型
	taskType:任务类型 枚举类型，其值为下列值之一
	DC_GuideLine，
	DC_MainLine,
	DC_BranchLine,
	DC_Daily,
	DC_Activity,
	DC_Other
]]
function DCTask.begin(taskId, taskType)
	DCLuaTask:begin(taskId, taskType)
end

--[[任务完成
	taskId:任务ID String类型
]]
function DCTask.complete(taskId)
	DCLuaTask:complete(taskId)
end

--[[任务失败
	taskId:任务ID String类型
	reason:任务失败原因
]]
function DCTask.fail(taskId, reason)
	DCLuaTask:fail(taskId, reason)
end

return DCTask