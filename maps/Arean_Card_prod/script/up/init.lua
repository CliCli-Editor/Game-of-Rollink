up = {}

function up.print(...)
	local str = ''
    local t = {...}
    for i = 1, #t - 1 do
        --str = str .. globalapi.to_str_default(t[i]) .. '    '
        str = str .. tostring(t[i]).. '    '
    end
    --str = str .. globalapi.to_str_default(t[#t])
    str = str .. tostring(t[#t])
    logout(str)
	GameAPI.print_to_dialog(3,str)
end
print = up.print

require 'up.keyboard'
require 'up.constant'
require 'up.game'
require 'up.util'
require 'up.math'
require 'up.point'
require 'up.rect'
require 'up.trigger'
require 'up.event'
require 'up.player'
require 'up.unit'
require 'up.skill'
require 'up.buff'
require 'up.effect'
require 'up.particle'
require 'up.lightning'
require 'up.sound'
require 'up.destructable'
require 'up.item'
require 'up.ui'
require 'up.kv'
require 'up.selector'
require 'up.order'
require 'up.mover'
require 'up.tech'
require 'up.precondition'
require 'up.timer'