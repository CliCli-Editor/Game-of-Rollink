local quest = {}
quest.data = config.questdata
--任务判断
--所有传统模式适用
local isJuniorOrSenior = function()
    if GameMode == 'Junior' or GameMode == 'Senior' then
        return true
    else
        return false
    end
end
--除房间模式外适用
local isNotCustom = function()
    if GameMode ~= 'Custom' then
        return true
    else
        return false
    end
end
--	除房间模式外适用
local isLord = function()
    if GameMode == 'Lord' then
        return true
    else
        return false
    end
end


local questCanFun = {
    ['all_in'] = function(player)--all_in-
        return true
    end,
    ['all_in_win'] = function(player)--all_in_win-
        return player.is_allin
    end,
    ['casual_num'] = function(player)--casual_num-进行传统模式局数
        return isJuniorOrSenior()
    end,
    ['casual_win_num'] = function(player)--casual_win_num-传统模式胜利局数
        return isJuniorOrSenior()
    end,
    ['creatures_num'] = function(player)--creatures_num-超级生物次数
        return isNotCustom()
    end,
    ['earn_gold'] = function(player)--earn_gold-获得金币数量
        return true
    end,
    ['elite_num'] = function(player)--elite_num-登场精英兵种次数
        return isNotCustom()
    end,
    ['kill_num'] = function(player)--kill_num-击败敌方单位数量
        return isNotCustom()
    end,
    ['log_in'] = function(player)--log_in-登录游戏
        return true
    end,
    ['lord_num'] = function(player)--lord_num-领主模式局数
        return isLord()
    end,
    ['lord_win_num'] = function(player)--lord_win_num-领主模式胜利局数
        return isLord()
    end,
    ['weed_player'] = function(player)--weed_player-淘汰玩家
        return isLord()
    end,
}
---获得存档内任务
quest.playerquestget = function()
    if IS_TEST then return end
    for pid = 1,PLAYER_MAX do
        local player = up.player(pid)
        if player:is_playing() then
            local quest = player:get_save_data(8,'table')
            --print('获取存档任务=======',quest)
            --print('任务类型',type(quest))
            if type(player.quest) == 'table' then
                for k, v in pairs(player.quest) do
                    --print(k,'=========',v)
                end
            end
            player.quest = quest
        end
    end
end

---判断是否完成任务
quest.playerquestset = function(_player,qtype,cnt)
    --print('进入任务事件',_player,qtype,cnt)
    if _player and _player.quest and type(_player.quest) == 'table' then
        cnt = cnt or 0
        for k, v in pairs(_player.quest) do
            if config.DailyTask[k].type == qtype and questCanFun[qtype](_player) then
                --print('---------任务增加进度',k,cnt)
                _player.quest[k] = _player.quest[k] + cnt
                _player:set_save_data(8,_player.quest,'table')
            end
        end
    end
end

--死亡计算
up.game:event('Unit-Die',function (_,dead,killer)
    if not killer then
        return
    end
    local _player = killer:get_owner()
    quest.playerquestset(_player,'kill_num',1)
end)



return quest