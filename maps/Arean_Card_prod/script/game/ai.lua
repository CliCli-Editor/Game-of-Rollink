local round = require('game.round')
local player_num
local betButtonCnt = 5
---根据权重表获取
local active_to_id = {
    ['all_in'] = 1,
    ['raise_'] = 2,
    ['follow'] = 3,
    ['fold'] = 4,
    ['check'] = 5,
}
local id_to_active = {
    'all_in','raise_','follow','fold','check',
}
local weightsgetvalue_one = function (_wtable)
    local wtable = {}
    for key, weight in pairs(_wtable) do
        wtable[active_to_id[key]] = weight
    end
	local keys = {}
	local weights = {}
	for key, weight in ipairs(wtable) do
		table.insert(keys,key)
		table.insert(weights,weight)
	end
	local values = {}
	local total = 0
	for _, weight in ipairs(weights) do
		total = total + weight
		table.insert(values,total)
	end
	local random = math.random(1,total)
	for idx, value in ipairs(values) do
		if random <= value then
			return id_to_active[keys[idx]]
		end
	end
end
local function ai_think(player)
    local add_bet
    if player:get(GOLD) <= round.bet - player.place_bet then
        add_bet = player:get(GOLD)
    else
        add_bet = round.bet - player.place_bet
    end
    local card_sum = player.card[1].num + player.card[2].num
    --河牌的权
    for i = 1,2 do 
        if player.card[i].powerup_times then
            card_sum = card_sum + (player.card[i].num * (player.card[i].powerup_times*0.2))
        end
    end
    --对子的权
    if player.card[1].num == player.card[2].num then
        card_sum = card_sum * 1.3
        if player.card[1].soldier == player.card[2].soldier then
            card_sum = 26
        end
    end
    ---随底池变化越来越谨慎
    local rdm = (add_bet + 1 / player.place_bet) * round.num * 0.01 + 1
    local wtable = {all_in= 0,raise_= 0,follow= 0,fold= 0,check=0}
    if add_bet > 0 then
        ---人多就怂，人少就诈
        if card_sum >=20 * player_num / 6 then
            wtable.all_in = 30
            wtable.raise_ = 50
            wtable.follow = 20 * rdm
        elseif card_sum >=15 * player_num / 6 then
            wtable.all_in = 10
            wtable.raise_ = 60
            wtable.follow = 25
            wtable.fold = 5
        elseif card_sum >=10 * player_num / 6 then
            wtable.all_in = 10
            wtable.raise_ = 30
            wtable.follow = 45
            wtable.fold = 15
        elseif card_sum >=5 * player_num / 6 then
            wtable.all_in = 10
            wtable.raise_ = 10
            wtable.follow = 10
            wtable.fold = 70
        elseif card_sum >=0 * player_num / 6 then
            wtable.raise_ = 10
            wtable.fold = 90
        end
        wtable.fold = wtable.fold * rdm
    else
        if card_sum >=20 * player_num / 6 then
            wtable.all_in = 35
            wtable.raise_ = 55
            wtable.check = 5
        elseif card_sum >=15 * player_num / 6 then
            wtable.all_in = 15
            wtable.raise_ = 65
            wtable.check = 20
        elseif card_sum >=10 * player_num / 6 then
            wtable.all_in = 15
            wtable.raise_ = 35
            wtable.check = 50
        elseif card_sum >=5 * player_num / 6 then
            wtable.all_in = 15
            wtable.raise_ = 15
            wtable.check = 70
        elseif card_sum >=0 * player_num / 6 then
            wtable.raise_ = 15
            wtable.check = 85
        end
        wtable.check =  wtable.check * rdm
    end
    if round.bat == player.place_bet then
        wtable.fold = 0
    end
    --AI下注
    --print("ai下注 新手引导模式 ================================================================ ", gameapi.get_trigger_variable_integer("新手引导模式"))
    if gameapi.get_trigger_variable_integer("新手引导模式") == 1004 then                       --新手引导 ai操作
        if gameapi.get_trigger_variable_integer("新手引导进度") < 24 then
            print("ai check ,存档槽 == ", gameapi.get_trigger_variable_integer("新手引导进度"))
            player.action = 'check'
        elseif gameapi.get_trigger_variable_integer("新手引导进度") > 24 and gameapi.get_trigger_variable_integer("新手引导进度") < 28 then
            print("ai fold ,存档槽 == ", gameapi.get_trigger_variable_integer("新手引导进度"))
            player.action = 'fold'
        elseif gameapi.get_trigger_variable_integer("新手引导进度") > 28 then
            player.action = weightsgetvalue_one(wtable)
        end
    else
        player.action = weightsgetvalue_one(wtable)
    end
    
    if player.action == 'check' then
        return
    end
    if player.action == 'fold' then
        player.add_bet = 0
    elseif player.action == 'follow' then
        player.add_bet = add_bet
    elseif player.action == 'all_in' then
        player.add_bet = player:get(GOLD)
    else
        local i
        if round.betNum[round.raise] > player.place_bet then 
            i = math.random(round.raise,betButtonCnt)
        end
        if i then
            player.action = 'raise_'..i
            player.add_bet = round.betNum[i] - player.place_bet
        else
            return
        end
    end

    if player.add_bet >= player:get(GOLD) then
        player.action = 'all_in'
        player.add_bet = player:get(GOLD)
    end
    if round.round_time then
        player.add_bet = tonumber(string.format('%d',player.add_bet))
        up.game:event_dispatch('回合流程-AI下注', player, player.add_bet, player.action)
        up.game:event_dispatch('回合流程-玩家下注', player, player.add_bet, player.action)
    end
end

-- 回合流程-提示下注 AI_ENABLE
local ai_think_list = {}
up.game:event('回合流程-提示下注', function()
    for _, v in ipairs(round.player) do
        if not ai_think_list[v] then ai_think_list[v] = {roll = 1,think = false,all_in = 0} end
        if round.round_time and not v.is_allin and not v.discard and #round.player > 1 and ((IS_TEST and v._base:get_role_status() ~= 1) or v.is_ai == true) then
            if not ai_think_list[v].think then
                ai_think_list[v].think = true
                local roll = math.random(1,5)
                if roll <= ai_think_list[v].roll then
                    if round.is_allin then
                        ai_think_list[v].all_in = ai_think_list[v].all_in + 1
                        if ai_think_list[v].all_in >= 3 then
                            v.action = 'fold'
                            v.add_bet = 0
                            up.game:event_dispatch('回合流程-AI下注', v, v.add_bet, v.action)
                            up.game:event_dispatch('回合流程-玩家下注', v, v.add_bet, v.action)
                            ai_think_list[v].all_in = 0
                            return
                        end
                    end
                    up.wait(config.GlobalConfig.AI_PET_TIME, function()
                        ai_think(v)
                    end)
                    up.wait(2, function()
                        ai_think_list[v].think = false
                    end)
                    ai_think_list[v].roll = 1
                else
                    ai_think_list[v].roll = ai_think_list[v].roll + 1
                    up.wait(0.5, function()
                        ai_think_list[v].think = false
                    end)
                end
            end
        end
    end
end)

-- 发牌的时候看本局多少人
up.game:event('回合流程-发牌', function(_, player)
    player_num = #round.player
end)