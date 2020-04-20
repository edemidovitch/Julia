using IterTools
using Combinatorics
#using Logging


#logger = SimpleLogger(stdout, Logging.Debug)
ENV["JULIA_DEBUG"]="info"
#ENV["JULIA_DEBUG"]="all"

@enum Status begin
  unknown
  wrong
  cow
  bull
end

abstract type Digit end
abstract type GoodDigit <: Digit end

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

function UnknownDigit(position::Position)
  d = UnknownDigit()
  push!(d.wrong_positions, position)
  return d
end

function UnknownDigit(d::UnknownDigit, position::Position)
  push!(d.wrong_positions, position)
  return d
end

mutable struct WrongDigit <: Digit
  status::Status
  currentposition::Position
  WrongDigit(positioin) = new(wrong, positioin)
  WrongDigit() = new(wrong, nothing)
end

mutable struct CowDigit <: GoodDigit
  status::Status
  currentposition::Position
  wrong_positions::Array{Position,1}
  CowDigit() = new(cow, nothing, Position[])
  CowDigit(position::Position) = new(cow, position, Position[])
  #CowDigit(position::Position, wrong_positions::Array{Position}) = new(cow, position, wrong_positions)
end

mutable struct BullDigit <: GoodDigit
  status::Status
  bullposition::Int
  BullDigit(position) = new(bull, position)
end

function CowDigit(position::Position, wrong_positions::Array{Position,1})
  push!(wrong_positions, position)
  d = CowDigit(position)
  d.wrong_positions = wrong_positions
  return d
end

function CowDigit(c::UnknownDigit, position::Position = nothing)
  return CowDigit(position::Position, c.wrong_positions)
end

function CowDigit(c::CowDigit, position::Position = nothing)
  push!(c.wrong_positions, position)
  return c
end

function CowDigit(b::BullDigit, position::Position = nothing)
  return b
end


function WrongDigit(b::UnknownDigit, p::Position = nothing)
  return WrongDigit(p)
end

function WrongDigit(d::Union{BullDigit,WrongDigit}, p::Position = nothing)
  return d
end

# function UnknownDigit(c::CowDigit, position::Position)
#   return CowDigit(c, position)
# end
#
# function UnknownDigit(d::Union{WrongDigit,BullDigit}, p::Position = nothing)
#   return d
# end

struct Trigger
  source_status::Status
  target::Digit
  target_status::Status
end

function conclusion(info::Info, position::Position, test_digit::Int)
  function like_cow(d, position)
    return d.status == cow || ((d.status == bull) && (d.bullposition != position))
  end
  @debug digits
  guess = copy(info.guess)
  old_digit = guess[position]
  new_digit = test_digit
  guess[position] = test_digit
  bulls, cows = check(guess)
  bull_diff = bulls - info.bulls
  cow_diff = cows - info.cows
  if bull_diff == 1
    digits[new_digit] = BullDigit(position)
  end

  if bull_diff == -1
    digits[old_digit] = BullDigit(position)
  end

  if cow_diff == 1
    digits[new_digit] = CowDigit(digits[new_digit], position)
    digits[old_digit] = WrongDigit(digits[old_digit], position)
  end

  if cow_diff == -1
    digits[old_digit] = CowDigit(digits[old_digit], position)
    digits[new_digit] = WrongDigit(digits[new_digit], position)
  end

  if cow_diff == 0 && like_cow(digits[new_digit], position)
    digits[old_digit] = CowDigit(digits[old_digit], position)
  end

  begin
    if cow_diff == 0 && bull_diff == 0 && digits[new_digit].status == wrong
      digits[old_digit] = WrongDigit(digits[old_digit], position)
    end

    if cow_diff == 0 && bull_diff == 0 && digits[new_digit].status in [bull, cow]
      digits[old_digit] = CowDigit(digits[old_digit], position)
    end

    if digits[9].status in [bull, cow] && digits[8].status == unknown
      digits[8] = WrongDigit(digits[8] )
    end
    if digits[8].status in [bull, cow] && digits[9].status == unknown
      digits[9] = WrongDigit(digits[9])
    end
    if digits[9].status == wrong && digits[8].status == unknown
      digits[8] = CowDigit(digits[8])
    end
    if digits[8].status == wrong && digits[9].status == unknown
      digits[9] = CowDigit(digits[9])
    end
  end
  bull_digits, cow_digits = cow2bulls()
  @debug "bulls, cows", bull_digits, cow_digits
  @debug digits
  @assert length(bull_digits) + length(cow_digits) <= 4
  return bulls, cows
end

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
    digits[8] = WrongDigit()
    digits[9] = WrongDigit()
    return info1, info1, info1
  end

  bulls2, cows2 = check([4, 5, 6, 7])
  info2 = Info([4, 5, 6, 7], bulls2, cows2)
  if bulls2 + cows2 == 4
    digits[8] = WrongDigit()
    digits[9] = WrongDigit()
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

cows_found() = [digits[i] for i = 0:9 if digits[i].status in [bull, cow]]

function all_cows_found(guess, cows_count)
  cows_in_guess = intersect(guess, cows_found())
  return length(cows_in_guess) == cows_count
end

function find_cows(info::Info)
  test_digit = 8
  @debug "cow guess", info.guess
  for pos = 1:4
    if digits[info.guess[pos]].status == unknown
      bulls, cows = conclusion(info, pos, test_digit)
      if digits[test_digit].status == unknown
        test_digit = 9
        bulls, cows = conclusion(info, pos, test_digit)
      end
      if all_cows_found(info.guess, cows + bulls)
        return
      end
    end
  end
end


function process_cow()
  info1, info2, info3 = getPattern()
  @debug "digits[8], digits[9]", digits[8], digits[9]
  find_cows(info1)
  cow_digits = cows_found()
  if length(cow_digits) < 4
    find_cows(info2)
  end
  return cow_digits
end

function cow2bulls()
  bull_digits = [key for (key, d) in digits if d.status == bull]
  cow_digits = [key for (key, d) in digits if d.status == cow]
  return bull_digits, cow_digits
end

function update_available_positions(bull_digits, cow_digits)
  bull_positions = [digits[d].bullposition for d in bull_digits]
  for c in cow_digits
    append!(digits[c].wrong_positions, bull_positions)
  end

  for c in cow_digits
    if Set(length(digits[c].wrong_positions)) == 3
      pos = pop!(setdiff(Set([1,2,3,4]), Set(digits[c].wrong_positions)))
      @debug c
      digits[c] = BullDigit(pos)
      @debug digits
      bull_digits, cow_digits = cow2bulls()
      bull_digits, cow_digits = update_available_positions(bull_digits, cow_digits)
    end
  end
  return bull_digits, cow_digits
end

function build_guess_OLD(bull_digits, cow_digits)
  @debug "bull_digits", bull_digits
  @debug "cow_digits", cow_digits
  #@assert  length(bull_digits) + length(cow_digits) == 4

  guess = [-1, -1, -1, -1]
  for b in bull_digits
    guess[digits[b].bullposition] = b
  end
  @debug "build_guess(): bull_digits, cow_digits", bull_digits, cow_digits
  free_positions = [i for i in 1:4 if guess[i] == -1]
  for p in permutations(free_positions)
    cow_d = copy(cow_digits)
    for i in p
      c = pop!(cow_d)
      if i in digits[c].wrong_positions
        @goto label1
      end
      guess[i] = c
    end
    #println("bull guess =", guess)
    bulls, cows = check(guess)
    if bulls == 4
      return guess
    end
    @label label1
  end
  @debug "bull_digits", bull_digits
  @debug "cow_digits", cow_digits
  @debug digits
  return guess
end

function build_guess(bull_digits, cow_digits)
  @debug "bull_digits", bull_digits
  @debug "cow_digits", cow_digits
  guess = [-1, -1, -1, -1]
  for b in bull_digits
    guess[digits[b].bullposition] = b
  end
  @debug "build_guess(): bull_digits, cow_digits", bull_digits, cow_digits

  free_positions = [i for i in 1:4 if guess[i] == -1]
  @debug "guess", guess
  pos_perm = Iterators.Stateful(permutations(free_positions))
  @debug "pos_perm", pos_perm
  @debug "cow_digits", cow_digits
  while true
    pf = popfirst!(pos_perm)
    @debug "pf", pf
    zp = zip(cow_digits, pf)
    @debug "zp", zp
    di = [(d, i) for (d, i) in zp if i ∉ digits[d].wrong_positions]
    if length(di) == length(cow_digits)
      for (d, i) in di
        guess[i] = d
      end
    #println("bull guess =", guess)
      bulls, cows = check(guess)

      if bulls == 4
        return guess
      end
    end
  end
  @debug "bull_digits", bull_digits
  @debug "cow_digits", cow_digits
  @debug digits
  return guess
end

function find_bulls(bull_digits, cow_digits)
  # guess = build_guess(bull_digits, cow_digits)
  # for d in bull_digits
  #   guess[digits[d].bullposition] = d
  # end
  # if length(bull_digits) == 4
  #   return guess
  # end

  bull_digits, cow_digits = update_available_positions(bull_digits, cow_digits)
  @debug "bull_digits", bull_digits
  @debug "cow_digits", cow_digits
  @debug digits
  return build_guess(bull_digits, cow_digits)
end


# begin
#   secret = [1, 0, 2, 8]
#   println("secret ", secret)
#   check = getcheck(secret)
#
#   digits = initdigits()
#
#
#   res = process_cow()
#   println(res)
#   @debug digits
#   bull_digits, cow_digits = cow2bulls()
#   @debug "bull_digits", bull_digits
#   @debug "cow_digits", cow_digits
#
#   println(bull_digits, cow_digits)
#   bull_digits, cow_digits = update_available_positions(bull_digits, cow_digits)
#
#   guess = find_bulls(bull_digits, cow_digits)
#   println("bull guess ", guess)
# end

digits_found() = [i for i = 0:9 if digits[i].status in [bull, cow]]

begin
  using IterTools
  using Combinatorics
  check = getcheck([1, 2, 3, 4])
  for s in subsets(0:9, 4)
    for p in permutations(s)
      secret = p
      @debug "secret", secret
      global check = getcheck(secret)
      digits = initdigits()
      res = process_cow()
      bull_digits, cow_digits = cow2bulls()
      guess = find_bulls(bull_digits, cow_digits)
      if secret != guess
        println(secret, "------", guess)
      #println(digits)
        break
      end
      print("secret - ", secret)
      println("    guess - ", guess)
    end
  end
end
# for i in subsets(0:9, 4)
#           @show i
#        end
