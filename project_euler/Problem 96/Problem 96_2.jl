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
#Problem 96

file_name = "/Users/eugene/Programming/Julia/project_euler/Problem 96/p096_sudoku.txt"
stext = readlines(file_name)
#show stext

function input_text(stext)
    d = Dict()
    for i = 1:50
        step = 10 * (i - 1)
        d[i] = view(stext,(step + 2):(step + 10))
    end
    return d
end

mutable struct Cell
    digit :: Union{Char,Nothing}
    possibilities :: Set
    variants :: Set
end

# sudoku = Matrix{Cell}(undef, 9, 9)
#
# fill!(sudoku, Cell(nothing, Set(collect(1:9))))
#sudoku = Array{Union{Char, Nothing}}(nothing, 3)

function init(ds)
    d = [collect(r) for r in ds]
    sudoku = Matrix{Cell}(undef, 9, 9)
    for i = 1:9
        for j = 1:9
            sudoku[i, j] =
                (d[i][j] == '0' ? Cell(nothing, Set(collect('1':'9')), Set()) :
                Cell(d[i][j], Set(), Set()))
        end
    end
    return sudoku
end

function vbox!(sudoku, i,  j)
    box_ranges = [1:3, 4:6, 7:9]
    ir, jr = box_ranges[i], box_ranges[j]
    return reshape(view(sudoku, ir, jr), 9)
end

function iterate!(v, f)
    updated = false
    for e in v
        updated = updated || f(e)
    end
    return updated
end

function iterate3!(vrows, vcols, vboxes, f)
    updated = false
    updated = updated || iterate!(vrows, f)
    updated = updated || iterate!(vcols, f)
    updated = updated || iterate!(vboxes, f)
    return updated
end

function vshow(v)
    for e in v
        @show e
    end
end

function conclusion1!(v)
    updated = false
    for e in v
        if !isnothing(e.digit)
            for ee in v
                if e != ee && e.digit in ee.possibilities
                    delete!(ee.possibilities, e.digit)
                    updated = true
                end
            end
        end
    end
    return updated
end

function  conclusion2!(v)
    updated = false
    dp = Dict(d => [e for e in v if d in e.possibilities] for d = '1':'9')
    digits = [d for (d, e) in dp if length(e) == 2]
    if length(digits) == 2
        cells = dp[digits[1]]
        for c in cells
            if length(c.possibilities) > 2 || isempty(c.variants)
                c.possibilities = Set(digits)
                c.variants = Set(digits)
                updated = true
            end
        end
    end
    return updated
end

function  conclusion3!(v)
    updated = false
    dp = Dict(d => [e for e in v if d in e.possibilities] for d = '1':'9')
    digits = [d for (d, e) in dp if length(e) == 3]
    if length(digits) == 3
        cells = dp[digits[1]]
        for c in cells
            if length(c.possibilities) > 3
                c.possibilities = Set(digits)
                c.variants = Set(digits)
                updated = true
            end
        end
    end
    return updated
end

function cleanup_variants!(v)
    updated = false
    for e in v
        if !isempty(e.variants) && e.variants in [ee.variants for ee in v if ee != e]
            for ee in v
                if e.variants != ee.variants && !isempty(intersect(ee.possibilities, e.variants))
                    setdiff!(ee.possibilities, e.variants)
                    updated = true
                    #@show "cleanup_variants!(v)"
                end
            end
        end
    end
    return updated
end

function trydigit!(v)
    for r in v
        for e in r
            if isnothing(e.digit) && !isempty(e.variants)
                e.digit = first(e.variants)
                return true
            end
        end
    end
    return false
end

function toupdate!(sudoku)
    updated = false
    for c in sudoku
        if isnothing(c.digit) && length(c.possibilities) == 1
            c.digit = first(c.possibilities)
            c.possibilities = Set()
            updated = true
        end
    end
    return updated
end

function setlast!(v)
    updated = false
    digits = [e.digit for e in v if !isnothing(e.digit)]
    cell = [e for e in v if isnothing(e.digit)]
    if length(digits) == 8
        digit = setdiff(collect('1':'9'), digits)
        cell[1].digit = digit[1]
        updated = true
        #@show "setlast!(v)"
    end
    return updated
end

function process(sudoku, vrows, vcols, vboxes)
    updated = true
    #@show countnothing(sudoku)
    while updated
        updated = iterate3!(vrows,vcols, vboxes, conclusion1!)
        updated = updated ||  toupdate!(sudoku)
        updated = updated ||  iterate3!(vrows,vcols, vboxes, conclusion2!)
        updated = updated ||  toupdate!(sudoku)
        updated = updated ||  iterate3!(vrows,vcols, vboxes, conclusion3!)
        updated = updated ||  toupdate!(sudoku)
        updated = updated ||  iterate3!(vrows,vcols, vboxes, cleanup_variants!)
        updated = updated ||  toupdate!(sudoku)
        updated = updated ||  iterate3!(vrows,vcols, vboxes, setlast!)
        updated = updated ||  toupdate!(sudoku)
        if countnothing(sudoku) == 0
            break
        else
            if !updated
                updated = trydigit!(vrows)
            end
        end
        #@show countnothing(sudoku)
    end
end

function showsudoku(sudoku)
    for i=1:9
        for j=1:9
            if isnothing(sudoku[i,j].digit)
                print('0')
            else
                print(sudoku[i,j].digit)

            end
            print(" ")
        end
        println()
    end
end
function showsudoku2(sudoku)
    @show "sudoku2"
    for i=1:9
        for j=1:9
            if sudoku[i,j].digit == '2'
                print("i=", i, " j=", j)
                print(sudoku[i,j])
            end
            print(" ")
        end
        println()
    end
end

function shownothing(sudoku)
    for i=1:9
        for j=1:9
            if isnothing(sudoku[i,j].digit)
                println(i, j, sudoku[i,j])
            end
        end
        println()
    end
end

function countnothing(sudoku)
    count = 0
    for c in sudoku
        if c.digit == nothing
            count += 1
        end
    end
    return count
end
function showview(v)
    for e in v
        @show e.digit, e.possibilities, e.variants
    end
end

d = input_text(stext)

for i = 1:50
    @show i
    sudoku = init(d[i])
    #showsudoku(sudoku)
    vrows = [view(sudoku, i, :) for i = 1:9]
    vcols = [view(sudoku, :, i) for i = 1:9]
    vboxes = [vbox!(sudoku, bi, bj) for bi = 1:3 for bj = 1:3]
    #@show vboxes[1][1].digit
    #showview(vboxes[1])
    # @show "vrows[4][2].digit = 'R'"
    # vrows[4][2].digit = 'R'
    # @show "vboxes[1][8].digit = 'B'"
    # vboxes[1][8].digit = 'B'
    # showsudoku(sudoku)
    process(sudoku, vrows, vcols, vboxes)
    @show i, countnothing(sudoku)
    #shownothing(sudoku)
    #showsudoku(sudoku)
    #showsudoku2(sudoku)
end
# conclusion1!(sudoku)
# @show countnothing(sudoku)

#@show   view(sudoku, : ,1)
#iterate!([view(sudoku, i, :) for i=1:9], vshow)
#@show box.getrange(1, 1)


# iterate3!(vrows,vcols, vboxes, vshow)
#vshow(vboxes)
# @show countnothing(sudoku)

#vshow(vboxes[1])
#showsudoku(sudoku)
#shownothing(sudoku)
@show "========================="
