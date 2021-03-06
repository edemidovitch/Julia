struct NaiveModel
    f::Function
end

m1 = NaiveModel(x -> 2x)
@show m1.f(10)


(m::NaiveModel)(x) = m.f(x)
@show m1(10)


struct Model{F}
    f::F
end

(m::Model)(x) = m.f(x)
m2 = Model(x->2x)
@show m2(10)
#######
function make_function(ex::Expr)
    return :(x -> $ex)
end

ex = :(2x);
@show make_function(ex)

function make_model(ex::Expr)
    return :(Model($ex))
end

@show make_function(:(2x))
#######

macro model(ex)
    @show ex
    @show typeof(ex)
    return nothing
end

m4 = @model 2x
@show ex
@show m4

macro model(ex)
    return make_model(make_function(ex))
end
m5 = @model 2x
@show m5(10)

#using Models2


macro model_esc(ex)
    return make_model(make_function(esc(ex)))
end

a = 2;
#m8 = @model_esc 2*a*x
m8 = @model_esc 2x
@show m8(10)
