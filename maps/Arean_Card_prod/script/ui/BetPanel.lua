---@diagnostic disable: need-check-nil
local BetPanel = {}
local local_player = up.get_localplayer()
local ui = require 'ui.local'
local round = require'game.round'
local magic = require'game.magicCard'
local bet_data = config.BetConfig[GameMode]
local scenes_table_coin = {'coin3','coin5','coin7','coin1',}
local scenes_table_card = {'card3','card5','card7','card1',}
local CoinPoint = {up.actor_point(1000000177),up.actor_point(1000000183),up.actor_point(1000000181),up.actor_point(1000000179),up.actor_point(1000000186)}
local soundPoint = CoinPoint[#CoinPoint]
local bet_light = 103182
local bet_sound = {134281058,134250345,134225089}
local progress_color = {['green'] = 134214,['yellow'] = 134212,['red'] = 134213}
local card_on_table = {['in'] = 103392 , ['out'] = 103393}
local cup_on_table = {['in'] = 103403 , ['out'] = 103404}
local sound_tab ={}
local ShowMagicCard = false
local MagicCard = 0
local NextMagicCard = 0
local ShowMagicCardLock = false
local ShowMagicCardOnoff = {[1] = false,[2] = false,[3] = false,}
local lord_ani ={
    ['sit_idle'] = 'owner_sit_idle',
    ['show'] = 'owner_sit_show',
    ['bet'] = {
        'owner_sit_ante1',
        'owner_sit_ante1',
        'owner_sit_ante1',
        'owner_sit_ante1',
        'owner_sit_ante1',
    },
    ['all_in'] = 'owner_allin',
    ['sit_win'] = 'owner_sit_roundwin',
    ['stand_win'] = 'owner_stand_roundwin',
    ['stand_idle'] = 'owner_stand_idle',
    ['sit_down'] = 'owner_sit',
}
local lord_show_span_min = config.GlobalConfig.LORD_SHOW_SPAN_MIN
local lord_show_span_max = config.GlobalConfig.LORD_SHOW_SPAN_MAX
local betButtonCnt = 5
local betinfo_bg = {
    ['all_in'] = 108524,
    ['fold'] = 108526,
    ['check'] = 134216,--108527,
    ['follow'] = 134216,--108527,
    ['raise'] = 134216
}
local color_txt = {
    ---金币
    ['reconnection_gold'] = {216,194,158},
    ['all_in_gold'] = {0,0,0},
    ['check_gold'] = {216,194,158},
    ['follow_gold'] = {216,194,158},
    ['raise_gold'] ={216,194,158},
    ['fold_gold'] = {255,255,255},
    ---上方加注那块
    ['reconnection_top'] = {216,194,158},
    ['all_in_top'] = {255,255,255},
    ['check_top'] = {255,255,255},
    ['follow_top'] ={255,255,255},
    ['raise_top'] = {255,255,255},
    ['fold_top'] = {225,225,225},
    ---playername
    ['reconnection_name'] = {199,194,186},
    ['all_in_name'] = {0,0,0},
    ['check_name'] = {225,225,225},
    ['follow_name'] ={225,225,225},
    ['raise_name'] = {225,225,225},
    ['fold_name'] = {225,225,225},

}
local icon_bg = {
    ['Icon_Hand'] = {
        ['sel'] = 134197,
        ['dis'] = 134198,
        ['nml'] = 134196,
    },
    ['Icon_spell'] = {
        ['sel'] = 134199,
        ['dis'] = 134200,
        ['nml'] = 134201,
    },
}

local player_info_bg = {['nml'] = 108489,['betting']=108490,['fold'] = 108491}
local hit_vx ={['B'] = 18,['R'] = 19,['Y'] = 20}
local HandCard_level_vx = {
    [1] = {['B'] = 21,['R'] = 22,['Y'] = 23},
    [2] = {['B'] = 24,['R'] = 25,['Y'] = 26},
    [3] = {['B'] = 27,['R'] = 28,['Y'] = 29},
}
round.betNum = {}
BetPanel.betting_player = nil
BetPanel.bettingTimer  = nil
BetPanel.button_player  = nil
BetPanel.handcard_visible = false
local BetPanelPath = 'BetPanel.main_bg.BetPanel'
local GameInfoPath = 'BetPanel.main_bg.GameInfo'
local HighestPath = 'BetPanel.main_bg.Highest'
local FoldPanelPath = 'BetPanel.main_bg.FoldPanel'
BetPanel.bet_btn = {
    ['follow'] = {
        ['path'] =BetPanelPath..'.Call',
        ['img']={
            ['nml'] = 133072,
            ['hover'] = 133071,
            ['dwn'] = 133070,
            ['slc'] = 131061,
        }
    },
    ['auto'] = {
        ['path'] =BetPanelPath..'.call_auto',
        ['img']={
            ['nml'] = 133072,
            ['hover'] = 133071,
            ['dwn'] = 133070,
            ['slc'] = 131061,
        }
    },
    ['raise'] = {
        ['path'] =BetPanelPath..'.Raise',
        ['img']={
            ['nml'] = 133072,
            ['hover'] = 133071,
            ['dwn'] = 133070,
            ['slc'] = 131061,
        }
    },
    ['fold'] = {
        ['path'] =BetPanelPath..'.Fold',
        ['img']={
            ['nml'] = 133076,
            ['hover'] = 133075,
            ['dwn'] = 133074,
            ['slc'] = 108502,
        }
    },
    ['all_in'] = {
        ['path'] =BetPanelPath..'.All_In',
        ['img']={
            ['nml'] = 133067,
            ['hover'] = 133066,
            ['dwn'] = 133065,
            ['slc'] = 108495,
        }
    },
}
for j = 3,5 do
    for i = 1, 5 do
        BetPanel.bet_btn['raise_'..j..'_'..i] = {
            ['path'] =BetPanelPath..'.Bet_Bg_'..j..'.BetButton'..i,
            ['img']={
                ['nml'] = 108517,
                ['hover'] = 108516,
                ['dwn'] = 108515,
                ['slc'] = 131064,
            }
        }
    end
end

---多人联机状态下调试用的print
---@diagnostic disable-next-line: undefined-doc-param
---@param txt string 文本
--[[ local function print(txt)
    txt = tostring(txt)
    local_player:msg(txt)
end ]]

local lord_idle_ani_player ={}
---领主播放待机个性动作
---@param _player table 播放个性动作的玩家 
---@return table anim_player  下一次播放动作的播放器timer
local function play_lord_show_ani(_player)
    local timer
    self:order_lord_do_action(_player,function (_unit)
        _unit:add_animation({['name'] = lord_ani.show})
    end)
    timer = up.wait(
        math.random(lord_show_span_min,lord_show_span_max),
        function ()
            lord_idle_ani_player[_player:get_id()] = play_lord_show_ani(_player)
        end)
    return timer
end

---初始化领主待机动作播放器
function BetPanel:init_lord_idle_ani_player()
    for k,v in pairs(lord_idle_ani_player) do
        if v then v:remove() v = nil end
    end
    for k,v in pairs (round.player) do
        lord_idle_ani_player[v:get_id()] = up.wait(
            math.random(lord_show_span_min,lord_show_span_max),
            function ()
                lord_idle_ani_player[v:get_id()] = play_lord_show_ani(v)
            end
        )
    end
end

---获得玩家A在玩家B的场景座位ui位置
---@param _playerA table 玩家实例
---@param _playerB table 玩家实例
---@return integer seat_id 座位的标号，本地玩家始终为1
function BetPanel:find_player_scene_seat(_playerA,_playerB)
    if not _playerB then _playerB = local_player end
    local seat_id
        if _playerA:get_id() >= _playerB:get_id() then
            seat_id = _playerA:get_id() - _playerB:get_id() + 1
        else
            seat_id = PLAYER_MAX - (_playerB:get_id() - _playerA:get_id()) + 1
        end
    return seat_id
end

local function player_font_set(player)
    local seat_id = BetPanel:find_player_scene_seat(player)
    local action = 'raise'
    local isfollow = false
    if player.is_allin then
        action = 'all_in'
        isfollow = true
        ui:set_text(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg.State'),action:gsub("^%l",string.upper):gsub("_"," "))
        ui:set_image(ui:get_scene_ui_child(local_player.player_info[seat_id],'PlayerInfo'),player_info_bg.betting)
        ui:set_visible(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg'),true)
    else
        if player.discard then
            action = 'fold'
            ui:set_text(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg.State'),action:gsub("^%l",string.upper):gsub("_"," "))
            ui:set_image(ui:get_scene_ui_child(local_player.player_info[seat_id],'PlayerInfo'),player_info_bg.fold)
            ui:set_visible(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg'),true)
        else
            if player.place_bet == round.bet then
                isfollow = true
                ui:set_text(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg.State'),player.place_bet)
                ui:set_image(ui:get_scene_ui_child(local_player.player_info[seat_id],'PlayerInfo'),player_info_bg.betting)
                ui:set_visible(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg'),true)
            else
                ui:set_text(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg.State'),'')
                ui:set_image(ui:get_scene_ui_child(local_player.player_info[seat_id],'PlayerInfo'),player_info_bg.nml)
                ui:set_visible(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg'),false)
            end
        end
    end
    ui:set_image(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg'),betinfo_bg[action])
    ui:set_font_color(ui:get_scene_ui_child(local_player.player_info[seat_id],'State_Bg.State'),color_txt[action..'_top'][1],color_txt[action..'_top'][2],color_txt[action..'_top'][3])
    if isfollow then
        action = 'all_in'
    end
    ui:set_font_color(ui:get_scene_ui_child(local_player.player_info[seat_id],'PlayerName'),color_txt[action..'_name'][1],color_txt[action..'_name'][2],color_txt[action..'_name'][3])
        ui:set_font_color(ui:get_scene_ui_child(local_player.player_info[seat_id],'GoldNum'),color_txt[action..'_gold'][1],color_txt[action..'_gold'][2],color_txt[action..'_gold'][3])
end

---让场上所有的领主执行动作
---@param _player any
---@param _action any
function BetPanel:order_lord_do_action(_player,_action)
    local unit_group_base = GameAPI.get_units_by_key(config.LordData[_player.lord_id].unit)
    local lords = {}
    for index, value in Python.enumerate(unit_group_base) do
        local unit = up.actor_unit(value)
        if unit then
            table.insert(lords,unit)
        end
    end

    for k,v in pairs(lords) do
        _action(v)
    end
end

---读表格获取指定金币数的特效id
---@param _goldnum integer 需要创建特效的金币数
---@param _effect_type string 创建金币的位置,bet or settlement
---@param _get_type string 创建金币的位置,table_effect or projectile
local function get_table_coin_effect(_goldnum,_effect_type,_get_type)
    for k,v in ipairs(config.TableEffect[_effect_type]) do
        if config.TableEffect[_effect_type][k+1] then
            if _goldnum >= v.gold and _goldnum < config.TableEffect[_effect_type][k+1].gold then
                return config.TableEffect[_effect_type][k+1][_get_type]
            end
        end
    end
end

---把在线的玩家信息放在本地玩家的正确UI位置
function BetPanel:seat_init()
    ---场景层
    --初始化场景座位表+金币槽位表
    GameAPI.enable_force_filter_raycast(1)
    local circle_point =  up.actor_point(gameapi.get_circle_center_point(gameapi.get_circle_area_by_res_id(1000000116)))
    for k = 1,4 do
        up.player(k).scene_seat = {}
        for i = 1,4 do
            up.player(k).scene_seat[i] = {}
            up.player(k).scene_seat[i]['angle'] = -90 * (i - 1) + 180
            up.player(k).scene_seat[i]['point'] = circle_point:offset(up.player(k).scene_seat[i]['angle'] - 180,250)
        end
    end
    local_player.player_info = {}
    for i = 1,4 do
        local angle = -90 * (i-1) + 180
        local point = circle_point:offset(angle - 180,250+40)
        --椅子只创一次
        local chair = up.create_unit(134229917,point,angle+180,up.player(32))
        --在椅子上挂上玩家信息
        local player_info_ui
        if i ~= 1 then
            player_info_ui = ui:creat_scene_ui('SceneUI.PlayerInfo',chair,'ui_hp')
        else
            player_info_ui = ui:creat_scene_ui('SceneUI.PlayerInfo',chair,'local_ui')
        end
        local_player.player_info[i] = player_info_ui
        up.wait(0.03,function ()
            local_player.player_info[i] = ui:bind_scene_ui(local_player.player_info[i])
        end)
    end

    local_player.placed_pet_ui = {}
    --为每个玩家的场景以指定玩家处于某个槽位生成一圈领主模型
    for i = 1,4 do
        local now_player = up.player(i)
        --创桌子
        local scenes_table = up.create_unit(134230973,up.actor_point(gameapi.get_circle_center_point(gameapi.get_circle_area_by_res_id(1000000116))),0,up.player(i))
        scenes_table:add_restriction('Invisible')
        scenes_table._base:api_set_transparent_when_invisible(false)
        now_player.scenes_table = scenes_table
        if now_player:is_playing() == true then
            for u = 1,4 do
                local v = up.player(u)
                if v.lord then
                    local seat_id = self:find_player_scene_seat(v,now_player)
                    local lord_model = up.create_unit(config.LordData[v.lord_id].unit,now_player.scene_seat[seat_id].point,now_player.scene_seat[seat_id].angle,up.player(i))
                    lord_model:add_restriction('Invisible')
                    lord_model._base:api_set_transparent_when_invisible(false)
                    up.wait(1.5,function ()
                        lord_model._base:api_change_animation(lord_ani['sit_idle'], "idle1")
                        lord_model._base:api_play_animation(lord_ani['sit_down'], 1, 0.0, -1.0, false, true)
                    end)
                end
            end
        end
    end

    local_player.pot_info = ui:creat_scene_ui('SceneUI.BetFinish',local_player.scenes_table,'coin_sum')
    up.wait(0.03,function() local_player.pot_info = ui:bind_scene_ui(local_player.pot_info) end)
    for t = 1,PLAYER_MAX do
        local placed_pet_ui
        if t <= 1 then
            placed_pet_ui = ui:creat_scene_ui('SceneUI.placed_pet_bg',local_player.scenes_table,scenes_table_coin[#scenes_table_coin + 1 -t])
        else
            placed_pet_ui = ui:creat_scene_ui('SceneUI.placed_pet_bg_up',local_player.scenes_table,scenes_table_coin[#scenes_table_coin + 1 -t])
        end
        up.wait(0.03,function ()
            local_player.placed_pet_ui[t] = ui:bind_scene_ui(placed_pet_ui)
        end)
    end


    ---ui层
    --场景ui晚一帧才会创出来
    up.wait(0.03,function ()
        for i=1,PLAYER_MAX do 
            local v = up.player(i)
            local seat_id = self:find_player_scene_seat(v)
            if v:is_playing() == true then
                ui:set_visible(local_player.player_info[seat_id],true)
                ui:set_text(ui:get_scene_ui_child(local_player.player_info[seat_id],'PlayerName'),v:get_name())
                self:slot_machine_ani(ui:get_scene_ui_child(local_player.player_info[seat_id],'GoldNum'),v:get(GOLD),0,1.0,0.03)
                v.goldtext = v:get(GOLD)
            else
                ui:set_visible(local_player.player_info[seat_id],false)
                ui:set_visible(local_player.placed_pet_ui[seat_id],false)
            end
            ui:vx_event(ui:get_scene_ui_child(local_player.player_info[i],'win_ani'),'show',5,'show',14)
            ui:vx_event(ui:get_scene_ui_child(local_player.player_info[i],'win_ani'),'out',5,'out',10)
        end
    end)
end

---左上角轮次信息播报
function BetPanel:fresh_game_info()
    local next_ante_raise
    ui:set_visible(GameInfoPath,true)
    if GameMode == 'Lord' or GameMode == 'Custom' then
        local is_max = true
        for i = round.num + 1 , #bet_data do
            if bet_data[i].Ante then
                if bet_data[i].Ante ~= bet_data[round.num].Ante and is_max then
                    next_ante_raise = i - round.num
                    is_max = false
                    ui:set_text(GameInfoPath..'.Bg_Info.Text_Round',string.format('%d',round.num))
                    ui:set_text(GameInfoPath..'.Bg_Info.Text_Ante',string.format('%d',round.min_pet))
                    ui:set_text(GameInfoPath..'.Icon.Text',next_ante_raise)
                    ui:set_text(GameInfoPath..'.tip.tip_txt',gameapi.get_text_config('%default_2')..next_ante_raise..gameapi.get_text_config('%default_3'))
                end
            end
        end
        if is_max then
            ui:set_text(GameInfoPath..'.Bg_Info.Text_Round',string.format('%d',round.num))
            ui:set_text(GameInfoPath..'.Bg_Info.Text_Ante',string.format('%d',round.min_pet))
            ui:set_visible(GameInfoPath..'.Icon',false)
            ui:set_visible(GameInfoPath..'.tip',false)
        end
    else
        ui:set_text(GameInfoPath..'.Bg_Info.Text_Round',string.format('%d',local_player:get_save_data(1)))
        ui:set_text(GameInfoPath..'.Bg_Info.Text_Ante',string.format('%d',round.min_pet))
    end
end

---刷新桌上的金币特效
---@param _player player 需要刷新的玩家
---@param _action string 刷新操作的玩家行为
---@param _place_bet integer 桌上已有的金币数
---@param _add_bet integer 新增的金币数 
local function fresh_table_coin(_player,_action,_place_bet,_add_bet)    
    --在每个玩家的桌子上创建该玩家当前应该创建的特效，并保存到该玩家的金币特效表
    for i = 1,4 do
        local scenes_table = up.player(i).scenes_table
        if _action ~= 'check' and _action ~= 'fold' then
            local seat_id = BetPanel:find_player_scene_seat(_player,up.player(i))
            local effect = get_table_coin_effect(_place_bet + _add_bet,'bet','table_effect')
            if _player.coin_effect[i] then _player.coin_effect[i]:remove() end
            if _player.is_watching ~= true then
                if _place_bet ~= 0 then
                    local coin = up.particle{
                        id = effect,
                        target = scenes_table,
                        socket = scenes_table_coin[#scenes_table_coin + 1 -seat_id],
                        scale = 1,
                        time = -1,
                        follow_rotation = true,
                        follow_scale = true
                    }
                    _player.coin_effect[i] = coin
                else
                    _player.coin_effect[i] = nil
                end
            else
                _player.coin_effect[i] = nil
            end
        end
    end
end

---控制桌面上卡牌的显示
---@param _player player 玩家
---@param _action string 类型 in or out
local function fresh_table_card(_player,_action)
    --在每个玩家的桌子上创建该玩家当前应该创建的特效，并保存到该玩家的卡牌特效表
    for i = 1,4 do
        local scenes_table = up.player(i).scenes_table
        if _action ~= 'out' then
            local seat_id = BetPanel:find_player_scene_seat(_player,up.player(i))
            local effect = card_on_table['in']
            if _player.card_effect[i] then _player.card_effect[i]:remove() end
            if _player.place_bet ~= 0 then
                local card = up.particle {
                    id = effect,
                    target = scenes_table,
                    socket = scenes_table_card[#scenes_table_card + 1 -seat_id],
                    scale = 0.5,
                    time = -1,
                    follow_rotation = true,
                    follow_scale = true
                }
                _player.card_effect[i] = card
            else
                _player.card_effect[i] = nil
            end
        else
            local seat_id = BetPanel:find_player_scene_seat(_player,up.player(i))
            if _player.card_effect[i] then _player.card_effect[i]:remove() end
            local effect = card_on_table['out']
            local card = up.particle {
                id = effect,
                target = scenes_table,
                socket = scenes_table_card[#scenes_table_card + 1 -seat_id],
                scale = 0.5,
                time = -1,
                follow_rotation = true,
                follow_scale = true
            }
            _player.card_effect[i] = card
        end
    end
end

---播放弃牌动画
function BetPanel:show_fold_ani()
    for i = 1,2 do
        ui:set_visible('BetPanel.main_bg.Discard_ani_'..i,true)
        ui:vx_play('BetPanel.main_bg.Discard_ani_'..i,11,'out')
    end
end
---设置底注
function BetPanel:get_betNum()
    for i = 1,betButtonCnt do
        --底池式加注算法
        local last_bet = round.last_bet or 0
        local num = round.num or 1
        if bet_data[num] then
            if round.betNum[i] ~= last_bet + (bet_data[num].Ante * bet_data[num]['Bet_'..i]) then
                round.betNum[i] = last_bet + (bet_data[num].Ante * bet_data[num]['Bet_'..i])
            end
        else
            if round.betNum[i] ~= last_bet + (bet_data[#bet_data].Ante * bet_data[#bet_data]['Bet_'..i]) then
                round.betNum[i] = last_bet + (bet_data[#bet_data].Ante * bet_data[#bet_data]['Bet_'..i])
            end
        end
    end
end

---初始化各UI控件的状态
function BetPanel:reset_game_ui()
    for _,v in ipairs(round.player) do
        v.is_auto = false
        ui:set_visible(BetPanelPath..'.call_auto.img_auto',v.is_auto)
        ui:set_visible(BetPanelPath..'.call_auto.text_auto',not v.is_auto)
        v.action = nil
        v.add_bet = 0
        v.follow_bet = 0
        v.raise = 1
        BetPanel:check_bet_btn(v)
        BetPanel:bet_btn_click(1,v)
        if v.lord.ani_state == 'stand' then
            --v.lord._base:clear_change_animation('idle1')
            self:order_lord_do_action(v,function (_unit)
                _unit._base:api_cancel_change_animation(lord_ani['stand_idle'],'idle1')
                _unit._base:api_change_animation(lord_ani['sit_idle'], 'idle1')
                _unit._base:api_play_animation(lord_ani['sit_down'], 1, 0.0, -1.0, false, true)
            end)
            v.lord.ani_state = 'sit'
        end
    end
    BetPanel:get_betNum()
    if GameMode == 'Lord' or GameMode == 'Custom' then
        ui:set_visible(GameInfoPath..'.Bg_Info.Text_1',true)
        ui:set_visible(GameInfoPath..'.Bg_Info.Text_3',false)
    else
        ui:set_visible(GameInfoPath..'.Bg_Info.Text_1',false)
        ui:set_visible(GameInfoPath..'.Bg_Info.Text_3',true)
    end
    GameAPI.set_render_option("FocusDistance", 25)
    for i= 3,5 do
        if betButtonCnt == i then
            ui:set_visible(BetPanelPath..'.Bet_Bg_'..i,true)
        else
            ui:set_visible(BetPanelPath..'.Bet_Bg_'..i,false)
        end
        for j = 1, i do
            ui:set_text(BetPanelPath..'.Bet_Bg_'..i..'.BetButton..'..j..'.Text',2*j..'x')
        end
    end
    BetPanel.magic_card_change(0)
    BetPanel:raise_ui_change(1)
    BetPanel:fresh_bet_btn_select()
    ui:set_visible('BattlePanel',false)
    ui:set_visible('BetPanel',true)
    ui:set_visible('LordSelectPanel',false)
    --ui:set_visible('ResultPanel',false)
    for i = 1,3 do
        ui:set_visible('BetPanel.main_bg.FlopCard_'..i,false)
    end
    ui:set_visible('BetPanel.main_bg.HandCard',true)
    ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn',false)
    for i = 1,2 do
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i,false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.powerup',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.pair_ani',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.Big_pair_ani',false)

        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i,false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.powerup',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.pair_ani',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.Big_pair_ani',false)
    end
    ui:set_visible('BetPanel.BetPanel',false)
    for i= 1,PLAYER_MAX do 
        local seat_id = self:find_player_scene_seat(up.player(i))
        if up.player(i):is_playing() == true then
            --刷新底注显示
            up.wait(0.2,function()
                if ui:get_scene_ui_child(local_player.placed_pet_ui[seat_id],'placed_pet') then 
                    self:slot_machine_ani(ui:get_scene_ui_child(local_player.placed_pet_ui[seat_id],'placed_pet'),up.player(i).place_bet,0,1,0.03)
                    up.player(i).placed_pet_text = up.player(i).place_bet
                end
            end)

            if up.player(i):get(GOLD) == 0 and not up.player(i).is_watching  then 
                up.player(i).action = 'all_in'
                self:play_lord_action_ani(up.player(i))
                BetPanel:fresh_player_action_state(up.player(i),'all_in',up.player(i).place_bet,up.player(i):get(GOLD),up.player(i).place_bet)
            end
        end
        local now_scenes = up.player(i)
        if now_scenes.sum_coin_effect then now_scenes.sum_coin_effect:remove() end
    end
    self.flop_order = 0
    self:play_3D_sound_on_table(134237114)
    if round.BetConfig[round.num] then
        round.add_bet = round.BetConfig[round.num].Ante
    else
        round.add_bet = round.BetConfig[#round.BetConfig].Ante
    end
    --刷新桌上的钱数
    for _,v in ipairs(round.player) do
        --移除要刷新玩家的所有特效
        if v.coin_effect then
            for k,v1 in pairs(v.coin_effect) do
                if v1 then
                    v1:remove()
                end
            end
        end
        if v.cup_effect then
            for k,v1 in pairs(v.cup_effect) do
                if v1 then
                    v1:remove()
                end
            end
        end
        if v.card_effect then
            for k,v1 in pairs(v.card_effect) do
                if v1 then
                    v1:remove()
                end
            end
        end
        v.coin_effect = {}
        v.cup_effect = {}
        v.card_effect = {}
        if not v.is_watching then
            fresh_table_coin(v,'start',v.place_bet,0)
            fresh_table_card(v,'show')
        end
    end
end



---控制玩家投注面板的显示
---@param _switch boolean 显示或隐藏
function BetPanel:show_bet_btn(_switch)
    ui:set_visible(BetPanelPath,_switch)
end

---卡牌对子动效
function BetPanel:play_pairs_ani()
    if self.is_big_pair then
        for i = 1,2 do
            ui:set_image('BetPanel.main_bg.HandCard.HandCard_'..i..'.card_img',local_player.card[i].soldier.red_soldier_image)
            ui:set_image('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.img',local_player.card[i].soldier.red_soldier_image_mini)
        end
        if self.handcard_visible then
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open',true)
            ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open',8,'in')
            ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Close',8,'out')
            for i = 1,2 do
                --ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.Big_pair_ani',true)
                --ui:vx_play('BetPanel.main_bg.HandCard.HandCard_'..i..'.Big_pair_ani',9,'out')
            end
        else
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Close',true)
            ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Close',8,'in')
            ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open',8,'out')
        end
    elseif self.num_type == 'double' then
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Close',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open2',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open3',false)
        for i = 1,2 do
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.pair_ani',false)
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.pair_ani',false)
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.big_pair_ani',false)
        end
        for i = 1,2 do
            ui:set_image('BetPanel.main_bg.HandCard.HandCard_'..i..'.card_img',local_player.card[i].soldier.red_soldier_image)
            ui:set_image('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.img',local_player.card[i].soldier.red_soldier_image_mini)
        end
        if self.handcard_visible then
            for i = 1,2 do
                ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.pair_ani',true)
                ui:vx_play('BetPanel.main_bg.HandCard.HandCard_'..i..'.pair_ani',10,'in')
                ui:play_ui_comp_anim('CardNum'..i..'_buff',false,1)
                ---有问题
                ui:wait(0.0333*16,function ()
                    ui:play_ui_comp_anim('CardNum'..i..'_buff_2',true,1)
                end)
            end
        else
            for i = 1,2 do
                ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.pair_ani',true)
                ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.pair_ani',10,'in')
            end
        end
    else
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Close',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open2',false)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open3',false)
        for i = 1,2 do
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.pair_ani',false)
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.pair_ani',false)
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.big_pair_ani',false)
        end
    end
end

---翻转手牌
---@param _order integer 第几张手牌
---@param _switch boolean 翻到正面或者反面
function BetPanel:turn_card(_order,_switch)
    local i = _order
    ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i,true)
    --ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.card_icon',_switch)
    ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.Num_bg',_switch)
    --ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.card_bg.back',not _switch)
    ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.card_bg.back2',not _switch)
    --ui:set_visible('BetPanel.main_bg.HandCard',_switch)
    if _switch then
        ui:set_image('BetPanel.main_bg.HandCard.HandCard_'..i..'.card_img',local_player.card[i].soldier.soldier_image)
        ui:set_image('BetPanel.main_bg.HandCard.HandCard_'..i..'.Num_bg.CardNum_img',ui.card_num_img[local_player.card[i].num][self.num_type])
        ui:set_image('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.img',local_player.card[i].soldier.soldier_image_mini)
        ui:set_image('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.Num_bg.CardNum_img',ui.card_num_img[local_player.card[i].num][self.num_type])
        local_player.card[i].powerup_times = 0
    end
end

---设置玩家手牌内容
function BetPanel:set_hand_card()
    self.num_type = 'nml'
    self.is_big_pair = false
    if local_player.card[1].num == local_player.card[2].num then
        self.num_type = 'double'
    end
    if self.num_type == 'double' and  local_player.card[1].soldier.unit_id == local_player.card[2].soldier.unit_id then
        self.is_big_pair = true
    end
    
    ui:set_opacity('BetPanel.main_bg.HandCard',100)
    --先显示卡背
    for i = 1,2 do
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.powerup',false)
        ui:set_opacity('BetPanel.main_bg.HandCard.HandCard_'..i,100)
        self:turn_card(i,false)
        local_player.card[i].color = nil
    end

    --播翻牌动画，播完到12帧隐藏卡背
    ui:play_ui_comp_anim('HandCard_1_turnover',false,1)
    ui:wait(12*0.0333,function ()
        ui:play_2d_sound(134243749)
        self:turn_card(1,true)
    end)
    ui:wait(0.5,function ()
        ui:play_ui_comp_anim('HandCard_2_turnover',false,1)
        ui:wait(12*0.0333,function ()
            ui:play_2d_sound(134243749)
            self:turn_card(2,true)
            self:show_starting_hand(true)
            self:play_pairs_ani()
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn',true)
            if self.num_type == 'double' and  local_player.card[1].soldier.unit_id == local_player.card[2].soldier.unit_id then
                ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open2',true)
                ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open3',true)
                ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open2',41,'out')
                ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open3',40,'out')
            end
        end)
    end) 
end
---控制玩家的手牌显示
---@param _switch boolean 显示或隐藏
function BetPanel:show_starting_hand(_switch)
    self.handcard_visible = _switch
    for i = 1,2 do
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i,_switch)
        ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i,not(_switch))
        if not local_player.card[i] then return end
        if local_player.card[i].color and local_player.card[i].powerup_times and HandCard_level_vx[local_player.card[i].powerup_times] then
            if local_player.card[i].powerup_times ~= 3 then
                ui:vx_play('BetPanel.main_bg.HandCard.HandCard_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'loop')
                ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'loop')
            else
                ui:vx_play('BetPanel.main_bg.HandCard.HandCard_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'in')
                ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'in')
            end
        else
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.powerup',false)
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.powerup',false)
        end
    end
    self:play_pairs_ani()
end

---刷新操作板按钮选中态
function BetPanel:fresh_bet_btn_select()
    if local_player.is_watching ~= false or local_player.is_watching == nil then return end
    -- for k,v in pairs(self.bet_btn) do
    --     if local_player.action == k then
    --         ui:set_image(v.path,v.img.slc)
    --         ui:set_image_hover(v.path,v.img.slc)
    --         ui:set_image_press(v.path,v.img.slc)
    --     else
    --         ui:set_image(v.path,v.img.nml)
    --         ui:set_image_hover(v.path,v.img.hover)
    --         ui:set_image_press(v.path,v.img.dwn)
    --     end
    -- end
    for i = 1,betButtonCnt do
        local _uiDate = BetPanel.bet_btn['raise_'..betButtonCnt..'_'..i]
        if local_player.raise == i then
            ui:set_image(_uiDate.path,'131064')
        else
            ui:set_image(_uiDate.path,_uiDate.img.nml)
        end
    end
    BetPanel:lock_bet_button(local_player)
end

function BetPanel:raise_ui_change(raise)
    for i = 1,betButtonCnt do
        if raise <= i then
            ui:set_enable(BetPanel.bet_btn['raise_'..betButtonCnt..'_'..i].path,true)
        else
            ui:set_enable(BetPanel.bet_btn['raise_'..betButtonCnt..'_'..i].path,false)
        end
    end
end

---在桌子的音效点位置播放3D音效 Vo_Allin allin台词 Vo_Fold弃牌 | Vo_Taunt嘲讽台词 Vo_RndVic回合胜利
---@param _sound_id integer 音频id
function BetPanel:play_3D_sound_on_table(_sound_id,is_seat,_player,str)
	if not _sound_id then
		print("============检查",_sound_id)
		return
	end
    if tostring(_sound_id):sub(1, 1) == '%' then _sound_id = tonumber(gameapi.get_text_config(_sound_id)) end
    for i =1 ,PLAYER_MAX do
        local player = up.player(i)
        local _soundPoint = soundPoint
        if is_seat and player then
            if is_seat == 1 then
                local seat_id = self:find_player_scene_seat(_player,player)
                _soundPoint = CoinPoint[seat_id]
            elseif is_seat == 2 then
                local circle_point = up.get_circle_center_point(1000000116)
                local angle = -90 * (i - 1)+180
                local point = circle_point:offset(angle,400)
                _soundPoint = point
            end
        end
		
        local sound = gameapi.play_3d_sound_for_player(player._base,_sound_id,_soundPoint._base,Fix32(1100.0))
        if str then
            if local_player == player then
                local _have_player = false
                local volume = 100
                for k,v in ipairs(sound_tab) do
                    if v.sound then
                        if v.player ~= player then
                            v.volume = v.volume - 20
                            gameapi.set_sound_volume(player._base,v.sound, math.max(0,v.volume))
                        else
                            _have_player = true
                        end
                    end
                end
                local val = #sound_tab 
                for k,v in ipairs(sound_tab) do
                    local slot = val - k + 1
                    if v.volume <= 0 then
                        table.remove(sound_tab,slot)
                    end
                end
                if _have_player then
                    volume = 80
                end
                local _sound_table = {}
                _sound_table.sound = sound
                _sound_table.volume = volume
                _sound_table.player = _player
                table.insert(sound_tab, _sound_table)
            end
        end
    end
end

---领主做指定操作的时候播动作
---@param _player player 需要播动作的玩家
function BetPanel:play_lord_action_ani(_player,_action)
    if not _action then _action = _player.action end
    if _action == "all_in" then
        self:order_lord_do_action(_player,function (_unit)
            _unit._base:api_cancel_change_animation(lord_ani.sit_idle,'idle1')
            _unit._base:api_change_animation(lord_ani.stand_idle,'idle1')
            _unit:add_animation({['name'] = lord_ani.all_in})
        end)
        _player.lord.ani_state = 'stand'
        self:play_3D_sound_on_table(config.LordData[_player.lord_id].Vo_Allin,2,_player,'Vo_Allin')
    end
    for i = 1,5 do
        if _action =='raise_'..i then
            self:order_lord_do_action(_player,function (_unit)
                _unit:add_animation({['name'] = lord_ani.bet[i]})
            end)
        end
    end
    if _action == "follow" then
        self:order_lord_do_action(_player,function (_unit)
            _unit:add_animation({['name'] = lord_ani.bet[1]})
        end)
    end
end

---控制下注按钮的整体禁用，防止连点情况下发N个事件。
---@param _player player 需要控制的玩家
---@param _switch boolean 是否启用下注按钮
function BetPanel:lock_bet_button(_player,_switch)
    if _switch then
        for k, v in pairs(self.bet_btn) do
            ui:set_enable(v.path,_switch) 
        end
        self:check_bet_btn(_player)
    else
        if not round.raise then round.raise = 1 end
        if _player == local_player then
            if local_player.is_allin or local_player.action == 'fold' or local_player.action == 'all_in' then
                for k, v in pairs(self.bet_btn) do
                    ui:set_enable(v.path,false)
                end
            else
                if local_player.place_bet < round.bet then
                    ui:set_enable(BetPanel.bet_btn['fold'].path,true)
                    ui:set_enable(BetPanel.bet_btn['all_in'].path,true)
                    ui:set_enable(BetPanel.bet_btn['follow'].path,true)
                    if round.betNum[betButtonCnt] >= round.bet and local_player.place_bet < round.betNum[local_player.raise] then
                        ui:set_enable(BetPanel.bet_btn['raise'].path,true)
                    else
                        ui:set_enable(BetPanel.bet_btn['raise'].path,false)
                    end
                else
                    ui:set_enable(BetPanel.bet_btn['fold'].path,false)
                    ui:set_enable(BetPanel.bet_btn['all_in'].path,true)
                    ui:set_enable(BetPanel.bet_btn['follow'].path,false)
                    if round.betNum[betButtonCnt] > round.bet and local_player.place_bet < round.betNum[local_player.raise] then
                        ui:set_enable(BetPanel.bet_btn['raise'].path,true)
                    else
                        ui:set_enable(BetPanel.bet_btn['raise'].path,false)
                    end
                end
                BetPanel:raise_ui_change(round.raise)
            end
        end
    end
    for i = 1,betButtonCnt do
        if round.raise <= i and round.betNum[i] > round.bet then
            ui:set_enable(BetPanel.bet_btn['raise_'..betButtonCnt..'_'..i].path,true)
        else
            if round.betNum[i] == round.bet and local_player.place_bet < round.bet then
                ui:set_enable(BetPanel.bet_btn['raise_'..betButtonCnt..'_'..i].path,true)
            else
                ui:set_enable(BetPanel.bet_btn['raise_'..betButtonCnt..'_'..i].path,false)
            end
        end
    end
end


---尝试进行下注
---@param _player player 尝试下注的玩家
function BetPanel:try_bet(_player)
    ---下注流程调整 下注
    if _player.double_click_cd then return end
    if not _player.action then return end
    self:fresh_bet_btn_select()
    local seat_id = self:find_player_scene_seat(_player)
    self:slot_machine_ani(ui:get_scene_ui_child(local_player.placed_pet_ui[seat_id],'placed_pet'),_player.place_bet + _player.add_bet,_player.placed_pet_text,1,0.03)
    _player.add_bet = tonumber(string.format('%d',_player.add_bet))
    _player.placed_pet_text = _player.place_bet + _player.add_bet
    if _player.add_bet >= _player:get(GOLD) then
        _player.action = 'all_in'
    end
    BetPanel:play_lord_action_ani(_player)
    round.add_bet = _player.add_bet
    _player.double_click_cd = true
    up.game:event_dispatch('回合流程-玩家下注',_player,_player.add_bet,_player.action)
end

---检查按钮是不是需要释放和禁选
---@param _player player 尝试检查的玩家
function BetPanel:check_bet_btn(_player)
    for i = 1,betButtonCnt do
        --底池式加注算法
        local last_bet = round.last_bet or 0
        if bet_data[round.num] then
            if round.betNum[i] ~= last_bet + (bet_data[round.num].Ante * bet_data[round.num]['Bet_'..i]) then
                round.betNum[i] = last_bet + (bet_data[round.num].Ante * bet_data[round.num]['Bet_'..i])
            end
        else
            if round.betNum[i] ~= last_bet + (bet_data[#bet_data].Ante * bet_data[#bet_data]['Bet_'..i]) then
                round.betNum[i] = last_bet + (bet_data[#bet_data].Ante * bet_data[#bet_data]['Bet_'..i])
            end
        end
        if _player.action == 'raise_'..i  then _player.add_bet = round.betNum[i] - _player.place_bet end
        if round.betNum[i] < round.bet or _player:get(GOLD) < round.betNum[i] - round.bet or _player:get(GOLD) <= _player.add_bet then
            if _player.action == 'raise_'..i then _player.action = nil end
        end
    end
    ---释放检查
    if _player.action ~= 'fold' and _player.action ~= 'all_in' then
        if round.bet > _player.add_bet + _player.place_bet then _player.action = nil end
        if _player.action then
            if string.find(_player.action,'raise')  and round.bet == _player.add_bet + _player.place_bet then 
                _player.action = 'call'
                _player.follow_bet = _player.add_bet 
            end
        end
    end
    ---本地按钮显示刷新
    print(local_player.is_watching)
    if local_player.is_watching ~= false or local_player.is_watching == nil then return end
    local gold = local_player:get(GOLD)
    if GameMode =='Lord' or GameMode == 'Custom'then
        if (gold <= round.bet - local_player.place_bet or gold < round.betNum[1]) and gold ~= 0 then
            ui:set_visible(BetPanelPath..'.All_In',true)
        end
    else
        if gold ~= 0 then
            ui:set_visible(BetPanelPath..'.All_In',true)
        end
    end
    ui:set_text(BetPanelPath..'.Call.txt_call_number',string.format('%d',round.bet - local_player.place_bet))
    self:fresh_bet_btn_select()
end

---控制公共牌的展示
---@param _switch boolean 显示或隐藏
---@param _order integer 第几张公共牌
function BetPanel:show_flop(_switch,_order)
    ui:set_visible('BetPanel.main_bg.FlopCard_'.._order,_switch)
    ui:set_text('BetPanel.main_bg.FlopCard_'.._order..'.CardName',round.magic_card[_order].name)
    ui:set_text('BetPanel.main_bg.FlopCard_'.._order..'.CardName.CardName_shadow',round.magic_card[_order].name)
    ui:set_image('BetPanel.main_bg.FlopCard_'.._order..'.card_img',round.magic_card[_order].icon)
    ui:set_text('BetPanel.main_bg.FlopCard_'.._order..'.CardType','场地魔法')
    ui:set_text('BetPanel.main_bg.FlopCard_'.._order..'.DesBg.DesTxt',round.magic_card[_order].tips)
end

---控制下注界面公共牌的变大tips显示
---@param _switch boolean 显示或隐藏
function BetPanel:show_flop_tips(_switch,i)
    if not self.flop_order then return end
    if i <= self.flop_order then
        if _switch then
            ui:play_ui_comp_anim('FlopCard_'..i..'_ZoomIn')
            ui:set_z_order('BetPanel.main_bg.FlopCard_'..i,50)
        else
            ui:play_ui_comp_anim('FlopCard_'..i..'_ZoomOut')
            ui:set_z_order('BetPanel.main_bg.FlopCard_'..i,1)
        end
    end
end


---用于提示玩家下注的暗角动画插值器
---@param _total_time float 闪烁总时间
---@param _dalta_time float 从亮到暗一次的时间
---@param _min_value float 最小的时候的暗角大小
function BetPanel:new_vignetting_tweener(_total_time,_delta_time,_min_value)
    local now_times = -1
    local max_value = 0.4
    local now_value = max_value
    local flash_times = _total_time/_delta_time/2
    local per_value = (max_value - _min_value) / (_total_time / (flash_times * 2))
    local state = 'down'
    local_player.vignetting_tweener = ui:loop(_delta_time,function()
        if now_value <= _min_value then
            state = 'up'
        elseif now_value >= max_value then
            state = 'down'
            now_times = now_times + 1
        end
        if state == 'up' then
            now_value = now_value + per_value
        else
            now_value = now_value - per_value
        end
        local_player._base:set_role_vignetting_size(Fix32(now_value))
        if now_times == flash_times or local_player ~= self.betting_player then
            local_player._base:set_role_vignetting_size(Fix32(max_value))
            ui:remove_timer(local_player.vignetting_tweener)
        end
    end)
end


---下注流程调整 加注事件调整为设定倍数
---加注按钮的事件处理
---@param _bet_btn_Order integer 第几个加注按钮
function BetPanel:bet_btn_click(_bet_btn_Order,_player)
    _player.raise = _bet_btn_Order
    if _player == local_player then
        ui:set_text(BetPanelPath..'.Raise.text_raise',string.format('%d',round.betNum[_player.raise]))
    end
    self:fresh_bet_btn_select()
end


---下注流程调整 新增事件raise  call
---raise的事件处理
---@param _player player 点击按钮的玩家
function BetPanel:raise_click(_player)
    local add_bet = tonumber(string.format('%d',round.betNum[_player.raise]))
    if add_bet < round.bet or _player.is_allin then
        return
    end
    _player.action = 'raise_'.._player.raise
    _player.add_bet =  add_bet - _player.place_bet
    round.raise = _player.raise
    self:fresh_bet_btn_select()
    self:try_bet(_player)
end
---auto的事件处理
---@param _player player 点击按钮的玩家
function BetPanel:auto_click(_player)
    _player.is_auto = not _player.is_auto
    print('无限跟==========',_player,round.add_bet)
    if _player.place_bet < round.bet then
        self:follow_click(_player)
        return
    end
    if _player == local_player then
        ui:set_visible(BetPanelPath..'.call_auto.img_auto',_player.is_auto) 
        ui:set_visible(BetPanelPath..'.call_auto.text_auto',not _player.is_auto)
    end
    self:fresh_bet_btn_select()
end


---跟牌、过牌的事件处理
---@param _player player 点击按钮的玩家
function BetPanel:follow_click(_player)
    _player.action = 'follow'
    if _player:get(GOLD) <= round.add_bet then
        self:all_in_click(_player)
        return
    else
        _player.add_bet = round.bet - _player.place_bet
    end
    self:fresh_bet_btn_select()
    self:try_bet(_player)
end

---allin的事件处理
---@param _player player 点击按钮的玩家
function BetPanel:all_in_click(_player)
    _player.add_bet = _player:get(GOLD)
    _player.action = 'all_in'
    self:fresh_bet_btn_select()
    self:try_bet(_player)
end

---弃牌的事件处理
---@param _player player 点击按钮的玩家
function BetPanel:fold_click(_player)
    if _player.place_bet < round.bet then
        _player.add_bet = 0
        _player.action = 'fold'
        self:fresh_bet_btn_select()
        self:try_bet(_player)
    end
end

---魔法卡刷新
---@param i integer 魔法卡展示ID
function BetPanel.magic_card_change(id)
    up.wait(1.5,function()
        round.raise = 1
        BetPanel:check_bet_btn(local_player)
        for _, v in ipairs(round.player) do
            v.double_click_cd = false
            BetPanel:bet_btn_click(1,v)
            BetPanel:lock_bet_button(v)
        end
    end)
    if id == 0 then
        ui:set_image(GameInfoPath..'.Bg_Step.List_Step.Icon_Hand.icon',icon_bg['Icon_Hand']['sel'])
        ui:set_visible(GameInfoPath..'.Bg_Step.List_Step.text_hand',true)
        for _, v in ipairs(round.player) do
            player_font_set(v)
        end
    else
        ui:set_image(GameInfoPath..'.Bg_Step.List_Step.Icon_Hand.icon',icon_bg['Icon_Hand']['dis'])
        ui:set_visible(GameInfoPath..'.Bg_Step.List_Step.text_hand',false)
    end
    for i = 1,3 do
        if id == i then
            ui:set_image(GameInfoPath..'.Bg_Step.List_Step.Icon_spell_'..i..'.icon',icon_bg['Icon_spell']['sel'])
            ui:set_visible(GameInfoPath..'.Bg_Step.List_Step.text_spell_'..i,true)
        else
            if i < id then
                ui:set_image(GameInfoPath..'.Bg_Step.List_Step.Icon_spell_'..i..'.icon',icon_bg['Icon_spell']['dis'])
            else
                ui:set_image(GameInfoPath..'.Bg_Step.List_Step.Icon_spell_'..i..'.icon',icon_bg['Icon_spell']['nml'])
            end
            ui:set_visible(GameInfoPath..'.Bg_Step.List_Step.text_spell_'..i,false)
        end
    end
end


---刷新玩家的操作状态
---@param _player player 玩家
---@param _action string 玩家的操作
---@param _place_bet integer 已经下过的注码
---@param _add_bet integer 新增的注码
---@param _round_bet integer 回合当前的最高注 
function BetPanel:fresh_player_action_state(_player,_action,_place_bet,_add_bet,_round_bet)
    local seat_id = self:find_player_scene_seat(_player)
    if not _action then return end
    local action = _action
    local raise_num = '0'
    raise_num = string.format('%d',round.betNum[_player.raise or 1])
    if string.find(_action,'raise') then
        for i = 1 ,5 do
            if _action == 'raise_' .. i then
                self:play_3D_sound_on_table(bet_sound[i],1,_player)
            end
        end
        action = 'raise'
    end
    if _action == 'check' then
        self:play_3D_sound_on_table(134281576,1,_player)
    end
    if _action == 'follow' then
        action = 'call'
        self:play_3D_sound_on_table(bet_sound[1],1,_player)
    end
    if _action == 'fold' then
        ui:set_image(ui:get_scene_ui_child(local_player.player_info[seat_id],'PlayerInfo'),player_info_bg.fold)
        fresh_table_card(_player,'out')
    end
    --print(_player:get_id().._player.action..':'..round.bet)

    player_font_set(_player)
    print('刷新玩家操作',_player,_action,_place_bet,_add_bet)
    fresh_table_coin(_player,_action,_place_bet,_add_bet)
end

---刷新玩家的面板金币数量显示
---@param _player player 需要刷新的玩家
function BetPanel:fresh_player_gold(_player)
    local player_seat = self:find_player_scene_seat(_player)
    if not local_player.player_info then return end
    if not ui:get_scene_ui_child(local_player.player_info[player_seat],'GoldNum') then return end
    if not _player.goldtext then _player.goldtext = 0 end
    self:slot_machine_ani(ui:get_scene_ui_child(local_player.player_info[player_seat],'GoldNum'),_player:get(GOLD),_player.goldtext,1.0,0.03)
    _player.goldtext = _player:get(GOLD)
end



---老虎机数字滚动效果
---@param _path string 文本控件路径
---@param _target_value float 动画后的目标值
---@param _old_value float 该文本的当前值
---@param _total_time float 动画持续时间
---@param _delta_time float 每次数字变化的时间
function BetPanel:slot_machine_ani(_path,_target_value,_old_value,_total_time,_delta_time)
    if _path == nil then
        return
    end
    local change_times = _total_time/_delta_time
    local per_value = (_target_value - _old_value) / change_times
    local now_value = _old_value 
    ui:set_text(_path,string.format('%d',now_value))
    if local_player[_path .. "text_timer"] then ui:remove_timer(local_player[_path .. "text_timer"]) end
    local_player[_path .. "text_timer"] = ui:loop(_delta_time,function()
        if _target_value > _old_value then
            now_value = now_value + per_value
            ui:set_text(_path,string.format('%d',now_value))
            if now_value >= _target_value then
                --print('wc',local_player[_path .. "text_timer"],_path)
                ui:set_text(_path,string.format('%d',_target_value))
                ui:remove_timer(local_player[_path .. "text_timer"])
            end
        elseif _target_value < _old_value then
            now_value = now_value + per_value
            ui:set_text(_path,string.format('%d',now_value))
            if now_value <= _target_value then
                ui:set_text(_path,string.format('%d',_target_value))
                ui:remove_timer(local_player[_path .. "text_timer"])
            end
        else
            ui:set_text(_path,string.format('%d',_target_value))
            ui:remove_timer(local_player[_path .. "text_timer"])
        end
    end)
end

---创建聚集的金币堆
function BetPanel:gather_coins()
    if self.betting_player then
        self:order_lord_do_action(self.betting_player,function (_unit)
            if _unit.bet_light then _unit.bet_light:remove() end
        end)
    end
    if #round.player ~= 1 then
        local _player = round.player[math.random(1,#round.player)]
        self:play_3D_sound_on_table(config.LordData[_player.lord_id].Vo_Taunt,2,_player)
    end
    self:play_3D_sound_on_table(134266376)
    for n = 1,4 do
        local v = up.player(n)
        if v:is_playing() and not v.is_watching then
            for i = 1,4 do 
                local now_scenes = up.player(i)
                local seat_id = self:find_player_scene_seat(v,now_scenes)
                local angle = gameapi.get_points_angle(CoinPoint[seat_id]._base, CoinPoint[#CoinPoint]._base):float()
                local speed = 15
                local dis = gameapi.get_points_dis(CoinPoint[seat_id]._base, CoinPoint[#CoinPoint]._base):float() / speed
                if v.coin_effect then
                    v.coin_effect[seat_id]:remove()
                end
                local fly_coin_id = get_table_coin_effect(v.place_bet,'bet','projectile')
                local fly_coin = now_scenes.scenes_table:add_effect({
                    id = fly_coin_id,
                    socket = scenes_table_coin[#scenes_table_coin + 1 -seat_id],
                    --socket = 'coin_sum',
                })
                local args = StraightMoverArgs()
				args.set_collision_type          (0)
				args.set_collision_radius        (Fix32(0.0))
				args.set_is_face_angle           (true)
				args.set_is_multi_collision      (false)
				args.set_unit_collide_interval   (Fix32(0.0))
				args.set_terrain_block           (false)
				args.set_terrain_collide_interval(Fix32(0.0))
				args.set_priority                (1)
				args.set_is_absolute_height      (false)
				args.dict['is_open_auto_pitch']  = false

                args.set_angle(Fix32(angle))
                args.set_max_dist(Fix32(dis))
                args.set_init_velocity(Fix32(speed))
                args.set_acceleration(Fix32(0.0))
                args.set_max_velocity(Fix32(9999.0))
                args.set_min_velocity(Fix32(0.0))
                args.set_init_height(Fix32(0))
                args.set_fin_height(Fix32(100))
                args.set_parabola_height(Fix32(120))
                args.set_is_parabola_height(true)
                args.set_is_open_init_height(false) --会重置挂接点
                args.set_is_open_fin_height(true)
				
                local unit_collide = function() end
                local mover_finish = function() end
                local terrain_collide = function() end
                local mover_interrupt = function() end
                local mover_removed
                if seat_id ~= 1 then
                    mover_removed = function()
                        fly_coin:remove()
                    end
                else
                    mover_removed = function()
                        fly_coin:remove()
                        local sum_coin = 0
                        for x = 1,PLAYER_MAX do
                            sum_coin = sum_coin + up.player(x).place_bet
                        end

                        local sum_coin_id = get_table_coin_effect(sum_coin,'settlement','table_effect')
                        now_scenes.sum_coin_effect = up.particle({
                            id = sum_coin_id,
                            target = now_scenes.scenes_table,
                            socket = 'coin_sum',
                            scale = 1,
                            time = -1,
                        })
                        if now_scenes == local_player then
                            ui:set_visible(local_player.pot_info,true)
                            self:slot_machine_ani(ui:get_scene_ui_child(local_player.pot_info,'txt_number'),sum_coin,0,1,0.03)
                            ui:play_2d_sound(134273798)
                        end
                    end
                end
                fly_coin._base:create_mover_trigger(args,'StraightMover',unit_collide,mover_finish,terrain_collide,mover_interrupt,mover_removed)
            end
        end
    end
end

---给每个玩家的场景创建飞向每个在结算时拿钱的玩家的飞行特效
function BetPanel:coins_to_winner()
    local win_player = round.player[1]
    if not win_player then
        for n = 1,PLAYER_MAX do
            local now_scenes = up.player(n)
            if now_scenes.sum_coin_effect then now_scenes.sum_coin_effect:remove() end
        end
        up.game:event_dispatch('回合流程-结算完成')
        self:fresh_game_info()
        return
    end

    local gold = 0
    self:play_3D_sound_on_table(134266376)
    for pid = 1, PLAYER_MAX do
        local player = up.player(pid)
        --ALL-IN逻辑
        if player.place_bet > win_player.place_bet then
            gold = gold + win_player.place_bet
            for n = 1,PLAYER_MAX do
                local now_scenes = up.player(n)
                local fly_coin_id = get_table_coin_effect(player.place_bet - win_player.place_bet,'settlement','projectile')
                local fly_target = self:find_player_scene_seat(player,now_scenes)
                local angle = gameapi.get_points_angle(CoinPoint[#CoinPoint]._base, CoinPoint[fly_target]._base):float()
                local speed = 15
                local dis = gameapi.get_points_dis(CoinPoint[#CoinPoint]._base, CoinPoint[fly_target]._base):float() /speed
                local fly_coin = now_scenes.scenes_table:add_effect({
                    id = fly_coin_id,
                    socket = 'coin_sum',
                })

                local args = StraightMoverArgs()
                args.set_angle(Fix32(angle))
                args.set_max_dist(Fix32(dis))
                args.set_init_velocity(Fix32(speed))
                args.set_acceleration(Fix32(0.0))
                args.set_max_velocity(Fix32(9999.0))
                args.set_init_height(Fix32(100))
                args.set_fin_height(Fix32(100))
                args.set_parabola_height(Fix32(120))
                args.set_collision_type(0)
                args.set_collision_radius(Fix32(0.0))
                args.set_is_face_angle(true)
                args.set_is_multi_collision(false)
                args.set_terrain_block(false)
                args.set_priority(1)
                args.set_is_parabola_height(true)
                args.set_is_absolute_height(false)
                args.set_is_open_init_height(false) --会重置挂接点
                args.set_is_open_fin_height(true)
                local unit_collide = function() end
                local mover_finish = function() end
                local terrain_collide = function() end
                local mover_interrupt = function() end
                local mover_removed
                if fly_target ~= 1 then
                    mover_removed = function()
                        fly_coin:remove()
                    end
                else
                    mover_removed = function()
                        fly_coin:remove()
                        round:GoldChange(player.place_bet - win_player.place_bet,player)
                        self:fresh_game_info()
                    end
                end
                fly_coin._base:create_mover_trigger(args,'StraightMover',unit_collide,mover_finish,terrain_collide,mover_interrupt,mover_removed)
            end
        else
            gold = gold + player.place_bet
        end
    end

    for n = 1,PLAYER_MAX do
        local now_scenes = up.player(n)
        ---这里不知道为什么大金币堆会拿到空，先判了再说
        if now_scenes.sum_coin_effect then now_scenes.sum_coin_effect:remove() end
        ui:set_visible(local_player.pot_info,false)
        local fly_coin_id = get_table_coin_effect(gold,'settlement','projectile')
        local fly_target = self:find_player_scene_seat(win_player,now_scenes)
        local angle = gameapi.get_points_angle(CoinPoint[#CoinPoint]._base,CoinPoint[fly_target]._base):float()
        local speed = 15*15
        local dis = gameapi.get_points_dis(CoinPoint[#CoinPoint]._base, CoinPoint[fly_target]._base):float() --/speed
        local fly_coin = now_scenes.scenes_table:add_effect({
            id = fly_coin_id,
            socket = 'coin_sum',
            scale = 1,
            visible_type = 2,
        })

        --print(n,fly_target,angle,dis,CoinPoint[fly_target]:get_x(),CoinPoint[fly_target]:get_y()CoinPoint[fly_target]:get_z())
        local args = StraightMoverArgs()
        args.set_angle(Fix32(angle))
        args.set_max_dist(Fix32(dis))
        args.set_init_velocity(Fix32(speed))
        args.set_acceleration(Fix32(0.0))
        args.set_max_velocity(Fix32(9999.0))
        args.set_min_velocity(Fix32(0.0))
        args.set_init_height(Fix32(100))
        args.set_fin_height(Fix32(100))
        args.set_parabola_height(Fix32(120))
        args.set_collision_type(0)
        args.set_collision_radius(Fix32(0.0))
        args.set_is_face_angle(true)
        args.set_is_multi_collision(false)
        args.set_terrain_block(false)
        args.set_priority(1)
        args.set_is_parabola_height(true)
        args.set_is_absolute_height(false)
        args.set_is_open_init_height(false) --会重置挂接点
        args.set_is_open_fin_height(true)
        local unit_collide = function() end
        local mover_finish = function() end
        local terrain_collide = function() end
        local mover_interrupt = function() end
        local mover_removed
        if n ~= 1 then
            mover_removed = function()
                fly_coin:remove()
            end
        else
            mover_removed = function()
                fly_coin:remove()
                round:GoldChange(gold,win_player)
            end
        end
        fly_coin._base:create_mover_trigger(args,'StraightMover',unit_collide,mover_finish,terrain_collide,mover_interrupt,mover_removed)
        if now_scenes == local_player then
            ui:set_visible(ui:get_scene_ui_child(local_player.player_info[fly_target],'win_ani'),true)
            ui:vx_play(ui:get_scene_ui_child(local_player.player_info[fly_target],'win_ani'),5,'show')
        end
    end
    local _num = round.num
    up.wait(6,function ()
        if _num == round.num then
            print('进保险++++++++++++++++++++++++++++++++++')
            up.game:event_dispatch('回合流程-结算完成')
            BetPanel:fresh_game_info()
        else
            print('没保险++++++++++++++++++++++++++++++++++')
        end
    end)
    local time_l = 3
    if win_player.lord.ani_state == 'stand' then
        self:order_lord_do_action(win_player,function (_unit)
            _unit:add_animation({['name'] = lord_ani.stand_win})
        end)
        time_l = config.LordData[win_player.lord_id].stand_win_time
    else
        self:order_lord_do_action(win_player,function (_unit)
            _unit:add_animation({['name'] = lord_ani.sit_win})
        end)
        time_l = config.LordData[win_player.lord_id].sit_win_time
    end
    up.wait(time_l+0.1,function ()
        up.game:event_dispatch('回合流程-结算完成')
        BetPanel:fresh_game_info()
    end)
    self:play_3D_sound_on_table(config.LordData[win_player.lord_id].Vo_RndVic,2,win_player)
end

---删除退出的玩家在下注界面的所有实例
---@param _player player 退出的玩家
function BetPanel:delete_player_instance(_player)
    _player.add_bet = 0
    _player.action = 'fold'
    _player.discard = false
    _player.delete = true
    self:try_bet(_player)
    if not _player.lord then return end
    for _,v in pairs(_player.coin_effect) do
        if v then v:remove() v = nil end
    end
    for _,v in pairs(_player.card_effect) do
        if v then v:remove() v = nil end
    end
    for _,v in pairs(_player.cup_effect) do
        if v then v:remove() v = nil end
    end
    self:order_lord_do_action(_player,function (_unit)
        _unit:remove()
    end)
    local seat_id = self:find_player_scene_seat(_player,local_player)
    ui:set_visible(local_player.player_info[seat_id],false)
    ui:set_visible(local_player.placed_pet_ui[seat_id],false)
    if _player == local_player then 
        BetPanel:show_bet_btn(false)
        --ui:set_text(FoldPanelPath..'.text','Fold')
        --ui:set_visible(FoldPanelPath,true)
        BetPanel:show_fold_ani()
    end
end


---初始化ui事件和vx事件。
function BetPanel:init_bet_panel_ui_event()
    for i = 1, betButtonCnt do
        up.ui:set_hotkey(BetPanelPath..'.Bet_Bg_'..betButtonCnt..'.BetButton'..i,tostring(i),local_player)
    end
    up.ui:set_hotkey(BetPanelPath..'.Fold','F',local_player)
    up.ui:set_hotkey(BetPanelPath..'.call_auto','W',local_player)
    up.ui:set_hotkey(BetPanelPath..'.Call','C',local_player)
    up.ui:set_hotkey(BetPanelPath..'.Raise','R',local_player)
    up.ui:set_hotkey(BetPanelPath..'.All_In','A',local_player)
    for i = 1 ,3 do 
        self['flop_move_in'..i] = ui:new_event('BetPanel.main_bg.FlopCard_'..i,'move_in')
        self['flop_move_out'..i] = ui:new_event('BetPanel.main_bg.FlopCard_'..i,'move_out')
        --self['flop_move_in'..i] = ui:new_event('BetPanel.main_bg.FlopTouch'..i,'move_in')
        --self['flop_move_out'..i] = ui:new_event('BetPanel.main_bg.FlopTouch'..i,'move_out')
    end

    ui:register_event('move_in_sound','BetPanel.main_bg.HandCard.HandCard_Btn','move_in')
    ui:register_event('move_in_sound','BetPanel.main_bg.Exit','move_in')
    ui:register_event('click_sound','BetPanel.main_bg.HandCard.HandCard_Btn','click')
    ui:register_event('click_sound','BetPanel.main_bg.Exit','click')

    for _,v in pairs(self.bet_btn)do
        ui:register_event('move_in_sound',v.path,'move_in')
        ui:register_event('click_sound',v.path,'click')
    end

    ---给cocos动效加事件轨
    ui:vx_event('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open','in',8,'in',14)
    ui:vx_event('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Close','in',8,'in',14)
    for i = 1,2 do
        ui:vx_event('BetPanel.main_bg.HandCard.HandCard_'..i..'.pair_ani','in',10,'in',13)
        ui:vx_event('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.pair_ani','in',10,'in',13)
        ui:vx_event('BetPanel.main_bg.HandCard.HandCard_'..i..'.Big_pair_ani','out',9,'out',40)

        ui:vx_event('BetPanel.main_bg.Discard_ani_'..i,'discard_ani_over',11,'out',35)
        ui:vx_event('BetPanel.main_bg.Discard_ani_'..i,'discard_ani_card',11,'out',6)
    end
    ui:vx_event('BetPanel.main_bg.show_handcard_ani','show_hand_card',34,'out',15)
    ui:vx_event('BetPanel.main_bg.show_handcard_ani2','out',34,'out',18)
    ui:vx_event('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open','in',8,'in',14)
    ui:vx_event('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open','out',8,'out',10)
    ui:vx_event('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Close','in',8,'in',14)
    ui:vx_event('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Close','out',8,'out',10)
    ui:vx_event('BetPanel.main_bg.show_flop_ani','flop',14,'out',10)
    ui:vx_event('BetPanel.main_bg.show_flop_ani','out',14,'out',35)
    ui:vx_event('BetPanel.main_bg.show_flop_ani','start_flop_tail',14,'out',9)
    
    for i = 1,2 do
        ui:vx_event('BetPanel.main_bg.tail_'..i,'start_handcard_hit_'..i,17,'out',3)
        ui:vx_event('BetPanel.main_bg.tail_'..i,'out',17,'out',18)
    end

    for k,v in pairs(hit_vx) do
        for i = 1,2 do 
            ui:vx_event('BetPanel.main_bg.HandCard.HandCard_'..i..'.Hit','out',v,'out',25)
        end
    end
    for k,v in pairs(HandCard_level_vx[3]) do
        for i = 1,2 do 
            ui:vx_event('BetPanel.main_bg.HandCard.HandCard_'..i..'.powerup','in',v,'in',40)
        end
    end
    ui:vx_event('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open2','out',41,'out',16)
    ui:vx_event('BetPanel.main_bg.HandCard.HandCard_Btn.BigPair_Open3','out',40,'out',32)
    if GameMode == 'Lord' or GameMode == 'Custom' then
        ui:set_visible(GameInfoPath..'.tip',true)
        ui:set_visible(GameInfoPath..'.Icon',true)
    else
        ui:set_visible(GameInfoPath..'.tip',false)
        ui:set_visible(GameInfoPath..'.Icon',false)
    end
end

---vx事件事件柄
up.game:event('VX-Event', function(self,event,ui_comp,vx_id)
    if event == 'show' then
        ui:vx_play(ui_comp,vx_id,'out')
        return
    end
    if event == 'out' then
        ui:set_visible(ui_comp,false)
        return
    end
    if event == 'in' then
        ui:vx_play(ui_comp,vx_id,'loop')
        return
    end
    if event == 'show_hand_card' then
        BetPanel:set_hand_card()
        ---不知道为什么直接衔接的过程中有空帧。但是不想管了,提前一点衔接加个wait吧。
        ui:wait(0.1,function ()
            ui:set_visible(ui_comp,false)
        end)
        return
    end
    if event == 'discard_ani_over' then
        ui:set_visible(ui_comp,false)
        BetPanel:show_starting_hand(false)
        return
    end
    if event == 'discard_ani_card' then
        ui:play_ui_comp_anim('HandCard_out',false,1)
        return
    end

    if event == 'flop' then
        local flop_order = BetPanel.flop_order
        BetPanel:show_flop(true,BetPanel.flop_order)
        ui:play_ui_comp_anim('FlopCard_'..BetPanel.flop_order..'_turnover',false,1)
        ui:play_2d_sound(134243749)

        -- local mouse_x = gameapi.get_role_ui_x_per(up.get_localplayer()._base):float()*gameapi.get_window_real_x_size()
        -- local mouse_y = gameapi.get_role_ui_y_per(up.get_localplayer()._base):float()*gameapi.get_window_real_y_size()
        -- print("mouse_x===================================================",mouse_x)
        -- print("mouse_y===================================================",mouse_y)
        -- if mouse_x >= 735.65 + (flop_order - 1) * 160 and mouse_x <= 864.35 + (flop_order - 1)*160 and mouse_y >= 507.05 and mouse_y <= 692.95 then
        --     ShowMagicCardLock = true
        -- end
        ui:wait(0.0333*38,function ()
            ui:set_visible('BetPanel.main_bg.FlopTouch',true)
            ShowMagicCardOnoff[flop_order] = true
            print("****************************************************************************",flop_order)
            for i = 1,3 do
                print("===============================================================ShowMagicCardOnoff",i.."="..tostring(ShowMagicCardOnoff[i]))
            end
            print("****************************************************************************")
        end)
        ui:set_visible(ui_comp,false)
        return
    end

    if event == 'start_flop_tail'  then
        if local_player.is_watching ~= false or local_player.is_watching == nil then return end
        BetPanel:show_starting_hand(true)
        ---不知道怎么可能card是nil，先容了再说
        if not local_player.card[1] then return end
        if round.magic_card[BetPanel.flop_order].pair then
            for i =1,2 do
                if magic.condition(round.magic_card[BetPanel.flop_order],local_player,i) then
                    if local_player.card[i].color ~= round.magic_card[BetPanel.flop_order].anim_effect and round.magic_card[BetPanel.flop_order].anim_effect_cover or not local_player.card[i].color then
                        local_player.card[i].color = round.magic_card[BetPanel.flop_order].anim_effect
                    end
                    --不知道怎么可能powerup_times是nil，先容了再说
                    if not local_player.card[i].powerup_times then local_player.card[i].powerup_times = 0 end
                    local_player.card[i].powerup_times = 1 + local_player.card[i].powerup_times
                    if not local_player.discard then
                        ui:set_visible('BetPanel.main_bg.tail_'..i,true)
                        ui:vx_play('BetPanel.main_bg.tail_'..i,17,'out')
                    end
                end
            end
        else
            if magic.condition(round.magic_card[BetPanel.flop_order],local_player,nil) then
                for i =1,2 do
                    if local_player.card[i].color ~= round.magic_card[BetPanel.flop_order].anim_effect and round.magic_card[BetPanel.flop_order].anim_effect_cover or not local_player.card[i].color then
                        local_player.card[i].color = round.magic_card[BetPanel.flop_order].anim_effect
                    end
                    if not local_player.card[i].powerup_times then local_player.card[i].powerup_times = 0 end
                    local_player.card[i].powerup_times = 1 + local_player.card[i].powerup_times
                    if not local_player.discard then
                        ui:set_visible('BetPanel.main_bg.tail_'..i,true)
                        ui:vx_play('BetPanel.main_bg.tail_'..i,17,'out')
                    end
                end
            end
        end
    end
    --
    for i = 1,2 do
        if event == 'start_handcard_hit_'..i then
            if local_player.is_watching ~= false or local_player.is_watching == nil then return end
            ui:play_ui_comp_anim('HandCard_'..i..'_shake',false,1)
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.powerup',true)
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.powerup',true)
            if local_player.card[i].color ~= nil and local_player.card[i].powerup_times ~= nil and HandCard_level_vx[local_player.card[i].powerup_times] then
                if local_player.card[i].powerup_times ~= 3 then
                    ui:vx_play('BetPanel.main_bg.HandCard.HandCard_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'loop')
                    ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'loop')
                else
                    ui:vx_play('BetPanel.main_bg.HandCard.HandCard_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'in')
                    ui:vx_play('BetPanel.main_bg.HandCard.HandCard_Close_'..i..'.powerup',HandCard_level_vx[local_player.card[i].powerup_times][local_player.card[i].color],'in')
                end
            end
            ui:set_visible('BetPanel.main_bg.HandCard.HandCard_'..i..'.Hit',true)
            ui:vx_play('BetPanel.main_bg.HandCard.HandCard_'..i..'.Hit',hit_vx[round.magic_card[BetPanel.flop_order].anim_effect],'out')
        end
    end
end)

---全局事件事件柄
up.game:event('主流程-锁定领主',function()
    BetPanel:seat_init()
end)

up.game:event('回合流程-弃牌',function (_,_player)
    if _player == local_player then
        BetPanel:show_bet_btn(false)
        ui:set_text(FoldPanelPath..'.text','Fold')
        ui:set_visible(FoldPanelPath,true)
        BetPanel:show_fold_ani()
    end
    local place_bet = _player.place_bet
    local round_bet = round.bet
    up.wait(0.5,function ()
        BetPanel:play_3D_sound_on_table(config.LordData[_player.lord_id].Vo_Fold,2,_player,'Vo_Fold')
        BetPanel:fresh_player_action_state(_player,'fold',place_bet,0,round_bet)
    end)
end)

up.game:event('回合流程-发牌',function (_)
    for i = 1,3 do
        ui:set_image(GameInfoPath..'.Bg_Step.List_Step.Icon_spell_'..i..'.icon',icon_bg['Icon_spell']['nml'])
    end
    BetPanel:reset_game_ui()
    ui:set_visible('BetPanel.main_bg.HandCard.HandCard_Btn',false)
    ui:set_visible('BetPanel.main_bg.HandCard.HandCard_1',false)
    ui:set_visible('BetPanel.main_bg.HandCard.HandCard_2',false)
    up.wait(3,function ()
        if local_player.is_watching ~= false or local_player.is_watching == nil then return end
        ui:play_2d_sound(134251761)
        ui:set_visible('BetPanel.main_bg.show_handcard_ani',true)
        ui:vx_play('BetPanel.main_bg.show_handcard_ani',34,'out')
        ui:wait(0.1,function ()
            ui:set_visible('BetPanel.main_bg.show_handcard_ani2',true)
            ui:vx_play('BetPanel.main_bg.show_handcard_ani2',34,'out')
        end)
    end)
    BetPanel:fresh_game_info()
end)

up.game:event('回合流程-发牌结束',function (_)
    round.timefun()
    BetPanel.magic_card_change(0)
    sound_tab= {}
    for k,v in ipairs(round.player) do
        v.action = nil
        BetPanel:lock_bet_button(v,true)
    end
    ui:set_text(HighestPath..'.Bg_highest.text_highest',round.bet)
    if not local_player.is_watching then
        BetPanel:show_bet_btn(true)
    end
end)

up.game:event('回合流程-AI下注',function (_,_player)
    BetPanel:fresh_bet_btn_select()
    local seat_id = BetPanel:find_player_scene_seat(_player)
    BetPanel:slot_machine_ani(ui:get_scene_ui_child(local_player.placed_pet_ui[seat_id],'placed_pet'),_player.place_bet + _player.add_bet,_player.placed_pet_text,1,0.03)
    _player.placed_pet_text = _player.place_bet + _player.add_bet
    BetPanel:play_lord_action_ani(_player)
    round.add_bet = _player.add_bet
    local action = _player.action
    if string.find(action,'raise') then
        for i = 1, 5 do
            if action == 'raise_'..i and i > round.raise then
                round.raise = i
            end
        end
    end
end)

up.game:event('回合流程-allin',function (_,player)
    if player == local_player then
        ui:set_text(FoldPanelPath..'.text','All in!')
        BetPanel:show_bet_btn(false)
        ui:set_visible(FoldPanelPath,true)
    end
end)

up.game:event('回合流程-玩家下注',function (_,player)
    local action = player.action
    local place_bet = player.place_bet
    local add_bet = player.add_bet
    local round_bet = round.bet
    print('回合流程-玩家下注================',player,action,place_bet,add_bet,round_bet)
    if action == 'all_in' and round.bet >= round.betNum[betButtonCnt] then
        round.raise = 5
    end
    if string.find(action,'raise') or action == 'all_in' then
        for _,v in ipairs(round.player) do
            if v.raise < round.raise and v ~= player and v.action ~= 'fold' then
                BetPanel:bet_btn_click(round.raise,v)
                BetPanel:raise_ui_change(round.raise)
            end
        end
        BetPanel:raise_ui_change(round.raise)
    end
    up.wait(0.5,function ()
        BetPanel:fresh_player_action_state(player,action,place_bet,add_bet,round_bet)
        for _, v in ipairs(round.player) do
            local seat_id = BetPanel:find_player_scene_seat(v)
            if v.is_auto and not v.is_allin and v.place_bet < round.bet and not v.discard then
                BetPanel:follow_click(v)
            end
            player_font_set(v)
        end
    end)
end)

up.game:event('回合流程-刷新操作',function(_,player)
    player.double_click_cd = false
    for _, v in ipairs(round.player) do
        BetPanel:lock_bet_button(v)
    end
    BetPanel:check_bet_btn(player)
    BetPanel:bet_btn_click(player.raise,player)
    ui:set_text(HighestPath..'.Bg_highest.text_highest',round.bet)
end)


up.game:event('回合流程-下注完成',function(_)
    ui:set_visible('BetPanel',false)
    for i = 1, PLAYER_MAX do
        ui:set_visible(ui:get_scene_ui_child(local_player.player_info[i],'State_Bg'),false)
    end
    if BetPanel.countdown_sound then
        gameapi.stop_sound(BetPanel.betting_player._base,BetPanel.countdown_sound)
        BetPanel.countdown_sound = nil
    end
    if BetPanel.BettingCountdownTimer then
        BetPanel.BettingCountdownTimer:remove()
        BetPanel.BettingCountdownTimer = nil
    end
    if BetPanel.BettingProgressTimer1 then
        BetPanel.BettingProgressTimer1:remove()
        BetPanel.BettingProgressTimer1 = nil
    end
    if BetPanel.BettingProgressTimer2 then
        BetPanel.BettingProgressTimer2:remove()
        BetPanel.BettingProgressTimer2 = nil
    end
    up.wait(1.5,function ()
        BetPanel:gather_coins()
    end)
end)

up.game:event('回合流程-结束发钱',function (_)
    ui:set_visible(FoldPanelPath,false)
    ui:set_visible('BattlePanel',false)
    ui:set_visible('BetPanel',true)
    ui:set_visible('BetPanel.main_bg.HandCard',false)
    ui:set_visible('BetPanel.main_bg.FlopCard_1',false)
    ui:set_visible('BetPanel.main_bg.FlopCard_2',false)
    ui:set_visible('BetPanel.main_bg.FlopCard_3',false)
    for i = 1,PLAYER_MAX do
        ui:set_visible(ui:get_scene_ui_child(local_player.player_info[i],'State_Bg'),false)
    end
    
    ui:set_visible(BetPanelPath,false)
    up.wait(1.5,function ()
        BetPanel:coins_to_winner()
    end)
    --初始化魔法牌展示限制的参数
    ShowMagicCard = false
    MagicCard = 0
    NextMagicCard = 0
    ShowMagicCardOnoff = {[1] = false,[2] = false,[3] = false,}
    print("=============================================ShowMagicCard reset success")
end)

up.game:event('玩家已退出',function(_,_player)
    BetPanel:delete_player_instance(_player)
end)

up.game:event('回合流程-公牌1',function (_,player)
    BetPanel.magic_card_change(1)
    ui:set_visible('BetPanel.main_bg.show_flop_ani',true)
    ui:set_visible('BetPanel.main_bg.FlopTouch',false)
    ui:vx_play('BetPanel.main_bg.show_flop_ani',14,'out')
    BetPanel.flop_order = 1
end)

up.game:event('回合流程-公牌2',function (_,player)
    BetPanel.magic_card_change(2)
    ui:set_visible('BetPanel.main_bg.show_flop_ani',true)
    ui:set_visible('BetPanel.main_bg.FlopTouch',false)
    ui:vx_play('BetPanel.main_bg.show_flop_ani',14,'out')
    BetPanel.flop_order = 2
end)

up.game:event('回合流程-公牌3',function (_,player)
    BetPanel.magic_card_change(3)
    ui:set_visible('BetPanel.main_bg.show_flop_ani',true)
    ui:set_visible('BetPanel.main_bg.FlopTouch',false)
    ui:vx_play('BetPanel.main_bg.show_flop_ani',14,'out')
    BetPanel.flop_order = 3
end)

up.game:event('Player-ResourceChange',function(_,player,res_key)
    if res_key == GOLD then
        BetPanel:fresh_player_gold(player)
    end
end)

BetPanel.topshow = false
BetPanel.top_progress_now = 0
BetPanel.top_time_sound = nil
local time_yellow = config.GlobalConfig.ROUND_TIME_YELLOW
local time_red = config.GlobalConfig.ROUND_TIME_RED

up.game:event('回合流程-时间刷新',function(_,time,timeMax)
    if time then
        BetPanel.top_progress_now = time
        if not BetPanel.topshow  then
            --print('回合流程-时间刷新===============')
            BetPanel.topshow = true
            ui:set_visible(HighestPath,BetPanel.topshow)
            for _,v in ipairs(round.player) do
                BetPanel:check_bet_btn(v)
            end
            BetPanel.set_top_progress = up.loop(0.03,function()
                ui:set_progress(HighestPath..'.Bg_time',timeMax,BetPanel.top_progress_now)
                BetPanel.top_progress_now = BetPanel.top_progress_now - 0.03
            end)
        end
        if time > time_yellow then
            ui:set_image(HighestPath..'.Bg_time',progress_color.green)
        elseif time <= time_yellow and time > time_red  then
            ui:set_image(HighestPath..'.Bg_time',progress_color.yellow)
        else
            ui:set_image(HighestPath..'.Bg_time',progress_color.red)
        end
        if time == 3 then
            if BetPanel.top_time_sound then BetPanel.top_time_sound:remove() end
            BetPanel:play_3D_sound_on_table(134233140)
        end
        ui:set_text(HighestPath..'.Bg_time.Text',time)
    else
        if round.round_time then
            round.round_time:remove()
            round.round_time = nil
        end
		BetPanel.topshow = false
        if BetPanel.set_top_progress then BetPanel.set_top_progress:remove() end
        ui:set_visible(HighestPath,BetPanel.topshow)
    end
end)


---ui事件事件柄
up.game:event('UI-Event', function(self, player,event)
    if round.round_time then
        for i = 1,5 do
            if event == 'BetButton'..i and gameapi.get_trigger_variable_integer("新手引导模式") ~= 1004 then 
                BetPanel:bet_btn_click(i,player)
                return
            end
        end
        if event == 'Raise' and gameapi.get_trigger_variable_integer("新手引导模式") ~= 1004 then
            BetPanel:raise_click(player)
            return
        end
        if event == 'Auto' and gameapi.get_trigger_variable_integer("新手引导模式") ~= 1004 then
            BetPanel:auto_click(player)
            return
        end
        if event == 'Follow' and gameapi.get_trigger_variable_integer("新手引导模式") ~= 1004 then
            BetPanel:follow_click(player)
            return
        end
        if event == 'Fold' and gameapi.get_trigger_variable_integer("新手引导模式") ~= 1004 then
            BetPanel:fold_click(player)
            return
        end
        if event == 'All_in' and gameapi.get_trigger_variable_integer("新手引导模式") ~= 1004 then
            BetPanel:all_in_click(player)
            return
        end
    end

    if player ~= local_player then return end

    if event == 'show_hand_card_btn' then
        BetPanel:show_starting_hand(not(BetPanel.handcard_visible))
    end
    for i = 1,3 do
        if event == BetPanel['flop_move_in'..i] and ShowMagicCardOnoff[i] and gameapi.get_trigger_variable_integer("新手引导模式") ~= 1004 then
            --if ShowMagicCardLock == false then
                if ShowMagicCard == false then
                    BetPanel:show_flop_tips(true,i)
                    ShowMagicCard = true
                    MagicCard = i
                elseif ShowMagicCard and MagicCard ~= i then
                    NextMagicCard = i 
                end
            -- else
            --     print("鼠标在控件内，移入失效")
            -- end
        end
        if event == BetPanel['flop_move_out'..i] and ShowMagicCardOnoff[i] and gameapi.get_trigger_variable_integer("新手引导模式") ~= 1004 then
            -- if ShowMagicCardLock then
            --     ShowMagicCardLock = false
            -- else
                if ShowMagicCard == true then
                    if MagicCard == i then
                        BetPanel:show_flop_tips(false,i)
                        ShowMagicCard = false
                        MagicCard = 0
                        if NextMagicCard ~= 0 then
                            BetPanel:show_flop_tips(true,NextMagicCard)
                            ShowMagicCard = true
                            MagicCard = NextMagicCard
                            NextMagicCard = 0
                        end
                    end
                end
            --end
        end
    end
end)

BetPanel:init_bet_panel_ui_event()

return BetPanel