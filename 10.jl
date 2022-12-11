function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    return lines
end

function signal_from_opearations(operations)
    y = [1]
    for op in operations
        if op == "noop"
            push!(y, y[end])
        else
            push!(y, y[end])
            val = parse(Int, split(op, ' ')[2])
            push!(y, y[end] + val)
        end
    end
    return y
end

function power_at(signal, samples)
    power = 0
    for sample in samples
        power += sample * signal[sample]
    end
    return power
end

function render_crt(signal, width, height)
    crt = zeros(Bool, height, width)
    for i in range(1, width * height)
        x, y = (i - 1) % width + 1, (i - 1) ÷ width + 1
        if abs(x - (signal[i] + 1)) <= 1
            crt[y, x] = true
        else
            crt[y, x] = false
        end
    end
    for row in range(1, height)
        println(String([x ? '#' : '.' for x in crt[row, :]]))
    end
    return crt
end

function main()
    operations = read_data("data/10_data.txt")
    signal = signal_from_opearations(operations)

    @show power_at(signal, 20:40:length(signal))
    render_crt(signal, 40, 6)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
