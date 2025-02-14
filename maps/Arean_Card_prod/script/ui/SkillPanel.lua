---@diagnostic disable: need-check-nil
local SkillPanel = {}
local local_player = up.get_localplayer()
local ui = require 'ui.local'
local round = require'game.round'
local bet_data = config.BetConfig[GameMode]
local skill_angle = {-5,0,5}
local ui_point = {
    ['skill_1'] = {
        ['down'] = {
            141.0,-22.0,
        },
        ['down_select'] = {
            141.0,-22.0
        },
        ['up'] = {
            141.0,137.0
        },
        ['up_select'] = {
            141.0,137.0
        },
    },
    ['skill_2'] = {
        ['down'] = {
            281.5,-1.0
        },
        ['down_select'] = {
            281.5,-1.0
        },
        ['up'] = {
            281.5,148.0
        },
        ['up_select'] = {
            281.5,148.0
        },
    },
    ['skill_3'] = {
        ['down'] = {
            421.0,-22.0
        },
        ['down_select'] = {
            421.0,-22.0
        },
        ['up'] = {
            421.0, 137.0
        },
        ['up_select'] = {
            421.0, 137.0
        },
    },
    ['skill_drop'] = {
        281,379
    },
}
---本地数据
local l_data = {
    ['show_type'] = 'down',
}
---初始化ui事件和vx事件。
function SkillPanel:init_skill_panel_ui_event()
    for pid = 1,PLAYER_MAX do
        local player = up.player(pid)
        if player:is_playing() then
            player.skill_hover = {}
        end
    end
    self['skill_show_type_click'] = ui:new_event('SkillPanel.LordSkill.show','click')
    self['close_skill_move_in'] = ui:new_event('SkillPanel.close_skill','move_in')
    self['close_skill_move_out'] = ui:new_event('SkillPanel.close_skill','move_out')
    for i = 1 ,3 do 
        ui:set_ui_comp_rotation('SkillPanel.LordSkill.SkillSlot.skill_'..i,skill_angle[i])
        self['skill_move_in'..i] = ui:new_event('SkillPanel.LordSkill.SkillSlot.skill_'..i,'move_in')
        self['skill_move_out'..i] = ui:new_event('SkillPanel.LordSkill.SkillSlot.skill_'..i,'move_out')
    end
end

---获得玩家A在玩家B的场景座位ui位置
---@param _playerA table 玩家实例
---@param _playerB table 玩家实例
---@return integer seat_id 座位的标号，本地玩家始终为1
function SkillPanel:find_player_scene_seat(_playerA,_playerB)
    if not _playerB then _playerB = local_player end
    local seat_id
        if _playerA:get_id() >= _playerB:get_id() then
            seat_id = _playerA:get_id() - _playerB:get_id() + 1
        else
            seat_id = PLAYER_MAX - (_playerB:get_id() - _playerA:get_id()) + 1
        end
    return seat_id
end

---绑定技能到某个技能UI
function SkillPanel:bind_skill_ui(path,skill)
    local _path = 'SkillPanel.LordSkill.'..path
    local skill_id = skill._base:api_get_ability_id()
    if not skill_id then return end
    if not  config.SkillData[skill_id] then return end
    local icon = config.SkillData[skill_id].Card
    ui:set_text(_path..'.skill.name',skill:get_name())
    ui:set_text(_path..'.skill.tips',skill:get_desc())
    ui:set_image(_path..'.skill',icon)
end

---技能替换 绑技能换表
function SkillPanel:bind_lord_skill()
    if local_player.is_watching ~= false or local_player.is_watching == nil or not local_player.lord then
    else
        ui:set_text('SkillPanel.LordSkill.skill_cnt.text',math.max(#local_player.skill_list - local_player.skill_slot_next+1,0))
        for i = 1,3 do
            local solt = local_player.skill_slot_now[i]
            if solt and local_player.lord._base:api_get_ability(2,solt) then
                ui:set_position('SkillPanel.LordSkill.SkillSlot.skill_'..i,ui_point['skill_'..i][l_data['show_type']])
                ui:set_visible('SkillPanel.LordSkill.SkillSlot.skill_'..i,true)
                local skill = up.actor_skill(local_player.lord._base:api_get_ability(2,solt))
                self:bind_skill_ui('SkillSlot.skill_'..i,skill)
                ui:set_visible('SkillPanel.LordSkill.SkillSlot.skill_'..i,true)
            else
                ui:set_visible('SkillPanel.LordSkill.SkillSlot.skill_'..i,false)
            end
        end
    end
    for j=1,PLAYER_MAX do
        local v = up.player(j)
        if v:is_playing() == true then
            local seat_id = self:find_player_scene_seat(v)
            for i = 1,3 do
                local solt = v.skill_slot_now[i]
                if solt and v.lord and v.lord._base:api_get_ability(2,solt) then
                    ui:set_image(ui:get_scene_ui_child(local_player.player_info[seat_id],'skill_show'..i),903499)
                else
                    ui:set_image(ui:get_scene_ui_child(local_player.player_info[seat_id],'skill_show'..i),903500)
                end
            end
        end
    end
    ui:set_visible('SkillPanel.LordSkill',true)
end

---计算镜头坐标
local camera_point_get = function (player)
    local camera_data = up.table_copy(player.battle_camera_data)
    camera_data.yaw = camera_data.yaw + player.yaw_offset
    camera_data.dis = camera_data.dis + player.dis_offset
    local focusDistance = camera_data.dis -1000 -- 焦点距离
    local focusHeight = camera_data.height -- 焦点高度
    local navAngle = camera_data.yaw -20-- 导航角
    local pitchAngle = camera_data.pitch -- 俯仰角
    local targetPosition = camera_data.point
    -- 计算相机坐标
    local cameraHeight = focusHeight + focusDistance * math.sin(pitchAngle)
    local distanceToTarget = focusDistance * math.cos(pitchAngle)
    local cameraPos = targetPosition:offset(navAngle,distanceToTarget)
    --cameraPos = cameraPos:offset({navAngle+90,1000})
    local x = cameraPos.x
    local y = cameraPos.y
    local z = targetPosition.z + cameraHeight -500* (player.dis_offset-3000)/-3000
    return cameraPos,z
    --lua: -4588.1776418509    -501.6529000001    -500.0
    --return up.point(2000,-3680,cameraPos.z-500)
end

---卡牌位置调整
local show_type_change = function(_type)
    print('show_type_change',_type,l_data['show_type'])
    if not _type then
        if l_data['show_type'] == 'down' then
            _type = 'up'
        else
            _type = 'down'
        end
        l_data['show_type'] = _type
    else
        if _type == 'refresh' then
            _type = l_data['show_type']
        end
    end
    local path = 'SkillPanel.LordSkill.show'
    if _type == 'down' then
        ui:set_ui_comp_rotation(path,180)
    else
        ui:set_ui_comp_rotation(path,0)
    end
    for i = 1,3 do
        if i == local_player.skill_hover_id then
            ui:set_position('SkillPanel.LordSkill.SkillSlot.skill_'..i,ui_point['skill_'..i][_type..'_select'])
        else
            ui:set_position('SkillPanel.LordSkill.SkillSlot.skill_'..i,ui_point['skill_'..i][_type])
        end
    end
end
---特效及指示器关闭
local lightning_stop = function(player)
    if not player.skill_hover then return end
    if player.skill_hover.lightning then player.skill_hover.lightning:remove() end
    if player.skill_hover.skill and player.lord and not player.lord:is_destroyed() then
        gameapi.stop_skill_pointer(player._base,player.skill_hover.skill._base)
    end
end
---特效及指示器创建
local lightning_start = function(player)
    lightning_stop(player)
    local _p,_h = camera_point_get(player)
    player.skill_hover.lightning = up.lightning({
        id = 102721,
        source = player:get_mouse_pos(),
        target_height = 10,
        target = _p,
        source_height = _h,
        immediately = true,
    })
    gameapi.start_skill_pointer(player._base,player.skill_hover.skill._base)
end

---去除之前技能特效
local LeftDown_skill_off = function (player)
    if player.skill_hover then
        if player.skill_hover.wait_time then player.skill_hover.wait_time:remove() end
        player.skill_hover.on = false
        if player.skill_hover.LeftRelease then player.skill_hover.LeftRelease:remove() end
        if player.skill_hover.RightDown then player.skill_hover.RightDown:remove() end
        if player.skill_hover.skill and player.lord and not player.lord:is_destroyed() then
            player.skill_hover.skill:enable()
        end
        if player ~= local_player then return end
        ui:set_visible('SkillPanel.LordSkill.skill_drop',false)
        ui:set_position('SkillPanel.LordSkill.skill_drop',ui_point['skill_drop'])
        lightning_stop(player)
        ui:set_visible('SkillPanel.close_skill',false)
    end
end

---左键
local LeftDown_skill = function (player,skill)
    if player.skill_hover.LeftRelease then player.skill_hover.LeftRelease:remove() end
    player.skill_hover.LeftRelease = up.game:event('Mouse-LeftRelease',function (self,_player)
        if _player ~= player then return end
        if player.skill_hover.on == false then return end
        self:remove()
        LeftDown_skill_off(player)
        show_type_change('refresh')
        if player.skill_hover.close then
        else
            if not player.cast_skill and round.is_battle == true then
                player.cast_skill = true
                up.wait(0.1,function ()
                    player.cast_skill = false
                end)
                local p = player:get_mouse_pos()
                local long = BATTLE_POINT:__mul(p)
                local angle = BATTLE_POINT:__div(p)
                if long > 30 then
                    p = BATTLE_POINT:offset(angle,3000)
                end
                player.lord:cast(skill, p)
            end
        end
    end)
    if player.skill_hover.RightDown then player.skill_hover.RightDown:remove() end
    player.skill_hover.RightDown = up.game:event('Mouse-RightDown',function (self,_player)
        if _player ~= player then return end
        if player.skill_hover.on == false then return end
        self:remove()
        LeftDown_skill_off(player)
        show_type_change('refresh')
    end)
    if player ~= local_player then return end
    SkillPanel:bind_skill_ui('skill_drop',skill)
end

---将tips设置到鼠标所在位置
function SkillPanel:set_to_mouse_pos(player)
    if player.skill_hover.skill and player.lord and not player.lord:is_destroyed() then
        player.skill_hover.skill:disable()
    end
    if player == local_player then
        ui:set_visible('SkillPanel.LordSkill.skill_drop',false)
        ui:set_position('SkillPanel.LordSkill.skill_drop',ui_point['skill_drop'])
        if not player.skill_hover.lightning then
            lightning_start(player)
        else
            player.skill_hover.lightning:set({
                target = player:get_mouse_pos(),
                height = 100,
                point_type = 'start'
            })
            local _p,_h = camera_point_get(player)
            player.skill_hover.lightning:set({
                target = _p,
                height = _h,
                point_type = 'end'
            })
        end
    end
end
up.game:event('Mouse-Move',function (_,player)
    if player.skill_hover.on == true then
        SkillPanel:set_to_mouse_pos(player)
    end
    if player ~= local_player then
        return
    end
end)

up.game:event('UI-Event', function(self, player,event)
    for i = 1,3 do
        if event == SkillPanel['skill_move_in'..i] then
            if player.skill_hover.on == true then
                return
            end
            local solt = player.skill_slot_now[i]
            if not solt then return end
			
            local skill = up.actor_skill(player.lord._base:api_get_ability(2,solt))
			if not skill then return end

            if player['skill_charge_'..solt] > 0 and player.can_cast == true then
                if round.is_battle == true then
                    LeftDown_skill_off(player)
                    player.skill_hover = {}
                    if player.skill_hover.wait_time then player.skill_hover.wait_time:remove() end
                    player.skill_hover.on = false
                    player.skill_hover.skill = skill
                    if player.skill_hover.LeftDown then player.skill_hover.LeftDown:remove() end
                    player.skill_hover.LeftDown = up.game:event('Mouse-LeftDown',function (self,_player)
                        if _player ~= player then return end
                        self:remove()
                        LeftDown_skill_off(player)
                        LeftDown_skill(player,player.skill_hover.skill)
                        player.skill_hover.wait_time = up.wait(0.1,function ()
                            player.skill_hover.on = true
                        end)
                        if _player ~= local_player then return end
                        show_type_change('down')
                        ui:set_visible('SkillPanel.close_skill',true)
                    end)
                end
            end
            if player.skill_hover_id and player.skill_hover_id ~= i then
                if player == local_player then
                    --ui:set_visible('SkillPanel.skill_..'..player.skill_hover_id..'.select',false)
                    ui:set_position('SkillPanel.LordSkill.SkillSlot.skill_'..player.skill_hover_id,ui_point['skill_'..player.skill_hover_id][l_data['show_type']])
                end
            end
            player.skill_hover_id = i
            if player ~= local_player then return end
            --ui:set_visible('SkillPanel.skill_..'..i..'.select',true)
            if round.is_battle ~= true then
                ui:set_position('SkillPanel.LordSkill.SkillSlot.skill_'..i,ui_point['skill_'..i]['down_select'])
            else
                ui:set_position('SkillPanel.LordSkill.SkillSlot.skill_'..i,ui_point['skill_'..i][l_data['show_type']..'_select'])
            end
            SkillPanel:bind_skill_ui('skill_drop',skill)
            ui:set_scale('SkillPanel.LordSkill.skill_drop',1)
            ui:set_position('SkillPanel.LordSkill.skill_drop',ui_point['skill_drop'])
            ui:set_visible('SkillPanel.LordSkill.skill_drop',true)
            return
        end
        if event == SkillPanel['skill_move_out'..i] then
            if player.skill_hover.on == true then
                return
            end
            if player.skill_hover_id then
                local _id = player.skill_hover_id
                if _id == i then
                    player.skill_hover_id = nil
                end
                if player.skill_hover.LeftDown then
                    player.skill_hover.LeftDown:remove()
                end
                if player ~= local_player then return end
                if round.is_battle ~= true then
                    ui:set_position('SkillPanel.LordSkill.SkillSlot.skill_'..i,ui_point['skill_'..i]['down'])
                else
                    ui:set_position('SkillPanel.LordSkill.SkillSlot.skill_'..i,ui_point['skill_'..i][l_data['show_type']])
                end
                --ui:set_visible('SkillPanel.skill_..'.._id..'.select',false)
                if not player.skill_hover_id then
                    ui:set_visible('SkillPanel.LordSkill.skill_drop',false)
                end
            end
            return
        end
    end
    if event == SkillPanel['close_skill_move_in'] then
        player.skill_hover.close = true
        if player.skill_hover.skill and player.lord and not player.lord:is_destroyed() then
            player.skill_hover.skill:enable()
        end
        if player ~= local_player then return end
        lightning_stop(player)
        return
    end
    if event == SkillPanel['close_skill_move_out'] then
        player.skill_hover.close = false
        if player.skill_hover.on == true then
            if player.skill_hover.skill and player.lord and not player.lord:is_destroyed() then
                player.skill_hover.skill:disable() 
            end
            if player ~= local_player then return end
            lightning_start(player)
        end
        return
    end
    if player ~= local_player then return end
    if event == SkillPanel['skill_show_type_click'] then
        show_type_change()
        return
    end
end)

up.game:event('战斗流程-收起魔法卡',function (_)
    if local_player.discard or (GameMode ~= 'Lord' and GameMode ~= 'Custom') or local_player.is_watching then
        return
    end
    show_type_change('refresh')
    ui:set_visible('SkillPanel.LordSkill.show',true)
    ui:set_visible('SkillPanel.LordSkill',true)
end)
---发牌时刷新ui及锁定
up.game:event('回合流程-发牌',function (_)
    SkillPanel:bind_lord_skill()
    for j=1,PLAYER_MAX do
        local player = up.player(j)
        if player:is_playing() then
            LeftDown_skill_off(player)
        end
    end
    if local_player.discard or (GameMode ~= 'Lord' and GameMode ~= 'Custom') or local_player.is_watching then
        return
    end
    show_type_change('down')
    ui:set_visible('SkillPanel.LordSkill.show',false)
    ui:set_visible('SkillPanel.LordSkill',true)
end)
up.game:event('回合流程-战斗',function ()
    if local_player.discard or (GameMode ~= 'Lord' and GameMode ~= 'Custom') or local_player.is_watching then
        return
    end
    ui:set_visible('SkillPanel.LordSkill',false)
end)
---胜利隐藏技能
up.game:event('回合流程-隐藏技能',function (_,player)
    LeftDown_skill_off(player)
    if player == local_player then
        ui:set_visible('SkillPanel.LordSkill',false)
    end
end)
up.game:event('回合流程-战斗败北',function (_,player)
    LeftDown_skill_off(player)
    if player == local_player then
        ui:set_visible('SkillPanel.LordSkill',false)
    end
end)

---vx事件事件柄
up.game:event('VX-Event', function(self,event,ui_comp,vx_id)

end)
local skill_strat_cast = function(player,i)
    local solt = player.skill_slot_now[i]
    if not solt then return end
    local skill = up.actor_skill(player.lord._base:api_get_ability(2,solt))
    if player['skill_charge_'..solt] <= 0 or player.can_cast == false then
        return
    end
    if skill then
        if player.skill_hover.LeftDown then
            player.skill_hover.LeftDown:remove()
        end
        LeftDown_skill_off(player)
        player.skill_hover = {}
        player.skill_hover.on = true
        player.skill_hover.skill = skill
        LeftDown_skill(player,skill)
        if player.skill_hover.skill and player.lord and not player.lord:is_destroyed() then
            player.skill_hover.skill:disable() 
        end
        if player ~= local_player then return end
        --ui:set_visible('SkillPanel.skill_..'..i..'.select',false)
        ui:set_position('SkillPanel.LordSkill.SkillSlot.skill_'..i,ui_point['skill_'..i][l_data['show_type']])
        ui:set_visible('SkillPanel.LordSkill.skill_drop',false)
        show_type_change('down')
        ui:set_visible('SkillPanel.close_skill',true)
        if not player.skill_hover.lightning then
            lightning_start(player)
        else
            player.skill_hover.lightning:set({
                target = player:get_mouse_pos(),
                height = 100,
                point_type = 'start'
            })
            local _p,_h = camera_point_get(player)
            player.skill_hover.lightning:set({
                target = _p,
                height = _h,
                point_type = 'end'
            })
        end
    end
end
up.game:event('Keyboard-Down',function(_,player,key)
    if not player then return end
    if round.is_battle == true then
        if key == KEY['1'] then
            local solt = player.skill_slot_now[1]
            if not solt then return end
            if player['skill_charge_'..solt] > 0 and player.can_cast == true then
                skill_strat_cast(player,1)
            end
            return
        end
        if key == KEY['2'] then
            local solt = player.skill_slot_now[2]
            if not solt then return end
            if player['skill_charge_'..solt] > 0 and player.can_cast == true then
                skill_strat_cast(player,2)
            end
            return
        end
        if key == KEY['3'] then
            local solt = player.skill_slot_now[3]
            if not solt then return end
            if player['skill_charge_'..solt] > 0 and player.can_cast == true then
                skill_strat_cast(player,3)
            end
            return
        end
		if key == KEY['ESC'] then
			LeftDown_skill_off(player)
		end
    end
end)
SkillPanel:init_skill_panel_ui_event()

return SkillPanel