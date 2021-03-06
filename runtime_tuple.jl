function A(v)
          k = (:x, :y, :z, :w)
          NamedTuple{k[eachindex(v)]}(v)
       end
#A (generic function with 1 method)

a = A((1,2,3))
@show a
#(x = 1, y = 2, z = 3)

a = A((1,2,3,4))
@show a
#(x = 1, y = 2, z = 3, w = 4)

a = [1,3,5,7]
for i in eachindex(a)
   println(a[i])
end

println([i for i in eachindex(a)])

g(x)=nothing
d(x::Int)=x+5
@show g(6.7)
@show g(6)
