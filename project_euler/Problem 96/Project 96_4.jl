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
    possibilities :: Union{Set,Nothing}
    variants :: Union{Set,Nothing}
    i :: Int
    j :: Int
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
            sudoku[i, j]=
                (d[i][j] == '0' ? Cell(nothing, Set(collect('1':'9')), Set(), i, j) :
                Cell(d[i][j], Set(), Set(), i, j))
        end
    end

    return sudoku
end


function vbox(sudoku, i,  j)
    box_ranges = [1:3, 4:6, 7:9]
    box_locator = [1,1,1,2,2,2,3,3,3]
    ir, jr = box_ranges[box_locator[i]], box_ranges[box_locator[j]]
    return reshape([sudoku[bi,bj] for bi = collect(box_ranges[box_locator[i]]) for bj = collect(box_ranges[box_locator[j]])], 9)
end

function vbox(sudoku)
    box_ranges = [1:3, 4:6, 7:9]
    return reshape([sudoku[box_ranges[bi], box_ranges[bj]] for bi = 1:3 for bj = 1:3], 9)
end

function iterate!(sudoku, f, v)
    updated = false
    for e in v
        updated =  f(sudoku, v) || updated
    end
    return updated
end

function iterate!(f, v)
    updated = false
    for e in v
        updated =  f(sudoku, v) || updated
    end
    return updated
end

function iterate!(sudoku, f, v, cell)
    updated = false
    for e in v
        if e !== cell
            updated = f(sudoku, v, cell) || updated
        end
    end
    return updated
end

function iterate3!(sudoku, f::Function, cell)
    row = view(sudoku, cell.i, :)
    col = view(sudoku, :, cell.j)
    box = vbox(sudoku, cell.i,  cell.j)
    r = iterate!(sudoku, f, row, cell)
    c = iterate!(sudoku, f, col, cell)
    b = iterate!(sudoku, f, box, cell)

    return r || c || b
end

function iterate3!(sudoku, f::Function)
    updated = false
    for i = 1:9
        row = view(sudoku, i, :)
        updated = f(sudoku, row) || updated
    end
    for j = 1:9
        col = view(sudoku, :, j)
        updated = f(sudoku, col) || updated
    end
    for box in vbox(sudoku)
        updated = f(sudoku, box) || updated
    end

    return updated
end

function iterate3_cleanup_variants!(sudoku, cell::Cell)
    row = view(sudoku, cell.i, :)
    col = view(sudoku, :, cell.j)
    box = vbox(sudoku, cell.i,  cell.j)
    r = cleanup_variants!(sudoku, row)
    c = cleanup_variants!(sudoku, col)
    b = cleanup_variants!(sudoku, box)
    return r || c || b
end

function iterate3_conclusion1!(sudoku, cell::Cell)
    row = view(sudoku, cell.i, :)
    col = view(sudoku, :, cell.j)
    box = vbox(sudoku, cell.i,  cell.j)
    r = conclusion1!(sudoku, row, cell)
    c = conclusion1!(sudoku, col, cell)
    b = conclusion1!(sudoku, box, cell)
    return r || c || b
end

function set_digit!(sudoku, cell :: Cell)
    updated = false
    if isnothing(cell.digit) && length(cell.possibilities) == 1
        cell.digit = first(cell.possibilities)
        cell.possibilities = Set()
        vcheck(sudoku)
        updated = iterate3!(sudoku, conclusion1!, cell) || updated
        return updated
    end
    return updated
end

function conclusion1!(sudoku, v, cell::Cell)
    if isnothing(cell.digit)
        return false
    end
    updated = false
    if !checkpossibilities(sudoku)
        @show "WRONG BEFORE conclusion1"
    end
    for e in v
        if e != cell && isnothing(e.digit)
            if cell.digit in e.possibilities
                delete!(e.possibilities, cell.digit)
                updated = true
                vcheck(sudoku)
                set_digit!(sudoku, e)
                #set_digit!(sudoku, cell::Cell)
            end
        end
    end
    if !checkpossibilities(sudoku)
        @show "WRONG AFTER conclusion1"
    end
    return updated
end

function checkpossibilities(sudoku)
    correct = true
    for c in sudoku
        if isnothing(c.digit) && isempty(c.possibilities)
            #@show "WRONG", c
            correct = false
        end
    end
    return correct
end


function process(sudoku)
    updated = true
    for c in sudoku
        if !isnothing(c.digit)
            iterate3!(sudoku, conclusion1!, c)
        end
    end
    while updated
        updated = false
        for cell in sudoku
            updated = iterate3!(sudoku, conclusion1!, cell)  || updated
        end

        count = 0
        for c in sudoku
            count += 1
            updated = set_digit!(sudoku, c) || updated
        end
        if !updated
            if iterate3!(sudoku, conclusion2!)
                updated = trydigit!(sudoku)
            end
        end

        if !updated
            updated = tryanydigit!(sudoku)
        end
    end
end

function vshow(v)
    for e in v
        @show e
    end
end

function vcheck(sudoku, v)
    correct = true
    for e in v
        digits = Set(e.digit for e in v)
        if length(digits) < 9
            correct = false
        end
    end
    return correct
end
function vcheck(sudoku)
    for e in sudoku
        if isnothing(e.digit) && isempty(e.possibilities)
            @show "vcheck(sudoku) FALSE"
            return false
        end
    end
    return true
end


function  conclusion2!(sudoku, v)
    updated = false
    dp = Dict(d => [e for e in v if d in e.possibilities] for d = '1':'9')
    digits = [d for (d, e) in dp if length(e) == 2]
    if length(digits) == 2
        cells = dp[digits[1]]
        for c in cells
            if  isempty(c.variants)
                c.possibilities = Set(digits)
                c.variants = Set(digits)
                updated = iterate3_cleanup_variants!(sudoku, c)
            end
        end
    end
    return updated
end

function  conclusion3!(sudoku, v)
    updated = false
    dp = Dict(d => [e for e in v if d in e.possibilities] for d = '1':'9')
    digits = [d for (d, e) in dp if length(e) == 3]
    if length(digits) == 3
        cells = dp[digits[1]]
        for c in cells
            if length(c.possibilities) > 3 &&  isempty(c.variants)
                c.possibilities = Set(digits)
                c.variants = Set(digits)
                updated = iterate3!(sudoku, cleanup_variants!)
            end
        end
    end
    return updated
end

function cleanup_variants!(sudoku, v)
    updated = false
    for e in v
        if !isnothing(e.variants) && (e.variants in [ee.variants for ee in v if ee != e])
            for ee in v
                if ee == e
                    continue
                end
                if e.variants != ee.variants && !isempty(intersect(ee.possibilities, e.variants))
                    setdiff!(ee.possibilities, e.variants)
                    updated = true
                    set_digit!(sudoku, ee)
                    #@show "cleanup_variants!(v)"
                end
            end
        end
    end
    return updated
end

function trydigit!(vrows, vcols, vboxes)
    function f(v)
        for r in v
            for e in r
                if isnothing(e.digit) && !isempty(e.variants)
                    e.digit = pop!(e.variants)
                    #iterate3!(vrows,vcols, vboxes, conclusion1!)
                    return true
                end
            end
        end
        @show "trydigit f() false"
        return false
    end
    return f(vrows) || f(vcols) || f(vboxes)
end

function trydigit!(sudoku)
    for e in sudoku
        if isnothing(e.digit) && !isempty(e.variants)
            e.digit = pop!(e.variants)
            iterate3_conclusion1!(sudoku, e)
            return true
        end
        return false
    end
    return false
end

function trydigit!(sudoku, v)
    for e in v
        if isnothing(e.digit) && !isempty(e.variants)
            e.digit = pop!(e.variants)
            e.possibilities = Set()
            iterate3!(sudoku, conclusion1!, e)
            return true
        end
    end
    return false
end

function tryanydigit!(sudoku)
    for e in sudoku
        if isnothing(e.digit)
            e.digit = pop!(e.possibilities)
            e.possibilities = Set()
            return true
        end
    end
    return false
end

function setlast!(sudoku, v)
    updated = false
    digits = [e.digit for e in v if !isnothing(e.digit)]
    cells = filter(e -> !isnothing(e.digit), v)
    if length(digits) == 8
        digit = setdiff(collect('1':'9'), digits)
        cells[1].digit = digit[1]
        cells[1].possibilities = Set()
        updated = true
    end
    return updated
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
            #if sudoku[i,j].digit
                print("i=", i, " j=", j)
                print(sudoku[i,j])
            #end
            print(" ")
        end
        println()
    end
end

function shownothing(sudoku)
    for i=1:9
        for j=1:9
            if isnothing(sudoku[i,j].digit)
                println(i, j, " ", length(sudoku[i,j].possibilities))
            end
        end
        println()
    end
end

function showonlypossibily(sudoku)
    for i=1:9
        for j=1:9
            if length(sudoku[i,j].possibilities) == 1
                println(i, j, " ", sudoku[i,j].digit, " ", sudoku[i,j].possibilities)
                @show i, j, sudoku[i,j].digit, sudoku[i,j].possibilities
            end
        end
        println()
    end
end

function countnothing(sudoku:: Matrix)
    count = 0
    for c in sudoku
        if isnothing(c.digit)  || c.digit == '0'
            count += 1
        end
    end
    return count
end

function countnothing(v::Vector)
    count = 0
    for c in sudoku
        if isnothing(c.digit)  || c.digit == '0'
            count += 1
        end
    end
    return count
end

function vcheck(sudoku)
    correct = true
    for i = 1:9
        row = view(sudoku, i, :)
        digits = [e.digit for e in row]
        if length(digits) < length(Set(digits))
            correct = false
            @show  digits
        end
        col = view(sudoku, :, i)
        digits = [e.digit for e in col]
        if length(digits) < length(Set(digits))
            correct = false
            @show  digits
        end
    end
    return correct
end

function showview(v)
    for e in v
        @show e.digit, e.possibilities, e.variants
    end
end

d = input_text(stext)

for i = 1:50
    sudoku = init(d[i])

    k1 = countnothing(sudoku)
    process(sudoku)
    k2 = countnothing(sudoku)
    @show i, k1, k2
    @show iterate3!(sudoku, vcheck)

end

@show "========================="
