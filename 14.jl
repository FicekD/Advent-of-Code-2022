import Base.+

mutable struct Coords
    x::Int
    y::Int
end

(+)(first::Coords, second::Coords) = Coords(first.x + second.x, first.y + second.y)

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    rock_paths = Vector{Vector{Coords}}()
    for line in lines
        path = [Coords([parse(Int, s_i) for s_i in split(s, ',')]...) for s in split(line, " -> ")]
        push!(rock_paths, path)
    end
    max_x = maximum(map(x -> maximum(map(y -> y.x, x)), rock_paths))
    max_y = maximum(map(x -> maximum(map(y -> y.y, x)), rock_paths))
    rock_map = zeros(Int, max_y + 1, max_x + 1)
    for path in rock_paths
        for i in range(1, length(path) - 1)
            step_x = (path[i+1].x - path[i].x) >= 0 ? 1 : -1
            for x in path[i].x:step_x:path[i+1].x
                step_y = (path[i+1].y - path[i].y) >= 0 ? 1 : -1
                for y in path[i].y:step_y:path[i+1].y
                    rock_map[y + 1, x + 1] = -1
                end
            end
        end
    end
    return rock_map
end

function simulate_sand(rock_map, sand_spawn)
    sand_pos = sand_spawn
    while true
        if rock_map[sand_pos.y + 1, sand_pos.x] == 0
            sand_pos += Coords(0, 1)
        elseif rock_map[sand_pos.y + 1, sand_pos.x - 1] == 0
            sand_pos += Coords(-1, 1)
        elseif rock_map[sand_pos.y + 1, sand_pos.x + 1] == 0
            sand_pos += Coords(1, 1)
        else
            rock_map[sand_pos.y, sand_pos.x] = 1
            break
        end
    end
end

function part1(rock_map)
    i = 0
    while true
        try simulate_sand(rock_map, Coords(501, 1))
        catch 
            break 
        end
        i += 1
    end
    @show i
end

function part2(rock_map)
    extended_map = zeros(Int, size(rock_map)[1] + 2, 2 * size(rock_map)[2])
    extended_map[1:size(rock_map)[1], 1:size(rock_map)[2]] = rock_map
    extended_map[end, :] .= -1

    i = 0
    while extended_map[1, 501] == 0
        simulate_sand(extended_map, Coords(501, 1))
        i += 1
    end
    @show i
end

function main()
    rock_map = read_data("data/14_data.txt")
    
    part1(copy(rock_map))
    part2(copy(rock_map))
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
