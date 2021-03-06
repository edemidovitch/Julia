using SQLite
#using Test, Dates, Random, WeakRefStrings, Tables, DBInterface
using Tables, DBInterface
using Dates


db = SQLite.DB()

DBInterface.execute(db, "create table stocks
	(date text, trans text, symbol text,
	qty real, price real)")


# Insert a row of data
DBInterface.execute(db, "insert into stocks
          values ('2006-01-05','BUY','RHAT',100,35.14)")

for t in [("2006-03-28", "BUY", "IBM", 1000, 45.00),
          ("2006-04-05", "BUY", "MSOFT", 1000, 72.00),
          ("2006-04-06", "SELL", "IBM", 500, 53.00),
         ]
    DBInterface.execute(db, "insert into stocks values (?,?,?,?,?)", t)
end
# Save (commit) the changes
#conn.commit()

symbol = "IBM"
t = (symbol  ,)
r = DBInterface.execute(db, "select * from stocks where symbol=?", t) |> rowtable
@show r

# We can also close the cursor if we are done with it
#c.close()

#Dates.DateTime("18/05/2009 16:12", "dd/mm/yyyy HH:MM")


@enum Transact begin
  BUY
  SELL
end

mutable struct TransRecord
  date::Union{Date,Nothing}
  rytrans::Transact
  symbol::String
  qty::Float64
  price::Float64
end

function TransRecord(sdate::String, strans::String, symbol::String, qty::Float64, price::Float64)
	date = Dates.DateTime(sdate, "yyyy-mm-dd")
	if strans == "BUY"
		trans = BUY
	end
	if strans == "SELL"
		trans = SELL
	end
	return TransRecord(date, trans, symbol, qty, price)
end

println("---")
for row in r
	#@show row.date
	#@show Dates.DateTime(row.date, "yyyy-mm-dd")
	println("row = ", row)
	t = TransRecord(row...)
	@show t
end
