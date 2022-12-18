struct Coords 
    x::Int
    y::Int
    z::Int
end

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    x, y, z = Vector{Int}(), Vector{Int}(), Vector{Int}()
    for line in lines
        x_i, y_i, z_i = [parse(Int, x) + 1 for x in split(line, ',')]
        push!(x, x_i); push!(y, y_i); push!(z, z_i)
    end
    x_min, x_max = minimum(x), maximum(x)
    y_min, y_max = minimum(y), maximum(y)
    z_min, z_max = minimum(z), maximum(z)
    tensor = zeros(Int, x_max - x_min + 2 + 2, y_max - y_min + 2 + 2, z_max - z_min + 2 + 2)
    for (x_i, y_i, z_i) in zip(x, y, z)
        tensor[x_i + 1, y_i + 1, z_i + 1] = 1
    end
    return tensor
end

function get_neighbors(tensor, t_size, x, y, z)
    neighbors = Vector{Vector{Int}}()
    if (x - 1) > 0 push!(neighbors, Int[x - 1, y, z]) end
    if (x + 1) <= t_size[1] push!(neighbors, Int[x + 1, y, z]) end
    if (y - 1) > 0 push!(neighbors, Int[x, y - 1, z]) end
    if (y + 1) <= t_size[2] push!(neighbors, Int[x, y + 1, z]) end
    if (z - 1) > 0 push!(neighbors, Int[x, y, z - 1]) end
    if (z + 1) <= t_size[3] push!(neighbors, Int[x, y, z + 1]) end
    return neighbors
end

function count_not_connected_sides(tensor)
    t_size = size(tensor)
    n_not_connected_sides = 0
    for x_i in range(1, t_size[1])
        for y_i in range(1, t_size[2])
            for z_i in range(1, t_size[3])
                if tensor[x_i, y_i, z_i] != 1
                    continue
                end
                n_not_connected_sides += 6 - sum([tensor[n...] for n in get_neighbors(tensor, t_size, x_i, y_i, z_i)])
            end
        end
    end
    return n_not_connected_sides
end

function get_outer_negative_cubes(t_size)
    coords = Vector{Vector{Int}}()
    for x_i in range(1, t_size[1])
        for y_i in range(1, t_size[2])
            for z_i in range(1, t_size[3])
                if (x_i != 1 && x_i != t_size[1] && y_i != 1 && y_i != t_size[2] && z_i != 1 && z_i != t_size[3])
                    continue
                end
                push!(coords, Int[x_i, y_i, z_i])
            end
        end
    end
    return coords
end

function count_outer_not_connected_sides(tensor)
    find_coords(_x, _vec) = findfirst(_c -> _c[1] == _x[1] && _c[2] == _x[2] && _c[3] == _x[3], _vec)
    closed_list = Set{Vector{Int}}()
    open_list = get_outer_negative_cubes(size(tensor))
    n_connected_coords = 0
    while length(open_list) > 0
        coords = popfirst!(open_list)
        push!(closed_list, coords)
        neighbors = get_neighbors(tensor, size(tensor), coords...)
        for neighbor in neighbors
            if tensor[neighbor...] != 0
                n_connected_coords += 1
                continue
            end
            if find_coords(neighbor, open_list) !== nothing || in(neighbor, closed_list)
                continue
            end
            push!(open_list, neighbor)
        end
    end
    return n_connected_coords
end

function main()
    tensor = read_data("data/18_data.txt")
    
    @show count_not_connected_sides(tensor)
    @show count_outer_not_connected_sides(tensor)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
