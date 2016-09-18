local controlbase = class("controlbase")

function controlbase:ctor( )

	if self.onCreate then self:onCreate() end

end

function controlbase:load()
	if self.onLoad then self:onLoad() end
end


return controlbase