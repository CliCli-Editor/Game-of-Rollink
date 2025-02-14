--- 游戏UI管理模块: 领主选择界面、下注界面、战斗界面、结算界面的交互逻辑相关。
-- @module GameUI
-- @author changoowu
local ResultPanel = {}
local local_player = up.get_localplayer()
local ui = require 'ui.local'
local round = require'game.round'
local rank_num_img = {108461,108462,108463,108464,108465,108466,108467,108468}
local ToastPanel = require 'ui.ToastPanel'
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
-----------------------------------------结算界面的方法-------------------------------------------------
-------------------------------------------------------------------------------------------------------
---初始化ui事件和vx事件。
local function init_result_panel_ui_event()
    gameapi.set_show_room_background_color(local_player._base, "41eb839b-fe7f-432a-8364-5e4b2002f3ba", Fix32(0.0), Fix32(0.0), Fix32(0.0), Fix32(0.0))
    gameapi.set_show_room_background_color(local_player._base, "02752bd3-b6c3-4086-bf37-d547f4d22284", Fix32(0.0), Fix32(0.0), Fix32(0.0), Fix32(0.0))
    gameapi.set_show_room_background_color(local_player._base, "7e695035-640d-42e6-97c1-01a4b7015489", Fix32(0.0), Fix32(0.0), Fix32(0.0), Fix32(0.0))
    ui:vx_event('ResultPanel.win.Title','in',12,'in',48)
    ui:vx_event('ResultPanel.lose.Title','in',13,'in',25)
    ui:vx_event('ResultPanel.finish.Title','in',13,'in',25)
    ui:vx_event('ResultPanel.win.Title','fade_in_win',12,'in',25)
    ui:vx_event('ResultPanel.lose.Title','fade_in_lose',13,'in',15)
    ui:vx_event('ResultPanel.finish.Title','fade_in_finish',13,'in',15)

    ui:register_event('move_in_sound','ResultPanel.win.exit_btn','move_in')
    ui:register_event('move_in_sound','ResultPanel.lose.exit_btn','move_in')
    ui:register_event('move_in_sound','ResultPanel.lose.other_btn','move_in')
    ui:register_event('move_in_sound','ResultPanel.finish.exit_btn','move_in')
    ui:register_event('click_sound','ResultPanel.win.exit_btn','click')
    ui:register_event('click_sound','ResultPanel.lose.exit_btn','click')
    ui:register_event('click_sound','ResultPanel.lose.other_btn','click')
    ui:register_event('click_sound','ResultPanel.finish.exit_btn','click')
end

---控制结算面板的显示
---@param _switch boolean 显示或隐藏
---@param _result string  传入'win' or 'lose',显示胜利或失败界面
---@param _player player 需要结算的玩家
local function show_result_panel(_switch,_result,_player)
    if _player == local_player then
        if not local_player.lord_id then local_player.lord_id = 1 end

        ui:set_visible('ResultPanel',_switch)
        ui:set_visible('ResultPanel.' .. _result,_switch)
        ui:set_text('ResultPanel.' .. _result.. '.Reward.Gold_Reward_Bg.Gold_Reward',string.format("%d",local_player.GameGold))
        ui:set_text('ResultPanel.' .. _result.. '.Reward.Score_Reward_Bg.Score_Reward',string.format("%d",local_player.GameCrown))
        ui:set_text('ResultPanel.' .. _result.. '.Game_Info.rounds.Text',string.format("%d",round.num))
        ui:set_text('ResultPanel.' .. _result.. '.Game_Info.win_rounds.Text',string.format("%d",local_player.WinRound))
        ui:set_text('ResultPanel.' .. _result.. '.Game_Info.most_earn.Text',string.format("%d",local_player.MaxGold))
        ui:set_text('ResultPanel.' .. _result.. '.info.Name_Bg.PlayerName',local_player:get_name())
        ui:set_text('ResultPanel.' .. _result.. '.info.Score_Bg.Score',string.format("%d",local_player:get_save_data(3)))
        if not local_player.is_force_quit then
            print('这里是排名',local_player.LordNum)
            ui:set_image('ResultPanel.' .. _result.. '.Rank.img_rank',rank_num_img[local_player.LordNum])
        else
            ui:set_image('ResultPanel.' .. _result.. '.Rank.img_rank',rank_num_img[#round.player])
        end
        --段位暂时不做
        ui:set_visible('ResultPanel.' .. _result.. '.info.Icon',true)
        ui:set_image('ResultPanel.' .. _result.. '.info.Icon',config.LordData[local_player.lord_id].head_icon)
        if _result == 'win' then
            ui:play_2d_sound(config.LordData[local_player.lord_id].Vo_Vic)
            ui:vx_play('ResultPanel.win.Title',12,'in')
            ui:set_image('ResultPanel.Lord_Model',config.LordData[local_player.lord_id].Vic_Panel)
        else
            ui:play_2d_sound(config.LordData[local_player.lord_id].Vo_fail)
            ui:vx_play('ResultPanel.'.._result..'.Title',13,'in')
            ui:set_image('ResultPanel.Lord_Model',config.LordData[local_player.lord_id].Fail_Panel)
        end
    end
    if _switch then
        _player.discard = true
        up.game:event_dispatch('玩家已退出',_player)
        if GameMode ~= 'Lord' then
            ui:set_visible('ResultPanel.' .. _result.. '.Rank',false)
        end

        for k,v in pairs(round.player) do
            if v == _player then
                table.remove(round.player,k)
            end
        end
        if GameMode ~= 'Lord' and GameMode ~= 'Custom' then
            --_player:game_win()
            gameapi.role_force_quit(_player._base, gameapi.get_text_config('%default_4'))
        end
    end
end

---播放时间轴动画
---@param _result string 结算结果'win'or'lose'or'finish'
local function timelineAni(_result)
    if _result ~= 'finish' then
        ui:play_ui_comp_anim(_result..'_rank_title_in',false,1)
        ui:play_ui_comp_anim(_result..'_img_rank_in',false,1)
        ui:play_ui_comp_anim(_result..'_rank_bg_in',false,1)
    end
    ui:play_ui_comp_anim(_result..'_info_bg_1_in',false,1)
    ui:play_ui_comp_anim(_result..'_round_in',false,1)
    ui:play_ui_comp_anim(_result..'_info_bg_2_in',false,1)
    ui:play_ui_comp_anim(_result..'_win_round_in',false,1)
    ui:play_ui_comp_anim(_result..'_info_bg_3_in',false,1)
    ui:play_ui_comp_anim(_result..'_most_earn_in',false,1)
    ui:play_ui_comp_anim(_result..'_reward_title_in',false,1)
    ui:play_ui_comp_anim(_result..'_gold_reward_in',false,1)
    ui:play_ui_comp_anim(_result..'_score_reward_in',false,1)
    ui:play_ui_comp_anim(_result..'_info_in',false,1) 
end

---将玩家切换至观战状态
local function change_to_watch()
    show_result_panel(false,'win',local_player)
    show_result_panel(false,'lose',local_player)
    show_result_panel(false,'finish',local_player)
    ToastPanel:show_toast('Observe')
    if round.pet_round == 4 then
        up.game:event_dispatch('观战',true,local_player)
        ui:set_visible('BetPanel',false)
    else
        up.game:event_dispatch('观战',false,local_player)
        ui:set_visible('BetPanel',true)
    end
end

---主动退出
---@param _player player 需要退出的玩家
local function player_click_quit(_player)
    if GameMode == 'Lord' or GameMode == 'Custom' then
        --_player:game_win()
        gameapi.role_force_quit(_player._base, gameapi.get_text_config('%default_4'))
    end
end

---结算数据并存档
---@param _player player 需要存档的玩家
local function set_player_save_data(_player)
    if GameMode == 'Lord' then
		local config_load_crown = config.LoadCrown[_player.LordNum]
		if config_load_crown then
			_player.GameGold = config.LoadCrown[_player.LordNum].gold
			_player.GameCrown = config.LoadCrown[_player.LordNum].crown
		else
			_player.GameGold = 0
			_player.GameCrown = 0
		end
        if _player:get_save_data(3) + _player.GameCrown < 0 then
            _player:set_save_data(3, 0)
        else
            _player:set_save_data(3, _player:get_save_data(3) + _player.GameCrown)
        end
        _player:set_save_data(1, _player:get_save_data(1) + _player.GameGold)
        if _player.gold_show == true then
            _player:msg('变化后存档货币:'.._player:get_save_data(1)..'此次变化值:'..tostring(_player.GameGold))
        end
        quest.playerquestset(_player,'earn_gold',math.max(0,_player.GameGold))
        if _player.LordNum <= 3 then
            quest.playerquestset(_player,'lord_win_num',1)
        end
        _player._base:add_global_map_archive_data("score", _player.GameCrown)
        _player:set_save_data(4, _player:get_save_data(4) + _player.WinRound)
        _player:set_save_data(5, _player:get_save_data(5) + (round.num - _player.WinRound))
    end
    _player._base:upload_save_data()
end
-------------------------------------------------------------------------------------------------------
--------------------------------------------事件注册----------------------------------------------------
-------------------------------------------------------------------------------------------------------

---vx事件柄
up.game:event('VX-Event', function(self,event,ui_comp,vx_id)
    if event == 'fade_in_win' then
        timelineAni('win')
        ui:play_2d_sound(134230870)
        return
    end
    if event == 'fade_in_lose' then
        timelineAni('lose')
        ui:play_2d_sound(134247156)
        return
    end
    if event == 'fade_in_finish' then
        timelineAni('finish')
        ui:play_2d_sound(134247156)
        return
    end
end)

---全局事件柄
up.game:event('游戏结束',function (_,player,result)
    --if IS_TEST then return end
    set_player_save_data(player)
    if not player.is_watching then
        show_result_panel(true,result,player)
    end
    player.is_watching = true
end)

---UI事件柄
up.game:event('UI-Event', function(self, player,event)
    if event == 'exit_btn_0' then
        if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then
            ui:set_visible('GuidePanel.masklayer',false)
            ui:set_text('GuidePanel.txt',".")
            ui:set_opacity('GuidePanel.txt',0)
        end
        player_click_quit(player)
    end

    if event == 'result_leave' then
        if player.is_watching then gameapi.role_force_quit(player._base, gameapi.get_text_config('%default_4'))  return end
        if GameMode ~= 'Lord' and GameMode ~= 'Custom' then
            up.game:event_dispatch('游戏结束',player,'finish')
        elseif round.num > 0  then
            player.is_force_quit = true
            up.game:event_dispatch('刷新玩家排行榜')
            up.game:event_dispatch('游戏结束',player,'lose')
        else
            gameapi.role_force_quit(player._base, gameapi.get_text_config('%default_4'))
        end
        if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then
            ui:set_visible('GuidePanel.masklayer',false)
            ui:set_text('GuidePanel.txt',".")
            ui:set_opacity('GuidePanel.txt',0)
        end
    end

    if event == 'watch_btn' and gameapi.get_trigger_variable_integer("新手引导模式") ~= 1004 then
        if round.is_gameover == true  then
            gameapi.role_force_quit(player._base, "Game is over!") 
        end
        if #round.player == 0 then
            player_click_quit(player)
        end
        if player ~= local_player then return end
        change_to_watch()
    end
end)
init_result_panel_ui_event()
return ResultPanel