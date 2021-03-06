generatedata(n, gen) = gen.(randn(n)) # uses broadcast for some function `gen`
# direct solution with broadcasting, and small user-defined function
n = 100
f(x) = x^2

x = randn(n)
plot(f.(x), label="x^2")
plot!(x, label="x") # layer on the same plot
