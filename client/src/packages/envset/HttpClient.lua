local HttpClient = HttpClientLua:getInstance()

function HttpClient.doGetFile(url)

	local fileCompleted = function(code, data)

		local arr = string.split(url, '/')
	    local filename = arr[#arr]
		if code == 200 then
	    	io.writefile(filename, data, 'wb')
		else

			logf("httpcompleted error:%d.", code)
		end

	    logf('httpclient getfile:%s success, len:%d.', filename, #data)
	end

	HttpClient:doGet(url, fileCompleted)
end

return HttpClient


