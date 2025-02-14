local LordSelectPanel = {}
local local_player = up.get_localplayer()
local ui = require 'ui.local'
local round = require'game.round'
LordSelectPanel.lord_select_panel_tips_visible= false

LordSelectPanel.select_lord_timer = nil

LordSelectPanel.lord_skill_move_in,LordSelectPanel.lord_skill_move_out,LordSelectPanel.commen_skill_move_in,LordSelectPanel.commen_skill_move_out = {},{},{},{}
LordSelectPanel.lord_card_move_in ,LordSelectPanel.lord_card_move_out={},{}
LordSelectPanel.lord_select_click = {}

---将tips设置到鼠标所在位置
function LordSelectPanel:set_tips_to_mouse_pos()
    if LordSelectPanel.lord_select_panel_tips_visible then
        ui:set_ui_to_mouse_pos('LordSelectPanel.Tips')
    end
end

---初始化选人界面UI事件
function LordSelectPanel:init_lord_select_panel_ui_event()
    for i = 1,8 do
        local per_lord_skill_move_in,per_lord_skill_move_out,per_commen_skill_move_in,per_commen_skill_move_out = {},{},{},{}
        for n = 1,3 do
            table.insert(per_lord_skill_move_in,ui:new_event('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.lord_skill_list.lord_skill_'..n,'move_in'))
            table.insert(per_lord_skill_move_out,ui:new_event('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.lord_skill_list.lord_skill_'..n,'move_out'))
            table.insert(per_commen_skill_move_in,ui:new_event('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.commen_skill_list.commen_skill_'..n,'move_in'))
            table.insert(per_commen_skill_move_out,ui:new_event('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.commen_skill_list.commen_skill_'..n,'move_out'))
        end
        table.insert(LordSelectPanel.lord_skill_move_in,per_lord_skill_move_in)
        table.insert(LordSelectPanel.lord_skill_move_out,per_lord_skill_move_out)
        table.insert(LordSelectPanel.commen_skill_move_in,per_commen_skill_move_in)
        table.insert(LordSelectPanel.commen_skill_move_out,per_commen_skill_move_out)
        table.insert(LordSelectPanel.lord_card_move_in,ui:new_event('LordSelectPanel.main.lordcard_'..i,'move_in'))
        table.insert(LordSelectPanel.lord_card_move_out,ui:new_event('LordSelectPanel.main.lordcard_'..i,'move_out'))
        table.insert(LordSelectPanel.lord_select_click,ui:new_event('LordSelectPanel.main.lordcard_'..i..'.select_btn','click'))
        ui:vx_event('LordSelectPanel.main.lordcard_'..i..'.my_select','in',33,'in',5)
        ui:vx_event('LordSelectPanel.main.lordcard_'..i..'.Ban','in',31,'in',5)
    end
end

local my_choise
local chosen_lord = {}
---控制领主选择界面的显示
---@param _switch boolean 显示或隐藏
function LordSelectPanel:show_lord_select_panel(_switch)
    my_choise = false
    ui:set_visible('LordSelectPanel',_switch)
    ui:set_text('LordSelectPanel.main.title','Pick Your Lord!')
    for i = 1 , 8 do
        ui:set_image('LordSelectPanel.main.lordcard_'..i..'.lordcard_img',config.LordData[i].img)
        ui:set_text('LordSelectPanel.main.lordcard_'..i..'.lordcard_name_bg.lordcard_name',gameapi.get_unit_name_by_type(config.LordData[i].unit))
        ui:set_text('LordSelectPanel.main.lordcard_'..i..'.lordcard_img.des_bg.des',gameapi.get_unit_desc_by_type(config.LordData[i].unit))
        for n = 1,3 do
            if config.LordData[i]['LordSkill_'..n] ~= 0 then
                ui:set_visible('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.lord_skill_list.lord_skill_'..n,true)
                ui:set_image('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.lord_skill_list.lord_skill_'..n..'.img',gameapi.get_icon_id_by_ability_type(config.LordData[i]['LordSkill_'..n]))
            else
                ui:set_visible('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.lord_skill_list.lord_skill_'..n,false)
            end
            if config.LordData[i]['CommenSkill_'..n] ~= 0 then
                ui:set_visible('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.commen_skill_list.commen_skill_'..n,true)
                ui:set_image('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.commen_skill_list.commen_skill_'..n..'.img',gameapi.get_icon_id_by_ability_type(config.LordData[i]['CommenSkill_'..n]))
            else
                ui:set_visible('LordSelectPanel.main.lordcard_'..i..'.lord_skill_bg.skill_list.commen_skill_list.commen_skill_'..n,false)
            end
        end
    end

    if _switch  then
        GameAPI.set_render_option("FocusDistance", 50)
        LordSelectPanel.select_lord_timer = up.loop(0.2,function ()
                if round.select_lord_timer then
                    ui:set_text('LordSelectPanel.main.countdown_bg.countdown_txt',string.format("%d",round.select_lord_timer:get_remaining()))

                    if round.select_lord_timer:get_remaining() > config.GlobalConfig.SELECT_COUNTDOWN_SHOW_TIME then
                        ui:set_visible('LordSelectPanel.main.countdown_bg',false)
                    else
                        ui:set_visible('LordSelectPanel.main.countdown_bg',true)
                    end
                else
                    LordSelectPanel.select_lord_timer:remove()
                end
            end)
    elseif LordSelectPanel.select_lord_timer then
        LordSelectPanel.select_lord_timer:remove()
    end
end

---控制领主牌的悬浮逻辑
---@param _switch boolean 进入或离开悬浮
---@param _lord_order integer 第几个领主
function LordSelectPanel:lord_card_hover(_switch,_lord_order)
    ui:set_visible('LordSelectPanel.main.lordcard_'.._lord_order..'.lordcard_img.des_bg',_switch)
    ui:set_text('LordSelectPanel.main.lordcard_'.._lord_order..'.lordcard_img.des_bg.des',gameapi.get_unit_desc_by_type(config.LordData[_lord_order].unit))
    ui:set_visible('LordSelectPanel.main.lordcard_'.._lord_order..'.hover',_switch)
    if not my_choise then
        local is_chosen = false
        for _,v in pairs(chosen_lord) do 
            if v == _lord_order then
                is_chosen = true
            end
        end
        if not is_chosen then
            ui:set_visible('LordSelectPanel.main.lordcard_'.._lord_order..'.select_btn',_switch)
        end
    end
end

---选择领主按钮的事件处理
---@param _player player 点击选择按钮的玩家
---@param _lord_order integer 第几个领主
function LordSelectPanel:select_lord_btn_click(_player,_lord_order)
    for _,v in pairs(chosen_lord) do 
        if v == _lord_order then
            return
        end
    end

    ui:set_visible('LordSelectPanel.main.lordcard_'.._lord_order..'.player_name',true)
    ui:set_visible('LordSelectPanel.main.lordcard_'.._lord_order..'.select_btn',false)
    ui:set_text('LordSelectPanel.main.lordcard_'.._lord_order..'.player_name',_player:get_name())
    
    if _player ~= local_player then
        ui:set_visible('LordSelectPanel.main.lordcard_'.._lord_order..'.Ban',true)
        ui:vx_play('LordSelectPanel.main.lordcard_'.._lord_order..'.Ban',31,'in')
        ui:set_visible('LordSelectPanel.main.lordcard_'.._lord_order..'.selected_state',true)
    else
        ui:set_visible('LordSelectPanel.main.lordcard_'.._lord_order..'.my_select',true)
        ui:vx_play('LordSelectPanel.main.lordcard_'.._lord_order..'.my_select',33,'in')
        ui:play_2d_sound(config.LordData[_lord_order].Vo_Sel)
        local_player.is_select_lord = true
    end

    up.game:event_dispatch('UI事件-选择领主',_player,_lord_order)
end


---最终确认选人名单的时候刷新界面
function LordSelectPanel:confirm_lord_info()
    ui:set_image('LordSelectPanel.main.header.title_1',133002)
    for i = 1,4 do
        local v = up.player(i)
        ui:set_visible('LordSelectPanel.main.lordcard_'..i..'.select_btn',false)
        if v.lord_id then
            for k1,v1 in pairs(config.LordData) do
                if k1 == v.lord_id then
                    if v ~= local_player then
                        ui:set_visible('LordSelectPanel.main.lordcard_'..k1..'.Ban',true)
                        ui:set_visible('LordSelectPanel.main.lordcard_'..k1..'.selected_state',true)
                    else
                        ui:set_visible('LordSelectPanel.main.lordcard_'..k1..'.my_select',true)
                        if not local_player.is_select_lord then
                            ui:play_2d_sound(config.LordData[v.lord_id].Vo_Sel)
                        end
                    end
                    --ui:set_image('LordSelectPanel.main.lordcard_'..k1..'lordcard_img',v1.img)
                    --ui:set_image('LordSelectPanel.main.lordcard_'..k1..'lord_skill',v1.Skill_1)
                    --ui:set_image('LordSelectPanel.main.lordcard_'..k1..'commen_skill',v1.Skill_3)
                    ui:set_visible('LordSelectPanel.main.lordcard_'..k1..'.player_name',true)
                    ui:set_text('LordSelectPanel.main.lordcard_'..k1..'.player_name',v:get_name())
                    chosen_lord[k1] = k1
                end
            end
        end
    end
    for k ,v in pairs(config.LordData) do 
        if not chosen_lord[k] then
            chosen_lord[k] = k
        end
    end

end

---控制领主技能的tips展示
---@param _switch boolean 显示或隐藏
---@param _lord_order integer UI面板第几个领主的技能
---@param _skill_order integer 第几个领主技能 
function LordSelectPanel:show_lord_skill_tips(_switch,_lord_order,_skill_order)
    LordSelectPanel.lord_select_panel_tips_visible = _switch
    ui:set_visible('LordSelectPanel.Tips',_switch)
    ui:set_visible('LordSelectPanel.Tips.Title.ico',true)
    ui:set_text('LordSelectPanel.Tips.Title.Text',gameapi.get_ability_name_by_type(config.LordData[_lord_order]['LordSkill_'.._skill_order]))
    ui:set_text('LordSelectPanel.Tips.Detail.Text',gameapi.get_ability_desc_by_type(config.LordData[_lord_order]['LordSkill_'.._skill_order]))
end

---控制领主通用技能的tips展示
---@param _switch boolean 显示或隐藏
---@param _lord_order integer UI面板第几个领主的技能
---@param _skill_order integer 第几个领主技能
function LordSelectPanel:show_commen_skill_tips(_switch,_lord_order,_skill_order)
    LordSelectPanel.lord_select_panel_tips_visible = _switch
    ui:set_visible('LordSelectPanel.Tips',_switch)
    ui:set_visible('LordSelectPanel.Tips.Title.ico',false)
    ui:set_text('LordSelectPanel.Tips.Title.Text',gameapi.get_ability_name_by_type(config.LordData[_lord_order]['CommenSkill_'.._skill_order]))
    ui:set_text('LordSelectPanel.Tips.Detail.Text',gameapi.get_ability_desc_by_type(config.LordData[_lord_order]['CommenSkill_'.._skill_order]))
end

---锁定领主事件柄
function LordSelectPanel:lock_lord()
    self:confirm_lord_info()
    self.lock_countdown_timer = up.wait(config.GlobalConfig.SELECT_LORD_CONFIRM_TIME,function ()
        self.lock_countdown_loop:remove()
    end)
    up.wait(1,function ()
        ui:set_visible('LordSelectPanel.main.countdown_bg',true)
    end)
    self.lock_countdown_loop = up.loop(1,function ()
        ui:set_text('LordSelectPanel.main.countdown_bg.countdown_txt',string.format("%d",self.lock_countdown_timer:get_remaining()))
    end)
end

up.game:event('Mouse-Move',function (_,player)
    if player ~= local_player then
        return
    end
    LordSelectPanel:set_tips_to_mouse_pos()
end)

up.game:event('主流程-选择领主',function (_,_switch)
    LordSelectPanel:show_lord_select_panel(_switch)
end)

up.game:event('玩家选择领主',function(_,_player,_lord_id)
    if _player == local_player then my_choise = _lord_id end
    table.insert(chosen_lord,_lord_id)
end)


up.game:event('主流程-强制选择领主',function (_)
    LordSelectPanel:confirm_lord_info()
end)

up.game:event('主流程-锁定领主',function()
    LordSelectPanel:lock_lord()
    ui:play_2d_sound(134256933)
end)

up.game:event('UI-Event', function(self, player,event)
    for k,v in pairs(LordSelectPanel.lord_select_click) do
        if event == v then
            LordSelectPanel:select_lord_btn_click(player,k)
            return
        end
    end

    if player ~= local_player then return end
    
    for k,v in pairs(LordSelectPanel.lord_card_move_in) do
        if event == v then
            LordSelectPanel:lord_card_hover(true,k)
            ui:play_2d_sound(134253965)
            return
        end
    end
    for k,v in pairs(LordSelectPanel.lord_card_move_out) do
        if event == v then
            LordSelectPanel:lord_card_hover(false,k)
            return
        end
    end
    for k, v in pairs(LordSelectPanel.lord_skill_move_in) do
        for k1,v1 in pairs(v) do
            if v1 == event then
                LordSelectPanel:show_lord_skill_tips(true,k,k1)
                return
            end
        end
    end
    for k, v in pairs(LordSelectPanel.lord_skill_move_out) do
        for k1,v1 in pairs(v) do
            if v1 == event then
                LordSelectPanel:show_lord_skill_tips(false,k,k1)
                return
            end
        end
    end
    for k, v in pairs(LordSelectPanel.commen_skill_move_in) do
        for k1,v1 in pairs(v) do
            if v1 == event then
                LordSelectPanel:show_commen_skill_tips(true,k,k1)
                ui:play_2d_sound(134253965)
                return
            end
        end
    end
    for k, v in pairs(LordSelectPanel.commen_skill_move_out) do
        for k1,v1 in pairs(v) do
            if v1 == event then
                LordSelectPanel:show_commen_skill_tips(false,k,k1)
                return
            end
        end
    end
end)


--LordSelectPanel:init_lord_select_panel_ui_event()

return LordSelectPanel