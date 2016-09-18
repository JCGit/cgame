
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

    -- self:enterScene("LoginScene")

    local loginScene = require("app.Login.LoginScene")
    -- local loginScene = g.mvc.SceneBase
    local scene = loginScene.new()
    display.replaceScene(scene)

    -- local scenebase  = g.mvc.SceneBase

    -- local scene = scenebase.new()


end

return MyApp
