function parts_in_line(lines, line_index)
    # Returns all parts in a specific line
    parts::Vector{Int} = []
    line = lines[line_index] |> join
    regex = r"\d+"
    if occursin(regex, line)
        for m in eachmatch(regex, line)
            is_match_adj = [is_adjacent_to_symbol(lines, line_index, j) for j in m.offset:(m.offset+length(m.match)-1)]
            if any(is_match_adj)
                push!(parts, parse(Int, m.match))
            end
        end
    end
    return parts
end

function is_adjacent_to_symbol(lines, row_index, column_index)
    potential_symbols::Vector{Char} = []
    if row_index > 1
        push!(potential_symbols, lines[row_index-1][column_index])
        if column_index > 1
            push!(potential_symbols, lines[row_index-1][column_index-1])
        end
        if column_index < length(lines[row_index])
            push!(potential_symbols, lines[row_index-1][column_index+1])
        end
    end
    if row_index < length(lines)
        push!(potential_symbols, lines[row_index+1][column_index])
        if column_index > 1
            push!(potential_symbols, lines[row_index+1][column_index-1])
        end
        if column_index < length(lines[row_index])
            push!(potential_symbols, lines[row_index+1][column_index+1])
        end
    end
    if column_index > 1
        push!(potential_symbols, lines[row_index][column_index-1])
    end
    if column_index < length(lines[row_index])
        push!(potential_symbols, lines[row_index][column_index+1])
    end
    return map(c -> (c != '.') && occursin(r"[[:punct:]]", string(c)), potential_symbols) |> any
end

# First read input into a matrix of chars
M = Vector{Vector{Char}}()
for line in eachline("day3_input.txt")
    push!(M, Vector{Char}(line))
end

part_sum = sum(sum(parts_in_line(M, i)) for i in 1:length(M))
println("Part sum: $part_sum")
