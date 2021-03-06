#anonymous function

b = begin
@show "do"
end
b

g = (function(p)
@show p
end)("k")
