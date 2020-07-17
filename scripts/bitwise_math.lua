
local bitwise_math = {}

local function to_bit_table_recursive(x, ...)
    if (x or 0) == 0 then
        return ...
    end
    return to_bit_table_recursive(math.floor(x/2), x%2, ...)
end

local function to_bit_table(x)
    if x == 0 then
        return { 0 }
    end
    return { to_bit_table_recursive(x) }
end

local function makeop(condition)
    local function operation(x, y, ...)
        if not y then
            return x
        end
        x, y = to_bit_table(x), to_bit_table(y)
        local xl, yl = #x, #y
        local t, tl = { }, math.max(xl, yl)
        for i = 0, tl-1 do
            local b1, b2 = x[xl-i], y[yl-i]
            if not (b1 or b2) then
                break
            end
            t[tl-i] = (condition((b1 or 0) ~= 0, (b2 or 0) ~= 0) and 1 or 0)
        end
        return operation(tonumber(table.concat(t), 2), ...)
    end
    return operation
end

bitwise_math.bitwise_and = makeop(function(a, b) return a and b end)
bitwise_math.bitwise_or = makeop(function(a, b) return a or b end)
bitwise_math.bitwise_xor = makeop(function(a, b) return a ~= b end)

function bitwise_math.left_shift(x, bits)
    return math.floor(x) * (2^bits)
end
    
function bitwise_math.right_shift(x, bits)
    return math.floor(math.floor(x) / (2^bits))
end

return bitwise_math