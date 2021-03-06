a= [1,3.5,"a",1, (1,3)]


is_int(t)= typeof(t) == Int
@show filter(is_int, a) |> sum
