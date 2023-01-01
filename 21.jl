using Roots

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

function find_equation_for(expressions, solve_for)
    expr_to_solve = expressions[findfirst(x -> x.first == solve_for, expressions)].second
    updated = true
    while updated
        updated = false
        for expr in expressions
            if occursin(expr.first, expr_to_solve)
                expr_to_solve = replace(expr_to_solve, expr.first => "($(expr.second))")
                updated = true
            end
        end
    end
    return expr_to_solve
end

function main()
    expressions = read_data("data/21_data.txt")
    
    result_pt1 = Int(eval(Meta.parse(find_equation_for(expressions, "root"))))
    @show result_pt1
    
    filter!(x -> x.first != "humn", expressions)
    root_expr = expressions[findfirst(x -> x.first == "root", expressions)].second
    exprs_to_solve = split(root_expr, " + ")
    equation_1 = find_equation_for(expressions, exprs_to_solve[1])
    equation_2 = find_equation_for(expressions, exprs_to_solve[2])
    f(x) = eval(Meta.parse(replace(equation_1 * "- ($equation_2)", "humn" => "$x")))
    @show Int(find_zero(f, result_pt1))
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
