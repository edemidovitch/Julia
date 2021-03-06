#Problem 15

# n = BigInt(20)
# p = BigInt(2)^((n-BigInt(1))^BigInt(2))
#
# #p = 2^(19^2)
# @show p


using Memoize

@memoize function path(r::Int64, d::Int64)
    s = 0
    @show r, d

    if r > 1
        s += 1
        s += path(r - 1, d)
    end

    if d > 1
         path(r, d - 1)
    end

    return s
end

@memoize function turn(r::Int64, d::Int64)
    s = 0

    for i = 1:r
        for j=i:d
            s += 1
        end
    end

    return s
end

@show turn(2,2)
