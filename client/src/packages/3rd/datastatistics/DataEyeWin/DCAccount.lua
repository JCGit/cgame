DCAccount = {}

--[[用户登陆接口
	accountId：用户登陆ID string类型
	gameServer:账号所在的区服 String类型
]]
function DCAccount.login(...)
end

--[[用户登出接口，用于账户重登陆前注销时调用]]
function DCAccount.logout()
end

--[[获取当前登陆用户ID]]
function DCAccount.getAccountId()
end

--[[设置账户类型
	accountType：枚举类型，其值可以为下列值其一
		DC_Anonymous,
		DC_Registered,
		DC_SinaWeibo,
		DC_QQ、
		DC_QQWeibo,
		DC_ND91,
		DC_Type1,
		DC_Type2,
		DC_Type3,
		DC_Type4,
		DC_Type5,
		DC_Type6,
		DC_Type7,
		DC_Type8,
		DC_Type9,
		DC_Type10
]]
function DCAccount.setAccountType(accountType)
end

--[[设置账号等级
	level:账号目前等级 int类型
]]
function DCAccount.setLevel(level)
end

--[[设置账号性别
	gender:玩家注册账号时的性别，其值是下列枚举之一
	DC_UNKNOWN,
	DC_MALE,
	DC_FEMALE
]]
function DCAccount.setGender(gender)
end

--[[设置玩家年龄
	age:玩家年龄，int类型
]]
function DCAccount.setAge(age)
end

--[[设置账号所在区服
	server:账号所在的区服 String类型
]]
function DCAccount.setGameServer(server)
end

--[[给玩家打标签
	tag:一级标签 String类型
    subTag:二级标签 String类型
]]
function DCAccount.addTag(tag, subTag)
end

--[[取消玩家已有的标签
	tag:一级标签 String类型
    subTag:二级标签 String类型
]]
function DCAccount.removeTag(tag, subTag)
end

return DCAccount
