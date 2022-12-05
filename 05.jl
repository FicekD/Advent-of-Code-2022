using DataStructures;

struct Movement
    count::Int
    from::Int
    to::Int
end

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end

    crate_indices = Dict{Int, Int}()
    crate_stacks = Dict{Int, Stack}()
    crate_movements = Vector{Movement}()
    for (i, line) in enumerate(lines)
        if length(crate_indices) == 0
            if '1' in line
                for (j, char) in enumerate(collect(line))
                    if char == ' '
                        continue
                    end
                    stack_id = parse(Int, char)
                    crate_indices[stack_id] = j
                    crate_stacks[stack_id] = Stack{Char}()
                end
                for line_rev in reverse(lines[1:i-1])
                    for (stack_id, index) in crate_indices
                        if line_rev[index] == ' '
                            continue
                        end
                        push!(crate_stacks[stack_id], line_rev[index])
                    end
                end
            end
        else
            matches = collect(eachmatch(r"\d+", line))
            if length(matches) == 0
                continue
            end
            push!(crate_movements, Movement([parse(Int, m.match) for m in matches]...))
        end
    end
    return crate_stacks, crate_movements
end

function main()
    crate_stacks, crate_movements = read_data("data/05_data.txt")
    crate_stacks_orig = deepcopy(crate_stacks)
    for movement in crate_movements
        for _ in range(1, movement.count)
            push!(crate_stacks[movement.to], pop!(crate_stacks[movement.from]))
        end
    end
    @show String([first(crate_stacks[i]) for i in range(minimum(keys(crate_stacks)), maximum(keys(crate_stacks)))])
    
    crate_stacks = crate_stacks_orig
    for movement in crate_movements
        placeholder = Vector{Char}()
        for _ in range(1, movement.count)
            push!(placeholder, pop!(crate_stacks[movement.from]))
        end
        for crate in reverse(placeholder)
            push!(crate_stacks[movement.to], crate)
        end
    end
    @show String([first(crate_stacks[i]) for i in range(minimum(keys(crate_stacks)), maximum(keys(crate_stacks)))])
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
