# gcd e phi == 1,
#                 (gcd (e-1) (p-1)) +1 == 3,
#                 (gcd (e-1) (q-1)) +1 == 3
#                ]

#p, q = 19, 37
p, q = 1009, 3643
function problem182(p, q)
    φ = (p - 1) * (q - 1)
    @show sum(
        e
        for e = 2:φ-1 if gcd(e, φ) == 1 && gcd(e - 1, p - 1) == 2 && gcd(e - 1, q - 1) == 2
    )
end

ctime = @elapsed problem182(p, q)

@show "problem182 elapsed time ", ctime
