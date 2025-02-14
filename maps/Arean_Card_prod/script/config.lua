--- tableReader: Preload Lua Table from table editor in CliCli
-- @module config
-- @author changoowu

config = {}
--- Fill in the table name in the table editor into the "tables" 
--- Then you can use table editor data by "config.tablename.key" or "config[tablename][key]" at evenywhere.

local function deep_copy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
        copy[deep_copy(orig_key)] = deep_copy(orig_value)
        end
        setmetatable(copy, deep_copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local function checkTable(_table)
    for k,v in pairs (_table) do
        if type(v) == "table" then
            checkTable(v)
        end
        if type(v) == "userdata" then
            _table[k] = v:float()
        end
    end
end


local dialog = ''
local GLOBAL_TABLES = deep_copy(GLOBAL_TABLES)
for table_name,each_table in pairs (GLOBAL_TABLES) do
    config[table_name] = {}
    for k,v in pairs(each_table) do 
        dialog = dialog ..'table_name  '..table_name..'|'..k..'|'..tostring(v)..'\n'
        config[table_name][k] = v
        if type(config[table_name][k]) == 'table' then
            checkTable(config[table_name][k])
        end
        if type(config[table_name][k]) == "userdata" then
            config[table_name][k] = config[table_name][k]:float()
        end
    end
end


return config
