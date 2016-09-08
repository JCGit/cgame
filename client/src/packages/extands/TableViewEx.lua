--[[
    File            :   TableViewEx.lua
    Description     :   TableView扩展类
    Author          :   Edward Chan
    Date            :   2016-04-27

    Copyright (C) 2016 - All Rights Reserved.
--]]

local TableViewEx = cc.TableView
CCTableView.kTableCellHightLight = cc.TABLECELL_HIGH_LIGHT
CCTableView.kTableCellUnhightLight = cc.TABLECELL_UNHIGH_LIGHT

--[[
-- 	eg:
--
	local cfg = {
		data = dataa,						--列表数据
		size = cc.size(280, 1000),			--列表大小
		cellSize = cc.size(280, 120),		--列表项大小
		cellSizeExtend = cc.size(280, 200),	--列表项扩展大小（扩展字段）
		cellCsb = "main/other/Cell.csb",	--列表项csb
		cellAction = true,					--列表项加载动作（扩展字段）
		updateCellfunc = updateCell,		--列表项更新回调（扩展字段）
		clickfunc = clickCell,				--列表项点击回调（扩展字段）
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
	local tableView = cc.TableView:create(cc.size(0, 0))	--创建一个空列表
	tableView:setupConfig(cfg) 								--设置配置
	tableView:setPosition(50, 100)
	self:addChild(tableView)

--	egOther:

	tableView:extendCell()						--伸缩cell
	tableView:getKeyByIdx(idx) 					--获取cell的key值
	tableView:getClickValid()					--获取cell的点击有效性
--]]

function TableViewEx:setupConfig(cfg)
	if not cfg.data then
		loge("cfg is error!!")
		return
	end

	self:initWithViewSize(cfg.size)
	self:setDirection(kCCScrollViewDirectionVertical)
	self:setVerticalFillOrder(kCCTableViewFillTopDown)
	self:setDelegate()

	self.selectIdx = -1
    self.clickValid = true
    self.playFlag = true
	self.cfg = cfg
	self.actionTag 	= 0
	self.num 		= math.ceil(cfg.size.height / cfg.cellSize.height)
	local dataNum 	= #cfg.data
	self.num 		= dataNum < self.num and dataNum or self.num

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
		if cfg.cellAction and self.playFlag  then
			cell:setPosition(cc.p(-point.x, point.y))

			local time
			if self.actionTag < self.num then
				time  		= 0.1 *idx +0.1
				self.actionTag 	= 1 + self.actionTag
			else
				time 		= 0.1
			end
			if self.actionTag == self.num then
				cfg.cellAction 	= not cfg.cellStartAction
			end

			cell:runAction(cc.MoveTo:create(time, point))
		else
			if cfg.cellSizeExtend and self.selectIdx == idx then
				cell:setPosition(cc.p(point.x, point.y + cfg.cellSizeExtend.height - cfg.cellSize.height))
			else
				cell:setPosition(point)
			end
		end

		if cfg.components then
			for i,v in ipairs(cfg.components) do
				-- local node = cell:getChildByName(v.name)
				local node = uihelper.seekWidgetByName(cell, v.name)
				if node then
					if v.type == "text" then
						local str = getValue(idx + 1, string.split(v.text, "."))
						if str then
							node:setString(str)
							node:setVisible(true)
						else
							node:setVisible(false)
						end
						if v.color then
							node:setTextColor(getValue(idx + 1, string.split(v.color, ".")))
						end
					elseif v.type == "button" then
						node:setEnabled(true)
	    				node:setSwallowTouches(false)
						node:addClickEventListener(v.callfunc)
						if v.text then
							node:setTitleText(getValue(idx + 1, string.split(v.text, ".")))
						end
						if v.image then
							node:loadTextureNormal(getValue(idx + 1, string.split(v.image, ".")))
						end
					elseif v.type == "image" then
						local value = getValue(idx + 1, string.split(v.image, "."))
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
						local value = getValue(idx + 1, string.split(v.image, "."))
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
						local value = getValue(idx + 1, string.split(v.image, "."))
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
			local function func()
				cfg.updateCellfunc(self.keyArr[idx + 1], cfg.data, cell)
			end
			local ok, r = xpcall(func, __G__TRACKBACK__)
		    if not ok then
		        logw("TableView updateCellfunc error..")
		    end
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

	local cellTag = 99
	local function tableCellTouched(view, cell)
		-- logi("cell touched at index = %d", cell:getIdx())
		if cfg.clickfunc then
			cfg.clickfunc(self.keyArr[cell:getIdx() + 1])
		end
	end

	local function tableCellHighlight(view, cell)
		self.clickValid = true
		self.key = self.keyArr[cell:getIdx() + 1]
	end

	local function tableCellUnhighlight(view, cell)
		self.clickValid = false
	end

	local function cellSizeForTable(view, idx)
		if cfg.cellSizeExtend and self.selectIdx == idx then
			return cfg.cellSizeExtend.width, cfg.cellSizeExtend.height
		end
		return cfg.cellSize.width, cfg.cellSize.height
	end

	local function numberOfCellsInTableView(view)
       return nums
    end

	local function tableCellAtIndex(view, idx)
        local cell = view:dequeueCell()
        if not cell then
        	cell = cc.TableViewCell:new()
			cell:addChild(createCell(idx), 5, cellTag)
		else
			updateCell(idx, cell:getChildByTag(cellTag))
        end
        return cell
	end

    self:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	self:registerScriptHandler(tableCellTouched, CCTableView.kTableCellTouched)
	self:registerScriptHandler(tableCellHighlight, CCTableView.kTableCellHightLight)
	self:registerScriptHandler(tableCellUnhighlight, CCTableView.kTableCellUnhightLight)
	self:registerScriptHandler(cellSizeForTable, CCTableView.kTableCellSizeForIndex)
	self:registerScriptHandler(tableCellAtIndex, CCTableView.kTableCellSizeAtIndex)
	self:reloadData()
end

function TableViewEx:updateConfigData(data, initial, isAction)
	local cfg = self.cfg
	cfg.data = data
	self.keyArr = table.keys(data)
	local nums = #self.keyArr
	if cfg.sortfunc then
		cfg.sortfunc(self.keyArr)
	else
		table.sort(self.keyArr)
	end

	local function numberOfCellsInTableView(view)
       return nums
    end
    self:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

    local offset = self:getContentOffset()
	if offset.y < cfg.size.height - (nums - 1) * cfg.cellSize.height then
		self:reload(true, isAction)
	else
		local init = nums <= math.floor(cfg.size.height/cfg.cellSize.height) and true or false
		if init then
			self:reload(init, isAction)
		else
			self:reload(initial, isAction)
		end
	end
end

function TableViewEx:updateConfigUpdateFunc(func, initial, isAction)
	local cfg = self.cfg
	cfg.updateCellfunc = func
	self:reload(initial, isAction)
end

function TableViewEx:reload(initial ,isAction)
	local offset = self:getContentOffset()
	if not isAction then
    	self.playFlag = false
	end
	self:reloadData()
	if not initial then
		self:setContentOffset(offset)
	end
    self.playFlag = true
end

function TableViewEx:extendCell(key)
	local isExtend
	local idx = key or (self.key - 1)
	if self.selectIdx == idx then
		self.selectIdx = -1
		isExtend = false
	else
		self.selectIdx = idx
		isExtend = true
	end

	isExtend 	= isExtend and self.isExtend

	local offset = self:getContentOffset()
	if not self.canExtend then
		self:setContentOffset(offset)
	else
		self:reloadData()
		if self.isExtend and isExtend then
			self:setContentOffset(offset)
		else
			if self.selectIdx ~= -1 then
				self.isExtend = true
				self:setContentOffset(cc.pSub(offset, cc.p(0, self.cfg.cellSizeExtend.height - self.cfg.cellSize.height)))
			else
				self.isExtend = false
				self:setContentOffset(cc.pAdd(offset, cc.p(0, self.cfg.cellSizeExtend.height - self.cfg.cellSize.height)))
			end
		end
	end
end

function TableViewEx:getClickValid()
	return self.clickValid
end

function TableViewEx:getKeyByIdx(idx)
	if self.keyArr then
		return self.keyArr[idx + 1]
	end
end

function TableViewEx:getKey()
	return self.key
end
