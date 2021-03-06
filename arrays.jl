a, b = [1,2,3], [4,5,6,7]

c = [a, b]
@show c
@show c[2][1]

#@show cat(1, c[1],c[2])
@show cat(dims=1, c[1],c[2], c[1])
c = [zeros(Int64, 1, 5), zeros(Int64, 1, 6)]
