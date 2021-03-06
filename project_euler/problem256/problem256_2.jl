
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
    nodes = fill(0, w + 1, h + 1)
    return lots, nodes
end

function second_in_direction(lots::Array{Bool}, lot::Location, direction::Direction)
    w, h = size(lots)
    x, y = lot
    if direction == horisontal
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

function get_corners(lot::Location, direction::Direction)
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
        if nodes[c...] > 2
            return false
        end
    end
    return true
end

function update_nodes!(corners::Vector{Tuple{Int64,Int64}}, nodes::Array{Int, 2})
    for c in corners
        nodes[c...] += 1
    end
end

function next_lot(lots::Array{Bool,2}, loc::Location)
    w, h = size(lots)
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
    return x, y
end

function cover(lot::Location, lots::Array{Bool,2}, nodes::Array{Int,2})
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
            lot = next_lot(lots, lot)
        else
            break
        end
    end

    return cover(lot, vertical, lots, nodes) || cover(lot, horisontal, lots, nodes)
end

function cover(lot::Location, direction::Direction, lots::Array{Bool}, nodes::Array{Int, 2})
    second_lot = second_in_direction(lots, lot, direction)
    if isnothing(second_lot) || lots[second_lot...]
        return false
    end
    corners = get_corners(lot, direction)
    if !check_nodes(corners, nodes)
        return false
    end
    new_lots = deepcopy(lots)
    new_lots[lot...] = true
    new_lots[second_lot...] = true
    new_nodes = deepcopy(nodes)
    update_nodes!(corners, new_nodes)
    new_lot = next_lot(lots, lot)
    if direction == vertical
        new_lot = next_lot(lots, new_lot)
    end
    return cover(new_lot, new_lots, new_nodes)
end

function check_tatami_free(room_size)
    Ts = 0
    h = 2
    while h <= room_size ^ 0.5
        if room_size % h == 0
            w = room_size ÷ h

        @show w, h

        lots, nodes = empty_room(w, h)
        res = cover((1, 1), lots, nodes)
        if !res
            Ts += 1
        end
        @show w, h, res
    end
    h += 1
    end
    return Ts
end

room_size = 1320

@show  room_size, check_tatami_free(room_size)
