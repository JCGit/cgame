
local SOCKET_TICK_TIME 				= 0.02 	-- check socket data interval
local SOCKET_RECONNECT_TIME 		= 5		-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT 	= 3		-- socket failure timeout
		
local STATUS_CLOSED 				= "closed"
local STATUS_NOT_CONNECTED 			= "Socket is not connected"
local STATUS_ALREADY_CONNECTED 		= "already connected"
local STATUS_ALREADY_IN_PROGRESS 	= "Operation already in progress"
local STATUS_TIMEOUT 				= "timeout"

local scheduler 	= cc.Director:getInstance():getScheduler()
local netevent 		= import(".event.NetEvent")
local socket 		= require "socket"
local Session 		= class("Session")
Session._VERSION 	= socket._VERSION
Session._DEBUG 		= socket._DEBUG

function Session.getTime()
	return socket.gettime()
end

function Session:ctor(host, port, retryConnectWhenFailure)
    self.host = host
    self.port = port
	self.tickScheduler = nil			-- timer for data
	self.reconnectScheduler = nil		-- timer for reconnect
	self.connectTimeTickScheduler = nil	-- timer for connect timeout
	self.name = 'Session'
	self.tcp = nil
	self.isRetryConnect = retryConnectWhenFailure
	self.isConnected = false
	self.mode = 0						-- 0 for data and 1 for message

	cc.bind(self, "event")
end

function Session:setMode(mode)
	self.mode = mode
	return self
end

function Session:connect(host, port, retryConnectWhenFailure)
	if host then self.host = host end
	if port then self.port = port end
	if retryConnectWhenFailure then self.isRetryConnect = retryConnectWhenFailure end

	logf("session:connect ip:%s port:%d.", self.host, self.port)
	assert(self.host or self.port, "Host and port are necessary!")
	--printInfo("%s.connect(%s, %d)", self.name, self.host, self.port)

	local ipv6_only = false
	local addrinfo, err = socket.dns.getaddrinfo(tostring(self.host))
	if addrinfo then
		for k,v in pairs(addrinfo) do
			if v.family == 'inet6' then
				-- self.host = v.addr
				ipv6_only = true
			end
		end
	end

	if ipv6_only then
		self.tcp = socket.tcp6()
	else
		self.tcp = socket.tcp()
	end

	self.tcp:settimeout(0)

	local function checkConnect()
		local succ = self:_connect()
		if succ then
			self:_onConnected()
		end
		return succ
	end

	-- check whether connection is success
	-- the connection is failure if socket isn't connected after SOCKET_CONNECT_FAIL_TIMEOUT seconds
	local function connectTimeTick()
		--printInfo("%s.connectTimeTick", self.name)
		if self.isConnected then return end
		self.waitConnect = self.waitConnect or 0
		self.waitConnect = self.waitConnect + SOCKET_TICK_TIME

		if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
			self.waitConnect = nil
			self:close()
			self:_connectFailure()
		end
		checkConnect()
	end

	if not checkConnect() then
		self.connectTimeTickScheduler = scheduler:scheduleScriptFunc(connectTimeTick, SOCKET_TICK_TIME, false)
	end
end

function Session:send(__data)
	assert(self.isConnected, self.name .. " is not connected.")
	--logi(string.format("session:send len:%d,data:%s.", #__data, __data))
	self.tcp:send(__data)
end

function Session:close(noMsg)
	printInfo("session:close ip:%s port:%d.", self.host, self.port)
	self.tcp:close()
	if self.connectTimeTickScheduler then
		scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler)
		self.connectTimeTickScheduler = nil
	end
	if self.tickScheduler then scheduler:unscheduleScriptEntry(self.tickScheduler) end
	if not noMsg then
		g.eventcenter:dispatchEvent({name=netevent.EVT_CLOSE})
	end
end

-- disconnect on user's own initiative.
function Session:disconnect()
	self:_disconnect()
	self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

--------------------
-- private
--------------------

--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function Session:_connect()

	self.tcp:connect(self.host, self.port)
	local __succ, __status = self.tcp:connect(self.host, self.port)
	-- print("Session._connect:", __succ, __status)
	return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function Session:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
	g.eventcenter:dispatchEvent({name=netevent.EVT_CLOSE})
end

function Session:_onDisconnect()
	--printInfo("%s._onDisConnect", self.name);
	self.isConnected = false
	g.eventcenter:dispatchEvent({name=netevent.EVT_CLOSED})
	-- self:_reconnect()
end

-- connecte success, cancel the connection timerout timer
function Session:_onConnected()
	--printInfo("%s._onConnectd", self.name)
	self.isConnected = true
	g.eventcenter:dispatchEvent({name=netevent.EVT_CONNECTED})

	if self.connectTimeTickScheduler then
		scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler)
		self.connectTimeTickScheduler = nil
	end

	local __tick = function()
		if self.mode == 0 then
			self:recvLine()
		else
			self:recvMsg()
		end
	end

	-- start to read TCP data
	self.tickScheduler = scheduler:scheduleScriptFunc(__tick, SOCKET_TICK_TIME, false)
end

function Session:_connectFailure(status)
	g.eventcenter:dispatchEvent({name=netevent.EVT_CONNECT_FAIL})
	-- self:_reconnect()
end

-- if connection is initiative, do not reconnect
function Session:_reconnect(__immediately)
	--[[if not self.isRetryConnect then return end
	--printInfo("%s._reconnect", self.name)
	if __immediately then self:connect() return end
	if self.reconnectScheduler then scheduler:unscheduleScriptEntry(self.reconnectScheduler) end
	local __doReConnect = function ()
		self:connect()
	end

	--TODO: j.c.
	--self.reconnectScheduler = scheduler:performWithDelayGlobal(__doReConnect, SOCKET_RECONNECT_TIME)
	]]
end

function Session:_recvCheckConnect(status)
	if status == STATUS_CLOSED or status == STATUS_NOT_CONNECTED then
    	self:close(true)
    	if self.isConnected then
    		self:_onDisconnect()
    	else
    		self:_connectFailure()
    	end
	end
end

function Session:validMsg(body, partial)
	--返回是否是有效消息结构
	if (body and string.len(body)==0) or
		(partial and string.len(partial)==0) then
		return nil
	else

		if not body or not partial then
			return body or partial
		elseif body and partial then
			return body .. partial
		end
	end
end

function Session:recvMsg()
	--1、fisrt read message length
	local __body, __status, __partial = self.tcp:receive(2)
	self:_recvCheckConnect(__status)

	local msg = self:validMsg(__body, __partial)
	if not msg then return end
	assert(#msg == 2, 'Session recvMsg msg length not 2!')

	local recved, total = 0
	total = string.byte(msg, 1) * 256 + string.byte(msg, 2)
	if total <= 0 then return end
	--logi(string.format("need recv msg len:%d.", total))

	recved = 0
	--2、loop receive last message body
	self.msg = ""
	while (recved < total) do

		local lastRecv = total - recved
		local __body, __status, __partial = self.tcp:receive(lastRecv)
		self:_recvCheckConnect(__status)

		local msg = self:validMsg(__body, __partial)
		if not msg then break end

		recved = recved + #msg
		self.msg = self.msg .. msg
		--logi(string.format("now received:%d.", recved))
	end

	g.eventcenter:dispatchEvent({name=netevent.EVT_MESSAGE, data=self.msg})
	self.msg = ""
end

function Session:recvLine()
	-- if use "*l" pattern, some buffer will be discarded, why?
	local body, status, partial = self.tcp:receive("*a")	-- read the package body
	--print("body:", body, "status:", status, "partial:", partial)
    self:_recvCheckConnect(status)

    local msg = self:validMsg(body, partial)
    if not msg then return end

    g.eventcenter:dispatchEvent({name=netevent.EVT_DATA, data=msg})
end

return Session
