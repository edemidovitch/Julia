using BullsAndCows

for s in subsets(0:9, 4)
  secret = s
  global check = getcheck(secret)

  digits = initdigits()

  bulls, cows = process()
  #println("bulls:", bulls, "cows:", cows)
  res = [i for i = 0:9 if digits[i].status in [bull, cow]]
  if Set(secret) != Set(res)
    println(secret, "------", res)
    exit
  end
  println(res)


end
# for i in subsets(0:9, 4)
#           @show i
#        end
