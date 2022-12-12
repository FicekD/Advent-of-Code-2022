import Base.+, Base.-

struct Coords 
    x::Int16
    y::Int16
end

struct Node
    pos::Coords
    parent::Union{Nothing, Node}
    dist::Int
end

(+)(first::Coords, second::Coords) = Coords(first.x + second.x, first.y + second.y)

is_in(node::Node, nodes::Vector{Node}) = any([n.pos == node.pos for n in nodes])

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    height_map = zeros(Int, length(lines), length(lines[1]))
    start_pos, target_pos = nothing, nothing
    for (row, line) in enumerate(lines)
        for (col, char) in enumerate(collect(line))
            if char == 'S'
                start_pos = Coords(col, row)
                height_map[row, col] = 0
            elseif char == 'E'
                target_pos = Coords(col, row)
                height_map[row, col] = Int('z') - Int('a')
            else
                height_map[row, col] = Int(char) - Int('a')
            end
        end
    end
    return height_map, start_pos, target_pos
end

function pathfinding(height_map, start, target)
    open_list = Node[Node(start, nothing, 0)]
    closed_list = Node[]
    path_to_valley = Inf
    while length(open_list) > 0
        current_node = popfirst!(open_list)
        push!(closed_list, current_node)
        if height_map[current_node.pos.y, current_node.pos.x] == 0 && current_node.dist < path_to_valley
            path_to_valley = current_node.dist
        end
        if current_node.pos == target
            return current_node.dist, path_to_valley
        end
        for dir in Coords[Coords(1, 0), Coords(-1, 0), Coords(0, 1), Coords(0, -1)]
            candidate_node_pos = current_node.pos + dir
            if (candidate_node_pos.x < 1 || candidate_node_pos.x > size(height_map)[2] ||
                candidate_node_pos.y < 1 || candidate_node_pos.y > size(height_map)[1])
                continue
            end
            candidate_node = Node(candidate_node_pos, current_node, current_node.dist + 1)
            diff = height_map[current_node.pos.y, current_node.pos.x] - height_map[candidate_node.pos.y, candidate_node.pos.x]
            if diff > 1 || is_in(candidate_node, closed_list) || is_in(candidate_node, open_list)
                continue
            end
            push!(open_list, candidate_node)
        end
    end
end

function main()
    height_map, start, target = read_data("data/12_data.txt")

    shortest_path, shortest_from_valley = pathfinding(height_map, target, start)
    @show shortest_path, shortest_from_valley

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
