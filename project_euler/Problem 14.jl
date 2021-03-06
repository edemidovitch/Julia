#Problem 14
#Longest Collatz sequence


# for_even(n) = n÷2
# for_odd(n) = 3n+1
using Memoize

function produce_seq(n::Int64)
    v = [n]
    while n > 1
        if isodd(n)
            n = 3n+1
        else
            n = n÷2
        end
        push!(v, n)
    end
    return v
end

#@show  produce_seq(13)
function count_seq(n::Int64)
    l = 1
    while n > 1
        if isodd(n)
            n = 3n+1
        else
            n = n÷2
        end
        l += 1
    end
    return l
end

function max_seq(start, finish)
    max_length = 5
    n = start
    number = n
    while n > finish
        l = count_seq(n)
        if l > max_length
            max_length = l
            number = n
        end
        n -= 1
    end
    return number, max_length
end

function f1()
    n, m = max_seq(1000000,2)
    @show n, m
end

ctime = @elapsed f1()
@show "f1() elapsed time ", ctime

#@memoize
function collatz_chain_length(n)
    if n == 1
        return 1
    end
    if iseven(n)
        p = n÷2
    else
        p = 3n+1
    end
    return collatz_chain_length(p) + 1
end

function compute()
    #res = (n, maximum(collatz_chain_length(n) for n = 1:1000000))

    res = findmax(map(collatz_chain_length, 1:1000000))
    @show "res2", res
end

ctime = @elapsed compute()
@show "f2() elapsed time ", ctime
