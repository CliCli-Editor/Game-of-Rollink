local round = require 'game.round'

local BattleLoopAttackTimer
local BattleAttackUpTimer
local BattleCameraTimer
local local_player = up.get_localplayer()
local BattleLoopCanEnd
local BattleLoopEnd
local loadcolor = {
    [134247740] = 393220,
    [134282585] = 393224,
    [134270378] = 393218,
    [134249068] = 393219,
    [134249401] = 393222,
    [134258195] = 393223,
    [134272622] = 393217,
    [134229544] = 393221,
}

local power_list = {
    [1] = 1,
    [2] = 5,
    [3] = 10,
    [4] = 20,
}
local get_unit_data = function(_unit)
    for k, v in pairs(config.UnitData) do
        if v.id == _unit:get_key() then
            return config.UnitData[k]
        end
    end
    return nil
end
local quality_quest = function(player,data)
    local quality = data.quality
    if quality then
        if quality == 2 then
            quest.playerquestset(player,'elite_num',1)
        elseif quality >= 3 then
            quest.playerquestset(player,'creatures_num',1)
        end
    end
end

--战斗
round.battle = function()
    round.is_needEnd = false
    local player_group = {}
    for _, v in ipairs(round.player) do
        v.can_cast = true
    end
    for pid = 1, PLAYER_MAX do
        local player = up.player(pid)
        --player:apply_camera(1000000006,0)
        if player:is_playing() then
            player.army = nil
            table.insert(player_group, player)
        end
    end

    local add_buff = function(player)
        local buff_list = {
            ['attack_speed'] = { id = 134234645, ['%'] = true },
            ['attack_phy'] = { id = 134243946, ['%'] = true },
            ['hp_max'] = { id = 134255143, ['%'] = true },
            ['vampire_phy'] = { id = 134260691, ['%'] = false },
        }
    
        --施加状态BUFF
        for _, buff in ipairs(player.buff) do
            if buff.id then
                for _, u in ipairs(player.army.all) do
                    if u:get_typeId() == buff.id then
                        if buff_list[buff.attr]['%'] then
                            u:add(buff.attr, buff.value, 'BaseRatio')
                        else
                            u:add(buff.attr, buff.value)
                        end
                        if not u.power_add then
                            u.power_add = 1
                        end
                        --u.power_add = u.power_add + 0.5
                        --u:new_buff(buff_list[buff.attr].id, {
                        --    source = u,
                        --    skill = nil,
                        --})
                    end
                end
            end
        end
    end

    local create_soldier = function(player,angle)
        player.army = {
            all = {},
            list = {
                [1] = {},
                [2] = {},
            },
            power = 0,
            powerMax = 0,
            power_unit ={},
        }
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
            if player.soldier[1].num == 0  then
                local point = BATTLE_POINT:offset(angle,config.GlobalConfig.CREATE_CENTER_DISTANCE)
                create_soldier_team_pos(2, point)
            elseif player.soldier[2].num == 0  then
                local point = BATTLE_POINT:offset(angle,config.GlobalConfig.CREATE_CENTER_DISTANCE)
                create_soldier_team_pos(1, point)
            else
                local point = BATTLE_POINT:offset(angle,config.GlobalConfig.CREATE_CENTER_DISTANCE - config.GlobalConfig.CREATE_OFFSET_DISTANCE)
                create_soldier_team_pos(1,point)
                point = BATTLE_POINT:offset(angle,config.GlobalConfig.CREATE_CENTER_DISTANCE + config.GlobalConfig.CREATE_OFFSET_DISTANCE)
                create_soldier_team_pos(2,point)
            end
        end
    
        array()

        local index = 0
        local allSoldier = {}
        local bar_color_id = loadcolor[config.LordData[player.lord_id].unit]
		print(player,bar_color_id)
        up.loop(0.03,function(t)
            index = index + 1
            if not soldier_data[index] then
                for _,v in ipairs(allSoldier) do
                    v:remove_restriction'Hide'
                end
                t:remove()
                return
            end
            local unit = up.create_unit(soldier_data[index].unit_id, soldier_data[index].pos, angle + 180, player)
            unit._base:api_set_blood_bar_type(bar_color_id)
            local unit_name = unit:get_name()
            local config_unit_data = config.UnitData[unit_name]
            if not config_unit_data then
                config_unit_data = get_unit_data(unit)
            end
            if not config_unit_data then
                print("!!!!获取UnitData失败", unit_name)
            else
                quality_quest(player,config_unit_data)
            end
            --unit:set_point(soldier_data[index].pos)
            unit:add_restriction'Hide'
            table.insert(allSoldier,unit)
            table.insert(round.all_unit, unit)
            table.insert(player.army.all, unit)
            table.insert(player.army.list[soldier_data[index].team_id], unit)
        end)
    end

    --开战
    round.is_battle = true
    for pid = 1,PLAYER_MAX do
        if up.player(pid):is_playing() then
            --up.player(pid):set_mouse_wheel_switch(true)
        end
    end
    local circle_point = BATTLE_POINT
    local t_group = {}
    for pid,player in ipairs(player_group) do
        if player.discard == false then
            table.insert(t_group, player)
        else
            player.battle_camera_data = {
                point = circle_point,
                dis = 4900,
                height = 0,
                yaw = 0,
                pitch = 20,
                show_dis = 35,
            }
            player:set_camera_data(player.battle_camera_data)
            --player:camera_set_tps_follow_unit(up.actor_unit(1),5,20,0,0,0,0,50)
            --player:apply_camera(1000000006,0)
        end
    end
    for pid = 1, #t_group do
        local player = t_group[pid]
        local angle = 360 / #t_group * pid
        --player:camera_set_tps_follow_unit(up.actor_unit(1),5,20,angle,0,0,0,50)
        player.battle_camera_data = {
            point = circle_point,
            dis = 4900,
            height = 0,
            yaw = angle,
            pitch = 20,
            show_dis = 35,
        }
        player:set_camera_data(player.battle_camera_data)
        --创建中心战场的单位
        print('开战创建', player)
        create_soldier(player,angle)
        gameapi.set_trigger_list_variable_point("出生点位", pid, circle_point:offset(angle, config.GlobalConfig.CREATE_CENTER_DISTANCE)._base)
        up.wait(1,function()
            add_buff(player)
            if #player.army.all == 0 then
                table.removeValue(round.player, player)
                round.judgeBattleEnd()
            end
        end)
        up.wait(1.5,function()
            for _, unit in ipairs(player.army.all) do
                local unit_name = unit:get_name()
                local config_unit_data = config.UnitData[unit_name]
                if not config_unit_data then
                    config_unit_data = get_unit_data(unit)
                end
                if not unit.power_add then
                    unit.power_add = 1
                end
                if not config_unit_data then
                    unit.power = power_list[1]
                    player.army.power = player.army.power + unit.power*unit.power_add
                    player.army.powerMax = player.army.powerMax + unit.power
                else
                    unit.power = power_list[config_unit_data.quality or 1]
                    player.army.power = player.army.power + unit.power*unit.power_add
                    player.army.powerMax = player.army.powerMax + unit.power
                    if config_unit_data.quality > 2 then
                        local have = false
                        for _, v in ipairs(player.army.power_unit) do
                            if v[1] == unit:get_key() then
                                v[2] = v[2] + 1
                                have = true
                            end
                        end
                        if not have then
                            table.insert(player.army.power_unit,{unit:get_key(),1})
                        end
                    end
                end
            end
            up.game:event_dispatch('回合流程-战斗开始')
        end)
    end
    up.wait(3, function()
        for pid = 1, #t_group do
            local player = t_group[pid]
            for _, v in ipairs(player.army.all) do
				if v:is_destroyed() then goto continue end
                local unit_point = v:get_point()
                local target_point = unit_point:offset(v:get_facing(), config.GlobalConfig.BATTLE_MOVE_DISTANCE)
                v:move(target_point)
				::continue::
            end
            --平衡天罚
            if round.is_balance then
                up.wait(5, function()
                    local all_army = {}
                    for _, v in ipairs(player.army.all) do
                        if v and v:is_alive() then
                            table.insert(all_army,v)
                        end
                    end
                    if #all_army <= 1 then return end
                    local index = math.floor(#all_army / 2)
                    for i = 1,index do
                        local random = math.random(1,#all_army)
                        local unit = all_army[random]
                        table.remove(all_army,random)
                        up.particle {
                            id = 103212,
                            target = unit:get_point(),
                            scale = 1,
                            time = 1,
                        }
                        unit:kill()
                    end
                end)
            end
        end
        round.judgeBattleEnd()
    end)
    ---战斗回合开始 发送回合开始事件
    gameapi.send_event_custom(1052001360, gameapi.gen_param_dict({}, "回合内", true))
    --延迟5秒后让所有单位向中心攻击
    up.wait(5, function()
        --print("进度 23 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
        if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then
            gameapi.send_event_custom(1261242200, gameapi.gen_param_dict(gameapi.gen_param_dict({}, "新手教程文本", config.GuideList[23]["str"]), "当前进度", 23))          --新手引导 23
        end
        gameapi.set_trigger_variable_boolean("战斗回合", true)
        BattleLoopAttackTimer = up.loop(1,function()
            for pid = 1, #t_group do
                local player = t_group[pid]
                if player.army then
                    local cnt = #player.army.all+1
                    for k, v in ipairs(player.army.all) do
                        local _u = player.army.all[cnt-k]
                        if _u and not _u:is_destroyed() then
                            v:attack(BATTLE_POINT)
                            if round.is_needEnd == true then
                                local data = {}
                                data.target = v
                                data.damage = 300
                                v:damage(data)
                            end
                        else
                            table.remove(player.army.all, cnt-k)
                            if #player.army.all == 0 then
                                table.removeValue(round.player, player)
                                round.judgeBattleEnd()
                            end
                        end
                    end
                end
            end
        end)
    end)
    BattleAttackUpTimer = up.wait(40,function()
        BattleLoopCanEnd = up.loop(5,function()
            round.judgeBattleEnd()
        end)        for pid = 1, #t_group do
            local player = t_group[pid]
            for _, v in ipairs(player.army.all) do
                if v:is_alive() then
                    v:add('attack_speed',100)
                    v:add('ori_speed',100)
                end
            end
        end
    end)
    BattleLoopEnd = up.wait(90,function()
        round.is_needEnd = true
    end)
    local function camera_update()
        local max_yaw_offset = 30
        local min_yaw_offset = -30
        local max_dis_offset = 0
        local min_dis_offset = -3000
        for pid = 1,PLAYER_MAX do
            local player = up.player(pid)
            if player:is_playing() then
                player.yaw_offset = 0
                player.dis_offset = 0
            end
        end
        BattleCameraTimer = up.loop(0.1,function()
            for pid = 1,PLAYER_MAX do
                local player = up.player(pid)
                if player:is_playing() then
                    if player:is_key_pressed('A') then
                        player.yaw_offset = player.yaw_offset - 3
                        --if player.yaw_offset < min_yaw_offset then player.yaw_offset = min_yaw_offset end
                    end
                    if player:is_key_pressed('D') then
                        player.yaw_offset = player.yaw_offset + 3
                        --if player.yaw_offset > max_yaw_offset then player.yaw_offset = max_yaw_offset end
                    end
                    if player:is_key_pressed('W') then
                        player.dis_offset = player.dis_offset - 150
                        if player.dis_offset < min_dis_offset then player.dis_offset = min_dis_offset end
                    end
                    if player:is_key_pressed('S') then
                        player.dis_offset = player.dis_offset + 150
                        if player.dis_offset > max_dis_offset then player.dis_offset = max_dis_offset end
                    end
                    local camera_data = up.table_copy(player.battle_camera_data)
                    camera_data.yaw = camera_data.yaw + player.yaw_offset
                    camera_data.dis = camera_data.dis + player.dis_offset
                    camera_data.time = 0.1
                    player:set_camera_data(camera_data)
                end
            end
        end)
    end
    camera_update()
end

round.judgeBattleEnd = function()
    if round.is_battle == false then return end
    if #round.player <= 1 then
        round.is_battle = false
        local time = 5
        local player = round.player[1]
        --关闭技能指示器
        if player.lord:is_destroyed() == false then
            for skill in player.lord:each_skill() do
                gameapi.stop_skill_pointer(player._base,skill._base)
            end
        end
        if GameMode == 'Lord' or GameMode == 'Custom' then
            player.can_cast = false
            ---技能替换 胜利隐藏技能
            up.game:event_dispatch('回合流程-隐藏技能', player)
            ---技能替换 发送回合结束事件
            gameapi.send_event_custom(1052001360, gameapi.gen_param_dict({}, "回合内", false))
        end
        print(player,'获得胜利')
        if BattleLoopAttackTimer then
            BattleLoopAttackTimer:remove()
        end
        if BattleAttackUpTimer then
            BattleAttackUpTimer:remove()
            if BattleLoopCanEnd then
                BattleLoopCanEnd:remove()
            end
        end
        if BattleLoopEnd then
            BattleLoopEnd:remove()
        end
        for _, u in ipairs(player.army.all) do
            u:add_restriction'Imperishable'
            u:set_hp_bar_type('无血条')
        end
        up.wait(1.5,function()
            for _, u in ipairs(player.army.all) do
                if u:has_tag('兵种') then
                    up.play_sound(player, 134272799, u)
                end
                u:stop()
                u:add_animation{
                    name = 'win',
                }
                ---技能替换 判兵种
                if not u:has_tag('兵种') then
                    print(u,u:getTypeKv('win','abilityName'))
                    local skill = u:find_skill('Common',u:getTypeKv('win','abilityName'))
                    if skill then
                        print(u,skill)
                        u:cast(skill)
                    end
                end
            end
        end)
        up.wait(time, function()
            if BattleCameraTimer then
                BattleCameraTimer:remove()
            end
            for pid = 1,PLAYER_MAX do
                if up.player(pid):is_playing() then
                    --up.player(pid):camera_cancel_tps()
                    --up.player(pid):set_mouse_wheel_switch(false)
                    --清理领主BUFF
                    if up.player(pid).lord and not up.player(pid).lord:is_destroyed() then
                        for buff in up.player(pid).lord:each_buff() do
                            buff:remove()
                        end
                    end
                end
            end
            up.game:event_dispatch('回合流程-战斗结束过场')
            up.wait(55/30, function()
                for i = 1,4 do
                    up.player(i):play_camera_timeline(1000000330)
                end
            end)
            --关闭技能指示器
            if player.lord:is_destroyed() == false then
                for skill in player.lord:each_skill() do
                    gameapi.stop_skill_pointer(player._base,skill._base)
                end
            end
            --清理场上单位
            for _, v in ipairs(round.all_unit) do
                v:remove()
            end
            gameapi.set_trigger_variable_boolean("战斗回合", false)
            round.all_unit = {}
            
            up.wait(85/30, function()
                round.over()
            end)
        end)
    end
    if #round.player == 0 then
        up.traceback('没有胜利玩家')
    end
end

--up.game:event('Mouse-Move',function(_,player)
--    local max_x_offset = 30
--    local max_y_offset = 1000
--    if round.is_battle then
--        local offset_x = (player:get_mouse_windows_pos().x - 0.5) / 0.5
--        local offset_y = player:get_mouse_windows_pos().y * -1
--        local camera_data = up.table_copy(player.battle_camera_data)
--        camera_data.yaw = camera_data.yaw + offset_x * max_x_offset
--        --camera_data.dis = camera_data.dis + offset_y * max_y_offset
--        camera_data.time = 0.1
--        player:set_camera_data(camera_data)
--    end
--end)

up.game:event('Unit-Die', function(_, unit)
    if not round.is_battle then
        return
    end
    local player = unit:get_owner()
    for k, v in ipairs(player.army.all) do
        if v == unit then
            unit.power = unit.power or 0
            unit.power_add = unit.power_add or 0
            player.army.power = player.army.power - unit.power*unit.power_add
            table.remove(player.army.all, k)
        end
    end
    for k, v in ipairs(player.army.power_unit) do
        if v[1] == unit:get_key() then
            v[2] = v[2] - 1
            if v[2] == 0 then
                table.remove(player.army.power_unit,k)
            end
        end
    end
    if unit.eff then
        gameapi.delete_sfx(unit.eff,true)
    end
    up.game:event_dispatch('战斗流程-战斗力变化', player)
    if #player.army.all == 0 and #round.player > 1 then
        print(player, '所有士兵阵亡')
        player.can_cast = false
        --关闭技能指示器
        if player.lord:is_destroyed() == false then
            for skill in player.lord:each_skill() do
                gameapi.stop_skill_pointer(player._base,skill._base)
            end
        end
        up.game:event_dispatch('回合流程-战斗败北', player)
        table.removeValue(round.player, player)
        --if player:get(GOLD)<= 0 and GameMode =='Lord' then
        --    InsertRank(player)
        --end
    end
    round.judgeBattleEnd()
end)

do
    local new_trigger = new_global_trigger(2095137375, "接受自定义事件", { "ET_EVENT_CUSTOM", 1893261918 }, true)
    new_trigger.event.target_type = ""
    new_trigger.on_event = function(trigger, event_name, actor, data)
        --print("--------------正常执行 1893261918")
        local unit = up.actor_unit((gameapi.get_custom_param(data['__c_param_dict'], "单位")))
        local player = up.player(gameapi.get_custom_param(data['__c_param_dict'], "玩家"):get_role_id_num())
        if not player.army then
            if unit then unit:remove() end
            return
        end
        table.insert(player.army.all, unit)
        table.insert(round.all_unit, unit)
        local bar_color_id = loadcolor[config.LordData[player.lord_id].unit]
        unit._base:api_set_blood_bar_type(bar_color_id)
        local unit_name = unit:get_name()
        local config_unit_data = config.UnitData[unit_name]
        if not config_unit_data then
            config_unit_data = get_unit_data(unit)
        end
        unit.power_add = 1
        if not config_unit_data then
            print("!!!!获取UnitData失败", unit_name)
            unit.power = power_list[2]
            player.army.power = player.army.power + unit.power
            player.army.powerMax = player.army.powerMax + unit.power
            local have = false
            for _, v in ipairs(player.army.power_unit) do
                if v[1] == unit:get_key() then
                    v[2] = v[2] + 1
                    have = true
                end
            end
            if not have then
                table.insert(player.army.power_unit,{unit:get_key(),1})
            end
        else
            unit.power = power_list[config_unit_data.quality or 1]
            player.army.power = player.army.power + unit.power
            player.army.powerMax = player.army.powerMax + unit.power
            if config_unit_data.quality > 2 then
                local have = false
                for _, v in ipairs(player.army.power_unit) do
                    if v[1] == unit:get_key() then
                        v[2] = v[2] + 1
                        have = true
                    end
                end
                if not have then
                    table.insert(player.army.power_unit,{unit:get_key(),1})
                end
                local buff_list = {
                    ['attack_speed'] = { id = 134234645, ['%'] = true },
                    ['attack_phy'] = { id = 134243946, ['%'] = true },
                    ['hp_max'] = { id = 134255143, ['%'] = true },
                    ['vampire_phy'] = { id = 134260691, ['%'] = false },
                }
                for _, buff in ipairs(player.buff) do
                    if buff.level then
                        if buff.level == config_unit_data.quality then
                            if buff_list[buff.attr]['%'] then
                                unit:add(buff.attr, buff.value, 'BaseRatio')
                            else
                                unit:add(buff.attr, buff.value)
                            end
                            if not unit.power_add then
                                unit.power_add = 1
                            end
                            --u.power_add = u.power_add + 0.5
                            --u:new_buff(buff_list[buff.attr].id, {
                            --    source = u,
                            --    skill = nil,
                            --})
                        end
                    end
                end
            end
        end
        if local_player.battle_show_player and local_player.battle_show_player ==  player then
            unit.eff = gameapi.create_sfx_on_unit(102581, unit._base, "root", false, true, 1.0, Fix32(-1.0), Fix32(-1.0))
        end
        up.game:event_dispatch('战斗流程-战斗力变化', player)
    end
end
