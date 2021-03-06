
using Unitful.DefaultSymbols
aslist_direct(x)=[x]
aslist_direct(x::Union{AbstractArray, Tuple}) = x
@show aslist_direct(9)

@show aslist_direct((1,2,3))

p(x) = println(x)
p(x::Int) = println(2*x)
p(x::Real) = println(5*x)

p("llll")
p(3)
p(3.0)
w = 10kg * 15m / 1s^2
@show w
