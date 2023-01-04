import Base.+

mutable struct Position
    x::Int
    y::Int
    dir::Char
    cube::Union{Char, Nothing}
end

struct Connection
    target::Char
    result_axis::Char
    inverted_x::Bool
    inverted_y::Bool
end

(+)(pos::Position, pos_add::Pair{Int, Int}) = Position(pos.x + pos_add.first, pos.y + pos_add.second, pos.dir, pos.cube)

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    board = Matrix{Char}(undef, length(lines) - 2, maximum([length(l) for l in lines[1:end-2]]))
    board[:, :] .= ' '
    for (i, line) in enumerate(lines[1:end-2])
        board[i, 1:length(line)] = collect(line)
    end
    instructions = [i.match for i in collect(eachmatch(r"(\d+|\w)", lines[end]))]
    return board, instructions
end

function navigate(board, instructions, position)
    directions = Dict{Char, Pair{Int, Int}}('R' => Pair(1, 0), 'D' => Pair(0, 1), 'L' => Pair(-1, 0), 'U' => Pair(0, -1))
    rotations = Dict{Char, Dict{Char, Char}}('R' => Dict('R' => 'D', 'D' => 'L', 'L' => 'U', 'U' => 'R'),
                                             'L' => Dict('R' => 'U', 'D' => 'R', 'L' => 'D', 'U' => 'L'))
    board_size = size(board)
    for instr in instructions
        if occursin(r"[R,U,L,D]", instr)
            position.dir = rotations[instr[1]][position.dir]
            continue
        end
        for _ in range(1, parse(Int, instr))
            next_pos = position + directions[position.dir]
            if next_pos.x > board_size[2]
                next_pos.x = findfirst(x -> x == 1, board[next_pos.y, :] .!= ' ')[1]
            elseif next_pos.y > board_size[1]
                next_pos.y = findfirst(x -> x == 1, board[:, next_pos.x] .!= ' ')[1]
            elseif next_pos.x < 1
                next_pos.x = findlast(x -> x == 1, board[next_pos.y, :] .!= ' ')[1]
            elseif next_pos.y < 1
                next_pos.y = findlast(x -> x == 1, board[:, next_pos.x] .!= ' ')[1]
            elseif board[next_pos.y, next_pos.x] == ' ' && position.dir == 'R'
                next_pos.x = findfirst(x -> x == 1, board[next_pos.y, :] .!= ' ')[1]
            elseif board[next_pos.y, next_pos.x] == ' ' && position.dir == 'D'
                next_pos.y = findfirst(x -> x == 1, board[:, next_pos.x] .!= ' ')[1]
            elseif board[next_pos.y, next_pos.x] == ' ' && position.dir == 'L'
                next_pos.x = findlast(x -> x == 1, board[next_pos.y, :] .!= ' ')[1]
            elseif board[next_pos.y, next_pos.x] == ' ' && position.dir == 'U'
                next_pos.y = findlast(x -> x == 1, board[:, next_pos.x] .!= ' ')[1]
            end

            if board[next_pos.y, next_pos.x] == '#'
                break
            else
                position = next_pos
            end
        end
    end
    return position
end

function split_board(board, size)
    A = board[1:size, size + 1:2 * size]
    B = board[1:size, 2 * size + 1:3 * size]
    C = board[size + 1:2 * size, size + 1:2 * size]
    D = board[2 * size + 1:3 * size, 1:size]
    E = board[2 * size + 1:3 * size, size + 1:2 * size]
    F = board[3 * size + 1:4 * size, 1:size]
    cube = Dict{Char, Matrix{Char}}('A' => A, 'B' => B, 'C' => C, 'D' => D, 'E' => E, 'F' => F)
    offsets = Dict{Char, Pair{Int, Int}}('A' => Pair(size, 0), 'B' => Pair(2 * size, 0), 'C' => Pair(size, size), 'D' => Pair(0, 2 * size), 'E' => Pair(size, 2 * size), 'F' => Pair(0, 3 * size))
    return cube, offsets
end

function navigate_cube(cube, instructions, position)
    cube_connections = Dict{Char, Dict{Char, Connection}}(
        'R' => Dict{Char, Connection}(
            'A' => Connection('B', 'x', false, false), 'B' => Connection('E', 'x', true, true), 'C' => Connection('B', 'y', false, true),
            'D' => Connection('E', 'x', false, false), 'E' => Connection('B', 'x', false, false), 'F' => Connection('E', 'y', false, true)),
        'U' => Dict{Char, Connection}(
            'A' => Connection('F', 'x', false, false), 'B' => Connection('F', 'y', false, true), 'C' => Connection('A', 'y', false, true),
            'D' => Connection('C', 'x', false, false), 'E' => Connection('C', 'y', false, true), 'F' => Connection('D', 'y', false, true)),
        'L' => Dict{Char, Connection}(
            'A' => Connection('D', 'x', false, true), 'B' => Connection('A', 'x', true, false), 'C' => Connection('D', 'y', false, false),
            'D' => Connection('A', 'x', false, true), 'E' => Connection('D', 'x', true, false), 'F' => Connection('A', 'y', false, false)),
        'D' => Dict{Char, Connection}(
            'A' => Connection('C', 'y', false, false), 'B' => Connection('C', 'x', true, false), 'C' => Connection('E', 'y', false, false),
            'D' => Connection('F', 'y', false, false), 'E' => Connection('F', 'x', true, false), 'F' => Connection('B', 'y', false, false)),
    )
    directions = Dict{Char, Pair{Int, Int}}('R' => Pair(1, 0), 'D' => Pair(0, 1), 'L' => Pair(-1, 0), 'U' => Pair(0, -1))
    rotations = Dict{Char, Dict{Char, Char}}('R' => Dict('R' => 'D', 'D' => 'L', 'L' => 'U', 'U' => 'R'),
                                             'L' => Dict('R' => 'U', 'D' => 'R', 'L' => 'D', 'U' => 'L'))
    cube_side_size = size(cube[position.cube])[1]
    
    for instr in instructions
        if occursin(r"[R,U,L,D]", instr)
            position.dir = rotations[instr[1]][position.dir]
            continue
        end
        for _ in range(1, parse(Int, instr))
            next_pos = position + directions[position.dir]
            connection = cube_connections[position.dir][position.cube]
            if next_pos.x > cube_side_size || next_pos.x < 1
                next_pos.cube = connection.target
                next_pos.dir = connection.result_axis == 'x' ? (connection.inverted_x ? 'L' : 'R') : (connection.inverted_y ? 'U' : 'D')
                if connection.result_axis == 'x'
                    next_pos.x = connection.inverted_x ? cube_side_size : 1
                    next_pos.y = connection.inverted_y ? cube_side_size - (position.y - 1) : position.y
                else
                    next_pos.x = connection.inverted_x ? cube_side_size - (position.y - 1) : position.y
                    next_pos.y = connection.inverted_y ? cube_side_size : 1
                end
            elseif next_pos.y > cube_side_size || next_pos.y < 1
                next_pos.cube = connection.target
                next_pos.dir = connection.result_axis == 'x' ? (connection.inverted_x ? 'L' : 'R') : (connection.inverted_y ? 'U' : 'D')
                if connection.result_axis == 'x'
                    next_pos.x = connection.inverted_x ? cube_side_size : 1
                    next_pos.y = connection.inverted_y ? cube_side_size - (position.x - 1) : position.x
                else
                    next_pos.x = connection.inverted_x ? cube_side_size - (position.x - 1) : position.x
                    next_pos.y = connection.inverted_y ? cube_side_size : 1
                end
            end

            if cube[next_pos.cube][next_pos.y, next_pos.x] == '#'
                break
            else
                position = next_pos
            end
        end
    end
    return position
end

function main()
    board, instructions = read_data("data/22_data.txt")
    face_scores = Dict{Char, Int}('R' => 0, 'D' => 1, 'L' => 2, 'U' => 3)
    
    position = Position(findfirst(x -> x == 1, board[1, :] .== '.')[1], 1, 'R', nothing)
    position = navigate(board, instructions, position)
    @show position, position.y * 1000 + position.x * 4 + face_scores[position.dir]

    cube, offsets = split_board(board, 50)
    position = Position(findfirst(x -> x == 1, cube['A'][1, :] .== '.')[1], 1, 'R', 'A')
    position = navigate_cube(cube, instructions, position)
    @show position, (position.y + offsets[position.cube].second) * 1000 + (position.x + offsets[position.cube].first) * 4 + face_scores[position.dir]
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
