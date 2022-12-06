function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    signal = lines[1]
    return signal
end

function find_packet(signal::String, num_distinct::Int)
    for i in range(num_distinct, length(signal))
        if length(Set(signal[i-num_distinct+1:i])) == num_distinct
            return i
        end
    end
end

function main()
    signal = read_data("data/06_data.txt")

    @show find_packet(signal, 4)
    @show find_packet(signal, 14)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
