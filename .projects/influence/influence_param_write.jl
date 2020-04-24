module MySQLmodule
export read_param

using SQLite
using Tables, DBInterface
using Dates
import JSON


function init(db_name)
  db = SQLite.DB("/Users/eugene/Programming/data/influence_data.sqlite")
  return db
end

function read(db)
  dict = Dict()
  #r = DBInterface.execute(db, "select * from stocks where symbol=?", t) |> rowtable
  r = DBInterface.execute(db, "select * from parameters") |> rowtable
  for row in r
    @show row.id, row.init_date
    d = JSON.parse(row.dictionary)
    @show  d
    @show row.comments
  end
end

function read(db, id)
  dict = Dict()
  stmt = DBInterface.prepare(db, "select * from parameters where id=?")
  r = DBInterface.execute(stmt, [id])|> rowtable
  for row in r
    d = row.dictionary
    return d
  end

end


p1 = Dict(
  "responsible_groups_number" => 3000,
  "phase_length"=>(30, 30, 30),
  "initial_rate" => (2, 2, 2),
  "inner" => Dict(
    "size" => 3,
    "overlap" => 0.2,
    "conformity" =>
      [Dict("ppe_usage" => 0.0, "higien" => 1.0, "distance" => 0.5),
      Dict("ppe_usage" => 0.95, "higien" => 1.0, "distance" => 0.9),
      Dict("ppe_usage" => 0.7, "higien" => 1.0, "distance" => 0.5)],
    "contact2m" => 5,
    "contact2o" => 3,
  ),
  "intermidiate" => Dict(
    "size" => 5,
    "overlap" => 0.3,
    "conformity" =>
      [Dict("ppe_usage" => 0.0, "higien" => 0.5, "distance" => 0.7),
      Dict("ppe_usage" => 0.75, "higien" => 0.5, "distance" => 0.7),
      Dict("ppe_usage" => 0.5, "higien" => 0.5, "distance" => 0.7)],
    "contact2o" => 5,
  ),
  "outer" => Dict(
    "size" => 8,
    "overlap" => 0.4,
    "conformity" =>
      [Dict("ppe_usage" => 0.0, "higien" => 0.0, "distance" => 0.0),
      Dict("ppe_usage" => 0.0, "higien" => 0.0, "distance" => 0.0),
      Dict("ppe_usage" => 0.0, "higien" => 0.0, "distance" => 0.0)],
  ),
)

function record_write(db, data::Dict)
  json_string = JSON.json(data)
  stmt = DBInterface.prepare(db, "insert into parameters(init_date, dictionary) values(?, ?)")
  DBInterface.execute(stmt, [Dates.format(DateTime(Dates.now()), "yyyy-mm-dd HH:MM:SS"), json_string])
end

function record_write(stmt, json_string::String)
  stmt = DBInterface.prepare(db, "insert into parameters(init_date, dictionary) values(?, ?)")
  DBInterface.execute(stmt, [Dates.format(DateTime(Dates.now()), "yyyy-mm-dd HH:MM:SS"), json_string])
end

function read_param(id)
  b = SQLite.DB("/Users/eugene/Programming/data/influence_data.sqlite")
  return JSON.parse(read(db, id)  )
end

db = init("/Users/eugene/Programming/data/influence_data.sqlite")
#record_write(db, p1)
#record_write(db, "{\"conformity_level_2\":[[0.1,0.8,0.5],[0.9,0.9,0.9],[0.5,0.5,0.5]],\"responsible_groups_number\":300,\"phase_longivity\":[10,60,30],\"conformity_level_1\":[[0.1,0.8,0.5],[0.9,0.9,0.9],[0.5,0.5,0.5]],\"conformity_level_3\":[[0.1,0.8,0.5],[0.9,0.9,0.9],[0.5,0.5,0.5]],\"initial_rate\":[2,2,2]}")
@show read(db)
#@show read(db,22)
#@show read_param(22)
end
