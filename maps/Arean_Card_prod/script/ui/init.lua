up.game:event('Game-Init',function()
    require'ui.LordSelectPanel'
    require'ui.BetPanel'
    require'ui.BattlePanel'
    require'ui.ResultPanel'
    require'ui.GuidePanel'
    --GameAPI.set_ui_comp_text_adaptive_min_size(up.get_localplayer()._base,10)
    gameapi.set_window_type(up.get_localplayer()._base, "full_screen")
    --GameAPI.set_render_option("EnableEnvRendering", 0)
    --GameAPI.set_render_option("DynamicShadowDistanceMovableLight", 40)
    --GameAPI.set_render_option("ShadowCameraFrustrumRange", 800)
end)


up.game:event('UI-Event', function(self, player,event)
    if player ~= up.player(GameAPI.get_owner_role_id()) then return end
    if event == 'click_sound' then
        gameapi.play_sound_for_player(up.player(GameAPI.get_owner_role_id())._base, 134255703, false, 0, 0)
        return
    end

    if event == 'move_in_sound' then
        --gameapi.play_sound_for_player(up.player(GameAPI.get_owner_role_id())._base, 134253965, false, 0, 0)
        return
    end
end)