---@diagnostic disable: need-check-nil
local BattlePanel = {}
local local_player = up.get_localplayer()
local ui = require 'ui.local'
local round = require 'game.round'
local BetPanel = require 'ui.BetPanel'
local ToastPanel = require 'ui.ToastPanel'
local SkillPanel = require 'ui.SkillPanel'
local skill_img = {903499,903500}
BattlePanel.flop_move_in,BattlePanel.flop_move_out = nil,nil
BattlePanel.handcard_move_in,BattlePanel.handcard_move_out = nil,nil
BattlePanel.lord_visible = true
BattlePanel.skill_tips_visible = false
BattlePanel.round_player = {}
local HandCard_level_vx = {
    [1] = {['B'] = 21,['R'] = 22,['Y'] = 23},
    [2] = {['B'] = 24,['R'] = 25,['Y'] = 26},
    [3] = {['B'] = 27,['R'] = 28,['Y'] = 29},
}
local eff_select =  102581
local soldier_icon = {
    [134228828] =133060,
    [134231515] =131026,
    [134245934] =133061,
    [134246151] =133062,
}

local img_data = {}
img_data.card = 130969
img_data.lord_select={
    head = {
        ['hover'] = 903522,
        ['nml'] = 903523,
    },
    more_bg = {
        ['slc'] = 903527,
        ['hover'] = 903525,
        ['nml'] = 903526,
    },
    little_bg = {
        ['slc'] = 903530,
        ['hover'] = 903528,
        ['nml'] = 903529,
    },
    more_btn = {
        ['slc'] = 903534,
        ['nml'] = 903533,
    },
    little_btn = {
        ['slc'] = 903496,
        ['nml'] = 903495,
    },
}
---初始化战斗界面UI事件
function BattlePanel:init_battle_panel_ui_event()
    BattlePanel.flop_move_in = ui:new_event('BattlePanel.FlopTouch','move_in')
    BattlePanel.flop_move_out = ui:new_event('BattlePanel.FlopTouch','move_out')
    BattlePanel.handcard_move_in = ui:new_event('BattlePanel.HandCardTouch','move_in')
    BattlePanel.handcard_move_out = ui:new_event('BattlePanel.HandCardTouch','move_out')
    BattlePanel.Lord_more = ui:new_event('BattlePanel.LordInfo.LordBtn.more','click')
    BattlePanel.Lord_little = ui:new_event('BattlePanel.LordInfo.LordBtn.little','click')
    BattlePanel.Lord_show =  ui:new_event('BattlePanel.LordInfo.LordShow','click')
    for i = 1,PLAYER_MAX do
        local more_lord = 'BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i
        local little_lord = 'BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..i
        BattlePanel['Lord_more_move_in'..i] = ui:new_event(more_lord,'move_in')
        BattlePanel['Lord_more_move_out'..i] = ui:new_event(more_lord,'move_out')
        BattlePanel['Lord_little_move_in'..i] = ui:new_event(little_lord,'move_in')
        BattlePanel['Lord_little_move_out'..i] = ui:new_event(little_lord,'move_out')
        BattlePanel['Lord_more_click'..i] = ui:new_event(more_lord,'click')
        BattlePanel['Lord_little_click'..i] = ui:new_event(little_lord,'click')
        for j = 1,3 do
            BattlePanel['Lord_more_move_in'..i..'_skill'..j] = ui:new_event(more_lord..'.skill_list.skill'..j,'move_in')
            BattlePanel['Lord_more_move_out'..i..'_skill'..j] = ui:new_event(more_lord..'.skill_list.skill'..j,'move_out')
        end
    end
    ui:vx_event('BattlePanel.HandCard.HandCard_Btn.BigPair_Open','in',8,'in',14)
    ui:vx_event('BattlePanel.HandCard.HandCard_Btn.BigPair_Close','in',8,'in',14)
    for i = 1,2 do
        ui:vx_event('BattlePanel.HandCard.HandCard_'..i..'.pair_ani','in',10,'in',13)
        ui:vx_event('BattlePanel.HandCard.HandCard_Close_'..i..'.pair_ani','in',10,'in',13)
        ui:vx_event('BattlePanel.HandCard.HandCard_'..i..'.Big_pair_ani','out',9,'out',40)

        ui:vx_event('BattlePanel.Discard_ani_'..i,'battle_discard_ani_over',11,'out',35)
        ui:vx_event('BattlePanel.Discard_ani_'..i,'battle_discard_ani_card',11,'out',6)
    end
    ui:vx_event('BattlePanel.HandCard.HandCard_Btn.BigPair_Open','in',8,'in',14)
    ui:vx_event('BattlePanel.HandCard.HandCard_Btn.BigPair_Open','out',8,'out',10)
    ui:vx_event('BattlePanel.HandCard.HandCard_Btn.BigPair_Close','in',8,'in',14)
    ui:vx_event('BattlePanel.HandCard.HandCard_Btn.BigPair_Close','out',8,'out',10)
    for k,v in pairs(HandCard_level_vx[3]) do
        for i = 1,2 do
            ui:vx_event('BattlePanel.HandCard.HandCard_'..i..'.powerup','in',v,'in',40)
        end
    end

    ui:vx_event('BattleEnd.BattleEnd','BattleEnd',6,'out',85)
end

---回合结束重设战斗界面
function BattlePanel:reset_ui()
    BattlePanel:show_flop_tips(false)
    BattlePanel.flop_show_is_over = false
    for i = 1,2 do
        ui:set_visible('BattlePanel.HandCard.HandCard_'..i,false)
        ui:set_visible('BattlePanel.HandCard.HandCard_'..i..'.powerup',false)
        ui:set_visible('BattlePanel.HandCard.HandCard_'..i..'.pair_ani',false)
        ui:set_visible('BattlePanel.HandCard.HandCard_'..i..'.Big_pair_ani',false)

        ui:set_visible('BattlePanel.HandCard.HandCard_Close_'..i,true)
        ui:set_visible('BattlePanel.HandCard.HandCard_Close_'..i..'.powerup',false)
        ui:set_visible('BattlePanel.HandCard.HandCard_Close_'..i..'.pair_ani',false)
    end
    self.handcard_visible = false
    ui:wait(3,function ()
        for i = 1,3 do
            ui:set_opacity('BattlePanel.Flop.Card_Bg_'..i,0)
        end
        ui:set_opacity('BattlePanel.HandCard',100)
    end)
    ui:set_visible('BattlePanel.HandCard',true)
    ui:set_visible('BattlePanel.LordInfo',false)
    ui:set_visible('BattlePanel.LordInfobg',false)
    if local_player.battle_show_player then
        local i = local_player.battle_show_player
        ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.img_head_bg.select',false)
        ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..i..'.img_head_bg.select',false)
        local_player.battle_show_player = nil
    end
end

---更新手牌数据显示
function BattlePanel:set_hand_card()
    if local_player.is_watching ~= false or local_player.is_watching == nil then return end
    local num_type = 'nml'
    if local_player.card[1].num == local_player.card[2].num then
        num_type = 'double'
    end
    for i = 1,2 do
        if num_type == 'double' then
            ui:set_image('BattlePanel.HandCard.HandCard_'..i..'.card_img',local_player.card[i].soldier.red_soldier_image)
            ui:set_image('BattlePanel.HandCard.HandCard_Close_'..i..'.img',local_player.card[i].soldier.red_soldier_image_mini)
        else
            ui:set_image('BattlePanel.HandCard.HandCard_'..i..'.card_img',local_player.card[i].soldier.soldier_image)
            ui:set_image('BattlePanel.HandCard.HandCard_Close_'..i..'.img',local_player.card[i].soldier.soldier_image_mini)
        end
        ui:set_image('BattlePanel.HandCard.HandCard_'..i..'.Num_bg.CardNum_img',ui.card_num_img[local_player.card[i].num][num_type])
        ui:set_image('BattlePanel.HandCard.HandCard_Close_'..i..'.Num_bg.CardNum_img',ui.card_num_img[local_player.card[i].num][num_type])
    end
end

---展示公共牌
---@param _switch boolean 展示或收起
---@param _card_group integer 公共牌的组id
---@param _card_id integer 公共牌的牌id
function BattlePanel:show_flop(_switch,_card_group,_card_id)
    for i = 1,3 do
        if round.magic_card[i].group_id == _card_group and round.magic_card[i].key == _card_id then
            ui:set_visible('BattlePanel.Flop.Flop'..i,_switch)
            ui:set_image('BattlePanel.Flop.Flop'..i..'.card_img',round.magic_card[i].icon)
            ui:set_text('BattlePanel.Flop.Flop'..i..'.CardName',round.magic_card[i].name)
            ui:set_text('BattlePanel.Flop.Flop'..i..'.CardName.CardName_shadow',  round.magic_card[i].name)
            ui:set_text('BattlePanel.Flop.Flop'..i..'.DesBg.DesTxt',round.magic_card[i].tips)
            ui:set_text('BattlePanel.Flop.Flop'..i..'.CardType','场地魔法')
        
            ui:set_text('BattlePanel.Flop.Card_Bg_'..i..'.Name',round.magic_card[i].name)
            ui:play_ui_comp_anim('Flop'..i..'_Show_a')
            ui:wait(1.5,function ()
                ui:play_ui_comp_anim('Flop'..i..'_Show_b')
                ui:play_ui_comp_anim('Card_Bg_'..i.."_in")
            end)
        end
    end
end

---控制战斗界面的开启
---@param _switch boolean 显示或隐藏
function BattlePanel:show_battle_ui(_switch)
    GameAPI.set_render_option("FocusDistance", 110)
    ui:set_visible('BattlePanel',_switch)
    ui:set_visible('BetPanel',false)
end


---控制战斗界面公共牌的变大tips显示
---@param _switch boolean 显示或隐藏
function BattlePanel:show_flop_tips(_switch)
    if not self.flop_show_is_over then return end
    for i = 1,3 do
        if _switch then
            ui:play_ui_comp_anim('Flop'..i..'_Show_c')
            ui:play_ui_comp_anim('Card_Bg_'..i.."_out")
        else
            ui:play_ui_comp_anim('Flop'..i..'_Show_b')
            ui:play_ui_comp_anim('Card_Bg_'..i.."_in")
        end
    end
    local size = {}
    local pos = {}
    if _switch then
        size[1] = 818.59
        size[2] = 344.15
        pos[1] = 959.22
        pos[2] = 907.63
    else
        size[1] = 512.34
        size[2] = 66.03
        pos[1] = 960.78
        pos[2] = 1046.69
    end
    ui:set_position('BattlePanel.FlopTouch',pos)
    ui:set_size('BattlePanel.FlopTouch',size)
end

---卡牌对子动效
function BattlePanel:play_pairs_ani()
    if BetPanel.is_big_pair then
        if self.handcard_visible then
            ---UI没有啊
            ui:set_visible('BattlePanel.HandCard.HandCard_Btn.BigPair_Open',true)
            ui:vx_play('BattlePanel.HandCard.HandCard_Btn.BigPair_Open',8,'in')
            ui:vx_play('BattlePanel.HandCard.BigPair_Close',8,'out')
            for i = 1,2 do
                --ui:set_visible('BattlePanel.HandCard.HandCard_'..i..'.Big_pair_ani',true)
                --ui:vx_play('BattlePanel.HandCard.HandCard_'..i..'.Big_pair_ani',9,'out')
            end
        else
            ui:set_visible('BattlePanel.HandCard.BigPair_Close',true)
            ui:vx_play('BattlePanel.HandCard.BigPair_Close',8,'in')
            ui:vx_play('BattlePanel.HandCard.HandCard_Btn.BigPair_Open',8,'out')
        end
    elseif BetPanel.num_type == 'double' then
        ui:set_visible('BattlePanel.HandCard.HandCard_Btn.BigPair_Open',false)
        ui:set_visible('BattlePanel.HandCard.BigPair_Close',false)
        if self.handcard_visible then
            for i = 1,2 do
                ui:set_visible('BattlePanel.HandCard.HandCard_'..i..'.pair_ani',true)
                ui:vx_play('BattlePanel.HandCard.HandCard_'..i..'.pair_ani',10,'in')
                ui:play_ui_comp_anim('CardNum'..i..'_buff',false,1)
                ui:wait(0.0333*16,function ()
                    ui:play_ui_comp_anim('CardNum'..i..'_buff_2',true,1)
                end)
            end
        else
            for i = 1,2 do
                ui:set_visible('BattlePanel.HandCard.HandCard_Close_'..i..'.pair_ani',true)
                ui:vx_play('BattlePanel.HandCard.HandCard_Close_'..i..'.pair_ani',10,'in')
            end
        end
    else
        ui:set_visible('BattlePanel.HandCard.HandCard_Btn.BigPair_Open',false)
        ui:set_visible('BattlePanel.HandCard.BigPair_Close',false)
        for i = 1,2 do
            ui:set_visible('BattlePanel.HandCard.HandCard_'..i..'.pair_ani',false)
            ui:set_visible('BattlePanel.HandCard.HandCard_Close_'..i..'.pair_ani',false)
            ui:set_visible('BattlePanel.HandCard.HandCard_'..i..'.big_pair_ani',false)
        end
    end
end

---控制战斗界面手牌的变大tips显示
---@param _switch boolean 显示或隐藏
function BattlePanel:show_hand_card_tips(_switch)
    if local_player.is_watching ~= false or local_player.is_watching == nil then return end
    for i =1 ,2 do
        ui:set_visible('BattlePanel.HandCard.HandCard_'..i,_switch)
        ui:set_visible('BattlePanel.HandCard.HandCard_Close_'..i,not(_switch))
        if not local_player.card or not local_player.card[i] then return end
        if local_player.card[i].color and local_player.card[i].powerup_times and HandCard_level_vx[local_player.card[i].powerup_times] then
            if local_player.card[i].powerup_times ~= 3 then
                ui:vx_play('BattlePanel.HandCard.HandCard_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'loop')
                ui:vx_play('BattlePanel.HandCard.HandCard_Close_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'loop')
            else
                ui:vx_play('BattlePanel.HandCard.HandCard_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'in')
                ui:vx_play('BattlePanel.HandCard.HandCard_Close_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'in')
            end
        else
            ui:set_visible('BattlePanel.HandCard.HandCard_'..i..'.powerup',false)
            ui:set_visible('BattlePanel.HandCard.HandCard_Close_'..i..'.powerup',false)
        end
    end
    local size = {}
    local pos = {}
    if _switch then
        size[1] = 379.88
        size[2] = 253.01
        pos[1] = 1653.45
        pos[2] = 158.51
    else
        size[1] = 378.39
        size[2] = 88.84 
        pos[1] = 1654.19
        pos[2] = 76.42
    end
    ui:set_position('BattlePanel.HandCardTouch',pos)
    ui:set_size('BattlePanel.HandCardTouch',size)

    self.handcard_visible = _switch
    BattlePanel:play_pairs_ani()
end

---战斗结束过程
function BattlePanel:show_battle_end()
    ui:set_visible('BattleEnd',true)
    -- local x_scale = gameapi.get_game_x_resolution() / gameapi.get_window_real_x_size()
    -- local y_scale = gameapi.get_game_y_resolution() / gameapi.get_window_real_y_size()
    -- local scale = {x_scale*1920*1.15,y_scale*1080*1.15}
    local x_scale = gameapi.get_game_x_resolution() / 1920 * 1.15
    local y_scale = gameapi.get_game_y_resolution() / 1080 * 1.15
    local scale = {x_scale,y_scale}
    ui:set_scale('BattleEnd.BattleEnd_Bg',scale)
    ui:set_visible('BattleEnd.BattleEnd',true)                                                                                                                        
    ui:vx_play('BattleEnd.BattleEnd',6,'out')
    ui:set_visible('BattleEnd.BattleEnd_Bg',true)
    ui:vx_play('BattleEnd.BattleEnd_Bg',7,'out')
end

---播放弃牌动画
function BattlePanel:show_fold_ani()
    for i = 1,2 do
        ui:set_visible('BattlePanel.Discard_ani_'..i,true)
        ui:vx_play('BattlePanel.Discard_ani_'..i,11,'out')
    end
end

---获得玩家A在玩家B的场景座位ui位置
---@param _playerA table 玩家实例
---@param _playerB table 玩家实例
---@return integer seat_id 座位的标号，本地玩家始终为1
function BattlePanel:find_player_scene_seat(_playerA,_playerB)
    if not _playerB then _playerB = local_player end
    local seat_id
    if _playerA:get_id() >= _playerB:get_id() then
        seat_id = _playerA:get_id() - _playerB:get_id() + 1
    else
        seat_id = PLAYER_MAX - (_playerB:get_id() - _playerA:get_id()) + 1
    end
    return seat_id
end

local lord_list_set = function(i)
    local _player = BattlePanel.round_player[i]
    local more_lord = 'BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i
    local little_lord = 'BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..i
    ui:set_text(more_lord..'.lord_bg.army',math.floor(_player.army.power))
    ui:set_text(little_lord..'.lord_bg.army',math.floor(_player.army.power))
    ui:set_progress(more_lord..'.lord_bg.army_progress',_player.army.powerMax,_player.army.power)
    ui:set_progress(little_lord..'.lord_bg.army_progress',_player.army.powerMax,_player.army.power)
    ui:set_image(more_lord..'.lord_bg.army_progress',config.LordData[_player.lord_id].battle_lord_hp)
    ui:set_image(little_lord..'.lord_bg.army_progress',config.LordData[_player.lord_id].battle_lord_hp)
    ui:set_text(more_lord..'.lord_bg.name',_player:get_name())
    ui:set_text(little_lord..'.lord_bg.name',_player:get_name())
    ui:set_image(more_lord..'.img_head_bg.img_head',config.LordData[_player.lord_id].battle_lord_icon)
    ui:set_image(little_lord..'.img_head_bg.img_head',config.LordData[_player.lord_id].battle_lord_icon)
    for i = 1,2 do
        ui:set_image(more_lord..'.card'..i..'.card',soldier_icon[_player.card[i].id])
        ui:set_text(more_lord..'.card'..i..'.cnt',_player.card[i].num)
    end
    if GameMode == 'Lord' or GameMode == 'Custom' then
        for j = 1,3 do
            local solt = _player.skill_slot_now[j]
            if solt then
                ui:set_image(more_lord..'.skill_list.skill'..j,img_data.card)
                ui:set_image(little_lord..'.skill_list.skill'..j,skill_img[1])
                ui:set_visible(more_lord..'.skill_list.skill'..j,true)
                ui:set_visible(little_lord..'.skill_list.skill'..j,true)
            else
                ui:set_visible(more_lord..'.skill_list.skill'..j,false)
                ui:set_visible(little_lord..'.skill_list.skill'..j,false)
            end
        end
    else
        ui:set_visible(more_lord..'.skill_list',false)
        ui:set_visible(little_lord..'.skill_list',false)
    end
    for i = 1,5 do
        if _player.army.power_unit[i] then
            ui:set_visible(more_lord..'.lord_bg.army_list.army'..i,false)
            -- ui:set_visible(more_lord..'.lord_bg.army_list.army'..i,true)
            -- ui:set_image(more_lord..'.lord_bg.army_list.army'..i..'.img',img_data.card)
            -- ui:set_text(little_lord..'.lord_bg.army_list.army'..i..'.army_cnt',_player.army.power_unit[i][2])
        else
            ui:set_visible(more_lord..'.lord_bg.army_list.army'..i,false)
        end
    end
end
---绑定回合内领主
function BattlePanel:bind_lord_round()
    local cnt = 1
    local pid = local_player:get_id()
    BattlePanel.round_player = up.table_copy(round.player)
    table.sort(BattlePanel.round_player, function(a, b)
        if self:find_player_scene_seat(a) < self:find_player_scene_seat(b)  then
            return true
        else
            return false
        end
    end)
    for i = 1, PLAYER_MAX do
        if BattlePanel.round_player[i] then
            ui:set_visible('BattlePanel.LordInfo.Lord_List_tips.Lord'..i..'.skill',false)
            ui:set_visible('BattlePanel.LordInfo.Lord_List_tips.Lord'..i,true)
            ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i,true)
            ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..i,true)
            BattlePanel.round_player[i].skill_now = {}
            lord_list_set(i)
        else
            ui:set_visible('BattlePanel.LordInfo.Lord_List_tips.Lord'..i,false)
            ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i,false)
            ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..i,false)
        end
    end
    ui:set_visible('BattlePanel.HandCard',false)
    ui:set_visible('BattlePanel.LordInfo',true)
    ui:set_visible('BattlePanel.LordInfobg',true)
end

local broadcast_queue = {}
local broadcast_timer
local broadcast_cd
BattlePanel.is_broadcast_cd = false
BattlePanel.broadcast_cd = 0
---将领主技能播报插入队列
---@param _player table 使用技能的玩家
---@param _skill table 使用的领主技能
function BattlePanel:insert_broadcast_queue(_player,_skill)
    -- local _player_name = _player:get_name()
    -- local _lord_icon = _player.lord:get_icon()
    -- local _skill_name = _skill:get_name()
    -- local data = {
    --     player_name = _player_name,
    --     lord_icon = _lord_icon,
    --     skill_name = _skill_name,
    --     time = 70/30,
    --     is_played = false,
    -- }
    -- table.insert(broadcast_queue,data)
    local i
    for k, v in ipairs(BattlePanel.round_player) do
        if _player == v then
            i = k
        end
    end
    if i then
        self:skill_list_tips(i,_skill)
    end
    local have = false
    if not _player.skill_now then _player.skill_now = {} end
    for k, v in ipairs(_player.skill_now) do
        if v == _skill then
            have = true
        end
    end
    if not have then
        table.insert(_player.skill_now,_skill)
    end
    local _skill_now_cnt = #_player.skill_now
    local solt_skill
    for k, v in ipairs(_player.skill_slot_now) do
        local skill = up.actor_skill(_player.lord._base:api_get_ability(2,v))
        if skill == _skill then
            solt_skill = k
        end
    end
    if solt_skill and i then
        local icon = config.SkillData[_skill._base:api_get_ability_id()].Card--_skill:get_icon()
        ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.skill_list.skill'.._skill_now_cnt,icon)
        ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..i..'.skill_list.skill'.._skill_now_cnt,skill_img[2])
        if _player == local_player then
            ui:set_visible('SkillPanel.LordSkill.SkillSlot.skill_'..solt_skill,false)
        end
    end
end

---技能触发使用
function BattlePanel:skill_list_tips(i,_skill)
    local name = _skill:get_name()
    local icon = config.SkillData[_skill._base:api_get_ability_id()].Card--skill:get_icon()
    if broadcast_queue[i] and broadcast_queue[i] > 0 then
        ui:set_visible('BattlePanel.LordInfo.Lord_List_tips.Lord'..i..'.skill',false)
    end
    ui:set_image('BattlePanel.LordInfo.Lord_List_tips.Lord'..i..'.skill',icon)
    ui:set_text('BattlePanel.LordInfo.Lord_List_tips.Lord'..i..'.skill.name',name)
    ui:set_visible('BattlePanel.LordInfo.Lord_List_tips.Lord'..i..'.skill',true)
    broadcast_queue[i] = 2
end

---初始化领主技能播报器
function BattlePanel:init_lord_skill_broadcast()
    -- broadcast_timer = up.loop(0.06,function()
    --     for i = 1,3 do 
    --         local data = broadcast_queue[i]
    --         if data then
    --             if data.time <= 0 then
    --                 table.remove(broadcast_queue,i)
    --             elseif not data.is_played and not self.is_broadcast_cd then
    --                 ui:play_ui_comp_anim('InfoBg_'..i..'_in',false,0.5)
    --                 data.is_played = true
    --                 self.is_broadcast_cd = true
    --                 self.broadcast_cd = 0
    --             elseif data.is_played then
    --                 ui:set_visible('BattlePanel.BattleInfoSlot.InfoBg_'..i,true)
    --                 ui:set_image('BattlePanel.BattleInfoSlot.InfoBg_'..i..'.HeadImg',data.lord_icon)
    --                 ui:set_text('BattlePanel.BattleInfoSlot.InfoBg_'..i..'.InfoTxt',data.player_name ..' uses the lord skill '.. data.skill_name)
    --                 data.time = data.time - 0.06
    --             end
    --         end
    --     end
    -- end)
    -- broadcast_cd = up.loop(0.1,function ()
    --     if self.is_broadcast_cd then
    --         if self.broadcast_cd < 0.8 then
    --             self.broadcast_cd = self.broadcast_cd + 0.1
    --         else
    --             self.is_broadcast_cd = false
    --         end
    --     end
    -- end)
    broadcast_cd = up.loop(1,function ()
        for i, v in pairs(broadcast_queue) do
            broadcast_queue[i] = broadcast_queue[i] - 1
            if broadcast_queue[i] == 0 then
                ui:set_visible('BattlePanel.LordInfo.Lord_List_tips.Lord'..i..'.skill',false)
            end
        end
    end)
end

---计算领主技能可用次数
---@param _player table 使用领主技能的玩家
---@param _skill table 使用的领主技能
function BattlePanel:count_lord_skill_charge(_player,_skill)
    ---技能替换 技能扣次数
    for solt = 1, #_player.skill_list do
        if _skill == _player.lord:find_skill('Common',_,solt) then
            _player['skill_charge_'..solt] = _player['skill_charge_'..solt] - 1
            if _player['skill_charge_'..solt] == 0 then
            end
        end
    end
    --self:fresh_lord_skill_charge()
end

---刷新领主技能的可用状态
function BattlePanel:fresh_lord_skill_charge()
    for _,v in pairs(round.player) do
		---技能替换 刷新可用状态
        for n = 1,3 do
            local solt = v.skill_slot_now[n]
            if solt then
                local sid = v.skill_list[solt]
                local now = v['skill_charge_'..solt]
                if now == 0 then
                    v.lord:find_skill('Common',_,solt):disable()
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------
--------------------------------------------事件注册----------------------------------------------------
-------------------------------------------------------------------------------------------------------
---cocos动效事件柄
up.game:event('VX-Event', function(self,event,ui_comp,vx_id)
    if event == 'BattleEnd' then
        ui:set_visible(ui_comp,false)
        ui:set_visible('BattleEnd',false)
        ui:set_visible('BattleEnd.BattleEnd_Bg',false)
    end
    if event == 'start_flop_tail' then
        if local_player.is_watching ~= false or local_player.is_watching == nil then return end
        for i = 1,2 do
            ui:set_visible('BattlePanel.HandCard.HandCard_'..i..'.powerup',true)
            ui:set_visible('BattlePanel.HandCard.HandCard_Close_'..i..'.powerup',true)
            if not local_player.card or not local_player.card[i] then return end
            if local_player.card[i].color and local_player.card[i].powerup_times and HandCard_level_vx[local_player.card[i].powerup_times] then
                if local_player.card[i].powerup_times ~= 3 then
                    ui:vx_play('BattlePanel.HandCard.HandCard_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'loop')
                    ui:vx_play('BattlePanel.HandCard.HandCard_Close_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'loop')
                else
                    ui:vx_play('BattlePanel.HandCard.HandCard_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'in')
                    ui:vx_play('BattlePanel.HandCard.HandCard_Close_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'in')
                end
            end
        end
    end
    if event == 'battle_discard_ani_over' then
        ui:set_visible(ui_comp,false)
        BattlePanel:show_hand_card_tips(false)
        return
    end
    if event == 'battle_discard_ani_card' then
        ui:play_ui_comp_anim('HandCard_battle_out',false,1)
        return
    end
end)

---全局事件柄
up.game:event('Skill-CSStart',function (_,_skill)
    for k,v in ipairs(round.player) do
        if _skill:get_owner() == v.lord then
            BattlePanel:insert_broadcast_queue(v,_skill)
            BattlePanel:count_lord_skill_charge(v,_skill)
        end
    end
end)

up.game:event('回合流程-发牌',function (_)
    BattlePanel:reset_ui()
    BattlePanel:set_hand_card()
end)

up.game:event('回合流程-战斗结束过场',function (_)
    BattlePanel:show_battle_end()
end)

up.game:event('战斗流程-揭示魔法卡',function (_,_card_group,_card_id)
    BattlePanel:show_flop(true,_card_group,_card_id)
end)

up.game:event('战斗流程-战斗力变化',function (_,_player)
    if BattlePanel.round_player then
        for i, v in ipairs(BattlePanel.round_player) do
            if v == _player then
                local more_lord = 'BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i
                local little_lord = 'BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..i
                ui:set_text(more_lord..'.lord_bg.army',math.floor(_player.army.power))
                ui:set_text(little_lord..'.lord_bg.army',math.floor(_player.army.power))
                ui:set_progress(more_lord..'.lord_bg.army_progress',_player.army.powerMax,_player.army.power)
                ui:set_progress(little_lord..'.lord_bg.army_progress',_player.army.powerMax,_player.army.power)
            end
        end
    end
end)

up.game:event('战斗流程-收起魔法卡',function (_)
    BattlePanel.flop_show_is_over = true
    BattlePanel:show_flop_tips(false)
end)

up.game:event('回合流程-阅兵弃牌',function (_)
    if local_player.discard and not local_player.is_watching then
        BattlePanel:show_hand_card_tips(true)
        BattlePanel:show_fold_ani()
    end
end)

up.game:event('回合流程-战斗开始',function ()
    BattlePanel:bind_lord_round()
end)

up.game:event('回合流程-战斗',function ()
    BattlePanel:show_battle_ui(true)
end)

up.game:event('观战',function (_,_switch,_player)
    if _player == local_player then
        BattlePanel:show_battle_ui(_switch)
    end
end)

up.game:event('回合流程-战斗败北',function (_,player)
    if player == local_player then
        ToastPanel:show_toast('%fail_text')
    end
end)

---UI事件柄
up.game:event('UI-Event', function(self, player,event)
    if player ~= local_player then return end

    if event == BattlePanel.handcard_move_in then
        BattlePanel:show_hand_card_tips(true)
        return
    end
    if event == BattlePanel.handcard_move_out then
        BattlePanel:show_hand_card_tips(false)
        return
    end
    if event == BattlePanel.flop_move_in then
        BattlePanel:show_flop_tips(true)
        return
    end
    if event == BattlePanel.flop_move_out then
        BattlePanel:show_flop_tips(false)
        return
    end
    if event == BattlePanel.Lord_more then
        ui:set_image('BattlePanel.LordInfo.LordBtn.more',img_data.lord_select.more_btn.slc)
        ui:set_image('BattlePanel.LordInfo.LordBtn.little',img_data.lord_select.little_btn.nml)
        ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_more',true)
        ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_little',false)
        return
    end
    if event == BattlePanel.Lord_little then
        ui:set_image('BattlePanel.LordInfo.LordBtn.more',img_data.lord_select.more_btn.nml)
        ui:set_image('BattlePanel.LordInfo.LordBtn.little',img_data.lord_select.little_btn.slc)
        ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_more',false)
        ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_little',true)
        return
    end
    for i =1,PLAYER_MAX do
        if event == BattlePanel['Lord_little_click'..i] or event == BattlePanel['Lord_more_click'..i] then
            local _player = BattlePanel.round_player[i]
            if _player then
                if local_player.battle_show_player == i then
                    for k, u in ipairs(_player.army.all) do
                        if u.eff then
                            gameapi.delete_sfx(u.eff,true)
                            u.eff = nil
                        end
                    end
                    ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.img_head_bg.select',false)
                    ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..i..'.img_head_bg.select',false)
                    ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.lord_bg',img_data.lord_select.more_bg.nml)
                    ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_littlr.Lord'..i..'.lord_bg',img_data.lord_select.little_bg.nml)
                    local_player.battle_show_player = nil
                else
                    if local_player.battle_show_player then
                        local _player2 = BattlePanel.round_player[local_player.battle_show_player]
                        for k, u in ipairs(_player2.army.all) do
                            if u.eff then
                                gameapi.delete_sfx(u.eff,true)
                                u.eff = nil
                            end
                        end
                        ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..local_player.battle_show_player..'.img_head_bg.select',false)
                        ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..local_player.battle_show_player..'.img_head_bg.select',false)
                        ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..local_player.battle_show_player..'.lord_bg',img_data.lord_select.more_bg.nml)
                        ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_littlr.Lord'..local_player.battle_show_player..'.lord_bg',img_data.lord_select.little_bg.nml)
                    end
                    local_player.battle_show_player = i
                    ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.img_head_bg.select',true)
                    ui:set_visible('BattlePanel.LordInfo.LordTable.Lord_List_little.Lord'..i..'.img_head_bg.select',true)
                    ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.lord_bg',img_data.lord_select.more_bg.slc)
                    ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_littlr.Lord'..i..'.lord_bg',img_data.lord_select.little_bg.slc)
                    for k, u in ipairs(_player.army.all) do
                        if not u.eff then
                            u.eff = gameapi.create_sfx_on_unit(eff_select, u._base, "root", false, true, 1.0, Fix32(-1.0), Fix32(-1.0))
                        end
                    end
                end
            end
            return
        end
        if event == BattlePanel['Lord_little_move_in'..i] or event == BattlePanel['Lord_more_move_in'..i] then
            if BattlePanel.round_player[i] and not local_player.battle_show_player then
                local _player = BattlePanel.round_player[i]
                ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.lord_bg',img_data.lord_select.more_bg.hover)
                ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_littlr.Lord'..i..'.lord_bg',img_data.lord_select.little_bg.hover)
                ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.img_head_bg',img_data.lord_select.head.hover)
                ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_littlr.Lord'..i..'.img_head_bg',img_data.lord_select.head.hover)
                for k, u in ipairs(_player.army.all) do
                    if not u.eff then
                        u.eff = gameapi.create_sfx_on_unit(eff_select, u._base, "root", false, true, 1.0, Fix32(-1.0), Fix32(-1.0))
                    end
                end
            end
            return
        end
        if event == BattlePanel['Lord_little_move_out'..i] or event == BattlePanel['Lord_more_move_out'..i] then
            if BattlePanel.round_player[i] and not local_player.battle_show_player then
                ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.lord_bg',img_data.lord_select.more_bg.nml)
                ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_littlr.Lord'..i..'.lord_bg',img_data.lord_select.little_bg.nml)
                ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_more.Lord'..i..'.img_head_bg',img_data.lord_select.head.nml)
                ui:set_image('BattlePanel.LordInfo.LordTable.Lord_List_littlr.Lord'..i..'.img_head_bg',img_data.lord_select.head.nml)
                local _player = BattlePanel.round_player[i]
                for k, u in ipairs(_player.army.all) do
                    if u.eff then
                        gameapi.delete_sfx(u.eff,true)
                        u.eff = nil
                    end
                end
            end
            return
        end
        for j =1,3 do
            if event == BattlePanel['Lord_more_move_in'..i..'_skill'..j] then
                if j <= #BattlePanel.round_player[i].skill_now then
                    SkillPanel:bind_skill_ui('skill_drop',BattlePanel.round_player[i].skill_now[j])
                    local path = 'SkillPanel.LordSkill.skill_drop'
                    local tips_scale = ui:get_size(path)
                    local x = math.min(1850 - tips_scale[1],math.max(100+ tips_scale[1],gameapi.get_role_ui_x_per(player._base):float()*1920 - tips_scale[1]/2))
                    local y = math.min(1050 - tips_scale[1],math.max(100+ tips_scale[2],gameapi.get_role_ui_y_per(player._base):float()*1080 + tips_scale[2]))
                    ui:set_scale(path,0.6)
                    ui:set_position(path,{x,y})
                    ui:set_visible(path,true)
                end
            end
            if event == BattlePanel['Lord_more_move_out'..i..'_skill'..j] then
                if j <= #BattlePanel.round_player[i].skill_now then
                    ui:set_visible('SkillPanel.LordSkill.skill_drop',false)
                end
            end
        end
    end
    if event == BattlePanel.Lord_show then
        BattlePanel.lord_visible = not BattlePanel.lord_visible
        if BattlePanel.lord_visible then
            ui:set_ui_comp_rotation('BattlePanel.LordInfo.LordShow',0)
        else
            ui:set_ui_comp_rotation('BattlePanel.LordInfo.LordShow',180)
        end
        ui:set_visible('BattlePanel.LordInfo.LordTable',BattlePanel.lord_visible)
        ui:set_visible('BattlePanel.LordInfo.LordBtn',BattlePanel.lord_visible)
        ui:set_visible('BattlePanel.LordInfobg',BattlePanel.lord_visible)
        return
    end
end)

BattlePanel:init_battle_panel_ui_event()
BattlePanel:init_lord_skill_broadcast()

return BattlePanel