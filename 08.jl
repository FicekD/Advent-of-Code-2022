function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    forest = zeros(Int, length(lines), length(lines[1]))
    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(line)
            forest[i, j] = parse(Int, char)
        end
    end
    return forest
end

function get_visible_trees(forest)
    rows, cols = size(forest)

    visible_tree_indices = Set{Tuple{Int, Int}}()
    for i in range(1, rows)
        push!(visible_tree_indices, (i, 1))
        push!(visible_tree_indices, (i, cols))
    end
    for i in range(2, cols-1)
        push!(visible_tree_indices, (1, i))
        push!(visible_tree_indices, (rows, i))
    end

    for i in range(2, rows-1)
        biggest_height_1, biggest_height_2 = forest[i, 1], forest[i, end]
        for (j1, j2) in zip(range(2, cols-1), reverse(range(2, cols-1)))
            if forest[i, j1] > biggest_height_1
                biggest_height_1 = forest[i, j1]
                push!(visible_tree_indices, (i, j1))
            end
            if forest[i, j2] > biggest_height_2
                biggest_height_2 = forest[i, j2]
                push!(visible_tree_indices, (i, j2))
            end
            if biggest_height_1 == 9 && biggest_height_2 == 9
                break
            end
        end
    end
    for j in range(2, cols-1)
        biggest_height_1, biggest_height_2 = forest[1, j], forest[end, j]
        for (i1, i2) in zip(range(2, rows-1), reverse(range(2, rows-1)))
            if forest[i1, j] > biggest_height_1
                biggest_height_1 = forest[i1, j]
                push!(visible_tree_indices, (i1, j))
            end
            if forest[i2, j] > biggest_height_2
                biggest_height_2 = forest[i2, j]
                push!(visible_tree_indices, (i2, j))
            end
            if biggest_height_1 == 9 && biggest_height_2 == 9
                break
            end
        end
    end
    return visible_tree_indices
end

function get_scenic_score(forest, row, col)
    rows, cols = size(forest)
    scores = [0, 0, 0, 0]
    for i in range(row+1, rows)
        scores[1] += 1
        if forest[row, col] <= forest[i, col]
            break
        end
    end
    for i in reverse(range(1, row-1))
        scores[2] += 1
        if forest[row, col] <= forest[i, col]
            break
        end
    end
    for i in range(col+1, cols)
        scores[3] += 1
        if forest[row, col] <= forest[row, i]
            break
        end
    end
    for i in reverse(range(1, col-1))
        scores[4] += 1
        if forest[row, col] <= forest[row, i]
            break
        end
    end
    return prod(scores)
end

function get_scenic_map(forest)
    rows, cols = size(forest)
    scenic_map = zeros(Int, rows, cols)
    for i in range(1, rows)
        for j in range(1, cols)
            scenic_map[i, j] = get_scenic_score(forest, i, j)
        end
    end
    return scenic_map
end

function main()
    forest = read_data("data/08_data.txt")
    
    @show length(get_visible_trees(forest))
    @time get_visible_trees(forest)

    @show max(get_scenic_map(forest)...)
    @time max(get_scenic_map(forest)...)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
