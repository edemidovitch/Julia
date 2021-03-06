let
   local x = 1
   let
      local x = 2
   end
   @show x
end

let
   x = 3
   let
      x = 4
   end
   @show x
end

x=5
begin
   x+=1
   @show x
end

a=5
let
   global a
   a+=1
   @show a
end
@show a

@show "--- "
a=2
for i in 1:4
   @show i+a
end
