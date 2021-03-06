#Project Euler Problem 182

using Dates

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
    @show "sieve 1"
    return [i for i=2:φ - 1 if numbers[i]]
end

function public_key(p, q)
    φ = (p - 1) * (q - 1)
    (e for e = 2:φ - 1 if gcd(e, φ) == 1)
end

function china(p::T, q::T, s) where {T<:Integer}
    de = Dict()
    for e in s
        #setprecision(1000) do
            ep = mod(T(e), p - one(T))
            eq = mod(T(e), q - one(T))

            de[e] = (ep, eq)
        #end
    end
    q_inv = invmod(q, p)

    return de, q_inv
end

function is_unconcealed_gen(p::T, q::T, s) where {T<:Integer}
    d, q_inv = china(p, q, s)
    function f(e::T, m::T) where {T<:Integer}
        ep, eq = d[e]
        #setprecision(1000) do

        m2 = mod(m^eq, q)
        # if q_inv == 0 && m2 == m
        #     return true
        # end
        m1 = mod(m^ep, p)

        h = mod(q_inv * (m1 - m2), p)
        return m2 + h * q == m
        #end
    end
end    

function count_unconcealed(p, q)
    k = Dict()
    @show "china"
    n = p * q
    @show n
    min_k = 100
    step = 1000
    count = step - 1
    s = sieve(p, q)
    #is_unconcealed2(e, m) = mod(BigInt(m)^BigInt(e), BigInt(n)) == BigInt(m)
    #is_unconcealed(e, m) = mod(m^e, n) == m
    #is_unconcealed = is_unconcealed_gen(BigInt(p), BigInt(q), s)
    is_unconcealed = is_unconcealed_gen(p, q, s)
    for e in s
        #@show e, min_k
        k[e] = 0
        for m = 0 : n - 1
            #if is_unconcealed(e, e) #is_unconcealed(BigInt(e), BigInt(m))
            if is_unconcealed(BigInt(e), BigInt(m))
                k[e] += 1
                if k[e] > min_k
                    break
                end
            end
        end
        #@show e, k[e]
        if k[e] < min_k
            min_k = k[e]
        end
        count +=1
        if count == step
            @show e, min_k, Dates.now()
            count = 0
        end
    end
    return k, min_k
end

sum_count_minimums(v, mv) = sum(k for k in v if k == mv)


p, q = 19, 37
#p, q = 1009, 3643

function problem182(p, q)
    #china(p, q)
    k, min_k = count_unconcealed(p, q)
    #
    # @show values(k)
    # #mink = minimum(values(k))
    #@show min_k
    #@show k
    @show "sum = ",sum_count_minimums(values(k), min_k)
end

ctime = @elapsed problem182(p, q)

@show "problem182 elapsed time ", ctime
