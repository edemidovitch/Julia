#1
x_vals = [1, 2, 3]
y_vals = [1, 1, 1]
@show sum(x * y for (x, y) in zip(x_vals, y_vals))

####
@show count(iseven, 1:99)

####
println("2")
pairs = ((2, 5), (4, 2), (9, 8), (12, 10))

@show count([iseven(a) & iseven(b) for (a,b) in pairs])
#OR
@show  sum(xy -> all(iseven, xy), pairs)

#2
coeff = [1,1,3,2,4,6]
function p1(x, coeff)
    s = 0
    for (i,v) in enumerate(coeff)
        s += v*x^i
    end
    return s
end
@show  p1(1,coeff)
#OR
p(x, coeff) = sum(a * x^(i-1) for (i, a) in enumerate(coeff))
@show   p(1, coeff)


#3
s = "arQIhjH"
upper_case_number(s) = length(intersect(s, uppercase(s)))

@show upper_case_number(s)

#4
function is_subset(seq1, seq2)
    s1 = Set(seq1)
    s2 = Set(seq2)
    return issubset(s1, s2)
end

@show is_subset([1,2,3], [1,2,3,4,5])

#5
function linapprox(f,a,b,n,x)
    #Li(z) = ai + bi(z − xi),
    #ai=yi and bi=yi+1−yi
    step = (b-a)/n
    l = step * n
    r = l + step
    fx = f(l) + (f(r) - f(l))/step * (x -l)

    return fx
end

f(x) = 3 * x + 0.5

@show linapprox(f, 1, 10, 20 , 4.5)
