#Problem 59
using Combinatorics

# function code_decode(s::String, key::String, shift = 0)
#     d = [Char(Int(c)⊻Int(key[mod(i + shift, 3) + 1])) for (i, c) in enumerate(s)]
#     return join(d)
# end

function code_decode(s::Vector{Int}, key::Vector{Int})
    d = [Char(c ⊻ key[mod(i, length(key)) + 1]) for (i, c) in enumerate(s)]
    return join(d)
end

# c = code_decode("ASDF", "qwe",1)
#
#
# d = code_decode(c, "qwe", 1)
# @show d


c_text = open(f->read(f, String),
 "/Users/eugene/Programming/Julia/project_euler/Problem_59/p059_cipher.txt")

in_text_int = [parse(Int, ss) for ss in split(c_text, ",")]
in_text_str = [ss for ss in split(c_text, ",")]

code_decode(in_text_int, [25])


# for c in collect('a':'z')
#     @show c, Int(c)
# end

#@show in_text_int[1] ⊻ Int('a')



function good_key(c_text, key)
    for c in c_text
        if !(c ⊻ Int(key) in collect(32:126))
            return false
        end
    end
    return true
end

#@show good_key([21,45], 'a')

function good_key_set(c_text)
    keys = Set()
    for key in collect('a':'z')
        if good_key(c_text, key)
            push!(keys, key)
        end
    end
    return keys
end

c_text_part(n) = [e for (i,e) in enumerate(in_text_int) if mod(i,3) == n]


# keys1 = good_key_set(c_text_part(1))
# keys2 = good_key_set(c_text_part(2))
# keys3 = good_key_set(c_text_part(3))
#
# @show keys1
# @show keys2
# @show keys3

#@show collect(permutations(['n', 'f', 'w', 'd'], 2))

key_words = [" a ", " the ", " is ", " have ", " and ", " to ", " at ", " do ", " will ", " were "]


function decode_numbers(s::Vector{Int}, key::Vector{Int})
    d = [Char(c ⊻ key[mod(i - 1, length(key)) + 1]) for (i, c) in enumerate(s)]
    return join(d)
end

function check_codes(in_text_int)
    d = Dict()
    for key in collect(permutations(collect('a':'z'), 3))
        key_number = [Int(k) for k in key]
        text = decode_numbers(in_text_int, key_number)
        #@show text
        s = 0
        for w in key_words
            s += length(collect(eachmatch(Regex(w), text)))
        end
        if s > 0
            d[key] = s
        end
    end
    return d
end

d = check_codes(in_text_int)
@show "-----"
mkey = maximum([(value, key) for (key, value) in d])
@show mkey
key = [Int(c) for c in ['e', 'x', 'p']]
@show decode_numbers(in_text_int, key)
#t = [36, 22, 80, 0, 0, 4, 23, 25, 19, 17, 88, 4, 4, 19, 21, 11, 88, 22, 23, 23, 29]
#@show check_codes(t)
#@show in_text_int

#s = [36, 22, 80, 0, 0, 4, 23, 25, 19, 17, 88, 4, 4, 19]

#@show decode_numbers([55, 39, 66, 73, 47, 55], [12,12,15])
