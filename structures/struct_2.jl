
function Person(name, age)
    getName() = name
    getAge() = age
    getOlder() = (age += 1)
    () -> (getName; getAge; getOlder)
end

o = Person("bob", 26)
@show o.getName(), o.getOlder(), o.getOlder()
####
struct Foo
    f::Any
    a::Int
end
F = Foo(x -> 2x, 2)
@show F.f(3)
###
function S(b)
    a = 3
    getA() = 5 * b
    getB(c) = a * b * c
    setA(x) = (a = x)
    return () -> (getA; getB; setA)
end

s = S(3)


@show s.getA(), s.getB(2), s.setA(7), s.getB(2)
###
mutable struct Too
    x::Int
    setx::Any
    getx::Any
    function Too(x)
        f = new(x)
        f.setx = (x_) -> (f.x = x_)
        f.getx = () -> f.x
        return f
    end
end

t = Too(5)
@show t.getx(), t.setx(10), t.getx(), t.x
