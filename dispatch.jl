
struct mystruct{p}
A::Array{Float64,2}
end

p1 = mystruct{1}([1.0 2.0])

@show p1


# f(m::mystruct{p}) where {p==0}
# @show "p==0"
# end

# f(m::mystruct{p}) #where {p>0}
# @show "p>0"
# end
#f(p1)
fn(::Val{true},  n) = "even $n"
fn(::Val{false}, n) = "odd $n"
fn(n) = fn(Val{n%2==0}(), n)
@show fn(11)
