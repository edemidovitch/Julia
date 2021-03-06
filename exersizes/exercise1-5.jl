using LinearAlgebra, Statistics, Compat
b = [1.0 2.0; 3.0 4.0]
@show b - I

#
function f(x)
    return [1 2; 3 4] * x # matrix * column vector
end

val = [1, 2]
y = similar(val)
@show y
@show f(val)

function f!(out, x)
    out .= [1 2; 3 4] * x
end

f!(y, val)
@show y
show_supertypes(Int64)
