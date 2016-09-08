--[[
    File            :   simp2trad.lua
    Description     :   简繁转换器 lua实现
    Author          :   Edward Chan
    Date            :   2016-08-17

    Copyright (C) 2016 - All Rights Reserved.
]]



-----------------------------华丽的分割线-------------------------------------
--Trie树节点
local TrieNode = class("TrieNode")

function TrieNode:ctor(key)
	self.level = 0
	self.key = key
	self.children = {}
	self.leaf = false
	self.vaule = ""
end

function TrieNode:getKey()
	return self.key
end

function TrieNode:setKey(key)
	self.key = key
end

function TrieNode:isLeaf()
	return self.leaf
end

function TrieNode:setLeaf(leaf)
	self.leaf = leaf
end


function TrieNode:getValue()
	return self.value
end

function TrieNode:setValue(value)
	self.value = value
end

function TrieNode:addChild(k)
	local node = TrieNode:create(k)
	node.level = self.level + 1
	self.children[k] = node
	return node
end

function TrieNode:child(k)
	return self.children[k]
end

function TrieNode:getLevel()
	return self.level
end

function TrieNode:setLevel(level)
	self.level = level
end

function TrieNode:toString()
	local str = self.key
	if self.value ~= nil then
		str = string.format("%s:%s", str, self.value)
	end
	return str
end

-----------------------------华丽的分割线-------------------------------------
--Trie树
local Trie = class("Trie")

function Trie:ctor()
	self.root = TrieNode:create(" ")
end

function Trie:add(word, value)
	if string.len(word) < 1 then return end

	local node = self.root
	local uchars = string.splitUtf8(word)
	for i,v in ipairs(uchars) do
		local n = node:child(v)
		if not n then
			n = node:addChild(v)
		end
		node = n
	end
	node:setLeaf(true)
	node:setValue(value)
end

function Trie:match(sen, offset, len)
	local node = self.root
	for i,v in ipairs(sen) do
		node = node:child(v)
		if not node then
			return nil
		end
	end
	return node
end

function Trie:bestMatch(sen, offset, len)
	local ret = nil
	local node = self.root
	for i=offset,len do
		node = node:child(sen[i])
		if node then
			if node:isLeaf() then
				ret = node
			end
		else
			break
		end
	end
	return ret
end

-----------------------------华丽的分割线-------------------------------------
--转换器
local Converter = class("Converter")

-- local CJK_UNIFIED_IDEOGRAPHS_START = "\\u4E00"
-- local CJK_UNIFIED_IDEOGRAPHS_END = "\\u9FA5"
local SIMPLIFIED_MAPPING_FILE = "res/simp2trad/simp.txt"
local SIMPLIFIED_LEXEMIC_MAPPING_FILE = "res/simp2trad/simplified.txt"
local TRADITIONAL_MAPPING_FILE = "res/simp2trad/trad.txt"
local TRADITIONAL_LEXEMIC_MAPPING_FILE = "res/simp2trad/traditional.txt"
local UNKOWNN_LEXEMIC_MAPPING_FILE = "res/simp2trad/unknown.txt"
local EQUAL = "="

function Converter:ctor(s2t)
	self.maxLen = 20
	self:loadCharMapping(s2t)
	self:loadLexemicMapping(s2t)
end

function Converter:loadCharMapping(s2t)
	-- local mappingFile = s2t and TRADITIONAL_MAPPING_FILE or SIMPLIFIED_MAPPING_FILE
	-- local input = io.readfile(mappingFile)
	-- self.chars = string.split(input, "\n")
	-- local start = timeStart()
	local simp = string.split(cc.FileUtils:getInstance():getStringFromFile(SIMPLIFIED_MAPPING_FILE), "\n")
	local trad = string.split(cc.FileUtils:getInstance():getStringFromFile(TRADITIONAL_MAPPING_FILE), "\n")
	self.chars = {}
	if s2t then
		for i,v in ipairs(simp) do
			self.chars[v] = trad[i]
		end
	else
		for i,v in ipairs(trad) do
			self.chars[v] = simp[i]
		end
	end
	-- timeStop(start)
end

function Converter:loadLexemicMapping(s2t)
	local mappingFile = s2t and TRADITIONAL_LEXEMIC_MAPPING_FILE or SIMPLIFIED_LEXEMIC_MAPPING_FILE
	self.dict = Trie:create()

	-- local start = timeStart()
	local input = cc.FileUtils:getInstance():getStringFromFile(mappingFile)
	local arr = string.split(input, "\n")
	local pair
	for i,v in ipairs(arr) do
		pair = string.split(v, EQUAL)
		if #pair == 2 then
			self.dict:add(pair[1], pair[2])
		end
	end

	input = cc.FileUtils:getInstance():getStringFromFile(UNKOWNN_LEXEMIC_MAPPING_FILE)
	arr = string.split(input, "\n")
	local pair
	for i,v in ipairs(arr) do
		pair = string.split(v, EQUAL)
		if #pair == 2 then
			self.dict:add(pair[1], " ")
		end
	end
	-- timeStop(start)
end

function Converter:convertCh(ch)
	local uchar = self.chars[ch]
	if uchar then
		return uchar
	else
		return ch
	end
end

function Converter:convert(str)
	-- local start = timeStart()
	local uchars, len = string.splitUtf8(str)
	if not len or len == 0 then return "" end

	local output = {}
	local node
	local idx = 1
	while idx <= len do
		node = self.dict:bestMatch(uchars, idx, len)
		if node then
			local level = node:getLevel()
			output[#output+1] = node:getValue()
			idx = idx + level
		else
			output[#output+1] = self:convertCh(uchars[idx])
			idx = idx + 1
		end
	end

	-- for i,v in ipairs(output) do
	-- 	output[i] = self:convertCh(v)
	-- end
	-- timeStop(start)
	return table.concat(output, "")
end

return Converter





--TODO:外部代码
-- -- 简繁转换器
-- local Converter = import(".simp2trad")
-- local converter = Converter:create(CC_ENV_CONFIG == 2 or CC_ENV_CONFIG == 4)
-- local function simp2trad(str)
--    return converter:convert(str)
-- end
-- utils.simp2trad = simp2trad