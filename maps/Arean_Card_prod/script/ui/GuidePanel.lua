--- 新手引导模块: 控制新手引导的打开与关闭。
-- @module GuidePanel
-- @author changoowu
local GuidePanel = {}
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
---初始化战斗界面UI事件
function GuidePanel:init_ui_event()
    ui:register_event('CardGuideShow','setting_Panel.CardGuideBtn','click')
    --ui:register_event('UnitGuideShow','BetPanel.main_bg.UnitGuideBtn','click')
    --ui:register_event('UnitGuideShow','BattlePanel.UnitGuideBtn','click')
    ui:register_event('CardGuideHide','GuidePanel.Card','click')
    ui:register_event('UnitGuideHide','GuidePanel.Unit','click')
end

function GuidePanel:show_Guide(_switch,_type)
    ui:set_visible('GuidePanel',_switch)
    ui:set_visible('GuidePanel.'.._type,_switch)
end

-------------------------------------------------------------------------------------------------------
--------------------------------------------事件注册----------------------------------------------------
-------------------------------------------------------------------------------------------------------
---UI事件柄
up.game:event('UI-Event', function(self, player,event)
    if player ~= local_player then return end
    if event == 'CardGuideShow' then
        GuidePanel:show_Guide(true,'Card')
    end
    if event == 'UnitGuideShow' then
        GuidePanel:show_Guide(true,'Unit')
    end
    if event == 'CardGuideHide' then
        GuidePanel:show_Guide(false,'Card')
    end
    if event == 'UnitGuideHide' then
        GuidePanel:show_Guide(false,'Unit')
    end
end)

GuidePanel:init_ui_event()

return GuidePanel