
local round = require 'game.round'

local lord_pool = {}
for i=1,PLAYER_MAX do
    table.insert(lord_pool,i)
end

up.game:event('Junior-Init',function()
    up.wait(0.1,function ()
        round.BetConfig = config.BetConfig[GameMode]
        for pid = 1,PLAYER_MAX do
            local player = up.player(pid)
            if player:is_playing() then
                player:add(GOLD,config.BetConfig[GameMode][1].Fee)
                player.statistic = {
                    ['胜利回合数'] = 0,
                    ['失败回合数'] = 0,
                    ['单场最大赚取'] = 0,
                }
            end
        end
        --创建领主
        local circle_point = up.get_circle_center_point(1000000176)
        for pid = 1,PLAYER_MAX do
            local player = up.player(pid)
            if player:is_playing() then
                local angle = -90 * (pid - 1)+180
                local point = circle_point:offset(angle,400)
                player.lord_id = pid
                player.lord = up.create_unit(config.LordData[player.lord_id].unit,point,angle + 180,player)
                player.lord.ani_state = 'sit'
                player:play_camera_timeline(1000000085)
                for i = 1,3 do 
                    player['lord_skill_charge_'..i] = config.LordData[player.lord_id]['LordSkillCharge_'..i]
                    player['commen_skill_charge_'..i] = config.LordData[player.lord_id]['CommenSkillCharge_'..i]
                end
            end
            up.player(pid):apply_camera(1000000108,0)
            up.wait(0.03, function()
                up.player(pid):play_camera_timeline(1000000330)
            end)
        end
        up.game:event_dispatch('主流程-锁定领主')
        round.start()
    end)
end)
