#Project Euler Problem 182

using Dates

function sieve(p, q)
    φ = (p - 1) * (q - 1)
    numbers = Vector{Bool}
    numbers = fill(true, φ - 2)

    for i = 2:φ - 1
        numbers[i - 1] = gcd(i, φ) == 1
    end
    s = [i + 1 for i=1:φ - 2 if numbers[i]]
    return s
end

function public_key(p, q)
    φ = (p - 1) * (q - 1)
    (e for e = 2:φ - 1 if gcd(e, φ) == 1)
end

function china(p::T, q::T, e::T) where {T<:Integer}
    ep = mod(T(e), p - one(T))
    eq = mod(T(e), q - one(T))
    q_inv = invmod(q, p)
    return ep, eq, q_inv
end

function squairing(ep, eq, q_inv, m)
    m1 = mod(m^ep, p)
    m2 = mod(m^eq, q)
    h = mod(q_inv * (m1 - m2), p)
    return m2 + h * q
end


function count_unconcealed(p, q)
    k = Dict()
    #@show "china"
    n = p * q
    @show n
    min_k = 100
    step = 1000
    count = step - 1
    s = sieve(p, q)
    for e in s
        k[e] = 0
    end
    t = [s[i + 1] - s[i] for i = 1:length(s) - 1]
    e1 = s[1]
    #ep, eq, q_inv = china(p, q, s[1])
    for m = 0:n-1
        r = powermod(m, e1, n)
        #r = squairing(ep, eq, q_inv, m)
        if r == m
            k[e1] += 1
        end
        for i = 2:length(s)
            d = t[i - 1]
            r *= m^d
            if r > n
                r = mod(r, n)
            end
            if r == m
                k[s[i]] += 1
            end
        end
        # if k[e] < min_k
        #     min_k = k[e]
        # end
        #
        # #@show e, k[e]
        count += 1
        if count == step
            #@show Dates.now()
            count = 0
        end
    end
    return k, minimum(values(k))
end

sum_count_minimums(d, mv) = sum(k for (k, v) in d if v == mv)

p, q = 19, 37
#p, q = 1009, 3643

function problem182(p, q)
    #china(p, q)
    k, min_k = count_unconcealed(p, q)

    #@show values(k)
    # #mink = minimum(values(k))
    @show min_k
    @show "sum = ",sum_count_minimums(k, min_k)
end

ctime = @elapsed problem182(p, q)

@show "problem182 elapsed time ", ctime

# n = p*q
# @show mod(BigInt(7)^BigInt(181),BigInt(n))
# @show BigInt(7)^BigInt(181) % BigInt(n)
