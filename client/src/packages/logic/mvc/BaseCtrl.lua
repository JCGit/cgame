local BaseCtrl = class("BaseCtrl")

function BaseCtrl:ctor( )
	
	if self.onCreate then 
		self:onCreate() 
		self:load()
	end
end

function BaseCtrl:load()
	if self.onLoad then self:onLoad() end
end


return BaseCtrl