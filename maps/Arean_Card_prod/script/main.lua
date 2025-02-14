--py
require 'python'
Python = python

GameAPI = gameapi

GlobalAPI = globalapi
Fix32Vec3 = Fix32Vec3
Fix32 = Fix32
New_global_trigger = new_global_trigger
New_modifier_trigger = new_modifier_trigger
New_item_trigger = new_item_trigger
-- constant --
PLAYER_CAMP_ID = 1 
NEUTRAL_ENEMY_CAMP_ID = 31 
NEUTRAL_FRIEND_CAMP_ID = 32 

SUMMON_UNITS = {}
MAX_SUMMON_NUM = 5
PLAYER_MAX = 4
ALL_PLAYER = GameAPI.get_all_role_ids()
UI_EVENT_LIST = {
    'Follow',
    'Fold',
    'LordSkill',
    'All_in',
    'show_hand_card_btn',
    'result_leave',
    'exit_btn_0',
    'watch_btn',
    'Raise',
    'Auto',
}

for i = 1,PLAYER_MAX do
    table.insert(UI_EVENT_LIST,'select_btn_'..i)
    table.insert(UI_EVENT_LIST,'lord_skill_in_'..i)
    table.insert(UI_EVENT_LIST,'lord_skill_out_'..i)
    table.insert(UI_EVENT_LIST,'commen_skill_out_'..i)
    table.insert(UI_EVENT_LIST,'commen_skill_in_'..i)
end

for i = 1,3 do
    table.insert(UI_EVENT_LIST,'Flop_in_'..i)
    table.insert(UI_EVENT_LIST,'Flop_out_'..i)
    table.insert(UI_EVENT_LIST,'LordSkillIn_'..i)
    table.insert(UI_EVENT_LIST,'LordSkillOut_'..i)
    table.insert(UI_EVENT_LIST,'SkillIn_'..i)
    table.insert(UI_EVENT_LIST,'SkillOut_'..i)
end

for i = 1,5 do
    table.insert(UI_EVENT_LIST,'BetButton'..i)
end

for i = 1,2 do
    table.insert(UI_EVENT_LIST,'HandCard_in_'..i)
    table.insert(UI_EVENT_LIST,'HandCard_out_'..i)
end

require 'up'
require 'config'

--require 'test.test'
---resource block start---
---The resource usage statement should be at the beginning of the script and the comments at the beginning and end of this section cannot be modified!!!  xxx_id refer to maps/offical_expr_data/trigger_related_xxx.json

local setmetatable = setmetatable

--up.print('lua','init success')

-- up.game:event('Game-Init', function(_, data)
--     up.print('test','init success')
    
-- end)

local test = require 'game.test'
up.game:event('Game-Init',function()
    if config.GlobalConfig.VIEW_SOLDIER then
        test()
    end
end)
if config.GlobalConfig.VIEW_SOLDIER == false then
    require 'game'
    require 'ui'
end

-- require 'random_trigger'
-- require 'ltyj'
-- require 'global_protect'



