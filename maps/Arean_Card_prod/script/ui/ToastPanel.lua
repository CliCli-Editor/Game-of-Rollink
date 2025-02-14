--- 游戏UI管理模块: 领主选择界面、下注界面、战斗界面、结算界面的交互逻辑相关。
-- @module GameUI
-- @author changoowu
local ToastPanel = {}
local local_player = up.get_localplayer()
local ui = require 'ui.local'

-------------------------------------------------------------------------------------------------------
-----------------------------------------公用的方法-----------------------------------------------------
-------------------------------------------------------------------------------------------------------

---多人联机状态下调试用的print
---@param txt string 文本
--local function print(txt)
--    txt = tostring(txt)
 --   local_player:msg(txt)
--end

-------------------------------------------------------------------------------------------------------
-----------------------------------------通知界面的方法-------------------------------------------------
-------------------------------------------------------------------------------------------------------
function ToastPanel:show_toast(text)
    if not local_player.is_watching then
        ui:set_visible('ToastPanel',true)
        ui:set_visible('ToastPanel.toast',true)
        ui:set_text('ToastPanel.toast.toast_txt',text)
        ui:wait(3,function ()
            ui:set_visible('ToastPanel',false)
            ui:set_visible('ToastPanel.toast',false)
        end)
    else
        ui:set_visible('ToastPanel',true)
        ui:set_visible('ToastPanel.Observe',true)
        ui:set_text('ToastPanel.Observe.toast_txt','%watching_text')
    end
end

-------------------------------------------------------------------------------------------------------
--------------------------------------------事件注册----------------------------------------------------
-------------------------------------------------------------------------------------------------------

return ToastPanel