using Flux

f(x) = 3x^2 + 2x + 1;

df(x) = gradient(f, x)[1]; # df/dx = 6x + 2

@show df(2)


d2f(x) = gradient(df, x)[1]; # d²f/dx² = 6

@show d2f(2)
