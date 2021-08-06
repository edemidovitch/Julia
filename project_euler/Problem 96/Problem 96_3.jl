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

function vcheck(v)
    correct = true
    for e in v
        digits = Set(e.digit for e in v)
        if length(digits) < 9
            correct = false
            @show setdiff(Set(collect('1':'9')), digits)
        end
    end
    return correct
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
            if length(c.possibilities) > 2  &&  isempty(c.variants)
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
            if length(c.possibilities) > 3 &&  isempty(c.variants)
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

function trydigit!(vrows,vcols, vboxes)
    function f(v)
        for r in v
            for e in r
                if isnothing(e.digit) && !isempty(e.variants)
                    e.digit = pop!(e.variants)
                    iterate3!(vrows,vcols, vboxes, conclusion1!)
                    return true
                end
            end
        end
        @show "trydigit f() false"
        return false
    end
    res = f(vrows) || f(vcols) || f(vboxes)
    @show "trydigit", res
    return res
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
                @show "if !updated updated =  ", updated
                updated = trydigit!(vrows,vcols, vboxes)
            end
        end
    end
    #iterate3!(vrows,vcols, vboxes, vcheck)
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
        if isnothing(c.digit)  || c.digit == '0'
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

for i = 6:6
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
    #showsudoku(sudoku)
    process(sudoku, vrows, vcols, vboxes)
    #@show i, countnothing(sudoku)
    showsudoku(sudoku)
    #iterate3!(vrows,vcols, vboxes, vcheck)
    #@show countnothing(sudoku)
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
