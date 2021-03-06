function newton_res(f::Function, df::Function, start_val, tolerance)
    x = start_val
    while abs(f(x)) > tolerance
        x = x - f(x)/df(x)
    end

    return x
end
f(x)=x^2 - 2
g(x) = 2*x
#println(f(0.1))

y = newton_res(f, g, 10, 0.0001)
println(y)
println(f(y))
