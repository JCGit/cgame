
--1、extand lua

require('packages.extands.functions')
require('packages.extands.string')
require('packages.extands.table')

--2、extand cc
require('packages.extands.ListenerEx')
require('packages.extands.ListViewEx')
-- require('packages.extands.TableViewEx')

--3、global
local g = g or {}
cc.exports.g = g


table.merge(g, cc.load("utils"))

g.mvc 				= cc.load("mvc")

g.logger.d(g.mvc)


