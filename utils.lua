-- Some helpfull utilities...

Utils = {}

function Utils.round(n)
    return (n > 0 and math.floor(n + 0.5) or math.ceil(n - 0.5))
end

function Utils.set(t)
    local result = {}
    for k, v in pairs(t) do
        result[v] = true
    end
    return result
end

function Utils.copy(tbl)
    local result = {}
    for k, v  in pairs(tbl) do
        result[k] = v
    end
    return result
end

return Utils
