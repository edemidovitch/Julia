# Repeat an operation n times, e.g.
# @dotimes 100 println("hi")

macro dotimes(n, body)
  quote
    for i = 1:$(esc(n))
      $(esc(body))
    end
  end
end

@dotimes 3 println("dotime")
# Equivalent to @time @dotimes ...

macro dotimed(n, body)
  :(@time @dotimes $(esc(n)) $(esc(body)))
end
@dotimed 3 println("dotimed")


# Stop Julia from complaining about redifined consts/types -
# @defonce type MyType
#   ...
# end
# or
# @defonce const pi = 3.14

macro defonce(typedef::Expr)
  if typedef.head == :type
    name = typedef.args[2]
  elseif typedef.head == :typealias || typedef.head == :abstract
    name = typedef.args[1]
  elseif typedef.head == :const
    name = typedef.args[1].args[1]
  else
    error("@defonce called with $(typedef.head) expression")
  end

  typeof(name) == Expr && (name = name.args[1]) # Type hints

  :(if !isdefined($(Expr(:quote, name)))
      $(esc(typedef))
    end)
end

# Julia's do-while loop, e.g.
# @once_then while x < 0.5
#   x = rand()
# end

macro once_then(expr::Expr)
  @assert expr.head == :while
  esc(quote
    $(expr.args[2]) # body of loop
    $(expr.args[1]) # loop
  end)
end

@once_then while x > 0.2
  x = rand()
  println("once_then ", x)
end

function memoize(f)
  cache = Dict()
  (args...) -> haskey(cache, args) ? cache[args] : (cache[args] = f(args...))
end

# Evaluate expressions at compile time, e.g.
# hard_calculation(n) = (sleep(1); n)
# f(x) = x * @preval hard_calculation(2) # takes 1 second
# f(2) => 4 # instant

macro preval(expr)
  eval(expr)
end

# Speed up anonymous functions 10x
# @dotimed 10^8 (x -> x^2)(rand()) # 3.9 s
# @dotimed 10^8 (@fn x -> x^2)(rand()) # 0.36 s

macro fn(expr::Expr)
  @assert expr.head in (:function, :->)
  name = gensym()
  args = expr.args[1]
  args = typeof(args) == Symbol ? [args] : args.args
  body = expr.args[2]
  @eval $name($(args...)) = $body
  name
end

# A dictionary whose values defaut to 0.
# You can write counter[k] += 1 without
# worrying about whether k has been set.

# @defonce Counter{K, V}
#   dict::Dict{K, V}
# end
# Counter(K::Type = Any, V::Type = Int) = Counter(Dict{K, V}())
# getindex{K, V}(c::Counter{K, V}, k::K) = haskey(c.dict, k) ? c.dict[k] : zero(V)
# setindex!{K, V}(c::Counter{K, V}, v::V, k::K) = c.dict[k] = v
