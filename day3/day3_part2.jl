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

function adjacent_indices(lines, row_index, column_index)
    v::Vector{Tuple{Int,Int}} = []
    if row_index > 1
        push!(v, (row_index-1, column_index))
        if column_index > 1
            push!(v, (row_index-1,column_index-1))
        end
        if column_index < length(lines[row_index])
            push!(v, (row_index-1,column_index+1))
        end
    end
    if row_index < length(lines)
        push!(v, (row_index+1,column_index))
        if column_index > 1
            push!(v, (row_index+1,column_index-1))
        end
        if column_index < length(lines[row_index])
            push!(v, (row_index+1,column_index+1))
        end
    end
    if column_index > 1
        push!(v, (row_index,column_index-1))
    end
    if column_index < length(lines[row_index])
        push!(v, (row_index,column_index+1))
    end
    return v
end

function adjacent_chars(lines, row_index, column_index)
    return [lines[i][j] for (i,j) in adjacent_indices(lines, row_index, column_index)]
end

function is_adjacent_to_symbol(lines, row_index, column_index)
    adjacent_symbols = adjacent_chars(lines, row_index, column_index)
    return map(c -> (c != '.') && occursin(r"[[:punct:]]", string(c)), adjacent_symbols) |> any
end

function part_numbers(lines)
    P = ones(Int, length(lines), length(lines[1]))

    regex = r"\d+"
    for i in 1:length(lines)
        line = lines[i] |> join
        if occursin(regex, line)
            for m in eachmatch(regex, line)
                # First loop once to check if it IS a part
                is_part = false
                for j in m.offset:(m.offset+length(m.match)-1)
                    if is_adjacent_to_symbol(lines, i, j)
                        is_part = true
                    end
                end
                # If it is, mark all digits as belonging to the part
                for j in m.offset:(m.offset+length(m.match)-1)
                    P[i,j] = parse(Int, m.match)
                end
            end
        end
    end

    return P
end

function gear_ratios(lines, part_numbers)
    g::Vector{Int} = []
    for i in 1:length(lines)
        for j in 1:length(lines[i])
            if lines[i][j] == '*'
                ai = adjacent_indices(lines,i,j)
                # Now the tricky part... We don't want to count the same part
                # twice and therefore have to do a bit of filtering
                filt_ai = []
                for ind in ai
                    if !any((ind[1] == m) && abs(ind[2]-n)==1 for (m,n) in filt_ai) && part_numbers[ind...] > 1
                        push!(filt_ai, ind)
                    end
                end
                part_nums = [part_numbers[m,n] for (m,n) in filt_ai]
                if count(x -> x>1, part_nums) == 2
                    # lines[i][j] is a gear
                    push!(g, reduce(*, part_nums))
                end
            end
        end
    end
    return g
end

# First read input into a matrix of chars
lines = Vector{Vector{Char}}()
for line in eachline("day3_input.txt")
    push!(lines, Vector{Char}(line))
end

# For each char, keep track of what part number it has. If it has no
# part number, use 1
gear_ratio_sum = sum(gear_ratios(lines, part_numbers(lines)))
println("Gear ratio sum: $gear_ratio_sum")
