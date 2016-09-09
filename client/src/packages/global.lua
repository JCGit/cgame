
--1、extand lua

-- require('packages.extands.functions')
-- require('packages.extands.string')
require('packages.extands.table')

--2、extand cc
-- require('packages.extands.ListenerEx')
-- require('packages.extands.ListViewEx')
-- require('packages.extands.TableViewEx')

--3、global
local g = g or {}
cc.exports.g = g


table.merge(g, cc.load("utils"))

--[[
-- test logger
local t = {a=1, b=2}
g.logger.n("11")
g.logger.i("22")

g.logger.f("%d", 33)
g.logger.w("44")
-- g.logger.e("55")
]]

g.eventcenter 		= cc.load("eventcenter")

g.mvc 				= cc.load("mvc")

-- g.logger.d(g.mvc)


