function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    
    parse_pair_fn(x) = Pair([parse(Int, a) for a in split(x, '-')]...)
    assignments = Vector{Pair}(undef, 0)
    for line in lines
        ranges = split(line, ',')
        first_elf_range = parse_pair_fn(ranges[1])
        second_elf_range = parse_pair_fn(ranges[2])
        push!(assignments, Pair(first_elf_range, second_elf_range))
    end
    return assignments
end

function main()
    assignments = read_data("data/04_data.txt")
    
    n_complete_overlaps = 0
    n_overlaps = 0
    for assignment_pair in assignments
        first_set = Set(range(assignment_pair.first...))
        second_set = Set(range(assignment_pair.second...))
        if length(union(first_set, second_set)) == max(length(first_set), length(second_set))
            n_complete_overlaps += 1
        end
        if length(intersect(first_set, second_set)) > 0
            n_overlaps += 1
        end
    end
    @show n_complete_overlaps
    @show n_overlaps
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
