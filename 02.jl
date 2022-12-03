struct RPSRound
    opponent::Char
    recommendation::Char
end

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    strategy = Vector{RPSRound}(undef, 0)
    for line in lines
        push!(strategy, RPSRound(line[1] + 23, line[3]))
    end
    return strategy
end

function rock_paper_scissors(rps::RPSRound)
    score = Int(rps.recommendation) - 87
    if rps.recommendation == rps.opponent
        score += 3
    elseif (rps.recommendation == 'X' && rps.opponent == 'Z') ||
           (rps.recommendation == 'Y' && rps.opponent == 'X') ||
           (rps.recommendation == 'Z' && rps.opponent == 'Y')
        score += 6
    end
    return score
end

function main()
    strategy = read_data("data/02_data.txt")
    score = 0
    for r in strategy
        score += rock_paper_scissors(r)
    end
    @show score
    
    score_map = Dict(
        'X' => Dict('X' => 3, 'Y' => 1, 'Z' => 2),
        'Y' => Dict('X' => 1 + 3, 'Y' => 2 + 3, 'Z' => 3 + 3),
        'Z' => Dict('X' => 2 + 6, 'Y' => 3 + 6, 'Z' => 1 + 6)
    )
    score = 0
    for r in strategy
        score += score_map[r.recommendation][r.opponent]
    end
    @show score
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
