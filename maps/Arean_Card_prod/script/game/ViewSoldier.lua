local round = require 'game.round'
local magicCard = require 'game.magicCard'

local RemoveViewSoldier = function(player)
    if not player.view_soldier then return end
    for _,v in ipairs(player.view_soldier) do
        v:remove()
    end
end

local KillViewSoldier = function(player)
    if not player.view_soldier then return end
    for _,v in ipairs(player.view_soldier) do
        v._base:set_dissolving(Fix32(1),Fix32(0))
    end
    up.wait(1,function()
        for _,v in ipairs(player.view_soldier) do
            v:remove()
        end
    end)
end

local CreateViewSoldier = function(player,need_buff_anim)
    player.view_point = {}
    player.view_soldier = {}
    player.view_soldier_team = {
        [1] = {},
        [2] = {},
    }
    local angle = 0
    local soldier_data = {}
    --阵列
    -- point 第一行中心点
    -- angle 单位面向方向
    local array = function()
        local col_max = 5           --每行最大玩家数
        local interval_dis = 200    --间距
        local function create_soldier_team_pos(id,center_point)
            local num = player.soldier[id].num
            local unit_id = player.soldier[id].id
    
            local mod = math.fmod(num, col_max) --最后一行人数
            local row = (num - mod) / col_max --行数
            if mod > 0 then
                row = row + 1
            end
            
            if row == 1 then --如果只有一行，直接创建
                for i = 1, num do
                    local offset_x = ((num / 2 - 0.5) * (-1) + i - 1) * interval_dis
                    local offset_point = center_point:offset(angle + 90, offset_x)
                    table.insert(soldier_data, {
                        pos = offset_point,
                        unit_id = unit_id,
                        team_id = id,
                    })
                end
            else
                local uid = 1
                for i = 1, row do
                    local offset_y = ((row / 2 - 0.5) * (-1) + i - 1) * interval_dis
                    local max = col_max
                    if i == row and mod ~= 0 then
                        max = mod
                    end
                    for n = 1, max do
                        local offset_x = ((max / 2 - 0.5) * (-1) + n - 1) * interval_dis
                        local offset_point = center_point:offset(angle + 90, offset_x)
                        offset_point = offset_point:offset(angle, offset_y)
                        table.insert(soldier_data, {
                            pos = offset_point,
                            unit_id = unit_id,
                            team_id = id,
                        })
                        uid = uid + 1
                    end
                end
            end
        end
        print(player, player.soldier[1], player.soldier[1].num)
        if player.soldier[1].num == 0  then
            local point = BATTLE_POINT:offset(angle,config.GlobalConfig.CREATE_CENTER_DISTANCE)
            create_soldier_team_pos(2, point)
            player.view_point[1] = point
            player.view_point[2] = point
        elseif player.soldier[2].num == 0  then
            local point = BATTLE_POINT:offset(angle,config.GlobalConfig.CREATE_CENTER_DISTANCE)
            create_soldier_team_pos(1, point)
            player.view_point[1] = point
            player.view_point[2] = point
        else
            local point = BATTLE_POINT:offset(angle,config.GlobalConfig.CREATE_CENTER_DISTANCE - config.GlobalConfig.CREATE_OFFSET_DISTANCE)
            create_soldier_team_pos(1,point)
            player.view_point[1] = point
            point = BATTLE_POINT:offset(angle,config.GlobalConfig.CREATE_CENTER_DISTANCE + config.GlobalConfig.CREATE_OFFSET_DISTANCE)
            create_soldier_team_pos(2,point)
            player.view_point[2] = point
        end
    end

    array()

    local index = 0
    up.loop(0.03,function(t)
        index = index + 1
        if not soldier_data[index] then
            for _,v in ipairs(player.view_soldier) do
                v:remove_restriction'Hide'
                v:add_restriction 'Invisible'
            end
            up.game:event_dispatch('阅兵-创建完成',player,need_buff_anim)
            t:remove()
            return
        end
        local unit = up.create_unit(soldier_data[index].unit_id, soldier_data[index].pos, angle, player)
        unit:add_restriction'Hide'
        unit:set_point(soldier_data[index].pos)
        unit:add_animation{
            name = 'show',
        }
        unit._base:api_set_transparent_when_invisible(false)
        unit._base:api_set_blood_bar_type(0)
        table.insert(player.view_soldier, unit)
        table.insert(player.view_soldier_team[soldier_data[index].team_id], unit)
    end)
end

local function ShowBuffAnim(player)
    for i=1,2 do
        if player.soldier[i].need_buff_anim then
            for _,u in ipairs(player.view_soldier_team[i]) do
                u:add_animation{
                    name = 'buff',
                }
            end
        end
    end
end

up.game:event('阅兵-创建完成',function(_,player,need_buff_anim)
    --队列音效
    for i=1,2 do
        if player.soldier[i].level < 3 then
            if player.soldier[i].num > 8 then
                up.play_sound( player, 134231579, player.view_point[i])
            elseif player.soldier[i].num > 3 then
                up.play_sound( player, 134264177, player.view_point[i])
            else
                up.play_sound( player, 134245207, player.view_point[i])
            end
        end
    end
    if need_buff_anim then
        ShowBuffAnim(player)
    end
end)

--阅兵
round.ViewSoldier = function()
    gameapi.set_day_and_night_time(10)
    local player_group = {}
    for pid = 1, PLAYER_MAX do
        local player = up.player(pid)
        gameapi.play_sound_for_player(player._base, 134277341, true, 0, 0)
        if player:is_playing() and player.is_watching == false then
            table.insert(player_group, player)
        end
    end

    for _, player in ipairs(player_group) do
        player:play_camera_timeline(1000000088)
        print('阅兵创建', player)
        CreateViewSoldier(player)
    end

    local card_list = up.table_copy(round.magic_card)
    --根据执行优先级降序排序
    table.sort(card_list, function(a, b)
        if a.level > b.level then
            return true
        else
            return false
        end
    end)

    --弃牌玩家
    local discard_player = function()
        local timeline = 0
        --镜头等待时间
        timeline = timeline + config.ViewSoldier.camera_time

        timeline = timeline + config.ViewSoldier.discard_wait_time
        up.wait(timeline, function()
            up.game:event_dispatch('回合流程-阅兵弃牌')
        end)
    
        timeline = timeline + config.ViewSoldier.discard_show_time
        up.wait(timeline, function()
        end)
    
        timeline = timeline + config.ViewSoldier.discard_action_time
        up.wait(timeline, function()
            for _, player in ipairs(player_group) do
                if player.discard then
                    --杀死阅兵的单位
                    KillViewSoldier(player)
                end
            end
        end)
    end
    discard_player()

    --常规玩家
    local normal_player = function()
        local timeline = 0
        --镜头等待时间
        timeline = timeline + config.ViewSoldier.camera_time
        --初始等待时间
        timeline = timeline + config.ViewSoldier.wait_time
        up.wait(timeline, function()
        end)

        local function show_card(player,card)
            if player.discard == true then return end
            player.soldier[1].need_buff_anim = false
            player.soldier[2].need_buff_anim = false
            local CardTakeEffect = {}
            if player.discard == false then
                local old_soldier = {
                    [1] = up.table_copy(player.soldier[1]),
                    [2] = up.table_copy(player.soldier[2]),
                }
                if card.pair == true then
                    for i = 1, 2 do
                        if magicCard.condition(card, player, i) then
                            print(player, '魔法卡', card.name, '对', i, '生效')
                            player.soldier[i].need_buff_anim = true
                            CardTakeEffect[i] = true
                            magicCard.action(card, player, i)
                        end
                    end
                else
                    if magicCard.condition(card, player) then
                        print(player, '魔法卡', card.name, '生效')
                        player.soldier[1].need_buff_anim = true
                        player.soldier[2].need_buff_anim = true
                        magicCard.action(card, player)
                        CardTakeEffect[0] = true
                    end
                end

                --只有数量或ID不同时，才要重新创建单位
                local rest_create = false
                for i= 1,2 do
                    if 
                        player.soldier[i].id ~= old_soldier[i].id or
                        player.soldier[i].num ~= old_soldier[i].num
                    then
                        rest_create = true
                    end
                end
                if rest_create then
                    RemoveViewSoldier(player)
                    CreateViewSoldier(player,true)
                else
                    if card.play_buff_anim then
                        ShowBuffAnim(player)
                    end
                end

                -- 必须在create_soldier之后执行，否则无法找到正确的每队中心点
                local function create_team_effect(i)
                    --buff音效
                    if card.buff_sound ~= 0 then
                        up.play_sound(player, card.buff_sound, player.view_point[i])
                    end
                    if card.partical_1 ~= 0 then
                        for _,u in ipairs(player.view_soldier_team[i]) do
                            up.particle {
                                id = card.partical_1,
                                target = u:get_point(),
                                scale = 1,
                                time = 3,
                            }
                        end
                    end
                    if card.partical_2 ~= 0 then
                        up.particle {
                            id = card.partical_2,
                            target = player.view_point[i],
                            scale = 1,
                            time = 3,
                        }
                    end
                end

                if player:is_local() then
                    if card.pair then
                        for i=1,2 do
                            if CardTakeEffect[i] then
                                create_team_effect(i)
                            end
                        end
                    else
                        if CardTakeEffect[0] then
                            for i=1,2 do
                                create_team_effect(i)
                            end
                        end
                    end
                    
                    if CardTakeEffect[0] or CardTakeEffect[1] or CardTakeEffect[2] then
                        if card.partical_3 ~= 0 then
                            up.particle {
                                id = card.partical_3,
                                target = BATTLE_POINT:offset(0,config.GlobalConfig.CREATE_CENTER_DISTANCE),
                                scale = 1,
                                time = 3,
                            }
                        end
                    end
                end
            end
        end

        for _, card in ipairs(card_list) do
            --卡牌揭示时间
            timeline = timeline + config.ViewSoldier.show_time
            up.wait(timeline,function()
                print('揭示[魔法卡]', card.name)
                up.game:event_dispatch('战斗流程-揭示魔法卡', card.group_id,card.key)
                for _, player in ipairs(player_group) do
                    if player.discard == false then
                        if player:is_local() then
                            up.particle {
                                id = card.ready_partical,
                                target = BATTLE_POINT:offset(0, 2500),
                                scale = 1,
                                time = 3,
                            }
                        end
                    end
                end
            end)
            --卡牌展示时间
            timeline = timeline + config.ViewSoldier.display_time
            up.wait(timeline,function()
                print('展示[魔法卡]', card.name)
                for _, player in ipairs(player_group) do
                    show_card(player,card)
                end
            end)
            --卡牌生效时间
            timeline = timeline + config.ViewSoldier.action_time
            up.wait(timeline,function()
                print('生效[魔法卡]', card.name)
            end)
        end
    
        up.wait(timeline, function()
            up.particle {
                id = 103231,
                target = up.actor_point(1697.3,4226.79),
                height = 1450,
                scale = 1,
                time = 1,
            }
        end)
        timeline = timeline + config.ViewSoldier.effect_time
        up.wait(timeline, function()
            for _, player in ipairs(player_group) do
                RemoveViewSoldier(player)
            end
            up.game:event_dispatch('战斗流程-收起魔法卡')
            round.battle()
        end)
    end
    normal_player()
end
