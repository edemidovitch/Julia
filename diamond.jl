abstract type Transport end

mutable struct Car <: Transport
    speed_g::Int
end

mutable struct Boat <: Transport
    speed_w::Int
end

mutable struct Amphibia <: Transport
    speed_g::Int
    speed_w::Int
end

function move(c::Car)
    return c.speed_g
end

function move(c::Boat)
    return c.speed_w
end

function move(c::Amphibia)
    return c.speed_g
end

#t = Vector{Transport}

t = Transport[Car(10), Boat(2), Amphibia(5, 1)]


for i = 1:3
    println(move(t[i]))
end
