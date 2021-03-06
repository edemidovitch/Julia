
opp(player) = 3 - player

function points_probability(match_stats)
    probability = [Dict(), Dict()]
    for i in 1:2
        served = match_stats[i]["service_points"][2]
        probability[i]["ace"] = match_stats[i]["aces"]/served
        probability[i]["double_fault"] = match_stats[i]["double_faults"]/served

        points_in_rallies = served - match_stats[i]["aces"] - match_stats[i]["double_faults"] +
        match_stats[opp(i)]["service_points"][2] - match_stats[opp(i)]["aces"] - match_stats[opp(i)]["double_faults"]

        probability[i]["winner"] = match_stats[i]["winners"]/points_in_rallies
        probability[i]["unforced_error"] = match_stats[i]["unforced_errors"]/points_in_rallies

        net_points = match_stats[i]["net_point"][2]
        probability[i]["net_win"] = (match_stats[i]["net_point"][1])/net_points
        probability[i]["net_lost"] = (net_points - match_stats[i]["net_point"][1])/net_points

        service_points = match_stats[i]["service_points"][2] - match_stats[i]["aces"] - match_stats[i]["double_faults"]
        probability[i]["service_point"] = (match_stats[i]["service_points"][1] - match_stats[i]["aces"])/service_points
        probability[i]["service_point_win"] = match_stats[i]["service_points"][1]/match_stats[i]["service_points"][2]
        return_points = match_stats[i]["return_points"][2] - match_stats[opp(i)]["aces"] - match_stats[opp(i)]["double_faults"]
        probability[i]["return_point"] = (match_stats[i]["return_points"][1] - match_stats[opp(i)]["double_faults"])/return_points
        probability[i]["other_point_win"] = (match_stats[i]["total_won"] - match_stats[i]["aces"] - match_stats[i]["winners"]
                   - match_stats[opp(i)]["double_faults"] - match_stats[opp(i)]["unforced_errors"])/match_stats[i]["total_won"]
        probability[i]["other_point_lost"] = (match_stats[opp(i)]["total_won"] - match_stats[i]["double_faults"] - match_stats[i]["unforced_errors"]
                    - match_stats[opp(i)]["aces"] - match_stats[opp(i)]["winners"])/match_stats[opp(i)]["total_won"]
    end
    return probability
end

function game_play(probability, player)
    WIN = 1
    PLAY = 0
    points = [0, 0]

    function add_point(layer)
        THIRTY = 30
        FOURTY = 40

        opponent = opp(player)

        if points[player] < THIRTY
            points[player] += 15
            return PLAY
        end
        if points[player] == THIRTY
            points[player] += 10
            return PLAY
        end
        if points[player] == FOURTY
            if points[opponent] < FOURTY
                return WIN
            else
               points[opponent] -= 10
               return PLAY
            end
        end
    end
    server = player
    reciever = opp(server)

    while true
        p = rand()
        r =  probability[server]["service_point_win"]
        if p < r
            s = add_point(server)
            if s == WIN
               return server
            end
        else
            s = add_point(reciever)
            if s == WIN
                return reciever
            end
        end
    end
end

function tie_break_play(probability, player)
    WIN = 1
    PLAY = 0
    points = [0,0]

    function add_point(player)
        opponent = opp(player)
        points[player] += 1
        if  (points[player]  >= 7) &&  (points[player] - points[opponent] >= 2)
            return WIN
        else
            return PLAY
        end
    end

    function serve_by(player)
        server = player
        reciever = opp(player)
        p = rand()
        r =  probability[server]["service_point_win"]
        if p < r
            s = add_point(server)
            if s == WIN
               return server
            end
        else
            s = add_point(reciever)
            if s == WIN
               return reciever
            end
        end
        return PLAY
    end

    server = player
    reciever = opp(player)
    while true
        r = serve_by(server)
        if r != PLAY
            return r
        end
        server, reciever = reciever, server
        r = serve_by(server)
        if r != PLAY
            return r
        end
    end
end

function play_simulation(play, probability, server, n)
    counts = [0,0]

    for i in 1:n
        r = play(probability, server)
        counts[r] += 1
    end
    return counts
end

match_stats_set5 = [Dict("aces"=> 2, "double_faults"=> 3,
        "winners"=> 20, "unforced_errors"=> 23,
        "net_point"=> (12, 17), "service_points"=> (56, 84), "return_points"=> (29, 81),
        "total_won"=>85),
         Dict("aces"=> 12, "double_faults"=> 0,
        "winners"=> 37, "unforced_errors"=> 22,
        "net_point"=> (22,30), "service_points"=> (52, 81), "return_points"=> (32, 88),
        "total_won"=>84)
         ]


match_stats = match_stats_set5
setn = 5

probability = points_probability(match_stats)

players = ("DJOKOVIC", "FEDERER")
# println("Match statistics set ", setn)
# for i in 1:2
#     println(players[i])
#     println(match_stats[i])
# end
#
#
# println("Points probability")
# for i in 1:2
#     println(players[i])
#     println(probability[i])
# end

n = 1000000
println("\nNumber of simulation - ", n)

println()

for i in 1:2
    counts  = play_simulation(game_play, probability, i, n)
    println(players[i], "starts games: \t\t", players[1], "=", counts[1],"\t", players[2],"=", counts[2])
end

for i in 1:2
    counts  = play_simulation(tie_break_play, probability, i, n)
    println(players[i], "starts tie breaks: \t", players[1], "=", counts[1], "\t", players[2],"=", counts[2])
end
