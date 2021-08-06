#Problem 116
using Memoization

const RED  = 2
const GREEN = 3
const BLUE = 4


@memoize function covers(size, l)
    if l < size
        return 0
    end
    p = l - size + 1
    #@show l, p
    n = p
    for i = 1:n
        p += covers(size, l - size - i + 1)
    end

    return p
end

const NUMBER = 50
@show covers(RED, NUMBER)
@show covers(GREEN, NUMBER)
@show covers(BLUE, NUMBER)
