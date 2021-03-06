s = ["aa", 5]

function f(s::String)
  println("it's a String")
end

function f(i::Integer)
  println("it's an Integer")
end

for t in s
    f(t)
end

for all in s
  println("ll")
end

struct S1
  a::Integer
  name::String
end

function fs(s::S1)
  @show s
end

s = S1(1, "aa")
fs(s)

struct S2
  a::Integer
  name::String
  w::Integer
end

function fs(s::S2)
  println(s.w)
  @show s
end
s2 = S2(1, "aa", 23)
fs(s2)

struct S3<: S2
  c3::Integer
end

s3 = S3(1, "aa", 23, 12)
@show s3
