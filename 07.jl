mutable struct File 
    name::String
    is_file::Bool
    size::Int
    parent::Union{File, Nothing}
    children::Union{Vector{File}, Nothing}
end

function find(vec::Vector{File}, name::String)
    for x in vec
        if x.name == name
            return x
        end
    end
end

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    root_file::File = File("root", false, 0, nothing, Vector{File}())
    current_dir = root_file
    for line in lines[2:end]
        if occursin("\$ ls", line)
            continue
        elseif occursin("\$ cd", line)
            argument = line[6:end]
            if argument == ".."
                current_dir = current_dir.parent
            else
                current_dir = find(current_dir.children, argument)
            end
        else
            size_or_dir, name = split(line, ' ')
            if size_or_dir == "dir"
                new_file = File(name, false, 0, current_dir, Vector{File}())
            else
                new_file = File(name, true, parse(Int, size_or_dir), current_dir, nothing)
            end
            push!(current_dir.children, new_file)
        end
    end
    return root_file
end

function set_dir_sizes(dir)
    size = 0
    for file in dir.children
        if file.is_file
            size += file.size
        else
            set_dir_sizes(file)
            size += file.size
        end
    end
    dir.size = size
end

function sum_dir_sizes_upper_thold(dir, thold)
    size_sum = 0
    for file in dir.children
        if ~file.is_file
            if file.size < thold
                size_sum += file.size
            end
            size_sum += sum_dir_sizes_upper_thold(file, thold)
        end
    end
    return size_sum
end

function find_dir_of_closest_size_above(dir, required_space)
    current_candidate = dir
    for file in dir.children
        if ~file.is_file && file.size >= required_space
            new_candidate = find_dir_of_closest_size_above(file, required_space)
            if new_candidate.size <= current_candidate.size
                current_candidate = new_candidate
            end
        end
    end
    return current_candidate
end

function main()
    root_file = read_data("data/07_data.txt")
    set_dir_sizes(root_file)
    
    @show sum_dir_sizes_upper_thold(root_file, 100000)

    total_space = 70000000
    total_req_space = 30000000

    current_space = total_space - root_file.size
    @show find_dir_of_closest_size_above(root_file, total_req_space - current_space).size
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
