
--1、extand lua

-- require('packages.extands.functions')
-- require('packages.extands.string')
-- require('packages.extands.table')

--2、extand cc
-- require('packages.extands.ListenerEx')
-- require('packages.extands.ListViewEx')
-- require('packages.extands.TableViewEx')

--3、core
local _M = {}

_M.EventCenter 		= cc.load("eventcenter")
_M.Utils 			= cc.load("utils")
_M.mvc 				= cc.load("mvc")


--4、ui

return _M