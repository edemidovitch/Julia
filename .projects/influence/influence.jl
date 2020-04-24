ENV["JULIA_DEBUG"]="info"
#ENV["JULIA_DEBUG"]="all"

abstract type Group end

function incubation_period()
  return 15
end

struct Conformity
  ppe_usage
  higien
  distance
end

function Conformity(d::Dict)
  return Conformity(d["ppe_usage"], d["higien"], d["distance"])
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
  # (1 - p2.group.conformity.higien) +
  # (1 - p1.group.conformity.distance) +
  # (1 - p2.group.conformity.distance)
  r = rand()


  if typeof(p1.group) == typeof(p2.group)
    transmission_possiblity = 1.0
  end
  if r < transmission_possiblity
    @debug "h transmission"
    p2 = Sick(incubation_period(), p2.group)
  end
  return p1, p2
end

function contact(p1::Healthy, p2::Sick)
  contact(p2::Sick, p1::Healthy)
  return p1, p2
end

contact(p1::Person, p2::Person) = p1, p2

function update_sick!(persons::Vector{<:Person})
  check_to_immune!(p::Person) = false
  function check_to_immune!(p::Sick)
    p.days_to_immune -= 1
    return p.days_to_immune == 0
  end
  for (i, p) in enumerate(persons)
    if check_to_immune!(p)
      persons[i] = Immune(p.group)
    end
  end
end

function daily_change_horizontal!(persons::Vector{<:Person}, overlap)
  for i = 1:lastindex(persons)-1
    r = rand()
    #@debug overlap, r
    if rand() < overlap
      persons[i], persons[i+1] = contact(persons[i], persons[i+1])
    end
  end
end

function daily_change_inner!(
  persons::Vector{<:Person},
  contacts_to_im,
  contact_to_out,
)
  for i  in eachindex(persons)
    im_c = rand(persons[i].group.intermidiate_circle, contacts_to_im)
    for im_person in im_c
      persons[i], regular_groups[im_person] = contact(persons[i], regular_groups[im_person])
    end
    out_c = rand(persons[i].group.outer_circle, contact_to_out)
    for out_person in out_c
      persons[i], irresponsible_groups[out_person] = contact(persons[i], irresponsible_groups[out_person])
    end
  end
end

function daily_change_intermidiate!(persons::Vector{<:Person}, contact_to_out)
  for i  in eachindex(persons)
    out_c = rand(persons[i].group.outer_circle, contact_to_out)
    for out_person in out_c
      persons[i], irresponsible_groups[out_person] = contact(persons[i], irresponsible_groups[out_person])
    end
  end
end

counter!(p::Healthy, v) = v[1] += 1
counter!(p::Sick, v) = v[2] += 1
counter!(p::Immune, v) = v[3] += 1

function daily_update()
  update_sick!(responsible_groups)
  update_sick!(regular_groups)
  update_sick!(irresponsible_groups)
  daily_change_horizontal!(responsible_groups, circle_param["inner"]["overlap"])
  daily_change_horizontal!(
    regular_groups,
    circle_param["intermidiate"]["overlap"],
  )
  daily_change_horizontal!(
    irresponsible_groups,
    circle_param["outer"]["overlap"],
  )
  daily_change_inner!(
    responsible_groups,
    circle_param["inner"]["contact2m"],
    circle_param["inner"]["contact2o"],
  )
  daily_change_intermidiate!(regular_groups, circle_param["intermidiate"]["contact2o"])
end

function count_cases!(v)
  for p in responsible_groups
    counter!(p, v)
  end
  for p in regular_groups
    counter!(p, v)
  end
  for p in irresponsible_groups
    counter!(p, v)
  end
end

circle_param = Dict(
  "inner" => Dict(
    "size" => 3,
    "overlap" => 0.2,
    "conformity" =>
      Dict("ppe_usage" => 0.95, "higien" => 1.0, "distance" => 0.9),
    "contact2m" => 5,
    "contact2o" => 3,
  ),
  "intermidiate" => Dict(
    "size" => 5,
    "overlap" => 0.3,
    "conformity" =>
      Dict("ppe_usage" => 0.75, "higien" => 0.5, "distance" => 0.7),
    "contact2o" => 5,
  ),
  "outer" => Dict(
    "size" => 8,
    "overlap" => 0.4,
    "conformity" => Dict("ppe_usage" => 0.0, "higien" => 0.0, "distance" => 0.0),
  ),
)

inner_conformity = Conformity(circle_param["inner"]["conformity"])
intermidiate_conformity = Conformity(circle_param["intermidiate"]["conformity"])
outer_conformity = Conformity(circle_param["outer"]["conformity"])

function set_conformity(circle::String, values)
  circle_param[circle]["conformity"]["ppe_usage"] = values[1]
  circle_param[circle]["conformity"]["higien"] = values[2]
  circle_param[circle]["conformity"]["distance"] = values[3]
end


p1 = Dict(
  "responsible_groups_number" => 300,
  "initial_rate" => (2, 2, 2),
  "conformity_level_1" => [(0.1, 0.8, 0.5), (0.9, 0.9, 0.9), (0.5, 0.5, 0.5)],
  "conformity_level_2" => [(0.1, 0.8, 0.5), (0.9, 0.9, 0.9), (0.5, 0.5, 0.5)],
  "conformity_level_3" => [(0.1, 0.8, 0.5), (0.9, 0.9, 0.9), (0.5, 0.5, 0.5)],
  "phase_longivity" => (10, 60, 30)
)

params = p1

responsible_groups_number = params["responsible_groups_number"]
initial_rate = 2, 2, 2
conformity_level = [(0.1, 0.8, 0.5), (0.9, 0.9, 0.9),(0.5, 0.5, 0.5)]

responsible_groups, regular_groups, irresponsible_groups =
  build_groups(circle_param, responsible_groups_number)

initial_impact!(initial_rate[1], responsible_groups)
initial_impact!(initial_rate[2], regular_groups)
initial_impact!(initial_rate[3], irresponsible_groups),



let
  v = [0, 0, 0]
  count_cases!(v)
  @show "----"
  @show v, v[3] / sum(v), initial_rate
  set_conformity("inner", (0.1, 0.8, 0.5))
  set_conformity("intermidiate", (0.9, 0.9, 0.9))
  set_conformity("outer", (0.5, 0.5, 0.5))

  for d = 1:10
    v = [0, 0, 0]
    daily_update()
    count_cases!(v)
  end
  @show v, v[3] / sum(v), initial_rate
  set_conformity("inner", (0.9, 1.0, 0.9))
  set_conformity("intermidiate", (0.8, 0.7, 0.5))
  set_conformity("outer", (0.5, 0.5, 0.5))

  for d = 1:60
    v = [0, 0, 0]
    daily_update()
    count_cases!(v)
  end
  @show v, v[3] / sum(v), initial_rate
  set_conformity("inner", (0.9, 0.9, 0.5))
  set_conformity("intermidiate", (0.5, 0.5, 0.5))
  set_conformity("outer", (0.5, 0.5, 0.5))

  for d = 1:30
    v = [0, 0, 0]
    daily_update()
    count_cases!(v)
  end
  @show v, v[3] / sum(v), initial_rate
end
