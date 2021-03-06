import JSON

dict2 = Dict()
open("../data/person_json.txt", "r") do f
    global dict2
    dict2=JSON.parse(f)  # parse and transform data
end

@show dict2

jo = JSON.json(dict2)
@show jo

d = JSON.parse(jo)
@show d
