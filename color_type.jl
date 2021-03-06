abstract type Color end

struct Green <: Color
    Green() = new()
end

struct Blue <: Color
    value :: Int
    Blue() = new(2)
end

struct Car
    model::String
    color::Color
end

a = Array{Color,1}

g = Green()
b = Blue()

pcolor(c::Green) = println("Green....")
pcolor(c::Blue) = println("Blue")

a = [b, b, g, b, g, Green()]

for i in a
    pcolor(i)
end

h = Car("Honda", Blue())
b = Car("BMW", Green())

carcolor(car::Car, color::Color) = pcolor(color)
cars = [h, b, b , Car("BMW", Blue())]

for c in cars
    println("----")
    carcolor(c, c.color)
    pcolor(c.color)
end
