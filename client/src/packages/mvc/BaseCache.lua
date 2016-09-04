local BaseCache = class("BaseCache")

function BaseCache:ctor( )
	assert(self.onCreate , "no cache onCreate")
	if self.onCreate then 
		self:onCreate() 
		self:load()
	end
end

function BaseCache:load()
	if self.onLoad then self:onLoad() end
end


return BaseCache