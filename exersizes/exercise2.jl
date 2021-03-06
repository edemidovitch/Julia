function in_circle()
    x=rand()
    y = rand()
    return x^2+y^2 <=1
end

function circle_area(n)
    t=0
    for i in 1:n
        if in_circle()
            t+=1
        end
    end
    return t/n
end

println(circle_area(100))
