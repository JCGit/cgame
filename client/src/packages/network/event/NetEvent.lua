local NetEvent = {}

NetEvent.EVT_DATA			= "NetEvent.EVT_DATA"		--只有LoginProxy需要定制这个事件
NetEvent.EVT_MESSAGE		= "NetEvent.EVT_MESSAGE"	--NetManager托管消息分发
NetEvent.EVT_CLOSE			= "NetEvent.EVT_CLOSE"		--以下事件由baseproxy截获，proxy子类处理
NetEvent.EVT_CLOSED			= "NetEvent.EVT_CLOSED"
NetEvent.EVT_CONNECTED 		= "NETEVENT.EVT_CONNECTED"
NetEvent.EVT_CONNECT_FAIL	= "NetEvent.EVT_CONNECT_FAIL"

return NetEvent