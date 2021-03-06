#using .MySQLmodule
using Plots
#using Printf


ENV["JULIA_DEBUG"] = "info"
#ENV["JULIA_DEBUG"]="all"

abstract type Group end

struct Conformity
  ppe_usage
  higien
  distance
  overlap
end

function Conformity(d::Dict)
  return Conformity(d["ppe_usage"], d["higien"], d["distance"], d["overlap"])
end

mutable struct Responsible <: Group
  conformity::Conformity
  inner_circle::Vector{Int64}
  intermidiate_circle::Vector{Int64}
  outer_circle::Vector{Int64}
end

function Responsible(circle_param)
  inner_circle = Vector{Int64}(undef, circle_param["inner"]["size"])
  intermidiate_circle = Vector{Int64}(undef, circle_param["inner"]["contact2m"])
  outer_circle = Vector{Int64}(undef, circle_param["inner"]["contact2o"])
  return Responsible(
    inner_conformity,
    inner_circle,
    intermidiate_circle,
    outer_circle,
  )
end

mutable struct Regular <: Group
  conformity::Conformity
  intermidiate_circle::Vector{Int64}
  outer_circle::Vector{Int64}
end

function Regular(circle_param)
  intermidiate_circle =
    Vector{Int64}(undef, circle_param["intermidiate"]["size"])
  outer_circle = Vector{Int64}(undef, circle_param["intermidiate"]["contact2o"])
  return Regular(intermidiate_conformity, intermidiate_circle, outer_circle)
end

mutable struct Irresponsible <: Group
  conformity::Conformity
  outer_circle::Vector{Int64}
end

function Irresponsible(circle_param)
  outer_circle = Vector{Int64}(undef, circle_param["outer"]["size"])
  return Irresponsible(outer_conformity, outer_circle)
end

abstract type Person end

mutable struct Healthy{T<:Group} <: Person
  group::T
end

mutable struct Sick{T<:Group} <: Person
  days_to_immune::Union{Int64,Nothing}
  group::T
end

mutable struct Immune{T<:Group} <: Person
  group::T
end

function build_groups(circle_param, responsible_groups_number)
  responsible_groups = Vector{Person}(undef, responsible_groups_number)
  for i in eachindex(responsible_groups)
    responsible_groups[i] = Healthy(Responsible(circle_param))
    responsible_groups[i].group.intermidiate_circle = [
      (i - 1) * circle_param["intermidiate"]["size"] + j
      for j = 1:circle_param["intermidiate"]["size"]
    ]
    responsible_groups[i].group.outer_circle = [
      (i - 1) * circle_param["outer"]["size"] + j
      for j = 1:circle_param["outer"]["size"]
    ]
  end


  regular_groups_number =
    responsible_groups_number * (circle_param["intermidiate"]["size"])

  regular_groups = Vector{Person}(undef, regular_groups_number)
  for i = 1:regular_groups_number
    regular_groups[i] = Healthy(Regular(circle_param))
    regular_groups[i].group.outer_circle = [
      (i - 1) * circle_param["outer"]["size"] + j
      for j = 1:circle_param["outer"]["size"]
    ]
  end

  irresponsible_group_number =
    regular_groups_number * (circle_param["outer"]["size"])
  irresponsible_groups = Vector{Person}(undef, irresponsible_group_number)
  for i = 1:irresponsible_group_number
    irresponsible_groups[i] = Healthy(Irresponsible(circle_param))
    # regular_groups[i].group.outer_circle = [
    #   i * circle_param["outer"]["size"] + j
    #   for j = 1:circle_param["intermidiate"]["contact2o"]
    # ]
  end

  return responsible_groups, regular_groups, irresponsible_groups
end

function get_incubation_period(days)
  return () -> rand(days[1]:days[2], 1)[1]
end

function initial_impact!(rate, persons::Vector{<:Person})
  l = size(persons)[1]
  r = l / 100 * rate
  list = rand(1:l, round(Int, r))
  #@debug l,r
  for i in list
    persons[i] = Sick(incubation_period(), persons[i].group)
  end
end


function contact(p1::Sick, p2::Healthy)
  transmission_possiblity =
    (1 - p1.group.conformity.ppe_usage) * (1 - p2.group.conformity.ppe_usage)
  (1 - p2.group.conformity.higien) * (1 - p1.group.conformity.higien)
  *(1 - p1.group.conformity.distance) * (1 - p2.group.conformity.distance)

  if typeof(p1.group) == typeof(p2.group)
    transmission_possiblity = (1 - p1.group.conformity.higien) / 2
  end
  transmission_possiblity =
    transmission_possiblity * p1.days_to_immune / incubation_period()
  r = rand()
  if r < transmission_possiblity / 7.0
    @debug "h transmission"
    p2 = Sick(incubation_period(), p2.group)
  end
  return p1, p2
end

function contact(p1::Healthy, p2::Sick)
  p2, p1 = contact(p2::Sick, p1::Healthy)
  return p1, p2
end

contact(p1::Person, p2::Person) = p1, p2

function going_out(p::Healthy, n, env_higien)
  transmission_possiblity =
    (1 - p.group.conformity.higien) *
    (1 - p.group.conformity.ppe_usage) *
    (1 - p.group.conformity.distance)

  r = rand()
  #@show n
  if r < transmission_possiblity / 100000 * (1 - env_higien) * max(0.4, n)
    #if r < transmission_possiblity/1000 *(1 - env_higien) * n
    p = Sick(incubation_period(), p.group)
  end
  return p
end

function going_out(p::Person, n, phase)
  return p
end

function update_sick!(persons::Vector{<:Person}, v, phase)
  check_to_immune!(p::Person) = false
  function check_to_immune!(p::Sick)
    p.days_to_immune -= 1
    return p.days_to_immune == 0
  end
  phase_higien = params["env_higien"][phase]
  for (i, p) in enumerate(persons)
    if check_to_immune!(p)
      persons[i] = Immune(p.group)
    else
      persons[i] = going_out(p, v[2] / (sum(v) + 1), phase_higien)
    end
  end
end

function daily_change_horizontal!(persons::Vector{<:Person})
  for i = 1:lastindex(persons)-1
    r = rand()
    #@debug overlap, r
    if rand() < persons[i].group.conformity.overlap
      persons[i], persons[i+1] = contact(persons[i], persons[i+1])
    end
  end
end

function daily_change_inner!(
  persons::Vector{<:Person},
  contacts_to_im,
  contact_to_out,
)
  for i in eachindex(persons)
    im_c = rand(persons[i].group.intermidiate_circle, contacts_to_im)
    for im_person in im_c
      persons[i], regular_groups[im_person] =
        contact(persons[i], regular_groups[im_person])
    end
    out_c = rand(persons[i].group.outer_circle, contact_to_out)
    for out_person in out_c
      persons[i], irresponsible_groups[out_person] =
        contact(persons[i], irresponsible_groups[out_person])
    end
  end
end

function daily_change_intermidiate!(persons::Vector{<:Person}, contact_to_out)
  for i in eachindex(persons)
    out_c = rand(persons[i].group.outer_circle, contact_to_out)
    for out_person in out_c
      persons[i], irresponsible_groups[out_person] =
        contact(persons[i], irresponsible_groups[out_person])
    end
  end
end

function daily_update(circle_param::Dict, v, phase)
  update_sick!(responsible_groups, v, phase)
  update_sick!(regular_groups, v, phase)
  update_sick!(irresponsible_groups, v, phase)
  daily_change_horizontal!(responsible_groups)
  daily_change_horizontal!(regular_groups)
  daily_change_horizontal!(irresponsible_groups)
  daily_change_inner!(
    responsible_groups,
    circle_param["inner"]["contact2m"],
    circle_param["inner"]["contact2o"],
  )
  daily_change_intermidiate!(
    regular_groups,
    circle_param["intermidiate"]["contact2o"],
  )
end

function setConformity(params::Dict, phase)
  d = params["inner"]["conformity"][phase]
  inner_conformity =
    Conformity(d["ppe_usage"], d["higien"], d["distance"], d["overlap"])
  d = params["intermidiate"]["conformity"][phase]
  intermidiate_conformity =
    Conformity(d["ppe_usage"], d["higien"], d["distance"], d["overlap"])
  d = params["outer"]["conformity"][phase]
  outer_conformity =
    Conformity(d["ppe_usage"], d["higien"], d["distance"], d["overlap"])
  return inner_conformity, intermidiate_conformity, outer_conformity
end

counter!(p::Healthy, v) = v[1] += 1
counter!(p::Sick, v) = v[2] += 1
counter!(p::Immune, v) = v[3] += 1

function count_cases()
  v = [0, 0, 0]
  for p in responsible_groups
    counter!(p, v)
  end
  for p in regular_groups
    counter!(p, v)
  end
  for p in irresponsible_groups
    counter!(p, v)
  end
  return v
end

function daily_cases!(daily_stat, v, phase, i)
  daily_stat[phase][1, i] = v[1]
  daily_stat[phase][2, i] = v[2]
  daily_stat[phase][3, i] = v[3]
end

p1 = Dict(
  "responsible_groups_number" => 3000,
  "phase_length" => (30, 40, 100),
  "initial_rate" => (0.2, 0.1, 0.1),
  "env_higien" => (0.3, 0.8, 0.2),
  "incubation_period" => (14, 21),
  "inner" => Dict(
    "size" => 3,
    "conformity" => [
      Dict(
        "ppe_usage" => 0.0,
        "higien" => 0.9,
        "distance" => 0.5,
        "overlap" => 0.5,
      ),
      Dict(
        "ppe_usage" => 0.95,
        "higien" => 1.0,
        "distance" => 0.9,
        "overlap" => 0.0,
      ),
      Dict(
        "ppe_usage" => 0.7,
        "higien" => 1.0,
        "distance" => 0.5,
        "overlap" => 0.1,
      ),
    ],
    "contact2m" => 5,
    "contact2o" => 3,
  ),
  "intermidiate" => Dict(
    "size" => 8,
    "conformity" => [
      Dict(
        "ppe_usage" => 0.0,
        "higien" => 0.2,
        "distance" => 0.2,
        "overlap" => 0.6,
      ),
      Dict(
        "ppe_usage" => 0.8,
        "higien" => 0.5,
        "distance" => 0.5,
        "overlap" => 0.05,
      ),
      Dict(
        "ppe_usage" => 0.3,
        "higien" => 0.4,
        "distance" => 0.7,
        "overlap" => 0.2,
      ),
    ],
    "contact2o" => 5,
  ),
  "outer" => Dict(
    "size" => 10,
    "conformity" => [
      Dict(
        "ppe_usage" => 0.0,
        "higien" => 0.1,
        "distance" => 0.0,
        "overlap" => 0.8,
      ),
      Dict(
        "ppe_usage" => 0.7,
        "higien" => 0.3,
        "distance" => 0.4,
        "overlap" => 0.1,
      ),
      Dict(
        "ppe_usage" => 0.2,
        "higien" => 0.2,
        "distance" => 0.0,
        "overlap" => 0.7,
      ),
    ],
  ),
)

params = p1
#params = MySQLmodule.read_param(23)
inner_conformity, intermidiate_conformity, outer_conformity =
  setConformity(params, 1)
responsible_groups_number = params["responsible_groups_number"]
responsible_groups, regular_groups, irresponsible_groups =
  build_groups(params, responsible_groups_number)

incubation_period = get_incubation_period(params["incubation_period"])

initial_rate = params["initial_rate"]
initial_impact!(initial_rate[1], responsible_groups)
initial_impact!(initial_rate[2], regular_groups)
initial_impact!(initial_rate[3], irresponsible_groups)
daily_stat = [
  zeros(Int64, 3, params["phase_length"][1]),
  zeros(Int64, 3, params["phase_length"][2]),
  zeros(Int64, 3, params["phase_length"][3]),
]
let
  @show "------------------"
  v = count_cases()
  @show v
  for phase = 1:3
    inner_conformity, intermidiate_conformity, outer_conformity =
      setConformity(params, phase)
    for d = 1:params["phase_length"][phase]
      daily_update(params, v, phase)
      v = count_cases()
      daily_cases!(daily_stat, v, phase, d)
    end
    @show v
  end
end
#s = @sprintf("phases:%.0f-%.0f-%.0f", params["phase_length"][1], params["phase_length"][2], params["phase_length"][3])
plot(
  [1:sum(params["phase_length"])],
  [
    cat(dims = 2, daily_stat[1], daily_stat[2], daily_stat[3])[i, :]
    for i = 1:3
  ],
  label = ["Healthy" "Sick" "Immune"],
  lw = 3,
  xlabel="Days",
  ylabel="Number of people",
)

phase_1 = params["phase_length"][1]
phase_2 = phase_1 + params["phase_length"][2]
vline!([phase_1], label = "phase1")
vline!([phase_2], label = "phase2")
