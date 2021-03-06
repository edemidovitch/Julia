open("/Users/eugene/Downloads/Broward County Property Appraiser's Office - 1850.txt") do io
line = readline(io)
while !eof(io)
    folio = line[1:12]
    owner = line[14:end]
    while true
        if occursin(r"^\1850", line)
            site = line
            break
        end
        line = readline(io)
        owner *= line
    end
    line = readline(io)
    mail_addr = line
    while true
        line = readline(io)
        if occursin(r"^\d{6}\D\D\d{4}", line)
            break
        end
        mail_addr *= line
    end
    println(owner)
end
end
