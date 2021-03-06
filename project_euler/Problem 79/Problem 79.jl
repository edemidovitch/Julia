#Problem 79

c_text = open(f->read(f, String),
 "/Users/eugene/Programming/Julia/project_euler/Problem 79/p079_keylog.txt")

 #@show c_text

c_text_str = [ss for ss in split(c_text, "\n")]

#@show c_text_str


# function character_set(c_text_str)
#     c_char_set = Set()
#     for w in c_text_str
#         union!(c_char_set, w)
#     end
#     @show c_char_set
#     @show union(c_text_str)
#     return c_char_set
#
# end

# function compare_char(s String)
#     s[2], s[1] = 1
#     s[3], s[2] = 1
#     s[3], s[1] = 1



function find_order(c_text_str)
    #c_set = character_set(c_text_str)
    c_vect = collect(Set(join(c_text_str)))
    @show c_vect
    c_dic = Dict(c => i for (i, c) in enumerate(c_vect))
    n = length(c_vect)
    relations = Array{Int, 2}
    relations = fill(0, n, n)
    for s in c_text_str
        if s != ""
            relations[c_dic[s[2]], c_dic[s[1]]] = 1
            relations[c_dic[s[3]], c_dic[s[2]]] = 1
            relations[c_dic[s[3]], c_dic[s[1]]] = 1
        end
    end
    #@show relations
    ss = sum(relations, dims = 2)
    @show vec(ss)
    sss = sortperm(vec(ss))
    return [c_vect[i] for i in sss]
end


@show join(find_order(c_text_str))
