using IterTools

function universe_from_lines(lines::Vector{String})::Matrix{Char}
    n_lines = length(lines)
    n_columns = length(lines[1])
    universe = Matrix{Char}(undef, n_lines, n_columns)
    for (i,line) in enumerate(lines)
        universe[i,:] = collect(line)
    end

    return universe
end

function lines_from_universe(universe::Matrix{Char})::Vector{String}
    lines = Vector{String}(undef, size(universe, 1))
    for i in eachindex(lines)
        lines[i] = join(universe[i,:])
    end

    return lines
end

function read_universe()::Matrix{Char}
    lines = readlines("day11_input.txt")
    return universe_from_lines(lines)
end

function expand_rows(universe::Matrix{Char})::Matrix{Char}
    lines = lines_from_universe(universe)
    lines_copy::Vector{String} = []

    for line in lines
        if occursin(r"^[.]+$", line)
            push!(lines_copy, line)
        end
        push!(lines_copy, line)
    end

    return universe_from_lines(lines_copy)
end

function get_galaxy_indices(universe::Matrix{Char})::Vector{CartesianIndex}
    return findall(c -> c == '#', universe)
end

function main()
    universe = read_universe()
    universe = expand_rows(universe)
    universe = expand_rows(universe |> permutedims) |> permutedims

    galaxy_indices = get_galaxy_indices(universe)

    dist = 0
    for (ind1, ind2) in subsets(galaxy_indices, 2)
        dist += Tuple(ind1-ind2) .|> abs |> sum
    end

    println("Sum of distances: $dist")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
