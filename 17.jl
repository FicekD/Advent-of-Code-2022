function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    return Int[x == '>' ? 1 : -1 for x in collect(lines[1])]
end

function get_height(chamber)
    h = findlast(x -> x == 1, any(chamber, dims=2))
    return h === nothing ? 0 : h[1]
end

function overlaps(chamber, rock, x, y)
    rows, cols = size(rock)
    try
        overlap = chamber[y-rows+1:y, x:x+cols-1] .* rock
        return sum(overlap) != 0
    catch
        return true
    end
end

function gas_push(chamber, rock, x, y, flows, flow_idx)
    f_i = mod1(flow_idx, length(flows))
    shifted_x = x + flows[f_i]
    x = overlaps(chamber, rock, shifted_x, y) ? x : shifted_x
    return x, flow_idx + 1
end

function simulate_single_fall(chamber, rock, flows, flow_idx)
    rock_rows, rock_cols = size(rock)
    x, y = 3, get_height(chamber) + 4 + rock_rows - 1
    if y > size(chamber)[1]
        chamber = cat(chamber, zeros(Int, size(chamber)...), dims=1)
    end

    x, flow_idx = gas_push(chamber, rock, x, y, flows, flow_idx)
    while true
        if overlaps(chamber, rock, x, y - 1)
            break
        end
        y -= 1
        x, flow_idx = gas_push(chamber, rock, x, y, flows, flow_idx)
    end
    chamber[y-rock_rows+1:y, x:x+rock_cols-1] = chamber[y-rock_rows+1:y, x:x+rock_cols-1] .| rock
    return chamber, flow_idx
end

function solve_n(n, flows, shapes)
    chamber = zeros(Int, 1024, 7)
    flow_idx = 1
    for i in range(1, n)
        chamber, flow_idx = simulate_single_fall(chamber, shapes[mod1(i, length(shapes))], flows, flow_idx)
    end
    return get_height(chamber)
end

function main()
    flows = read_data("data/17_data.txt")
    shapes = Matrix{Int}[x[end:-1:1, :] for x in Matrix{Int}[
        reshape([1, 1, 1, 1], 1, 4),
        reshape([0, 1, 0, 1, 1, 1, 0, 1, 0], 3, 3),
        reshape([0, 0, 1, 0, 0, 1, 1, 1, 1], 3, 3),
        reshape([1, 1, 1, 1], 4, 1),
        reshape([1, 1, 1, 1], 2, 2)
    ]]
    @show solve_n(2022, flows, shapes)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
