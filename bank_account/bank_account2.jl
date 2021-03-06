
struct Date
    d :: String
end

now() = "NOW"
new_acct_number() =   "new number"

abstract type AccoutType end

mutable struct Checking <: AccoutType
end

mutable struct Saving <: AccoutType
end


mutable struct BankAccount{T<:AccoutType}
    checkind_saving :: T
    number :: String
    owner
    open_date :: Date
    closed_date :: Date
    last_acsess :: Date
    amount :: Float64

    function BankAccount(checking_saving<:AccoutType, owner)
        new(checking_saving, new_acct_number(), owner, 0.0,  now(), "None", "None")
    end
end

@show BankAccount
