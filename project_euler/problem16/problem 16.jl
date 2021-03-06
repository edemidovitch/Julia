#Problem 16
#2^15 = 32768 and the sum of its digits is 3 + 2 + 7 + 6 + 8 = 26.
#What is the sum of the digits of the number 2^1000?

# m1 = mod(15, 4)
# r1 = 15 ÷ 4
#
# digits = Dict()
#
# @show m1, r1
# digits[1] = 2^3
# m2 = mod(12, 4)
# r1 = 12 ÷ 4
# digit[2] = 2^4
#
# r2 = 12
# d = Dict()
# p2 = 15

function digits2(p2)
    s = 0
    d = [2, 4, 8, 7]
    for i = 1:p2
        m = mod(i, 4)
        @show i, m
        s += d[m]
    end
    return s
end

function digits3(power)
    digits = Dict()
    digits[1] = [0, 1]
    for i = 1:power
        key = 1
        while haskey(digits, key)
            # if digits[key][2] == 0
            #     break
            # end
            p = digits[key]
            p2 = p[2] * 2
            if p2 > 9
                digits[key] = [1, mod(p2, 10)]
                if !haskey(digits, key + 1)
                    digits[key + 1] = [0, 0]
                end
            else
                digits[key] = [0, p2]
            end
            if key > 1
                digits[key][2] +=  digits[key - 1][1]
                digits[key - 1][1] = 0
            end
            #@show i, key, digits[key]

            key += 1
        end
    end
    s = 0
    for v in values(digits)
        s += v[2] + v[1]
    end

    return s
end

@show digits3(1000)
