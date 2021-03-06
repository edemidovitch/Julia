a = 0.2
f(x) = a * x^2     # refers to the `a` in the outer scope
r = f(1)               # univariate function
println(r)
using Expectations
#, Distributions

@show d = Exponential(2.0)

f(x) = x^2
@show expectation(f, d);  # E(f(x))

####
