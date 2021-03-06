mutable struct A
x
y
end

mutable struct B
    a::A
end

a = A(1,2)
b = B(a)

@show b.a.x

a.x=5

@show b.a.x

function f(p::B)
    println(p.a)
end

@show f(b)
@show methods(B)
