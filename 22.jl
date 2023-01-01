import Base.+

mutable struct Position
    x::Int
    y::Int
    dir::Char
end

(+)(pos::Position, pos_add::Pair{Int, Int}) = Position(pos.x + pos_add.first, pos.y + pos_add.second, pos.dir)

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

function main()
    board, instructions = read_data("data/22_data.txt")
    position = Position(findfirst(x -> x == 1, board[1, :] .== '.')[1], 1, 'R')

    face_scores = Dict{Char, Int}('R' => 0, 'D' => 1, 'L' => 2, 'U' => 3)
    position = navigate(board, instructions, position)
    @show position, position.y * 1000 + position.x * 4 + face_scores[position.dir]
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
