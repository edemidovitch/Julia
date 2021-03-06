#Problem 96

file_name = "/Users/eugene/Programming/Julia/project_euler/Problem 96/p096_sudoku.txt"
stext = readlines(file_name)
#@show stext

function input_text(stext)
    d = Dict()
    for i = 1:50
        step = 10 * (i - 1)
        d[i] = view(stext,(step + 2):(step + 10))
    end
    return d
end

box_locator = [1,1,1,2,2,2,3,3,3]

function boxset(d)
    bs = [[Set() for j = 1:3] for i = 1:3]
    for i = 1:9
        for j = 1:9
            if d[i][j] != '0'
                push!(bs[box_locator[i]][box_locator[j]], d[i][j])
            end
        end
    end
    return bs
end


function the_end(a)
    for i=1:9
        if length(a[i]) < 9
            return false
        end
    end
    return true
end

function solver(ds)
    d = [collect(r) for r in ds]
    @show d
    chars = "123456789"
    hs = [Set(c for c in d[i] if c != '0') for i = 1:9]
    vs = [Set(d[i][j] for i = 1:9 if d[i][j] != '0') for j = 1:9]
    bs = boxset(d)
    while !the_end(hs)
        for i = 1:9
            for j = 1:9
                if d[i][j] == '0'
                    s = Set()
                    for ch in chars
                        if !(ch in hs[i]) &&
                           !(ch in vs[j]) &&
                           !(ch in bs[box_locator[i]][box_locator[j]])
                            push!(s, ch)
                        end
                    end
                    if length(s) == 1
                        ch = first(s)
                        d[i][j] = ch
                        push!(hs[i], ch)
                        push!(vs[j], ch)
                        push!(bs[box_locator[i]][box_locator[j]], ch)
                    end
                end
            end
        end
    end
    return d
end

d = input_text(stext)

#for i = 1:50
i=3
    @show i, solver(d[i])
#end
#@show d[1]
# @show horset(d[1])
# @show vertset(d[1])

#@show boxset(d[1])
