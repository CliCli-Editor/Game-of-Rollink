
up.kv = {
    get_float = function(source,key)
        return gameapi.get_kv_pair_value_float(source._base, key)
    end,
}
