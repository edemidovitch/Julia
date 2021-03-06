module Models2

export Model, @model

struct Model{F}
    f::F
end

(m::Model)(x) = m.f(x)

function make_function(ex::Expr)
    return :(x -> $ex)
end

function make_model(ex::Expr)
    return :(Model($ex))
end

macro model(ex)
    return make_model(make_function(esc(ex)))
end

end
