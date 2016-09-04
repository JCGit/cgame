local Download = DownloadLua:getInstance()

function Download.downloadFile(url, path, cb)
	local arr = string.split(url, '/')
    local filename = arr[#arr]

	local progress = function(bytesReceived, totalBytesReceived, totalBytesExpected)
	    cb('progress', bytesReceived, totalBytesReceived, totalBytesExpected)
	end

	local fileSuccess = function(identifier, requestURL, storagePath)
	    cb('fileSuccess', identifier, requestURL, storagePath)
	end

	local fileError = function(errorCode, errorCodeInternal, errorStr)
	    cb('fileError', errorCode, errorCodeInternal, errorStr)
	end

	local target = path .. filename
	Download:createDownloadFileTask(filename, url, target, progress, fileSuccess, fileError)
end

return Download


