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

Position = Union{Int64,Nothing}
mutable struct Digit1_9
    value :: Char
    hindex :: Position
    vindex :: Position
    bindex :: Union{Tuple{Int64,Int64},Nothing}
end

mutable struct Drow
    digits
    Drow() = digits()
end

mutable struct Dcolumn
    digits
    Dcolumn() = digits()
end


mutable struct Dbox
    digits
    Dbox() = digits()
end
getrowpart(bi, bj, i) = [3 * (bi - 1) + k for k = 1:3 ]
@show getrowpart(2,2, 4)
function box_util()
    box_locator = [1,1,1,2,2,2,3,3,3]
    getbox(i,j) = (box_locator[i], box_locator[j])
    #getrowpart(bi, bj, i) = [3 * (bi - 1) + k, 3*(bj -1)] for k = 1:3 ]
    return () -> (getbox)
end

mutable struct Box
    number::Int
    posi
    function Box(x)
        f = new(x)
        f.digits = [Digit1_9(i, nothing, nothing, nothing ) for i=1:9]
        return f
    end
end




function addDigit(i, j, v)
    addDigit!(drow, i, j, v)
    addDigit!(dcolumn, i, j, v)
    addDigit!(dbox, i, j, v)
end

# function addDigit!(drow, i, j, v)
#     push!(drow.digits, Digit1_9
#function fillDigits()


@show Digit1_9(1, nothing, nothing, nothing)

d50 = input_text(stext)

d1 = d50[1]
@show d1

bu = box_util()
function digits1(d1)
    digits = Set()
    for i = 1:9
        for j = 1:9
            if d1[i][j] != '0'
                d = Digit1_9(d1[i][j], i, j, bu.getbox(i,j))
                push!(digits, d)
            end
        end
    end
    return digits
end

digitset = digits1(d1)
