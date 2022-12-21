mutable struct MutablePair
    first::Any
    second::Any
end

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    expressions = [MutablePair(split(line, ": ")...) for line in lines]
    return expressions
end

function main()
    expressions = read_data("data/21_data.txt")
    
    while length(expressions) > 1
        for (i, expr1) in enumerate(expressions)
            if !occursin(r"[a-zA-z]", expr1.second)
                for expr2 in expressions
                    expr2.second = replace(expr2.second, expr1.first => "($(expr1.second))")
                end
                popat!(expressions, i)
                break
            end
        end
    end
    @show Int(eval(Meta.parse(expressions[1].second)))
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
