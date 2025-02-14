
GOLD = 'official_res_1'
GameMode = 'Custom'
GAME_TYPE = {
    [0] = 'Custom',  -- 0 传统模式
    [1001] = 'Lord',    -- 1 领主模式
    [1002] = 'Junior',  -- 2 传统模式 中
    [1003] = 'Senior',  -- 3 传统模式 高
    [1004] = 'Custom',  -- 4 新手引导
}
IS_TEST = config.GlobalConfig.AI_ENABLE  --测试开关
BATTLE_POINT = up.get_circle_center_point(1000000005)

mode_id = up.get_game_mode_id()
if GAME_TYPE[mode_id] then
    GameMode = GAME_TYPE[mode_id]
end

UNIT_ID = {}
for name,v in pairs(config.UnitData) do
    UNIT_ID[name] = v.id
end

local ui = require 'ui.local'
quest = require 'game.quest'
require 'game.select_lord'
--require 'game.gm'
require 'game.Junior'
require 'game.round'
require 'game.Battle'
require 'game.ViewSoldier'
require 'game.ai'

local function InitPlayerData()
    for pid = 1,PLAYER_MAX do
        local player = up.player(pid)
        gameapi.set_ui_comp_chat_channel(player._base,"68f788d9-ba6b-4b41-915e-8b1cb122e83b",false)
        player.GameGold = 0
        player.GameCrown = 0
        player.WinRound = 0
        player.MaxGold = 0
        player.LordNum = 0
        player.LoseRouond = 0
        player.delete = false
        player.skill_hover = {}
        if IS_TEST then
            player.InitGameGold = config.BetConfig[GameMode][1].Fee
            player.InitGameCrow = 0
            player.is_watching = false
        else
            if player:is_playing() then
                player.InitGameGold = config.BetConfig[GameMode][1].Fee
                player.InitGameCrow = player:get_save_data(3)
                --如果是领主模式，先把钱扣了，最后打完结算再根据排名给奖励
                if GameMode == 'Lord' then
                    --player:set_save_data(1,player:get_save_data(1) - config.BetConfig[GameMode][1].Fee)
                    if player.gold_show == true then
                        player:msg('变化后存档货币:'..player:get_save_data(1)..'此次变化值:'..tostring(-1*config.BetConfig[GameMode][1].Fee))
                    end
                    player:save_archive()
                end
                ---ai判断
                if player._base:get_role_type() ~= 1 then
                    print('AI进入',player)
                    player.is_ai = true
                end

            else
                player.InitGameGold = 0
                player.InitGameCrow = 0
            end
        end
        --print(player,'InitGameGold',player.InitGameGold)
        --print(player,'InitGameCrow',player.InitGameCrow)
    end
end

up.game:event('Game-Init',function()
    --print('==================本局游戏信息==================')
    print('GAME_ID = ',up.get_game_mode_id())
    print('GAMEMode = ',GameMode)
    print('==================本局游戏信息==================')
    -- if GameMode == 'Custom' then
    --     local num = 0
    --     for pid = 1,PLAYER_MAX do
    --         if up.player(pid):is_playing() then
    --             num = num + 1
    --         end
    --     end
    --     if num == 1 then
    --         IS_TEST = true
    --     end
    -- end

    local num = 0
    local player
    for pid = 1,PLAYER_MAX do
        if up.player(pid):is_playing() then
            num = num + 1
            player = up.player(pid)
        end
    end

    if num == 1 then
        IS_TEST = true
        print("添加AI成功")
    end

    InitPlayerData()
    
    if GameMode == 'Lord' or GameMode == 'Custom' then
        require'ui.SkillPanel'
        up.game:event_dispatch('Lord-Init')
    end
    if GameMode == 'Junior' or GameMode == 'Senior' then
        ui:set_visible("setting_Panel.CardGuideBtn",true)
        up.game:event_dispatch('Junior-Init')
    end
    quest.playerquestget()
end)

local base_particle = {
    103183,103184
}
for _, v in pairs(base_particle) do
    GameAPI.preload_effect(v)
end