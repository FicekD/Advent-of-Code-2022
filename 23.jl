import Base.+, Base.Iterators.countfrom

struct Pos
    x::Int
    y::Int
end

mutable struct Elf
    position::Pos
    proposed_position::Union{Pos, Nothing}
end

(+)(p1::Pos, p2::Pos) = Pos(p1.x + p2.x, p1.y + p2.y)

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    elves = Vector{Elf}()
    for (y, line) in enumerate(lines)
        for (x, l) in enumerate(line)
            if l == '#'
                push!(elves, Elf(Pos(x, y), nothing))
            end
        end
    end
    return elves
end

is_not_occupied(_pos, _elves) = (findfirst(x -> x.position == _pos, _elves) === nothing)

function update_positions!(elves, iter)
    directions = Dict{String, Pos}("N" => Pos(0, -1), "NE" => Pos(1, -1), "E" => Pos(1, 0), "SE" => Pos(1, 1),
                                   "S" => Pos(0, 1), "SW" => Pos(-1, 1), "W" => Pos(-1, 0), "NW" => Pos(-1, -1))
    check_functions = [Pair(x -> x["N"] && x["NE"] && x["NW"], "N"), Pair(x -> x["S"] && x["SE"] && x["SW"], "S"),
                       Pair(x -> x["W"] && x["SW"] && x["NW"], "W"), Pair(x -> x["E"] && x["SE"] && x["NE"], "E")]
    propositions = Dict{Pos, Int}()
    occupations = Dict{String, Bool}("N" => false, "NE" => false, "E" => false, "SE" => false,
                                     "S" => false, "SW" => false, "W" => false, "NW" => false)
    for elf in elves
        for key in keys(occupations)
            occupations[key] = is_not_occupied(elf.position + directions[key], elves)
        end
        elf.proposed_position = elf.position
        if all(values(occupations))
            continue
        end
        for i in range(iter, iter + 3)
            if (check_functions[mod1(i, 4)].first)(occupations)
                elf.proposed_position = elf.position + directions[check_functions[mod1(i, 4)].second]
                break
            end
        end
        try 
            propositions[elf.proposed_position] += 1
        catch
            propositions[elf.proposed_position] = 1
        end
    end
    if length(propositions) == 0
        return true
    end
    for elf in elves
        if get(propositions, elf.proposed_position, 0) == 1
            elf.position = elf.proposed_position
        end
    end
    return false
end

function get_n_not_occupied(elves)
    x, y = [elf.position.x for elf in elves], [elf.position.y for elf in elves]
    x_min, x_max = minimum(x), maximum(x)
    y_min, y_max = minimum(y), maximum(y)

    n_not_occupied = 0
    for x in range(x_min, x_max)
        for y in range(y_min, y_max)
            n_not_occupied += is_not_occupied(Pos(x, y), elves)
        end
    end
    return n_not_occupied
end

function main()
    elves = read_data("data/23_data.txt")
    for i in countfrom(1)
        if update_positions!(elves, i)
            @show i
            break
        end
        if i == 10
            @show get_n_not_occupied(elves)
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
