module Acccounts
struct Date
    d :: String
end

now() = "NOW"
new_acct_number() =   "new number"

mutable struct Person
     name:: String
     SSN :: String
end

mutable struct Currency
    name :: String
    amount :: Float64
end

abstract type AccoutType end

mutable struct Checking <: AccoutType
    check_cancelled :: Array
end

mutable struct Saving <: AccoutType
end

mutable struct CreditCard <: AccoutType
    credit_line :: Float64
end

mutable struct BankAccount{T<: AccoutType}
    the_account :: T
    number :: String

    owner :: Person
    open_date :: Date
    closed_date :: Date
    last_acsess :: Date
    amount :: Currency

    # function BankAccount{T}(checking_saving,  owner::Person) where {T<:AccoutType}
    #     new(checking_saving, new_acct_number(), owner,  Date(now()), Date("None"), Date(now()),Currency("USD", 0.0))
    # end
end

function BankAccount{T}(checking_saving,  owner::Person) where {T<:AccoutType}
    BankAccount(checking_saving, new_acct_number(), owner,  Date(now()), Date("None"), Date(now()),Currency("USD", 0.0))
end



function add_to(acct :: AccoutType, amount :: Currency)
end

function statement(account::BankAccount{Checking})
    println("Checking account")
    #println(account.checking_saving.credit_line)

end

function statement(account::BankAccount{CreditCard})
    println("Credit card:")
    println(account.the_account.credit_line)

end

ca = BankAccount{Checking}(Checking([]), Person("Me", "12344"))
@show ca


cca = BankAccount{CreditCard}(CreditCard(15000.0), Person("Me", "12344"))
@show cca

statement(cca)
end
