function adder(x)
    return y->x+y
end

f = adder(5)
@show f(4)

function secret(x)
    r = rand(14:28,1)[1]
    @show r
    return ()->x+r
end

g=secret(3)

@show g()

function ff()
    # function gg()
    #     return 22
    # end
    gg()= 22
    return gg
end


ggg = ff()
@show ggg()
