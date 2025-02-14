
local round = require 'game.round'

local lord_pool = {}
for i=1,PLAYER_MAX do
    table.insert(lord_pool,i)
end
local skill_card_max = config.GlobalConfig.SKILL_CARD_MAX
---技能替换 表(临时)
local skill_get = function()
    local list = {}
    local SkillPool = up.table_copy(config.SkillPool)
    for i = 1, skill_card_max-1 do
        local solt = math.random(1,#SkillPool)
        table.insert(list,SkillPool[solt].Skill_ID)
        table.remove(SkillPool,solt)
    end
    return list
end


local countdown = config.GlobalConfig.SELECT_LORD_COUNTDOWN


local function select_lord_end()
    gameapi.set_day_and_night_time(8)
    -- local door_human_L = up.create_destructable(134271003,up.point(438.49,5172.0,860),-103,1.6)
    -- local door_human_R = up.create_destructable(134271003,up.point(306.92,5661.5,860),-103,1.6)
    
    --创建领主
    local circle_point = up.get_circle_center_point(1000000176)
    for pid = 1,PLAYER_MAX do
        local player = up.player(pid)
        if (player:is_playing() and player.is_watching == false) or IS_TEST then
            local angle = -90 * (pid - 1)+180
            local point = circle_point:offset(angle,400)
            if not player.lord_id then
                player.lord_id = lord_pool[math.random(1,#lord_pool)]
                table.removeValue(lord_pool,player.lord_id)
            end
            player.lord = up.create_unit(config.LordData[player.lord_id].unit,point,angle + 180,player)
            for i = 1,3 do 
                player['lord_skill_charge_'..i] = config.LordData[player.lord_id]['LordSkillCharge_'..i]
                player['commen_skill_charge_'..i] = config.LordData[player.lord_id]['CommenSkillCharge_'..i]
            end
            player.lord.ani_state = 'sit'
            ---技能替换  --学习技能表里的技能
            player.skill_list = {config.LordData[player.lord_id].LordSkill_1}
            player['skill_charge_1'] = config.LordData[player.lord_id]['LordSkillCharge_1']
            local _skillList = skill_get()
            for i, v in ipairs(_skillList) do
                player.lord:add_skill('Common',v,i+1)
                table.insert(player.skill_list,v)
                player['skill_charge_'..i+1] = config.SkillData[v]['SkillCharge']
            end
            player.skill_slot_now = {}
            player.skill_slot_next = 1
        end
    end
    up.game:event_dispatch('主流程-锁定领主')
    up.wait(config.GlobalConfig.SELECT_LORD_CONFIRM_TIME,function()
        --print("进度 5 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
        if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then
            gameapi.send_event_custom(1261242200, gameapi.gen_param_dict(gameapi.gen_param_dict({}, "新手教程文本", config.GuideList[5]["str"]), "当前进度", 5))          --新手引导 5
        end

        local particle

        for pid = 1,PLAYER_MAX do
            local player = up.player(pid)
            gameapi.play_sound_for_player(player._base, 134240027, true, 0, 0)
            player:play_camera_timeline(1000000085)
        end
        up.game:event_dispatch('主流程-选择领主',false)
        
        --雕像灰尘
        up.wait(1.3,function()
            --print('++++++++++++++++'..up.actor_destructable(2):get_point().x.."++++++++++++++++++")
            local particle_L=up.particle{
            id = 104065,
            target = up.actor_point(up.actor_destructable(2):get_point().x*100,up.actor_destructable(2):get_point().y*100),
            height = up.actor_destructable(2):get_point().z*100+150,
            angle = 0,
            scale =1,
            time = 10,
            speed =1,
            }
            local particle_R=up.particle{
                id = 104065,
                target = up.actor_point(up.actor_destructable(3):get_point().x*100,up.actor_destructable(3):get_point().y*100),
                height = up.actor_destructable(2):get_point().z*100+150-85-(up.actor_destructable(3):get_point().x*100-up.actor_destructable(2):get_point().x*100)-(up.actor_destructable(3):get_point().y*100-up.actor_destructable(2):get_point().y*100)-(up.actor_destructable(3):get_point().z*100-up.actor_destructable(2):get_point().z*100),
                angle = 0,
                scale = 1,
                time = 10,
                speed =1,
                }   
        end)
        --雕像播放动画
        up.wait(1.8,function()
            --print('_______________高度一为：'..up.actor_destructable(2):get_point().z..'____________')
            --print('_______________高度2为：'..up.actor_destructable(3):get_point().z..'____________')
            up.actor_destructable(2):play_animation('spell1')
            up.actor_destructable(3):play_animation('spell1')
            up.wait(2.2,function()
                local particle_L=up.particle{
                id = 104066,
                target = up.actor_point(up.actor_destructable(2):get_point().x*100,up.actor_destructable(2):get_point().y*100),
                height = up.actor_destructable(2):get_point().z*100-380,
                angle = 0,
                scale = 1,
                time = 10,
                speed = 1,
                }
                local particle_R=up.particle{
                    id = 104066,
                    target = up.actor_point(up.actor_destructable(3):get_point().x*100,up.actor_destructable(3):get_point().y*100),
                    height = up.actor_destructable(2):get_point().z*100-380-85-(up.actor_destructable(3):get_point().x*100-up.actor_destructable(2):get_point().x*100)-(up.actor_destructable(3):get_point().y*100-up.actor_destructable(2):get_point().y*100)-(up.actor_destructable(3):get_point().z*100-up.actor_destructable(2):get_point().z*100),
                    angle = 0,
                    scale = 1,
                    time = 10,
                    speed = 1,
                    }
            end)
        end)

        up.wait(4.5,function()
            particle = up.particle{
                id = 103183,
                target = up.actor_point(544.92,5508.67),
                height = 382,
                angle = 257.5,
                scale = 1,
                time = 5,
                speed = 0.8,
            }
            particle:set_scale(0.6,1,1)
        end)
        up.wait(5,function()
            up.actor_destructable(29):play_animation('open')
            local light
            up.wait(1.2,function()
                light = up.particle{
                    id = 103184,
                    target = up.actor_point(482,5446),
                    --target = up.actor_point(464.92,5488.67),
                    height = 1280,
                    scale = 3,
                    time = 5,
                }
            end)
            up.wait(1.8,function()
                particle:remove()
                light:set_point(up.actor_point(1650.93,6382.48))
                light:set_height(-99)
                up.wait(0.03,function()
                    for pid = 1,PLAYER_MAX do
                        up.player(pid):play_camera_timeline(1000000330)
                    end
                end)
                round.start()
            end)
        end)
    end)
end

up.game:event('Lord-Init',function()
    --up.send_event_custom(1546010391,{})
    round.BetConfig = config.BetConfig[GameMode]
    for pid = 1,PLAYER_MAX do
        local player = up.player(pid)
        if player:is_playing() then
            gameapi.play_sound_for_player(player._base, 134270737, true, 0, 0)
            player:add(GOLD,config.BetConfig[GameMode][1].Fee)
            player.statistic = {
                ['胜利回合数'] = 0,
                ['失败回合数'] = 0,
                ['单场最大赚取'] = 0,
            }
        end
    end
    up.game:event_dispatch('主流程-选择领主',true)
    gameapi.send_event_custom(1546010391, {})
    up.wait(0.03, function()
        --print("选人时间调整 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
        if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then          --新手引导 选人时间调整
            countdown = 3
        end
        round.select_lord_timer = up.wait(countdown,function()
            select_lord_end()
            round.select_lord_timer = nil
        end)
    end)
end)

--接收玩家选择领主事件
do
    local new_trigger = new_global_trigger(2095114375, "接受自定义事件", { "ET_EVENT_CUSTOM", 1803439340}, true)
    new_trigger.event.target_type = ""
    new_trigger.on_event = function(trigger, event_name, actor, data)
        local player = up.player(gameapi.get_custom_param(data['__c_param_dict'], "玩家"):get_role_id_num())
        local uid_key = gameapi.get_custom_param(data['__c_param_dict'], "领主ID")
        if player.lord_id ~= nil then
            up.traceback(player,'重复选择领主')
            return
        end
        player.lord_id = uid_key
        table.removeValue(lord_pool,uid_key)

        if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then          --新手引导 选人时间调整
            return
        end
        
        for pid = 1,PLAYER_MAX do
            local player = up.player(pid)
            if player:is_playing() then
                if player._base:get_role_status() == 1 then
                    if player.lord_id == nil then
                        return
                    end
                end
            end
        end
        if round.select_lord_timer then
            round.select_lord_timer:remove()
            round.select_lord_timer = nil
        end
        select_lord_end()
    end
end

local new_trigger3 = new_global_trigger(1004528195, "接受自定义事件", { "ET_EVENT_CUSTOM", 1577687523 }, true)
new_trigger3.event.target_type = ""
new_trigger3.on_event = function(trigger, event_name, actor, data)
    local player = up.player(1)
    player.action = 'all_in'
    player.add_bet = player:get(GOLD)
    up.game:event_dispatch('回合流程-AI下注', player, player:get(GOLD), 'all_in')
    up.game:event_dispatch('回合流程-玩家下注', player, player:get(GOLD), 'all_in')
    up.game:event_dispatch('回合流程-allin', player)
    print("新手引导 all in了")
end

up.game:event('UI事件-选择领主',function(_,player,uid_key)
    if player.lord_id ~= nil then
        up.traceback(player,'重复选择领主')
        return
    end
    player.lord_id = uid_key
    table.removeValue(lord_pool,uid_key)
    
    for pid = 1,PLAYER_MAX do
        local player = up.player(pid)
        if player:is_playing() then
            if player.lord_id == nil then
                return
            end
        end
    end
    if round.select_lord_timer then
        round.select_lord_timer:remove()
        round.select_lord_timer = nil
    end
    select_lord_end()
end)