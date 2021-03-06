
macro until(condition, block)
    quote
        while true
            $(block)
            if $(condition)
                break
            end
        end
    end |> esc
end

i = 0
@until i == 10 begin
    global i += 1
    println(i)
end

x = 5

@until x < 1 (println(x); global x -= 1)

macro repeat(times, block)
    quote
        n = $(times)
        while true
            global n
            if n == 0
                break
            end
            n -= 1
            $(block)
        end
    end |> esc
end

@repeat 3 (println("repeat n --"))

macro iterate_i(iteratable, block)
    quote
        for i in $(iteratable)
            $(block)
        end
    end |> esc
end

@iterate_i 1:3 (println("x=", i))
