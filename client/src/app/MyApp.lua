
require("config")
require("cocos.init")
require("framework.init")
require("packages.global")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:enterScene("MainScene")

   --[[
    -- local scene = display.newScene("jc")
    local SceneBase = g.mvc.scenebase
    g.logger.d(SceneBase)
    local scene = SceneBase:create()

    g.logger.i(scene)
    
    local PanelBase = g.mvc.panelbase

    local panel = PanelBase:create()
    g.logger.i(panel)

    panel:open(scene)

    -- ]] --
end

return MyApp
