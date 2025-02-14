
local magicCardPool = {}
---根据权重表获取
local weightsgetvalue_one = function (wtable)
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
			return keys[idx]
		end
	end
end
local magicCard = {
    ---初始化魔法卡卡池
    init = function()
        for group_id=1,6 do
            magicCardPool[group_id] = up.table_copy(config.MagicCardData[group_id])
        end
        local wtable = {}
        for k, v in ipairs(config.MagicPool) do
            wtable[k] = v[1]['weight']
        end
        return weightsgetvalue_one(wtable)
    end,

    ---获取魔法卡（需要先初始化魔法卡卡池）
    ---@param group_id_list table 魔法卡池的表，可以放置多个魔法卡group_id
    getCard = function(group_id_list)
        local _group_id_list = {}
        local pool = {}
        for k,group_id in pairs(group_id_list) do
            if k ~= 'weight' and k ~= 'type_id' and k ~= 'group_id' then
                _group_id_list[tonumber(k)] = group_id
            end
        end
        for k,group_id in ipairs(_group_id_list) do
            if magicCardPool[group_id] then
                for _,card in ipairs(magicCardPool[group_id]) do
                    table.insert(pool,card)
                end
            end
        end
        local card = pool[math.random(1,#pool)]
        table.removeValue(magicCardPool[card.id],card)
        return card
    end,

    ---对魔法卡能否生效进行判断
    ---@param card integer 魔法卡ID
    ---@param player player 检索玩家
    ---@param soldier_id integer 队伍ID，仅对pairs为true的魔法卡有意义
    condition = function(card,player,soldier_id)
        local f = {
            ['unit'] = function(equals)
                local unitType_list = up.splitStringByFlag(card.filter,"|")
                for _,unitType in ipairs(unitType_list) do
                    if player.soldier[soldier_id].id == UNIT_ID[unitType] then
                        return equals == true
                    end
                end
                return equals == false
            end,
            ['all_unit'] = function(equals)
                if 
                    player.card[1].id == UNIT_ID[card.filter] and
                    player.card[2].id == UNIT_ID[card.filter]
                then
                    return equals == true
                end
                return equals == false
            end,
            ['all_create_unit'] = function(equals)
                if 
                    player.soldier[1].id == UNIT_ID[card.filter] and
                    player.soldier[2].id == UNIT_ID[card.filter]
                then
                    return equals == true
                end
                return equals == false
            end,
            ['level'] = function(equals)
                local num = up.splitStringByFlag(card.filter,"|")
                for _,n in ipairs(num) do
                    if player.soldier[soldier_id].level == tonumber(n) then
                        return equals == true
                    end
                end
                return equals == false
            end,
            ['all_level'] = function(equals)
                local num = up.splitStringByFlag(card.filter,"|")
                for _,n in ipairs(num) do
                    if 
                        player.soldier[1].level == tonumber(n) and
                        player.soldier[2].level == tonumber(n)
                    then
                        return equals == true
                    end
                end
                return equals == false
            end,
            ['amount'] = function(equals)
                local num = up.splitStringByFlag(card.filter,"|")
                for _,n in ipairs(num) do
                    if player.card[soldier_id].num == tonumber(n) then
                        return equals == true
                    end
                end
                return equals == false
            end,
            ['amount_compare'] = function(equals)
                if player.card[1].num == player.card[2].num then
                    return equals == true
                end
                return equals == false
            end,
            ['only_unit_compare'] = function(equals)
                if
                    player.card[1].num ~= player.card[2].num and
                    player.card[1].id == player.card[2].id
                then
                    return equals == true
                end
                return equals == false
            end,
            ['amount_sum'] = function(equals)
                local num = up.splitStringByFlag(card.filter,"|")
                for _,n in ipairs(num) do
                    if player.card[1].num + player.card[2].num == tonumber(n) then
                        return equals == true
                    end
                end
                return equals == false
            end,
            ['优胜劣汰'] = function(equals)
                if
                    player.soldier[1].level ~= player.soldier[2].level and
                    player.soldier[1].level < 3 and
                    player.soldier[2].level < 3
                then
                    return true
                end
                return false
            end,
            ['无条件'] = function(equals)
                return true
            end,
        }
        --print('card condition',card.name,card.condition_arg,card.condition)
        if player.soldier.flag.is_all == false then
            return false
        end
        return f[card.condition_arg](card.condition)
    end,

    ---执行魔法卡的效果
    ---@param card integer 魔法卡ID
    ---@param player player 检索玩家
    ---@param soldier_id integer 队伍ID，仅对pairs为true的魔法卡有意义
    action = function(card,player,soldier_id)
        local f = {
            ['add_attr'] = function()
                local attr_name = up.splitStringByFlag(card.effect_arg_1,"|")
                if card.condition_arg == 'unit' then
                    local unitType_list = up.splitStringByFlag(card.filter,"|")
                    for _,attr in ipairs(attr_name) do
                        for _,unitType in ipairs(unitType_list) do
                            table.insert(player.buff,{
                                id = UNIT_ID[unitType],
                                attr = attr,
                                value = card.effect_arg_3
                            })
                        end
                    end
                elseif card.condition_arg == 'amount' then
                    for _,attr in ipairs(attr_name) do
                        print(card.name,attr)
                        table.insert(player.buff,{
                            id = player.card[soldier_id].id,
                            attr = attr,
                            value = card.effect_arg_3
                        })
                    end
                elseif card.condition_arg == 'level' then
                    local level_list = up.splitStringByFlag(card.filter,"|")
                    for _,attr in ipairs(attr_name) do
                        for _,level in ipairs(level_list) do
                            table.insert(player.buff,{
                                level = level,
                                attr = attr,
                                value = card.effect_arg_3
                            })
                        end
                    end
                else
                    -- for _,attr in ipairs(attr_name) do
                    --     table.insert(player.buff,{
                    --         id = UNIT_ID[unitType],
                    --         attr = attr,
                    --         value = card.effect_arg_3
                    --     })
                    -- end
                end
            end,
            ['优胜劣汰'] = function()
                if player.card[1].level == 2 then
                    player.soldier[2].num = player.soldier[1].num
                else
                    player.soldier[1].num = player.soldier[2].num
                end
            end,
            ['能力出众'] = function()
                if player.card[1].num > player.card[2].num then
                    player.soldier[2].num = 0
                else
                    player.soldier[1].num = 0
                end
            end,
            ['后起之秀'] = function()
                if player.card[1].num > player.card[2].num then
                    player.soldier[1].num = 0
                else
                    player.soldier[2].num = 0
                end
            end,
            ['amount_less'] = function()
                player.soldier[soldier_id].num = 0
            end,
            ['num'] = function()
                if player.soldier[soldier_id].level > 2 then return end
                local num = tonumber(card.effect_arg_2)
                if card.effect_arg_1 == 'set' then
                    player.soldier[soldier_id].num = num
                end
                if card.effect_arg_1 == 'add' then
                    player.soldier[soldier_id].num = player.soldier[soldier_id].num + num
                end
                if card.effect_arg_1 == 'multiply' then
                    player.soldier[soldier_id].num = player.soldier[soldier_id].num * num
                end
            end,
            ['level'] = function()
                if player.soldier[soldier_id].level > 2 then return end
                local num = tonumber(card.effect_arg_2)
                if card.effect_arg_1 == 'set' then
                    player.soldier[soldier_id].level = num
                end
                if card.effect_arg_1 == 'add' then
                    player.soldier[soldier_id].level = player.soldier[soldier_id].level + num
                end
                if player.soldier[soldier_id].level == 1 then
                    player.soldier[soldier_id].id = player.card[soldier_id].id
                end
                if player.soldier[soldier_id].level == 2 then
                    player.soldier[soldier_id].id = config.UnitData[player.card[soldier_id].soldier.card_soldier_type].upgrade
                end
            end,
            ['sacrifice'] = function()      
                if player.soldier.flag.is_sacrifice == false then return end
                player.soldier[soldier_id].num = tonumber(card.effect_arg_2)
                player.soldier[soldier_id].id = config.UnitData[card.effect_arg_1].id
                player.soldier[soldier_id].level = 3
            end,
            ['屠龙者'] = function()
            end,
            ['平衡'] = function()
                local round = require 'game.round'
                round.is_balance = true
            end,
            ['魔法失效'] = function()
                player.soldier.flag.is_all = false
            end,
            ['sacrifice_all'] = function()
                player.soldier[1].num = tonumber(card.effect_arg_2)
                player.soldier[1].id = config.UnitData[card.effect_arg_1].id
                player.soldier[1].level = 3
                player.soldier[2].num = 0
            end,
            ['random_all'] = function()
                player.soldier[soldier_id].num = math.random(1,config.GlobalConfig.CARD_NUM_MAX)
                player.soldier[soldier_id].id = config.SoldierData[math.random(1,#config.SoldierData)].unit_id
            end,
            ['终止献祭'] = function()
                player.soldier.flag.is_sacrifice = false
            end,
        }
        --print('card action',card.name,card.effect_type)
        f[card.effect_type]()
    end,
}

return magicCard