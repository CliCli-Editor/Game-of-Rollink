---@diagnostic disable: redundant-parameter
local ui = {}
up.ui = ui
local player = up.get_localplayer()._base

ui.card_num_img = {
    [1] = {
        nml = 131027 ,
        double = 131040,
    },
    [2] = {
        nml = 131028 ,
        double = 131041,
    },
    [3] = {
        nml = 131029 ,
        double = 131042,
    },
    [4] = {
        nml = 131030 ,
        double = 131043,
    },
    [5] = {
        nml = 131031 ,
        double = 131044,
    },
    [6] = {
        nml = 131032 ,
        double = 131045,
    },
    [7] = {
        nml = 131033 ,
        double = 131046,
    },
    [8] = {
        nml = 131034 ,
        double = 131047,
    },
    [9] = {
        nml = 131035 ,
        double = 131048,
    },
    [10] = {
        nml = 131036 ,
        double = 131049,
    },
    [11] = {
        nml = 131037 ,
        double = 131050,
    },
    [12] = {
        nml = 131038 ,
        double = 131051,
    },
    [13] = {
        nml = 131039 ,
        double = 131052,
    },
}

ui.anim_name = {
    Flop1_Show_a = 2,
    Flop2_Show_a = 3,
    Flop3_Show_a = 4,
    Flop1_Show_b = 5,
    Flop2_Show_b = 6,
    Flop3_Show_b = 7,
    Card_Bg_1_in = 8,
    Card_Bg_2_in = 9,
    Card_Bg_3_in = 10,
    Flop1_Show_c= 11,
    Flop2_Show_c= 12,
    Flop3_Show_c= 13,
    Card_Bg_1_out = 14,
    Card_Bg_2_out = 15,
    Card_Bg_3_out = 16,
    InfoBg_1_in = 18,
    InfoBg_2_in = 19,
    InfoBg_3_in = 20,
    HandCard_1_turnover = 23,
    HandCard_2_turnover = 24,
    FlopCard_1_turnover = 22,
    FlopCard_2_turnover = 25,
    FlopCard_3_turnover = 26,
    HandCard_1_shake = 27,
    HandCard_2_shake = 28,
    HandCard_out = 29,
    FlopCard_1_ZoomIn = 30,
    FlopCard_2_ZoomIn = 31,
    FlopCard_3_ZoomIn = 32,
    FlopCard_1_ZoomOut = 33,
    FlopCard_2_ZoomOut = 34,
    FlopCard_3_ZoomOut = 35,
    CardNum1_buff = 36,
    CardNum2_buff = 37,
    CardNum1_buff_2 = 38,
    CardNum2_buff_2 = 39,
    win_rank_title_in = 40,
    lose_rank_title_in = 41,
    win_img_rank_in = 42,
    lose_img_rank_in = 43,
    win_rank_bg_in = 44,
    lose_rank_bg_in = 45,
    win_info_bg_1_in = 46,
    win_round_in = 47,
    lose_info_bg_1_in = 48,
    lose_round_in = 49,
    finish_info_bg_1_in = 50,
    finish_round_in = 51,
    win_info_bg_2_in = 52,
    win_win_round_in = 53,
    lose_info_bg_2_in = 54,
    lose_win_round_in = 55,
    finish_info_bg_2_in = 56,
    finish_win_round_in = 57,
    win_info_bg_3_in = 58,
    win_most_earn_in = 59,
    lose_info_bg_3_in = 60,
    lose_most_earn_in = 61,
    finish_info_bg_3_in =62,
    finish_most_earn_in = 63,
    win_reward_title_in = 64,
    lose_reward_title_in = 65,
    finish_reward_title_in = 66,
    win_gold_reward_in = 67,
    win_score_reward_in = 68,
    lose_gold_reward_in = 69,
    lose_score_reward_in = 70,
    finish_gold_reward_in = 71,
    finish_score_reward_in = 72,
    win_info_in = 73,
    lose_info_in = 74,
    finish_info_in = 75,
    HandCard_battle_out = 76
}

local adapive_text = {}


function ui:show(path)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.show_ui_comp_animation(player,GameAPI.get_comp_by_absolute_path(player,path),'')
    else
        GameAPI.show_ui_comp_animation(player,path,'')
    end
end

function ui:local_text(_local_text_key)
    return gameapi.get_text_config(_local_text_key)
end

function ui:hide(path)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.hide_ui_comp_animation(player,GameAPI.get_comp_by_absolute_path(player,path),'')
    else
        GameAPI.hide_ui_comp_animation(player,path,'')
    end
end

function ui:set_visible(path,switch)
    if switch == true then
        ui:show(path)
    elseif switch == false then
        ui:hide(path)
    end
end

function ui:creat_scene_ui(path,unit,node,dis)
    if not dis then dis = 1000 end
    return gameapi.create_scene_node_on_unit(GameAPI.get_comp_by_absolute_path(player,path), player, unit._base,node, dis)
end

function ui:bind_scene_ui(_scene_node)
    return gameapi.get_ui_comp_in_scene_ui(_scene_node,nil)
end

function ui:get_scene_ui_child(scene_ui,child_name)
    return gameapi.get_comp_by_path(player, scene_ui, child_name)
end

function ui:play_ui_comp_anim(_anim_name,loop,speed)
    if not loop then loop = false end
    if not speed then speed = 1 end
    print('_anim_name',_anim_name)
    gameapi.play_ui_comp_anim(player, ui.anim_name[_anim_name], speed, loop)
end

function ui:vx_event(path,event_name,vx_id,vx_name,frame_num)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        gameapi.register_ui_comp_fx_cb(player,GameAPI.get_comp_by_absolute_path(player,path),vx_id,vx_name,frame_num,event_name)
    else
        gameapi.register_ui_comp_fx_cb(player,path,vx_id,vx_name,frame_num,event_name)
    end
end

function ui:vx_play(_ui,_vx_id,_vx_name)
    if GameAPI.get_comp_by_absolute_path(player,_ui) then
        gameapi.play_ui_comp_fx(player,GameAPI.get_comp_by_absolute_path(player,_ui), _vx_id ,_vx_name)
    else
        gameapi.play_ui_comp_fx(player,_ui, _vx_id ,_vx_name)
    end
end

function ui:set_visible_global(player,path,switch)
    if switch == true then
        GameAPI.show_ui_comp_animation(player._base,GameAPI.get_comp_by_absolute_path(player._base,path),'')
        --print(GameAPI.get_comp_by_absolute_path(player,path))
    elseif switch == false then
        GameAPI.hide_ui_comp_animation(player._base,GameAPI.get_comp_by_absolute_path(player._base,path),'')
    end
end

function ui:set_hotkey(path,key)
    if KEY[key] then key = KEY[key] end
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_btn_short_cut(player,GameAPI.get_comp_by_absolute_path(player,path),key)
    else
        GameAPI.set_btn_short_cut(player,path,key)
    end
end

function ui:set_prefab_ui_visible(flag)
    GameAPI.set_prefab_ui_visible(player,flag)
end

function ui:set_position(path,position)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_pos(player,GameAPI.get_comp_by_absolute_path(player,path),position[1],position[2])
    else
        GameAPI.set_ui_comp_pos(player,path,position[1],position[2])
    end
end

function ui:set_size(path,size)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_size(player,GameAPI.get_comp_by_absolute_path(player,path),size[1],size[2])
    else
        GameAPI.set_ui_comp_size(player,path,size[1],size[2])
    end
end

function ui:set_scale(path,scale)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        if type(scale) == 'table' then
            GameAPI.set_ui_comp_scale(player,GameAPI.get_comp_by_absolute_path(player,path),Fix32(scale[1]),Fix32(scale[2]))
        else
            GameAPI.set_ui_comp_scale(player,GameAPI.get_comp_by_absolute_path(player,path),Fix32(scale),Fix32(scale))
        end
    else
        if type(scale) == 'table' then
            GameAPI.set_ui_comp_scale(player,path,Fix32(scale[1]),Fix32(scale[2]))
        else
            GameAPI.set_ui_comp_scale(player,path,Fix32(scale),Fix32(scale))
        end
    end
end

function ui:active_skill(path,bool)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_skill_btn_action_effect(player, GameAPI.get_comp_by_absolute_path(player,path),bool) 
    else
        GameAPI.set_skill_btn_action_effect(player, path,bool) 
    end
end

function ui:set_z_order(path,z_order)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_z_order(player,GameAPI.get_comp_by_absolute_path(player,path),z_order)
    else
        GameAPI.set_ui_comp_z_order(player,path,z_order)
    end
end

function ui:set_image_press(path,image_id)
    if tostring(image_id):sub(1, 1) == '%' then image_id = tonumber(ui:local_text(image_id)) end
    image_id = tonumber(image_id)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_press_image(player,GameAPI.get_comp_by_absolute_path(player,path),image_id)
    else
        GameAPI.set_ui_comp_press_image(player,path,image_id)
    end
end

function ui:set_image_disable(path,image_id)
    if tostring(image_id):sub(1, 1) == '%' then image_id = tonumber(ui:local_text(image_id)) end
    image_id = tonumber(image_id)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_disabled_image(player,GameAPI.get_comp_by_absolute_path(player,path),image_id)
    else
        GameAPI.set_ui_comp_disabled_image(player,path,image_id)
    end
end

function ui:set_image_hover(path,image_id)
    if tostring(image_id):sub(1, 1) == '%' then image_id = tonumber(ui:local_text(image_id)) end
    image_id = tonumber(image_id)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_suspend_image(player,GameAPI.get_comp_by_absolute_path(player,path),image_id)
    else
        GameAPI.set_ui_comp_suspend_image(player,path,image_id)
    end
end

function ui:set_image(path,image_id)
    if tostring(image_id):sub(1, 1) == '%' then image_id = tonumber(ui:local_text(image_id)) end
    image_id = tonumber(image_id)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_image(player,GameAPI.get_comp_by_absolute_path(player,path),image_id)
    else
        GameAPI.set_ui_comp_image(player,path,image_id)
    end
end

function ui:set_progress(path,max,cur)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_progress_bar_max_value(player,GameAPI.get_comp_by_absolute_path(player,path),max)
        GameAPI.set_progress_bar_current_value(player,GameAPI.get_comp_by_absolute_path(player,path),cur)
    else
        GameAPI.set_progress_bar_max_value(player,path,max)
        GameAPI.set_progress_bar_current_value(player,path,cur)
    end
end


function ui:set_max_value(path,max_value)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_progress_bar_max_value(player,GameAPI.get_comp_by_absolute_path(player,path),max_value)
    else
        GameAPI.set_progress_bar_max_value(player,path,max_value)
    end
end

function ui:set_cur_value(path,current_value)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_progress_bar_current_value(player,GameAPI.get_comp_by_absolute_path(player,path),current_value)
    else
        GameAPI.set_progress_bar_current_value(player,path,current_value)
    end
end


function ui:set_enable(path,enable)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_enable(player,GameAPI.get_comp_by_absolute_path(player,path),enable)
    else
        GameAPI.set_ui_comp_enable(player,path,enable)
    end
end

function ui:set_text(path,txt)
    if path == nil then
        return
    end
    if tostring(txt):sub(1, 1) == '%' then txt = ui:local_text(txt) end

    if GameAPI.get_comp_by_absolute_path(player,path) then
        if not adapive_text[GameAPI.get_comp_by_absolute_path(player,path)] then
            adapive_text[GameAPI.get_comp_by_absolute_path(player,path)] = GameAPI.get_comp_by_absolute_path(player,path)
            gameapi.set_ui_comp_text_adaptive(player,GameAPI.get_comp_by_absolute_path(player,path),true)
        end
        GameAPI.set_ui_comp_text(player,GameAPI.get_comp_by_absolute_path(player,path),tostring(txt))
    else
        if not adapive_text[path] then
            adapive_text[path] = path
            gameapi.set_ui_comp_text_adaptive(player,path,true)
        end
        GameAPI.set_ui_comp_text(player,path,tostring(txt))
    end
end

function ui:set_font_size(path,font_size)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_font_size(player,GameAPI.get_comp_by_absolute_path(player,path),font_size)
    else
        GameAPI.set_ui_comp_font_size(player,path,font_size)
    end
end

function ui:set_font_color(path,r,g,b)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_font_color(player,GameAPI.get_comp_by_absolute_path(player,path),Fix32(r),Fix32(g),Fix32(b),255)
    else
        GameAPI.set_ui_comp_font_color(player,path,Fix32(r),Fix32(g),Fix32(b),255)
    end
end

--设置透明度
function ui:set_opacity(path,opacity)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_opacity(player,GameAPI.get_comp_by_absolute_path(player,path),Fix32(opacity))
    else
        GameAPI.set_ui_comp_opacity(player,path,Fix32(opacity))
    end
end

function ui:unbind_skill(path)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.cancel_bind_skill(player,GameAPI.get_comp_by_absolute_path(player,path))
    else
        GameAPI.cancel_bind_skill(player,path)
    end
end

function ui:get_size(path)
    local size = {}
    if GameAPI.get_comp_by_absolute_path(player,path) then
        size[1] = GameAPI.get_ui_comp_width(gameapi.get_comp_by_absolute_path(player,path))
        size[2] = GameAPI.get_ui_comp_height(gameapi.get_comp_by_absolute_path(player,path))
    else
        size[1] = GameAPI.get_ui_comp_width(path)
        size[2] = GameAPI.get_ui_comp_height(path)
    end
    return size
end



function ui:bind_skill(path,skill)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_skill_on_ui_comp(player,skill._base,GameAPI.get_comp_by_absolute_path(player,path))
    else
        GameAPI.set_skill_on_ui_comp(player,skill._base,path)
    end
end

function ui:bind_buff(path,unit)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_buff_on_ui_comp(player,unit._base,GameAPI.get_comp_by_absolute_path(player,path))
    else
        GameAPI.set_buff_on_ui_comp(player,unit._base,path)
    end
end

function ui:bind_item(path,item)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_skill_on_ui_comp(player,item._base,GameAPI.get_comp_by_absolute_path(player,path))
    else
        GameAPI.set_skill_on_ui_comp(player,item._base,path)
    end
end

function ui:bind_item_tbl(path,unit,slot_type,slot)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_unit_slot(player,GameAPI.get_comp_by_absolute_path(player,path),unit._base,SlotType[slot_type],slot)
    else
        GameAPI.set_ui_comp_unit_slot(player,path,unit._base,SlotType[slot_type],slot)
    end
end

function ui:set_ui_comp_slot(path,slot_type,slot)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_comp_slot(player,GameAPI.get_comp_by_absolute_path(player,path),SlotType[slot_type],slot)
    else
        GameAPI.set_ui_comp_slot(player,path,SlotType[slot_type],slot)
    end
end

function ui:set_model(path,model)
    if tostring(model):sub(1, 1) == '%' then model = tonumber(ui:local_text(model)) end
    model = tonumber(model)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        GameAPI.set_ui_model_id(player,GameAPI.get_comp_by_absolute_path(player,path),model)
    else
        GameAPI.set_ui_model_id(player,path,model)
    end
end

function ui:new_event(path,event_type)
    local new_event_name
    if GameAPI.get_comp_by_absolute_path(player,path) then
        new_event_name = gameapi.create_ui_comp_event(player, GameAPI.get_comp_by_absolute_path(player,path), UIEventType[event_type])
    else
        new_event_name = gameapi.create_ui_comp_event(player, path, UIEventType[event_type])
    end
    up.game:ui_event(new_event_name)
    return new_event_name
end

function ui:register_event(event_name,path,event_type)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        gameapi.create_ui_comp_event_ex(player, GameAPI.get_comp_by_absolute_path(player,path), UIEventType[event_type], event_name)
    else
        gameapi.create_ui_comp_event_ex(player, path, UIEventType[event_type], event_name)
    end
    up.game:ui_event(event_name)
end


function ui:set_ui_to_mouse_pos(path)
    local tips_scale = ui:get_size(path)
    ui:set_position(path,{math.min(1850 - tips_scale[1]/2,math.max(100+ tips_scale[1]/2,(gameapi.get_role_ui_x_per(player):float()*1920 + tips_scale[1]/2))) ,math.min(1050 - tips_scale[1]/2,math.max(20 + tips_scale[2]/2,gameapi.get_role_ui_y_per(player):float()*1080 + tips_scale[2]/2)) })
end

--本地客户端计时器
function ui:wait(timeout,on_timer)
    return gameapi.add_local_timer(timeout,on_timer)
end

function ui:loop(interval,callback)
    return gameapi.add_local_repeat_timer(Fix32(interval),callback)
end

function ui:remove_timer(localtimer)
    --print('is remove',localtimer)
    gameapi.cancel_local_timer(localtimer)
end

function ui:play_3d_sound(id,target)
    if tostring(id):sub(1, 1) == '%' then id = tonumber(gameapi.get_text_config(id)) end
    id = tonumber(id)
    if target.type == 'point' then
        gameapi.play_3d_sound_for_player(player, id, target._base, Fix32(0.0), 0, 0, true)
    end
    if target.type == 'unit' then
        gameapi.follow_object_play_3d_sound_for_player(player, id, target._base, 0, 0, true)
    end
end


function ui:play_2d_sound(id)
    if tostring(id):sub(1, 1) == '%' then id = tonumber(gameapi.get_text_config(id)) end
    id = tonumber(id)
    gameapi.play_sound_for_player(player, id, false, 0, 0)
end

function ui:set_ui_comp_rotation(path,angle)
    if GameAPI.get_comp_by_absolute_path(player,path) then
        path = GameAPI.get_comp_by_absolute_path(player,path)
    end
    gameapi.set_ui_comp_rotation(player,path,Fix32(angle))
end


return ui