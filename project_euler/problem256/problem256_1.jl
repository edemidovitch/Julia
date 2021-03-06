
@enum Direction begin
  horisontal
  vertical
end

Location = Union{Tuple{Int, Int}, Nothing}

function empty_room(w, h)
    #lots = Array{Bool}(undef, w, h)
    lots = Array{Bool, 2}
    lots = fill(false, w, h)  #is covered?
    nodes = Array{Int, 2}
    nodes = fill(0, w + 2, h + 2)
    return lots, nodes
end

function gen_next_in_direction(w, h)
    function (lot::Location, direction::Direction)
        x, y = lot
        if  direction == horisontal
            if x > w - 1
                return nothing
            end
            x += 1
        end
        if direction == vertical
            if y > h - 1
                return nothing
            end
            y += 1
        end
        return x, y
    end
end

function get_corners(lot::Location, direction::Direction)
    # @show lot
    # x, y = lot[1], lot[2]
    x, y = lot
    if direction == horisontal
        return [
            (x, y),
            (x, y + 1),
            (x + 2, y + 1),
            (x + 2, y),
        ]
    end
    if direction == vertical
        return [
            (x, y),
            (x, y + 2),
            (x + 1, y + 2),
            (x + 1 , y),
        ]
    end
end

function check_nodes(corners::Vector{Tuple{Int64,Int64}}, nodes::Array{Int64, 2})
    for c in corners
        x, y = c
        if nodes[x, y] > 1
            return false
        else
            nodes[x, y] += 1
        end
    end
    return true
end

function update_nodes!(corners::Vector{Tuple{Int64,Int64}}, nodes::Array{Int, 2})
    for c in corners
        x, y = c
        nodes[x, y] += 1
    end
end

function next_lot_gen(w, h)
    return function (loc::Location)
        x, y = loc
        if y < h
            y += 1
        else
            y = 1
            x += 1
        end
        if x > w || y > h
            return nothing
        end
        if x == w && y == h
            return nothing
        end
        return x, y
    end
end

function cover(lot::Location, lots::Array{Bool,2}, nodes::Array{Int,2})
    @show lot
    while true
        if isnothing(lot)
            for l in lots
                for e in l
                    if !e
                        @show "----------Failure"
                        return false
                    end
                end
            end
            @show "----------Done"
            return true
        end

        if lots[lot...]
            lot = next_lot(lot)
            continue
        end

        if !cover(lot, horisontal, lots, nodes)
            cover(lot, vertical, lots, nodes)
            lot = next_lot(lot)
        end
        lot = next_lot(lot)
    end
end

function cover(lot::Location, direction::Direction, lots::Array{Bool}, nodes::Array{Int, 2})
    second_lot = next_in_direction(lot, direction)
    @show lot, second_lot
    if isnothing(second_lot) || lots[second_lot...]
        return false
    end
    corners = get_corners(lot, direction)
    if !check_nodes(corners, nodes)
        return false
    end
    new_lots = copy(lots)
    new_lots[lot...] = true
    new_lots[second_lot...] = true
    new_nodes = copy(nodes)
    update_nodes!(corners, new_nodes)
    # lot = next_lot(lot)
    # if direction == vertical
    #     lot = next_lot(lot)
    # end
    return true
end

function check_tatami_free(w, h)
    lots, nodes = empty_room(w, h)
    #@show lots[(1,3)...]
    res = cover((1, 1), lots, nodes)
    return res
end

w, h = 4,4
@show w, h
next_lot = next_lot_gen(w, h)
next_in_direction = gen_next_in_direction(w, h)

@show w, h, check_tatami_free(w, h)
