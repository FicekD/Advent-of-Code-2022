function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    elves = [Vector{Int32}(undef, 0)]
    for line in lines
        if line == ""
            push!(elves, Vector{Int32}(undef, 0))
        else
            calories = parse(Int32, line)
            push!(elves[end], calories)
        end
    end
    return elves
end

function main()
    elves = read_data("data/01_data.txt")
    
    calories_sums = Vector{Int32}(undef, 0)
    for elf in elves
        push!(calories_sums, sum(elf))
    end
    @show maximum(calories_sums)

    sort_indices = sortperm(calories_sums, rev=true)
    sorted_elves = elves[sort_indices]
    @show sum([sum(x) for x in sorted_elves[1:3]])
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
