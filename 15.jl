import Base.==

struct Coords
    x::Int
    y::Int
end

(==)(a::Coords, b::Coords) = a.x == b.x && a.y == b.y
dist(a::Coords, b::Coords) = abs(a.x - b.x) + abs(a.y - b.y)

function read_data(path::AbstractString)
    lines = open(path, "r") do io
        readlines(io)
    end
    sensors, beacons = Vector{Coords}(), Vector{Coords}()
    for line in lines
        matches = collect(eachmatch(r"-?\d+", line))
        push!(sensors, Coords(parse(Int, matches[1].match), parse(Int, matches[2].match)))
        push!(beacons, Coords(parse(Int, matches[3].match), parse(Int, matches[4].match)))
    end
    return sensors, beacons
end

function is_covered(sensors, beacons, position, account_for_objects)
    for (sensor, beacon) in zip(sensors, beacons)
        if position == beacon || position == sensor
            return account_for_objects
        end
        d_beacon = dist(sensor, beacon)
        d_inspected = dist(sensor, position)
        if d_inspected <= d_beacon
            return true
        end
    end
    return false
end

function check_n_occupied_tiles_on_row(sensors, beacons, row)
    boundaries_x = Vector{Int}()
    for (sensor, beacon) in zip(sensors, beacons)
        d = dist(sensor, beacon)
        push!(boundaries_x, sensor.x - d, sensor.x + d)
    end
    
    n_covered_tiles = 0
    for x in range(minimum(boundaries_x), maximum(boundaries_x))
        current_coords = Coords(x, row)
        if is_covered(sensors, beacons, current_coords, false)
            n_covered_tiles += 1
        end
    end
    return n_covered_tiles
end

function get_adjacent_points_roi(center, radius, roi_range)
    check_roi = x -> x >= 0 && x <= roi_range
    
    adjacency_radius = radius + 1
    points = Vector{Coords}()
    for dx in range(-adjacency_radius, adjacency_radius)
        if !check_roi(center.x + dx)
            continue
        end
        dy = adjacency_radius - abs(dx)
        if check_roi(center.y + dy)
            push!(points, Coords(center.x + dx, center.y + dy))
        end
        if dy > 0 && check_roi(center.y - dy)
            push!(points, Coords(center.x + dx, center.y - dy))
        end
    end
    return points
end

function find_distress_signal(sensors, beacons, roi_size)
    for (sensor, beacon) in zip(sensors, beacons)
        d = dist(sensor, beacon)
        points = get_adjacent_points_roi(sensor, d, roi_size)
        for point in points
            if !is_covered(sensors, beacons, point, true)
                return 4000000 * point.x + point.y
            end
        end
    end
end

function main()
    sensors, beacons = read_data("data/15_data.txt")

    @show check_n_occupied_tiles_on_row(sensors, beacons, 2000000)
    @show find_distress_signal(sensors, beacons, 4000000)
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
