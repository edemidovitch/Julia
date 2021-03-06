#Project Euler Problem 182

function public_key(p, q)
    φ = (p - 1) * (q - 1)
    (e for e = 2:φ - 1 if gcd(e, φ) == 1)
end

function count_unconcealed(p, q)
    k = Dict()
    n = p * q
    pk = public_key(p, q)
    for e in pk
        k[e] = 0
        for m = 0:n - 1
            if powermod(m, e, n) == m
                k[e] += 1
            end
        end
    end
    return k
end

sum_count_minimums(d, mv) = sum(k for (k, v) in d if v == mv)

p, q = 19, 37
#p, q = 1009, 3643

function problem182(p, q)
    k = count_unconcealed(p, q)

    #@show values(k)
    mink = minimum(values(k))
    #@show mink
    @show sum_count_minimums(k, mink)
end

ctime = @elapsed problem182(p, q)

@show "problem182 elapsed time ", ctime
