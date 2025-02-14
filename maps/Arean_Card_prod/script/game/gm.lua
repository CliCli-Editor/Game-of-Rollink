local round = require 'game.round'
local ui = require 'ui.local'

local gm = {
    ['win'] = function (player)
        round.player = {up.player(1)}
        for pid = 2,PLAYER_MAX do
            local player = up.player(pid)
            player:set(GOLD,0)
        end
        round.over()
    end,
    ['kill'] = function(player)
        print('人数',PLAYER_MAX)
        for _, v in ipairs(round.all_unit) do
            if v:get_owner() ~= player then
                v:kill()
            end
        end
    end,
    ['guide'] = function(player)
        player._base:set_save_data_int_value(9,0)
        player:save_archive()
        print("----------------------------------------存档恢复初始："..player._base:get_save_data_int_value(9).."--------------------------------------")
    end,
    ---技能替换 gm命令3个
    ['skill'] = function (player,value)
        value = value or 1

        local solt = 20
        local skill = up.actor_skill(player.lord._base:api_get_ability(2,solt))
        if skill then
            skill:remove()
        end
        
        print("----------------------------------",value,config.SkillPool[value]["Skill_ID"])

        player.lord:add_skill('Common',config.SkillPool[value]["Skill_ID"],20)

        if solt and player.lord._base:api_get_ability(2,solt) then
            local skill = up.actor_skill(player.lord._base:api_get_ability(2,solt))
            print("------------------------------",skill)
            player.skill_slot_now[1] = 20
            player['skill_charge_'..20] = 1
            
            
            local _path = 'SkillPanel.LordSkill.SkillSlot.skill_1'
            local skill_id = skill._base:api_get_ability_id()
            local icon = config.SkillData[skill_id].Card
            ui:set_text(_path..'.skill.name',skill:get_name())
            ui:set_text(_path..'.skill.tips',skill:get_desc())
            ui:set_image(_path..'.skill',icon)
        end

    end,
    ['lordskill'] = function (player,value)
        value = value or 1
        local solt = 20
        local skill = up.actor_skill(player.lord._base:api_get_ability(2,solt))
        if skill then
            skill:remove()
        end
        print("----------------------------------",value,config.LordData[value]["LordSkill_1"])
        player.lord:add_skill('Common',config.LordData[value]["LordSkill_1"],20)
        if solt and player.lord._base:api_get_ability(2,solt) then
            local skill = up.actor_skill(player.lord._base:api_get_ability(2,solt))
            print("------------------------------",skill)
            ui:bind_skill('BattlePanel.LordSkill.SkillSlot.skill_btn_1',skill)
            local skill_id = player.lord._base:api_get_ability(2,solt):api_get_ability_id()
            local charge = 0
            local skilltype = 1

            ui:set_image('BetPanel.main_bg.LordSkill.SkillSlot.skill_btn_1.layout.icon',skill:get_icon())
            ui:set_text('BetPanel.main_bg.LordSkill.SkillSlot.skill_btn_1.UseTimes',charge..'/'..charge)
            ui:set_text('BattlePanel.LordSkill.SkillSlot.skill_btn_1.UseTimes',charge..'/'..charge)
            ui:set_visible('BetPanel.main_bg.LordSkill.SkillSlot.skill_btn_1.UseTimes',true)
            ui:set_visible('BattlePanel.LordSkill.SkillSlot.skill_btn_1',true)
            
        end
    end,
    ['test'] = function (player,value)
        local onoff = true
        if value == 0 then
            onoff = false
        end
        gameapi.send_event_custom(1714020003, gameapi.gen_param_dict({}, "onoff", onoff))
    end,
    ['e1'] = function(player,id)
        print('effect',id)
        up.particle {
            id = id,
            target = BATTLE_POINT:offset(0,config.GlobalConfig.CREATE_CENTER_DISTANCE + config.GlobalConfig.CREATE_OFFSET_DISTANCE),
            scale = 1,
            time = 3,
        }
        up.particle {
            id = id,
            target = BATTLE_POINT:offset(0,config.GlobalConfig.CREATE_CENTER_DISTANCE - config.GlobalConfig.CREATE_OFFSET_DISTANCE),
            scale = 1,
            time = 3,
        }
    end,
    ['e2'] = function(player,id)
        print('effect',id)
        up.particle {
            id = id,
            target = BATTLE_POINT:offset(0,config.GlobalConfig.CREATE_CENTER_DISTANCE),
            scale = 1,
            time = 3,
        }
    end,
    ['show'] = function(player,id)
        for i=1,2 do
            for _,u in ipairs(player.view_soldier_team[i]) do
                u:remove()
            end
            player.view_soldier_team[i] = {}
        end
        if player.show_unit then player.show_unit:remove() end
        if player.show_bazi then player.show_bazi:remove() end
        up.player(1):apply_camera(1000000006,0)
        --gameapi.get_all_role_ids().set_role_mouse_left_click(true)
        player.show_unit = player:create_unit(id,BATTLE_POINT,0)
        player.show_bazi = up.player(2):create_unit(201339863,BATTLE_POINT,0)
    end,
    ['sp'] = function(player)
        player.show_bazi:set_point(player:get_mouse_pos())
    end,
    ['showwin'] = function(player)    
        local skill = player.show_unit:find_skill('Common',player.show_unit:getTypeKv('win','abilityName'))
        if skill then
            player.show_unit:cast(skill)
        end
    end,
    ['new'] = function()
        gameapi.request_new_round()
    end,
    ['q'] = function(player,v)
        local questCanFun = {
            'log_in_1','all_in_1','all_in_2','casual_num_1','casual_num_2','casual_win_num_1','creatures_num_1','earn_gold_1','elite_num_1','kill_num_1',
            'lord_num_1','lord_win_num_1','weed_player_1'
        }
        local c = nil
        if player.quest then
            for k, v1 in pairs(player.quest) do
                print('拥有的任务：'..k..'   任务的数目：'..v1)
                if config.DailyTask[k].type == v then
                    c = k
                end
            end
        end
        if config.DailyTask[v] then
            quest.playerquestset(player,v,5)
        elseif c then
            quest.playerquestset(c,5)
        else
            quest.playerquestset(player,questCanFun[v],5)
        end
    end,
    ['ai'] = function(player,v)
        player:msg('玩家类型:'..player._base:get_role_type())
    end,
    ['g'] = function(player,v)
        if player.gold_show == true then
            player.gold_show = false
        else
            player.gold_show = true
        end
    end,

}

up.game:event('Player-ChatSend',function(_,player,msg)
    if gm[msg] then
        gm[msg](player)
        return
    end
    local start = string.find(msg,' ')
    if not start then return end
    local name = string.sub(msg,1,start-1)

    if gm[name] then
        gm[name](player,tonumber(string.sub(msg,start+1)))
    end
end)
