using SQLite
#using Test, Dates, Random, WeakRefStrings, Tables, DBInterface
using Tables, DBInterface
#using Dates
using Interpolations
using Plots
#import GR
#gr(fmt=:png);
#gr(reuse=true)

function data_res(db, symbol)
    t = (symbol,)
    r =
        DBInterface.execute(
            db,
            "select new_cases_smoothed_per_million from owid_covid_data where iso_code=? and date > '2020-03-02' and date <  date('now')",
            t,
        ) |> rowtable
    return r
end

function data_plot(d, symbol, save = false)
    dm = Tables.matrix(d)
    #@show dm
    x = 1:length(dm)
    xf = 1:0.1:length(dm)
    y = parse.(Float64, dm)[:, 1]
    #@show y
    li_spline = CubicSplineInterpolation(x, y)

    #@show li(0.3) # evaluate at a single point
    scatter(x, y, label = symbol, markersize = 1, legend = :topleft)
    p = plot!(xf, li_spline.(xf), label = "daily cases per mil")
    display(p)
    if save
        savefig(p, "/Users/eugene/Programming/data/covid/$symbol.png")
    end
end


db = SQLite.DB("/Users/eugene/Programming/data/covid/cov_test.db")

symbols = ["USA", "CAN", "DEU", "GBR", "FRA", "ISR", "ESP","BEL","SWE", "DNK",  "CHE", "ITA"] #, "POR"]

for symbol in symbols
    df = data_res(db, symbol)
    data_plot(df, symbol, true)
end
