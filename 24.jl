import Base.+, Base.Iterators.countfrom

struct Pos
    x::Int
    y::Int
end

mutable struct Blizzard
    pos::Pos
    dir::Char
end

(+)(p1::Pos, p2::Pos) = Pos(p1.x + p2.x, p1.y + p2.y)

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    blizzards = Vector{Blizzard}()
    for (y, line) in enumerate(lines[2:end - 1])
        for (x, l) in enumerate(line[2:end - 1])
            if l != '.'
                push!(blizzards, Blizzard(Pos(x, y), l))
            end
        end
    end
    return blizzards, Pos(1, 0), Pos(length(lines[1]) - 2, length(lines) - 1)
end

function update_blizzards(blizzards, max_pos)
    directions = Dict{Char, Pos}('>' => Pos(1, 0), 'v' => Pos(0, 1), '<' => Pos(-1, 0), '^' => Pos(0, -1))
    for blizz in blizzards
        blizz.pos = blizz.pos + directions[blizz.dir]
        if blizz.pos.x < 1
            blizz.pos = Pos(max_pos.x, blizz.pos.y)
        elseif blizz.pos.x > max_pos.x
            blizz.pos = Pos(1, blizz.pos.y)
        elseif blizz.pos.y < 1
            blizz.pos = Pos(blizz.pos.x, max_pos.y)
        elseif blizz.pos.y > max_pos.y
            blizz.pos = Pos(blizz.pos.x, 1)
        end
    end
end

function get_fastest_path(blizzards, pos, end_pos)
    max_pos = Pos(max(pos.x, end_pos.x), max(pos.y - 1, end_pos.y - 1))
    directions = Pos[Pos(1, 0), Pos(0, 1), Pos(-1, 0), Pos(0, -1)]
    valid_pos_fn = _x -> _x.x >= 1 && _x.x <= max_pos.x && _x.y >= 1 && _x.y <= max_pos.y
    not_occupied_fn = _pos -> findfirst(_x -> _x.pos == _pos, blizzards) === nothing
    all_positions = Set{Pos}([pos])
    for i in countfrom(1)
        update_blizzards(blizzards, max_pos)
        candidate_positions = Set{Pos}()
        for pos in all_positions
            for dir in directions
                candidate_pos = pos + dir
                if candidate_pos == end_pos
                    return i
                end
                if valid_pos_fn(candidate_pos) && not_occupied_fn(candidate_pos)
                    push!(candidate_positions, candidate_pos)
                end
            end
        end
        filter!(_x -> not_occupied_fn(_x), all_positions)
        union!(all_positions, candidate_positions)
    end
end

function main()
    blizzards, start_pos, end_pos = read_data("data/24_data.txt")

    first_path = get_fastest_path(blizzards, start_pos, end_pos)
    second_path = get_fastest_path(blizzards, end_pos, start_pos)
    third_path = get_fastest_path(blizzards, start_pos, end_pos)
    @show first_path
    @show first_path + second_path + third_path
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
