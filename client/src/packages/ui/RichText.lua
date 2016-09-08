
local RichLabel = class("RichLabel", function()
    local node = display.newNode()
    return node
end)

--[[ 公共方法
	创建方法 create
	set:
	设置文字方法 setLabelString
	设置尺寸方法 setDimensions
	get:
	获得文字实际占用尺寸 getLabelSize
]]--

RichLabel.__index = RichLabel
RichLabel._fontName = "comm/fonts/font.TTF"
RichLabel._fontSize = 30
RichLabel._fontColor = cc.c3b(255, 255, 255)
RichLabel._rowSpacing = 0	--行间距
RichLabel._dimensions = cc.size(0, 0)
RichLabel._containLayer = nil --装载layer
RichLabel._spriteBoxArray = nil
RichLabel._textStr = nil
RichLabel._maxWidth = nil
RichLabel._maxHeight = nil
RichLabel._bCenter = false

--创建方法
--[[
	local params = {
		fontName = "Arial",
		fontSize = 30,
		fontColor = cc.c3b(255, 255, 255),
        rowSpacing = 10,         --行间距
		dimensions = cc.size(300, 200),
		text = "[]hello RichText[/]",
	}

    text格式——
    []hello richText[/] --使用默认属性创建
    [fc=00000] hello richText[/fc]  --黑色文本
    [image=comm/commRes/button_fh.png][/image]  --创建图片
    [image=comm/commRes/button_fh.png]hello image[/image]  --创建图片和文本
    [fs=50 fc=ffffff image=comm/commRes/button_fh.png]hello image[/fs]  --创建图片和文本(字号50，白色)
]]--
function RichLabel:create(params)
    if params.text ~= "" then
	    local ret = RichLabel.new()
	    ret:init_(params)
        ret:setDimensions(ret:getLabelSize())
	    return ret
    else
        return ccui.Text:create("", self._fontName, self._fontSize)
    end
end

function RichLabel:init_(params)

	--装文字和图片精灵
	local containLayer = display.newLayer() --cc.LayerColor:create(cc.c3b(255,0,0))
	self:addChild(containLayer)

    --如果text的格式指定字体则使用指定字体，否则使用默认字体
	--大小和颜色同理
    self._fontName     = params.fontName or self._fontName --默认字体
    self._fontSize     = params.fontSize or self._fontSize --默认大小
    self._fontColor    = params.fontColor or self._fontColor --默认白色
    self._rowSpacing   = params.rowSpacing or self._rowSpacing    --默认行间距
    self._dimensions   = params.dimensions or self._dimensions --默认无限扩展，即沿着x轴往右扩展
    self._bCenter      = params.bCenter or self._bCenter

    self._containLayer = containLayer

    self:setLabelString(params.text)
end

--设置text
function RichLabel:setLabelString(text)
	if self._textStr == text then
		return --相同则忽略
	end

	if self._textStr then --删除之前的string
        self._spriteBoxArray = nil
		self._containLayer:removeAllChildren()
	end

	self._textStr = text

	--分段
	local parseArray = self:parseString_(text)
	--将字符串拆分成一个个字符
	self:formatString_(parseArray)
	--获得每个字的包围盒
	local spriteBoxArray = self:getSpritesBox_(parseArray)
    self._spriteBoxArray = spriteBoxArray

	self:adjustPosition_()
end

--设置尺寸
function RichLabel:setDimensions(dimensions)

	self._containLayer:setContentSize(dimensions)
	self._dimensions = dimensions

	self:adjustPosition_()
end

--获得label尺寸
function RichLabel:getLabelSize()
	local width = self._maxWidth or 0
	local height = self._maxHeight or 0
	return cc.size(width, height)
end

--调整位置（设置文字和尺寸都会触发此方法）
function RichLabel:adjustPosition_()

	--获得每个精灵的宽度和高度
	local widthArr, heightArr = self:getSizeOfSprites_(self._spriteBoxArray)
	--获得每个精灵的坐标
	local pointArrX, pointArrY = self:getPointOfSprite_(widthArr, heightArr, self._dimensions)

    local lastPosX = self._spriteBoxArray[1].PosX
	local lastPosY = self._spriteBoxArray[1].PosY
    local lastFontName = ""
    local lastFontSize = 0
    local lastFontColor = nil
    local str = ""

    --效率优化代码    思路是——相同属性的文字使用一个lable创建，以减少创建的lable数量
    self._containLayer:removeAllChildren()

    for i, boxInfo in ipairs(self._spriteBoxArray) do
        local function compareColor(color1, color2)
            if color1.r == color2.r and color1.g == color2.g and color1.b == color2.b then
                return true
            else
                return false
            end
        end

        if boxInfo.image then
            local sprite = CCSprite:create(boxInfo.image)
            if not sprite then
                sprite = CCSprite:createWithSpriteFrameName(boxInfo.image)
            end

            sprite:setPosition(cc.p(boxInfo.PosX, boxInfo.PosY))
            sprite:setAnchorPoint(cc.p(0, 0.5))
            self._containLayer:addChild(sprite)
        end


        if lastFontName ~= boxInfo.fontName
        or lastFontSize ~= boxInfo.fontSize
        or false == compareColor(lastFontColor, boxInfo.fontColor)
        or(self._spriteBoxArray[i-1] and self._spriteBoxArray[i-1].PosY ~= boxInfo.PosY) then

            --新行
            if str and str ~= "" then
                local label = ccui.Text:create(str, lastFontName, lastFontSize)
			    label:setTextColor(lastFontColor)
                label:setAnchorPoint(cc.p(0, 0.5))

                label:setPosition(cc.p(lastPosX, lastPosY))
                self._containLayer:addChild(label)
            end

            lastPosX = self._spriteBoxArray[i].PosX
	        lastPosY = self._spriteBoxArray[i].PosY

            if boxInfo.text == "\n" then
                str = ""
            else
                str = boxInfo.text
            end
        else
            --叠加字符串
            str = str..boxInfo.text
        end

        lastFontName = boxInfo.fontName
        lastFontSize = boxInfo.fontSize
        lastFontColor = boxInfo.fontColor
    end

    --添加最后一段字符串
    if str ~= "" then
        local label = ccui.Text:create(str, lastFontName, lastFontSize)
	    label:setTextColor(lastFontColor)
        label:setAnchorPoint(cc.p(0, 0.5))
        label:setPosition(cc.p(lastPosX, lastPosY))
        self._containLayer:addChild(label)
    end
end

--文字解析，按照顺序转换成数组，每个数组对应特定的标签
function RichLabel:parseString_(str)

    -- string.split()
    function RichLabel:stringSplit_(str, flag)
	    local tab = {}
	    while true do
		    local n = string.find(str, flag)
		    if n then
			    local first = string.sub(str, 1, n-1)
			    str = string.sub(str, n+1, #str)
			    table.insert(tab, first)
		    else
			    table.insert(tab, str)
			    break
		    end
	    end
	    return tab
    end

	local clumpheadTab = {} -- 标签头
	--作用，取出所有格式为[xxxx]的标签头
	for w in string.gfind(str, "%b[]") do
		if  string.sub(w,2,2) ~= "/" then-- 去尾
			table.insert(clumpheadTab, w)
		end
	end
	-- 解析标签
	local totalTab = {}
	for k,ns in pairs(clumpheadTab) do
		local tab = {}
		local tStr = ""
		-- 第一个等号前为块标签名
		string.gsub(ns, string.sub(ns, 2, #ns-1), function (w)
			local n = string.find(w, "=")
			if n then
				local temTab = self:stringSplit_(w, " ") -- 支持标签内嵌
				for k,pstr in pairs(temTab) do
					local temtab1 = self:stringSplit_(pstr, "=")

					local pname = temtab1[1]

					if k == 1 then
						tStr = pname
					end -- 标签头

					local js = temtab1[2]
					local p = string.find(js, "[^%6d.]")
        			if not p then
        				js = tonumber(js)
        			end
					local switchState = {
						["fc"]	 = function()
							tab["fc"] = self:convertColor_(js)
						end,
					} --switch end

					local fSwitch = switchState[pname] --switch 方法

					--存在switch
					if fSwitch then
						--目前只是颜色需要转换
						local result = fSwitch() --执行function
					else --没有枚举
						tab[pname] = js
						--return
					end
				end
            end
		end)

		-- 取出文本
		local beginFind,endFind = string.find(str, "%[%/"..tStr.."%]")
		local endNumber = beginFind-1
		local gs = string.sub(str, #ns+1, endNumber)
		if string.find(gs, "%[") then
			tab["text"] = gs
		else

			string.gsub(str, gs, function (w)
				tab["text"] = w
			end)

            if not tab["text"] then
                tab["text"] = gs
            end
		end
		-- 截掉已经解析的字符
		str = string.sub(str, endFind+1, #str)
		table.insert(totalTab, tab)
	end
	-- 普通格式label显示
	if table.nums(clumpheadTab) == 0 then
		local ptab = {}
		ptab.text = str
		table.insert(totalTab, ptab)
	end
	return totalTab
end

--将字符串转换成一个个字符
function RichLabel:formatString_(parseArray)

    -- 拆分出单个字符
    function RichLabel:stringToChar_(str)

        local list = {}
        local len = string.len(str)
        local i = 1
        while i <= len do
            local c = string.byte(str, i)
            local shift = 1
            if c > 0 and c <= 127 then
                shift = 1
            elseif (c >= 192 and c <= 223) then
                shift = 2
            elseif (c >= 224 and c <= 239) then
                shift = 3
            elseif (c >= 240 and c <= 247) then
                shift = 4
            end
            local char = string.sub(str, i, i+shift-1)
            i = i + shift
            table.insert(list, char)
        end
	    return list, len
    end

	for i,dic in ipairs(parseArray) do
		local text = dic.text
		if text then
			local textArr = self:stringToChar_(text)
			dic.textArray = textArr
		end
	end
end

--获得精灵包围盒
function RichLabel:getSpritesBox_(parseArray)
    --先每个字符创建一个控件，以便获得文本的box，下一帧这些空间会被remove，实际的控件会在adjustPosition_()中创建
    local spriteBoxArray = {}

	for i, dic in ipairs(parseArray) do
		local textArr = dic.textArray
		if dic.image then
			local sprite = CCSprite:create(dic.image)
            if not sprite then
                sprite = CCSprite:createWithSpriteFrameName(dic.image)
            end

            local index = #spriteBoxArray + 1
            spriteBoxArray[index] = {}
            spriteBoxArray[index].box = sprite:getBoundingBox()
            spriteBoxArray[index].image = dic.image
        end

        if #textArr > 0 then --创建文字

			local fontName = dic.fn or self._fontName
			local fontSize = dic.fs or self._fontSize
			local fontColor = dic.fc or self._fontColor

			for j, word in ipairs(textArr) do

                local label = ccui.Text:create(word, fontName, fontSize)

                local index = #spriteBoxArray + 1
                spriteBoxArray[index] = {}
                spriteBoxArray[index].box = label:getBoundingBox()
                spriteBoxArray[index].fontName = fontName
                spriteBoxArray[index].fontSize = fontSize
                spriteBoxArray[index].fontColor = fontColor
                spriteBoxArray[index].text = word
			end
        end
		--else
			--error("not define")
		--end
	end
	return spriteBoxArray
end

--[[解析16进制颜色rgb值]]
function  RichLabel:convertColor_(xStr)
    local function toTen(v)
        return tonumber("0x" .. v)
    end

    local b = string.sub(xStr, -2, -1)
    local g = string.sub(xStr, -4, -3)
    local r = string.sub(xStr, -6, -5)

    local red = toTen(r) or self._fontColor.r
    local green = toTen(g) or self._fontColor.g
    local blue = toTen(b) or self._fontColor.b
    return cc.c3b(red, green, blue)
end

function RichLabel:setAnchorPoint(point)
    self._containLayer:setAnchorPoint(point)
    self._containLayer:ignoreAnchorPointForPosition(false)
end

--获得每个精灵的尺寸
function RichLabel:getSizeOfSprites_(spriteBoxArray)
	local widthArr = {} --宽度数组
	local heightArr = {} --高度数组

	--精灵的尺寸
	for i, boxInfo in ipairs(spriteBoxArray) do
		-- local contentSize = sprite:getContentSize()
		local rect = boxInfo.box
        if boxInfo.text and "\n" == boxInfo.text then
            widthArr[i] = -1
            heightArr[i] = -1
        else
            widthArr[i] = rect.width
		    heightArr[i] = rect.height
        end
	end
	return widthArr, heightArr

end

--获得每个精灵的位置
function RichLabel:getPointOfSprite_(widthArr, heightArr, dimensions)

	local totalWidth = dimensions.width
	local totalHight = dimensions.height

	local maxWidth = 0
	local maxHeight = 0

	local spriteNum = #widthArr

	--从左往右，从上往下拓展
	local curX = 0 --当前x坐标偏移

	local curIndexX = 1 --当前横轴index
	local curIndexY = 1 --当前纵轴index

	local pointArrX = {} --每个精灵的x坐标

	local rowIndexArr = {} --行数组，以行为index储存精灵组
	local indexArrY = {} --每个精灵的行index

	--计算宽度，并自动换行
	for i, spriteWidth in ipairs(widthArr) do
		local nexX = curX + spriteWidth
		local pointX
		local rowIndex = curIndexY

		local halfWidth = spriteWidth * 0.5
		if (nexX > totalWidth and totalWidth ~= 0) or spriteWidth == -1 then --超出界限了
			pointX = halfWidth
			if curIndexX == 1 then --当前是第一个，
				curX = 0-- 重置x
			else --不是第一个，当前行已经不足容纳
				rowIndex = curIndexY + 1 --换行
				curX = spriteWidth
			end
			curIndexX = 1 --x坐标重置
			curIndexY = curIndexY + 1 --y坐标自增
		else
			pointX = curX + halfWidth --精灵坐标x
			curX = pointX + halfWidth --精灵最右侧坐标
			curIndexX = curIndexX + 1
		end
		pointArrX[i] = pointX --保存每个精灵的x坐标

        self._spriteBoxArray[i].PosX = pointX - halfWidth   --将坐标还原为从最左边开始

		indexArrY[i] = rowIndex --保存每个精灵的行

		local tmpIndexArr = rowIndexArr[rowIndex]

		if not tmpIndexArr then --没有就创建
			tmpIndexArr = {}
			rowIndexArr[rowIndex] = tmpIndexArr
		end
		tmpIndexArr[#tmpIndexArr + 1] = i --保存相同行对应的精灵

		if curX > maxWidth then
			maxWidth = curX
		end
	end

    if self._bCenter then
        local rowWidth = 0
        for key, rowIndexs in ipairs(rowIndexArr) do

            for key, index in ipairs(rowIndexs) do
                rowWidth = rowWidth + widthArr[index]
            end

            local DValue = dimensions.width - rowWidth
            if DValue > 0 then

                for key, index in ipairs(rowIndexs) do

                    self._spriteBoxArray[index].PosX = self._spriteBoxArray[index].PosX + DValue/2
                end
            end

            rowWidth = 0
        end
    end
	local curY = 0
	local rowHeightArr = {} --每一行的y坐标

	--计算每一行的高度
    local lastRow = 0
	for i, rowInfo in ipairs(rowIndexArr) do
        local rowSpacing = self._rowSpacing
		local rowHeight = 0
		for j, index in ipairs(rowInfo) do --计算最高的精灵
			local height = heightArr[index]
			if height > rowHeight then
				rowHeight = height
			end
		end

        if i > lastRow and i ~= 1 then

        else
            rowSpacing = 0
        end

		local pointY = curY + rowHeight * 0.5 --当前行所有精灵的y坐标（正数，未取反）
		rowHeightArr[#rowHeightArr + 1] = -pointY + totalHight - rowSpacing*(i-1) --从左往右，从上到下扩展，所以是负数
		curY = curY + rowHeight --当前行的边缘坐标（正数）

		if curY > maxHeight then
			maxHeight = curY
		end

        lastRow = i
	end

	self._maxWidth = maxWidth
	self._maxHeight = maxHeight

	local pointArrY = {}

	for i = 1, spriteNum do
		local indexY = indexArrY[i] --y坐标是先读取精灵的行，然后再找出该行对应的坐标
		local pointY = rowHeightArr[indexY]
		pointArrY[i] = pointY
	    self._spriteBoxArray[i].PosY = pointY
    end

	return pointArrX, pointArrY
end

return RichLabel
