#Project Euler Problem 182

function sieve(p, q)
    φ = (p - 1) * (q - 1)
    numbers = Vector{Bool}
    numbers = fill(true, φ)
    for i = 2:φ - 1
        numbers[i] = gcd(i, φ) == 1
        for j = 2:i - 1
            k = i * j
            if k > φ
                break
            end
            numbers[k] = false
        end
    end
    # for i=2:φ - 1
    #     if numbers[i]
    #         @show i
    #     end
    # end
    @show "sieve "
    return (i for i=2:φ - 1 if numbers[i])
end

function public_key(p, q)
    φ = (p - 1) * (q - 1)
    (e for e = 2:φ - 1 if gcd(e, φ) == 1)
end



function is_unconcealed(e::T, n::T, m::T) where {T <: Integer}
    #me mod n=m
    mod(m^BigInt(e), BigInt(n)) == m
end

# for e in public_key(19, 37)
# @show e
# end

function count_unconcealed(p::T, q::T) where {T <: Integer}
    k = Dict()
    n = p * q
    min_k = BigInt(100)
    for e in sieve(p, q)
        #@show e, min_k
        k[e] = zero(T)
        for m = zero(T) : n - one(T)
            if is_unconcealed(e, n, m)
                k[e] += 1
            end
            if k[e] > min_k
                break
            end
        end
        if k[e] < min_k
            min_k = k[e]
        end
        @show e, min_k
    end
    return k, min_k
end

# function sum_count_minimums(v, mv)
#     s = 0
#     for k in v
#         if k == mv
#             s += k
#         end
#     end
#     return s
# end

#sum_count_minimums(v, mv) = sum(k for k in v if k == mv)
sum_count_minimums(v, mv) = sum(k for k in v if k == mv)

p, q = 19, 37
#p, q = 1009, 3643

function problem182(p, q)

    k, min_k = count_unconcealed(p, q)
    #
    # @show values(k)
    # #mink = minimum(values(k))
    @show min_k
    #@show k
    @show sum_count_minimums(values(k), min_k)
end

ctime = @elapsed problem182(p, q)

@show "problem182 elapsed time ", ctime
