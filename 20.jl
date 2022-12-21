import Base.Iterators.countfrom

mutable struct Node
    id::Int
    val::Int
    prev::Union{Nothing, Node}
    next::Union{Nothing, Node}
end

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    
    head = Node(1, parse(Int, lines[1]), nothing, nothing)
    current_node = head
    for i in range(2, length(lines))
        node = Node(i, parse(Int, lines[i]), current_node, nothing)
        current_node.next = node
        current_node = node
    end
    current_node.next = head
    head.prev = current_node
    return head, length(lines)
end

function shift_node(node_to_shift, n)
    if node_to_shift.val == 0
        return
    end
    node_to_shift.prev.next = node_to_shift.next
    node_to_shift.next.prev = node_to_shift.prev
    for _ in range(0, (abs(node_to_shift.val) - 1) % (n - 1))
        if node_to_shift.val < 0
            node_to_shift.next = node_to_shift.prev
            node_to_shift.prev = node_to_shift.prev.prev
        else
            node_to_shift.prev = node_to_shift.next
            node_to_shift.next = node_to_shift.next.next
        end
    end
    node_to_shift.prev.next = node_to_shift
    node_to_shift.next.prev = node_to_shift
end

function find_node(head, id=nothing, val=nothing)
    current_node = head
    while (id !== nothing && current_node.id != id) || (val !== nothing && current_node.val != val)
        current_node = current_node.next
    end
    return current_node
end

function sum_at_from_zero(head, at)
    current_node = find_node(head, nothing, 0)
    vals = Vector{Int}()
    for i in countfrom(0)
        if any(i == a for a in at)
            push!(vals, current_node.val)
            if length(vals) == length(at) break end
        end
        current_node = current_node.next
    end
    return sum(vals)
end

function part1()
    head, n = read_data("data/20_data.txt")

    for i in range(1, n)
        node = find_node(head, i, nothing)
        shift_node(node, n)
    end
    @show sum_at_from_zero(head, [1000, 2000, 3000])
end

function part2()
    head, n = read_data("data/20_data.txt")
    node = head
    for _ in range(1, n)
        node.val = node.val * 811589153
        node = node.next
    end

    for _ in range(1, 10)
        for i in range(1, n)
            node = find_node(head, i, nothing)
            shift_node(node, n)
        end
    end
    @show sum_at_from_zero(head, [1000, 2000, 3000])
end

function main()
    part1()
    part2()
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
