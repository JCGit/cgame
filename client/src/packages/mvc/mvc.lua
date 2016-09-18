local mvc = cc.mvc

--TODO: 扩展viewBase
-- local ViewBase = import("")

--TODO: 扩展ViewMgr
-- local ViewMgr = import("")

--TODO: 扩展SceneBase
local SceneBase = import(".scenebase")

--TODO: 扩展SceneMgr
-- local SceneMgr = import("")

mvc.ViewBase 	= ViewBase
mvc.SceneBase 	= SceneBase

return mvc, SceneMgr
--[[
	scenemgr 
		|   \
		|    \
		|     \
     scene1 scene2
	 	|
	 	|
	 	|
	 viewmgr
	    |	 \
	    |	  \
	  view1	  view2
]]