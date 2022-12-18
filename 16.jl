using OrderedCollections

struct Valve
    id::Union{String, Int}
    flow_rate::Int
    leads_to::Union{Set{String}, Set{Int}}
end

mutable struct Path
    path::Set{Int}
    score::Int
end

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    valves = Vector{Valve}()
    for line in lines
        m = collect(match(r"Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)", line))
        id = String(m[1])
        flow_rate = parse(Int, m[2])
        leads_to = Set{String}([String(x) for x in split(m[3], ", ")])
        push!(valves, Valve(id, flow_rate, leads_to))
    end
    name_map = Dict{String, Int}(v.id => i for (i, v) in enumerate(valves))
    valves = Valve[Valve(name_map[v.id], v.flow_rate, Set{Int}([name_map[x] for x in v.leads_to])) for v in valves]
    return valves, name_map["AA"]
end

function calculate_distance_matrix(valves)
    # https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm
    distances = zeros(Float64, length(valves), length(valves))
    for va in valves
        for vb in valves
            if va.id == vb.id
                distances[va.id, vb.id] = 0
            elseif in(vb.id, va.leads_to)
                distances[va.id, vb.id] = 1
            else
                distances[va.id, vb.id] = Inf
            end
        end
    end
    for k in range(1, length(valves))
        for i in range(1, length(valves))
            for j in range(1, length(valves))
                new_dist = distances[i, k] + distances[k, j]
                if distances[i, j] > new_dist
                    distances[i, j] = new_dist
                end
            end
        end
    end
    distances = convert(Matrix{Int}, distances)
    return distances
end

function get_all_paths(from, valves, cost_matrix, limit, current_path, all_paths)
    for valve in valves
        if valve.flow_rate == 0 || in(valve.id, current_path.path) continue end
        updated_limit = limit - (cost_matrix[from, valve.id] + 1)
        if updated_limit < 0 continue end
        new_path = deepcopy(current_path)
        push!(new_path.path, valve.id)
        new_path.score += updated_limit * valve.flow_rate
        get_all_paths(valve.id, valves, cost_matrix, updated_limit, new_path, all_paths)
    end
    push!(all_paths, current_path)
end

function main()
    valves, start_id = read_data("data/16_data.txt")
    dists = calculate_distance_matrix(valves)

    paths = Path[]
    get_all_paths(start_id, valves, dists, 30, Path(Set{Int}(), 0), paths)
    @show maximum([path.score for path in paths])
    
    paths = Path[]
    get_all_paths(start_id, valves, dists, 26, Path(Set{Int}(), 0), paths)
    scores = Int[0]
    for i in range(1, length(paths) - 1)
        for j in range(i + 1, length(paths))
            if isdisjoint(paths[i].path, paths[j].path)
                push!(scores, paths[i].score + paths[j].score)
            end
        end
    end
    @show maximum(scores)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
