a = 1
b = 3
ex = :($a + $b)
@show ex
@show eval(ex)
macro twostep(arg)
    println("I execute at parse time.       The argument is: ", arg)
    return :(println("I execute at runtime. The argument is: ", $arg))
end

@twostep "AAA"
ex = macroexpand(Main, :(@twostep :(1, 2, 3)) );
eval(ex)
eval(ex)
