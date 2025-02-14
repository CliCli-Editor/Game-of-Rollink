local magicCard = require 'game.magicCard'
local local_player = up.get_localplayer()
local round = {}
local ui = require 'ui.local'
---下注流程调整 计时数 当前计数
local round_time = config.GlobalConfig.ROUND_TIME
round.time = 0
--回合数
round.num = 0
--本局游戏的所有玩家
round.all_player = {}
--有资格参与游戏的玩家
round.player = {}
--本轮进入战斗的玩家，如果发生平局，在该组的玩家会平分所有奖金
round.battle_player = nil
-- 回合底注 回合开始时，最初始的入场底注
round.min_pet = 0
--轮次底注 回合内每轮的底注，会随着轮次提高而提高
round.pet_base = 0
--当前回合的注
round.bet = 0
--下注轮次
round.pet_round = 0
--存个下注轮次
round.old_pet_round = 0
--下注限时
round.pet_time = config.GlobalConfig.PET_TIME
--是否在战斗状态
round.is_battle = false
--金币池
round.GoldPool = 0
--是否有人allin
round.is_allin = false
--战场上的所有单位
round.all_unit = {}
round.is_gameover = false
round.last_bet = 0

--玩家属性
-- LordNum 排名
-- InitGameGold 玩家的初始金币存档
-- InitGameCrow 玩家的初始皇冠存档
-- GameCrow 皇冠变化
-- GameGold 
    -- 领主模式下 根据排名变化，只在结算时进行计算处理
    -- 传统模式下 玩家的金币变化，每次下注都要处理
-- MaxGold 本局游戏单轮获取的最多金币数（领主模式）
-- WinRound 本局游戏胜利过的回合数（领主模式）
-- discard 是否弃牌
-- is_allin 是否allin
-- is_watching 是否观战（所有金币耗尽也会进入观战，不是玩家的status属性）
-- card 持有的手牌
-- soldier 进入战场的士兵数据，会被各种效果影响，与手牌不对应
-- place_bet 本轮下注的总金币数
-- place_log 本轮是否行动过

-- local function print()
    
--end 
--if up.get_game_mode_id() == 1004 then      --新手引导 下注时间调整

up.game:event('Game-Init',function()
    up.wait(0.03, function()
        --print("调整回合时间 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
        if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then      
            print("存档 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导进度"))
            if gameapi.get_trigger_variable_integer("新手引导进度") > 24 then
                round_time = config.GlobalConfig.ROUND_TIME
                --round.pet_time = config.GlobalConfig.PET_TIME
            else
                round_time = 1
            end
        end
    end)
end)
--end

local function Test(player)
    print("★★★★★★★★★★★★★★★★★★★★★★★★★★★★")
    print(player.GameCrown,player.WinRound,player.GameGold,player.MaxGold,player.LordNum)
end

local camera_data = config.CameraData

local function play_camera(id)
    print('-----------------',id)
    local data = camera_data[id]
    gameapi.apply_camera_conf(gameapi.get_role_by_role_id(1), data.camera_id, Fix32(data.time), data.type)
    if data.next ~= 0 then
        up.wait(data.time + 0.1,function ()
            play_camera(data.next)
        end)
    end
end

local function updateCrownSave(player)
    player:set_save_data(3, player.InitGameCrow + player.GameCrown)
    --player._base:add_global_map_archive_data("score", player.GameCrown)
    player:save_archive()
end

up.game:event('Player-JoinGame', function(_, player)
    print('玩家数据初始化')
    if player:get_status() == 'watching' then
        --中途加入游戏
        player.is_watching = true
    elseif player:is_playing() then
        if player == local_player then
            ui:set_visible('watchingPanel.bg',false)
        end
        --正常加入游戏
        table.insert(round.all_player,player)
        player.is_watching = false
    else
        --？？？
        player.is_watching = nil
    end
end)

up.game:event('刷新玩家排行榜', function(_, player)
    round.update_lord_num()
end)

up.game:event('游戏结束', function(_, player)
    print('============玩家离开游戏',player._base)
    table.removeValue(round.player, player)
    player.discard = true
    player:set(GOLD,0)
    round.update_lord_num()
end)

function round:GoldChange(_num, player)
    player:add(GOLD,_num)
    --如果是传统模式，每次金币变化都会更新金币存档
    if GameMode ~= 'Custom' and GameMode ~= 'Lord' then
        --金币池只会在下注时变化
        if _num < 0 then
            round.GoldPool = round.GoldPool - _num
        end
        player.GameGold = player.GameGold + _num
        if IS_TEST then return end
        --player:set_save_data(1, player:get_save_data(1) + _num)
        if player.gold_show == true then
            player:msg('变化后存档货币:'..player:get_save_data(1)..'此次变化值:'..tostring(_num))
        end
        quest.playerquestset(player,'earn_gold',math.max(0,player.GameGold))
        player:save_archive()
        print(player,'筹码变化:',_num,'当前筹码:',player:get_save_data(1))
    end
end

local function CrownCount(_type, _player)
    if GameMode == 'Lord' then
        --根据排名计算皇冠
        print(_player.LordNum)
        --_player.GameCrown = config.LoadCrown[_player.LordNum].crown
    elseif GameMode == 'Custom' then
        --不计算
    else
        print(_player,_type)
        local function commonCrown()
            local Fee = round.BetConfig[1].Fee
            print('CommonCrown',Fee,round.GoldPool)
            for k, v in ipairs(config.CommonCrown) do
                if round.GoldPool / Fee <= v.key then
                    --print(_player,'GameCrown',Fee,_player.GameCrown , v[_type])
                    _player.GameCrown = _player.GameCrown + v[_type]
                    return
                end
            end
        end
        commonCrown()
    end
    updateCrownSave(_player)
    --GameMode
end

---技能替换 领主技能更新
local lord_skill_set = function(_player)
    local _skill_slot_now = {}
    for n = 1,3 do
        local slot = _player.skill_slot_now[n]
        if slot then
            local now = _player['skill_charge_'..slot]
            if now > 0 then
                table.insert(_skill_slot_now,slot)
            end
        end
    end
    _player.skill_slot_now = _skill_slot_now
    local solt = _player.skill_slot_next
    local sid = _player.skill_list[solt]
    if #_player.skill_slot_now < 3 and sid then
        table.insert(_player.skill_slot_now,solt)
        _player.skill_slot_next = _player.skill_slot_next +1
    end
    --print('==============玩家',_player:get_id(),_player.skill_slot_next)
    --print('===================当前拥有技能',#_player.skill_slot_now)
    for i, v in ipairs(_player.skill_slot_now) do
        print(v)
    end
end
---下注流程调整 计时器创建
round.timefun = function()
    up.game:event_dispatch('回合流程-时间刷新')
    if round.check_place_bet_over() then
    else
        round.time = round_time
        up.game:event_dispatch('回合流程-时间刷新',round.time,round_time)
        round.round_time = up.loop(1,function()
            if round.check_place_bet_over() then
                round.time = 0
                up.game:event_dispatch('回合流程-时间刷新')
            else
                if round.time <= 0 then
                    round.place_bet_over()
                    up.game:event_dispatch('回合流程-时间刷新')
                else
                    up.game:event_dispatch('回合流程-提示下注')
                    round.time = round.time - 1
                    up.game:event_dispatch('回合流程-时间刷新',round.time,round_time)
                end
            end
        end)
    end
end
--回合开始，发牌，扣底注
round.start = function()
    gameapi.set_day_and_night_time(9)
    gameapi.play_sound_for_player(local_player._base, 134268459, true, 0, 0)
    round.player = {}
    round.battle_player = {}
    round.num = round.num + 1
    round.is_allin = false
    round.pet_round = 1
    round.old_pet_round = 1
    round.can_do_0 = false
    if round.BetConfig[round.num] then
        round.min_pet = round.BetConfig[round.num].Ante
    else
        round.min_pet = round.BetConfig[#round.BetConfig].Ante
    end
    round.pet_base = round.min_pet
    round.bet = round.min_pet
    round.magic_card_pool = up.table_copy(config.MagicCardData)
    round.magic_card = {}
    round.is_balance = false
    round.is_over = false
    round.show_round = 0
    round.last_bet = 0
    round.can_do_0 = false
    round.raise = 1
    up.game:event_dispatch('回合流程-时间刷新')
    print('==============' .. '第' .. round.num .. '回合 发牌阶段' .. '==============')
    for pid = 1, PLAYER_MAX do
        local player = up.player(pid)
        player.card = {}
        player.soldier = {
            flag = {},
        }
        player.buff = {}
        player.is_allin = false
        player.raise = 1
        if player:is_playing() and player.is_watching ~= true then
            if player:get_status() == 'lost' then
                player.LoseRouond = player.LoseRouond + 1
            else
                player.LoseRouond = 0
            end
            if player.LoseRouond <= 3 then
                if GameMode == 'Lord' or GameMode == 'Custom' then
                    ---技能替换 领主技能更新
                    lord_skill_set(player)
                end
                if player:get(GOLD) > 0 then
                    for i = 1, config.GlobalConfig.HAND_CARD_NUM do
                        local soldier_id = math.random(1, #config.SoldierData)
                        player.card[i] = {
                            num = math.random(1, config.GlobalConfig.CARD_NUM_MAX),
                            soldier = config.SoldierData[soldier_id],
                            id = config.SoldierData[soldier_id].unit_id,
                        }
                        player.soldier[i] = {
                            num = player.card[i].num,
                            id = player.card[i].soldier.unit_id,
                            level = 1,
                        }
                    end
                    if config.GlobalConfig.TEST_ENABLE and pid == 1 then
                        for i=1,2 do
                            local soldier_id = config.TestConfig.soldier_card[i].key1
                            local num = config.TestConfig.soldier_card[i].key2
                            player.card[i] = {
                                num = num,
                                id = config.SoldierData[soldier_id].unit_id,
                                soldier = config.SoldierData[soldier_id],
                            }
                            player.soldier[i] = {
                                num = num,
                                id = player.card[i].soldier.unit_id,
                                level = 1,
                            }
                        end
                    end
                    --print("发手牌 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
                    if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then
                        print("存档 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导进度"))
                        if gameapi.get_trigger_variable_integer("新手引导进度") < 24 then               --新手引导 发手牌
                            if pid == 1 then
                                for i=1,2 do
                                    local soldier_id = i
                                    local num = 14-i
                                    player.card[i] = {
                                        num = num,
                                        id = config.SoldierData[soldier_id].unit_id,
                                        soldier = config.SoldierData[soldier_id],
                                    }
                                    player.soldier[i] = {
                                        num = num,
                                        id = player.card[i].soldier.unit_id,
                                        level = 1,
                                    }
                                end
                            else
                                for i = 1, config.GlobalConfig.HAND_CARD_NUM do
                                    local soldier_id = math.random(1, #config.SoldierData)
                                    player.card[i] = {
                                        num = i * 2,
                                        soldier = config.SoldierData[soldier_id],
                                        id = config.SoldierData[soldier_id].unit_id,
                                    }
                                    player.soldier[i] = {
                                        num = player.card[i].num,
                                        id = player.card[i].soldier.unit_id,
                                        level = 1,
                                    }
                                end
                            end
                        else
                            if pid == 1 then
                                for i=1,2 do
                                    local soldier_id = config.TestConfig.soldier_card[i].key1
                                    local num = config.TestConfig.soldier_card[1].key2
                                    player.card[i] = {
                                        num = num,
                                        id = config.SoldierData[soldier_id].unit_id,
                                        soldier = config.SoldierData[soldier_id],
                                    }
                                    player.soldier[i] = {
                                        num = num,
                                        id = player.card[i].soldier.unit_id,
                                        level = 1,
                                    }
                                end
                            else
                                for i = 1, config.GlobalConfig.HAND_CARD_NUM do
                                    local soldier_id = math.random(1, #config.SoldierData)
                                    player.card[i] = {
                                        num = i * 2,
                                        soldier = config.SoldierData[soldier_id],
                                        id = config.SoldierData[soldier_id].unit_id,
                                    }
                                    player.soldier[i] = {
                                        num = player.card[i].num,
                                        id = player.card[i].soldier.unit_id,
                                        level = 1,
                                    }
                                end
                            end
                        end
                    end
                    --如果第一张卡是弓兵，第二张卡不是，调换位置
                    if player.card[1].soldier.unit_id == 134228828 and player.card[2].soldier.unit_id ~= 134228828 then
                        local card_num = player.card[1].num
                        local card_soldier = player.card[1].soldier
                        player.card[1] = {
                            num = player.card[2].num,
                            soldier = player.card[2].soldier,
                            id = player.card[2].id,
                        }
                        player.soldier[1] = {
                            num = player.card[1].num,
                            id = player.card[1].soldier.unit_id,
                            level = 1,
                        }
                        player.card[2] = {
                            num = card_num,
                            soldier = card_soldier,
                            id = card_soldier.unit_id,
                        }
                        player.soldier[2] = {
                            num = player.card[2].num,
                            id = player.card[2].soldier.unit_id,
                            level = 1,
                        }
                    end
                    if player.card[1].num == player.card[2].num then
                        player.soldier[1].level = 2
                        player.soldier[2].level = 2
                        player.soldier[1].id = config.UnitData[player.card[1].soldier.card_soldier_type].upgrade
                        player.soldier[2].id = config.UnitData[player.card[2].soldier.card_soldier_type].upgrade
                        if player.soldier[1].id == player.soldier[2].id then
                            player.soldier[1].num = 1
                            player.soldier[1].level = 3
                            player.soldier[1].id = UNIT_ID['圣甲护卫']
                            player.soldier[2].num = 1
                            player.soldier[2].level = 3
                            player.soldier[2].id = UNIT_ID['圣甲护卫']
                        end
                    end
                    --消耗底注金币
                    if player:get(GOLD) > round.min_pet then
                        player.place_bet = round.min_pet
                    else
                        player.place_bet = tonumber(string.format('%d',player:get(GOLD)))
                        player.is_allin = true
                        up.game:event_dispatch('回合流程-allin', player)
                        if round.is_allin == false then
                            round.is_allin = true
                            gameapi.play_sound_for_player(local_player._base, 134229766, true, 0, 0)
                        end
                    end
                    table.insert(round.player, player)
                    player.discard = false
                    round:GoldChange(-player.place_bet, player)
                    print(player, '存活', '扣除底金', round.min_pet, '剩余金币', player:get(GOLD), '牌',
                        player.card[1].num, player.card[1].soldier.card_soldier_type, player.card[2].num,
                        player.card[2].soldier.card_soldier_type)
                else
                    print(player, '已出局')
                    player.is_watching = true
                    player.place_bet = 0
                    player.discard = true
                end
            else
                up.game:event_dispatch('游戏结束', player, 'finish')
            end
        else
            print(player, '已出局')
            player.place_bet = 0
            player.discard = true
        end
    end
    up.game:event_dispatch('回合流程-发牌')
    up.wait(5,function ()
        round.timefun()
        --print("进度 6、23 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
        if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then
            gameapi.send_event_custom(1261242200, gameapi.gen_param_dict(gameapi.gen_param_dict({}, "新手教程文本", config.GuideList[6]["str"]), "当前进度", 6))          --新手引导 6
            gameapi.send_event_custom(1261242200, gameapi.gen_param_dict(gameapi.gen_param_dict({}, "新手教程文本", config.GuideList[25]["str"]), "当前进度", 25))          --新手引导 25
        end
        up.game:event_dispatch('回合流程-发牌结束')
    end)
end

--下注流程调整 玩家进行下注
round.place_bet = function(player,gold)
    -- round.place_bet_timer:remove()
    if gold > player:get(GOLD) then
        gold = tonumber(string.format('%d',player:get(GOLD)))
    end
    --player.place_log = true
    player.place_bet = player.place_bet + gold
    if player.place_bet > round.bet then
        round.bet = player.place_bet
    end
    round:GoldChange(-gold, player)
    if player:get(GOLD) == 0.00 then
        if round.is_allin == false then
            round.is_allin = true
            gameapi.play_sound_for_player(local_player._base, 134229766, true, 0, 0)
        end
        player.is_allin = true
        up.game:event_dispatch('回合流程-allin', player)
        print(player,'allin')
        quest.playerquestset(player,'all_in',1)
        round.check_place_bet_over()
    end
    print('下注金额', gold, '总计下注', player.place_bet, '剩余金币', player:get(GOLD), 'All_In',player.is_allin or false)

    --如果当前下注玩家是庄家，则重置所有人的下注记录，保证下一轮的place_log记录正确
    up.wait(0.5,function()
        for _, v in ipairs(round.player) do
            up.game:event_dispatch('回合流程-刷新操作', v)
        end
    end)
    ---下注流程调整 下注时间重置
    if round.time < 7 then
        round.time = 7
    end
end

---检查玩家能否下注
round.check_place = function(player)
    if player.is_allin then
        return false
    end
    if player.discard then
        return false
    end
    if round.bet ~= round.pet_base then
        if player.place_bet == round.bet then
            return false
        end
    end
    return true
end
---下注流程调整 判断是否都弃牌或allin
---检查所有人下注是否一致或者是否仅剩一名玩家
round.check_place_bet_over = function()
    if #round.player <= 1 then
        if round.is_over == false then
            round.is_over = true
            print('==============', '仅剩一名玩家，回合结束', '==============')
            up.game:event_dispatch('回合流程-下注完成')
            up.game:event_dispatch('回合流程-时间刷新')
            up.wait(config.GlobalConfig.GATHER_COIN_TIME,function ()
                round.over()
            end)
            return true
        else
            return true
        end
    end

    --检查还能进行操作的玩家数量
    local can_do_num = 0
    local _player
    for _, player in ipairs(round.player) do
        if player.is_allin == false then
            _player = player
            can_do_num = can_do_num + 1
        end
    end

    if can_do_num == 0 and not round.can_do_0 then
        round.can_do_0 = true
        print('可以操作的玩家不存在，结束回合')
        up.game:event_dispatch('回合流程-时间刷新')
        round.place_bet_over()
        return true
    end
    if can_do_num == 1 and not round.can_do_0 and _player.place_bet == round.bet then
        round.can_do_0 = true
        print('可以操作的玩家不存在，结束回合')
        up.game:event_dispatch('回合流程-时间刷新')
        round.place_bet_over()
        return true
    end
    return false
end

---下注流程调整 玩家进行弃牌
--玩家进行弃牌
round.player_discard = function(player)
    --print('======player_discard',player)
    if #round.player <= 1 then
        if round.is_over == false then
            round.is_over = true
            --print('==============', '仅剩一名玩家，回合结束', '==============')
            up.game:event_dispatch('回合流程-下注完成')
            up.game:event_dispatch('回合流程-时间刷新')
            up.wait(config.GlobalConfig.GATHER_COIN_TIME,function ()
                round.over()
            end)
            return
        else
            return
        end
    end
    if player.discard then
        up.traceback(player,'重复弃牌操作')
    end
    print(player, '弃牌')
    player.discard = true
    table.removeValue(round.player, player)
    up.game:event_dispatch('回合流程-弃牌', player)
    --如果只剩下一个玩家结束游戏
    if round.check_place_bet_over() then
    else
        up.wait(0.5,function()
            for _, v in ipairs(round.player) do
                up.game:event_dispatch('回合流程-刷新操作', v)
            end
        end)
    end
end

---下注流程调整 下注多传参玩家
up.game:event('回合流程-玩家下注', function(_, player, bet, action)
    if player.delete then
        return
    end
    up.game:event_dispatch('回合流程-提示下注')
    if action == 'fold' then
        round.player_discard(player)
        return
    end
    round.place_bet(player,bet)
end)

round.place_bet_over = function()
    --下注结束，进行公牌
    up.game:event_dispatch('回合流程-时间刷新')
    local roundCnt = #round.player
    if roundCnt and roundCnt > 0 then
        for i=1,roundCnt do
            local v = round.player[roundCnt+1-i]
            if v.place_bet < round.bet and v.is_allin == false then
                round.player_discard(v)
            end
        end
    end
    if #round.player > 1 then
        round.last_bet = round.bet
        round.show_card[round.pet_round]()
    else
        if round.is_over == false then
            round.is_over = true
            print('==============', '仅剩一名玩家，回合结束', '==============')
            up.game:event_dispatch('回合流程-下注完成')
            up.wait(config.GlobalConfig.GATHER_COIN_TIME,function ()
                round.over()
            end)
        end
    end
end

--下一轮下注
local next_pet_round = function()
    ---下注流程调整 下一轮下注
    round.timefun()
end

--抽取魔法卡
local get_magic_card = function(list)
    local card = magicCard.getCard(list)
    local id = #round.magic_card + 1
    if config.GlobalConfig.TEST_ENABLE then
        local group_id = config.TestConfig.magic_card[id].key1
        local key = config.TestConfig.magic_card[id].key2
        card = up.table_copy(config.MagicCardData[group_id][key])
    end
    --print("设置魔法卡 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
    if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then
        print("存档 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导进度"))
        if gameapi.get_trigger_variable_integer("新手引导进度") < 24 then              --新手引导 设置魔法卡
            local group_id = config.TestConfig.magic_card[id].key1
            local key = config.TestConfig.magic_card[id].key2
            card = up.table_copy(config.MagicCardData[group_id][key])
        end
    end
    round.magic_card[id] = card
    print('抽取魔法牌', card.name,card.name_comment,'魔法卡ID',card.id)
end

--公牌
round.show_card = {
    [1] = function()
        --print('1==============公牌[1]==============',#round.player,round.time)
        if round.old_pet_round == 1 then
            --print('2==============公牌[1]==============',#round.player,round.time)
            round.can_do_0 = false
            round.magicPoolType = magicCard.init()
            --print('魔法卡权重得到的类型=========',round.magicPoolType)
            get_magic_card(config.MagicPool[round.magicPoolType][1])
            up.game:event_dispatch('回合流程-公牌1')
            
            round.old_pet_round = 2
            --开启下一轮下注
            up.wait(1.5,function()
                --print("进度 19 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
                if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then
                    gameapi.send_event_custom(1261242200, gameapi.gen_param_dict(gameapi.gen_param_dict({}, "新手教程文本", config.GuideList[19]["str"]), "当前进度", 19))          --新手引导 19
                end
                round.pet_round = 2
                next_pet_round()
            end)
        end
    end,
    [2] = function()
        --print('1==============公牌[2]==============',#round.player,round.time)
        if round.old_pet_round == 2 then
        --print('2==============公牌[2]==============',#round.player,round.time)
            round.can_do_0 = false
            get_magic_card(config.MagicPool[round.magicPoolType][2])
            up.game:event_dispatch('回合流程-公牌2')
            round.old_pet_round = 3
            --开启下一轮下注
            up.wait(1.5,function()
                round.pet_round = 3
                next_pet_round()
            end)
        end
    end,
    [3] = function()
        --print('1==============公牌[3]==============',#round.player,round.time)
        if round.old_pet_round == 3 then
            --print('2==============公牌[3]==============',#round.player,round.time)
            round.can_do_0 = false
            get_magic_card(config.MagicPool[round.magicPoolType][3])
            up.game:event_dispatch('回合流程-公牌3')
            round.old_pet_round = 4
            --开启下一轮下注
            up.wait(1.5,function()
                round.pet_round = 4
                next_pet_round()
            end)
        end
    end,
    [4] = function()
        --print('1==============战斗==============',#round.player,round.time)
        if round.old_pet_round == 4 then
            round.old_pet_round = 5
            --print('2==============战斗==============',#round.player,round.time)
            up.wait(1.5,function()
                up.game:event_dispatch('回合流程-下注完成')
                round.battle_player = up.table_copy(round.player)
                up.wait(config.GlobalConfig.GATHER_COIN_TIME,function ()
                    up.game:event_dispatch('回合流程-战斗')
                    --开始阅兵
                    round.ViewSoldier()
                end)
            end)
        end
    end,
}

--回合结束，发钱，开启下一回合
round.over = function()
    if not (#round.player == 0 and #round.battle_player == 0) then
        up.game:event_dispatch('回合流程-结束发钱')
        --print("进度 24、27 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
        if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then
            gameapi.send_event_custom(1261242200, gameapi.gen_param_dict(gameapi.gen_param_dict({}, "新手教程文本", config.GuideList[24]["str"]), "当前进度", 24))          --新手引导 24
            gameapi.send_event_custom(1261242200, gameapi.gen_param_dict(gameapi.gen_param_dict({}, "新手教程文本", config.GuideList[27]["str"]), "当前进度", 27))          --新手引导 27
        end
        round_time = config.GlobalConfig.ROUND_TIME
    else
        up.game:event_dispatch('回合流程-结算完成')
    end
end

--更新领主排名
round.update_lord_num = function()
    --计算排名
    local players = {}
    for pid = 1,PLAYER_MAX do
        local player = up.player(pid)
        if player:is_playing() and player.is_watching ~= true then
            table.insert(players,player)
        end
    end

    table.sort(players,function(a,b)
        local gold = {
            a:get(GOLD),
            b:get(GOLD),
        }
        if gold[1] == gold[2] then
            return false
        end
        if gold[1] > gold[2] then
            return true
        else
            return false
        end
    end)

    print('---------------排名统计---------------')
    for k,v in ipairs(players) do
        v.LordNum = k
        print(k,v,v:get(GOLD))
    end
end

up.game:event('回合流程-结算完成',function()
    round.pet_round = 5
    print('==================胜利结算===============',#round.player)
    local win_player = nil
    if #round.player == 0 then
    else
        win_player = round.player[1]
        local gold = 0
        for pid = 1, PLAYER_MAX do
            local player = up.player(pid)
            --ALL-IN逻辑
            if player.place_bet > win_player.place_bet then
                gold = gold + win_player.place_bet
            else
                gold = gold + player.place_bet
            end
        end
        quest.playerquestset(win_player,'all_in_win',1)
        --刷新玩家一次获胜赚取到的最多数量金币记录作为结算显示
        if win_player.MaxGold < gold then
            win_player.MaxGold = gold
        end
        win_player.WinRound = win_player.WinRound + 1
        print(win_player:get_name(), '获得回合胜利，赚取', gold)
        --计算排名
        round.update_lord_num()
        
        ----___传统模式结算排名和奖励____----
        if GameMode == 'Junior' or GameMode == 'Senior' then
            --传统模式
            for i = 1, PLAYER_MAX, 1 do
                local player = up.player(i)
                if player:is_playing() and player.is_watching ~= true then
                    quest.playerquestset(player,'casual_num',1)
                    if player ~= win_player then
                        if player.discard then
                            CrownCount('fold', player)
                        else
                            CrownCount('fail', player)
                        end
                    end
                end
            end
            quest.playerquestset(win_player,'casual_win_num',1)
            CrownCount('win', win_player)
        end
    end
    ----___统计剩余玩家数量____----
    local life = 0
    if GameMode == 'Custom' or GameMode == 'Lord' then
        for pid = 1, PLAYER_MAX do
            local player = up.player(pid)
            if player:is_playing() and player.is_watching ~= true then
                if player:get(GOLD) > 0 then
                    life = life + 1
                    print('存活玩家',life)
                else
                    if not player.is_watching then
                        quest.playerquestset(win_player,'weed_player',1)
                        quest.playerquestset(player,'lord_num',1)
                        up.game:event_dispatch('游戏结束', player, 'lose')
                    end
                end
            end
        end
    else
        for pid = 1, PLAYER_MAX do
            local player = up.player(pid)
            if player:is_playing() then
                print(player,'剩余存档筹码',player:get_save_data(1))
                if player:get_save_data(1) > config.BetConfig[GameMode][1].Fee then
                    life = life + 1
                else
                    player.is_watching = true
                end
            end
        end
    end

    ----___重新开局还是结束游戏____----
    local check_kick_player = function()
        local _life = 0
        local _player
        --将支付不起筹码的玩家踢出去
        for pid = 1,PLAYER_MAX do
            local player = up.player(pid)
            if player:is_playing() then 
                if player:get_save_data(1) < config.BetConfig[GameMode][1].Fee then
                    player.is_watching = true
                    print(player,'筹码不足')
                    up.game:event_dispatch('游戏结束', player, 'finish')
                else
                    _life = _life + 1
                    _player = player
                end
            end
        end
        if _life == 1 then
            return _player
        else
            return nil
        end
    end

    if life > 1 then
        if GameMode == 'Custom' or GameMode == 'Lord' then
            round.start()
        else
            for pid = 1,PLAYER_MAX do
                if up.player(pid) and up.player(pid):is_playing() then
                    up.player(pid):save_archive()
                end
            end
            up.wait(5, function()
                local _player = check_kick_player()
                if _player then
                    _player.is_watching = true
                    up.game:event_dispatch('游戏结束', _player, 'finish')
                else
                    gameapi.request_new_round()
                end
            end)
        end
    else
        round.is_gameover = true
        if GameMode == 'Custom' or GameMode == 'Lord' then
            quest.playerquestset(win_player,'lord_num',1)
            for pid = 1, PLAYER_MAX do
                local player = up.player(pid)
                if player:is_playing() and player.is_watching ~= true then
                    if player == win_player then
                        if GameMode ~= 'Custom' then
                            player.LordNum = 1
                            --CrownCount('win', player)
                        end
                        up.game:event_dispatch('游戏结束', player, 'win')
                    else
                        if GameMode ~= 'Custom' then
                            player.LordNum = #round.player + 1
                            --CrownCount('fail', player)
                        end
                        up.game:event_dispatch('游戏结束', player, 'lose')
                    end
                end
            end
        else
            local has_watching_player = function()
                for pid = 1,PLAYER_MAX do
                    local player = up.player(pid)
                    --如果有观战的玩家则重开一局
                    if player:get_status() == 'watching' then
                        print(player,'在观战')
                        return true
                    end
                end
                return false
            end
            if has_watching_player() then
                gameapi.request_new_round()
            else
                local _player = check_kick_player()
                if _player then
                    up.game:event_dispatch('游戏结束', _player, 'finish')
                else
                    gameapi.request_new_round()
                end
            end
        end
    end
end)


return round
