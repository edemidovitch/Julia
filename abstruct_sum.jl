abstract type A end

struct B <: A
    x
    y
end

struct C <: A
    w
    z
end

prop1(b::B) = b.x
prop2(b::B) = b.y
prop1(c::C) = c.w
prop2(c::C) = c.z  # changed from prop2(c::C)=c.w

mysum(a::A) = prop1(a) + prop2(a)

b = B(5,6)
@show mysum(b)
