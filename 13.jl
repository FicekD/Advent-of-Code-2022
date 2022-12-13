function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    grouped_lines = [lines[(group_id - 1) * 3 + 1 : group_id * 3 - 1] for group_id in range(1, (length(lines) - 2) ÷ 3 + 1)]
    pairs = Vector{Pair}()
    for group in grouped_lines
        push!(pairs, Pair(map(x -> eval(Meta.parse(x)), group)...))
    end
    return pairs
end

function check_single_order(vec1, vec2)
    valid = nothing
    for i in range(1, max(length(vec1), length(vec2)))
        if i > length(vec1)
            return true
        elseif i > length(vec2)
            return false
        end
        item1, item2 = vec1[i], vec2[i]
        if item1 isa Vector && item2 isa Vector
            valid = check_single_order(item1, item2)
        elseif item1 isa Vector && item2 isa Int
            valid = check_single_order(item1, [item2])
        elseif item1 isa Int && item2 isa Vector
            valid = check_single_order([item1], item2)
        elseif item1 isa Int && item2 isa Int
            if item1 < item2
                valid = true
            elseif item2 < item1
                valid = false
            end
        end
        if valid !== nothing
            return valid
        end
    end
end

function main()
    pairs = read_data("data/13_data.txt")

    result = 0
    for (i, pair) in enumerate(pairs)
        if check_single_order(pair...) result += i end
    end
    @show result

    unwrapped_pairs = []
    for pair in pairs
        push!(unwrapped_pairs, pair.first)
        push!(unwrapped_pairs, pair.second)
    end
    
    divider_packets = [[2]], [[6]]
    push!(unwrapped_pairs, divider_packets[1])
    push!(unwrapped_pairs, divider_packets[2])

    sorted = sort(unwrapped_pairs, lt=check_single_order)
    div1_idx = findfirst(x -> x == divider_packets[1], sorted)
    div2_idx = findfirst(x -> x == divider_packets[2], sorted)
    @show div1_idx * div2_idx
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
