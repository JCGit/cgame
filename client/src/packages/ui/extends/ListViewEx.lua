--[[
    File            :   ListViewEx.lua
    Description     :   ListView扩展类
    Author          :   Edward Chan
    Date            :   2016-04-27

    Copyright (C) 2016 - All Rights Reserved.
--]]

local ListViewEx = ccui.ListView

--[[
-- 	eg:
--
	local cfg = {
		data = dataa,						--列表数据
		size = cc.size(280, 1000),			--列表大小
		cellSize = cc.size(280, 120),		--列表项大小
		cellCsb = "main/other/Cell.csb",	--列表项csb
		cellAction = true,					--列表项加载动作（扩展字段）
		updateCellfunc = updateCell,		--列表项更新回调（扩展字段）
		sortfunc = sortData,				--列表排序（扩展字段）

		-- 	控件操作（扩展字段）
			有text，button，image，sprite，node 5个类型
			name：控件名，type：控件类型，
			text：文字（填写规则：数据的字段名）（text必须字段，button可选字段）
			image：图片（填写规则：数据的字段名）（image，sprite，node必须字段，button可选字段）
			callfunc：控件回调（button必须字段, image可选字段）
			color：颜色（text可选字段）
		--
		components = {
			{name = "Text_1", type = "text", text = "name"},
			{name = "Button_1", type = "button", text = "des", image = "btn.btn", callfunc = handler(self, self.onTest)}
		}
	}
	local listView = ccui.ListView:create(cc.size(0, 0))	--创建一个空列表
	listView:setupConfig(cfg) 								--设置配置
	listView:setPosition(380, 100)
	self:addChild(listView)

--	egOther:

	listView:getKeyByIdx(idx) 							--获取cell的key值
	listView:getClickValid()							--获取cell的点击有效性
--]]

function ListViewEx:setupConfig(cfg)
	if not cfg.data then
		loge("cfg is error!!")
		return
	end

	self:setDirection(SCROLLVIEW_DIR_VERTICAL)
	self:setContentSize(cfg.size)

	if cfg.cellSizeExtend then
		self.canExtend = true
		self.isExtend = false
	end

	self.keyArr = table.keys(cfg.data)
	local nums = #self.keyArr
	if cfg.sortfunc then
		cfg.sortfunc(self.keyArr)
	else
		table.sort(self.keyArr)
	end

	local function getValue(idx, arr)
		local size = #arr
		local cellData
		local data
		if self.keyArr then
			cellData = cfg.data[self.keyArr[idx]]
		else
			cellData = cfg.data[idx]
		end
		if size == 0 then
			return ""
		elseif size == 1 then
			data = cellData[arr[1]]
			if not data then
				loge("list data error")
			end
			return data
		elseif size == 2 then
			data = cellData[arr[1]][arr[2]]
			if not data then
				loge("list data error")
			end
			return data
		elseif size == 3 then
			data = cellData[arr[1]][arr[2]][arr[3]]
			if not data then
				loge("list data error")
			end
			return data
		end
	end

	local function updateCell(idx, cell)
		local point = cc.size2pMid(cfg.cellSize)
		if cfg.cellAction then
			if math.mod(idx, 2) == 1 then
				cell:setPosition(cc.p(-point.x, point.y))
			else
				cell:setPosition(cc.p(point.x + cfg.cellSize.width, point.y))
			end
			cell:runAction(cc.MoveTo:create(0.2, point))
		else
			cell:setPosition(point)
		end

		if cfg.components then
			for i,v in ipairs(cfg.components) do
				local node = cell:getChildByName(v.name)
				if node then
					if v.type == "text" then
						local str = getValue(idx, string.split(v.text, "."))
						if str then
							node:setString(str)
							node:setVisible(true)
						else
							node:setVisible(false)
						end
						if v.color then
							node:setTextColor(getValue(idx, string.split(v.color, ".")))
						end
					elseif v.type == "button" then
						node:setEnabled(true)
	    				node:setSwallowTouches(false)
						node:addClickEventListener(v.callfunc)
						if v.text then
							node:setTitleText(getValue(idx, string.split(v.text, ".")))
						end
						if v.image then
							node:loadTextureNormal(getValue(idx, string.split(v.image, ".")))
						end
					elseif v.type == "image" then
						local value = getValue(idx, string.split(v.image, "."))
						if value then
							if cc.SpriteFrameCache:getInstance():getSpriteFrame(value) then
								node:loadTexture(value, UI_TEX_TYPE_PLIST)
							else
								node:loadTexture(value)
							end
							node:setVisible(true)
						else
							node:setVisible(false)
						end
						if v.callfunc then
							node:setTouchEnabled(true)
	    					node:setSwallowTouches(false)
							node:addClickEventListener(v.callfunc)
						end
					elseif v.type == "sprite" then
						local value = getValue(idx, string.split(v.image, "."))
						if value then
							local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(value)
							if frame then
								node:setSpriteFrame(frame)
							end
							node:setVisible(true)
						else
							node:setVisible(false)
						end
					elseif v.type == "node" then
						local value = getValue(idx, string.split(v.image, "."))
						if value then
							local sp = cc.Sprite:createWithSpriteFrameName(value)
							node:addChild(sp)
							node:setVisible(true)
						else
							node:setVisible(false)
						end
					end
				end
			end
		end

		if cfg.updateCellfunc then
			cfg.updateCellfunc(self.keyArr[idx], cfg.data, cell)
		end
	end

	local function createCell(idx)
		local node = cc.CSLoader:createNode(cfg.cellCsb)
		for i,v in ipairs(node:getChildren()) do
			if v.isTouchEnabled and v:isTouchEnabled() and v.setSwallowTouches then
    			v:setSwallowTouches(false)
			end
		end
    	updateCell(idx, node)
		return node
	end

	for i=1,nums do
		local widget = ccui.Widget:create()
		widget:setContentSize(cfg.cellSize)
		widget:addChild(createCell(i))
		widget:setTag(i)
		self:pushBackCustomItem(widget)
	end

	local function scrollCallfunc(sender, eventType)
		if eventType == TOUCH_EVENT_BEGAN then
			self.clickValid = true
			self.key = self.keyArr[self:getCurSelectedIndex() + 1]
			self.touchPos = sender:getTouchBeganPosition()
		elseif eventType == TOUCH_EVENT_MOVED then
			if not self.clickValid then return end

			local movePos = sender:getTouchMovePosition()
			local dis = math.abs(movePos.y - self.touchPos.y)
			if dis > 10 then
				self.clickValid = false
			end
		end
	end
	self:addTouchEventListener(scrollCallfunc)
end

function ListViewEx:getClickValid()
	return self.clickValid
end

function ListViewEx:getKeyByIdx(idx)
	if self.keyArr then
		return self.keyArr[idx]
	end
end

function ListViewEx:getKey()
	return self.key
end

function ListViewEx:addScrollListener()
	local function scrollCallfunc(sender, eventType)
		if eventType == TOUCH_EVENT_BEGAN then
			self.clickValid = true
			self.touchPos = sender:getTouchBeganPosition()
		elseif eventType == TOUCH_EVENT_MOVED then
			if not self.clickValid then return end

			local movePos = sender:getTouchMovePosition()
			local dis
			if self:getDirection() == SCROLLVIEW_DIR_VERTICAL then
				dis = math.abs(movePos.y - self.touchPos.y)
			else
				dis = math.abs(movePos.x - self.touchPos.x)
			end
			if dis > 10 then
				self.clickValid = false
			end
		end
	end
	self.clickValid = true
	self:addTouchEventListener(scrollCallfunc)
end

-- local ImageView = ccui.ImageView
-- ImageView.loadTextureForLua = ImageView.loadTexture
-- ImageView.loadTexture = function(self, texture, packtype)
--     local func = function ()
--         ImageView.loadTextureForLua(self, texture, packtype or 1)
--     end

--     local ok, r = xpcall(func, __G__TRACKBACK__)
--     if not ok then
--         logw(string.format('texture icon:%s.', icon))
--     end
-- end
