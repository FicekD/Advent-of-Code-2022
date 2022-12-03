function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    bags = Vector{Array}(undef, 0)
    for line in lines
        chars = collect(line)
        push!(bags, chars)
    end
    return bags
end

function get_priority(item::Char)
    if islowercase(item) return Int(item) - 96
    else return Int(item) - 38
    end
end

function main()
    bags = read_data("data/03_data.txt")
    
    sum_of_priorities::Int = 0
    for bag in bags
        midpoint = length(bag) ÷ 2
        inter = intersect(Set(bag[1:midpoint]), Set(bag[midpoint + 1:end]))
        for item in inter
            sum_of_priorities += get_priority(item)
        end
    end
    @show sum_of_priorities

    sum_of_priorities = 0
    for i in 0:(length(bags) ÷ 3) - 1
        grouped_bags = bags[i * 3 + 1:i * 3 + 3]
        inter = intersect(map(Set, grouped_bags)...)
        sum_of_priorities += get_priority(collect(inter)[1])
    end
    @show sum_of_priorities
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
