using SimpleTraits

abstract type Asset end

abstract type Property <: Asset end
abstract type Investment <: Asset end
abstract type Cash <: Asset end

abstract type House <: Property end
abstract type Apartment <: Property end

abstract type FixedIncome <: Investment end
abstract type Equity <: Investment end

struct Residence <: House
    location
end

struct Stock <: Equity
    symbol
    name
end

struct TreasuryBill <: FixedIncome
    cusip
end

struct Money <: Cash
    currency
    amount
end


@traitdef IsLiquid{T}
@traitimpl IsLiquid{Cash}
@traitimpl IsLiquid{Investment}

@traitdef IsIlliquid{T}
@traitimpl IsLiquid{Asset}


@traitfn marketprice(x::::IsLiquid) =
    error("Please implement pricing function for ", typeof(x))

@traitfn marketprice(x::::(!IsLiquid)) =
    error("Price for illiquid asset $x is not available.")


function trait_test_cash()
    cash = Money("USD", 100.00)
    @show marketprice(cash)
end

function trait_test_stock()
    aapl = Stock("AAPL", "Apple, Inc.")
    @show marketprice(aapl)
end

function trait_test_residence()
    try
        home = Residence("Los Angeles")
        @show marketprice(home) # exception is raised
    catch ex
        println(ex)
    end
    return true
end

function trait_test_bond()
    try
        bill = TreasuryBill("123456789")
        @show marketprice(bill) # exception is raised
    catch ex
        println(ex)
    end
    return true
end

trait_test_stock()
trait_test_cash()
trait_test_residence()
