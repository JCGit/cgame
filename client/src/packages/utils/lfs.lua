--[[
file: fs.lua [file system]
desc: 文件系统相关api接口
]]

local lfs = require('lfs')

local _searchPaths = {--[['/upd/', ]]'/src/'}

function lfs.dirfiles(relative)
	local infolist = {}

	local curdir = lfs.currentdir()

	for k,v in pairs(_searchPaths) do
		local datadir = curdir .. v .. relative

		local attr = lfs.attributes(datadir)

		if attr and attr.mode == "directory" then

			for file in lfs.dir (datadir) do
				if file ~= '.' and file ~= '..' then
					if not infolist[file] then
						infolist[file] = v .. relative .. '/' .. file
					end
				end
			end
		else
			logw(string.format("dir:%s not exists.", datadir))
		end
	end
    return infolist
end

return lfs
