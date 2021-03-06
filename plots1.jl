using Plots
pyplot()
#gr(fmt=:png); # setting for easier display in jupyter notebooks

# n = 100
# ϵ = randn(n)
# plot(1:n, ϵ)
x = 1:10; y = rand(10, 2)
#plot(x, y, seriestype = :scatter, title = "My Scatter Plot")
# x = [1,5,7,9]; y = x*2
# plot(x, y, seriestype = :scatter, title = "My Scatter Plot")

#plot(d.Month, [d.Tmax, d.Tmin], label=["Tmax","Tmin"])
#plot([1:4], [[1,2,3,5],[4,3,2,2]], label=["Tmax","Tmin"])
# vline([1,2])
f = Plots.font("DejaVu Sans", 10)
plot!([3.5], seriestype="vline", label="")

#annotate!(5, 0, text("\$ \\bar \\delta \$",f, :bottom, :left))
annotate!(7, 0, text("\$\\bar \\gamma \$",f, :top)

plot([1:4], [[1,2,3,5],[4,3,2,2]], title = "Two Lines", label = ["Line 1" "Line 2"], lw = 3)


current()
