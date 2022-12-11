import Base.+, Base.-

mutable struct Coords 
    x::Int64
    y::Int64
end

(+)(first::Coords, second::Coords) = Coords(first.x + second.x, first.y + second.y)
(-)(first::Coords, second::Coords) = Coords(first.x - second.x, first.y - second.y)

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    dir_to_coord_diffs = Dict{String, Coords}("R" => Coords(1, 0), "L" => Coords(-1, 0), "U" => Coords(0, 1), "D" => Coords(0, -1))
    directions = Vector{Pair{Coords, Int}}()
    for line in lines
        dir, num = split(line, ' ')
        push!(directions, Pair(dir_to_coord_diffs[dir], parse(Int, num)))
    end
    return directions
end

function simulate_knots(directions, n_knots)
    head = Coords(0, 0)
    tails = Vector{Coords}()
    for _ in range(1, n_knots - 1)
        push!(tails, Coords(0, 0))
    end

    occurence_map = Dict{Pair{Int, Int}, Int}(Pair(tails[end].x, tails[end].y) => 1)
    for (dir, num) in directions
        for _ in range(1, num)
            head += dir
            
            curr_head = head
            for tail in tails
                dists = curr_head - tail
                if abs(dists.x) > 1 || abs(dists.y) > 1
                    if abs(dists.x) > 1 && abs(dists.y) == 0
                        tail.x += dists.x / abs(dists.x)
                    elseif abs(dists.x) == 0 && abs(dists.y) > 1
                        tail.y += dists.y / abs(dists.y)
                    else
                        tail.x += dists.x / abs(dists.x)
                        tail.y += dists.y / abs(dists.y)
                    end
                end
                curr_head = tail
            end

            key = Pair(tails[end].x, tails[end].y)
            occurence_map[key] = get(occurence_map, key, 0) + 1
        end
    end

    @show length(keys(occurence_map))
end

function main()
    directions = read_data("data/09_data.txt")

    simulate_knots(directions, 2)
    simulate_knots(directions, 10)
    
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
