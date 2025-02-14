
---@param player player
---@param id integer
---@param target point|unit
local play_sound = function(player,id,target)
    if tostring(id):sub(1, 1) == '%' then id = tonumber(gameapi.get_text_config(id)) end
    if not player then
        player = gameapi.get_all_role_ids()
    else
        player = player._base
    end
    if target.type == 'point' then
        gameapi.play_3d_sound_for_player(player, id, target._base, Fix32(0.0), 0, 0, true)
    end
    if target.type == 'unit' then
        gameapi.follow_object_play_3d_sound_for_player(player, id, target._base, 0, 0, true)
    end
end

up.play_sound = play_sound