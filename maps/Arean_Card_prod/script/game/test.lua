
--require 'game.gm'
BATTLE_POINT = up.get_circle_center_point(1000000005)

up.player(1).soldier = {
    [1] = {
        num = config.TestConfig.soldier_card[1].key2,
        id =config.SoldierData[1].unit_id,
        level = 1,
    },
    [2] = {
        num = config.TestConfig.soldier_card[2].key2,
        id = config.SoldierData[2].unit_id,
        level = 1,
    },
}

local test = function()
    up.player(1):apply_camera(1000000331,0)
    local CreateViewSoldier = function(player)
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
    
        for i=1,#soldier_data do
            local unit = up.create_unit(soldier_data[i].unit_id, soldier_data[i].pos, angle, up.player(1))
            table.insert(player.view_soldier_team[soldier_data[i].team_id],unit)
        end
    end
    CreateViewSoldier(up.player(1))
end

return test
