@enum Status begin
  unknown
  wrong
  cow
  bull
end

abstract type Digit end

mutable struct Info
  guess::Array{Int}
  bulls::Int
  cows::Int
end

Position = Union{Int64,Nothing}

mutable struct UnknownDigit <: Digit
  status::Status
  currentposition::Position
  wrong_positions::Array{Position,1}
  UnknownDigit() = new(unknown, nothing, Position[])
end
function UnknownDigit(position)
  d = UnknownDigit()
  push!(d.wrong_positions, position)
  return d
end


mutable struct WrongDigit <: Digit
  status::Status
  currentposition::Position
  WrongDigit(positioin) = new(wrong, positioin)
  WrongDigit() = new(wrong, nothing)
end

mutable struct CowDigit <: Digit
  status::Status
  currentposition::Position
  wrong_positions::Array{Position,1}
  CowDigit() = new(cow, nothing, Position[])
  CowDigit(position) = new(cow, position, Position[])
end

function CowDigit(position, wrong_positions)
  push!(wrong_positions, position)
  d = CowDigit(position)
  d.wrong_positions = wrong_positions
  return d
end


mutable struct BullDigit <: Digit
  status::Status
  bullposition::Int
  BullDigit(position) = new(bull, position)
end

struct Trigger
  source_status::Status
  target::Digit
  target_status::Status
end

function conclusion(
  position,
  old_digit::Int,
  new_digit::Int,
  bull_diff::Int,
  cow_diff::Int,
)
  if bull_diff == 1
    digits[new_digit] = BullDigit(position)
  end
  if bull_diff == -1
    digits[old_digit] = BullDigit(position)
  end

  if cow_diff == 1
    if digits[new_digit].status != bull
      digits[new_digit] = CowDigit(position, digits[new_digit].wrong_positions)
    end
    if digits[old_digit].status != bull
      digits[old_digit] = WrongDigit(position)
    end
  end

  if cow_diff == -1
    digits[old_digit] = CowDigit(position, digits[old_digit].wrong_positions)
    if digits[new_digit].status != bull
      digits[new_digit] = WrongDigit(position)
    end
  end

  if cow_diff == 0 && digits[new_digit].status == cow
    digits[old_digit] = CowDigit(position, digits[old_digit].wrong_positions)
  end

if cow_diff == 0 &&
   (digits[new_digit].status == bull) &&
   (digits[new_digit].bullposition != position)
  digits[old_digit] = CowDigit(position, digits[old_digit].wrong_positions)
end

  if cow_diff == 0 && bull_diff == 0 && digits[new_digit].status == wrong
    digits[old_digit] = WrongDigit(position)
  end

  if cow_diff == 0 && bull_diff == 0 && digits[new_digit].status == unknown
    digits[old_digit] = UnknownDigit(position)
  end
end

function addwrongposition!(d::Digit, currentposition::Int)
  union!(d.wrong_positions, currentposition)
end

# function promote2cow!(digit, position)
#   d = CowDigit(position)
#   push!(d.wrong_positions, d.currentposition)
#   return d
# end


function getcheck(secret)
  function check(guess)
    cows = 0
    bulls = 0
    for i = 1:4
      for j = 1:4
        if secret[i] == guess[j]
          if i == j
            bulls += 1
          else
            cows += 1
          end
        end
      end
    end
    return bulls, cows
  end
  return check
end

digits = Dict{Int,Digit}()

function initdigits()
  for i = 0:9
    digits[i] = UnknownDigit()
  end
  return digits
end

function getPattern()
  bulls1, cows1 = check([0, 1, 2, 3])
  info1 = Info([0, 1, 2, 3], bulls1, cows1)
  if bulls1 + cows1 == 4
    return info1, info1, info1
  end

  bulls2, cows2 = check([4, 5, 6, 7])
  info2 = Info([4, 5, 6, 7], bulls2, cows2)
  if bulls2 + cows2 == 4
    return info2, info2, info2
  end

  if bulls2 + cows2 > bulls1 + cows1
    info1, info2 = info2, info1
  end

  if info2.bulls + info2.cows == 0
    for i = 1:4
      digits[info2.guess[i]] = WrongDigit()
    end
  end

  info3 = Info([8, 9], 0, 4 - bulls1 - cows1 - bulls2 - cows2)
  if info3.cows == 0
    digits[8] = WrongDigit()
    digits[9] = WrongDigit()
  end
  if info3.cows == 2
    digits[8] = CowDigit()
    digits[9] = CowDigit()
  end

  return info1, info2, info3
end

function cows_found()
  cow_digits = Digit[]
  for i = 0:9
    if digits[i].status in [bull, cow]
      push!(cow_digits, digits[i])
    end
  end
  return cow_digits
end

function all_cows_found(guess, cows_count)
  cows_in_guess = intersect(guess, cows_found())
  return length(cows_in_guess) == cows_count
end


function find_cows(info::Info)
  test_digit = 8
  for pos = 1:4
    if digits[info.guess[pos]].status == unknown
      guess = copy(info.guess)
      guess[pos] = test_digit
      bulls, cows = check(guess)
      bull_diff = bulls - info.bulls
      cow_diff = cows - info.cows
      conclusion(pos, info.guess[pos], test_digit, bull_diff, cow_diff)
      if digits[8].status == unknown && digits[9].status in [bull, cow]
          digits[8].status = wrong
      end
      if digits[9].status == unknown && digits[8].status in [bull, cow]
          digits[9].status = wrong
      end
      if digits[9].status == unknown && digits[8].status == wrong
          digits[9].status = cow
      end

      if digits[test_digit].status == unknown
        test_digit = 9
        conclusion(pos, info.guess[pos], test_digit, bull_diff, cow_diff)
      end
      if all_cows_found(guess, cows + bulls)
        println("all_cows_found(guess, cows + bulls)")
        return
      end
    end
  end
end


function process()
  info1, info2, info3 = getPattern()
  find_cows(info1)
  cow_digits = cows_found()
  if length(cow_digits) < 4
    println("find_cows(info2)")
    find_cows(info2)
  end
  return cow_digits
end


# secret = [1, 3, 5, 6]
# check = getcheck(secret)
#
# digits = initdigits()
#
# res = process()
# println(res)

digits_found() = [i for i = 0:9 if digits[i].status in [bull, cow]]


using IterTools
check = getcheck([1,2,3,4])
for s in subsets(0:9, 4)
  secret = s
  println("secret - ",secret)
  global check = getcheck(secret)

  digits = initdigits()

  cow_digits = process()
  #println("bulls:", bulls, "cows:", cows)
  res = [i for i = 0:9 if digits[i].status in [bull, cow]]
  if Set(secret) != Set(res)
    println(secret, "------", res)
    break
  end
  println("res=", res)
end
# for i in subsets(0:9, 4)
#           @show i
#        end
