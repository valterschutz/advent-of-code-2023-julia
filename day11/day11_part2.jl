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

function get_galaxy_indices(universe::Matrix{Char})::Vector{CartesianIndex}
    return findall(c -> c == '#', universe)
end

function get_empty_columns(universe)
    findall(v -> !in('#', v), eachcol(universe))  
end

function get_empty_rows(universe)
    findall(v -> !in('#', v), eachrow(universe))  
end

const EXPANSION_FACTOR = 1_000_000

function main()
    universe = read_universe()
    empty_column_ind = get_empty_columns(universe)
    empty_row_ind = get_empty_rows(universe)

    galaxy_indices = get_galaxy_indices(universe)

    dist = 0
    for (ind1, ind2) in subsets(galaxy_indices, 2)
        for i in empty_row_ind
            if min(ind1[1],ind2[1]) < i < max(ind1[1],ind2[1])
                dist += EXPANSION_FACTOR-1
            end
        end
        for j in empty_column_ind
            if min(ind1[2],ind2[2]) < j < max(ind1[2],ind2[2])
                dist += EXPANSION_FACTOR-1
            end
        end
        dist += Tuple(ind1-ind2) .|> abs |> sum
    end

    println("Sum of distances: $dist")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
