struct Monkey
    items::Vector{Int}
    update::Base.Callable
    division_test::Int
    target_passed::Int
    target_failed::Int
end

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    grouped_lines = [lines[(group_id - 1) * 7 + 2 : group_id * 7 - 1] for group_id in range(1, (length(lines) - 6) ÷ 7 + 1)]

    monkeys = Vector{Monkey}()
    for lines in grouped_lines
        items = [parse(Int, x) for x in split(split(lines[1], ": ")[2], ", ")]
        update_fn = _x -> eval(Meta.parse(replace(split(lines[2], " = ")[2], r"old" => string(_x))))
        division_test = parse(Int, split(lines[3], "divisible by ")[2])
        passed_test_target = parse(Int, split(lines[4], "monkey ")[2])
        failed_test_target = parse(Int, split(lines[5], "monkey ")[2])
        monkey = Monkey(items, update_fn, division_test, passed_test_target, failed_test_target)
        push!(monkeys, monkey)
    end
    return monkeys
end

function simulate_monkeys(monkeys, rounds, div)
    normalizer = lcm([monkey.division_test for monkey in monkeys]..., div)
    counter = Int128[0 for _ in range(1, length(monkeys))]
    for round in range(1, rounds)
        for (monkey_id, monkey) in enumerate(monkeys)
            for _ in range(1, length(monkey.items))
                item = popfirst!(monkey.items)
                new_val = (monkey.update(item) ÷ div) % normalizer
                target = new_val % monkey.division_test == 0 ? monkey.target_passed : monkey.target_failed
                push!(monkeys[target + 1].items, new_val)
                counter[monkey_id] += 1
            end
        end
    end
    sort!(counter)
    @show counter[end] * counter[end-1]
end

function main()
    monkeys = read_data("data/11_data.txt")
    simulate_monkeys(monkeys, 20, 3)
    
    monkeys = read_data("data/11_data.txt")
    simulate_monkeys(monkeys, 10000, 1)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
